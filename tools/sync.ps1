<#
  키룬 관리표 - GitHub 동기화/배포 스크립트 (git 없이 GitHub API로 동작)

  사용법 (프로젝트 폴더에서):
    powershell -ExecutionPolicy Bypass -File tools\sync.ps1 status
        내 PC와 GitHub의 차이만 보여줌 (아무것도 안 바꿈)
    powershell -ExecutionPolicy Bypass -File tools\sync.ps1 pull
        사이트에서 편집된 데이터(docs/*.json, docs/img/*)를 내 PC로 받아옴
    powershell -ExecutionPolicy Bypass -File tools\sync.ps1 push "수정 내용"
        바뀐 코드/문서 파일만 GitHub에 올림 (1~2분 뒤 사이트 반영)
        ※ docs/*.json 데이터 파일은 기본으로 안 올림 (사이트에서 편집한 내용 덮어쓰기 방지)
    powershell -ExecutionPolicy Bypass -File tools\sync.ps1 push "수정 내용" -IncludeData
        데이터 파일까지 올림. 반드시 먼저 pull 한 뒤 수정했을 때만 사용

  토큰: .secrets\github-token.txt  (LINGFIT-board 저장소 전용 편집키. 출력/공유/업로드 금지)
#>
param(
  [Parameter(Position=0)][ValidateSet('status','pull','push')][string]$Action = 'status',
  [Parameter(Position=1)][string]$Message = '사이트 수정',
  [switch]$IncludeData
)
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Owner = 'kwonster89-beep'; $Repo = 'LINGFIT-board'; $Branch = 'main'
$Root = Split-Path -Parent $PSScriptRoot
$TokenFile = Join-Path $Root '.secrets\github-token.txt'
if (-not (Test-Path $TokenFile)) { throw "토큰 파일이 없어요: $TokenFile" }
$Token = (Get-Content $TokenFile -Raw).Trim()
$H = @{ Authorization = "Bearer $Token"; Accept = 'application/vnd.github+json'; 'User-Agent' = 'LINGFIT-board-sync' }
$Api = "https://api.github.com/repos/$Owner/$Repo"

# GitHub에 올리는 대상 (이 밖의 파일은 무시)
$Include = @('docs', 'tools', '.claude', '.vscode', 'CLAUDE.md', 'README.md', '.gitignore')
$Exclude = '(^|/)(\.secrets|node_modules|import)(/|$)|\.xlsx$|(^|/)~\$'
$DataRe  = '^docs/[^/]+\.json$|^docs/img/'   # 사이트에서 편집되는 데이터

function Get-BlobSha([byte[]]$Bytes) {
  $hdr = [Text.Encoding]::ASCII.GetBytes("blob $($Bytes.Length)`0")
  $all = New-Object byte[] ($hdr.Length + $Bytes.Length)
  [Array]::Copy($hdr, 0, $all, 0, $hdr.Length)
  [Array]::Copy($Bytes, 0, $all, $hdr.Length, $Bytes.Length)
  $sha1 = [Security.Cryptography.SHA1]::Create()
  return (($sha1.ComputeHash($all) | ForEach-Object { $_.ToString('x2') }) -join '')
}
function Get-Remote {
  $t = Invoke-RestMethod -Uri "$Api/git/trees/$($Branch)?recursive=1" -Headers $H
  $m = @{}; foreach ($x in $t.tree) { if ($x.type -eq 'blob') { $m[$x.path] = $x.sha } }; return $m
}
function Get-Local {
  $m = @{}
  foreach ($inc in $Include) {
    $p = Join-Path $Root $inc
    if (-not (Test-Path $p)) { continue }
    foreach ($f in (Get-ChildItem $p -Recurse -File -Force -ErrorAction SilentlyContinue)) {
      $rel = $f.FullName.Substring($Root.Length + 1).Replace('\', '/')
      if ($rel -notmatch $Exclude) { $m[$rel] = $f.FullName }
    }
  }
  return $m
}
function Compare-All {
  $remote = Get-Remote; $local = Get-Local; $rows = @()
  foreach ($rel in $local.Keys) {
    $sha = Get-BlobSha ([IO.File]::ReadAllBytes($local[$rel]))
    if (-not $remote.ContainsKey($rel)) { $rows += [pscustomobject]@{ Path = $rel; State = '내 PC에만 있음'; RemoteSha = $null } }
    elseif ($remote[$rel] -ne $sha) { $rows += [pscustomobject]@{ Path = $rel; State = '내용 다름'; RemoteSha = $remote[$rel] } }
  }
  foreach ($rel in $remote.Keys) {
    if (-not $local.ContainsKey($rel) -and $rel -match '^docs/') { $rows += [pscustomobject]@{ Path = $rel; State = 'GitHub에만 있음'; RemoteSha = $remote[$rel] } }
  }
  return $rows | Sort-Object Path
}

switch ($Action) {
  'status' {
    $d = Compare-All
    if (-not $d) { Write-Host '차이 없음 - 내 PC와 GitHub가 같아요.'; break }
    $d | Format-Table Path, State -AutoSize
  }
  'pull' {
    $n = 0
    foreach ($x in (Compare-All)) {
      if ($x.Path -notmatch $DataRe -or -not $x.RemoteSha) { continue }
      $dest = Join-Path $Root ($x.Path.Replace('/', '\'))
      New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null
      $rh = $H.Clone(); $rh.Accept = 'application/vnd.github.raw+json'
      Invoke-WebRequest -Uri "$Api/git/blobs/$($x.RemoteSha)" -Headers $rh -OutFile $dest -UseBasicParsing
      Write-Host "받음: $($x.Path)"; $n++
    }
    Write-Host "데이터 받기 완료: $($n)개 파일"
  }
  'push' {
    $n = 0
    foreach ($x in (Compare-All)) {
      if ($x.State -eq 'GitHub에만 있음') { continue }
      if ($x.Path -match $DataRe -and $x.Path -match '\.json$' -and -not $IncludeData) { Write-Host "건너뜀(데이터): $($x.Path)  -> 올리려면 -IncludeData"; continue }
      $bytes = [IO.File]::ReadAllBytes((Join-Path $Root ($x.Path.Replace('/', '\'))))
      $body = @{ message = "$Message ($($x.Path))"; content = [Convert]::ToBase64String($bytes); branch = $Branch }
      if ($x.RemoteSha) { $body.sha = $x.RemoteSha }
      $json = $body | ConvertTo-Json -Compress
      Invoke-RestMethod -Method Put -Uri "$Api/contents/$($x.Path)" -Headers $H -ContentType 'application/json; charset=utf-8' -Body ([Text.Encoding]::UTF8.GetBytes($json)) | Out-Null
      Write-Host "올림: $($x.Path)"; $n++
    }
    Write-Host "배포 완료: $($n)개 파일. 1~2분 뒤 https://$Owner.github.io/$Repo/ 에 반영돼요."
  }
}

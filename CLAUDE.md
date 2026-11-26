# 키룬 관리표 (LONGFIT-board) - Claude Code 작업 안내

이 파일은 Claude Code가 이 프로젝트에서 일할 때 먼저 읽는 안내서예요. **답변과 설명은 항상 한국어로**, 사용자는 개발자가 아니므로 쉬운 말로 설명해 주세요.

## 무엇인가
- 무역팀(권성택)이 키룬 공장(厦门云中飞, Xiamen Yunzhongfei)과 공유하는 관리표 웹사이트.
- 예전에 텐센트 문서(腾讯文档) "EGOJIN_키룬云中飞 管理表格"에서 쓰던 표를 옮겨온 것.
- 주소: https://kwonster89-beep.github.io/LONGFIT-board/  (GitHub Pages, main 브랜치의 `/docs` 폴더)
- 저장소: https://github.com/kwonster89-beep/LONGFIT-board (공개 저장소. 검색엔진 차단(noindex)만 되어 있음)
- 서버·DB 없음. `docs/index.html` 한 파일(HTML+CSS+순수 JavaScript)이 `docs/*.json`을 읽어서 표를 그림.
- 참고: 같은 내용의 이전 버전 사이트 `kwonster89-beep/mat-bundle`이 따로 있음. **그 저장소는 절대 건드리지 말 것.**

## 폴더 구조
```
docs/                 ← 실제 웹사이트 (이 폴더만 Pages로 공개)
  index.html          화면 + 로직 전부
  delivery.json       납기표 (交期表) + 설 전 출고 계획(年前出货计划)
  parts.json          부속 신청 (配件申请表)
  samples.json        샘플 현황 (样品状况)
  data.json           매트 합포 기준표 (기구별 합포 매트 종류/수량)
  stock.json          매트 재고: 기준일, 시작 수량(묶음), 보낸 기록, PI별 수동 수정, 차감 끝 PI
  shipments.json      매트 재고용 PI 목록 (무역허브에서 갱신)
  img/                표에 붙는 사진 (jpg, 긴 변 1400px 이하)
tools/
  sync.ps1            GitHub 받기/올리기 (git 없이 동작)
  bookmarklet.js      무역허브 "키룬 PI 갱신" 북마크 원본
  bookmarklet.txt     북마크 URL에 붙여넣는 한 줄 버전
.secrets/             편집키(GitHub 토큰). 절대 출력·커밋·업로드 금지
```

## 데이터 형식
- delivery.json: `{ updated, notice, rows:[{group, product, pi, due, actual, note, done, hl, images[]}], plan:[{product, pi, model, date, note, hl}] }`
  - group = 보라색 묶음 제목(예 "704W 蓝牙"), due = 요청 납기, actual = 공장 실제 납기, hl = 노란 강조
- parts.json: `{ updated, notice, rows:[{product, parts, date, status, note, ko, done, hl, images[]}] }`
  - parts = 부속 내역(여러 줄), status = 진행 상황, note = 미발송·메모, ko = 한국어 메모
- samples.json: `{ updated, rows:[{product, date, ready, note, done, images[]}] }`
- 날짜는 텐센트 문서 형식 그대로 `YY.MM.DD` 문자열 (예 "26.12.15"). 비교할 땐 normD()로 0채움 후 문자열 비교.
- done=true 인 행은 "완료" (텐센트 문서에서 접어둔/숨긴 행). 기본 화면은 진행 중만 보이고, "전체" 버튼으로 완료 포함.
- images 경로는 docs 기준 상대경로 (예 "img/p-r22-c4-1.jpg").
- 매트 재고 규칙: 묶음 단위(기구 1대 = 1묶음, EVA 4/5/6장·TPE 3/5장 묶음). 남은 수량 = 시작 수량 + 보낸 수량 − 선적일(ETD)이 잡힌(포장 끝난) PI 대수. `closed`에 있는 PI는 이미 시작 수량에 반영된 것이라 빼지 않음. 선적일 미정 PI는 "생산 중 발주까지 차감 후" 줄에서 마이너스로 미리 보여줌.

## 화면 규칙 (지켜야 할 것)
- 한국어/중국어 병기: 라벨은 `<span class="ko">한국어</span><span class="cn">中文</span>`. 상단 "한/中·한국어·中文" 토글이 body 클래스로 숨김 처리. 새 문구도 꼭 두 언어로.
- 표 데이터 자체(상품명, 비고 등)는 공장과 같이 보므로 중국어 원문 그대로 둠.
- 기본 색/스타일은 index.html 상단 CSS 변수 사용. 이모지 쓰지 않기.
- 휴대폰에서도 보이게: 표는 `.tablebox` 안에서 가로 스크롤.
- localStorage 키는 `longfitboard_*` 사용 (mat-bundle 사이트와 같은 도메인이라 `matsite_*`를 쓰면 서로 꼬임).

## 편집 방식 (두 가지)
1. **사이트에서 직접 편집**: 사장님 브라우저에만 편집키가 저장되어 있어서 "✎ 편집" 버튼이 보임 → 수정 → 저장하면 GitHub API로 docs/*.json이 바로 바뀜. 사진도 편집 모드에서 업로드(docs/img/u-*.jpg).
2. **Claude Code로 코드 수정**: 화면/기능 변경은 docs/index.html을 고치고 tools/sync.ps1로 올림.

⚠️ 데이터(docs/*.json)는 사이트에서 수시로 바뀌므로, 내 PC 파일이 옛날 것일 수 있음.
- 작업 시작 전 항상: `powershell -ExecutionPolicy Bypass -File tools\sync.ps1 pull`
- 코드만 고쳤으면: `... sync.ps1 push "무엇을 고쳤는지"` (json은 자동으로 건너뜀)
- 데이터를 직접 고쳤으면: pull → 수정 → `... sync.ps1 push "설명" -IncludeData`
- 올린 뒤 1~2분 기다렸다가 사이트 주소에 `?v=숫자`를 붙여 열어서 확인 (브라우저 캐시 때문)

## 로컬 미리보기
- VS Code 확장 "Live Server" → docs/index.html 우클릭 → Open with Live Server (설정에서 루트를 /docs 로 해둠).
- 로컬에서는 내 PC의 json을 먼저 읽고, 없으면 GitHub의 데이터를 읽음. (file:// 로 그냥 열면 브라우저 보안 때문에 GitHub 데이터를 읽음)

## 무역허브 PI 갱신 (매트 재고 탭)
- 사이트가 무역허브(trade.egojinsvc.com)를 직접 읽을 수 없음(CORS). 그래서 무역허브 탭에서 북마크 "키룬 PI 갱신"(tools/bookmarklet.*)을 누르면 `/api/trade-purchase-orders`를 읽어 `#sync=` 해시로 사이트에 넘기고, 사이트가 shipments.json을 저장함.
- 필터: 취소/더미 PI 제외, 입고 완료 제외, ETD가 기준일(stock.json base_date) 이전이면 제외, data.json에 있는 어드민코드만.

## 텐센트 문서 다시 가져오기 (필요할 때만)
1. 텐센트 문서에서 파일 → 导出为 → 本地Excel(.xlsx)로 받아 `import/` 폴더에 넣기 (import/는 업로드 안 됨)
2. 시트 → JSON 대응: 交期表→delivery.json(A~E열, 보라색 칸=group, 91행 아래 "年前出货计划"=plan), 配件申请表→parts.json(A~F열), 样品状况→samples.json(B~F열).
3. 숨겨진(접힌) 행 = done:true. 그림은 걸린 행에 붙여서 jpg로 줄여 docs/img/에 저장.
4. 주의: 텐센트에서 받은 xlsx의 styles.xml에 빈 `<fill/>`이 있어 openpyxl이 못 읽음 → `<fill><patternFill patternType="none"/></fill>`로 바꿔서 읽기.
5. 덮어쓰기 전에 사이트에서 편집된 내용과 차이를 사용자에게 보여주고 확인받기.

## 하지 말 것
- .secrets/ 안의 토큰 값을 화면에 출력하거나 파일/커밋에 넣지 않기.
- mat-bundle 저장소/사이트 수정 금지.
- 사용자 확인 없이 json 데이터를 대량 삭제·덮어쓰기 금지.

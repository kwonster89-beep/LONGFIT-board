---
description: 고친 내용을 GitHub에 올려 사이트에 반영
argument-hint: [무엇을 고쳤는지 한 줄 설명]
---
1. `powershell -ExecutionPolicy Bypass -File tools\sync.ps1 status` 로 올라갈 파일을 확인하세요.
2. docs/index.html 을 고쳤다면 브라우저에서 깨지지 않는지 문법을 다시 한번 점검하세요 (한/中 병기 규칙 포함).
3. 이번 작업에서 docs/*.json 데이터를 직접 고친 경우에만 `-IncludeData` 를 붙이세요. 그 전에 pull 을 했는지 확인하세요.
4. 실행: `powershell -ExecutionPolicy Bypass -File tools\sync.ps1 push "$ARGUMENTS"` (설명이 비어 있으면 변경 내용을 보고 한국어로 한 줄 요약해서 넣기)
5. 1~2분 뒤 https://kwonster89-beep.github.io/kirun-board/?v=<현재시각숫자> 에서 반영됐는지 확인하는 방법을 안내해 주세요.

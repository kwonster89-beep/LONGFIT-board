---
description: 사이트에서 편집된 최신 데이터를 내 PC로 받기
---
1. `powershell -ExecutionPolicy Bypass -File tools\sync.ps1 status` 로 차이를 확인해서 한국어로 요약해 주세요.
2. `powershell -ExecutionPolicy Bypass -File tools\sync.ps1 pull` 을 실행해 docs/*.json 과 docs/img 를 받으세요.
3. 받은 파일 목록과, 눈에 띄는 변경(행 추가/삭제 등)을 짧게 알려 주세요.

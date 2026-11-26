---
description: 텐센트 문서에서 내려받은 엑셀(import/*.xlsx)을 사이트 데이터로 변환
---
CLAUDE.md 의 "텐센트 문서 다시 가져오기" 규칙을 따라 주세요.
1. import/ 폴더의 가장 최근 .xlsx 를 찾으세요. 없으면 텐센트 문서에서 내려받는 방법을 안내하고 멈추세요.
2. 먼저 `tools\sync.ps1 pull` 로 사이트의 최신 데이터를 받으세요.
3. 엑셀을 읽어 delivery/parts/samples 형식으로 변환하되, 바로 덮어쓰지 말고 기존 데이터와의 차이(추가/변경/삭제 행)를 표로 보여주고 확인을 받으세요.
4. 확인 후 저장하고, 사진은 docs/img 에 jpg로 줄여 넣은 뒤 `push "텐센트 문서 반영" -IncludeData` 로 올리세요.

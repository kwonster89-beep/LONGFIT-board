# 키룬 관리표 (LINGFIT-board)

키룬 공장(云中飞)과 함께 보는 납기표 · 부속 신청 · 샘플 현황 · 매트 재고 사이트.

- 사이트: https://kwonster89-beep.github.io/LINGFIT-board/
- 화면: 한국어/중국어 전환 가능, 로그인 없이 보기
- 편집: 편집키가 저장된 브라우저에서 "✎ 편집" 버튼

## VS Code + Claude Code로 고치는 법
1. VS Code에서 이 폴더(내 문서\LINGFIT-board)를 연다.
2. Claude Code 창에 하고 싶은 걸 한국어로 말한다. 예) "납기표에 '선적항' 칸 추가해줘"
3. 다 고치면 `/deploy` 라고 입력 → GitHub에 올라가고 1~2분 뒤 사이트에 반영.

자주 쓰는 명령 (Claude Code 창에서):
- `/pull` 사이트에서 바뀐 데이터를 내 PC로 받기
- `/deploy` 고친 내용 사이트에 올리기
- `/import-tencent` 텐센트 문서 엑셀을 다시 가져오기

자세한 규칙은 CLAUDE.md 참고.

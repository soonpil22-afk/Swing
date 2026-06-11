# CLAUDE.md

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

## 5. No Closing Colons (Korean Output)

**End Korean sentences with a period, not a colon.**

When the user writes in Korean, your output is also Korean:
- Don't end sentences with `:` even if the next line is a list or example.
- LLMs trained on English docs leak the colon habit into Korean. Catch it.
- The test: every Korean sentence terminator should be `.`, `?`, or `!` — not `:`.
- Colons are fine inside code, key-value pairs, or labels. Not as sentence enders.

## 6. File Header Comments in Korean

**First line of every new source file: a one-line Korean comment stating its role.**

When creating a new file:
- TypeScript/JavaScript: `// 사용자 인증 상태를 관리하는 Context Provider`
- Python: `# KIS API 호출을 비동기로 래핑하는 클라이언트`
- SQL: `-- 일별 집계 결과를 저장하는 머티리얼라이즈드 뷰`
- Place it directly under required directives (`'use client'`, `'use server'`, shebang).
- Skip config files (`*.config.ts`, `package.json`, etc.).

Why: agents read files selectively, not whole codebases. A one-line Korean header gives instant context so the next session (human or agent) can navigate without re-reading the entire file.

## 7. Plan + Checklist + Context Notes

**Before any non-trivial task, produce three artifacts. Don't start coding without them.**

- **Plan** — what we're building and why.
- **Checklist** (`checklist.md`) — concrete tasks as checkboxes. Tick as you go.
- **Context Notes** (`context-notes.md`) — decisions made during the work and the reasoning behind them. Append continuously.

If the user gives only a plan and asks you to start coding, stop and ask: "Should I create the checklist and context notes first?" The next session — yours or someone else's — needs the notes to pick up where you left off without re-deriving every decision.

## 8. Run Tests Before Marking Complete

**If you touched code, run the tests before saying "done".**

- `npm test`, `pytest`, `cargo test`, whatever the project uses — run it.
- If tests pass, report results. If they fail, fix and re-run.
- No test setup? At minimum, verify the project builds/compiles.
- Run tests proactively, before the user signals "끝", "완료", "다 됐어" — not after.

This is the step LLMs skip most often. Treat it as non-negotiable.

## 9. Semantic Commits

**Commit when one logical change is complete. Don't wait for the user to ask.**

- The test: "Can I describe this commit in one sentence?" If yes, commit. If no, the changes are still mixed — split them.
- Good: "auth 미들웨어 추가". Bad: "auth 추가하고 UI도 고치고 버그도 수정" (split into 3).
- Don't accumulate 20 unrelated edits and lose the ability to roll back individually.
- Don't commit just to commit — meaningful units only.

Note: For solo prototypes or throwaway scripts, group commits loosely if it slows you down. The point is reversibility, not ceremony.

## 10. Read Errors, Don't Guess

**Read the actual error/log line. Don't pattern-match from memory.**

When something fails:
- Read the full error message and stack trace.
- Check the actual log output, not what you assume it should say.
- Don't apply a "common fix" before confirming the cause.
- If unclear, add a print/log to verify state — then fix.

This is the step LLMs skip most often after "run tests". They guess from error keywords and apply the most-recent-pattern fix. That's how a one-line bug becomes a three-file refactor.

---

# SwingTiger 프로젝트 스타일·구조 규칙

이 앱(Flutter + Firebase 배달/정산)에서 **항상 지킬 관례**. 새 코드는 아래를 따른다.

## A. 디자인 토큰 (색·그림자·여백)
- 색/그림자/여백은 **`tokens.dart` 단일 출처**에서만 가져온다. 파일마다 상단에 private 별칭을 둔다.
  - 예: `const _teal = kTeal;` `const _elevated = kElevated;` `const _surface = kSurface;`
- 팔레트: `kAppBg` `kPanel` `kSurface` `kElevated` `kChip` `kText`/`kText2`/`kText3` `kTeal` `kPurple` `kPink` `kAmber` `kRed`. 그림자: `kCardShadow` `kPanelShadow`.
- **하드코딩 색(Color(0x...)) 금지** — 토큰에 없으면 토큰에 추가하고 쓴다.
- 미사용 토큰은 그때그때 삭제한다 (내가 만든 orphan은 내가 정리).

## B. 테두리·경계선
- 중립 테두리/구분선 = **`_elevated`**, 두께 **1**, 투명도 없음(솔리드).
- 강조 테두리 = 의미가 있을 때만 accent색(활성=`_teal`, 경고/액션=`_pink`/`_amber`, 보조=`_purple`). **의미 없으면 `_elevated`**.

## C. 여백(갭) 시맨틱
- `kGapInner = 8`, `kGapCard = 8`, `kGapSection = 10`.
- 뒤로가기 헤더 ↔ 경계선 = `kGapInner`(8). 경계선 ↔ 첫 카드/탭 = `kGapSection`(10). 카드 ↔ 카드 = `kGapCard`(8).
- 패널 헤더 밑 경계선은 **끝에 닿지 않게** 좌우 여백을 준다(예: `dividerInset: 15`).

## D. 텍스트·버튼 관례
- 뒤로가기 헤더 제목 글씨 크기 = **19** (메인 "안녕하세요" 헤더 제외).
- 금액 표기: **숫자는 강조색 유지, 단위 " 원"만 `_text` 색**. `Text.rich`로 분리한다.
- "초기화" 버튼 = pink 글씨+테두리. "조회" 버튼 = teal 아웃라인. 공제 타입(매일/주1회/매월) 버튼 = 아웃라인 스타일에 accent teal/pink/purple.
- 한 화면 안에서 같은 역할 버튼은 **크기를 통일**한다(기사·관리자 대응 버튼 등).

## E. 파일·구조
- 관리자 서브페이지는 `admin_common.dart`의 **`adminPanelScaffold(context, title, child, {dividerColor, dividerInset})`** 로 감싼다.
- 기사 서브페이지는 `driver_common.dart`의 `pageHeader` / `showInfoDialog` 등 공용 위젯을 쓴다.
- 파일이 커지면 **기능별 파일로 분리**한다. 다른 파일에서 참조할 클래스는 **public**으로(앞 `_` 제거).
- 새 소스 파일 첫 줄: 역할을 적은 **한 줄 한글 주석**.

## F. Firestore 데이터 패턴
- 실시간 구독은 `.snapshots()` 스트림을 **State 필드로 한 번만 생성**한다(build마다 재구독 금지 → 무한로딩·깜빡임 방지).
- 쿼리에서 **`where(필드A) + orderBy(필드B)` 조합 금지**(컬렉션마다 복합 인덱스 필요). 대신 단일 `where`로 받아 **화면에서 정렬**한다. 동일 필드 equality `where` 여러 개는 허용.
- 시각 비교는 기기 로컬 `DateTime.now()` 기준. "오늘 이후" 같은 기준은 24시간제 `.hour`로 충분(오후11시=23시 동일).

## G. 병렬 구조 (리스비 ↔ 기타)
- 같은 흐름의 변형은 **종류 디스크립터 1개 + 제네릭 빌더**로 처리한다. 코드 복붙 금지.
  - 예: `_Kind/_DKind(prefix, collection, title, icon, accent)` 를 만들고 `리스비`/`기타`를 같은 함수로 렌더.
  - users 필드는 `${prefix}Type/Amount/Cycle/StartDate/LastDate/NewAlert`, 회차 컬렉션은 `${prefix}_payments`.

## H. 커밋·테스트
- 한 논리 단위가 끝나면 의미 있는 단위로 커밋. 메시지 끝에 `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>`.
- 코드 건드리면 `flutter analyze` 로 **error 0** 확인 후 완료(경고는 prefer_const 등 info만 허용).
- 로컬 웹 동시 확인: `run_web.bat`(서버) → `open_windows.bat`(관리자·기사 2창). 코드 반영은 콘솔에서 `R`(hot restart).

## I. 보안 (출시 전)
- `google-services.json` / `firebase_options.dart`의 웹 apiKey는 **클라이언트 공개키**(비밀 아님). GitHub secret-scan 경고는 false positive.
- Firestore 규칙은 컬렉션별로 둔다. **새 컬렉션을 추가하면 규칙에도 같이 추가**한다(안 하면 permission-denied로 무한로딩). 출시 전 role 기반으로 강화 예정.

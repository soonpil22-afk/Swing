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

## 11. 페이지 코드 정리 컨벤션 (Flutter 페이지 공통)

**모든 페이지 파일(`*_page.dart`, `main.dart`)은 동일한 구조로 상수·로직을 정리한다.** 기존 코드 순서보다 이 컨벤션을 우선한다.

### 상수(디자인 토큰) 구조 — 파일 상단
1. **공통 색 팔레트** 블록: 여러 섹션이 공유하는 색(`_surface`·`_teal` 등) + 카드 그림자. 헤더는 `// ═══ 공통 색 팔레트 (모든 섹션 공유) ═══`.
2. 그 아래 **번호 섹션**을 화면에 보이는 순서(위→아래)대로 배치:
   `1. 전체배경 → 2. 메인배경 → 3. … → N.` (서브는 `7-1`, `7-2` 식).
   섹션 헤더는 `// ═══ N. 섹션명 ═══`.

### 요소별 묶음 (★ 핵심)
- **글씨**: 그 글씨의 `크기 + 색`을 같이. **글씨와 숫자는 따로** 둔다.
- **숫자**(아이콘·박스 크기/여백): 따로.
- **카드 / 탭 / 버튼**: 그 요소의 `크기 + 여백 + 색 + 테두리`를 같이.
- ❌ **금지**: "색 전부 모음", "크기 전부 모음" 같은 통뭉치 분류.
- 인라인 하드코딩 값(`fontSize: 14` 등)은 가능한 한 토큰으로 빼서 해당 요소 코드에서 바로 수정 가능하게 한다.

### 로직(위젯/메서드/클래스) 헤더
- 각 위젯·페이지 클래스 앞에 **같은 번호 헤더**를 단다: `// ── N. 섹션명 (로직) ──`.
- Dart는 메서드가 클래스 안에 있어야 하므로 물리적 이동 대신 **번호 헤더로 상수↔로직을 매칭**한다.

### 안전 절차 (큰 파일 재정리 시)
- 시작 전 **git 커밋(체크포인트)** 으로 되돌릴 지점 확보.
- 상수는 **블록 단위로 이동**(값 손실/오타 방지). 한 줄씩 새로 타이핑하지 말 것.
- **매 단계 `flutter analyze`** 로 에러 0 확인. 이동으로 생긴 **orphan 토큰 제거**.
- 이모지 금지(아이콘만). 한글 문장은 마침표로 끝낸다(콜론 금지).

> 기준 예시: `driver_page.dart`(가장 잘 정리된 본). 새 섹션이 생기면 다음 번호(`N+1`)로 이어 붙인다.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

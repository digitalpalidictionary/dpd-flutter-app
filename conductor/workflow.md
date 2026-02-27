# Project Workflow

## Guiding Principles

1. **The Plan is the Source of Truth:** All work must be tracked in `plan.md`
2. **The Tech Stack is Deliberate:** Changes to the tech stack must be documented in `tech-stack.md` *before* implementation
3. **Test Data and Logic Only:** Write tests for data processing, database queries, and business logic. No tests for UI/UX — the user provides visual feedback directly.
4. **User Experience First:** Every decision should prioritize user experience
5. **Non-Interactive & CI-Aware:** Prefer non-interactive commands. Use `CI=true` for watch-mode tools (tests, linters) to ensure single execution.

## Task Workflow

All tasks follow a strict lifecycle:

### Standard Task Workflow

1. **Select Task:** Choose the next available task from `plan.md` in sequential order

2. **Mark In Progress:** Before beginning work, edit `plan.md` and change the task from `[ ]` to `[~]`

3. **Write Failing Tests (Red Phase) — Data/Logic Tasks Only:**
   - If the task involves data processing, database queries, or business logic: create tests that define expected behavior.
   - If the task is purely UI/UX: skip directly to step 4.
   - **CRITICAL:** For testable tasks, run the tests and confirm they fail before proceeding.

4. **Implement to Pass Tests (Green Phase):**
   - Write the application code.
   - For data/logic tasks: run tests and confirm all pass.
   - For UI tasks: implement and move on.

5. **Refactor (Optional but Recommended):**
   - With passing tests (if applicable), refactor for clarity and simplicity.
   - Rerun tests to ensure they still pass after refactoring.

6. **Verify Coverage (Data/Logic Only):**
   - Run coverage for data and logic modules only.
   - Target: >80% coverage for data/logic code.

7. **Document Deviations:** If implementation differs from tech stack:
   - **STOP** implementation
   - Update `tech-stack.md` with new design
   - Add dated note explaining the change
   - Resume implementation

8. **Commit Code Changes:**
   - Stage all code changes related to the task.
   - Commit with a short conventional commit message. No body, no footer. Just the summary line.

9. **Attach Task Summary with Git Notes:**
   - **Step 9.1: Get Commit Hash:** Obtain the hash of the *just-completed commit* (`git log -1 --format="%H"`).
   - **Step 9.2: Draft Note Content:** Create a detailed summary for the completed task.
   - **Step 9.3: Attach Note:** Use `git notes add -m "<note content>" <commit_hash>`.

10. **Get and Record Task Commit SHA:**
    - **Step 10.1: Update Plan:** Read `plan.md`, find the completed task, update from `[~]` to `[x]`, append first 7 chars of commit hash.
    - **Step 10.2: Write Plan:** Write the updated content back to `plan.md`.

11. **Commit Plan Update:**
    - Stage `plan.md` and commit: `conductor(plan): Mark task '<task name>' as complete`

### Phase Completion Verification and Checkpointing Protocol

**Trigger:** This protocol is executed immediately after a task is completed that also concludes a phase in `plan.md`.

1.  **Announce Protocol Start:** Inform the user that the phase is complete and the verification protocol has begun.

2.  **Ensure Test Coverage for Phase Changes (Data/Logic Only):**
    -   **Step 2.1: Determine Phase Scope:** Read `plan.md` to find the Git commit SHA of the *previous* phase's checkpoint.
    -   **Step 2.2: List Changed Files:** Execute `git diff --name-only <previous_checkpoint_sha> HEAD`.
    -   **Step 2.3: Verify and Create Tests:** For each data/logic code file (not UI widgets or screens), verify a corresponding test file exists. Create missing tests for data/logic only.

3.  **Execute Automated Tests with Proactive Debugging:**
    -   Announce the exact shell command before execution.
    -   If tests fail, attempt to fix a **maximum of two times**. If still failing, stop and ask the user.

4.  **Propose Manual Verification Plan:**
    -   Generate step-by-step instructions for the user to visually verify the phase on device/emulator.
    -   Include specific commands to launch the app and what to look for.

5.  **Await Explicit User Feedback:**
    -   Ask: "**Does this meet your expectations? Please confirm with yes or provide feedback.**"
    -   **PAUSE** and await response.

6.  **Create Checkpoint Commit:**
    -   Stage all changes. Commit: `conductor(checkpoint): Checkpoint end of Phase X`

7.  **Attach Verification Report using Git Notes:**
    -   Draft and attach a verification report to the checkpoint commit.

8.  **Get and Record Phase Checkpoint SHA:**
    -   Update `plan.md` phase heading with `[checkpoint: <sha>]`.

9.  **Commit Plan Update:**
    -   Commit: `conductor(plan): Mark phase '<PHASE NAME>' as complete`

10. **Announce Completion.**

### Quality Gates

Before marking any task complete, verify:

- [ ] All data/logic tests pass (if applicable)
- [ ] Code coverage meets requirements for data/logic modules (>80%)
- [ ] Code follows project's code style guidelines
- [ ] Type safety is enforced
- [ ] No linting or static analysis errors
- [ ] No security vulnerabilities introduced

## Development Commands

### Setup
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Daily Development
```bash
flutter run                    # Run on device/emulator
flutter analyze                # Static analysis
flutter test                   # Run tests
```

### Before Committing
```bash
flutter analyze
flutter test
```

## Testing Requirements

### What to Test
- Database queries and DAOs
- Data parsing and transformation (JSON unpack, search normalization)
- Business logic (Pāḷi sort order, Velthuis transliteration, search flow)
- Provider logic (state transformations)

### What NOT to Test
- Widget rendering and layout
- Screen navigation
- Visual styling
- User interaction flows (the user tests these manually)

### Test Conventions
- Use `flutter_test` framework
- Mock database and external dependencies
- Test both success and failure cases

## Commit Guidelines

### Format
```
<type>: <short description>
```

Short and sweet. No body, no footer, no essays.

### Types
- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code restructuring
- `test`: Adding/updating tests
- `chore`: Maintenance tasks
- `style`: Formatting only
- `docs`: Documentation only

### Examples
```bash
git commit -m "feat: synced style with webapp"
git commit -m "fix: missing button in entry display"
git commit -m "feat: add root family expandable section"
git commit -m "refactor: simplify search provider logic"
```

## Definition of Done

A task is complete when:

1. Code implemented to specification
2. Data/logic tests written and passing (if applicable)
3. Code passes `flutter analyze`
4. Changes committed with proper message
5. Git note with task summary attached to the commit

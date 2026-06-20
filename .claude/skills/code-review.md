# Code Review

When asked to review any code change, before committing or pushing, perform this self-review.

## Review Checklist

### 1. Correctness
- [ ] Does the code do what it claims to do?
- [ ] Are all edge cases handled? (null/undefined, empty input, errors)
- [ ] Is error handling present where needed?

### 2. ArkTS Compliance (Critical for this project)
- [ ] No `{ ...obj }` spread — all field assignments explicit
- [ ] No `obj[key]` index access — all keys compile-time
- [ ] No `any`/`unknown` types
- [ ] No `catch (e: Error)` type annotation
- [ ] No `this` in arrow callbacks without `self = this`
- [ ] All imports at file top
- [ ] No regex with `\` escape — use `.split().join()`

### 3. Project Conventions
- [ ] Comments in Chinese
- [ ] `@Builder` not used for bindPopup
- [ ] SidePanel root is `Row()`
- [ ] WebView uses `loadUrl(data:)` not `loadData()`
- [ ] `PanGesture` uses delta pattern (NOT cumulative offsetX)

### 4. Code Quality
- [ ] Clear variable/function names
- [ ] No duplicated logic — extract shared utilities
- [ ] Props use correct decorator (`@Prop` vs `@Link`)
- [ ] Classes used in `@State` are `@Observed`

## Output Format

```
## Review: [filename]

### Issues Found
- **Critical:** [description] — must fix
- **Important:** [description] — should fix
- **Minor:** [description] — optional

### Verdict: APPROVED / REQUEST_CHANGES
```

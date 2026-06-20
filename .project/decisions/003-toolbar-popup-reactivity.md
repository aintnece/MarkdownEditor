# ADR 003: Independent @State Booleans for Toolbar Popups

**Date**: 2026-06-20
**Status**: accepted
**Context**: Toolbar has 20+ buttons, each needs a hover/delay popup. Multiple approaches
failed: `@Builder` wrappers broke `bindPopup` reactivity; `Record<string,boolean>` type
is disallowed in ArkTS strict mode; `showInSubWindow:false` caused clipping with `Placement.Top`.

**Decision**:
1. One `@State isPopupN: boolean = false` per button (20 individual booleans)
2. `Placement.Top` + `showInSubWindow:true` to escape container clipping
3. 400ms `setTimeout` delay before showing (avoids flicker on hover-through)
4. No `@Builder` for popup content — inline `Text()` directly in `bindPopup .popup()`

**Consequences**:
- Verbose (20 individual state variables) but stable
- No Arrow functions in event handlers — use method references
- `.showInSubWindow:true` is essential — without it, tall tooltips are clipped
- Future cleanup: could extract a `ToolbarButton` component to reduce duplication

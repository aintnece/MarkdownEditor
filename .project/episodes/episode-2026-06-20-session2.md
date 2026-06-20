# Episode 2026-06-20 (Session 2)

## Export Feature Fixes (12 compilation errors)

**Commit chain**: `bc37e4d` → `eac9194` → `4bbf2bd` → `ea7a905` → `b04748c` → `2a8103e`

### Round 1: Imports + layout + types (`bc37e4d`)
- Missing imports: `webview`, `MarkdownParser`, `HtmlRenderer`, `DocumentNode`
- `build()` dual root → `Stack` wrapper
- `arkts-no-any-unknown`: explicit type annotations on parser/ast/renderer/html
- `print.print()` arg: `string` → `string[]`
- `fileIo.openSync` return: `:number` removed

### Round 2: File API + print API fixes (`eac9194`)
- `openSync()` returns `File`, not `number` → use `file.fd`
- `print.print()` needs 4-param adapter overload: `(jobName, adapter, PrintAttributes, context)`
- Correct enum: `PrintPageType`, not `PrintPageSize`

### Round 3: ExportSheet layout in Stack (`4bbf2bd`)
- Content pushed off-screen: merged overlay+content columns
- `@Link` → `@Prop` for themeColors
- Toolbar tooltip: '导出HTML' → '导出文档'

### Round 4: Wire previewController (`ea7a905`)
- `MarkdownPreview` creates controller internally, never exposed
- Added `onControllerReady` callback
- EditorPage captures in `buildPreviewOnly` + `buildSplitView`

### Round 5: Print adapter failure → window.print() (`b04748c`)
- `createWebPrintDocumentAdapter` needs custom `onStartLayoutWrite` implementation
- Logs confirmed `window.print()` works: `PrintNow ret=0`, `page_count=2`, `WriteResultCallback=0`
- Simulator print dialog UI can't complete save — real device should work

### Round 6: Simplify export options (`2a8103e`)
- Removed PDF option (merged into Print)
- 3 options: MD save, HTML save, Print/PDF via browser dialog

## UI Polish

### SidePanel tooltips (`499ef97`)
- Added bindPopup to tab buttons (📁📑🕐) + collapse button (◀)

### SidePanel collapsed state expand button (`0e54e15` → `343ec89`)
- Added ▶ expand button at bottom of collapsed sidebar
- Removed conflicting Column-level onClick
- Double-click bug emerged: first click after startup works, subsequent need two

### Emoji icon cleanup (`fab50f2`)
- 👁 → ◎ (preview)
- ↩ → ↶ (undo)
- ↪ → ↷ (redo)
- ✏️ → ✎ (edit)

### SidePanel root unification (`1deb20c`)
- Was: Column(collapsed) / Row(expanded) — type switch
- Now: always Row, conditional content area
- Changed @Link→@Prop for themeColors
- Did NOT fix double-click

### Double-click root cause (`f4e6dd0`)
- Logs show bindPopup creates/destroys subwindow 106 constantly
- Hot areas from popup subwindow intercept clicks on nearby buttons
- Removed ALL bindPopup from SidePanel → clicks work on first try
- Confirmed: popup subwindows are the cause

## Current State
- Export: MD/HTML save works, Print/PDF calls window.print() (simulator limited)
- SidePanel: expand/collapse works (without tooltips), content tabs functional
- Toolbar: all buttons with bindPopup tooltips, icons polished
- KaTeX: local rendering via onInterceptRequest
- Split view: drag divider works

## Decisions Made
1. `window.print()` over `createWebPrintDocumentAdapter` — simpler, works at native level
2. SidePanel `@Prop` over `@Link` — one-way sufficient
3. Unified Row root over Column/Row switch — avoids ArkUI state reset risk
4. bindPopup conflicts with click events in sidebar — needs alternative approach

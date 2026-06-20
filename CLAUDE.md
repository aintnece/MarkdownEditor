# MarkdownEditor — HarmonyOS NEXT Markdown Editor

ArkTS + ArkUI project for HarmonyOS NEXT (API 12). DevEco Studio 5.0+.

## Knowledge Base & Project Tracking

- **Obsidian vault**: `/workspace/obsidian-vault/鸿蒙开发/` — API refs, guides, 踩坑记录
- **Project state**: `/workspace/MarkdownEditor/.project/status.md` — current completion
- **Active task**: `/workspace/MarkdownEditor/.project/active-task.md` — what to work on next
- **Decisions**: `/workspace/MarkdownEditor/.project/decisions/` — design rationale

Before starting any task, read active-task.md and relevant Obsidian 踩坑记录.
After completing work:
1. Update .project/status.md — mark completed items with `[x]`
2. If design decisions were made, write a note to .project/decisions/YYYY-MM-DD-title.md
3. Write a brief episode note: date, what was done, rationale
4. Update active-task.md if work continues
5. Commit with conventional format: `type: Chinese description`

## Project Structure

```
entry/src/main/ets/
  pages/EditorPage.ets    — Main editor page (3 view modes)
  components/
    Toolbar.ets           — 20-button toolbar with bindPopup
    SidePanel.ets         — Collapsible file browser (root MUST be Row)
    MarkdownEditor.ets    — TextArea-based editor
    MarkdownPreview.ets   — WebView-based preview with KaTeX
    ExportSheet.ets       — Export options sheet
    StatusBar.ets         — Cursor position, save state
  core/
    MarkdownParser.ts     — Custom Markdown → AST parser
    HtmlRenderer.ts       — AST → HTML renderer with KaTeX math
    MarkdownAST.ts        — AST type definitions
  services/
    ThemeService.ts       — Light/dark theme
    FileService.ts        — File I/O
    ExportService.ts      — HTML/PDF export
  utils/                  — Utility functions
```

## Key Commands

- Build: Open in DevEco Studio, click Run (or `hvigorw assembleHap`)
- No CLI build on Windows — must use DevEco Studio GUI
- Clean build when line numbers in errors don't match: Build → Clean Project → Rebuild

## ArkTS Strict Mode Rules (Critical)

ArkTS is a severely restricted subset of TypeScript. These WILL cause compile errors:

| ❌ Forbidden | ✅ Use Instead |
|---|---|
| `{ ...obj }` spread | Explicit field-by-field assignment |
| `obj[key]` index access | `obj.field` — all keys must be compile-time |
| `Record<string, T>` / `Map` | Class with named fields + if-else chains |
| `any` / `unknown` | Specific types |
| `catch (e: Error)` | `catch (e)` — no type annotation |
| `Object.values(enum)` | if-else comparison chain |
| `value as Type` | `Number()`, `String()` etc. |
| `this` in arrow callbacks | `const self = this` then use `self` |
| class inside struct/component | Move to file level |
| `interface { [k:string]: T }` | class with named fields |
| import mid-file | All imports at file top |
| `\n` concatenation in strings | Template literals (backticks) |

## Regular Expressions — Use split/join Instead

Regex with `\` escape is unreliable in ArkTS. Always use `.split().join()`:

```typescript
// ❌ result.replace(/\\^\\{([^}]*)\\}/g, '^($1)')
// ✅ 
result = result.split('^{').join('^(')
  .split('_{').join('_(')
  .split('}').join(')')
```

## bindPopup Rules

- ❌ Cannot be inside `@Builder` — must be inline in `build()`
- Must use `placement: Placement.Top` + `showInSubWindow: true`
- Each button needs its own `@State`, own timer, own if-else logic
- Use 400ms debounced hide to prevent hover-loop (uses `clearTimeout`)

## Spread Operator Silent Failure

`{ ...obj1, ...obj2 }` sometimes compiles but silently produces undefined fields.
Always use explicit field-by-field assignment:

```typescript
this.config = {
  enableMath: opts.enableMath !== undefined ? opts.enableMath : DEFAULT.enableMath,
  enableTables: opts.enableTables !== undefined ? opts.enableTables : DEFAULT.enableTables,
}
```

## SidePanel — Root Must Be Row

```typescript
build() {
  Row() {  // ← MUST be Row at root, NOT Column
    Column() { /* content */ }
  }
}
```

## WebView Preview Rules

- Always use `loadUrl(data: URI)` — NEVER `loadData()`
- HTML must be 100% self-contained — no CDN `<link>`, `<script src>`, `@font-face url()`
- Use `onInterceptRequest` to serve local rawfile resources
- Binary files (fonts): use `resourceManager.getRawFileContentSync()`
- Set `focusable(false)` on WebView to prevent stealing TextArea focus
- Handle CORS: set `Access-Control-Allow-Origin` header in `onInterceptRequest`
- Use `runJavaScript` for incremental updates (preserves scroll position)
- Set `lastRendered` ONLY on success; reset on failure

## PanGesture — Cumulative offsetX

`PanGesture.offsetX` is cumulative across gestures. Use delta pattern:

```typescript
let lastPanX = 0
.onActionUpdate((event: GestureEvent) => {
  const delta = event.offsetX - lastPanX
  this.translateX += delta
  lastPanX = event.offsetX
})
```

## Import Conventions

```typescript
import { router } from '@kit.ArkUI'
import { webview } from '@kit.ArkWeb'
import { resourceManager } from '@kit.LocalizationKit'
import { fileIo } from '@kit.CoreFileKit'
import { promptAction } from '@kit.ArkUI'
```

## Style Conventions

- Component files use `.ets` extension
- Pure logic utilities use `.ts`
- Classes used for struct @State must be `@Observed`
- Use `@Link` for child-to-parent, `@Prop` for one-way parent-to-child
- `aboutToAppear()` for initialization, NOT constructor
- `@Builder` for reusable UI fragments (but NOT for bindPopup)
- Comments in Chinese

## NAS Development Gotcha

- `ohpm install` fails on NAS Z: drive (non-NTFS) — develop on C:\ or F:\
- Symbolic link failures = NTFS required for HarmonyOS toolchain

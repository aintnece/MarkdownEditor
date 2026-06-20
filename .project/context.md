# Project Context: MarkdownEditor

**Last updated**: 2026-06-20

## Overview

A full-featured Markdown editor and compiler for HarmonyOS Next (API 12),
targeting phones, tablets, and 2-in-1 devices. GFM + LaTeX math (KaTeX)
with real-time split-pane preview.

## Tech Stack

- **Language**: ArkTS (strict mode, no `any`/index signatures/object spread)
- **Core engine**: TypeScript (`MarkdownTokenizer` → `MarkdownParser` → `HtmlRenderer`)
- **UI framework**: ArkUI (declarative, `@Component`/`@Builder`/`@State`/`@Link`)
- **Preview**: `WebView` (`loadUrl(data:)`), `@ohos.web.webview`
- **Math rendering**: KaTeX v0.16.22 (local fonts via `onInterceptRequest` + `$rawfile`)
- **File access**: `@ohos.file.picker`, `@ohos.file.fs`, `@ohos.file.statvfs`
- **Print/PDF**: `@ohos.print`, `controller.createWebPrintDocumentAdapter()`
- **State management**: `AppStorage`, `@StorageProp`, `@StorageLink`

## IDE & Build

- **IDE**: DevEco Studio 5.0 (build 2600461), Windows 11
- **Build tool**: hvigor (Huawei Gradle wrapper)
- **SDK**: OpenHarmony API 12, OHPM
- **Build command**: `./hvigorw clean assembleHap` (or click Build in DevEco)
- **hdc path**: `E:\Program Files\DevEco Studio\sdk\default\openharmony\toolchains\hdc.exe`
- **Git**: GitHub `aintnece/MarkdownEditor` (pushed via HTTP/1.1 proxy)

## Project Structure

```
entry/src/main/ets/
├── app.ets                        ← App entry
├── core/                          ← Render engine
│   ├── MarkdownAST.ts             ← AST node types
│   ├── MarkdownTokenizer.ts       ← Lexer
│   ├── MarkdownParser.ts          ← Parser (AST builder)
│   └── HtmlRenderer.ts            ← AST → HTML (with math fallback)
├── components/                    ← UI widgets
│   ├── MarkdownEditor.ets         ← Editor pane (TextArea)
│   ├── MarkdownPreview.ets        ← WebView preview pane
│   ├── Toolbar.ets                ← Toolbar with 20+ buttons + popups
│   ├── SidePanel.ets              ← File tree / outline
│   ├── StatusBar.ets              ← Word count, line info
│   └── ExportSheet.ets            ← Export format picker (MD/HTML/PDF/Print)
├── pages/
│   ├── Index.ets                  ← File list / welcome page
│   └── EditorPage.ets             ← Main editor (split pane, toolbar, status)
└── services/
    ├── ExportService.ts           ← Multi-format export
    ├── FileService.ts             ← File operations
    └── ThemeService.ts            ← Theme switching
utils/
    └── PreferencesManager.ts      ← User preferences
```

## Key Conventions

- No arrow expressions as event handlers (ArkTS strict mode)
- No object spread `{...obj}` — use explicit field assignment
- Regex usage is restricted — prefer `indexOf`/`substring`/`split`/`join` for Unicode safety
- `@BuildParam/@BuilderParam` for custom composition
- `class NavData` for router params (no object literal route params)
- `bindPopup` with `@State` boolean for tooltips (not `@Builder` for button content)

## Architecture

**Editor/Preview split**: User types in `TextArea` → debounced (300ms) → HTML rendered via `HtmlRenderer`
→ `WebView.loadUrl(data:text/html,...)` or `runJavaScript('updateContent(...)')` for in-place updates.

**KaTeX rendering**: Resources bundled in `rawfile/katex/`. `WebView` loads HTML with KaTeX CDN URLs →
`onInterceptRequest` intercepts CDN requests → redirects to `$rawfile` → serves local font files with
correct MIME types and CORS headers. `split('$rawfile').join('resource://rawfile')` for path normalization.

## Known Footguns

- `WebView` focus steals cursor → must set `.focusable(false)` on preview `WebView`
- `data:text/html` loads → content shows on every render, but scroll resets → fixed with `runJavaScript` update method
- `onInterceptRequest` font MIME must be `font/woff2` explicitly
- `Placement.Top` + `bindPopup` → content clipped in default mode, must use `showInSubWindow:true`
- `@Builder` breaks `bindPopup` reactivity → inline all buttons directly with `@State` variable per button
- `{...DefaultConfig}` silently fails in ArkTS → must manually copy fields
- Template strings (backtick) for test docs → more reliable than `\n` concatenation
- `@ohos.file.picker.DocumentViewPicker` for save dialogs
- `@ohos.print.print()` for PDF/print — requires `ohos.permission.PRINT`

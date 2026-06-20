# 2026-06-21: WYSIWYG Phase 1

## What was done
- Downloaded @toast-ui/editor@3.2.2 via npm, bundled with esbuild as IIFE (564KB min)
- Bundled CSS (base + dark theme, 179KB min)
- Created WysiwygEditor.ets — WebView-based WYSIWYG editor component
  - Self-contained HTML served via onInterceptRequest
  - JS bundle & CSS served from rawfile/editor/
  - JS→ArkTS sync bridge: Image request → onInterceptRequest → callback
  - Debounced change events (500ms)
  - setMarkdown() / getMarkdown() API via runJavaScript
  - Theme switching support (data-theme attribute)
- Updated Toolbar.ets: added ViewMode.Wysiwyg enum value + WYSIWYG button (≡ icon)
- Updated EditorPage.ets: added buildWysiwygOnly() builder, mode switching logic
- Moved project files to NAS: /data/Online Document/MarkdownEditor/

## Design decisions
- Used esbuild IIFE format (--global-name=toastui) instead of ESM — simpler for WebView
- Image request sync over console.log — more reliable in HarmonyOS WebView
- URL-based communication limited to 8KB; long documents truncated in sync

## Files changed
- NEW: entry/src/main/ets/components/WysiwygEditor.ets (343 lines)
- NEW: entry/src/main/resources/rawfile/editor/tui-editor-bundle.js (578KB)
- NEW: entry/src/main/resources/rawfile/editor/tui-editor-full.min.css (179KB)
- MOD: entry/src/main/ets/components/Toolbar.ets (added WYSIWYG button + ViewMode)
- MOD: entry/src/main/ets/pages/EditorPage.ets (added WYSIWYG mode + builder)

# ADR 002: In-Place WebView Update via runJavaScript

**Date**: 2026-06-19
**Status**: accepted
**Context**: Previously, every content change triggered `loadUrl(data:text/html,...)` which reset
the WebView scroll position to top — extremely annoying for users editing long documents.
Alternative approaches: saving/restoring scroll position via loadUrl parameters; using loadData.

**Decision**: Use `runJavaScript('updateContent(...)')` to update preview content in-place.
The HTML template is loaded once via `loadUrl`, and subsequent updates inject new content
into a `<div id="content">` via a JavaScript call.

**Consequences**:
- Scroll position preserved across edits
- Lower flicker (no full page reload)
- Requires a `updateContent` JS function defined in the initial HTML template
- Content must be properly escaped for JavaScript string literal (single quotes, backslashes)
- Size limit: `runJavaScript` has a practical limit (~1MB); very large documents may need fallback to `loadUrl`

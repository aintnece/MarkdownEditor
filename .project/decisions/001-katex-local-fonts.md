# ADR 001: Use onInterceptRequest for Local KaTeX Font Delivery

**Date**: 2026-06-19
**Status**: accepted
**Context**: KaTeX CSS and fonts initially loaded from CDN, but `data:text/html` origin is null,
causing CDN requests to fail (CORS / mixed content). Alternative: bundle all KaTeX assets in
the app and serve locally.

**Decision**: Bundle KaTeX CSS and fonts in `rawfile/katex/`. Generate HTML that references
CDN URLs (to satisfy KaTeX CSS's font-face declarations), then intercept those requests
via `WebView.onInterceptRequest` and serve local files via `$rawfile`.

**Consequences**:
- No network dependency for math rendering
- `onInterceptRequest` must handle font MIME types explicitly (`font/woff2`, `font/woff`, `font/ttf`)
- CORS headers must be set on intercepted responses
- `$rawfile` path processing: `split('$rawfile').join('resource://rawfile')`
- Download script needed to fetch KaTeX v0.16.22 (woff2 + woff + ttf for all 6 font variants)

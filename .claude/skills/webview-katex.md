# WebView Preview with KaTeX

Complete battle-tested pattern for WebView-based rendering with KaTeX math support. Applies to any component that displays rendered HTML with math in a WebView.

## Core Rules (MUST Follow)

1. **Always `loadUrl(data: URI)`** — NEVER `loadData()`
2. **HTML must be 100% self-contained** — no CDN `<link>`, `<script src>`, `@font-face url()`
3. **Use `onInterceptRequest`** to serve local rawfile resources
4. **`focusable(false)`** on WebView to prevent stealing TextArea focus
5. **`lastRendered` only on success** — reset on failure

## Template

```typescript
import { webview } from '@kit.ArkWeb'
import { resourceManager } from '@kit.LocalizationKit'

@Component
export struct Preview {
  @Prop @Watch('onContentChange') content: string = ''
  private controller: webview.WebviewController | null = null
  private resMgr: resourceManager.ResourceManager | null = null
  private isReady: boolean = false
  private debounceTimer: number | null = null
  private lastRendered: string = ''
  private bodyOnly: boolean = false
  private currentHtml: string = ''

  aboutToAppear(): void {
    this.controller = new webview.WebviewController()
    this.resMgr = getContext().resourceManager
  }

  onContentChange(): void {
    if (!this.isReady) return
    if (this.debounceTimer !== null) clearTimeout(this.debounceTimer)
    this.debounceTimer = setTimeout(() => {
      this.debounceTimer = null
      this.doRender()
    }, 300)
  }

  private doRender(): void {
    const bodyHtml = renderer.renderBody(ast)
    if (!this.bodyOnly) {
      // First load: full page via loadUrl
      this.currentHtml = renderer.renderFullPage(ast)
      this.controller?.loadUrl(APP_URL + '?t=' + Date.now())
      this.bodyOnly = true
    } else {
      // Incremental: runJavaScript preserves scroll
      const escaped = encodeURIComponent(bodyHtml)
      this.controller?.runJavaScript(`
        var article = document.querySelector('.markdown-body');
        if (article) {
          article.innerHTML = decodeURIComponent('${escaped}');
          renderMathInElement(article, {
            delimiters: [{left: '$$', right: '$$', display: true},
                         {left: '$', right: '$', display: false}],
            throwOnError: false
          });
        }
      `)
    }
    // ★ Only on success
    this.lastRendered = this.content
  }

  build() {
    Web({ src: 'about:blank', controller: this.controller! })
      .javaScriptAccess(true)
      .domStorageAccess(true)
      .focusable(false)
      .onInterceptRequest((event) => {
        const url = event?.request?.getRequestUrl()
        if (!url) return null

        // Intercept KaTeX CDN → local rawfile
        if (url.startsWith('https://unpkg.com/katex@')) {
          const path = url.substring('https://unpkg.com/katex@'.length)
          const resp = new webview.WebResourceResponse()
          resp.setResponseData($rawfile('katex/' + path))
          resp.setResponseEncoding('utf-8')
          if (path.endsWith('.css')) resp.setResponseMIMEType('text/css')
          else if (path.endsWith('.js')) resp.setResponseMIMEType('application/javascript')
          return resp
        }

        // ★ Font files: use resourceManager
        if (path.endsWith('.woff2') || path.endsWith('.woff') || path.endsWith('.ttf')) {
          const data: Uint8Array = this.resMgr!.getRawFileContentSync('katex/' + path)
          // ★ Must copy to avoid shared buffer offset
          const copy: Uint8Array = new Uint8Array(data.byteLength)
          copy.set(data)
          const resp = new webview.WebResourceResponse()
          resp.setResponseData(copy.buffer)
          resp.setResponseMIMEType('font/woff2')
          // ★ CORS header required
          resp.setResponseHeader([{
            headerKey: 'Access-Control-Allow-Origin',
            headerValue: 'https://markdown.local'
          }])
          return resp
        }
        return null
      })
      .onPageEnd(() => {
        if (!this.isReady) {
          this.isReady = true
          if (this.content !== '' && this.content !== this.lastRendered) {
            this.doRender()
          }
        }
      })
  }
}
```

## Font MIME Types

| ❌ Wrong | ✅ Correct |
|---|---|
| `application/font-woff2` | `font/woff2` |
| `application/font-woff` | `font/woff` |
| `application/x-font-ttf` | `font/ttf` |

## setResponseHeader API (Correct Usage)

```typescript
// ✅ Only valid form: inline object array
resp.setResponseHeader([{
  headerKey: 'Access-Control-Allow-Origin',
  headerValue: 'https://markdown.local'
}])

// ❌ All of these fail:
// resp.setResponseHeader('Header: value')
// resp.setResponseHeader(name, value, overwrite)
// const h: webview.Header = {...}
```

## CORS Notes

`onInterceptRequest` returns font data but browser still checks CORS:
- Page origin ≠ font URL origin → must add header
- Without: fonts silently fail → `ARKWEB-CONSOLE` shows `OnRequestError -2`
- Debug: filter DevEco log by tag `ARKWEB-CONSOLE`

## Checklist (When WebView is black/not rendering)

1. [ ] Using `loadUrl(data:)` not `loadData()`
2. [ ] No external CDN references in HTML
3. [ ] `lastRendered` set only on success, reset on failure
4. [ ] `isReady` guard — first render in `onPageEnd`
5. [ ] Clean Build if error line numbers don't match

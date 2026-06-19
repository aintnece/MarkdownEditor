import { webview } from '@kit.ArkWeb';
import { MarkdownParser } from '../core/MarkdownParser';
import { HtmlRenderer } from '../core/HtmlRenderer';
import { ThemeColors } from '../services/ThemeService';

const KATEX_PREFIX = 'https://unpkg.com/katex@0.16.22/';

@Component
export struct MarkdownPreview {
  @Prop @Watch('onContentChange') content: string;
  @Link themeColors: ThemeColors;
  @Prop fontSize: number;
  @Prop isDark: boolean;

  onRendered?: () => void;

  private controller: webview.WebviewController | null = null;
  private isReady: boolean = false;
  private debounceTimer: number | null = null;
  private lastRendered: string = '';

  aboutToAppear(): void {
    this.controller = new webview.WebviewController();
  }

  onContentChange(): void {
    if (!this.isReady) return;
    if (this.debounceTimer !== null) clearTimeout(this.debounceTimer);
    this.debounceTimer = setTimeout(() => {
      this.debounceTimer = null;
      this.doRender();
    }, 300);
  }

  build() {
    Web({ src: 'about:blank', controller: this.controller! })
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeColors.previewBg)
      .javaScriptAccess(true)
      .domStorageAccess(true)
      .focusable(false)
      .onInterceptRequest((event) => {
        if (!event) return;
        const request = event.request;
        const url: string = request.getRequestUrl();
        // 拦截 KaTeX CDN 请求，返回本地 rawfile 中的资源
        if (url.startsWith(KATEX_PREFIX)) {
          const path: string = url.substring(KATEX_PREFIX.length);
          const mimeType: string = this.getMimeType(path);
          const resp = new WebResourceResponse();
          resp.setResponseEncoding('utf-8');
          resp.setResponseMimeType(mimeType);
          resp.setResponseCode(200);
          resp.setReasonMessage('OK');
          try {
            resp.setResponseData($rawfile('katex/' + path));
            resp.setResponseIsReady(true);
            return resp;
          } catch (e) {
            console.error('Rawfile not found: katex/' + path);
          }
        }
        return null;
      })
      .onPageEnd(() => {
        if (!this.isReady) {
          this.isReady = true;
          if (this.content !== '' && this.content !== this.lastRendered) this.doRender();
        }
        if (this.onRendered) this.onRendered();
      })
  }

  private getMimeType(path: string): string {
    if (path.endsWith('.css')) return 'text/css';
    if (path.endsWith('.js')) return 'text/javascript';
    if (path.endsWith('.woff2')) return 'font/woff2';
    if (path.endsWith('.woff')) return 'font/woff';
    if (path.endsWith('.ttf')) return 'font/ttf';
    return 'text/html';
  }

  private doRender(): void {
    if (this.content === this.lastRendered) return;
    try {
      const parser = new MarkdownParser(this.content);
      const ast = parser.parse();
      const renderer = new HtmlRenderer({ darkMode: this.isDark, fontSize: this.fontSize });
      const html = renderer.renderFullPage(ast);
      const encoded = encodeURIComponent(html);
      this.lastRendered = this.content;
      this.controller?.loadUrl('data:text/html;charset=UTF-8,' + encoded);
    } catch (err) {
      console.error('[MarkdownPreview] render error: ' + String(err));
      this.lastRendered = '';
    }
  }
}

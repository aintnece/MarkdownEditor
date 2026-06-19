import { webview } from '@kit.ArkWeb';
import { resourceManager } from '@kit.LocalizationKit';
import { MarkdownParser } from '../core/MarkdownParser';
import { HtmlRenderer } from '../core/HtmlRenderer';
import { ThemeColors } from '../services/ThemeService';

const APP_URL = 'https://markdown.local/preview';
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
  private currentHtml: string = '';

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
    Web({ src: APP_URL, controller: this.controller! })
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeColors.previewBg)
      .javaScriptAccess(true)
      .domStorageAccess(true)
      .focusable(false)
      .onInterceptRequest((event) => {
        if (!event) return null;
        const url: string = event.request.getRequestUrl();
        // 拦截自定义应用页面请求 → 返回动态 HTML
        if (url.startsWith(APP_URL)) {
          const resp = new WebResourceResponse();
          resp.setResponseData(this.currentHtml);
          resp.setResponseEncoding('utf-8');
          resp.setResponseMimeType('text/html');
          resp.setResponseCode(200);
          resp.setReasonMessage('OK');
          resp.setResponseIsReady(true);
          return resp;
        }
        // 拦截 KaTeX CDN 请求 → 返回本地 rawfile
        if (url.startsWith(KATEX_PREFIX)) {
          const path: string = url.substring(KATEX_PREFIX.length);
          const resp = new WebResourceResponse();
          resp.setResponseEncoding('utf-8');
          resp.setResponseMimeType(this.getMimeType(path));
          resp.setResponseCode(200);
          resp.setReasonMessage('OK');
          try {
            // 用组件级的 resourceManager 读取字体二进制数据
            const ctx: resourceManager.ResourceManager = getContext(this).resourceManager;
            const rawPath: string = 'katex/' + path;
            const data: Uint8Array = ctx.getRawFileContentSync(rawPath);
            // 创建精确字节拷贝的 ArrayBuffer
            const copy: Uint8Array = new Uint8Array(data.byteLength);
            copy.set(data);
            resp.setResponseData(copy.buffer);
            // CORS: 允许自定义域名加载字体
            resp.setResponseHeader('Access-Control-Allow-Origin: https://markdown.local');
            resp.setResponseIsReady(true);
            return resp;
          } catch (e) {
            console.error('Rawfile not found: katex/' + path);
            return null;
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
    if (path.endsWith('.js')) return 'application/javascript';
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
      this.currentHtml = renderer.renderFullPage(ast);
      this.lastRendered = this.content;
      // 重新导航到 APP_URL，由 onInterceptRequest 响应新的 HTML
      this.controller?.loadUrl(APP_URL + '?t=' + Date.now());
    } catch (err) {
      console.error('[MarkdownPreview] render error: ' + String(err));
      this.lastRendered = '';
    }
  }
}

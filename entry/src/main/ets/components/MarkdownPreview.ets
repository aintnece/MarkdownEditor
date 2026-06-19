/**
 * MarkdownPreview 组件
 *
 * 基于 WebView 的 Markdown 实时预览组件。
 * 使用 controller.loadData() 加载渲染后的 HTML。
 * 带防抖处理，防止每敲一个字符就全量重渲染。
 */

import { webview } from '@kit.ArkWeb';
import { MarkdownParser } from '../core/MarkdownParser';
import { HtmlRenderer } from '../core/HtmlRenderer';
import { ThemeColors } from '../services/ThemeService';

@Component
export struct MarkdownPreview {
  @Prop @Watch('onContentChange') content: string;
  @Link themeColors: ThemeColors;
  @Prop fontSize: number;
  @Prop isDark: boolean;

  private controller: webview.WebviewController | null = null;
  private parser: MarkdownParser = new MarkdownParser('');
  private renderer: HtmlRenderer = new HtmlRenderer({ darkMode: false });
  private isReady: boolean = false;
  private debounceTimer: number | null = null;

  aboutToAppear(): void {
    this.controller = new webview.WebviewController();
  }

  /** 防抖处理：停止输入 300ms 后才渲染 */
  onContentChange(): void {
    if (!this.isReady) {
      return;
    }
    if (this.debounceTimer !== null) {
      clearTimeout(this.debounceTimer);
    }
    this.debounceTimer = setTimeout(() => {
      this.debounceTimer = null;
      this.renderPreview();
    }, 300);
  }

  build() {
    Web({ src: 'about:blank', controller: this.controller! })
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeColors.previewBg)
      .javaScriptAccess(true)
      .domStorageAccess(true)
      .onPageEnd(() => {
        this.isReady = true;
        this.renderPreview();
      })
  }

  /** 渲染完整 HTML 到 WebView */
  renderPreview(): void {
    try {
      const parser = new MarkdownParser(this.content);
      const ast = parser.parse();
      const renderer = new HtmlRenderer({
        darkMode: this.isDark,
        fontSize: this.fontSize,
      });
      const html = renderer.renderFullPage(ast);
      this.controller?.loadData(html, 'text/html', 'UTF-8', 'https://cdn.jsdelivr.net/npm/');
    } catch (err) {
      console.error('[MarkdownPreview] render error: ' + JSON.stringify(err));
    }
  }
}

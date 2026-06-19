/**
 * MarkdownPreview 组件
 *
 * 基于 WebView 的 Markdown 实时预览组件。
 * 使用 controller.loadData() 加载渲染后的 HTML。
 * 支持：
 *   - 实时渲染（编辑器内容变化时自动更新）
 *   - 深色/浅色主题
 *   - 代码高亮
 *   - 标题锚点导航
 *   - 点击链接处理
 */

import { webview } from '@kit.ArkWeb';
import { MarkdownParser } from '../core/MarkdownParser';
import { HtmlRenderer } from '../core/HtmlRenderer';
import { ThemeColors } from '../services/ThemeService';

@Component
export struct MarkdownPreview {
  // ── 组件属性 ──
  @Prop @Watch('onContentChange') content: string;
  @Link themeColors: ThemeColors;
  @Prop fontSize: number;
  @Prop isDark: boolean;

  private controller: webview.WebviewController | null = null;
  private parser: MarkdownParser = new MarkdownParser('');
  private renderer: HtmlRenderer = new HtmlRenderer({ darkMode: false });
  private isReady: boolean = false;

  aboutToAppear(): void {
    this.controller = new webview.WebviewController();
  }

  /** 内容变化时自动刷新预览 */
  onContentChange(): void {
    if (this.isReady) {
      this.renderPreview();
    }
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
      const baseUrl = 'https://cdn.jsdelivr.net/npm/';
      this.controller?.loadData(html, 'text/html', 'UTF-8', baseUrl);
    } catch (err: Error) {
      console.error('[MarkdownPreview] render error: ' + JSON.stringify(err));
    }
  }
}

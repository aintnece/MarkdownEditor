/**
 * MarkdownPreview 组件
 *
 * 基于 WebView 的 Markdown 实时预览组件。
 * 使用 loadUrl(data URI) + 防抖，避免无限循环和卡顿。
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
  private isReady: boolean = false;
  private debounceTimer: number | null = null;
  // 缓存上次渲染的内容，防止 loadUrl → onPageEnd 循环
  private lastRendered: string = '';

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
      .onPageEnd(() => {
        if (!this.isReady) {
          this.isReady = true;
          // 首次加载：内容不为空且和上次不同才渲染
          if (this.content !== '' && this.content !== this.lastRendered) {
            this.doRender();
          }
        }
      })
  }

  /** 仅在内容变动时执行渲染 */
  private doRender(): void {
    if (this.content === this.lastRendered) {
      return; // 内容没变，跳过（阻断 loadUrl → onPageEnd 循环）
    }
    this.lastRendered = this.content;
    try {
      const parser = new MarkdownParser(this.content);
      const ast = parser.parse();
      const renderer = new HtmlRenderer({
        darkMode: this.isDark,
        fontSize: this.fontSize,
      });
      const html = renderer.renderFullPage(ast);
      const encoded = encodeURIComponent(html);
      this.controller?.loadUrl('data:text/html;charset=UTF-8,' + encoded);
    } catch (err) {
      console.error('[MarkdownPreview] render error: ' + JSON.stringify(err));
    }
  }
}

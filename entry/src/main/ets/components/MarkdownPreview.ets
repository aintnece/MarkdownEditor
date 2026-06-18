/**
 * MarkdownPreview 组件
 *
 * 基于 WebView 的 Markdown 实时预览组件。
 * 通过解析-渲染管线将 Markdown 转为带样式的 HTML 并展示。
 * 支持：
 *   - 实时渲染（编辑器内容变化时自动更新）
 *   - 深色/浅色主题
 *   - 代码高亮
 *   - 标题锚点导航
 *   - 点击链接处理
 *   - 滚动同步（预览滚动 ↔ 编辑滚动）
 */

import { webview } from '@kit.ArkWeb';
import { MarkdownParser } from '../core/MarkdownParser';
import { HtmlRenderer } from '../core/HtmlRenderer';
import { ThemeColors } from '../services/ThemeService';
import { ViewModel } from '../pages/EditorPage';

@Component
export struct MarkdownPreview {
  // ── 组件属性 ──
  @Link @Watch('onContentChanged') content: string;
  @Link themeColors: ThemeColors;
  @Link fontSize: number;
  @Link isDark: boolean;

  // 回调
  private onHeadingClick?: (headingId: string) => void;
  private onScrollSync?: (scrollPercent: number) => void;

  private controller: WebviewController = new WebviewController();
  private parser: MarkdownParser = new MarkdownParser('');
  private renderer: HtmlRenderer = new HtmlRenderer({ darkMode: false });

  aboutToAppear(): void {
    // 初始化
  }

  build() {
    Web({ src: this.getInitialHtml(), controller: this.controller })
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeColors.previewBg)
      .javaScriptAccess(true)
      .domStorageAccess(true)
      .horizontalScrollBarAccess(ScrollBarState.Auto)
      .verticalScrollBarAccess(ScrollBarState.Auto)
      .onPageEnd(() => {
        this.renderPreview();
      })
      .onMessageReceive((msg: string) => {
        this.handleWebMessage(msg);
      })
  }

  /** 获取初始空白页面 */
  getInitialHtml(): string {
    const bg = this.isDark ? '#1a1a2e' : '#ffffff';
    return `<!DOCTYPE html><html><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><style>body{background:${bg};}</style></head><body><p style="color:#888;text-align:center;margin-top:40vh;">预览区域<br><span style="font-size:0.9em;">输入内容后实时渲染</span></p></body></html>`;
  }

  /** 渲染预览 */
  renderPreview(): void {
    try {
      this.parser = new MarkdownParser(this.content);
      const ast = this.parser.parse();
      this.renderer = new HtmlRenderer({
        darkMode: this.isDark,
        fontSize: this.fontSize,
      });
      const html = this.renderer.renderFullPage(ast);

      // 通过 JS 接口注入 HTML
      const jsCode = `
        document.open();
        document.write(${JSON.stringify(html)});
        document.close();
        // 通知原生层：渲染完成
        window.hiproxy && window.hiproxy.call('onRendered', {
          headings: Array.from(document.querySelectorAll('h1,h2,h3')).map(h => ({
            id: h.id,
            text: h.textContent,
            level: parseInt(h.tagName[1])
          })),
          totalHeight: document.body.scrollHeight
        });
      `;
      this.controller.runJavaScript(jsCode);
    } catch (err) {
      console.error('[MarkdownPreview] render error:', JSON.stringify(err));
    }
  }

  /** 处理来自 WebView 的消息 */
  private handleWebMessage(msg: string): void {
    try {
      const data = JSON.parse(msg);
      switch (data.type) {
        case 'linkClick':
          if (data.url) {
            // 链接点击处理（可在外部浏览器打开）
            try {
              import('@kit.AbilityKit').then((kit) => {
                kit.openLink(data.url);
              });
            } catch {}
          }
          break;
        case 'headingClick':
          if (this.onHeadingClick) {
            this.onHeadingClick(data.id);
          }
          break;
        case 'taskToggle':
          // 任务列表状态同步（需要反向更新 Markdown）
          console.log('Task toggled:', data.index);
          break;
        case 'scroll':
          // 滚动事件同步
          if (this.onScrollSync) {
            this.onScrollSync(data.percent);
          }
          break;
      }
    } catch {
      console.warn('[MarkdownPreview] unknown message:', msg);
    }
  }

  /** 滚动到指定标题 */
  scrollToHeading(headingId: string): void {
    const js = `
      const el = document.getElementById('${headingId}');
      if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' });
    `;
    this.controller.runJavaScript(js);
  }

  /** 刷新预览（外部调用） */
  refresh(): void {
    this.renderPreview();
  }

  /** 获取渲染后的纯文本（用于导出） */
  async getRenderedHtml(): Promise<string> {
    return new Promise((resolve) => {
      this.controller.runJavaScript(
        'document.querySelector(".markdown-body")?.innerHTML || ""',
        (err: string, result: string) => {
          if (!err) resolve(result);
          else resolve('');
        }
      );
    });
  }
}

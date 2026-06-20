/**
 * WysiwygEditor - 所见即所得编辑器组件
 *
 * 基于 WebView 内嵌 Toast UI Editor v3.2.2 (ProseMirror) 实现。
 * 通过 runJavaScript 桥接 ArkTS ↔ JS 通信。
 *
 * 通信协议：
 *   ArkTS → JS: this.controller.runJavaScript('window.arkts.receive(...)')
 *   JS → ArkTS: (通过约定回调，暂时单向)
 */

import { webview } from '@kit.ArkWeb';
import { resourceManager } from '@kit.LocalizationKit';

const EDITOR_HTML_URL = 'https://markdown.local/editor/index';
const EDITOR_JS_URL = 'https://markdown.local/editor/tui-editor-bundle.js';
const EDITOR_CSS_URL = 'https://markdown.local/editor/tui-editor-full.min.css';
const EDITOR_SYNC_URL = 'https://markdown.local/editor/sync';

@Component
export struct WysiwygEditor {
  @Prop @Watch('onContentChange') content: string;
  @Prop isDark: boolean;
  @Prop fontSize: number;

  onMarkdownChange?: (markdown: string) => void;
  onReady?: () => void;

  private controller: webview.WebviewController = new webview.WebviewController();
  private isReady: boolean = false;
  private pendingContent: string = '';
  private debounceTimer: number | null = null;

  aboutToAppear(): void {
    // content 初始化时可能还没 ready，先暂存
    if (this.content !== '') {
      this.pendingContent = this.content;
    }
  }

  onContentChange(): void {
    if (!this.isReady) {
      this.pendingContent = this.content;
      return;
    }
    this.setMarkdown(this.content);
  }

  build() {
    Web({ src: EDITOR_HTML_URL, controller: this.controller })
      .width('100%')
      .height('100%')
      .backgroundColor(this.isDark ? '#1e1e1e' : '#ffffff')
      .javaScriptAccess(true)
      .domStorageAccess(true)
      .focusable(true)
      .onInterceptRequest((event) => {
        if (!event) return null;
        const url: string = event.request.getRequestUrl();

        // HTML 入口
        if (url.startsWith(EDITOR_HTML_URL)) {
          return this.buildHtmlResponse(this.getEditorHtml());
        }

        // JS bundle
        if (url.startsWith(EDITOR_JS_URL)) {
          return this.buildRawfileResponse('editor/tui-editor-bundle.js', 'application/javascript');
        }

        // CSS
        if (url.startsWith(EDITOR_CSS_URL)) {
          return this.buildRawfileResponse('editor/tui-editor-full.min.css', 'text/css');
        }

        // 内容同步：JS 通过 Image 请求回传 Markdown
        if (url.startsWith(EDITOR_SYNC_URL)) {
          this.handleSyncRequest(url);
          return null;
        }

        return null;
      })
      .onPageEnd(() => {
        if (!this.isReady) {
          this.isReady = true;
          // 初始化完成后设置内容
          if (this.pendingContent !== '') {
            this.setMarkdown(this.pendingContent);
            this.pendingContent = '';
          }
          if (this.onReady) this.onReady();
          // 注入同步回传桥
          this.injectSyncBridge();
        }
      })
  }

  // ── 内容同步桥 ──

  /** 处理 JS 侧通过 Image 请求回传的 Markdown 内容 */
  private handleSyncRequest(url: string): void {
    try {
      // URL: https://markdown.local/editor/sync?md=<encoded>
      const q: string = url.substring(url.indexOf('?') + 1);
      const params: string[] = q.split('&');
      for (let i = 0; i < params.length; i++) {
        const kv: string[] = params[i].split('=');
        if (kv[0] === 'md' && kv[1]) {
          const md: string = decodeURIComponent(kv[1]);
          if (this.onMarkdownChange) this.onMarkdownChange(md);
          break;
        }
      }
    } catch (e) {
      // 静默忽略解码错误
    }
  }

  /** 注入 sync 桥接函数到 WebView */
  private injectSyncBridge(): void {
    this.controller.runJavaScript(`
      // 重写 sync 方法：通过 Image 请求回传 Markdown（onInterceptRequest 拦截）
      window.arkts.setContent = function(md) {
        if (!md) return;
        // 截断过长的内容（URL 长度限制）
        var maxLen = 8000;
        var chunk = md.length > maxLen ? md.substring(0, maxLen) : md;
        new Image().src = '${EDITOR_SYNC_URL}?md=' + encodeURIComponent(chunk);
      };

      // 防抖版 change 回调
      var _syncTimer = null;
      var _lastSynced = '';

      function syncContent() {
        var md = editor.getMarkdown();
        if (md !== _lastSynced) {
          _lastSynced = md;
          window.arkts.setContent(md);
        }
      }

      // 监听编辑器变更
      editor.on('change', function() {
        if (_syncTimer) clearTimeout(_syncTimer);
        _syncTimer = setTimeout(syncContent, 500);
      });
    `);
  }

  /** 获取编辑器当前 Markdown 内容 */
  getMarkdown(): void {
    if (!this.isReady) return;
    this.controller.runJavaScript(`
      try {
        var md = editor.getMarkdown();
        window.arkts.setContent(md);
      } catch(e) {
        window.arkts.log('getMarkdown error: ' + e.message);
      }
    `);
  }

  /** 设置 Markdown 内容到编辑器 */
  setMarkdown(md: string): void {
    if (!this.isReady) {
      this.pendingContent = md;
      return;
    }
    // 防抖：避免频繁 setMarkdown 导致性能问题
    if (this.debounceTimer !== null) clearTimeout(this.debounceTimer);
    this.debounceTimer = setTimeout(() => {
      this.debounceTimer = null;
      const escaped: string = encodeURIComponent(md);
      this.controller.runJavaScript(`
        try {
          editor.setMarkdown(decodeURIComponent('${escaped}'), false);
        } catch(e) {
          window.arkts.log('setMarkdown error: ' + e.message);
        }
      `);
    }, 150);
  }

  /** 执行编辑器命令（粗体/斜体/表格等） */
  execCommand(command: string, value?: string): void {
    if (!this.isReady) return;
    const payload: string = value ? `'${value}'` : '';
    this.controller.runJavaScript(`
      try {
        window.arkts.execEditorCommand('${command}', ${payload || 'null'});
      } catch(e) {
        window.arkts.log('execCommand error: ' + e.message);
      }
    `);
  }

  /** 切换主题 */
  setTheme(isDark: boolean): void {
    if (!this.isReady) return;
    const theme: string = isDark ? 'dark' : 'light';
    this.controller.runJavaScript(`
      try {
        document.documentElement.setAttribute('data-theme', '${theme}');
        window.arkts.log('Theme set to ${theme}');
      } catch(e) {}
    `);
  }

  /** 获取选区文本 */
  getSelection(): void {
    if (!this.isReady) return;
    this.controller.runJavaScript(`
      try {
        window.arkts.setContent(editor.getSelectedText() || '');
      } catch(e) {}
    `);
  }

  // ── 内部方法 ──

  private getEditorHtml(): string {
    const escaped: string = this.content !== '' ? encodeURIComponent(this.content) : '';
    return `<!DOCTYPE html>
<html lang="zh-CN" data-theme="${this.isDark ? 'dark' : 'light'}">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="${EDITOR_CSS_URL}">
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  html, body { height: 100%; overflow: hidden; }
  body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    font-size: ${this.fontSize}px;
  }
  #editor { height: 100%; }
  /* 暗色主题适配 */
  [data-theme="dark"] body { background: #1e1e1e; }
  /* 编辑器高度自适应 */
  .toastui-editor-defaultUI { height: 100% !important; }
  .toastui-editor-defaultUI .ProseMirror {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    font-size: ${this.fontSize}px;
    line-height: 1.6;
  }
</style>
</head>
<body>
<div id="editor"></div>

<script>
// ArkTS 通信桥接对象
window.arkts = {
  log: function(msg) { console.log('[arkts] ' + msg); },
  setContent: function(md) {
    // 由 ArkTS 端注入实现
    console.log('[arkts] setContent called with: ' + (md ? md.substring(0, 100) : ''));
  },
  execEditorCommand: function(cmd, val) {
    console.log('[arkts] execEditorCommand: ' + cmd);
  }
};
</script>

<script src="${EDITOR_JS_URL}"></script>
<script>
var editor = null;
var initContent = ${escaped ? "decodeURIComponent('" + escaped + "')" : "''"};

try {
  if (!window.toastui || !window.toastui.Editor) {
    console.error('toastui.Editor not found! window.toastui=' + typeof window.toastui);
  } else {
    editor = new window.toastui.Editor({
      el: document.querySelector('#editor'),
      initialEditType: 'wysiwyg',
      previewStyle: 'tab',
      height: '100%',
      initialValue: initContent,
      usageStatistics: false,
      toolbarItems: [
        ['heading', 'bold', 'italic', 'strike'],
        ['hr', 'quote'],
        ['ul', 'ol', 'task'],
        ['table', 'image', 'link'],
        ['code', 'codeblock']
      ]
    });

    // 内容变更时通知 ArkTS
    editor.on('change', function() {
      var md = editor.getMarkdown();
      // 通过修改 URL fragment 触发 onInterceptRequest（可选）
    });

    console.log('[editor] Toast UI Editor initialized successfully');
  }
} catch(e) {
  console.error('[editor] Init error: ' + e.message);
}
</script>
</body>
</html>`;
  }

  private buildHtmlResponse(html: string): WebResourceResponse {
    const resp = new WebResourceResponse();
    resp.setResponseData(html);
    resp.setResponseEncoding('utf-8');
    resp.setResponseMimeType('text/html');
    resp.setResponseCode(200);
    resp.setReasonMessage('OK');
    resp.setResponseIsReady(true);
    return resp;
  }

  private buildRawfileResponse(path: string, mimeType: string): WebResourceResponse {
    const resp = new WebResourceResponse();
    resp.setResponseEncoding('utf-8');
    resp.setResponseMimeType(mimeType);
    resp.setResponseCode(200);
    resp.setReasonMessage('OK');
    try {
      const ctx: resourceManager.ResourceManager = getContext(this).resourceManager;
      const data: Uint8Array = ctx.getRawFileContentSync(path);
      const copy: Uint8Array = new Uint8Array(data.byteLength);
      copy.set(data);
      resp.setResponseData(copy.buffer);
      resp.setResponseHeader([{
        headerKey: 'Access-Control-Allow-Origin',
        headerValue: 'https://markdown.local'
      }]);
      resp.setResponseIsReady(true);
      return resp;
    } catch (e) {
      console.error('Rawfile not found: ' + path);
      return resp;
    }
  }
}

/**
 * EditorPage - 编辑器主页面
 *
 * 核心编辑界面，由以下部分组成：
 *   - 工具栏 (Toolbar)
 *   - 侧面板 (SidePanel) - 可收起
 *   - 编辑区域 / 预览区域（分屏或单模式）
 *   - 状态栏 (StatusBar)
 *
 * 支持三种视图模式：
 *   1. Edit Only - 仅编辑
 *   2. Split View - 编辑 + 预览分屏
 *   3. Preview Only - 仅预览
 */

import { router } from '@kit.ArkUI';

import { MarkdownEditor } from '../components/MarkdownEditor';
import { MarkdownPreview } from '../components/MarkdownPreview';
import { Toolbar, ViewMode } from '../components/Toolbar';
import { SidePanel } from '../components/SidePanel';
import { StatusBar } from '../components/StatusBar';

import { ThemeService, ThemeColors } from '../services/ThemeService';
import { FileService } from '../services/FileService';
import { ExportService } from '../services/ExportService';

// ── 视图模型 ──

@Observed
export class EditorViewModel {
  content: string = '';
  viewMode: ViewMode = ViewMode.Split;
  themeKey: string = 'light';
  isDark: boolean = false;
  fontSize: number = 16;
  filePath: string = '';
  fileName: string = '未命名文档';
  isSaved: boolean = true;
  cursorLine: number = 1;
  cursorCol: number = 1;

  constructor() {
    const theme = ThemeService.getInstance().getTheme();
    this.themeKey = ThemeService.getInstance().getThemeKey();
    this.isDark = theme.isDark;
  }
}

class NavData {
  filePath: string = '';
}

// ── 主题对象桥接（ArkUI 需要 @ObjectLink 绑定） ──

@Observed
class ThemeBridge {
  name: string = '';
  isDark: boolean = false;
  editorBg: string = '#ffffff';
  editorFg: string = '#24292e';
  editorLineNumber: string = '#959da5';
  editorCursor: string = '#0366d6';
  editorSelection: string = '#c8e1ff';
  editorGutter: string = '#f6f8fa';
  editorActiveLine: string = '#f8f9fa';
  previewBg: string = '#ffffff';
  previewFg: string = '#24292e';
  previewHeading: string = '#1a1a2e';
  previewLink: string = '#0366d6';
  previewCodeBg: string = '#f6f8fa';
  previewCodeFg: string = '#24292e';
  previewBorder: string = '#dfe2e5';
  toolbarBg: string = '#f6f8fa';
  toolbarFg: string = '#24292e';
  toolbarActive: string = '#0366d6';
  toolbarHover: string = '#e1e4e8';
  sidebarBg: string = '#f6f8fa';
  sidebarFg: string = '#24292e';
  sidebarActive: string = '#e1e4e8';
  sidebarHover: string = '#eaecef';
  syntaxKeyword: string = '#d73a49';
  syntaxString: string = '#032f62';
  syntaxNumber: string = '#005cc5';
  syntaxComment: string = '#6a737d';
  syntaxFunction: string = '#6f42c1';
  syntaxType: string = '#22863a';
  syntaxOperator: string = '#d73a49';
  syntaxVariable: string = '#e36209';

  constructor() {
    this.updateFromTheme(ThemeService.getInstance().getTheme());
  }

  updateFromTheme(theme: ThemeColors): void {
    this.name = theme.name;
    this.isDark = theme.isDark;
    this.editorBg = theme.editorBg;
    this.editorFg = theme.editorFg;
    this.editorLineNumber = theme.editorLineNumber;
    this.editorCursor = theme.editorCursor;
    this.editorSelection = theme.editorSelection;
    this.editorGutter = theme.editorGutter;
    this.editorActiveLine = theme.editorActiveLine;
    this.previewBg = theme.previewBg;
    this.previewFg = theme.previewFg;
    this.previewHeading = theme.previewHeading;
    this.previewLink = theme.previewLink;
    this.previewCodeBg = theme.previewCodeBg;
    this.previewCodeFg = theme.previewCodeFg;
    this.previewBorder = theme.previewBorder;
    this.toolbarBg = theme.toolbarBg;
    this.toolbarFg = theme.toolbarFg;
    this.toolbarActive = theme.toolbarActive;
    this.toolbarHover = theme.toolbarHover;
    this.sidebarBg = theme.sidebarBg;
    this.sidebarFg = theme.sidebarFg;
    this.sidebarActive = theme.sidebarActive;
    this.sidebarHover = theme.sidebarHover;
    this.syntaxKeyword = theme.syntaxKeyword;
    this.syntaxString = theme.syntaxString;
    this.syntaxNumber = theme.syntaxNumber;
    this.syntaxComment = theme.syntaxComment;
    this.syntaxFunction = theme.syntaxFunction;
    this.syntaxType = theme.syntaxType;
    this.syntaxOperator = theme.syntaxOperator;
    this.syntaxVariable = theme.syntaxVariable;
  }
}

// ─── 编辑器命令工具 ────────────────────────────────

class MarkdownCommands {
  /** 根据命令名生成要插入的 Markdown 文本 */
  static execute(command: string, selection?: string): string {
    switch (command) {
      case 'bold': return `**${selection || '粗体文本'}**`;
      case 'italic': return `*${selection || '斜体文本'}*`;
      case 'strikethrough': return `~~${selection || '删除文本'}~~`;
      case 'inlineCode': return `\`${selection || 'code'}\``;
      case 'heading': {
        const lines = (selection || '标题').split('\n');
        return lines.map(l => `## ${l}`).join('\n');
      }
      case 'blockquote': {
        const lines = (selection || '引用文字').split('\n');
        return lines.map(l => `> ${l}`).join('\n');
      }
      case 'ulist': {
        const lines = (selection || '列表项').split('\n');
        return lines.map(l => `- ${l}`).join('\n');
      }
      case 'olist': {
        const lines = (selection || '列表项').split('\n');
        return lines.map((l, i) => `${i + 1}. ${l}`).join('\n');
      }
      case 'codeBlock': return '```\n' + (selection || '// 代码') + '\n```';
      case 'link': return `[${selection || '链接文字'}](https://)`;
      case 'image': return `![${selection || '图片描述'}](https://)`;
      case 'table': return '| 列1 | 列2 | 列3 |\n| --- | --- | --- |\n| 内容 | 内容 | 内容 |';
      case 'hr': return '\n---\n';
      case 'task': {
        const lines = (selection || '任务').split('\n');
        return lines.map(l => `- [ ] ${l}`).join('\n');
      }
      default: return '';
    }
  }
}

// ─── EditorPage 组件 ───────────────────────────────

@Entry
@Component
struct EditorPage {
  @State private vm: EditorViewModel = new EditorViewModel();
  @State private themeBridge: ThemeBridge = new ThemeBridge();
  @State private viewMode: ViewMode = ViewMode.Split;

  private fileService: FileService | null = null;
  private exportService: ExportService | null = null;

  aboutToAppear(): void {
    // 初始化服务
    const context = getContext(this);
    this.fileService = FileService.getInstance(context);
    this.exportService = new ExportService(context);

    // 初始化主题
    ThemeService.getInstance().init();

    // 获取传入参数（从 Index 页面跳转）
    const data: NavData = router.getParams() as NavData;
    if (data && data.filePath) {
      this.openFile(data.filePath);
    } else {
      this.loadTestDocument();
    }
  }

  build() {
    Column() {
      // 工具栏
      Toolbar({
        themeColors: this.themeBridge,
        viewMode: this.viewMode,
        onCommand: (cmd: string) => this.handleCommand(cmd),
        onExport: () => this.handleExport(),
      })

      // 主内容区
      Row() {
        // 侧面板
        SidePanel({
          themeColors: this.themeBridge,
          onFileSelect: (path: string) => this.openFile(path),
          onHeadingSelect: (id: string) => this.scrollToHeading(id),
        })

        // 编辑/预览区域
        if (this.viewMode === ViewMode.Edit) {
          this.buildEditorOnly()
        } else if (this.viewMode === ViewMode.Preview) {
          this.buildPreviewOnly()
        } else {
          this.buildSplitView()
        }
      }
      .layoutWeight(1)

      // 状态栏
      StatusBar({
        themeColors: this.themeBridge,
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeBridge.editorBg)
  }

  @Builder
  buildEditorOnly() {
    MarkdownEditor({
      content: this.vm.content,
      themeColors: this.themeBridge,
      fontSize: this.vm.fontSize,
      onChange: (text: string) => {
        this.vm.content = text;
        this.vm.isSaved = false;
        this.updateStats();
      },
    })
  }

  @Builder
  buildPreviewOnly() {
    MarkdownPreview({
      content: this.vm.content,
      themeColors: this.themeBridge,
      fontSize: this.vm.fontSize,
      isDark: this.vm.isDark,
    })
  }

  @Builder
  buildSplitView() {
    Row() {
      // 左：编辑器
      MarkdownEditor({
        content: this.vm.content,
        themeColors: this.themeBridge,
        fontSize: this.vm.fontSize,
        onChange: (text: string) => {
          this.vm.content = text;
          this.vm.isSaved = false;
          this.updateStats();
        },
      })
      .layoutWeight(1)

      // 分割线
      Divider()
        .vertical(true)
        .width(4)
        .height('100%')
        .color(this.themeBridge.previewBorder)

      // 右：预览
      MarkdownPreview({
        content: this.vm.content,
        themeColors: this.themeBridge,
        fontSize: this.vm.fontSize,
        isDark: this.vm.isDark,
      })
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }

  /** 加载测试文档（用于验证渲染效果） */
  private loadTestDocument(): void {
    this.vm.content = '# Markdown 编辑器测试文档\n' +
      '\n' +
      '## 文本样式\n' +
      '\n' +
      '**粗体**、*斜体*、~~删除线~~、`行内代码`\n' +
      '\n' +
      '## 列表\n' +
      '\n' +
      '- 无序列表项\n' +
      '  - 嵌套列表项\n' +
      '1. 有序列表项\n' +
      '2. 有序列表项\n' +
      '\n' +
      '## 任务列表\n' +
      '\n' +
      '- [x] 已完成的任务\n' +
      '- [ ] 未完成的任务\n' +
      '\n' +
      '## 代码块\n' +
      '\n' +
      '```typescript\n' +
      'function greet(name: string): void {\n' +
      '  console.log(\'Hello, \' + name + \'!\');\n' +
      '}\n' +
      '```\n' +
      '\n' +
      '## 数学公式\n' +
      '\n' +
      '行内公式：$E = mc^2$\n' +
      '\n' +
      '块级公式：\n' +
      '$$\\\n' +
      '\\int_{a}^{b} f(x)\\,dx = F(b) - F(a)\n' +
      '$$\n' +
      '\n' +
      '## 引用\n' +
      '\n' +
      '> 行到水穷处，坐看云起时。\n' +
      '>\n' +
      '> —— 王维\n' +
      '\n' +
      '## 表格\n' +
      '\n' +
      '| 功能 | 状态 | 备注 |\n' +
      '|------|------|------|\n' +
      '| 编辑 | ✅ | TextArea 组件 |\n' +
      '| 预览 | ✅ | WebView + KaTeX |\n' +
      '| 数学公式 | ✅ | KaTeX 渲染 |\n' +
      '| 导出 | 🚧 | HTML 格式 |\n' +
      '\n' +
      '## 分割线\n' +
      '\n' +
      '---\n' +
      '\n' +
      '> 测试完毕，可以自由编辑这个文档。\n';
  }

  // ── 命令处理 ──

  private handleCommand(command: string): void {
    const insertion = MarkdownCommands.execute(command, this.getSelection());
    if (insertion) {
      // 在当前光标位置插入
      this.vm.content += (this.vm.content.endsWith('\n') || this.vm.content === '')
        ? insertion
        : '\n' + insertion;
      this.vm.isSaved = false;

      // 切换到编辑或分屏模式
      if (this.viewMode === ViewMode.Preview) {
        this.viewMode = ViewMode.Split;
      }
    }

    // 视图模式切换
    if (command === ViewMode.Edit) {
      this.viewMode = ViewMode.Edit;
    } else if (command === ViewMode.Split) {
      this.viewMode = ViewMode.Split;
    } else if (command === ViewMode.Preview) {
      this.viewMode = ViewMode.Preview;
    }

    // 其他命令
    switch (command) {
      case 'undo':
        // TextArea 原生支持撤销
        break;
      case 'redo':
        break;
    }
  }

  private getSelection(): string {
    // TextArea 的选中文本获取受限，这里返回空
    // 可通过 TextAreaController 的 selection 属性获取
    return '';
  }

  // ── 文件操作 ──

  private async openFile(filePath: string): Promise<void> {
    const content = await this.fileService?.readFile(filePath);
    if (content !== null && content !== undefined) {
      this.vm.content = content;
      this.vm.filePath = filePath;
      this.vm.fileName = this.fileService?.getFileName(filePath) || '未命名文档';
      this.vm.isSaved = true;
      this.updateStats();
    }
  }

  private async saveFile(): Promise<void> {
    if (this.vm.filePath) {
      const success = await this.fileService?.saveFile(
        this.vm.filePath,
        this.vm.content,
      );
      if (success) {
        this.vm.isSaved = true;
      }
    } else {
      // 新文件，触发另存为
      this.saveFileAs();
    }
  }

  private async saveFileAs(): Promise<void> {
    const uri = await this.fileService?.saveFileAs(
      this.vm.content,
      this.vm.fileName,
    );
    if (uri) {
      this.vm.filePath = uri;
      this.vm.fileName = this.fileService?.getFileName(uri) || '未命名文档';
      this.vm.isSaved = true;
    }
  }

  // ── 导出 ──

  private async handleExport(): Promise<void> {
    try {
      const result = await this.exportService?.export(this.vm.content, {
        format: 'html',
        darkMode: this.vm.isDark,
        fontSize: this.vm.fontSize,
      });
      if (result) {
        console.log('[EditorPage] Export saved to:', result);
      }
    } catch (err) {
      console.error('[EditorPage] Export failed:', JSON.stringify(err));
    }
  }

  // ── 页面导航 ──

  private scrollToHeading(id: string): void {
    // 通过 MarkdownPreview 组件暴露的方法
  }

  private updateStats(): void {
    // StatusBar 通过 @Link 自动更新
  }
}

import { ThemeColors } from '../services/ThemeService';

/**
 * Toolbar 组件
 *
 * 编辑器格式化工具栏，提供：
 *   - 文本样式（粗体/斜体/删除线/行内代码）
 *   - 块级元素（标题/引用/列表/代码块）
 *   - 插入（链接/图片/表格/分割线）
 *   - 编辑操作（撤销/重做/缩进）
 *   - 分割面板控制（编辑/预览/分屏切换）
 *   - 导出按钮
 *   - 鼠标悬停显示浮层气泡提示
 */
@Component
export struct Toolbar {
  // ── 组件属性 ──
  @Link themeColors: ThemeColors;

  onCommand?: (command: string) => void;
  onExport?: () => void;

  // 视图模式
  @Link viewMode: ViewMode;

  // 每个按钮的 popup 显示状态
  @State private boldPopup: boolean = false;
  @State private italicPopup: boolean = false;
  @State private strikePopup: boolean = false;
  @State private inlineCodePopup: boolean = false;
  @State private headingPopup: boolean = false;
  @State private blockquotePopup: boolean = false;
  @State private ulistPopup: boolean = false;
  @State private olistPopup: boolean = false;
  @State private codeBlockPopup: boolean = false;
  @State private linkPopup: boolean = false;
  @State private imagePopup: boolean = false;
  @State private tablePopup: boolean = false;
  @State private hrPopup: boolean = false;
  @State private taskPopup: boolean = false;
  @State private editPopup: boolean = false;
  @State private splitPopup: boolean = false;
  @State private previewPopup: boolean = false;
  @State private undoPopup: boolean = false;
  @State private redoPopup: boolean = false;
  @State private exportPopup: boolean = false;

  build() {
    Row() {
      this.buildStyleGroup();
      this.buildDivider();
      this.buildBlockGroup();
      this.buildDivider();
      this.buildInsertGroup();
      this.buildDivider();
      this.buildViewGroup();
      this.buildSpacer();
      this.buildExtraGroup();
    }
    .width('100%')
    .height(44)
    .padding({ left: 8, right: 8 })
    .backgroundColor(this.themeColors.toolbarBg)
    .border({ width: { bottom: 1 }, color: this.themeColors.previewBorder })
  }

  // ── 工具方法 ──

  /** 设置 popup 显示状态 */
  private setPopup(name: string, show: boolean): void {
    if (name === 'bold') { this.boldPopup = show; }
    else if (name === 'italic') { this.italicPopup = show; }
    else if (name === 'strikethrough') { this.strikePopup = show; }
    else if (name === 'inlineCode') { this.inlineCodePopup = show; }
    else if (name === 'heading') { this.headingPopup = show; }
    else if (name === 'blockquote') { this.blockquotePopup = show; }
    else if (name === 'ulist') { this.ulistPopup = show; }
    else if (name === 'olist') { this.olistPopup = show; }
    else if (name === 'codeBlock') { this.codeBlockPopup = show; }
    else if (name === 'link') { this.linkPopup = show; }
    else if (name === 'image') { this.imagePopup = show; }
    else if (name === 'table') { this.tablePopup = show; }
    else if (name === 'hr') { this.hrPopup = show; }
    else if (name === 'task') { this.taskPopup = show; }
    else if (name === 'edit') { this.editPopup = show; }
    else if (name === 'split') { this.splitPopup = show; }
    else if (name === 'preview') { this.previewPopup = show; }
    else if (name === 'undo') { this.undoPopup = show; }
    else if (name === 'redo') { this.redoPopup = show; }
    else if (name === 'export') { this.exportPopup = show; }
  }

  /** 获取 popup 显示状态 */
  private getPopup(name: string): boolean {
    if (name === 'bold') return this.boldPopup;
    if (name === 'italic') return this.italicPopup;
    if (name === 'strikethrough') return this.strikePopup;
    if (name === 'inlineCode') return this.inlineCodePopup;
    if (name === 'heading') return this.headingPopup;
    if (name === 'blockquote') return this.blockquotePopup;
    if (name === 'ulist') return this.ulistPopup;
    if (name === 'olist') return this.olistPopup;
    if (name === 'codeBlock') return this.codeBlockPopup;
    if (name === 'link') return this.linkPopup;
    if (name === 'image') return this.imagePopup;
    if (name === 'table') return this.tablePopup;
    if (name === 'hr') return this.hrPopup;
    if (name === 'task') return this.taskPopup;
    if (name === 'edit') return this.editPopup;
    if (name === 'split') return this.splitPopup;
    if (name === 'preview') return this.previewPopup;
    if (name === 'undo') return this.undoPopup;
    if (name === 'redo') return this.redoPopup;
    if (name === 'export') return this.exportPopup;
    return false;
  }

  /** 根据命令名获取中文提示 */
  private getTooltip(command: string): string {
    if (command === 'bold') return '粗体 (Ctrl+B)';
    if (command === 'italic') return '斜体 (Ctrl+I)';
    if (command === 'strikethrough') return '删除线';
    if (command === 'inlineCode') return '行内代码';
    if (command === 'heading') return '标题';
    if (command === 'blockquote') return '引用';
    if (command === 'ulist') return '无序列表';
    if (command === 'olist') return '有序列表';
    if (command === 'codeBlock') return '代码块';
    if (command === 'link') return '插入超链接';
    if (command === 'image') return '插入图片';
    if (command === 'table') return '插入表格';
    if (command === 'hr') return '插入分割线';
    if (command === 'task') return '任务列表';
    if (command === 'edit') return '仅编辑模式';
    if (command === 'split') return '分屏模式';
    if (command === 'preview') return '仅预览模式';
    if (command === 'undo') return '撤销';
    if (command === 'redo') return '重做';
    if (command === 'export') return '导出为 HTML 文件';
    return command;
  }

  // ── 按钮组 ──

  @Builder
  buildStyleGroup() {
    this.buildToolButton('B', 'bold');
    this.buildToolButton('I', 'italic');
    this.buildToolButton('S', 'strikethrough');
    this.buildToolButton('<>', 'inlineCode');
  }

  @Builder
  buildBlockGroup() {
    this.buildToolButton('H', 'heading');
    this.buildToolButton('❝', 'blockquote');
    this.buildToolButton('•', 'ulist');
    this.buildToolButton('1.', 'olist');
    this.buildToolButton('{ }', 'codeBlock');
  }

  @Builder
  buildInsertGroup() {
    this.buildToolButton('🔗', 'link');
    this.buildToolButton('🖼', 'image');
    this.buildToolButton('⊞', 'table');
    this.buildToolButton('—', 'hr');
    this.buildToolButton('☑', 'task');
  }

  @Builder
  buildViewGroup() {
    this.buildToolButton('✏️', 'edit', this.viewMode === ViewMode.Edit);
    this.buildToolButton('⇔', 'split', this.viewMode === ViewMode.Split);
    this.buildToolButton('👁', 'preview', this.viewMode === ViewMode.Preview);
  }

  @Builder
  buildExtraGroup() {
    this.buildToolButton('↩', 'undo');
    this.buildToolButton('↪', 'redo');
    Button({ type: ButtonType.Normal }) {
      Text('导出')
        .fontSize(12)
        .fontColor(this.themeColors.toolbarFg)
    }
    .height(28)
    .padding({ left: 10, right: 10 })
    .backgroundColor(this.themeColors.toolbarBg)
    .borderRadius(4)
    .border({ width: 1, color: this.themeColors.previewBorder })
    .margin({ left: 4 })
    .onClick(() => {
      if (this.onExport) this.onExport();
    })
    .bindPopup(this.exportPopup, {
      message: this.getTooltip('export'),
      placement: Placement.Bottom,
      showInSubWindow: false,
      onStateChange: (e) => {
        if (!e.isVisible) this.exportPopup = false;
      }
    })
    .onHover((isHover: boolean, _event: HoverEvent) => {
      this.exportPopup = isHover;
    })
  }

  @Builder
  buildToolButton(icon: string, command: string, active: boolean = false) {
    Button({ type: ButtonType.Normal }) {
      Text(icon)
        .fontSize(14)
        .fontColor(active ? this.themeColors.toolbarActive : this.themeColors.toolbarFg)
        .fontWeight(active ? 700 : 400)
    }
    .width(32)
    .height(28)
    .padding(0)
    .backgroundColor(active ? this.themeColors.toolbarHover : Color.Transparent)
    .borderRadius(4)
    .margin({ left: 2, right: 2 })
    .onClick(() => {
      if (this.onCommand) this.onCommand(command);
    })
    .bindPopup(this.getPopup(command), {
      message: this.getTooltip(command),
      placement: Placement.Bottom,
      showInSubWindow: false,
      onStateChange: (e) => {
        if (!e.isVisible) this.setPopup(command, false);
      }
    })
    .onHover((isHover: boolean, _event: HoverEvent) => {
      this.setPopup(command, isHover);
    })
  }

  @Builder
  buildDivider() {
    Divider()
      .vertical(true)
      .height(20)
      .width(1)
      .color(this.themeColors.previewBorder)
      .margin({ left: 4, right: 4 })
  }

  @Builder
  buildSpacer() {
    Blank()
  }
}

export enum ViewMode {
  Edit = 'edit',
  Split = 'split',
  Preview = 'preview',
}
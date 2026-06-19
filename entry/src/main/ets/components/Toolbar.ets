import { ThemeColors } from '../services/ThemeService';

@Component
export struct Toolbar {
  @Link themeColors: ThemeColors;
  onCommand?: (command: string) => void;
  onExport?: () => void;
  @Link viewMode: ViewMode;

  // 每个按钮独立的 popup 状态
  @State popBold: boolean = false;
  @State popItalic: boolean = false;
  @State popStrike: boolean = false;
  @State popInlineCode: boolean = false;
  @State popHeading: boolean = false;
  @State popBlockquote: boolean = false;
  @State popUlist: boolean = false;
  @State popOlist: boolean = false;
  @State popCodeBlock: boolean = false;
  @State popLink: boolean = false;
  @State popImage: boolean = false;
  @State popTable: boolean = false;
  @State popHr: boolean = false;
  @State popTask: boolean = false;
  @State popEdit: boolean = false;
  @State popSplit: boolean = false;
  @State popPreview: boolean = false;
  @State popUndo: boolean = false;
  @State popRedo: boolean = false;
  @State popExport: boolean = false;

  build() {
    Row() {
      // 文本样式
      this.buildBtn(this.popBold, 'B', 'bold');
      this.buildBtn(this.popItalic, 'I', 'italic');
      this.buildBtn(this.popStrike, 'S', 'strikethrough');
      this.buildBtn(this.popInlineCode, '<>', 'inlineCode');
      this.buildDiv();
      // 块级
      this.buildBtn(this.popHeading, 'H', 'heading');
      this.buildBtn(this.popBlockquote, '❝', 'blockquote');
      this.buildBtn(this.popUlist, '•', 'ulist');
      this.buildBtn(this.popOlist, '1.', 'olist');
      this.buildBtn(this.popCodeBlock, '{ }', 'codeBlock');
      this.buildDiv();
      // 插入
      this.buildBtn(this.popLink, '🔗', 'link');
      this.buildBtn(this.popImage, '🖼', 'image');
      this.buildBtn(this.popTable, '⊞', 'table');
      this.buildBtn(this.popHr, '—', 'hr');
      this.buildBtn(this.popTask, '☑', 'task');
      this.buildDiv();
      // 视图
      this.buildBtn(this.popEdit, '✏️', 'edit', this.viewMode === ViewMode.Edit);
      this.buildBtn(this.popSplit, '⇔', 'split', this.viewMode === ViewMode.Split);
      this.buildBtn(this.popPreview, '👁', 'preview', this.viewMode === ViewMode.Preview);
      this.buildSpacer();
      // 操作
      this.buildBtn(this.popUndo, '↩', 'undo');
      this.buildBtn(this.popRedo, '↪', 'redo');
      this.buildBtnExport();
    }
    .width('100%').height(44).padding({ left: 8, right: 8 })
    .backgroundColor(this.themeColors.toolbarBg)
    .border({ width: { bottom: 1 }, color: this.themeColors.previewBorder })
  }

  private tip(cmd: string): string {
    if (cmd === 'bold') return '粗体';
    if (cmd === 'italic') return '斜体';
    if (cmd === 'strikethrough') return '删除线';
    if (cmd === 'inlineCode') return '行内代码';
    if (cmd === 'heading') return '标题';
    if (cmd === 'blockquote') return '引用';
    if (cmd === 'ulist') return '无序列表';
    if (cmd === 'olist') return '有序列表';
    if (cmd === 'codeBlock') return '代码块';
    if (cmd === 'link') return '插入超链接';
    if (cmd === 'image') return '插入图片';
    if (cmd === 'table') return '插入表格';
    if (cmd === 'hr') return '分割线';
    if (cmd === 'task') return '任务列表';
    if (cmd === 'edit') return '编辑';
    if (cmd === 'split') return '分屏';
    if (cmd === 'preview') return '预览';
    if (cmd === 'undo') return '撤销';
    if (cmd === 'redo') return '重做';
    if (cmd === 'export') return '导出 HTML';
    return cmd;
  }

  private setPop(cmd: string, v: boolean): void {
    if (cmd === 'bold') this.popBold = v;
    else if (cmd === 'italic') this.popItalic = v;
    else if (cmd === 'strikethrough') this.popStrike = v;
    else if (cmd === 'inlineCode') this.popInlineCode = v;
    else if (cmd === 'heading') this.popHeading = v;
    else if (cmd === 'blockquote') this.popBlockquote = v;
    else if (cmd === 'ulist') this.popUlist = v;
    else if (cmd === 'olist') this.popOlist = v;
    else if (cmd === 'codeBlock') this.popCodeBlock = v;
    else if (cmd === 'link') this.popLink = v;
    else if (cmd === 'image') this.popImage = v;
    else if (cmd === 'table') this.popTable = v;
    else if (cmd === 'hr') this.popHr = v;
    else if (cmd === 'task') this.popTask = v;
    else if (cmd === 'edit') this.popEdit = v;
    else if (cmd === 'split') this.popSplit = v;
    else if (cmd === 'preview') this.popPreview = v;
    else if (cmd === 'undo') this.popUndo = v;
    else if (cmd === 'redo') this.popRedo = v;
  }

  // ── 按钮 ──

  @Builder buildBtn($$: boolean, txt: string, cmd: string, active: boolean = false) {
    Button({ type: ButtonType.Normal }) {
      Text(txt).fontSize(14)
        .fontColor(active ? this.themeColors.toolbarActive : this.themeColors.toolbarFg)
        .fontWeight(active ? 700 : 400)
    }
    .width(32).height(28).padding(0)
    .backgroundColor(active ? this.themeColors.toolbarHover : Color.Transparent)
    .borderRadius(4).margin({ left: 2, right: 2 })
    .onClick(() => { if (this.onCommand) this.onCommand(cmd); })
    .bindPopup($$, { message: this.tip(cmd) })
    .onHover((isHover: boolean) => { this.setPop(cmd, isHover); })
  }

  @Builder buildBtnExport() {
    Button({ type: ButtonType.Normal }) {
      Text('导出').fontSize(12).fontColor(this.themeColors.toolbarFg)
    }
    .height(28).padding({ left: 10, right: 10 })
    .backgroundColor(this.themeColors.toolbarBg).borderRadius(4)
    .border({ width: 1, color: this.themeColors.previewBorder }).margin({ left: 4 })
    .onClick(() => { if (this.onExport) this.onExport(); })
    .bindPopup(this.popExport, { message: this.tip('export') })
    .onHover((isHover: boolean) => { this.popExport = isHover; })
  }

  @Builder buildDiv() {
    Divider().vertical(true).height(20).width(1)
      .color(this.themeColors.previewBorder).margin({ left: 4, right: 4 })
  }

  @Builder buildSpacer() { Blank() }
}

export enum ViewMode {
  Edit = 'edit', Split = 'split', Preview = 'preview',
}
import { ThemeColors } from '../services/ThemeService';

@Component
export struct Toolbar {
  @Link themeColors: ThemeColors;
  onCommand?: (command: string) => void;
  onExport?: () => void;
  @Link viewMode: ViewMode;

  @State hBold: boolean = false;
  @State hItalic: boolean = false;
  @State hStrike: boolean = false;
  @State hInlineCode: boolean = false;
  @State hHeading: boolean = false;
  @State hBlockquote: boolean = false;
  @State hUlist: boolean = false;
  @State hOlist: boolean = false;
  @State hCodeBlock: boolean = false;
  @State hLink: boolean = false;
  @State hImage: boolean = false;
  @State hTable: boolean = false;
  @State hHr: boolean = false;
  @State hTask: boolean = false;
  @State hEdit: boolean = false;
  @State hSplit: boolean = false;
  @State hPreview: boolean = false;
  @State hUndo: boolean = false;
  @State hRedo: boolean = false;
  @State hExport: boolean = false;

  // 防闪烁延迟
  private tBold: number = -1;
  private tItalic: number = -1;
  private tStrike: number = -1;
  private tInlineCode: number = -1;
  private tHeading: number = -1;
  private tBlockquote: number = -1;
  private tUlist: number = -1;
  private tOlist: number = -1;
  private tCodeBlock: number = -1;
  private tLink: number = -1;
  private tImage: number = -1;
  private tTable: number = -1;
  private tHr: number = -1;
  private tTask: number = -1;
  private tEdit: number = -1;
  private tSplit: number = -1;
  private tPreview: number = -1;
  private tUndo: number = -1;
  private tRedo: number = -1;
  private tExport: number = -1;

  private getTimer(k: string): number {
    if (k === 'bold') return this.tBold;
    if (k === 'italic') return this.tItalic;
    if (k === 'strikethrough') return this.tStrike;
    if (k === 'inlineCode') return this.tInlineCode;
    if (k === 'heading') return this.tHeading;
    if (k === 'blockquote') return this.tBlockquote;
    if (k === 'ulist') return this.tUlist;
    if (k === 'olist') return this.tOlist;
    if (k === 'codeBlock') return this.tCodeBlock;
    if (k === 'link') return this.tLink;
    if (k === 'image') return this.tImage;
    if (k === 'table') return this.tTable;
    if (k === 'hr') return this.tHr;
    if (k === 'task') return this.tTask;
    if (k === 'edit') return this.tEdit;
    if (k === 'split') return this.tSplit;
    if (k === 'preview') return this.tPreview;
    if (k === 'undo') return this.tUndo;
    if (k === 'redo') return this.tRedo;
    if (k === 'export') return this.tExport;
    return -1;
  }

  private setTimer(k: string, v: number): void {
    if (k === 'bold') this.tBold = v;
    else if (k === 'italic') this.tItalic = v;
    else if (k === 'strikethrough') this.tStrike = v;
    else if (k === 'inlineCode') this.tInlineCode = v;
    else if (k === 'heading') this.tHeading = v;
    else if (k === 'blockquote') this.tBlockquote = v;
    else if (k === 'ulist') this.tUlist = v;
    else if (k === 'olist') this.tOlist = v;
    else if (k === 'codeBlock') this.tCodeBlock = v;
    else if (k === 'link') this.tLink = v;
    else if (k === 'image') this.tImage = v;
    else if (k === 'table') this.tTable = v;
    else if (k === 'hr') this.tHr = v;
    else if (k === 'task') this.tTask = v;
    else if (k === 'edit') this.tEdit = v;
    else if (k === 'split') this.tSplit = v;
    else if (k === 'preview') this.tPreview = v;
    else if (k === 'undo') this.tUndo = v;
    else if (k === 'redo') this.tRedo = v;
    else if (k === 'export') this.tExport = v;
  }

  // 延迟关闭（防闪烁）
  // private popTimers: Record<string, number> = {};

  private popShow(k: string): void {
    const t: number = this.getTimer(k);
    if (t !== -1) { clearTimeout(t); this.setTimer(k, -1); }
    if (k === 'bold') this.hBold = true;
    else if (k === 'italic') this.hItalic = true;
    else if (k === 'strikethrough') this.hStrike = true;
    else if (k === 'inlineCode') this.hInlineCode = true;
    else if (k === 'heading') this.hHeading = true;
    else if (k === 'blockquote') this.hBlockquote = true;
    else if (k === 'ulist') this.hUlist = true;
    else if (k === 'olist') this.hOlist = true;
    else if (k === 'codeBlock') this.hCodeBlock = true;
    else if (k === 'link') this.hLink = true;
    else if (k === 'image') this.hImage = true;
    else if (k === 'table') this.hTable = true;
    else if (k === 'hr') this.hHr = true;
    else if (k === 'task') this.hTask = true;
    else if (k === 'edit') this.hEdit = true;
    else if (k === 'split') this.hSplit = true;
    else if (k === 'preview') this.hPreview = true;
    else if (k === 'undo') this.hUndo = true;
    else if (k === 'redo') this.hRedo = true;
    else if (k === 'export') this.hExport = true;
  }

  private popHide(k: string): void {
    const t: number = this.getTimer(k);
    if (t !== -1) clearTimeout(t);
    const id: number = setTimeout(() => {
      if (k === 'bold') this.hBold = false;
      else if (k === 'italic') this.hItalic = false;
      else if (k === 'strikethrough') this.hStrike = false;
      else if (k === 'inlineCode') this.hInlineCode = false;
      else if (k === 'heading') this.hHeading = false;
      else if (k === 'blockquote') this.hBlockquote = false;
      else if (k === 'ulist') this.hUlist = false;
      else if (k === 'olist') this.hOlist = false;
      else if (k === 'codeBlock') this.hCodeBlock = false;
      else if (k === 'link') this.hLink = false;
      else if (k === 'image') this.hImage = false;
      else if (k === 'table') this.hTable = false;
      else if (k === 'hr') this.hHr = false;
      else if (k === 'task') this.hTask = false;
      else if (k === 'edit') this.hEdit = false;
      else if (k === 'split') this.hSplit = false;
      else if (k === 'preview') this.hPreview = false;
      else if (k === 'undo') this.hUndo = false;
      else if (k === 'redo') this.hRedo = false;
      else if (k === 'export') this.hExport = false;
    }, 200);
    this.setTimer(k, id);
  }

  private tip(k: string): string {
    if (k === 'bold') return '粗体';
    if (k === 'italic') return '斜体';
    if (k === 'strikethrough') return '删除线';
    if (k === 'inlineCode') return '行内代码';
    if (k === 'heading') return '标题';
    if (k === 'blockquote') return '引用';
    if (k === 'ulist') return '无序列表';
    if (k === 'olist') return '有序列表';
    if (k === 'codeBlock') return '代码块';
    if (k === 'link') return '超链接';
    if (k === 'image') return '图片';
    if (k === 'table') return '表格';
    if (k === 'hr') return '分割线';
    if (k === 'task') return '任务列表';
    if (k === 'edit') return '编辑';
    if (k === 'split') return '分屏';
    if (k === 'preview') return '预览';
    if (k === 'undo') return '撤销';
    if (k === 'redo') return '重做';
    if (k === 'export') return '导出 HTML';
    return k;
  }

  build() {
    Row() {
      this.btn('B', 'bold', this.hBold)
      this.btn('I', 'italic', this.hItalic)
      this.btn('S', 'strikethrough', this.hStrike)
      this.btn('<>', 'inlineCode', this.hInlineCode)
      this.div()
      this.btn('H', 'heading', this.hHeading)
      this.btn('❝', 'blockquote', this.hBlockquote)
      this.btn('•', 'ulist', this.hUlist)
      this.btn('1.', 'olist', this.hOlist)
      this.btn('{ }', 'codeBlock', this.hCodeBlock)
      this.div()
      this.btn('🔗', 'link', this.hLink)
      this.btn('🖼', 'image', this.hImage)
      this.btn('⊞', 'table', this.hTable)
      this.btn('—', 'hr', this.hHr)
      this.btn('☑', 'task', this.hTask)
      this.div()
      this.btnV('✏️', 'edit', this.hEdit, this.viewMode === ViewMode.Edit)
      this.btnV('⇔', 'split', this.hSplit, this.viewMode === ViewMode.Split)
      this.btnV('👁', 'preview', this.hPreview, this.viewMode === ViewMode.Preview)
      Blank()
      this.btn('↩', 'undo', this.hUndo)
      this.btn('↪', 'redo', this.hRedo)
      this.btn('导出', 'export', this.hExport)
    }
    .width('100%').height(44).padding({ left: 8, right: 8 })
    .backgroundColor(this.themeColors.toolbarBg)
    .border({ width: { bottom: 1 }, color: this.themeColors.previewBorder })
  }

  @Builder btn(label: string, k: string, pop: boolean) {
    Button({ type: ButtonType.Normal }) {
      Text(label).fontSize(14).fontColor(this.themeColors.toolbarFg)
    }
    .width(32).height(32).padding(0)
    .backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
    .onClick(() => { if (this.onCommand) this.onCommand(k); })
    .bindPopup(pop, { message: this.tip(k), showInSubWindow: true })
    .onHover((isHover: boolean) => { if (isHover) this.popShow(k); else this.popHide(k); })
  }

  @Builder btnV(label: string, k: string, pop: boolean, active: boolean) {
    Button({ type: ButtonType.Normal }) {
      Text(label).fontSize(14)
        .fontColor(active ? this.themeColors.toolbarActive : this.themeColors.toolbarFg)
        .fontWeight(active ? 700 : 400)
    }
    .width(32).height(32).padding(0)
    .backgroundColor(active ? this.themeColors.toolbarHover : Color.Transparent)
    .borderRadius(4).margin({ left: 2, right: 2 })
    .onClick(() => { if (this.onCommand) this.onCommand(k); })
    .bindPopup(pop, { message: this.tip(k), showInSubWindow: true })
    .onHover((isHover: boolean) => { if (isHover) this.popShow(k); else this.popHide(k); })
  }

  @Builder div() {
    Divider().vertical(true).height(20).width(1)
      .color(this.themeColors.previewBorder).margin({ left: 4, right: 4 })
  }
}

export enum ViewMode {
  Edit = 'edit', Split = 'split', Preview = 'preview',
}
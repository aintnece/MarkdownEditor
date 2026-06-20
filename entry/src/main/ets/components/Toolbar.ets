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

  // timers: positive = pending show, negative = pending hide
  private tBold: number = 0; private tItalic: number = 0; private tStrike: number = 0;
  private tInlineCode: number = 0; private tHeading: number = 0; private tBlockquote: number = 0;
  private tUlist: number = 0; private tOlist: number = 0; private tCodeBlock: number = 0;
  private tLink: number = 0; private tImage: number = 0; private tTable: number = 0;
  private tHr: number = 0; private tTask: number = 0; private tEdit: number = 0;
  private tSplit: number = 0; private tPreview: number = 0; private tUndo: number = 0;
  private tRedo: number = 0; private tExport: number = 0;

  private clrAll(k: string): void {
    let t: number = 0;
    if (k === 'bold') t = this.tBold;
    else if (k === 'italic') t = this.tItalic;
    else if (k === 'strikethrough') t = this.tStrike;
    else if (k === 'inlineCode') t = this.tInlineCode;
    else if (k === 'heading') t = this.tHeading;
    else if (k === 'blockquote') t = this.tBlockquote;
    else if (k === 'ulist') t = this.tUlist;
    else if (k === 'olist') t = this.tOlist;
    else if (k === 'codeBlock') t = this.tCodeBlock;
    else if (k === 'link') t = this.tLink;
    else if (k === 'image') t = this.tImage;
    else if (k === 'table') t = this.tTable;
    else if (k === 'hr') t = this.tHr;
    else if (k === 'task') t = this.tTask;
    else if (k === 'edit') t = this.tEdit;
    else if (k === 'split') t = this.tSplit;
    else if (k === 'preview') t = this.tPreview;
    else if (k === 'undo') t = this.tUndo;
    else if (k === 'redo') t = this.tRedo;
    else if (k === 'export') t = this.tExport;
    if (t !== 0) { clearTimeout(t); }
    this.setT(k, 0);
  }
  private setT(k: string, v: number): void {
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

  private hoverEnter(k: string): void {
    this.clrAll(k);
    // 延迟 500ms 后才显示气泡，防止快速划过闪烁
    const id: number = setTimeout(() => { this.setPop(k, true); }, 500);
    this.setT(k, id);
  }
  private hoverLeave(k: string): void {
    this.clrAll(k);
    this.setPop(k, false);
  }

  private setPop(k: string, v: boolean): void {
    if (k === 'bold') this.hBold = v;
    else if (k === 'italic') this.hItalic = v;
    else if (k === 'strikethrough') this.hStrike = v;
    else if (k === 'inlineCode') this.hInlineCode = v;
    else if (k === 'heading') this.hHeading = v;
    else if (k === 'blockquote') this.hBlockquote = v;
    else if (k === 'ulist') this.hUlist = v;
    else if (k === 'olist') this.hOlist = v;
    else if (k === 'codeBlock') this.hCodeBlock = v;
    else if (k === 'link') this.hLink = v;
    else if (k === 'image') this.hImage = v;
    else if (k === 'table') this.hTable = v;
    else if (k === 'hr') this.hHr = v;
    else if (k === 'task') this.hTask = v;
    else if (k === 'edit') this.hEdit = v;
    else if (k === 'split') this.hSplit = v;
    else if (k === 'preview') this.hPreview = v;
    else if (k === 'undo') this.hUndo = v;
    else if (k === 'redo') this.hRedo = v;
    else if (k === 'export') this.hExport = v;
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
    if (k === 'export') return '导出文档';
    return k;
  }

  build() {
    Row() {
      // B
      Button({ type: ButtonType.Normal }) { Text('B').fontSize(14).fontColor(this.themeColors.toolbarFg) }
      .width(32).height(32).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
      .onClick(() => { if (this.onCommand) this.onCommand('bold'); })
      .bindPopup(this.hBold, { message: this.tip('bold'), placement: Placement.Top, showInSubWindow: true })
      .onHover((isHover: boolean) => { if (isHover) this.hoverEnter('bold'); else this.hoverLeave('bold'); })
      // I
      Button({ type: ButtonType.Normal }) { Text('I').fontSize(14).fontColor(this.themeColors.toolbarFg) }
      .width(32).height(32).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
      .onClick(() => { if (this.onCommand) this.onCommand('italic'); })
      .bindPopup(this.hItalic, { message: this.tip('italic'), placement: Placement.Top, showInSubWindow: true })
      .onHover((isHover: boolean) => { if (isHover) this.hoverEnter('italic'); else this.hoverLeave('italic'); })
      // S
      Button({ type: ButtonType.Normal }) { Text('S').fontSize(14).fontColor(this.themeColors.toolbarFg) }
      .width(32).height(32).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
      .onClick(() => { if (this.onCommand) this.onCommand('strikethrough'); })
      .bindPopup(this.hStrike, { message: this.tip('strikethrough'), placement: Placement.Top, showInSubWindow: true })
      .onHover((isHover: boolean) => { if (isHover) this.hoverEnter('strikethrough'); else this.hoverLeave('strikethrough'); })
      // <>
      Button({ type: ButtonType.Normal }) { Text('<>').fontSize(14).fontColor(this.themeColors.toolbarFg) }
      .width(32).height(32).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
      .onClick(() => { if (this.onCommand) this.onCommand('inlineCode'); })
      .bindPopup(this.hInlineCode, { message: this.tip('inlineCode'), placement: Placement.Top, showInSubWindow: true })
      .onHover((isHover: boolean) => { if (isHover) this.hoverEnter('inlineCode'); else this.hoverLeave('inlineCode'); })

      Divider().vertical(true).height(20).width(1).color(this.themeColors.previewBorder).margin({ left: 4, right: 4 })

      // H
      Button({ type: ButtonType.Normal }) { Text('H').fontSize(14).fontColor(this.themeColors.toolbarFg) }
      .width(32).height(32).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
      .onClick(() => { if (this.onCommand) this.onCommand('heading'); })
      .bindPopup(this.hHeading, { message: this.tip('heading'), placement: Placement.Top, showInSubWindow: true })
      .onHover((isHover: boolean) => { if (isHover) this.hoverEnter('heading'); else this.hoverLeave('heading'); })
      // ❝
      Button({ type: ButtonType.Normal }) { Text('❝').fontSize(14).fontColor(this.themeColors.toolbarFg) }
      .width(32).height(32).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
      .onClick(() => { if (this.onCommand) this.onCommand('blockquote'); })
      .bindPopup(this.hBlockquote, { message: this.tip('blockquote'), placement: Placement.Top, showInSubWindow: true })
      .onHover((isHover: boolean) => { if (isHover) this.hoverEnter('blockquote'); else this.hoverLeave('blockquote'); })
      // •
      Button({ type: ButtonType.Normal }) { Text('•').fontSize(14).fontColor(this.themeColors.toolbarFg) }
      .width(32).height(32).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
      .onClick(() => { if (this.onCommand) this.onCommand('ulist'); })
      .bindPopup(this.hUlist, { message: this.tip('ulist'), placement: Placement.Top, showInSubWindow: true })
      .onHover((isHover: boolean) => { if (isHover) this.hoverEnter('ulist'); else this.hoverLeave('ulist'); })
      // 1.
      Button({ type: ButtonType.Normal }) { Text('1.').fontSize(14).fontColor(this.themeColors.toolbarFg) }
      .width(32).height(32).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
      .onClick(() => { if (this.onCommand) this.onCommand('olist'); })
      .bindPopup(this.hOlist, { message: this.tip('olist'), placement: Placement.Top, showInSubWindow: true })
      .onHover((isHover: boolean) => { if (isHover) this.hoverEnter('olist'); else this.hoverLeave('olist'); })
      // { }
      Button({ type: ButtonType.Normal }) { Text('{ }').fontSize(14).fontColor(this.themeColors.toolbarFg) }
      .width(32).height(32).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
      .onClick(() => { if (this.onCommand) this.onCommand('codeBlock'); })
      .bindPopup(this.hCodeBlock, { message: this.tip('codeBlock'), placement: Placement.Top, showInSubWindow: true })
      .onHover((isHover: boolean) => { if (isHover) this.hoverEnter('codeBlock'); else this.hoverLeave('codeBlock'); })

      Divider().vertical(true).height(20).width(1).color(this.themeColors.previewBorder).margin({ left: 4, right: 4 })

      // 🔗
      Button({ type: ButtonType.Normal }) { Text('🔗').fontSize(14).fontColor(this.themeColors.toolbarFg) }
      .width(32).height(32).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
      .onClick(() => { if (this.onCommand) this.onCommand('link'); })
      .bindPopup(this.hLink, { message: this.tip('link'), placement: Placement.Top, showInSubWindow: true })
      .onHover((isHover: boolean) => { if (isHover) this.hoverEnter('link'); else this.hoverLeave('link'); })
      // 🖼
      Button({ type: ButtonType.Normal }) { Text('🖼').fontSize(14).fontColor(this.themeColors.toolbarFg) }
      .width(32).height(32).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
      .onClick(() => { if (this.onCommand) this.onCommand('image'); })
      .bindPopup(this.hImage, { message: this.tip('image'), placement: Placement.Top, showInSubWindow: true })
      .onHover((isHover: boolean) => { if (isHover) this.hoverEnter('image'); else this.hoverLeave('image'); })
      // ⊞
      Button({ type: ButtonType.Normal }) { Text('⊞').fontSize(14).fontColor(this.themeColors.toolbarFg) }
      .width(32).height(32).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
      .onClick(() => { if (this.onCommand) this.onCommand('table'); })
      .bindPopup(this.hTable, { message: this.tip('table'), placement: Placement.Top, showInSubWindow: true })
      .onHover((isHover: boolean) => { if (isHover) this.hoverEnter('table'); else this.hoverLeave('table'); })
      // —
      Button({ type: ButtonType.Normal }) { Text('—').fontSize(14).fontColor(this.themeColors.toolbarFg) }
      .width(32).height(32).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
      .onClick(() => { if (this.onCommand) this.onCommand('hr'); })
      .bindPopup(this.hHr, { message: this.tip('hr'), placement: Placement.Top, showInSubWindow: true })
      .onHover((isHover: boolean) => { if (isHover) this.hoverEnter('hr'); else this.hoverLeave('hr'); })
      // ☑
      Button({ type: ButtonType.Normal }) { Text('☑').fontSize(14).fontColor(this.themeColors.toolbarFg) }
      .width(32).height(32).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
      .onClick(() => { if (this.onCommand) this.onCommand('task'); })
      .bindPopup(this.hTask, { message: this.tip('task'), placement: Placement.Top, showInSubWindow: true })
      .onHover((isHover: boolean) => { if (isHover) this.hoverEnter('task'); else this.hoverLeave('task'); })

      Divider().vertical(true).height(20).width(1).color(this.themeColors.previewBorder).margin({ left: 4, right: 4 })

      // ✏️
      Button({ type: ButtonType.Normal }) { Text('✏️').fontSize(14).fontColor(this.viewMode === ViewMode.Edit ? this.themeColors.toolbarActive : this.themeColors.toolbarFg).fontWeight(this.viewMode === ViewMode.Edit ? 700 : 400) }
      .width(32).height(32).padding(0).backgroundColor(this.viewMode === ViewMode.Edit ? this.themeColors.toolbarHover : Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
      .onClick(() => { if (this.onCommand) this.onCommand('edit'); })
      .bindPopup(this.hEdit, { message: this.tip('edit'), placement: Placement.Top, showInSubWindow: true })
      .onHover((isHover: boolean) => { if (isHover) this.hoverEnter('edit'); else this.hoverLeave('edit'); })
      // ⇔
      Button({ type: ButtonType.Normal }) { Text('⇔').fontSize(14).fontColor(this.viewMode === ViewMode.Split ? this.themeColors.toolbarActive : this.themeColors.toolbarFg).fontWeight(this.viewMode === ViewMode.Split ? 700 : 400) }
      .width(32).height(32).padding(0).backgroundColor(this.viewMode === ViewMode.Split ? this.themeColors.toolbarHover : Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
      .onClick(() => { if (this.onCommand) this.onCommand('split'); })
      .bindPopup(this.hSplit, { message: this.tip('split'), placement: Placement.Top, showInSubWindow: true })
      .onHover((isHover: boolean) => { if (isHover) this.hoverEnter('split'); else this.hoverLeave('split'); })
      // 👁
      Button({ type: ButtonType.Normal }) { Text('👁').fontSize(14).fontColor(this.viewMode === ViewMode.Preview ? this.themeColors.toolbarActive : this.themeColors.toolbarFg).fontWeight(this.viewMode === ViewMode.Preview ? 700 : 400) }
      .width(32).height(32).padding(0).backgroundColor(this.viewMode === ViewMode.Preview ? this.themeColors.toolbarHover : Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
      .onClick(() => { if (this.onCommand) this.onCommand('preview'); })
      .bindPopup(this.hPreview, { message: this.tip('preview'), placement: Placement.Top, showInSubWindow: true })
      .onHover((isHover: boolean) => { if (isHover) this.hoverEnter('preview'); else this.hoverLeave('preview'); })

      Blank()

      // ↩
      Button({ type: ButtonType.Normal }) { Text('↩').fontSize(14).fontColor(this.themeColors.toolbarFg) }
      .width(32).height(32).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
      .onClick(() => { if (this.onCommand) this.onCommand('undo'); })
      .bindPopup(this.hUndo, { message: this.tip('undo'), placement: Placement.Top, showInSubWindow: true })
      .onHover((isHover: boolean) => { if (isHover) this.hoverEnter('undo'); else this.hoverLeave('undo'); })
      // ↪
      Button({ type: ButtonType.Normal }) { Text('↪').fontSize(14).fontColor(this.themeColors.toolbarFg) }
      .width(32).height(32).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
      .onClick(() => { if (this.onCommand) this.onCommand('redo'); })
      .bindPopup(this.hRedo, { message: this.tip('redo'), placement: Placement.Top, showInSubWindow: true })
      .onHover((isHover: boolean) => { if (isHover) this.hoverEnter('redo'); else this.hoverLeave('redo'); })
      // 导出
      Button({ type: ButtonType.Normal }) { Text('导出').fontSize(12).fontColor(this.themeColors.toolbarFg) }
      .height(28).padding({ left: 10, right: 10 }).backgroundColor(this.themeColors.toolbarBg).borderRadius(4)
      .border({ width: 1, color: this.themeColors.previewBorder }).margin({ left: 4 })
      .onClick(() => { if (this.onExport) this.onExport(); })
      .bindPopup(this.hExport, { message: this.tip('export'), placement: Placement.Top, showInSubWindow: true })
      .onHover((isHover: boolean) => { if (isHover) this.hoverEnter('export'); else this.hoverLeave('export'); })
    }
    .width('100%').height(44).padding({ left: 8, right: 8 })
    .backgroundColor(this.themeColors.toolbarBg)
    .border({ width: { bottom: 1 }, color: this.themeColors.previewBorder })
  }
}

export enum ViewMode {
  Edit = 'edit', Split = 'split', Preview = 'preview',
}
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

  private tBold: number = -1; private tItalic: number = -1; private tStrike: number = -1;
  private tInlineCode: number = -1; private tHeading: number = -1; private tBlockquote: number = -1;
  private tUlist: number = -1; private tOlist: number = -1; private tCodeBlock: number = -1;
  private tLink: number = -1; private tImage: number = -1; private tTable: number = -1;
  private tHr: number = -1; private tTask: number = -1; private tEdit: number = -1;
  private tSplit: number = -1; private tPreview: number = -1; private tUndo: number = -1;
  private tRedo: number = -1; private tExport: number = -1;

  private clr(k: string): void {
    let t: number = -1;
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
    if (t !== -1) clearTimeout(t);
    this.setT(k, -1);
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
  private tip(k: string): string {
    if (k === 'bold') return '粗体'; if (k === 'italic') return '斜体';
    if (k === 'strikethrough') return '删除线'; if (k === 'inlineCode') return '行内代码';
    if (k === 'heading') return '标题'; if (k === 'blockquote') return '引用';
    if (k === 'ulist') return '无序列表'; if (k === 'olist') return '有序列表';
    if (k === 'codeBlock') return '代码块'; if (k === 'link') return '超链接';
    if (k === 'image') return '图片'; if (k === 'table') return '表格';
    if (k === 'hr') return '分割线'; if (k === 'task') return '任务列表';
    if (k === 'edit') return '编辑'; if (k === 'split') return '分屏';
    if (k === 'preview') return '预览'; if (k === 'undo') return '撤销';
    if (k === 'redo') return '重做'; if (k === 'export') return '导出 HTML';
    return k;
  }

  build() {
    Row() {
      // B
      Button({ type: ButtonType.Normal }) { Text('B').fontSize(14).fontColor(this.themeColors.toolbarFg) }
      .width(32).height(32).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
      .onClick(() => { if (this.onCommand) this.onCommand('bold'); })
      .bindPopup(this.hBold, { message: this.tip('bold'), placement: Placement.Top, showInSubWindow: true })
      .onHover((isHover: boolean) => { this.clr('bold'); if (isHover) this.hBold = true; else { const t = setTimeout(() => { this.hBold = false; }, 400); this.tBold = t; } })
      // I
      Button({ type: ButtonType.Normal }) { Text('I').fontSize(14).fontColor(this.themeColors.toolbarFg) }
      .width(32).height(32).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
      .onClick(() => { if (this.onCommand) this.onCommand('italic'); })
      .bindPopup(this.hItalic, { message: this.tip('italic'), showInSubWindow: true, placement: Placement.Top })
      .onHover((isHover: boolean) => { this.clr('italic'); if (isHover) this.hItalic = true; else { const t = setTimeout(() => { this.hItalic = false; }, 400); this.tItalic = t; } })
      // S
      Button({ type: ButtonType.Normal }) { Text('S').fontSize(14).fontColor(this.themeColors.toolbarFg) }
      .width(32).height(32).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
      .onClick(() => { if (this.onCommand) this.onCommand('strikethrough'); })
      .bindPopup(this.hStrike, { message: this.tip('strikethrough'), showInSubWindow: true, placement: Placement.Top })
      .onHover((isHover: boolean) => { this.clr('strikethrough'); if (isHover) this.hStrike = true; else { const t = setTimeout(() => { this.hStrike = false; }, 400); this.tStrike = t; } })
      // <>
      Button({ type: ButtonType.Normal }) { Text('<>').fontSize(14).fontColor(this.themeColors.toolbarFg) }
      .width(32).height(32).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
      .onClick(() => { if (this.onCommand) this.onCommand('inlineCode'); })
      .bindPopup(this.hInlineCode, { message: this.tip('inlineCode'), showInSubWindow: true, placement: Placement.Top })
      .onHover((isHover: boolean) => { this.clr('inlineCode'); if (isHover) this.hInlineCode = true; else { const t = setTimeout(() => { this.hInlineCode = false; }, 400); this.tInlineCode = t; } })

      Divider().vertical(true).height(20).width(1).color(this.themeColors.previewBorder).margin({ left: 4, right: 4 })

      // H
      Button({ type: ButtonType.Normal }) { Text('H').fontSize(14).fontColor(this.themeColors.toolbarFg) }
      .width(32).height(32).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
      .onClick(() => { if (this.onCommand) this.onCommand('heading'); })
      .bindPopup(this.hHeading, { message: this.tip('heading'), showInSubWindow: true, placement: Placement.Top })
      .onHover((isHover: boolean) => { this.clr('heading'); if (isHover) this.hHeading = true; else { const t = setTimeout(() => { this.hHeading = false; }, 400); this.tHeading = t; } })
      // ❝
      Button({ type: ButtonType.Normal }) { Text('❝').fontSize(14).fontColor(this.themeColors.toolbarFg) }
      .width(32).height(32).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
      .onClick(() => { if (this.onCommand) this.onCommand('blockquote'); })
      .bindPopup(this.hBlockquote, { message: this.tip('blockquote'), showInSubWindow: true, placement: Placement.Top })
      .onHover((isHover: boolean) => { this.clr('blockquote'); if (isHover) this.hBlockquote = true; else { const t = setTimeout(() => { this.hBlockquote = false; }, 400); this.tBlockquote = t; } })
      // •
      Button({ type: ButtonType.Normal }) { Text('•').fontSize(14).fontColor(this.themeColors.toolbarFg) }
      .width(32).height(32).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
      .onClick(() => { if (this.onCommand) this.onCommand('ulist'); })
      .bindPopup(this.hUlist, { message: this.tip('ulist'), showInSubWindow: true, placement: Placement.Top })
      .onHover((isHover: boolean) => { this.clr('ulist'); if (isHover) this.hUlist = true; else { const t = setTimeout(() => { this.hUlist = false; }, 400); this.tUlist = t; } })
      // 1.
      Button({ type: ButtonType.Normal }) { Text('1.').fontSize(14).fontColor(this.themeColors.toolbarFg) }
      .width(32).height(32).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
      .onClick(() => { if (this.onCommand) this.onCommand('olist'); })
      .bindPopup(this.hOlist, { message: this.tip('olist'), showInSubWindow: true, placement: Placement.Top })
      .onHover((isHover: boolean) => { this.clr('olist'); if (isHover) this.hOlist = true; else { const t = setTimeout(() => { this.hOlist = false; }, 400); this.tOlist = t; } })
      // { }
      Button({ type: ButtonType.Normal }) { Text('{ }').fontSize(14).fontColor(this.themeColors.toolbarFg) }
      .width(32).height(32).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
      .onClick(() => { if (this.onCommand) this.onCommand('codeBlock'); })
      .bindPopup(this.hCodeBlock, { message: this.tip('codeBlock'), showInSubWindow: true, placement: Placement.Top })
      .onHover((isHover: boolean) => { this.clr('codeBlock'); if (isHover) this.hCodeBlock = true; else { const t = setTimeout(() => { this.hCodeBlock = false; }, 400); this.tCodeBlock = t; } })

      Divider().vertical(true).height(20).width(1).color(this.themeColors.previewBorder).margin({ left: 4, right: 4 })

      // 🔗
      Button({ type: ButtonType.Normal }) { Text('🔗').fontSize(14).fontColor(this.themeColors.toolbarFg) }
      .width(32).height(32).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
      .onClick(() => { if (this.onCommand) this.onCommand('link'); })
      .bindPopup(this.hLink, { message: this.tip('link'), showInSubWindow: true, placement: Placement.Top })
      .onHover((isHover: boolean) => { this.clr('link'); if (isHover) this.hLink = true; else { const t = setTimeout(() => { this.hLink = false; }, 400); this.tLink = t; } })
      // 🖼
      Button({ type: ButtonType.Normal }) { Text('🖼').fontSize(14).fontColor(this.themeColors.toolbarFg) }
      .width(32).height(32).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
      .onClick(() => { if (this.onCommand) this.onCommand('image'); })
      .bindPopup(this.hImage, { message: this.tip('image'), showInSubWindow: true, placement: Placement.Top })
      .onHover((isHover: boolean) => { this.clr('image'); if (isHover) this.hImage = true; else { const t = setTimeout(() => { this.hImage = false; }, 400); this.tImage = t; } })
      // ⊞
      Button({ type: ButtonType.Normal }) { Text('⊞').fontSize(14).fontColor(this.themeColors.toolbarFg) }
      .width(32).height(32).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
      .onClick(() => { if (this.onCommand) this.onCommand('table'); })
      .bindPopup(this.hTable, { message: this.tip('table'), showInSubWindow: true, placement: Placement.Top })
      .onHover((isHover: boolean) => { this.clr('table'); if (isHover) this.hTable = true; else { const t = setTimeout(() => { this.hTable = false; }, 400); this.tTable = t; } })
      // —
      Button({ type: ButtonType.Normal }) { Text('—').fontSize(14).fontColor(this.themeColors.toolbarFg) }
      .width(32).height(32).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
      .onClick(() => { if (this.onCommand) this.onCommand('hr'); })
      .bindPopup(this.hHr, { message: this.tip('hr'), showInSubWindow: true, placement: Placement.Top })
      .onHover((isHover: boolean) => { this.clr('hr'); if (isHover) this.hHr = true; else { const t = setTimeout(() => { this.hHr = false; }, 400); this.tHr = t; } })
      // ☑
      Button({ type: ButtonType.Normal }) { Text('☑').fontSize(14).fontColor(this.themeColors.toolbarFg) }
      .width(32).height(32).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
      .onClick(() => { if (this.onCommand) this.onCommand('task'); })
      .bindPopup(this.hTask, { message: this.tip('task'), showInSubWindow: true, placement: Placement.Top })
      .onHover((isHover: boolean) => { this.clr('task'); if (isHover) this.hTask = true; else { const t = setTimeout(() => { this.hTask = false; }, 400); this.tTask = t; } })

      Divider().vertical(true).height(20).width(1).color(this.themeColors.previewBorder).margin({ left: 4, right: 4 })

      // ✏️
      Button({ type: ButtonType.Normal }) { Text('✏️').fontSize(14).fontColor(this.viewMode === ViewMode.Edit ? this.themeColors.toolbarActive : this.themeColors.toolbarFg).fontWeight(this.viewMode === ViewMode.Edit ? 700 : 400) }
      .width(32).height(32).padding(0).backgroundColor(this.viewMode === ViewMode.Edit ? this.themeColors.toolbarHover : Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
      .onClick(() => { if (this.onCommand) this.onCommand('edit'); })
      .bindPopup(this.hEdit, { message: this.tip('edit'), showInSubWindow: true, placement: Placement.Top })
      .onHover((isHover: boolean) => { this.clr('edit'); if (isHover) this.hEdit = true; else { const t = setTimeout(() => { this.hEdit = false; }, 400); this.tEdit = t; } })
      // ⇔
      Button({ type: ButtonType.Normal }) { Text('⇔').fontSize(14).fontColor(this.viewMode === ViewMode.Split ? this.themeColors.toolbarActive : this.themeColors.toolbarFg).fontWeight(this.viewMode === ViewMode.Split ? 700 : 400) }
      .width(32).height(32).padding(0).backgroundColor(this.viewMode === ViewMode.Split ? this.themeColors.toolbarHover : Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
      .onClick(() => { if (this.onCommand) this.onCommand('split'); })
      .bindPopup(this.hSplit, { message: this.tip('split'), showInSubWindow: true, placement: Placement.Top })
      .onHover((isHover: boolean) => { this.clr('split'); if (isHover) this.hSplit = true; else { const t = setTimeout(() => { this.hSplit = false; }, 400); this.tSplit = t; } })
      // 👁
      Button({ type: ButtonType.Normal }) { Text('👁').fontSize(14).fontColor(this.viewMode === ViewMode.Preview ? this.themeColors.toolbarActive : this.themeColors.toolbarFg).fontWeight(this.viewMode === ViewMode.Preview ? 700 : 400) }
      .width(32).height(32).padding(0).backgroundColor(this.viewMode === ViewMode.Preview ? this.themeColors.toolbarHover : Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
      .onClick(() => { if (this.onCommand) this.onCommand('preview'); })
      .bindPopup(this.hPreview, { message: this.tip('preview'), showInSubWindow: true, placement: Placement.Top })
      .onHover((isHover: boolean) => { this.clr('preview'); if (isHover) this.hPreview = true; else { const t = setTimeout(() => { this.hPreview = false; }, 400); this.tPreview = t; } })

      Blank()

      // ↩
      Button({ type: ButtonType.Normal }) { Text('↩').fontSize(14).fontColor(this.themeColors.toolbarFg) }
      .width(32).height(32).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
      .onClick(() => { if (this.onCommand) this.onCommand('undo'); })
      .bindPopup(this.hUndo, { message: this.tip('undo'), showInSubWindow: true, placement: Placement.Top })
      .onHover((isHover: boolean) => { this.clr('undo'); if (isHover) this.hUndo = true; else { const t = setTimeout(() => { this.hUndo = false; }, 400); this.tUndo = t; } })
      // ↪
      Button({ type: ButtonType.Normal }) { Text('↪').fontSize(14).fontColor(this.themeColors.toolbarFg) }
      .width(32).height(32).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
      .onClick(() => { if (this.onCommand) this.onCommand('redo'); })
      .bindPopup(this.hRedo, { message: this.tip('redo'), showInSubWindow: true, placement: Placement.Top })
      .onHover((isHover: boolean) => { this.clr('redo'); if (isHover) this.hRedo = true; else { const t = setTimeout(() => { this.hRedo = false; }, 400); this.tRedo = t; } })
      // 导出
      Button({ type: ButtonType.Normal }) { Text('导出').fontSize(12).fontColor(this.themeColors.toolbarFg) }
      .height(28).padding({ left: 10, right: 10 }).backgroundColor(this.themeColors.toolbarBg).borderRadius(4)
      .border({ width: 1, color: this.themeColors.previewBorder }).margin({ left: 4 })
      .onClick(() => { if (this.onExport) this.onExport(); })
      .bindPopup(this.hExport, { message: this.tip('export'), showInSubWindow: true, placement: Placement.Top })
      .onHover((isHover: boolean) => { this.clr('export'); if (isHover) this.hExport = true; else { const t = setTimeout(() => { this.hExport = false; }, 400); this.tExport = t; } })
    }
    .width('100%').height(44).padding({ left: 8, right: 8 })
    .backgroundColor(this.themeColors.toolbarBg)
    .border({ width: { bottom: 1 }, color: this.themeColors.previewBorder })
  }
}

export enum ViewMode {
  Edit = 'edit', Split = 'split', Preview = 'preview',
}
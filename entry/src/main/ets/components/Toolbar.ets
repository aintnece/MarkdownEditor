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

  build() {
    Row() {
      // === 文本样式 ===
      Button({ type: ButtonType.Normal }) { Text('B').fontSize(14).fontColor(this.themeColors.toolbarFg) }
        .width(32).height(28).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
        .onClick(() => { if (this.onCommand) this.onCommand('bold'); })
        .bindPopup(this.hBold, { message: '粗体', showInSubWindow: true })
        .onHover((isHover: boolean) => { this.hBold = isHover; })

      Button({ type: ButtonType.Normal }) { Text('I').fontSize(14).fontColor(this.themeColors.toolbarFg) }
        .width(32).height(28).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
        .onClick(() => { if (this.onCommand) this.onCommand('italic'); })
        .bindPopup(this.hItalic, { message: '斜体', showInSubWindow: true })
        .onHover((isHover: boolean) => { this.hItalic = isHover; })

      Button({ type: ButtonType.Normal }) { Text('S').fontSize(14).fontColor(this.themeColors.toolbarFg) }
        .width(32).height(28).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
        .onClick(() => { if (this.onCommand) this.onCommand('strikethrough'); })
        .bindPopup(this.hStrike, { message: '删除线', showInSubWindow: true })
        .onHover((isHover: boolean) => { this.hStrike = isHover; })

      Button({ type: ButtonType.Normal }) { Text('<>').fontSize(14).fontColor(this.themeColors.toolbarFg) }
        .width(32).height(28).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
        .onClick(() => { if (this.onCommand) this.onCommand('inlineCode'); })
        .bindPopup(this.hInlineCode, { message: '行内代码', showInSubWindow: true })
        .onHover((isHover: boolean) => { this.hInlineCode = isHover; })

      this.div()

      // === 块级元素 ===
      Button({ type: ButtonType.Normal }) { Text('H').fontSize(14).fontColor(this.themeColors.toolbarFg) }
        .width(32).height(28).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
        .onClick(() => { if (this.onCommand) this.onCommand('heading'); })
        .bindPopup(this.hHeading, { message: '标题', showInSubWindow: true })
        .onHover((isHover: boolean) => { this.hHeading = isHover; })

      Button({ type: ButtonType.Normal }) { Text('❝').fontSize(14).fontColor(this.themeColors.toolbarFg) }
        .width(32).height(28).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
        .onClick(() => { if (this.onCommand) this.onCommand('blockquote'); })
        .bindPopup(this.hBlockquote, { message: '引用', showInSubWindow: true })
        .onHover((isHover: boolean) => { this.hBlockquote = isHover; })

      Button({ type: ButtonType.Normal }) { Text('•').fontSize(14).fontColor(this.themeColors.toolbarFg) }
        .width(32).height(28).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
        .onClick(() => { if (this.onCommand) this.onCommand('ulist'); })
        .bindPopup(this.hUlist, { message: '无序列表', showInSubWindow: true })
        .onHover((isHover: boolean) => { this.hUlist = isHover; })

      Button({ type: ButtonType.Normal }) { Text('1.').fontSize(14).fontColor(this.themeColors.toolbarFg) }
        .width(32).height(28).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
        .onClick(() => { if (this.onCommand) this.onCommand('olist'); })
        .bindPopup(this.hOlist, { message: '有序列表', showInSubWindow: true })
        .onHover((isHover: boolean) => { this.hOlist = isHover; })

      Button({ type: ButtonType.Normal }) { Text('{ }').fontSize(14).fontColor(this.themeColors.toolbarFg) }
        .width(32).height(28).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
        .onClick(() => { if (this.onCommand) this.onCommand('codeBlock'); })
        .bindPopup(this.hCodeBlock, { message: '代码块', showInSubWindow: true })
        .onHover((isHover: boolean) => { this.hCodeBlock = isHover; })

      this.div()

      // === 插入 ===
      Button({ type: ButtonType.Normal }) { Text('🔗').fontSize(14).fontColor(this.themeColors.toolbarFg) }
        .width(32).height(28).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
        .onClick(() => { if (this.onCommand) this.onCommand('link'); })
        .bindPopup(this.hLink, { message: '超链接', showInSubWindow: true })
        .onHover((isHover: boolean) => { this.hLink = isHover; })

      Button({ type: ButtonType.Normal }) { Text('🖼').fontSize(14).fontColor(this.themeColors.toolbarFg) }
        .width(32).height(28).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
        .onClick(() => { if (this.onCommand) this.onCommand('image'); })
        .bindPopup(this.hImage, { message: '图片', showInSubWindow: true })
        .onHover((isHover: boolean) => { this.hImage = isHover; })

      Button({ type: ButtonType.Normal }) { Text('⊞').fontSize(14).fontColor(this.themeColors.toolbarFg) }
        .width(32).height(28).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
        .onClick(() => { if (this.onCommand) this.onCommand('table'); })
        .bindPopup(this.hTable, { message: '表格', showInSubWindow: true })
        .onHover((isHover: boolean) => { this.hTable = isHover; })

      Button({ type: ButtonType.Normal }) { Text('—').fontSize(14).fontColor(this.themeColors.toolbarFg) }
        .width(32).height(28).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
        .onClick(() => { if (this.onCommand) this.onCommand('hr'); })
        .bindPopup(this.hHr, { message: '分割线', showInSubWindow: true })
        .onHover((isHover: boolean) => { this.hHr = isHover; })

      Button({ type: ButtonType.Normal }) { Text('☑').fontSize(14).fontColor(this.themeColors.toolbarFg) }
        .width(32).height(28).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
        .onClick(() => { if (this.onCommand) this.onCommand('task'); })
        .bindPopup(this.hTask, { message: '任务列表', showInSubWindow: true })
        .onHover((isHover: boolean) => { this.hTask = isHover; })

      this.div()

      // === 视图模式 ===
      Button({ type: ButtonType.Normal }) {
        Text('✏️').fontSize(14)
          .fontColor(this.viewMode === ViewMode.Edit ? this.themeColors.toolbarActive : this.themeColors.toolbarFg)
          .fontWeight(this.viewMode === ViewMode.Edit ? 700 : 400)
      }
      .width(32).height(28).padding(0)
      .backgroundColor(this.viewMode === ViewMode.Edit ? this.themeColors.toolbarHover : Color.Transparent)
      .borderRadius(4).margin({ left: 2, right: 2 })
      .onClick(() => { if (this.onCommand) this.onCommand('edit'); })
      .bindPopup(this.hEdit, { message: '编辑', showInSubWindow: true })
      .onHover((isHover: boolean) => { this.hEdit = isHover; })

      Button({ type: ButtonType.Normal }) {
        Text('⇔').fontSize(14)
          .fontColor(this.viewMode === ViewMode.Split ? this.themeColors.toolbarActive : this.themeColors.toolbarFg)
          .fontWeight(this.viewMode === ViewMode.Split ? 700 : 400)
      }
      .width(32).height(28).padding(0)
      .backgroundColor(this.viewMode === ViewMode.Split ? this.themeColors.toolbarHover : Color.Transparent)
      .borderRadius(4).margin({ left: 2, right: 2 })
      .onClick(() => { if (this.onCommand) this.onCommand('split'); })
      .bindPopup(this.hSplit, { message: '分屏', showInSubWindow: true })
      .onHover((isHover: boolean) => { this.hSplit = isHover; })

      Button({ type: ButtonType.Normal }) {
        Text('👁').fontSize(14)
          .fontColor(this.viewMode === ViewMode.Preview ? this.themeColors.toolbarActive : this.themeColors.toolbarFg)
          .fontWeight(this.viewMode === ViewMode.Preview ? 700 : 400)
      }
      .width(32).height(28).padding(0)
      .backgroundColor(this.viewMode === ViewMode.Preview ? this.themeColors.toolbarHover : Color.Transparent)
      .borderRadius(4).margin({ left: 2, right: 2 })
      .onClick(() => { if (this.onCommand) this.onCommand('preview'); })
      .bindPopup(this.hPreview, { message: '预览', showInSubWindow: true })
      .onHover((isHover: boolean) => { this.hPreview = isHover; })

      Blank()

      // === 操作 ===
      Button({ type: ButtonType.Normal }) { Text('↩').fontSize(14).fontColor(this.themeColors.toolbarFg) }
        .width(32).height(28).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
        .onClick(() => { if (this.onCommand) this.onCommand('undo'); })
        .bindPopup(this.hUndo, { message: '撤销', showInSubWindow: true })
        .onHover((isHover: boolean) => { this.hUndo = isHover; })

      Button({ type: ButtonType.Normal }) { Text('↪').fontSize(14).fontColor(this.themeColors.toolbarFg) }
        .width(32).height(28).padding(0).backgroundColor(Color.Transparent).borderRadius(4).margin({ left: 2, right: 2 })
        .onClick(() => { if (this.onCommand) this.onCommand('redo'); })
        .bindPopup(this.hRedo, { message: '重做', showInSubWindow: true })
        .onHover((isHover: boolean) => { this.hRedo = isHover; })

      Button({ type: ButtonType.Normal }) {
        Text('导出').fontSize(12).fontColor(this.themeColors.toolbarFg)
      }
      .height(28).padding({ left: 10, right: 10 })
      .backgroundColor(this.themeColors.toolbarBg).borderRadius(4)
      .border({ width: 1, color: this.themeColors.previewBorder }).margin({ left: 4 })
      .onClick(() => { if (this.onExport) this.onExport(); })
      .bindPopup(this.hExport, { message: '导出 HTML', showInSubWindow: true })
      .onHover((isHover: boolean) => { this.hExport = isHover; })
    }
    .width('100%').height(44).padding({ left: 8, right: 8 })
    .backgroundColor(this.themeColors.toolbarBg)
    .border({ width: { bottom: 1 }, color: this.themeColors.previewBorder })
  }

  @Builder div() {
    Divider().vertical(true).height(20).width(1)
      .color(this.themeColors.previewBorder).margin({ left: 4, right: 4 })
  }
}

export enum ViewMode {
  Edit = 'edit', Split = 'split', Preview = 'preview',
}
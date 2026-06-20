import { ThemeColors } from '../services/ThemeService';

/**
 * SidePanel 组件
 *
 * 侧面板，提供：文件浏览 / 文档大纲 / 最近文件
 * 使用 bindPopup 显示 tooltip，与 Toolbar 一致
 */
@Component
export struct SidePanel {
  @Prop themeColors: ThemeColors;

  @State private activeTab: PanelTab = PanelTab.Files;
  @State private fileList: FileItem[] = [];
  @State private outlineItems: OutlineItem[] = [];
  @State private recentFiles: RecentFileItem[] = [];
  @State private expanded: boolean = true;

  // bindPopup hover states
  @State private hFiles: boolean = false;
  @State private hOutline: boolean = false;
  @State private hRecent: boolean = false;
  @State private hToggle: boolean = false;

  // timers: positive = pending show
  private tFiles: number = 0;
  private tOutline: number = 0;
  private tRecent: number = 0;
  private tToggle: number = 0;

  onFileSelect?: (path: string) => void;
  onHeadingSelect?: (headingId: string) => void;

  aboutToAppear(): void {
    this.loadSampleOutline();
  }

  build() {
    Row() {
      Column() {
        // 📁 文件浏览
        Button({ type: ButtonType.Normal }) {
          Text('📁').fontSize(16).opacity(this.activeTab === PanelTab.Files ? 1.0 : 0.6)
        }
        .width(28).height(28).padding(0)
        .backgroundColor(this.activeTab === PanelTab.Files ? this.themeColors.sidebarActive : Color.Transparent)
        .borderRadius(4).margin({ top: 4 })
        .bindPopup(this.hFiles, { message: '文件浏览', placement: Placement.Top, showInSubWindow: true })
        .onHover((isHover: boolean) => { if (isHover) this.hoverEnter('files'); else this.hoverLeave('files'); })
        .onClick(() => { this.activeTab = PanelTab.Files; })

        // 📑 文档大纲
        Button({ type: ButtonType.Normal }) {
          Text('📑').fontSize(16).opacity(this.activeTab === PanelTab.Outline ? 1.0 : 0.6)
        }
        .width(28).height(28).padding(0)
        .backgroundColor(this.activeTab === PanelTab.Outline ? this.themeColors.sidebarActive : Color.Transparent)
        .borderRadius(4).margin({ top: 4 })
        .bindPopup(this.hOutline, { message: '文档大纲', placement: Placement.Top, showInSubWindow: true })
        .onHover((isHover: boolean) => { if (isHover) this.hoverEnter('outline'); else this.hoverLeave('outline'); })
        .onClick(() => { this.activeTab = PanelTab.Outline; })

        // 🕐 最近文件
        Button({ type: ButtonType.Normal }) {
          Text('🕐').fontSize(16).opacity(this.activeTab === PanelTab.Recent ? 1.0 : 0.6)
        }
        .width(28).height(28).padding(0)
        .backgroundColor(this.activeTab === PanelTab.Recent ? this.themeColors.sidebarActive : Color.Transparent)
        .borderRadius(4).margin({ top: 4 })
        .bindPopup(this.hRecent, { message: '最近文件', placement: Placement.Top, showInSubWindow: true })
        .onHover((isHover: boolean) => { if (isHover) this.hoverEnter('recent'); else this.hoverLeave('recent'); })
        .onClick(() => { this.activeTab = PanelTab.Recent; })

        Blank()

        // 展开/收起
        if (this.expanded) {
          Button({ type: ButtonType.Normal }) {
            Text('◀').fontSize(12).fontColor(this.themeColors.sidebarFg)
          }
          .width(28).height(28).backgroundColor(Color.Transparent).borderRadius(4)
          .bindPopup(this.hToggle, { message: '收起侧栏', placement: Placement.Top, showInSubWindow: true })
          .onHover((isHover: boolean) => { if (isHover) this.hoverEnter('toggle'); else this.hoverLeave('toggle'); })
          .onClick(() => { this.expanded = false; })
        } else {
          Button({ type: ButtonType.Normal }) {
            Text('▶').fontSize(12).fontColor(this.themeColors.sidebarFg)
          }
          .width(28).height(28).backgroundColor(Color.Transparent).borderRadius(4)
          .bindPopup(this.hToggle, { message: '展开侧栏', placement: Placement.Top, showInSubWindow: true })
          .onHover((isHover: boolean) => { if (isHover) this.hoverEnter('toggle'); else this.hoverLeave('toggle'); })
          .onClick(() => { this.expanded = true; })
        }
      }
      .width(32).height('100%')
      .backgroundColor(this.themeColors.sidebarBg).padding({ top: 4 })

      // 内容区域
      if (this.expanded) {
        Column() {
          Text(this.getTabTitle())
            .fontSize(13).fontWeight(600)
            .fontColor(this.themeColors.sidebarFg)
            .height(36).padding({ left: 12, top: 8 })

          if (this.activeTab === PanelTab.Files) {
            this.buildFileList()
          } else if (this.activeTab === PanelTab.Outline) {
            this.buildOutline()
          } else {
            this.buildRecentList()
          }
        }
        .layoutWeight(1).height('100%')
        .backgroundColor(this.themeColors.sidebarBg)
      }
    }
    .width(this.expanded ? 220 : 32).height('100%')
    .border({ width: { right: 1 }, color: this.themeColors.previewBorder })
  }

  @Builder buildFileList() {
    Scroll() {
      Column() {
        ForEach(this.fileList, (item: FileItem) => {
          Row() {
            Text('📄').fontSize(14).margin({ right: 6 })
            Text(item.name).fontSize(13).fontColor(this.themeColors.sidebarFg)
          }
          .width('100%').padding({ left: 12, top: 6, bottom: 6, right: 8 }).borderRadius(4)
          .onClick(() => { if (this.onFileSelect) this.onFileSelect(item.path); })
        }, (item: FileItem) => item.path)
      }
      .width('100%').padding(4)
    }
    .width('100%').layoutWeight(1)
  }

  @Builder buildOutline() {
    Scroll() {
      Column() {
        ForEach(this.outlineItems, (item: OutlineItem) => {
          Text(item.text)
            .fontSize(item.level === 1 ? 14 : item.level === 2 ? 13 : 12)
            .fontWeight(item.level === 1 ? 600 : 400)
            .fontColor(this.themeColors.sidebarFg)
            .width('100%')
            .padding({ left: 12 + (item.level - 1) * 16, top: 4, bottom: 4, right: 8 }).borderRadius(4)
            .onClick(() => { if (this.onHeadingSelect) this.onHeadingSelect(item.id); })
        }, (item: OutlineItem) => item.id)
      }
      .width('100%').padding(4)
    }
    .width('100%').layoutWeight(1)
  }

  @Builder buildRecentList() {
    Scroll() {
      Column() {
        ForEach(this.recentFiles, (item: RecentFileItem) => {
          Row() {
            Text('📄').fontSize(14).margin({ right: 6 })
            Column() {
              Text(item.name).fontSize(13).fontColor(this.themeColors.sidebarFg)
              Text(item.timeAgo).fontSize(11).fontColor(this.themeColors.editorLineNumber)
            }.layoutWeight(1)
          }
          .width('100%').padding({ left: 12, top: 6, bottom: 6, right: 8 }).borderRadius(4)
          .onClick(() => { if (this.onFileSelect) this.onFileSelect(item.path); })
        }, (item: RecentFileItem) => item.path)
      }
      .width('100%').padding(4)
    }
    .width('100%').layoutWeight(1)
  }

  updateFiles(files: FileItem[]): void { this.fileList = files; }
  updateOutline(headings: OutlineItem[]): void { this.outlineItems = headings; }
  updateRecent(files: RecentFileItem[]): void { this.recentFiles = files; }

  private getTabTitle(): string {
    if (this.activeTab === PanelTab.Files) return '文件浏览';
    if (this.activeTab === PanelTab.Outline) return '文档大纲';
    if (this.activeTab === PanelTab.Recent) return '最近文件';
    return '';
  }

  private loadSampleOutline(): void {}

  // ── Hover / bindPopup 方法（与 Toolbar 一致） ──

  private clrAll(k: string): void {
    let t: number = 0;
    if (k === 'files') t = this.tFiles;
    else if (k === 'outline') t = this.tOutline;
    else if (k === 'recent') t = this.tRecent;
    else if (k === 'toggle') t = this.tToggle;
    if (t !== 0) { clearTimeout(t); }
    this.setT(k, 0);
  }

  private setT(k: string, v: number): void {
    if (k === 'files') this.tFiles = v;
    else if (k === 'outline') this.tOutline = v;
    else if (k === 'recent') this.tRecent = v;
    else if (k === 'toggle') this.tToggle = v;
  }

  private setPop(k: string, v: boolean): void {
    if (k === 'files') this.hFiles = v;
    else if (k === 'outline') this.hOutline = v;
    else if (k === 'recent') this.hRecent = v;
    else if (k === 'toggle') this.hToggle = v;
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
}

export enum PanelTab { Files = 'files', Outline = 'outline', Recent = 'recent' }

export interface FileItem { path: string; name: string; isDirectory?: boolean; lastModified?: number }
export interface OutlineItem { id: string; text: string; level: number }
export interface RecentFileItem { path: string; name: string; timeAgo: string }

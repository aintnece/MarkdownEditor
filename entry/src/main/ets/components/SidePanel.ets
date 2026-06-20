import { ThemeColors } from '../services/ThemeService';

/**
 * SidePanel 组件
 *
 * 侧面板，提供：文件浏览 / 文档大纲 / 最近文件
 * Tooltip 用 Stack + 内联 Text，不用 bindPopup（子窗口热区拦截点击）
 */
@Component
export struct SidePanel {
  @Prop themeColors: ThemeColors;

  @State private activeTab: PanelTab = PanelTab.Files;
  @State private fileList: FileItem[] = [];
  @State private outlineItems: OutlineItem[] = [];
  @State private recentFiles: RecentFileItem[] = [];
  @State private expanded: boolean = true;

  // Hover tooltips — inline Text, no bindPopup/subwindow
  @State private hTabFiles: boolean = false;
  @State private hTabOutline: boolean = false;
  @State private hTabRecent: boolean = false;
  @State private hToggle: boolean = false;

  onFileSelect?: (path: string) => void;
  onHeadingSelect?: (headingId: string) => void;

  aboutToAppear(): void {
    this.loadSampleOutline();
  }

  build() {
    Stack({ alignContent: Alignment.Start }) {
      Row() {
        Column() {
          // 图标按钮栏
          // 📁 文件浏览
          Button({ type: ButtonType.Normal }) {
            Text('📁').fontSize(16).opacity(this.activeTab === PanelTab.Files ? 1.0 : 0.6)
          }
          .width(28).height(28).padding(0)
          .backgroundColor(this.activeTab === PanelTab.Files ? this.themeColors.sidebarActive : Color.Transparent)
          .borderRadius(4).margin({ top: 4 })
          .onHover((isHover: boolean) => { this.hTabFiles = isHover; })
          .onClick(() => { this.activeTab = PanelTab.Files; })

          // 📑 文档大纲
          Button({ type: ButtonType.Normal }) {
            Text('📑').fontSize(16).opacity(this.activeTab === PanelTab.Outline ? 1.0 : 0.6)
          }
          .width(28).height(28).padding(0)
          .backgroundColor(this.activeTab === PanelTab.Outline ? this.themeColors.sidebarActive : Color.Transparent)
          .borderRadius(4).margin({ top: 4 })
          .onHover((isHover: boolean) => { this.hTabOutline = isHover; })
          .onClick(() => { this.activeTab = PanelTab.Outline; })

          // 🕐 最近文件
          Button({ type: ButtonType.Normal }) {
            Text('🕐').fontSize(16).opacity(this.activeTab === PanelTab.Recent ? 1.0 : 0.6)
          }
          .width(28).height(28).padding(0)
          .backgroundColor(this.activeTab === PanelTab.Recent ? this.themeColors.sidebarActive : Color.Transparent)
          .borderRadius(4).margin({ top: 4 })
          .onHover((isHover: boolean) => { this.hTabRecent = isHover; })
          .onClick(() => { this.activeTab = PanelTab.Recent; })

          Blank()

          // 展开/收起
          if (this.expanded) {
            Button({ type: ButtonType.Normal }) {
              Text('◀').fontSize(12).fontColor(this.themeColors.sidebarFg)
            }
            .width(28).height(28).backgroundColor(Color.Transparent).borderRadius(4)
            .onHover((isHover: boolean) => { this.hToggle = isHover; })
            .onClick(() => { this.expanded = false; })
          } else {
            Button({ type: ButtonType.Normal }) {
              Text('▶').fontSize(12).fontColor(this.themeColors.sidebarFg)
            }
            .width(28).height(28).backgroundColor(Color.Transparent).borderRadius(4)
            .onHover((isHover: boolean) => { this.hToggle = isHover; })
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

      // ── 内联 tooltip（浮在 Row 上层，不受 32px 裁剪） ──
      if (this.hTabFiles) {
        Text('文件浏览')
          .fontSize(11).fontColor('#fff')
          .backgroundColor('#333333').borderRadius(4)
          .padding({ left: 6, right: 6, top: 3, bottom: 3 })
          .position({ x: 36, y: 8 })
      }
      if (this.hTabOutline) {
        Text('文档大纲')
          .fontSize(11).fontColor('#fff')
          .backgroundColor('#333333').borderRadius(4)
          .padding({ left: 6, right: 6, top: 3, bottom: 3 })
          .position({ x: 36, y: 40 })
      }
      if (this.hTabRecent) {
        Text('最近文件')
          .fontSize(11).fontColor('#fff')
          .backgroundColor('#333333').borderRadius(4)
          .padding({ left: 6, right: 6, top: 3, bottom: 3 })
          .position({ x: 36, y: 72 })
      }
      if (this.hToggle) {
        Text(this.expanded ? '收起侧栏' : '展开侧栏')
          .fontSize(11).fontColor('#fff')
          .backgroundColor('#333333').borderRadius(4)
          .padding({ left: 6, right: 6, top: 3, bottom: 3 })
          .position({ x: 36, y: this.expanded ? 400 : 140 })
      }
    }
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
}

export enum PanelTab { Files = 'files', Outline = 'outline', Recent = 'recent' }

export interface FileItem { path: string; name: string; isDirectory?: boolean; lastModified?: number }
export interface OutlineItem { id: string; text: string; level: number }
export interface RecentFileItem { path: string; name: string; timeAgo: string }

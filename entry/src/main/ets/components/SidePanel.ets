import { ThemeColors } from '../services/ThemeService';

/**
 * SidePanel 组件
 *
 * 侧面板，提供：文件浏览 / 文档大纲 / 最近文件
 * 提示使用底部文字栏（避免 bindPopup 子窗口拦截点击）
 */

@Component
export struct SidePanel {
  @Prop themeColors: ThemeColors;

  @State private activeTab: PanelTab = PanelTab.Files;
  @State private fileList: FileItem[] = [];
  @State private outlineItems: OutlineItem[] = [];
  @State private recentFiles: RecentFileItem[] = [];
  @State private expanded: boolean = true;

  // 底部提示
  @State private tipText: string = '';
  @State private showTip: boolean = false;

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
        .onHover((isHover: boolean) => { this.setTip(isHover, '文件浏览'); })
        .onClick(() => { this.activeTab = PanelTab.Files; })

        // 📑 文档大纲
        Button({ type: ButtonType.Normal }) {
          Text('📑').fontSize(16).opacity(this.activeTab === PanelTab.Outline ? 1.0 : 0.6)
        }
        .width(28).height(28).padding(0)
        .backgroundColor(this.activeTab === PanelTab.Outline ? this.themeColors.sidebarActive : Color.Transparent)
        .borderRadius(4).margin({ top: 4 })
        .onHover((isHover: boolean) => { this.setTip(isHover, '文档大纲'); })
        .onClick(() => { this.activeTab = PanelTab.Outline; })

        // 🕐 最近文件
        Button({ type: ButtonType.Normal }) {
          Text('🕐').fontSize(16).opacity(this.activeTab === PanelTab.Recent ? 1.0 : 0.6)
        }
        .width(28).height(28).padding(0)
        .backgroundColor(this.activeTab === PanelTab.Recent ? this.themeColors.sidebarActive : Color.Transparent)
        .borderRadius(4).margin({ top: 4 })
        .onHover((isHover: boolean) => { this.setTip(isHover, '最近文件'); })
        .onClick(() => { this.activeTab = PanelTab.Recent; })

        Blank()

        // 底部提示文字（替代 bindPopup，不创建子窗口）
        if (this.showTip) {
          Text(this.tipText)
            .fontSize(10).fontColor(this.themeColors.sidebarFg)
            .maxLines(2).textAlign(TextAlign.Center)
            .padding({ top: 4, bottom: 4 }).margin({ bottom: 2 })
        }

        // 展开/收起
        if (this.expanded) {
          Button({ type: ButtonType.Normal }) {
            Text('◀').fontSize(12).fontColor(this.themeColors.sidebarFg)
          }
          .width(28).height(28).backgroundColor(Color.Transparent).borderRadius(4)
          .onHover((isHover: boolean) => { this.setTip(isHover, '收起侧栏'); })
          .onClick(() => { this.expanded = false; })
        } else {
          Button({ type: ButtonType.Normal }) {
            Text('▶').fontSize(12).fontColor(this.themeColors.sidebarFg)
          }
          .width(28).height(28).backgroundColor(Color.Transparent).borderRadius(4)
          .onHover((isHover: boolean) => { this.setTip(isHover, '展开侧栏'); })
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

  private setTip(show: boolean, text: string): void {
    if (show) {
      this.tipText = text;
      this.showTip = true;
    } else {
      this.showTip = false;
      this.tipText = '';
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

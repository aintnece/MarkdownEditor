import { ThemeColors } from '../services/ThemeService';

/**
 * SidePanel 组件
 *
 * 侧面板，提供：
 *   - 文件浏览器（当前目录 Markdown 文件列表）
 *   - 文档大纲（各级标题导航）
 *   - 最近文件列表
 */

@Component
export struct SidePanel {
  // ── 组件属性 ──
  @Link themeColors: ThemeColors;

  @State private activeTab: PanelTab = PanelTab.Files;
  @State private fileList: FileItem[] = [];
  @State private outlineItems: OutlineItem[] = [];
  @State private recentFiles: RecentFileItem[] = [];
  @State private expanded: boolean = true;

  // 气泡状态
  @State private hTabFiles: boolean = false;
  @State private hTabOutline: boolean = false;
  @State private hTabRecent: boolean = false;
  @State private hCollapse: boolean = false;

  onFileSelect?: (path: string) => void;
  onHeadingSelect?: (headingId: string) => void;

  aboutToAppear(): void {
    this.loadSampleOutline();
  }

  build() {
    if (!this.expanded) {
      // 收起状态：只显示标签图标（内联 bindPopup）
      Column() {
        // 📁 文件浏览
        Button({ type: ButtonType.Normal }) {
          Text('📁').fontSize(16)
        }
        .width(28).height(28).padding(0)
        .backgroundColor(Color.Transparent).borderRadius(4).margin({ top: 4 })
        .bindPopup(this.hTabFiles, { message: '文件浏览', placement: Placement.Right, showInSubWindow: true })
        .onHover((isHover: boolean) => { this.hTabFiles = isHover; })

        // 📑 文档大纲
        Button({ type: ButtonType.Normal }) {
          Text('📑').fontSize(16)
        }
        .width(28).height(28).padding(0)
        .backgroundColor(Color.Transparent).borderRadius(4).margin({ top: 4 })
        .bindPopup(this.hTabOutline, { message: '文档大纲', placement: Placement.Right, showInSubWindow: true })
        .onHover((isHover: boolean) => { this.hTabOutline = isHover; })

        // 🕐 最近文件
        Button({ type: ButtonType.Normal }) {
          Text('🕐').fontSize(16)
        }
        .width(28).height(28).padding(0)
        .backgroundColor(Color.Transparent).borderRadius(4).margin({ top: 4 })
        .bindPopup(this.hTabRecent, { message: '最近文件', placement: Placement.Right, showInSubWindow: true })
        .onHover((isHover: boolean) => { this.hTabRecent = isHover; })

        Blank()
      }
      .width(32)
      .height('100%')
      .backgroundColor(this.themeColors.sidebarBg)
      .border({ width: { right: 1 }, color: this.themeColors.previewBorder })
      .onClick(() => { this.expanded = true; })
    } else {
      Row() {
        // 标签栏（按钮直接内联 — bindPopup 不响应 @Builder 参数）
        Column() {
          // 📁 文件浏览
          Button({ type: ButtonType.Normal }) {
            Text('📁').fontSize(16).opacity(this.activeTab === PanelTab.Files ? 1.0 : 0.6)
          }
          .width(28).height(28).padding(0)
          .backgroundColor(this.activeTab === PanelTab.Files ? this.themeColors.sidebarActive : Color.Transparent)
          .borderRadius(4).margin({ top: 4 })
          .bindPopup(this.hTabFiles, { message: '文件浏览', placement: Placement.Right, showInSubWindow: true })
          .onHover((isHover: boolean) => { this.hTabFiles = isHover; })
          .onClick(() => { this.activeTab = PanelTab.Files; })

          // 📑 文档大纲
          Button({ type: ButtonType.Normal }) {
            Text('📑').fontSize(16).opacity(this.activeTab === PanelTab.Outline ? 1.0 : 0.6)
          }
          .width(28).height(28).padding(0)
          .backgroundColor(this.activeTab === PanelTab.Outline ? this.themeColors.sidebarActive : Color.Transparent)
          .borderRadius(4).margin({ top: 4 })
          .bindPopup(this.hTabOutline, { message: '文档大纲', placement: Placement.Right, showInSubWindow: true })
          .onHover((isHover: boolean) => { this.hTabOutline = isHover; })
          .onClick(() => { this.activeTab = PanelTab.Outline; })

          // 🕐 最近文件
          Button({ type: ButtonType.Normal }) {
            Text('🕐').fontSize(16).opacity(this.activeTab === PanelTab.Recent ? 1.0 : 0.6)
          }
          .width(28).height(28).padding(0)
          .backgroundColor(this.activeTab === PanelTab.Recent ? this.themeColors.sidebarActive : Color.Transparent)
          .borderRadius(4).margin({ top: 4 })
          .bindPopup(this.hTabRecent, { message: '最近文件', placement: Placement.Right, showInSubWindow: true })
          .onHover((isHover: boolean) => { this.hTabRecent = isHover; })
          .onClick(() => { this.activeTab = PanelTab.Recent; })

          Blank()

          // ◀ 收起侧栏
          Button({ type: ButtonType.Normal }) {
            Text('◀').fontSize(12).fontColor(this.themeColors.sidebarFg)
          }
          .width(28).height(28)
          .backgroundColor(Color.Transparent).borderRadius(4)
          .bindPopup(this.hCollapse, { message: '收起侧栏', placement: Placement.Right, showInSubWindow: true })
          .onHover((isHover: boolean) => { this.hCollapse = isHover; })
          .onClick(() => { this.expanded = false; })
        }
        .width(32)
        .height('100%')
        .backgroundColor(this.themeColors.sidebarBg)
        .padding({ top: 4 })

        // 内容区域
        Column() {
          Text(this.getTabTitle())
            .fontSize(13)
            .fontWeight(600)
            .fontColor(this.themeColors.sidebarFg)
            .height(36)
            .padding({ left: 12, top: 8 })

          if (this.activeTab === PanelTab.Files) {
            this.buildFileList()
          } else if (this.activeTab === PanelTab.Outline) {
            this.buildOutline()
          } else {
            this.buildRecentList()
          }
        }
        .layoutWeight(1)
        .height('100%')
        .backgroundColor(this.themeColors.sidebarBg)
      }
      .width(220)
      .height('100%')
      .border({ width: { right: 1 }, color: this.themeColors.previewBorder })
    }
  }

  @Builder
  buildFileList() {
    Scroll() {
      Column() {
        ForEach(this.fileList, (item: FileItem) => {
          Row() {
            Text('📄').fontSize(14).margin({ right: 6 })
            Text(item.name).fontSize(13).fontColor(this.themeColors.sidebarFg)
          }
          .width('100%')
          .padding({ left: 12, top: 6, bottom: 6, right: 8 })
          .borderRadius(4)
          .onClick(() => { if (this.onFileSelect) this.onFileSelect(item.path); })
        }, (item: FileItem) => item.path)
      }
      .width('100%').padding(4)
    }
    .width('100%').layoutWeight(1)
  }

  @Builder
  buildOutline() {
    Scroll() {
      Column() {
        ForEach(this.outlineItems, (item: OutlineItem) => {
          Text(item.text)
            .fontSize(item.level === 1 ? 14 : item.level === 2 ? 13 : 12)
            .fontWeight(item.level === 1 ? 600 : 400)
            .fontColor(this.themeColors.sidebarFg)
            .width('100%')
            .padding({ left: 12 + (item.level - 1) * 16, top: 4, bottom: 4, right: 8 })
            .borderRadius(4)
            .onClick(() => { if (this.onHeadingSelect) this.onHeadingSelect(item.id); })
        }, (item: OutlineItem) => item.id)
      }
      .width('100%').padding(4)
    }
    .width('100%').layoutWeight(1)
  }

  @Builder
  buildRecentList() {
    Scroll() {
      Column() {
        ForEach(this.recentFiles, (item: RecentFileItem) => {
          Row() {
            Text('📄').fontSize(14).margin({ right: 6 })
            Column() {
              Text(item.name).fontSize(13).fontColor(this.themeColors.sidebarFg)
              Text(item.timeAgo).fontSize(11).fontColor(this.themeColors.editorLineNumber)
            }
            .layoutWeight(1)
          }
          .width('100%')
          .padding({ left: 12, top: 6, bottom: 6, right: 8 })
          .borderRadius(4)
          .onClick(() => { if (this.onFileSelect) this.onFileSelect(item.path); })
        }, (item: RecentFileItem) => item.path)
      }
      .width('100%').padding(4)
    }
    .width('100%').layoutWeight(1)
  }

  // ── 公共方法 ──

  updateFiles(files: FileItem[]): void { this.fileList = files; }
  updateOutline(headings: OutlineItem[]): void { this.outlineItems = headings; }
  updateRecent(files: RecentFileItem[]): void { this.recentFiles = files; }

  // ── 内部方法 ──

  private getTabTitle(): string {
    switch (this.activeTab) {
      case PanelTab.Files: return '文件浏览';
      case PanelTab.Outline: return '文档大纲';
      case PanelTab.Recent: return '最近文件';
    }
  }

  private loadSampleOutline(): void {}
}

// ─── 类型定义 ─────────────────────────────────────

export enum PanelTab {
  Files = 'files',
  Outline = 'outline',
  Recent = 'recent',
}

export interface FileItem {
  path: string;
  name: string;
  isDirectory?: boolean;
  lastModified?: number;
}

export interface OutlineItem {
  id: string;
  text: string;
  level: number;
}

export interface RecentFileItem {
  path: string;
  name: string;
  timeAgo: string;
}

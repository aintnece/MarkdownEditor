/**
 * Index - 应用首页（文件选择器/欢迎页）
 *
 * 提供：
 *   - 最近文件列表
 *   - 新建文档按钮
 *   - 打开文件按钮
 *   - 快速入门指南
 */

import { router } from '@kit.AbilityKit';
import { picker } from '@kit.CoreFileKit';
import { fileIo } from '@kit.CoreFileKit';

import { ThemeService, BUILTIN_THEMES, ThemeColors } from '../services/ThemeService';
import { PreferencesManager } from '../utils/PreferencesManager';

@Observed
class HomeThemeBridge {
  bg: string = '#ffffff';
  fg: string = '#24292e';
  muted: string = '#959da5';
  cardBg: string = '#f6f8fa';
  cardHover: string = '#e1e4e8';
  accent: string = '#0366d6';
  border: string = '#dfe2e5';

  constructor(isDark: boolean) {
    const theme = isDark ? BUILTIN_THEMES.dark : BUILTIN_THEMES.light;
    this.bg = theme.editorBg;
    this.fg = theme.editorFg;
    this.muted = theme.editorLineNumber;
    this.cardBg = theme.sidebarBg;
    this.cardHover = theme.sidebarHover;
    this.accent = theme.previewLink;
    this.border = theme.previewBorder;
  }
}

@Entry
@Component
struct Index {
  @State private themeBridge: HomeThemeBridge = new HomeThemeBridge(false);
  @State private recentFiles: RecentFileItem[] = [];
  @State private showWelcome: boolean = true;

  aboutToAppear(): void {
    ThemeService.getInstance().init();
    const theme = ThemeService.getInstance().getTheme();
    this.themeBridge = new HomeThemeBridge(theme.isDark);
    this.loadRecentFiles();
  }

  build() {
    Column() {
      // 应用标题
      this.buildHeader()

      Scroll() {
        Column() {
          if (this.showWelcome) {
            this.buildWelcomeSection()
          }

          // 快捷操作
          this.buildQuickActions()

          // 最近文件
          if (this.recentFiles.length > 0) {
            this.buildRecentSection()
          }

          // Markdown 语法速查
          this.buildCheatSheet()
        }
        .width('100%')
        .padding({ left: 24, right: 24, top: 16, bottom: 40 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeBridge.bg)
  }

  @Builder
  buildHeader() {
    Row() {
      // 应用图标和名称
      Row() {
        Text('✍️')
          .fontSize(28)
          .margin({ right: 10 })
        Text('Markdown 编辑器')
          .fontSize(22)
          .fontWeight(700)
          .fontColor(this.themeBridge.fg)
      }

      Blank()

      // 设置按钮
      Button({ type: ButtonType.Normal }) {
        Text('⚙️')
          .fontSize(20)
      }
      .width(40)
      .height(40)
      .backgroundColor(Color.Transparent)
      .borderRadius(8)
      .onClick(() => {
        // 跳转到设置页（可选）
      })
    }
    .width('100%')
    .padding({ top: 16, bottom: 8, left: 24, right: 24 })
    .border({ width: { bottom: 1 }, color: this.themeBridge.border })
  }

  @Builder
  buildWelcomeSection() {
    Column() {
      // 大标题
      Text('欢迎使用')
        .fontSize(32)
        .fontWeight(700)
        .fontColor(this.themeBridge.fg)
        .margin({ top: 32 })

      Text('专为鸿蒙系统打造的 Markdown 编辑器')
        .fontSize(16)
        .fontColor(this.themeBridge.muted)
        .margin({ top: 8, bottom: 32 })

      // 功能亮点
      Row() {
        this.buildFeature('实时预览', '编辑同时预览渲染效果')
        this.buildFeature('语法高亮', '支持 10+ 编程语言')
        this.buildFeature('多主题', '深色/浅色/护眼模式')
      }
      .width('100%')
      .margin({ bottom: 32 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildFeature(title: string, desc: string) {
    Column() {
      Text(title)
        .fontSize(15)
        .fontWeight(600)
        .fontColor(this.themeBridge.fg)
      Text(desc)
        .fontSize(12)
        .fontColor(this.themeBridge.muted)
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .padding(12)
    .margin(4)
    .backgroundColor(this.themeBridge.cardBg)
    .borderRadius(8)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildQuickActions() {
    Row() {
      // 新建文档
      this.buildActionButton(
        '📄',
        '新建文档',
        '创建一个空白 Markdown 文件',
        () => this.createNewFile(),
      )

      // 打开文件
      this.buildActionButton(
        '📂',
        '打开文件',
        '从设备中选择 Markdown 文件',
        () => this.openFile(),
      )

      // 快速笔记
      this.buildActionButton(
        '📝',
        '快速笔记',
        '打开临时笔记窗口',
        () => this.createQuickNote(),
      )
    }
    .width('100%')
    .margin({ top: 8, bottom: 8 })
  }

  @Builder
  buildActionButton(icon: string, title: string, desc: string, onClick: () => void) {
    Column() {
      Text(icon)
        .fontSize(32)
        .margin({ bottom: 8 })
      Text(title)
        .fontSize(15)
        .fontWeight(600)
        .fontColor(this.themeBridge.fg)
      Text(desc)
        .fontSize(12)
        .fontColor(this.themeBridge.muted)
        .margin({ top: 4 })
        .textAlign(TextAlign.Center)
    }
    .layoutWeight(1)
    .padding(16)
    .margin(6)
    .backgroundColor(this.themeBridge.cardBg)
    .borderRadius(10)
    .border({ width: 1, color: this.themeBridge.border })
    .onClick(() => onClick())
  }

  @Builder
  buildRecentSection() {
    Column() {
      Row() {
        Text('最近文件')
          .fontSize(16)
          .fontWeight(600)
          .fontColor(this.themeBridge.fg)

        Blank()

        Text('全部清除')
          .fontSize(13)
          .fontColor(this.themeBridge.accent)
          .onClick(() => {
            this.recentFiles = [];
          })
      }
      .width('100%')
      .margin({ top: 24, bottom: 12 })

      ForEach(this.recentFiles, (file: RecentFileItem, index: number) => {
        Row() {
          Text(file.icon || '📄')
            .fontSize(18)
            .margin({ right: 12 })
          Column() {
            Text(file.name)
              .fontSize(14)
              .fontWeight(500)
              .fontColor(this.themeBridge.fg)
            Text(file.path)
              .fontSize(11)
              .fontColor(this.themeBridge.muted)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .layoutWeight(1)

          Text(file.timeAgo)
            .fontSize(11)
            .fontColor(this.themeBridge.muted)
        }
        .width('100%')
        .padding(12)
        .backgroundColor(this.themeBridge.cardBg)
        .borderRadius(8)
        .margin({ top: 4, bottom: 4 })
        .onClick(() => {
          this.openRecentFile(file);
        })
      }, (file: RecentFileItem, index: number) => file.path + index)
    }
    .width('100%')
  }

  @Builder
  buildCheatSheet() {
    Column() {
      Text('Markdown 快速入门')
        .fontSize(16)
        .fontWeight(600)
        .fontColor(this.themeBridge.fg)
        .margin({ top: 24, bottom: 12 })

      this.buildCheatItem('# 标题', '一级标题')
      this.buildCheatItem('**粗体** *斜体*', '文本样式')
      this.buildCheatItem('- 列表项', '无序列表')
      this.buildCheatItem('1. 列表项', '有序列表')
      this.buildCheatItem('```code```', '代码块')
      this.buildCheatItem('[链接](url)', '超链接')
      this.buildCheatItem('![图片](url)', '图片')
      this.buildCheatItem('| 列1 | 列2 |', '表格')
    }
    .width('100%')
  }

  @Builder
  buildCheatItem(code: string, desc: string) {
    Row() {
      Text(code)
        .fontSize(13)
        .fontFamily("'Cascadia Code', 'JetBrains Mono', monospace")
        .fontColor(this.themeBridge.accent)
        .backgroundColor(this.themeBridge.cardBg)
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .borderRadius(4)

      Blank()

      Text(desc)
        .fontSize(13)
        .fontColor(this.themeBridge.muted)
    }
    .width('100%')
    .margin({ top: 4, bottom: 4 })
  }

  // ── 页面导航 ──

  private async createNewFile(): Promise<void> {
    router.pushUrl({
      url: 'pages/EditorPage',
      params: { newFile: true },
    });
  }

  private async openFile(): Promise<void> {
    try {
      const context = getContext(this);
      const documentPicker = new picker.DocumentViewPicker(context);
      const uris = await documentPicker.select({
        maxSelectCount: 1,
        fileSuffixFilters: ['.md', '.markdown', '.mdown', '.txt'],
      });

      if (uris.length > 0) {
        router.pushUrl({
          url: 'pages/EditorPage',
          params: { filePath: uris[0] },
        });
      }
    } catch (err) {
      console.error('[Index] open file error:', JSON.stringify(err));
    }
  }

  private createQuickNote(): void {
    router.pushUrl({
      url: 'pages/EditorPage',
      params: { newFile: true, quickNote: true },
    });
  }

  private openRecentFile(file: RecentFileItem): void {
    router.pushUrl({
      url: 'pages/EditorPage',
      params: { filePath: file.path },
    });
  }

  private async loadRecentFiles(): Promise<void> {
    try {
      const data = await PreferencesManager.getInstance().load('recentFiles');
      if (data) {
        const files: RecentFileItem[] = JSON.parse(data);
        this.recentFiles = files.slice(0, 10)
          .sort((a, b) => b.lastOpened - a.lastOpened)
          .map(f => ({
            ...f,
            timeAgo: this.formatTimeAgo(f.lastOpened),
          }));
      }
    } catch {
      this.recentFiles = [];
    }
  }

  private formatTimeAgo(ts: number): string {
    const diff = Date.now() - ts;
    if (diff < 60000) return '刚刚';
    if (diff < 3600000) return `${Math.floor(diff / 60000)} 分钟前`;
    if (diff < 86400000) return `${Math.floor(diff / 3600000)} 小时前`;
    return `${Math.floor(diff / 86400000)} 天前`;
  }
}

interface RecentFileItem {
  path: string;
  name: string;
  lastOpened: number;
  timeAgo: string;
  icon?: string;
}

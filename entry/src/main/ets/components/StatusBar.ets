/**
 * StatusBar 组件
 *
 * 底部状态栏，显示：
 *   - 字数统计（字符/单词/行数）
 *   - 当前行/列位置
 *   - 文件编码信息
 *   - 编辑模式（插入/改写）
 *   - 保存状态
 */

@Component
export struct StatusBar {
  @Link themeColors: ThemeColors;

  @State private charCount: number = 0;
  @State private wordCount: number = 0;
  @State private lineCount: number = 0;
  @State private cursorLine: number = 1;
  @State private cursorCol: number = 1;
  @State private readTime: number = 1;
  @State private saved: boolean = true;
  @State private fileSize: string = '';

  build() {
    Row() {
      // 左侧：统计信息
      Row() {
        this.buildStatItem('行', this.lineCount.toString())
        this.buildDivider()
        this.buildStatItem('字', this.charCount.toString())
        this.buildDivider()
        this.buildStatItem('词', this.wordCount.toString())
        this.buildDivider()
        this.buildStatItem('阅读', `${this.readTime}min`)
      }
      .margin({ left: 8 })

      Blank()

      // 右侧：编辑信息
      Row() {
        if (!this.saved) {
          Text('● 未保存')
            .fontSize(11)
            .fontColor('#e74c3c')
            .margin({ right: 12 })
        }
        this.buildStatItem('位置', `L${this.cursorLine}:${this.cursorCol}`)
        if (this.fileSize) {
          this.buildDivider()
          this.buildStatItem('大小', this.fileSize)
        }
        Text('UTF-8')
          .fontSize(11)
          .fontColor(this.themeColors.editorLineNumber)
          .margin({ right: 8, left: 8 })
      }
      .margin({ right: 8 })
    }
    .width('100%')
    .height(24)
    .backgroundColor(this.themeColors.toolbarBg)
    .border({ width: { top: 1 }, color: this.themeColors.previewBorder })
    .padding({ left: 4, right: 4 })
  }

  @Builder
  buildStatItem(label: string, value: string) {
    Row() {
      Text(value)
        .fontSize(11)
        .fontColor(this.themeColors.toolbarFg)
        .fontWeight(500)
      Text(' ' + label)
        .fontSize(11)
        .fontColor(this.themeColors.editorLineNumber)
    }
    .margin({ left: 6, right: 6 })
  }

  @Builder
  buildDivider() {
    Text('·')
      .fontSize(11)
      .fontColor(this.themeColors.editorLineNumber)
  }

  // ── 公共方法 ──

  /** 更新统计信息 */
  updateStats(text: string, line: number, col: number): void {
    this.charCount = text.length;
    this.lineCount = text.split('\n').length;
    this.wordCount = this.countWords(text);
    this.readTime = Math.max(1, Math.ceil(this.wordCount / 300));
    this.cursorLine = line;
    this.cursorCol = col;
  }

  /** 更新保存状态 */
  updateSaveStatus(saved: boolean): void {
    this.saved = saved;
  }

  /** 更新文件大小 */
  updateFileSize(bytes: number): void {
    if (bytes < 1024) this.fileSize = `${bytes}B`;
    else if (bytes < 1024 * 1024) this.fileSize = `${(bytes / 1024).toFixed(1)}KB`;
    else this.fileSize = `${(bytes / (1024 * 1024)).toFixed(1)}MB`;
  }

  private countWords(text: string): number {
    const chineseChars = text.match(/[\u4e00-\u9fff\u3400-\u4dbf\uf900-\ufaff]/g) || [];
    const englishWords = text
      .replace(/[\u4e00-\u9fff\u3400-\u4dbf\uf900-\ufaff]/g, ' ')
      .split(/\s+/)
      .filter(w => w.length > 0);
    return chineseChars.length + englishWords.length;
  }
}

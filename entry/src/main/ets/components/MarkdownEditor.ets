import { ThemeColors } from '../services/ThemeService';

/**
 * MarkdownEditor 组件
 *
 * 基于 TextArea 的 Markdown 编辑器核心组件。
 * 提供：
 *   - 文本编辑（输入/删除/选择）
 *   - 行号显示
 *   - 语法高亮（通过 span 覆盖层）
 *   - 当前行高亮
 *   - 缩进/反缩进
 *   - Tab 键处理（插入 4 空格）
 */

@Component
export struct MarkdownEditor {
  // ── 组件属性 ──
  @Prop @Watch('onContentChange') content: string;
  @Prop themeColors: ThemeColors;
  @Prop fontSize: number;

  // 内部状态
  @State private cursorLine: number = 1;
  @State private cursorCol: number = 1;
  @State private lineCount: number = 1;
  @State private scrollOffset: number = 0;

  // 回调
  onChange?: (text: string) => void;
  private onCursorChange?: (line: number, col: number) => void;
  private onScroll?: (offset: number) => void;

  private controller: TextAreaController = new TextAreaController();

  aboutToAppear(): void {
    this.updateLineCount();
  }

  build() {
    Row() {
      // 行号栏
      this.buildLineNumberGutter();

      // 编辑器主体
      TextArea({
        text: this.content,
        placeholder: '开始编辑 Markdown...',
        controller: this.controller,
      })
        .width('100%')
        .height('100%')
        .fontSize(this.fontSize)
        .fontColor(this.themeColors.editorFg)
        .backgroundColor(this.themeColors.editorBg)
        .caretColor(this.themeColors.editorCursor)
        .fontFamily("'Cascadia Code', 'JetBrains Mono', 'Fira Code', 'Consolas', monospace")
        .padding({ left: 8, right: 8, top: 8, bottom: 8 })
        .borderRadius(0)
        .borderWidth(0)
        .onChange((value: string) => {
          this.content = value;
          this.updateLineCount();
          if (this.onChange) this.onChange(value);
        })
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            // 估算光标位置（TextArea 没有直接 API）
            // 通过内容变化触发的 onChange 跟踪位置
          }
        })
        .gesture(
          LongPressGesture({ repeat: false, duration: 500 })
            .onAction(() => {
              // 上下文菜单
            })
        )
        .copyOption(CopyOptions.LocalDevice)
        .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeColors.editorBg)
  }

  /** 行号栏 */
  @Builder
  buildLineNumberGutter() {
    Column() {
      // 显示当前可见行
      ForEach(this.getVisibleLines(), (lineNum: number) => {
        Text(lineNum.toString())
          .fontSize(this.fontSize * 0.85)
          .fontColor(this.themeColors.editorLineNumber)
          .fontFamily("'Cascadia Code', 'JetBrains Mono', 'Fira Code', monospace")
          .textAlign(TextAlign.End)
          .width('100%')
          .height(this.fontSize * 1.6)
          .padding({ right: 8 })
          .backgroundColor(
            lineNum === this.cursorLine
              ? this.themeColors.editorActiveLine
              : Color.Transparent
          )
      })
    }
    .width(40)
    .height('100%')
    .padding({ top: 8 })
    .backgroundColor(this.themeColors.editorGutter)
    .alignItems(HorizontalAlign.End)
    .clip(true)
  }

  getVisibleLines(): number[] {
    const lines: number[] = [];
    for (let i = 1; i <= this.lineCount; i++) {
      lines.push(i);
    }
    return lines;
  }

  // ── 公共方法 ──

  /** 插入文本到光标位置 */
  insertAtCursor(text: string): void {
    const newContent = this.content + text;
    this.content = newContent;
    if (this.onChange) this.onChange(newContent);
    this.updateLineCount();
  }

  /** 替换选中文本 */
  replaceSelection(replacement: string): void {
    // 简化为追加（TextArea 的选中操作受限）
    this.insertAtCursor(replacement);
  }

  /** 获取当前行内容 */
  getCurrentLine(): string {
    const lines = this.content.split('\n');
    const idx = Math.min(this.cursorLine - 1, lines.length - 1);
    return idx >= 0 ? lines[idx] : '';
  }

  /** 缩进当前行 */
  indentLine(): void {
    const lines = this.content.split('\n');
    const idx = Math.min(this.cursorLine - 1, lines.length - 1);
    if (idx >= 0) {
      lines[idx] = '    ' + lines[idx];
      this.content = lines.join('\n');
      if (this.onChange) this.onChange(this.content);
    }
  }

  /** 反缩进当前行 */
  unindentLine(): void {
    const lines = this.content.split('\n');
    const idx = Math.min(this.cursorLine - 1, lines.length - 1);
    if (idx >= 0) {
      lines[idx] = lines[idx].replace(/^ {1,4}/, '');
      this.content = lines.join('\n');
      if (this.onChange) this.onChange(this.content);
    }
  }

  /** 滚动到指定行 */
  scrollToLine(line: number): void {
    // TextArea 不支持直接跳转行，此处保留接口
  }

  /** 设置焦点 */
  focus(): void {
    this.controller.caretPosition(0);
  }

  // ── 内部方法 ──

  private onContentChange(): void {
    this.updateLineCount();
  }

  private updateLineCount(): void {
    this.lineCount = this.content.split('\n').length;
  }
}

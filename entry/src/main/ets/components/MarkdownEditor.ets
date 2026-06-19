import { ThemeColors } from '../services/ThemeService';

/**
 * MarkdownEditor 组件
 *
 * 基于 TextArea 的 Markdown 编辑器核心组件。
 */

@Component
export struct MarkdownEditor {
  @Prop content: string;
  @Prop themeColors: ThemeColors;
  @Prop fontSize: number;

  @State private cursorLine: number = 1;
  @State private cursorCol: number = 1;
  @State private lineCount: number = 1;
  @State private scrollOffset: number = 0;

  onChange?: (text: string) => void;

  private controller: TextAreaController = new TextAreaController();

  aboutToAppear(): void {
    this.updateLineCount();
  }

  build() {
    Row() {
      this.buildLineNumberGutter();

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
          if (this.onChange) this.onChange(value);
          this.updateLineCount();
        })
        .copyOption(CopyOptions.LocalDevice)
        .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeColors.editorBg)
  }

  @Builder
  buildLineNumberGutter() {
    Column() {
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

  insertAtCursor(text: string): void {
    const newContent = this.content + text;
    this.content = newContent;
    if (this.onChange) this.onChange(newContent);
    this.updateLineCount();
  }

  replaceSelection(replacement: string): void {
    this.insertAtCursor(replacement);
  }

  getCurrentLine(): string {
    const lines = this.content.split('\n');
    const idx = Math.min(this.cursorLine - 1, lines.length - 1);
    return idx >= 0 ? lines[idx] : '';
  }

  indentLine(): void {
    const lines = this.content.split('\n');
    const idx = Math.min(this.cursorLine - 1, lines.length - 1);
    if (idx >= 0) {
      lines[idx] = '    ' + lines[idx];
      this.content = lines.join('\n');
      if (this.onChange) this.onChange(this.content);
    }
  }

  unindentLine(): void {
    const lines = this.content.split('\n');
    const idx = Math.min(this.cursorLine - 1, lines.length - 1);
    if (idx >= 0) {
      lines[idx] = lines[idx].replace(/^ {1,4}/, '');
      this.content = lines.join('\n');
      if (this.onChange) this.onChange(this.content);
    }
  }

  scrollToLine(line: number): void {
  }

  focus(): void {
    this.controller.caretPosition(0);
  }

  private updateLineCount(): void {
    this.lineCount = this.content.split('\n').length;
  }
}

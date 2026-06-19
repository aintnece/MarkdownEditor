import { ThemeColors } from '../services/ThemeService';

/**
 * Toolbar 组件
 *
 * 编辑器格式化工具栏，提供：
 *   - 文本样式（粗体/斜体/删除线/行内代码）
 *   - 块级元素（标题/引用/列表/代码块）
 *   - 插入（链接/图片/表格/分割线）
 *   - 编辑操作（撤销/重做/缩进）
 *   - 分割面板控制（编辑/预览/分屏切换）
 *   - 导出按钮
 *   - 鼠标悬停显示功能提示
 */

@Component
export struct Toolbar {
  // ── 组件属性 ──
  @Link themeColors: ThemeColors;

  onCommand?: (command: string) => void;
  onExport?: () => void;

  // 视图模式
  @Link viewMode: ViewMode;

  // 鼠标悬停状态（显示 tooltip）
  @State private hoveredButton: string = '';

  build() {
    Column({ space: 0 }) {
      Row() {
        this.buildStyleGroup();
        this.buildDivider();
        this.buildBlockGroup();
        this.buildDivider();
        this.buildInsertGroup();
        this.buildDivider();
        this.buildViewGroup();
        this.buildSpacer();
        this.buildExtraGroup();
      }
      .width('100%')
      .height(44)
      .padding({ left: 8, right: 8 })
      .backgroundColor(this.themeColors.toolbarBg)

      // 工具提示条（鼠标悬停时显示）
      if (this.hoveredButton !== '') {
        Text(this.getTooltip(this.hoveredButton))
          .fontSize(11)
          .fontColor('#ffffff')
          .backgroundColor(this.themeColors.toolbarActive)
          .width('100%')
          .height(20)
          .padding({ left: 10, right: 10 })
          .textAlign(TextAlign.Start)
      }
    }
    .width('100%')
    .border({ width: { bottom: 1 }, color: this.themeColors.previewBorder })
  }

  /** 根据命令名获取中文提示 */
  private getTooltip(command: string): string {
    if (command === 'bold') return '粗体';
    if (command === 'italic') return '斜体';
    if (command === 'strikethrough') return '删除线';
    if (command === 'inlineCode') return '行内代码';
    if (command === 'heading') return '标题';
    if (command === 'blockquote') return '引用';
    if (command === 'ulist') return '无序列表';
    if (command === 'olist') return '有序列表';
    if (command === 'codeBlock') return '代码块';
    if (command === 'link') return '插入超链接';
    if (command === 'image') return '插入图片';
    if (command === 'table') return '插入表格';
    if (command === 'hr') return '插入分割线';
    if (command === 'task') return '任务列表';
    if (command === 'edit') return '仅编辑模式';
    if (command === 'split') return '分屏模式（编辑+预览）';
    if (command === 'preview') return '仅预览模式';
    if (command === 'undo') return '撤销';
    if (command === 'redo') return '重做';
    if (command === 'export') return '导出为 HTML 文件';
    return command;
  }

  @Builder
  buildStyleGroup() {
    this.buildToolButton('B', 'bold');
    this.buildToolButton('I', 'italic');
    this.buildToolButton('S', 'strikethrough');
    this.buildToolButton('<>', 'inlineCode');
  }

  @Builder
  buildBlockGroup() {
    this.buildToolButton('H', 'heading');
    this.buildToolButton('❝', 'blockquote');
    this.buildToolButton('•', 'ulist');
    this.buildToolButton('1.', 'olist');
    this.buildToolButton('{ }', 'codeBlock');
  }

  @Builder
  buildInsertGroup() {
    this.buildToolButton('🔗', 'link');
    this.buildToolButton('🖼', 'image');
    this.buildToolButton('⊞', 'table');
    this.buildToolButton('—', 'hr');
    this.buildToolButton('☑', 'task');
  }

  @Builder
  buildViewGroup() {
    this.buildToolButton('✏️', 'edit', this.viewMode === ViewMode.Edit);
    this.buildToolButton('⇔', 'split', this.viewMode === ViewMode.Split);
    this.buildToolButton('👁', 'preview', this.viewMode === ViewMode.Preview);
  }

  @Builder
  buildExtraGroup() {
    this.buildToolButton('↩', 'undo');
    this.buildToolButton('↪', 'redo');
    Button({ type: ButtonType.Normal }) {
      Text('导出')
        .fontSize(12)
        .fontColor(this.themeColors.toolbarFg)
    }
    .height(28)
    .padding({ left: 10, right: 10 })
    .backgroundColor(this.themeColors.toolbarBg)
    .borderRadius(4)
    .border({ width: 1, color: this.themeColors.previewBorder })
    .margin({ left: 4 })
    .onClick(() => {
      if (this.onExport) this.onExport();
    })
    .onHover((isHover: boolean, _event: HoverEvent) => {
      this.hoveredButton = isHover ? 'export' : '';
    })
  }

  @Builder
  buildToolButton(icon: string, command: string, active: boolean = false) {
    Button({ type: ButtonType.Normal }) {
      Text(icon)
        .fontSize(14)
        .fontColor(active ? this.themeColors.toolbarActive : this.themeColors.toolbarFg)
        .fontWeight(active ? 700 : 400)
    }
    .width(32)
    .height(28)
    .padding(0)
    .backgroundColor(active ? this.themeColors.toolbarHover : Color.Transparent)
    .borderRadius(4)
    .margin({ left: 2, right: 2 })
    .onClick(() => {
      if (this.onCommand) this.onCommand(command);
    })
    .onHover((isHover: boolean, _event: HoverEvent) => {
      this.hoveredButton = isHover ? command : '';
    })
  }

  @Builder
  buildDivider() {
    Divider()
      .vertical(true)
      .height(20)
      .width(1)
      .color(this.themeColors.previewBorder)
      .margin({ left: 4, right: 4 })
  }

  @Builder
  buildSpacer() {
    Blank()
  }
}

export enum ViewMode {
  Edit = 'edit',
  Split = 'split',
  Preview = 'preview',
}

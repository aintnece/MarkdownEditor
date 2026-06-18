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
 */

@Component
export struct Toolbar {
  // ── 组件属性 ──
  @Link themeColors: ThemeColors;

  private onCommand?: (command: string) => void;
  private onExport?: () => void;

  // 视图模式
  @Link viewMode: ViewMode;

  build() {
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
    .borderRadius(0)
    .border({ width: { bottom: 1 }, color: this.themeColors.previewBorder })
  }

  @Builder
  buildStyleGroup() {
    // 粗体
    this.buildToolButton('B', 'bold', '粗体');
    // 斜体
    this.buildToolButton('I', 'italic', '斜体');
    // 删除线
    this.buildToolButton('S', 'strikethrough', '删除线');
    // 行内代码
    this.buildToolButton('<>', 'inlineCode', '行内代码');
  }

  @Builder
  buildBlockGroup() {
    // 标题
    this.buildToolButton('H', 'heading', '标题');
    // 引用
    this.buildToolButton('❝', 'blockquote', '引用');
    // 无序列表
    this.buildToolButton('•', 'ulist', '无序列表');
    // 有序列表
    this.buildToolButton('1.', 'olist', '有序列表');
    // 代码块
    this.buildToolButton('{ }', 'codeBlock', '代码块');
  }

  @Builder
  buildInsertGroup() {
    // 链接
    this.buildToolButton('🔗', 'link', '插入链接');
    // 图片
    this.buildToolButton('🖼', 'image', '插入图片');
    // 表格
    this.buildToolButton('⊞', 'table', '插入表格');
    // 分割线
    this.buildToolButton('—', 'hr', '分割线');
    // 任务列表
    this.buildToolButton('☑', 'task', '任务列表');
  }

  @Builder
  buildViewGroup() {
    // 编辑模式
    this.buildToolButton('✏️', 'edit', '编辑', this.viewMode === ViewMode.Edit);
    // 分屏模式
    this.buildToolButton('⇔', 'split', '分屏', this.viewMode === ViewMode.Split);
    // 预览模式
    this.buildToolButton('👁', 'preview', '预览', this.viewMode === ViewMode.Preview);
  }

  @Builder
  buildExtraGroup() {
    // 撤销
    this.buildToolButton('↩', 'undo', '撤销');
    // 重做
    this.buildToolButton('↪', 'redo', '重做');
    // 导出
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
  }

  @Builder
  buildToolButton(icon: string, command: string, tooltip: string, active: boolean = false) {
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

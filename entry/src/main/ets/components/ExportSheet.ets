/**
 * 导出选择弹窗
 *
 * 提供 MD 保存 / HTML 保存 / 打印（含另存为 PDF）
 * 渲染在全屏 Stack 中作为 overlay
 */

@Component
export struct ExportSheet {
  @Prop visible: boolean;
  @Prop themeColors: object;
  onSelect?: (fmt: ExportFormat) => void;
  onClose?: () => void;

  build() {
    if (this.visible) {
      Column() {
        Blank()
        // 弹窗内容（底部弹出）
        Column({ space: 0 }) {
          Text('导出文档')
            .fontSize(18).fontWeight(600)
            .width('100%').padding({ left: 16, top: 16, bottom: 8 })
            .fontColor('#1a1a2e')

          this.item('📄', '保存 Markdown (.md)', ExportFormat.MD)
          this.item('🌐', '保存网页 (.html)', ExportFormat.HTML)
          this.item('🖨️', '打印 / 另存为 PDF', ExportFormat.PRINT)

          Divider().width('100%').margin({ top: 8 })
          Button('取消')
            .width('100%').height(44).fontSize(16)
            .backgroundColor(Color.Transparent).fontColor('#666')
            .onClick(() => { if (this.onClose) this.onClose(); })
        }
        .width('100%')
        .backgroundColor('#ffffff')
        .borderRadius({ topLeft: 16, topRight: 16 })
        .padding({ bottom: 20 })
      }
      .width('100%').height('100%')
      .backgroundColor('rgba(0,0,0,0.3)')
      .onClick(() => { if (this.onClose) this.onClose(); })
    }
  }

  @Builder item(icon: string, label: string, fmt: ExportFormat) {
    Row({ space: 12 }) {
      Text(icon).fontSize(22)
      Column() {
        Text(label).fontSize(15).fontColor('#1a1a2e')
      }
      Blank()
      Text('›').fontSize(20).fontColor('#ccc')
    }
    .width('100%').height(48)
    .padding({ left: 16, right: 16 })
    .onClick(() => {
      if (this.onSelect) this.onSelect(fmt);
    })
  }
}

export enum ExportFormat {
  MD = 'md', HTML = 'html', PRINT = 'print',
}

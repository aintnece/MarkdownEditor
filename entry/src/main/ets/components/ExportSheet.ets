/**
 * 导出选择弹窗
 *
 * 提供 MD / HTML / PDF / 打印 四种导出方式
 */

@Component
export struct ExportSheet {
  @Prop visible: boolean;
  @Link themeColors: object;
  onSelect?: (fmt: ExportFormat) => void;
  onClose?: () => void;

  build() {
    if (this.visible) {
      Column() {
        // 遮罩
        Column()
          .width('100%').height('100%')
          .backgroundColor('rgba(0,0,0,0.3)')
          .onClick(() => { if (this.onClose) this.onClose(); })

        // 弹窗内容
        Column({ space: 0 }) {
          Text('导出文档')
            .fontSize(18).fontWeight(600)
            .width('100%').padding({ left: 16, top: 16, bottom: 8 })
            .fontColor('#1a1a2e')

          this.item('📄', 'Markdown (.md)', ExportFormat.MD)
          this.item('🌐', 'HTML 网页 (.html)', ExportFormat.HTML)
          this.item('📑', 'PDF 文档 (.pdf)', ExportFormat.PDF)
          this.item('🖨️', '直接打印', ExportFormat.PRINT)

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
      .position({ x: 0, y: 0 })
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
  MD = 'md', HTML = 'html', PDF = 'pdf', PRINT = 'print',
}

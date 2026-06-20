import { picker } from '@kit.CoreFileKit';
import { fileIo } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { webview } from '@kit.ArkWeb';
import { print } from '@kit.BasicServicesKit';

export enum ExportFormat {
  MD = 'md', HTML = 'html', PDF = 'pdf', PRINT = 'print',
}

export class ExportService {
  private context: common.Context;

  constructor(context: common.Context) {
    this.context = context;
  }

  /** 导出 MD 文件 */
  async saveMD(content: string): Promise<void> {
    const docPicker = new picker.DocumentViewPicker(this.context);
    const options = new picker.DocumentSaveOptions();
    options.newFileNames = ['document.md'];
    options.fileSuffixChoices = ['Markdown|.md'];
    try {
      const uris: Array<string> = await docPicker.save(options);
      if (uris.length > 0) {
        this.writeFile(uris[0], content);
      }
    } catch (err) {
      console.error('saveMD failed: ' + String(err));
    }
  }

  /** 导出 HTML 文件 */
  async saveHTML(html: string): Promise<void> {
    const docPicker = new picker.DocumentViewPicker(this.context);
    const options = new picker.DocumentSaveOptions();
    options.newFileNames = ['document.html'];
    options.fileSuffixChoices = ['HTML 文件|.html'];
    try {
      const uris: Array<string> = await docPicker.save(options);
      if (uris.length > 0) {
        this.writeFile(uris[0], html);
      }
    } catch (err) {
      console.error('saveHTML failed: ' + String(err));
    }
  }

  /** 导出 PDF（通过 WebView 打印 API 生成） */
  exportPdf(webCtrl: webview.WebviewController): void {
    try {
      const adapter = webCtrl.createWebPrintDocumentAdapter('markdown_export.pdf');
      print.print('markdown_export', adapter);
    } catch (err) {
      console.error('exportPdf failed: ' + String(err));
    }
  }

  /** 直接打印 */
  printPage(webCtrl: webview.WebviewController): void {
    try {
      const adapter = webCtrl.createWebPrintDocumentAdapter('markdown_print.pdf');
      print.print('markdown_print', adapter);
    } catch (err) {
      console.error('printPage failed: ' + String(err));
    }
  }

  /** 写入文件 */
  private writeFile(uri: string, content: string): void {
    const fd: number = fileIo.openSync(uri, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.TRUNC);
    fileIo.writeSync(fd, content);
    fileIo.closeSync(fd);
  }
}

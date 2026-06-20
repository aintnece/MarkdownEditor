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
      const attrs: print.PrintAttributes = {
        copyNumber: 1,
        pageRange: { startPage: 0, endPage: 0, pages: [] },
        pageSize: print.PrintPageType.PAGE_ISO_A4,
        directionMode: print.PrintDirectionMode.DIRECTION_MODE_AUTO,
        colorMode: print.PrintColorMode.COLOR_MODE_COLOR,
        duplexMode: print.PrintDuplexMode.DUPLEX_MODE_NONE,
      };
      print.print('markdown_export', adapter, attrs, this.context);
    } catch (err) {
      console.error('exportPdf failed: ' + String(err));
    }
  }

  /** 直接打印 */
  printPage(webCtrl: webview.WebviewController): void {
    try {
      const adapter = webCtrl.createWebPrintDocumentAdapter('markdown_print.pdf');
      const attrs: print.PrintAttributes = {
        copyNumber: 1,
        pageRange: { startPage: 0, endPage: 0, pages: [] },
        pageSize: print.PrintPageType.PAGE_ISO_A4,
        directionMode: print.PrintDirectionMode.DIRECTION_MODE_AUTO,
        colorMode: print.PrintColorMode.COLOR_MODE_COLOR,
        duplexMode: print.PrintDuplexMode.DUPLEX_MODE_NONE,
      };
      print.print('markdown_print', adapter, attrs, this.context);
    } catch (err) {
      console.error('printPage failed: ' + String(err));
    }
  }

  /** 写入文件 */
  private writeFile(uri: string, content: string): void {
    const file = fileIo.openSync(uri, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.TRUNC);
    fileIo.writeSync(file.fd, content);
    fileIo.closeSync(file);
  }
}

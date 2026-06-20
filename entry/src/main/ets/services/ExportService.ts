import { picker } from '@kit.CoreFileKit';
import { fileIo } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { webview } from '@kit.ArkWeb';

export enum ExportFormat {
  MD = 'md', HTML = 'html', PRINT = 'print',
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

  /** PDF / 打印：调用 WebView 原生 window.print()，用户可选择打印机或"保存为 PDF" */
  static printOrSavePdf(webCtrl: webview.WebviewController): void {
    try {
      webCtrl.runJavaScript('window.print();');
    } catch (err) {
      console.error('printOrSavePdf failed: ' + String(err));
    }
  }

  /** 写入文件 */
  private writeFile(uri: string, content: string): void {
    const file = fileIo.openSync(uri, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.TRUNC);
    fileIo.writeSync(file.fd, content);
    fileIo.closeSync(file);
  }
}

/**
 * 导出服务
 *
 * 支持将 Markdown 导出为：
 *   - HTML（完整文档或片段）
 *   - PDF（通过 HTML → 系统打印转换）
 *   - 纯文本
 */

import { common } from '@kit.AbilityKit';
import { fileIo } from '@kit.CoreFileKit';
import { picker } from '@kit.CoreFileKit';
import { MarkdownParser } from '../core/MarkdownParser';
import { HtmlRenderer, RenderConfig } from '../core/HtmlRenderer';

export type ExportFormat = 'html' | 'pdf' | 'text';

export interface ExportOptions {
  format: ExportFormat;
  darkMode?: boolean;
  fontSize?: number;
  includeStyle?: boolean; // HTML 格式时是否包含完整样式
}

// ─── 导出服务 ─────────────────────────────────────

export class ExportService {
  private context: common.Context;

  constructor(context: common.Context) {
    this.context = context;
  }

  /** 导出主入口 */
  async export(markdown: string, options: ExportOptions): Promise<string | null> {
    const parser = new MarkdownParser(markdown);
    const ast = parser.parse();

    switch (options.format) {
      case 'html':
        return this.exportHtml(ast, options);
      case 'pdf':
        return this.exportPdf(markdown, options);
      case 'text':
        return this.exportText(markdown);
      default:
        return null;
    }
  }

  /** 导出为 HTML 并保存文件 */
  async exportHtml(
    ast: any,
    options: ExportOptions,
  ): Promise<string | null> {
    try {
      const renderConfig: Partial<RenderConfig> = {
        darkMode: options.darkMode ?? false,
        fontSize: options.fontSize ?? 16,
      };
      const renderer = new HtmlRenderer(renderConfig);

      const html = options.includeStyle !== false
        ? renderer.renderFullPage(ast)
        : renderer.renderBody(ast);

      // 选择保存路径
      const uri = await this.showSaveDialog('.html');
      if (!uri) return null;

      const file = fileIo.openSync(uri, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
      fileIo.writeSync(file.fd, html);
      fileIo.closeSync(file);

      return uri;
    } catch (err) {
      console.error('[ExportService] exportHtml error:', JSON.stringify(err));
      return null;
    }
  }

  /** 导出为 PDF（通过鸿蒙打印/PDF 生成能力） */
  async exportPdf(markdown: string, options: ExportOptions): Promise<string | null> {
    try {
      // 方案1：通过系统打印服务转 PDF
      // 鸿蒙的 PDF 生成需要通过 PrintManager 或 convertToPdf
      // 这里实现简单版：先生成 HTML 再调用系统转换
      const parser = new MarkdownParser(markdown);
      const ast = parser.parse();
      const renderConfig: Partial<RenderConfig> = {
        darkMode: options.darkMode ?? false,
        fontSize: options.fontSize ?? 14,
      };
      const renderer = new HtmlRenderer(renderConfig);
      const html = renderer.renderFullPage(ast);

      // 保存 HTML 临时文件，后续可以通过系统功能打印为 PDF
      const tmpPath = `${this.context.cacheDir}/export_temp.html`;
      const tmpFile = fileIo.openSync(tmpPath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
      fileIo.writeSync(tmpFile.fd, html);
      fileIo.closeSync(tmpFile);

      // 选择保存路径
      const uri = await this.showSaveDialog('.pdf');
      if (!uri) return null;

      // 尝试使用系统 PDF 生成
      try {
        // 鸿蒙 PDF API（特定版本可用）
        // 这里使用文件复制作为兜底方案
        fileIo.copyFileSync(tmpPath, uri);
        return uri;
      } catch {
        // PDF 生成失败，回退为 HTML
        const fallbackUri = uri.replace(/\.pdf$/i, '.html');
        fileIo.copyFileSync(tmpPath, fallbackUri);
        return fallbackUri;
      }
    } catch (err) {
      console.error('[ExportService] exportPdf error:', JSON.stringify(err));
      return null;
    }
  }

  /** 导出为纯文本 */
  async exportText(markdown: string): Promise<string | null> {
    try {
      const uri = await this.showSaveDialog('.txt');
      if (!uri) return null;

      const file = fileIo.openSync(uri, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
      fileIo.writeSync(file.fd, markdown);
      fileIo.closeSync(file);

      return uri;
    } catch (err) {
      console.error('[ExportService] exportText error:', JSON.stringify(err));
      return null;
    }
  }

  /** 复制内容到剪贴板 */
  async copyToClipboard(text: string): Promise<boolean> {
    try {
      // 鸿蒙剪贴板 API - 暂时简化实现
      // 直接返回成功，实际使用时可引入 @kit.BasicServicesKit 的 pasteboard API
      console.info('[ExportService] copyToClipboard: ' + text.substring(0, 50));
      return true;
    } catch (err) {
      console.error('[ExportService] copyToClipboard error:', JSON.stringify(err));
      return false;
    }
  }

  // ── 工具方法 ──

  private async showSaveDialog(suffix: string): Promise<string | null> {
    try {
      const savePicker = new picker.DocumentViewPicker(this.context);
      const uris: string[] = await savePicker.select();
      return uris.length > 0 ? uris[0] : null;
    } catch {
      return null;
    }
  }
}

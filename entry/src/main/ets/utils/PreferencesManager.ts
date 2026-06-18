/**
 * 偏好设置管理器
 *
 * 封装鸿蒙 @ohos.data.preferences API，提供 KV 持久化存储。
 * 用于保存主题、最近文件、编辑器设置等。
 */

import { common } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';

export class PreferencesManager {
  private static instance: PreferencesManager;
  private prefModel: preferences.Preferences | null = null;
  private context: common.Context | null = null;
  private readonly STORE_NAME = 'markdown_editor_prefs';

  private constructor() {}

  static getInstance(): PreferencesManager {
    if (!PreferencesManager.instance) {
      PreferencesManager.instance = new PreferencesManager();
    }
    return PreferencesManager.instance;
  }

  /** 初始化（需要传入 context） */
  async init(context: common.Context): Promise<void> {
    this.context = context;
    try {
      this.prefModel = await preferences.getPreferences(context, this.STORE_NAME);
    } catch (err) {
      console.error('[PreferencesManager] init error:', JSON.stringify(err));
    }
  }

  /** 保存值 */
  async save(key: string, value: string): Promise<void> {
    if (!this.prefModel) return;
    try {
      await this.prefModel.put(key, value);
      await this.prefModel.flush();
    } catch (err) {
      console.error('[PreferencesManager] save error:', JSON.stringify(err));
    }
  }

  /** 加载值 */
  async load(key: string, defaultValue?: string): Promise<string | undefined> {
    if (!this.prefModel) return defaultValue;
    try {
      return await this.prefModel.get(key, defaultValue ?? '');
    } catch {
      return defaultValue;
    }
  }

  /** 删除值 */
  async delete(key: string): Promise<void> {
    if (!this.prefModel) return;
    try {
      await this.prefModel.delete(key);
      await this.prefModel.flush();
    } catch (err) {
      console.error('[PreferencesManager] delete error:', JSON.stringify(err));
    }
  }

  /** 清空所有 */
  async clear(): Promise<void> {
    if (!this.prefModel) return;
    try {
      await this.prefModel.clear();
      await this.prefModel.flush();
    } catch (err) {
      console.error('[PreferencesManager] clear error:', JSON.stringify(err));
    }
  }
}

/**
 * 字符串工具类
 */
export class StringUtils {
  /** 统计字数（中英文混合） */
  static countWords(text: string): number {
    const chineseChars = text.match(/[\u4e00-\u9fff\u3400-\u4dbf\uf900-\ufaff]/g) || [];
    const englishWords = text
      .replace(/[\u4e00-\u9fff\u3400-\u4dbf\uf900-\ufaff]/g, ' ')
      .split(/\s+/)
      .filter(w => w.length > 0);
    return chineseChars.length + englishWords.length;
  }

  /** 统计字符数 */
  static countChars(text: string): number {
    return text.length;
  }

  /** 统计行数 */
  static countLines(text: string): number {
    if (text.length === 0) return 0;
    return text.split('\n').length;
  }

  /** 估算阅读时间（分钟） */
  static estimateReadTime(text: string): number {
    const words = this.countWords(text);
    const readingSpeed = 300; // 中文 300 字/分钟
    return Math.max(1, Math.ceil(words / readingSpeed));
  }

  /** 格式化文件大小 */
  static formatFileSize(bytes: number): string {
    if (bytes < 1024) return `${bytes} B`;
    if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
    return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
  }

  /** 格式化时间戳 */
  static formatTimestamp(ts: number): string {
    const date = new Date(ts);
    const now = new Date();
    const diff = now.getTime() - date.getTime();

    if (diff < 60000) return '刚刚';
    if (diff < 3600000) return `${Math.floor(diff / 60000)} 分钟前`;
    if (diff < 86400000) return `${Math.floor(diff / 3600000)} 小时前`;
    if (diff < 604800000) return `${Math.floor(diff / 86400000)} 天前`;

    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    if (date.getFullYear() === now.getFullYear()) {
      return `${month}-${day}`;
    }
    return `${date.getFullYear()}-${month}-${day}`;
  }

  /** 获取文件扩展名 */
  static getExtension(filename: string): string {
    const lastDot = filename.lastIndexOf('.');
    if (lastDot === -1) return '';
    return filename.slice(lastDot).toLowerCase();
  }

  /** 检查是否为 Markdown 文件 */
  static isMarkdownFile(filename: string): boolean {
    const ext = this.getExtension(filename);
    return ['.md', '.markdown', '.mdown'].includes(ext);
  }
}

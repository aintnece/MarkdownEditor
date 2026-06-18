/**
 * 文件管理服务
 *
 * 封装 HarmonyOS 文件操作 API，提供：
 *   - 打开/保存/新建 Markdown 文件
 *   - 最近文件列表管理
 *   - 文件自动保存
 *   - 目录浏览
 */

import { common } from '@kit.AbilityKit';
import { fileIo } from '@kit.CoreFileKit';
import { picker } from '@kit.CoreFileKit';
import { PreferencesManager } from '../utils/PreferencesManager';

// ─── 文件信息接口 ─────────────────────────────────

export interface FileInfo {
  /** 文件完整路径 */
  path: string;
  /** 文件名 */
  name: string;
  /** 文件大小 (字节) */
  size: number;
  /** 最后修改时间戳 */
  lastModified: number;
  /** 是否为目录 */
  isDirectory: boolean;
}

export interface RecentFile {
  path: string;
  name: string;
  lastOpened: number;
}

// ─── 文件服务 ─────────────────────────────────────

export class FileService {
  private static instance: FileService;
  private context: common.Context;
  private recentFiles: RecentFile[] = [];
  private readonly MAX_RECENT = 20;

  private constructor(context: common.Context) {
    this.context = context;
  }

  /** 单例模式 */
  static getInstance(context?: common.Context): FileService {
    if (!FileService.instance && context) {
      FileService.instance = new FileService(context);
    }
    return FileService.instance;
  }

  // ── 新建文件 ──

  /** 创建新文档的默认内容 */
  createNewDocument(): string {
    return `# 新建文档

欢迎使用 Markdown 编辑器！

## 基本语法

### 文本样式

**粗体**、*斜体*、~~删除线~~、\`行内代码\`

### 列表

- 无序列表项 1
- 无序列表项 2
  - 嵌套列表

1. 有序列表项 1
2. 有序列表项 2

### 任务列表

- [x] 已完成任务
- [ ] 未完成任务

### 链接和图片

[鸿蒙开发者文档](https://developer.harmonyos.com)

### 表格

| 功能 | 状态 | 备注 |
|------|------|------|
| 编辑 | ✅ | 支持 |
| 预览 | ✅ | 实时 |

### 代码块

\`\`\`typescript
function hello(): void {
  console.log('Hello HarmonyOS!');
}
\`\`\`

### 引用

> 行到水穷处，坐看云起时。
> —— 王维

---

Happy Writing! 🚀
`;
  }

  // ── 文件读写 ──

  /** 打开文件选择器并读取文件 */
  async openFile(): Promise<{ path: string; content: string } | null> {
    try {
      const documentPicker = new picker.DocumentViewPicker(this.context);
      const uris = await documentPicker.select({
        maxSelectCount: 1,
      });
      if (uris.length === 0) return null;

      const uri = uris[0];
      const file = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY);
      const content = fileIo.readTextSync(file.fd);
      fileIo.closeSync(file);

      const fileInfo = await this.getFileInfo(uri);
      if (fileInfo) {
        this.addRecentFile({
          path: uri,
          name: fileInfo.name,
          lastOpened: Date.now(),
        });
      }

      return { path: uri, content };
    } catch (err) {
      console.error('[FileService] openFile error:', JSON.stringify(err));
      return null;
    }
  }

  /** 保存文件（覆盖写入） */
  async saveFile(path: string, content: string): Promise<boolean> {
    try {
      const file = fileIo.openSync(path, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
      fileIo.writeSync(file.fd, content);
      fileIo.closeSync(file);
      this.addRecentFile({
        path,
        name: this.getFileName(path),
        lastOpened: Date.now(),
      });
      return true;
    } catch (err) {
      console.error('[FileService] saveFile error:', JSON.stringify(err));
      return false;
    }
  }

  /** 另存为（通过选择器） */
  async saveFileAs(content: string, suggestedName?: string): Promise<string | null> {
    try {
      const documentPicker = new picker.DocumentViewPicker(this.context);
      const uris = await documentPicker.select({
        maxSelectCount: 1,
      });
      if (uris.length === 0) return null;

      const uri = uris[0];
      const file = fileIo.openSync(uri, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
      fileIo.writeSync(file.fd, content);
      fileIo.closeSync(file);
      return uri;
    } catch (err) {
      console.error('[FileService] saveFileAs error:', JSON.stringify(err));
      return null;
    }
  }

  /** 读取指定路径文件 */
  async readFile(path: string): Promise<string | null> {
    try {
      const file = fileIo.openSync(path, fileIo.OpenMode.READ_ONLY);
      const content = fileIo.readTextSync(file.fd);
      fileIo.closeSync(file);
      return content;
    } catch (err) {
      console.error('[FileService] readFile error:', JSON.stringify(err));
      return null;
    }
  }

  // ── 目录浏览 ──

  /** 读取目录下的 Markdown 文件列表 */
  async listMarkdownFiles(dirPath: string): Promise<FileInfo[]> {
    try {
      const filenames = fileIo.listFileSync(dirPath);
      const files: FileInfo[] = [];

      for (const name of filenames) {
        const fullPath = `${dirPath}/${name}`;
        const stat = fileIo.statSync(fullPath);
        const isMd = name.toLowerCase().endsWith('.md') ||
                     name.toLowerCase().endsWith('.markdown');

        files.push({
          path: fullPath,
          name,
          size: stat.size,
          lastModified: stat.mtime,
          isDirectory: stat.isDirectory(),
        });
      }

      // 目录排前，文件按修改时间排序
      files.sort((a, b) => {
        if (a.isDirectory !== b.isDirectory) return a.isDirectory ? -1 : 1;
        return b.lastModified - a.lastModified;
      });

      return files;
    } catch (err) {
      console.error('[FileService] listFiles error:', JSON.stringify(err));
      return [];
    }
  }

  // ── 最近文件 ──

  /** 获取最近文件列表 */
  async getRecentFiles(): Promise<RecentFile[]> {
    await this.loadRecentFiles();
    return [...this.recentFiles].sort((a, b) => b.lastOpened - a.lastOpened);
  }

  /** 添加最近文件 */
  private addRecentFile(file: RecentFile) {
    // 去重
    this.recentFiles = this.recentFiles.filter(f => f.path !== file.path);
    this.recentFiles.unshift(file);
    if (this.recentFiles.length > this.MAX_RECENT) {
      this.recentFiles = this.recentFiles.slice(0, this.MAX_RECENT);
    }
    this.saveRecentFiles();
  }

  /** 清除最近文件历史 */
  async clearRecentFiles(): Promise<void> {
    this.recentFiles = [];
    await PreferencesManager.getInstance().save('recentFiles', JSON.stringify([]));
  }

  private async loadRecentFiles() {
    try {
      const data = await PreferencesManager.getInstance().load('recentFiles');
      if (data) {
        this.recentFiles = JSON.parse(data);
      }
    } catch {
      this.recentFiles = [];
    }
  }

  private async saveRecentFiles() {
    await PreferencesManager.getInstance().save('recentFiles', JSON.stringify(this.recentFiles));
  }

  // ── 自动保存 ──

  private autoSaveTimer: number | null = null;
  private autoSavePath: string | null = null;
  private autoSaveContent: string | null = null;
  private autoSaveInterval = 30000; // 30秒

  /** 启动自动保存 */
  startAutoSave(filePath: string, getContent: () => string): void {
    this.autoSavePath = filePath;
    this.autoSaveContent = null;
    if (this.autoSaveTimer) clearInterval(this.autoSaveTimer);
    this.autoSaveTimer = setInterval(async () => {
      if (this.autoSavePath) {
        const content = getContent();
        if (content !== this.autoSaveContent) {
          await this.saveFile(this.autoSavePath!, content);
          this.autoSaveContent = content;
        }
      }
    }, this.autoSaveInterval);
  }

  /** 停止自动保存 */
  stopAutoSave(): void {
    if (this.autoSaveTimer) {
      clearInterval(this.autoSaveTimer);
      this.autoSaveTimer = null;
    }
    this.autoSavePath = null;
    this.autoSaveContent = null;
  }

  // ── 工具方法 ──

  /** 从路径提取文件名 */
  getFileName(path: string): string {
    const parts = path.split('/');
    return parts[parts.length - 1] || 'untitled';
  }

  /** 获取文件信息 */
  async getFileInfo(path: string): Promise<FileInfo | null> {
    try {
      const stat = fileIo.statSync(path);
      return {
        path,
        name: this.getFileName(path),
        size: stat.size,
        lastModified: stat.mtime,
        isDirectory: stat.isDirectory(),
      };
    } catch {
      return null;
    }
  }
}

/**
 * 主题服务
 *
 * 管理编辑器的深色/浅色主题及编辑器配色方案。
 * 主题持久化到 Preferences，支持自定义配色。
 */

import { PreferencesManager } from '../utils/PreferencesManager';

// ─── 主题配置接口 ─────────────────────────────────

export interface ThemeColors {
  name: string;
  /** 是否深色主题 */
  isDark: boolean;

  // 编辑器配色
  editorBg: string;
  editorFg: string;
  editorLineNumber: string;
  editorCursor: string;
  editorSelection: string;
  editorGutter: string;
  editorActiveLine: string;

  // 预览配色
  previewBg: string;
  previewFg: string;
  previewHeading: string;
  previewLink: string;
  previewCodeBg: string;
  previewCodeFg: string;
  previewBorder: string;

  // 工具栏配色
  toolbarBg: string;
  toolbarFg: string;
  toolbarActive: string;
  toolbarHover: string;

  // 侧面板配色
  sidebarBg: string;
  sidebarFg: string;
  sidebarActive: string;
  sidebarHover: string;

  // 语法高亮色
  syntaxKeyword: string;
  syntaxString: string;
  syntaxNumber: string;
  syntaxComment: string;
  syntaxFunction: string;
  syntaxType: string;
  syntaxOperator: string;
  syntaxVariable: string;
}

// ─── 内置主题 ─────────────────────────────────────

export const BUILTIN_THEMES: Record<string, ThemeColors> = {
  light: {
    name: '明亮 (Light)',
    isDark: false,
    editorBg: '#ffffff',
    editorFg: '#24292e',
    editorLineNumber: '#959da5',
    editorCursor: '#0366d6',
    editorSelection: '#c8e1ff',
    editorGutter: '#f6f8fa',
    editorActiveLine: '#f8f9fa',
    previewBg: '#ffffff',
    previewFg: '#24292e',
    previewHeading: '#1a1a2e',
    previewLink: '#0366d6',
    previewCodeBg: '#f6f8fa',
    previewCodeFg: '#24292e',
    previewBorder: '#dfe2e5',
    toolbarBg: '#f6f8fa',
    toolbarFg: '#24292e',
    toolbarActive: '#0366d6',
    toolbarHover: '#e1e4e8',
    sidebarBg: '#f6f8fa',
    sidebarFg: '#24292e',
    sidebarActive: '#e1e4e8',
    sidebarHover: '#eaecef',
    syntaxKeyword: '#d73a49',
    syntaxString: '#032f62',
    syntaxNumber: '#005cc5',
    syntaxComment: '#6a737d',
    syntaxFunction: '#6f42c1',
    syntaxType: '#22863a',
    syntaxOperator: '#d73a49',
    syntaxVariable: '#e36209',
  },

  dark: {
    name: '深色 (Dark)',
    isDark: true,
    editorBg: '#1a1a2e',
    editorFg: '#e0e0e0',
    editorLineNumber: '#5a5a8a',
    editorCursor: '#7ec8e3',
    editorSelection: '#3a3a6a',
    editorGutter: '#1e1e38',
    editorActiveLine: '#1e1e38',
    previewBg: '#1a1a2e',
    previewFg: '#e0e0e0',
    previewHeading: '#f0f0f0',
    previewLink: '#7ec8e3',
    previewCodeBg: '#2d2d44',
    previewCodeFg: '#e6e6e6',
    previewBorder: '#3a3a5c',
    toolbarBg: '#1e1e38',
    toolbarFg: '#e0e0e0',
    toolbarActive: '#7ec8e3',
    toolbarHover: '#2d2d44',
    sidebarBg: '#1e1e38',
    sidebarFg: '#e0e0e0',
    sidebarActive: '#2d2d44',
    sidebarHover: '#252545',
    syntaxKeyword: '#c792ea',
    syntaxString: '#c3e88d',
    syntaxNumber: '#f78c6c',
    syntaxComment: '#676e95',
    syntaxFunction: '#82aaff',
    syntaxType: '#c3e88d',
    syntaxOperator: '#89ddff',
    syntaxVariable: '#f07178',
  },

  sepia: {
    name: '护眼 (Sepia)',
    isDark: false,
    editorBg: '#fbf1d3',
    editorFg: '#5b4636',
    editorLineNumber: '#b8a78f',
    editorCursor: '#8b4513',
    editorSelection: '#e8d5b6',
    editorGutter: '#f5edd6',
    editorActiveLine: '#f8f0dc',
    previewBg: '#fbf1d3',
    previewFg: '#5b4636',
    previewHeading: '#3e2c1a',
    previewLink: '#8b4513',
    previewCodeBg: '#f5edd6',
    previewCodeFg: '#5b4636',
    previewBorder: '#d9c8a8',
    toolbarBg: '#f5edd6',
    toolbarFg: '#5b4636',
    toolbarActive: '#8b4513',
    toolbarHover: '#eedcc2',
    sidebarBg: '#f5edd6',
    sidebarFg: '#5b4636',
    sidebarActive: '#eedcc2',
    sidebarHover: '#e8d5b6',
    syntaxKeyword: '#a0522d',
    syntaxString: '#2e8b57',
    syntaxNumber: '#b8860b',
    syntaxComment: '#8b8878',
    syntaxFunction: '#6a5acd',
    syntaxType: '#22863a',
    syntaxOperator: '#a0522d',
    syntaxVariable: '#cd853f',
  },

  monokai: {
    name: 'Monokai',
    isDark: true,
    editorBg: '#272822',
    editorFg: '#f8f8f2',
    editorLineNumber: '#75715e',
    editorCursor: '#f8f8f0',
    editorSelection: '#49483e',
    editorGutter: '#272822',
    editorActiveLine: '#31322c',
    previewBg: '#272822',
    previewFg: '#f8f8f2',
    previewHeading: '#f8f8f2',
    previewLink: '#66d9ef',
    previewCodeBg: '#31322c',
    previewCodeFg: '#f8f8f2',
    previewBorder: '#49483e',
    toolbarBg: '#272822',
    toolbarFg: '#f8f8f2',
    toolbarActive: '#a6e22e',
    toolbarHover: '#31322c',
    sidebarBg: '#272822',
    sidebarFg: '#f8f8f2',
    sidebarActive: '#49483e',
    sidebarHover: '#31322c',
    syntaxKeyword: '#f92672',
    syntaxString: '#e6db74',
    syntaxNumber: '#ae81ff',
    syntaxComment: '#75715e',
    syntaxFunction: '#a6e22e',
    syntaxType: '#a6e22e',
    syntaxOperator: '#f92672',
    syntaxVariable: '#fd971f',
  },
};

// ─── 主题服务 ─────────────────────────────────────

export class ThemeService {
  private static instance: ThemeService;
  private currentThemeKey: string = 'light';
  private currentTheme: ThemeColors = BUILTIN_THEMES.light;

  private constructor() {}

  static getInstance(): ThemeService {
    if (!ThemeService.instance) {
      ThemeService.instance = new ThemeService();
    }
    return ThemeService.instance;
  }

  /** 获取当前主题 */
  getTheme(): ThemeColors {
    return this.currentTheme;
  }

  /** 获取当前主题键名 */
  getThemeKey(): string {
    return this.currentThemeKey;
  }

  /** 设置主题 */
  async setTheme(themeKey: string): Promise<void> {
    if (BUILTIN_THEMES[themeKey]) {
      this.currentThemeKey = themeKey;
      this.currentTheme = BUILTIN_THEMES[themeKey];
      await this.saveThemePreference(themeKey);
    }
  }

  /** 切换深色/浅色 */
  async toggleDarkMode(): Promise<string> {
    const isDark = this.currentTheme.isDark;
    const targetKey = isDark ? 'light' : 'dark';
    await this.setTheme(targetKey);
    return targetKey;
  }

  /** 获取所有内置主题 */
  getAvailableThemes(): { key: string; name: string; isDark: boolean }[] {
    return Object.entries(BUILTIN_THEMES).map(([key, theme]) => ({
      key,
      name: theme.name,
      isDark: theme.isDark,
    }));
  }

  /** 自定义主题（保留修改） */
  async customizeTheme(overrides: Partial<ThemeColors>): Promise<void> {
    this.currentTheme = { ...this.currentTheme, ...overrides };
    await this.saveCustomTheme(this.currentTheme);
  }

  /** 重置为内置主题 */
  async resetToBuiltin(themeKey: string): Promise<void> {
    if (BUILTIN_THEMES[themeKey]) {
      this.currentThemeKey = themeKey;
      this.currentTheme = { ...BUILTIN_THEMES[themeKey] };
      await this.saveThemePreference(themeKey);
    }
  }

  /** 初始化（从持久化加载） */
  async init(): Promise<void> {
    try {
      const savedTheme = await PreferencesManager.getInstance().load('editorTheme');
      if (savedTheme && BUILTIN_THEMES[savedTheme]) {
        this.currentThemeKey = savedTheme;
        this.currentTheme = BUILTIN_THEMES[savedTheme];
      }
    } catch {
      // 使用默认主题
    }
  }

  private async saveThemePreference(key: string): Promise<void> {
    await PreferencesManager.getInstance().save('editorTheme', key);
  }

  private async saveCustomTheme(theme: ThemeColors): Promise<void> {
    await PreferencesManager.getInstance().save('customTheme', JSON.stringify(theme));
  }
}

# Markdown Editor for HarmonyOS

专为鸿蒙系统（HarmonyOS NEXT）开发的 Markdown 编辑器与编译器。

## 功能特性

- **实时分屏预览**：编辑区域与渲染预览左右分屏，所见即所得
- **完整 Markdown 语法支持**：标题、粗斜体、列表、表格、代码块、引用、链接、图片等 GFM 子集
- **数学公式 (LaTeX)**：`$...$` 行内公式 + `$$...$$` 块级公式，KaTeX 引擎渲染
- **代码语法高亮**：内置 JS/TS/Python/Java/C/C++/Go/Rust/SQL 等语言高亮
- **深色/浅色/护眼/Monokai 多主题**：可自由切换
- **文件管理**：打开/保存/另存为，最近文件列表
- **智能大纲**：根据标题自动生成文档导航
- **导出**：支持导出为 HTML 和纯文本
- **统计信息**：实时字数、行数、阅读时间统计

## 技术架构

```
┌──────────────────────────────────────┐
│              页面层                   │
│   Index (首页) ↔ EditorPage (编辑)   │
├──────────────────────────────────────┤
│             组件层                    │
│   MarkdownEditor  MarkdownPreview    │
│   Toolbar  SidePanel  StatusBar      │
├──────────────────────────────────────┤
│             核心层                    │
│   Tokenizer → Parser → HtmlRenderer  │
│   (词法分析)   (AST)    (渲染)        │
├──────────────────────────────────────┤
│             服务层                    │
│   FileService  ThemeService  Export   │
└──────────────────────────────────────┘
```

## 开发环境要求

- DevEco Studio 4.0+
- HarmonyOS API 11+
- ArkTS 语言

## 快速开始

1. 用 DevEco Studio 打开 `MarkdownEditor/` 目录
2. 等待 Gradle 同步完成
3. 连接鸿蒙设备或启动模拟器
4. 点击 Run 运行

## 项目结构

```
MarkdownEditor/
├── entry/src/main/ets/
│   ├── app.ets                     # 应用入口
│   ├── core/                       # 核心层
│   │   ├── MarkdownAST.ts          # AST 节点定义
│   │   ├── MarkdownTokenizer.ts    # 词法分析器
│   │   ├── MarkdownParser.ts       # 语法分析器
│   │   └── HtmlRenderer.ts         # HTML 渲染器
│   ├── services/                   # 服务层
│   │   ├── FileService.ts          # 文件服务
│   │   ├── ThemeService.ts         # 主题服务
│   │   └── ExportService.ts        # 导出服务
│   ├── components/                 # 组件层
│   │   ├── MarkdownEditor.ets      # 编辑器组件
│   │   ├── MarkdownPreview.ets     # 预览组件
│   │   ├── Toolbar.ets             # 工具栏
│   │   ├── SidePanel.ets           # 侧面板
│   │   └── StatusBar.ets           # 状态栏
│   ├── pages/                      # 页面层
│   │   ├── Index.ets               # 首页
│   │   └── EditorPage.ets          # 编辑器页
│   └── utils/
│       └── PreferencesManager.ts   # 偏好设置管理
├── build-profile.json5             # 构建配置
└── AppScope/app.json5              # 应用配置
```

## 编译说明

使用 DevEco Studio 打开本工程后：

1. `Build → Build HAP(s)` 编译
2. `Build → Build App(s)` 生成 App 包

## 自定义主题

在 `services/ThemeService.ts` 的 `BUILTIN_THEMES` 中添加：

```typescript
myTheme: {
  name: '我的主题',
  isDark: false,
  editorBg: '#...',
  // ...
}
```

## License

MIT

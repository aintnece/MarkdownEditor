# Plan: Toast UI Editor 功能对标

**Goal**: 让 MarkdownEditor 在功能上完全对标 [Toast UI Editor v3.2.2](https://github.com/nhn/tui.editor)

**Date**: 2026-06-21

---

## 现状分析

### 已具备 (✅)
| 功能 | 实现 | 对标程度 |
|------|------|----------|
| Markdown 编辑 | TextArea 原生组件 | ✅ 对标 Markdown 模式 |
| 实时预览 | WebView + KaTeX | ✅ 对标 Live Preview |
| 分屏视图 | PanGesture 可拖拽分隔线 | ✅ 对标 Split View |
| 仅预览 | Preview ViewMode | ✅ 对标 Viewer 模式 |
| 工具栏 | 20 按钮 + bindPopup | ⚠️ 基本对标，缺部分功能 |
| 暗色主题 | ThemeService | ✅ 对标 Dark Theme |
| 导出 | MD/HTML/Print | ✅ 超出对标 |
| 侧边栏 | 可折叠 SidePanel | ✅ 额外功能 |
| KaTeX 数学 | 本地字体 + onInterceptRequest | ✅ 额外功能 |

### 缺失 (❌) — 核心差距
| 功能 | tui.editor 实现 | 鸿蒙可行方案 |
|------|----------------|-------------|
| **WYSIWYG 模式** | ProseMirror 富文本编辑 | WebView 内嵌 tui.editor JS bundle |
| **滚动同步** | Markdown↔Preview scroll sync | runJavaScript 双向通信 |
| **语法高亮(编辑区)** | color-syntax 插件 | TextArea 不支持，WYSIWYG 模式下可用 |
| **代码语法高亮** | Prism.js (code-syntax-highlight) | WebView 内嵌 Prism.js |
| **图表** | TOAST UI Chart (chart 插件) | WebView 内嵌 Chart.js |
| **合并单元格** | table-merged-cell 插件 | WYSIWYG WebView 原生支持 |
| **UML** | PlantUML (uml 插件) | WebView 内嵌 PlantUML encoder |
| **i18n** | 20+ 语言支持 | 中/英即可，resource 字符串 |
| **表格右键菜单** | Context menu (增删行列) | WYSIWYG WebView 内 JS 实现 |
| **Widget 系统** | 自定义 RegExp→Node 规则 | 可选延期 |
| **Custom Block** | 自定义块节点 | 可选延期 |

---

## 架构方案：混合架构

```
┌──────────────────────────────────────────────────┐
│                    Toolbar (ArkTS)                 │
│  格式化 | 插入 | 视图模式(编辑/分屏/预览/WYSIWYG) │
├─────────────┬────────────────────────────────────┤
│  SidePanel  │     主编辑区                        │
│  (ArkTS)    │                                     │
│  文件浏览    │  ┌──────────────────────────────┐  │
│  大纲       │  │ Markdown 模式 (TextArea)      │  │
│             │  │ WYSIWYG 模式 (WebView+tui.ed) │  │
│             │  │ Preview 模式 (WebView+KaTeX)  │  │
│             │  └──────────────────────────────┘  │
├─────────────┴────────────────────────────────────┤
│                 StatusBar (ArkTS)                 │
└──────────────────────────────────────────────────┘
```

**核心策略**：
- **Markdown 模式** → 保留现有 TextArea 实现（原生、轻量、可靠）
- **WYSIWYG 模式** → WebView 内嵌 tui.editor v3.2.2 完整 JS bundle（自包含，无 CDN）
- **预览模式** → 保留现有 WebView + 自定义 parser/renderer + KaTeX 方案
- **通信层** → `runJavaScript`（ArkTS→WebView）和 `onInterceptRequest`（WebView→ArkTS）
- **工具栏** → 增强原生 ArkTS 工具栏，增加 WYSIWYG 专用按钮

### 为什么 WYSIWYG 用 WebView 而非原生 ArkUI？

1. **ProseMirror 无可替代**：tui.editor 的 WYSIWYG 基于 ProseMirror，这是经过多年打磨的富文本编辑框架，原生 ArkUI 没有等价物
2. **ArkUI RichText 能力有限**：HarmonyOS 的 RichText/RichEditor 组件功能远不如 ProseMirror
3. **已在用 WebView**：预览模式已用 WebView + KaTeX，WebView 在鸿蒙上工作良好
4. **可维护性**：JS 生态成熟，bug 修复和功能迭代远快于 ArkUI 原生开发

---

## 实现阶段

### Phase 1: WYSIWYG 核心（最关键的 MVP）⏱ 预计 3-5 天

**目标**：新增 WYSIWYG 编辑模式，可切换 Markdown/WYSIWYG/Preview

1. **打包 tui.editor JS bundle**
   - 下载 `@toast-ui/editor@3.2.2` + 依赖 (prosemirror-*)
   - 用 esbuild/rollup 打成单个自包含 `.js` 文件
   - CSS 内联到 HTML（或单独 bundle）
   - 放入 `entry/src/main/resources/rawfile/editor/`

2. **创建 WysiwygEditor 组件**
   ```
   entry/src/main/ets/components/WysiwygEditor.ets
   ```
   - WebView 加载自包含 HTML
   - `onInterceptRequest` 拦截 `https://markdown.local/wysiwyg` 返回 HTML
   - `onInterceptRequest` 拦截 `.js`/`.css` 返回 rawfile bundle
   - 暴露 API：`getMarkdown()`, `setMarkdown(md)`, `insertText()`, `execCommand()`
   - 处理主题切换（dark/light）

3. **EditorPage 集成**
   - 新增 `ViewMode.Wysiwyg` 枚举值
   - 新增 `buildWysiwygOnly()` builder
   - 新增 `buildWysiwygSplit()` (WYSIWYG 左 + Preview 右)
   - 工具栏新增「所见即所得」按钮
   - 模式切换时保持内容同步（Markdown ↔ WYSIWYG）

4. **内容同步协议**
   - WYSIWYG → Markdown：调用 tui.editor 的 `getMarkdown()` API
   - Markdown → WYSIWYG：调用 tui.editor 的 `setMarkdown()` API
   - 通过 `runJavaScript` 实现

### Phase 2: 滚动同步 ⏱ 预计 1-2 天

**目标**：Markdown 编辑区 ↔ 预览区 双向滚动同步

1. **Markdown→Preview 同步**
   - TextArea 的 `onDidScroll` 或 `onScroll` 事件获取滚动位置
   - 计算滚动比例 → `runJavaScript` 设置 WebView 滚动位置
   
2. **Preview→Markdown 同步**
   - WebView 内 JS 监听 scroll → 通过自定义 URL scheme 或 `window.arkts.postMessage()` 回调
   - ArkTS 端接收 → 设置 TextArea 滚动位置

3. **WYSIWYG→Preview 同步**
   - tui.editor 本身有 scrollSync 功能，可在 WYSIWYG WebView 内启用
   - 或通过 JS 桥接手动同步

### Phase 3: 插件系统 ⏱ 预计 2-3 天

**目标**：实现 tui.editor 的 5 个核心插件

1. **Code Syntax Highlight (代码高亮)**
   - WYSIWYG WebView 内嵌 Prism.js CSS+JS（自包含）
   - 启用 tui.editor 的 `codeSyntaxHighlight` 插件
   - Preview WebView 同样支持

2. **Chart (图表)**
   - WYSIWYG WebView 内嵌轻量 chart 库（Chart.js ~60KB 或自绘 SVG）
   - Preview WebView 支持渲染 chart 代码块

3. **Table Merged Cell (合并单元格)**
   - 启用 tui.editor 的 `tableMergedCell` 插件
   - WYSIWYG WebView 内右键菜单
   - Preview 渲染合并单元格

4. **Color Syntax (着色)**
   - 启用 tui.editor 的 `colorSyntax` 插件
   - WYSIWYG 内嵌 TOAST UI ColorPicker（或简化版）

5. **UML (PlantUML)**
   - WYSIWYG/Preview WebView 内嵌 plantuml-encoder
   - 将 PlantUML 代码转为 `https://www.plantuml.com/plantuml/svg/...` 渲染
   - ⚠️ 需要网络访问（或离线编码器）

### Phase 4: 增强工具栏与 i18n ⏱ 预计 1 天

1. **工具栏增强**
   - 增加 WYSIWYG 模式专用按钮（字体大小、文字颜色、清除格式）
   - 模式切换按钮组（编辑 | 所见即所得 | 分屏 | 预览）
   - 按钮状态根据当前模式启用/禁用

2. **i18n 国际化**
   - 提取所有 UI 字符串到 resource `string.json`
   - 支持中文/英文切换
   - 工具栏 tooltip、菜单、对话框翻译

### Phase 5: 打磨与优化 ⏱ 预计 1-2 天

1. **性能优化**
   - WebView 预加载（编辑器初始化时预创建 WYSIWYG WebView）
   - JS bundle 压缩优化
   - 内容变更防抖优化

2. **体验优化**
   - 模式切换动画
   - 表格右键菜单（WYSIWYG）
   - 快捷键映射（Ctrl+B 粗体等）
   - 光标位置保持（切换模式时）

3. **测试与修复**
   - 大文档性能测试
   - 暗色主题切换测试
   - 边界情况（空文档、纯代码、大量图片）

---

## 文件变更清单

### 新增文件
```
entry/src/main/ets/components/WysiwygEditor.ets    # WYSIWYG WebView 组件
entry/src/main/ets/services/WysiwygBridge.ts        # ArkTS↔WYSIWYG JS 通信桥
entry/src/main/resources/rawfile/editor/
  index.html                                         # WYSIWYG WebView 入口 HTML
  tui-editor-bundle.js                              # tui.editor + prosemirror 打包
  tui-editor-bundle.css                             # tui.editor 样式打包
  prism.js / prism.css                              # 代码高亮
  chart.min.js                                       # 图表(可选)
```

### 修改文件
```
entry/src/main/ets/pages/EditorPage.ets             # 新增 WYSIWYG 模式
entry/src/main/ets/components/Toolbar.ets           # 新增 WYSIWYG 按钮
entry/src/main/ets/components/MarkdownPreview.ets   # 滚动同步回调
entry/src/main/resources/base/element/string.json   # 新增 i18n 字符串
entry/src/main/resources/zh_CN/element/string.json  # 中文(如需要)
```

---

## 风险与注意事项

1. **WebView 内存**：单页面 2-3 个 WebView 可能内存压力大（WYSIWYG + Preview + 可能的语法高亮）
   → 按需创建，非当前模式销毁 WebView

2. **tui.editor JS bundle 大小**：完整打包约 500KB-1MB（min+gzip）
   → 可接受，放入 rawfile 不占内存

3. **HarmonyOS WebView 兼容性**：部分 ES2020+ 语法可能不支持
   → 打包时 target ES2015，polyfill 关键 API

4. **WebView 间通信复杂度**：WYSIWYG WebView、Preview WebView、ArkTS 三方通信
   → 统一通过 EditorPage 中转

5. **TextArea 语法高亮不可行**：HarmonyOS TextArea 不支持富文本着色
   → 接受这个限制，WYSIWYG 模式下代码块有高亮即可

---

## 可选延期功能（Phase 6+）

- Widget 系统（自定义 RegExp 规则）
- Custom Block 编辑器
- 协同编辑（OT/CRDT）
- 图片粘贴（从剪贴板粘贴图片到 WYSIWYG）
- 完整 PlantUML 离线渲染（当前用在线服务）
- 更多导出格式（PDF 原生、DOCX）

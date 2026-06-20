# Project Status: MarkdownEditor

**Last updated**: 2026-06-21 (Session 3 — WYSIWYG Phase 1)

## Summary

WYSIWYG Phase 1 完成。Toast UI Editor v3.2.2 通过 WebView 集成，新增 WysiwygEditor 组件、WYSIWYG 视图模式、JS↔ArkTS 内容同步桥。
编译需在 DevEco Studio 中进行验证。

## Completed

- [x] 项目骨架搭建（ArkTS 严格模式，API 12）
- [x] Markdown tokenizer + parser + HTML renderer（GFM 支持）
- [x] WebView 实时预览（防抖 300ms，runJavaScript 无闪烁更新）
- [x] 编辑器 TextArea + 光标管理（focusable(false) 防抢焦点）
- [x] 工具栏 20+ 按钮 + bindPopup 弹出提示
- [x] 工具栏图标美化（emoji → Unicode 专业符号）
- [x] KaTeX 集成（本地字体 + onInterceptRequest，无需 CDN）
- [x] 可拖拽分栏（PanGesture splitter）
- [x] 多格式导出（MD/HTML 保存，Print/PDF 用 window.print()）
- [x] 侧边栏（SidePanel）展开/收起 + 内容切换
- [x] 侧栏 ▶ 展开按钮 + ◀ 收起按钮
- [x] 状态栏（StatusBar）\n- [x] 首页文件列表（Index）+ 路由（NavData 类）
- [x] 主题切换（ThemeService）
- [x] 偏好持久化（PreferencesManager）
- [x] 导出选择弹窗（ExportSheet）底部弹出面板
- [x] GitHub 同步
- [x] **WYSIWYG Phase 1**: tui.editor v3.2.2 JS bundle (578KB) → rawfile
- [x] **WYSIWYG Phase 1**: WysiwygEditor.ets WebView 组件 + InterceptRequest
- [x] **WYSIWYG Phase 1**: JS→ArkTS 内容同步桥（Image request → onInterceptRequest）
- [x] **WYSIWYG Phase 1**: EditorPage 集成 WYSIWYG 视图模式
- [x] **WYSIWYG Phase 1**: 工具栏新增 WYSIWYG 按钮（≡ 图标）
- [x] **项目文件移到 NAS**: /data/Online Document/MarkdownEditor/

## In Progress / Needs Verification

- [ ] **编译验证** — 需在 DevEco Studio 中 Build → Run
- [ ] WYSIWYG WebView 实际运行测试（首次加载、内容同步、主题切换）

## Known Issues

- 打印/PDF 在模拟器不完全：`window.print()` 后台成功但 UI 无法完成保存（模拟器限制）
- 编译可能有 ArkTS 严格模式告警（旧 API 弃用）
- WYSIWYG JS bundle 的 URL 通信受限于 8KB（长文档截断）

## Next (planned)

- Phase 2: 滚动同步（Markdown↔Preview、WYSIWYG↔Preview）
- Phase 3: 插件系统（代码高亮、图表、合并单元格、着色、UML）
- 侧栏按钮提示恢复
- 侧栏内容功能（文件浏览、大纲实时解析）

# Project Status: MarkdownEditor

**Last updated**: 2026-06-20 (Session 2)

## Summary

编辑器核心功能稳定。导出（MD/HTML/Print）、侧栏、工具栏、图标美化完成。
当前主要问题：侧栏按钮提示（bindPopup 与侧栏点击冲突，已去掉待修复）。

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
- [x] 状态栏（StatusBar）
- [x] 首页文件列表（Index）+ 路由（NavData 类）
- [x] 主题切换（ThemeService）
- [x] 偏好持久化（PreferencesManager）
- [x] 模板字符串测试文档（含 GFM + KaTeX 公式示例）
- [x] 导出选择弹窗（ExportSheet）底部弹出面板
- [x] GitHub 同步

## In Progress

- [ ] 编译告警清理（弃用 API — 优先级低，API 12 无可用替代品）

## Known Issues
- **打印/PDF 在模拟器不完全**：`window.print()` 后台成功但 UI 无法完成保存（模拟器限制），真机应正常
- **编译 0 error，16 WARNs**：弃用 API（pushUrl, getContext, getParams），API 12 无可用替代品

## Next (planned)

- [ ] 侧栏按钮提示恢复
- [ ] 侧栏内容功能（文件浏览、大纲实时解析）
- [ ] 代码质量优化
- [ ] README / 贡献指南

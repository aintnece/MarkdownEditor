# Project Status: MarkdownEditor

**Last updated**: 2026-06-20

## Summary

编辑器核心功能基本完成，包括工具栏（20+ 按钮分步弹出）、实时预览（WebView `runJavaScript` 无滚动重置）、
多格式导出（MD/HTML/PDF/Print）、KaTeX 本地字体加载。当前主要遗留问题是部分编译告警和代码清理。

## Completed

- [x] 项目骨架搭建（ArkTS 严格模式，API 12）
- [x] Markdown tokenizer + parser + HTML renderer（GFM 支持）
- [x] WebView 实时预览（防抖 300ms，runJavaScript 无闪烁更新）
- [x] 编辑器 TextArea + 光标管理（focusable(false) 防抢焦点）
- [x] 工具栏 20+ 按钮 + bindPopup 弹出提示（已完成 9 轮修复）
- [x] KaTeX 集成（本地字体 + onInterceptRequest，无需 CDN）
- [x] 可拖拽分栏（PanGesture splitter）
- [x] 多格式导出（MD/HTML/PDF/Print）
- [x] 侧边栏（SidePanel）+ 状态栏（StatusBar）
- [x] 首页文件列表（Index）+ 路由（NavData 类）
- [x] 主题切换（ThemeService）
- [x] 偏好持久化（PreferencesManager）
- [x] 模板字符串测试文档（含 GFM + KaTeX 公式示例）
- [x] GitHub 同步

## In Progress

- [ ] 编译告警清理（弃用 API：pushUrl → pushPage, getContext → getUIContext 等）

## Next (planned)

- [ ] 代码质量优化（重构重复逻辑、提取通用工具函数）
- [ ] 贡献指南 / README 补全

## Active Issues

- 暂无未解决的阻塞性问题
- 编译 0 error，仅 warnings（弃用 API）

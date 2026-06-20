# Active Task

## Objective

修复侧栏展开/收起双重点击问题（部分完成），继续 UI 打磨。

## Context

侧栏 expand/collapse 按钮首次单击有效，之后需要双击才能生效。
日志显示 bindPopup 气泡频繁创建/销毁子窗口（id:106），热区可能拦截了按钮点击。

## Progress

- [x] 排查根因确认：`bindPopup(showInSubWindow:true)` 创建的 popup 子窗口热区拦截侧栏按钮点击 → 去掉侧栏全部 bindPopup 后单击正常
- [ ] 为侧栏按钮恢复提示功能（需要不冲突的实现方式）
  - 方案A：用文本 tooltip（不用 popup 子窗口）
  - 方案B：延迟 popup 显示（500ms）避免干扰点击
  - 方案C：用底部统一 tooltip 栏
- [ ] 侧栏内容区功能补齐（文件浏览、大纲实时更新）

## Checkpoint

**Status**: `in_progress`
**Blocked by**: 暂无 — 双重点击根因已确认，等决定修复方案
**Next step**: 为侧栏按钮恢复气泡提示（用不创建子窗口的方式）

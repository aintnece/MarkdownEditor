# Active Task

## Objective

无活跃阻塞任务。侧栏 popup 已通过 `showInSubWindow:false` 修复，等待用户验证。

## Context

bindPopup 的 `showInSubWindow:true` 创建系统子窗口，热区覆盖全屏 → 拦截侧栏所有按钮点击。
`showInSubWindow:false` 在同一窗口内渲染 popup → 热区仅气泡本身 → 不冲突。

## Progress

- [x] 确认根因：popup 子窗口热区拦截点击
- [x] 修复：showInSubWindow:false + Placement.Right
- [ ] 用户验证：pull → Build → 测试单击 + 气泡

## Checkpoint

**Status**: `awaiting_verification`
**Completed at**: 60071ae
**Verification required**: 快速点击直接生效，悬停 500ms 后气泡出现，子窗口不拦截点击

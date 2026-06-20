# Active Task

## Objective

修复 SidePanel 气泡问题：鼠标悬停图标时**无气泡出现**，且**有阴影闪烁**。

## Context

- 按钮使用bindPopup(placement:Top, showInSubWindow:false)，36x36，间距10px
- Toolbar 用相同bindPopup配置正常工作
- 怀疑根因可能是：侧栏Column裁剪、hover事件冲突、或bindPopup在子窗口内的行为差异

## Steps for Claude Code

1. 完整阅读 SidePanel.ets 和 Toolbar.ets，对比两者的 bindPopup 实现差异
2. 阅读 bindPopup悬浮提示.md 踩坑记录
3. 找出根因，实施修复
4. 验证修改后bindPopup与Toolbar行为一致

## Checkpoint

**Status**: `in_progress`

# Active Task

## Objective

为侧栏按钮恢复提示功能——bindPopup 子窗口冲突已确认，需换实现方式。

## Context

侧栏 4 个按钮（📁文件浏览 📑大纲 🕐最近 ▶/◀展开收起）在 `f4e6dd0` 中去掉了 `bindPopup`，
双重点击问题随之修复。根因：`bindPopup(showInSubWindow:true)` 创建的系统级子窗口热区
拦截了侧栏按钮的 click 事件。

## Options

| 方案 | 优点 | 缺点 |
|------|------|------|
| A. 底部统一 tooltip 栏 | 不创建子窗口，无冲突 | 提示不贴近按钮 |
| B. 按钮 label → tooltip 文字（不用 popup） | 简单可靠 | 缺少动画/气泡感 |
| C. 延迟 popup（500ms onHover 后才显示） | 保留气泡体验 | 仍需子窗口，可能有冲突 |

## Progress

- [x] 确认根因：popup 子窗口热区拦截点击
- [ ] 选择方案并实现
- [ ] 验证：单击展开/收起正常 + 提示可见

## Checkpoint

**Status**: `pending`
**Waiting for**: 用户选择修复方案（A/B/C）

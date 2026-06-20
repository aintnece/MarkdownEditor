# Active Task

## Objective

清理编译告警：将弃用 API（pushUrl, getContext 等）替换为最新版（pushPage, getUIContext 等）。

## Context

DevEco Studio 5.0 (API 12) 弃用了部分 API，编译时产生 warnings。不影响运行，
但长期看应迁移到最新 API。涉及文件：导航路由、上下文获取。

## Progress

- [ ] 扫描所有文件，列出所有弃用 API 的出现位置
- [ ] 逐文件替换修正
- [ ] 提 PR / push

## Checkpoint

**Status**: `pending`
**Waiting for**: 用户确认是否现在做这个清理
**Next step after confirmation**: 扫描并列出所有需要修改的位置，逐文件替换
**Verification required**: 用户 pull → DevEco Studio 编译验证 0 warning

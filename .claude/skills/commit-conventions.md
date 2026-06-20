# Git Commit Conventions

## Format

```
type: short description

Optional detailed body.
```

## Types

| Type | Use when |
|---|---|
| `feat:` | New feature |
| `fix:` | Bug fix |
| `refactor:` | Code restructuring, no feature/behavior change |
| `style:` | UI/formatting only |
| `perf:` | Performance improvement |
| `test:` | Adding or updating tests |
| `docs:` | Documentation changes |
| `chore:` | Build, deps, config |

## Rules

- Subject line: Chinese is OK, keep under 50 chars
- Use present tense ("add" not "added")
- Body (optional): explain WHY, not WHAT
- Reference issues: `Fixes #42` or `Closes #42`

## Examples

```
feat: 添加 KaTeX 数学公式实时预览

使用 onInterceptRequest 拦截 CDN 请求，转由本地 rawfile 提供。
首次 loadUrl 加载完整页面，后续 runJavaScript 保持滚动位置。
```

```
fix: WebView 抢占 TextArea 焦点导致光标消失

Web 组件添加 .focusable(false) 阻止获取焦点。
```

```
refactor: 工具栏按钮改为内联 bindPopup

@Builder 封装导致 bindPopup 不响应 hover 状态变化。
全部内联到 build() 中解决。
```

## Branch Naming

```
feature/<name>
fix/<name>
refactor/<name>
```

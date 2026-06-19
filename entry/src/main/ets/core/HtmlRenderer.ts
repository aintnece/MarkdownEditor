/**
 * HTML 渲染器
 *
 * 将 Markdown AST 渲染为带完整样式的 HTML5 文档。
 * 输出可直接在 WebView 中展示，支持：
 *   - 深色/浅色主题
 *   - 代码语法高亮（内置简易高亮器）
 *   - 响应式布局
 *   - Task list 交互支持
 */

import {
  BlockType, InlineType, ListType, AlignType,
  DocumentNode, BlockNode, InlineNode,
  HeadingNode, ParagraphNode, BlockquoteNode,
  ListNode, ListItemNode, CodeBlockNode,
  TableNode, TableRowNode, TableCellNode,
  ThematicBreakNode,
  TextNode, BoldNode, ItalicNode, StrikethroughNode,
  InlineCodeNode, LinkNode, ImageNode, AutoLinkNode,
  LineBreakNode, HtmlBlockNode, HtmlInlineNode,
  MathBlockNode, MathInlineNode,
} from './MarkdownAST';

// ─── 渲染器配置 ───────────────────────────────────

export interface RenderConfig {
  /** 是否为深色主题 */
  darkMode: boolean;
  /** 基础字体大小 (px) */
  fontSize: number;
  /** 行高 */
  lineHeight: number;
  /** 代码字体 */
  codeFontFamily: string;
}

const DefaultRenderConfig: RenderConfig = {
  darkMode: false,
  fontSize: 16,
  lineHeight: 1.7,
  codeFontFamily: "'Cascadia Code', 'JetBrains Mono', 'Fira Code', 'Consolas', monospace",
};

// ─── 渲染器主类 ───────────────────────────────────

export class HtmlRenderer {
  private config: RenderConfig;

  constructor(config?: Partial<RenderConfig>) {
    this.config = { ...DefaultRenderConfig, ...config };
  }

  /** 渲染完整 HTML 文档 */
  renderFullPage(node: DocumentNode): string {
    const bodyContent = this.renderChildren(node.children);
    return `<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="https://unpkg.com/katex@0.16.22/dist/katex.min.css">
<style>
${this.getStyles()}
</style>
<script defer src="https://unpkg.com/katex@0.16.22/dist/katex.min.js"></script>
<script defer src="https://unpkg.com/katex@0.16.22/dist/contrib/auto-render.min.js"
  onload="renderMathInElement(document.body, { delimiters: [{left:'$$',right:'$$',display:true},{left:'$',right:'$',display:false}], throwOnError:false })"></script>
</head>
<body class="${this.config.darkMode ? 'dark' : 'light'}">
<article class="markdown-body">
${bodyContent}
</article>
<script>
document.addEventListener('click', function(e) {
  var cb = e.target.closest('input[type="checkbox"]');
  if (cb) cb.disabled = false;
});
</script>
</body>
</html>`;
  }

  /** 仅渲染主体内容（无 HTML 框架，可嵌入已有页面） */
  renderBody(node: DocumentNode): string {
    return `<div class="markdown-body ${this.config.darkMode ? 'dark' : 'light'}">\n${this.renderChildren(node.children)}\n</div>`;
  }

  // ── 块级渲染 ────────────────────────────────────

  private renderChildren(children: BlockNode[]): string {
    return children.map(child => this.renderBlock(child)).join('\n');
  }

  private renderBlock(node: BlockNode): string {
    switch (node.type) {
      case BlockType.Paragraph:
        return this.renderParagraph(node as ParagraphNode);
      case BlockType.Heading:
        return this.renderHeading(node as HeadingNode);
      case BlockType.Blockquote:
        return this.renderBlockquote(node as BlockquoteNode);
      case BlockType.List:
        return this.renderList(node as ListNode);
      case BlockType.ListItem:
        return this.renderListItem(node as ListItemNode);
      case BlockType.CodeBlock:
        return this.renderCodeBlock(node as CodeBlockNode);
      case BlockType.Table:
        return this.renderTable(node as TableNode);
      case BlockType.ThematicBreak:
        return '<hr>';
      case BlockType.HtmlBlock:
        return (node as HtmlBlockNode).html;
      case BlockType.MathBlock:
        return this.renderMathBlock(node as MathBlockNode);
      default:
        return '';
    }
  }

  private renderParagraph(node: ParagraphNode): string {
    const content = this.renderInlineChildren(node.children);
    return `<p>${content}</p>`;
  }

  private renderHeading(node: HeadingNode): string {
    const level = Math.min(6, Math.max(1, node.level));
    const content = this.renderInlineChildren(node.children);
    const id = this.slugify(this.getTextContent(node));
    return `<h${level} id="${id}">${content}</h${level}>`;
  }

  private renderBlockquote(node: BlockquoteNode): string {
    const content = node.children.map(c => this.renderBlock(c)).join('\n');
    return `<blockquote>${content}</blockquote>`;
  }

  private renderList(node: ListNode): string {
    const items = node.children.map(item => this.renderListItem(item)).join('\n');
    if (node.listType === ListType.Ordered) {
      const start = node.orderedStart && node.orderedStart !== 1 ? ` start="${node.orderedStart}"` : '';
      return `<ol${start}>\n${items}\n</ol>`;
    }
    return `<ul class="${node.listType === ListType.Task ? 'task-list' : ''}">\n${items}\n</ul>`;
  }

  private renderListItem(node: ListItemNode): string {
    const innerChildren = node.children.map(c => this.renderBlock(c)).join('\n');
    if (node.checked !== undefined) {
      const checked = node.checked ? ' checked' : '';
      return `<li class="task-list-item"><input type="checkbox" disabled${checked}> ${innerChildren}</li>`;
    }
    return `<li>${innerChildren}</li>`;
  }

  private renderCodeBlock(node: CodeBlockNode): string {
    const lang = node.lang || '';
    // 简易语法高亮
    const highlighted = lang ? this.highlightCode(node.code, lang) : this.escapeHtml(node.code);
    return `<pre><code class="language-${lang}">${highlighted}</code></pre>`;
  }

  private renderMathBlock(node: MathBlockNode): string {
    const formula = this.escapeHtml(node.formula);
    return `<div class="math-block">$$${formula}$$</div>`;
  }

  private renderMathInline(node: MathInlineNode): string {
    const formula = this.escapeHtml(node.formula);
    return `<span class="math-inline">$${formula}$</span>`;
  }

  private renderTable(node: TableNode): string {
    const header = this.renderTableRow(node.header, true);
    const rows = node.rows.map(r => this.renderTableRow(r, false)).join('\n');
    return `<div class="table-wrapper"><table>\n<thead>\n${header}\n</thead>\n<tbody>\n${rows}\n</tbody>\n</table></div>`;
  }

  private renderTableRow(node: TableRowNode, isHeader: boolean): string {
    const cells = node.children.map((cell, i) => this.renderTableCell(cell, isHeader)).join('\n    ');
    return `<tr>\n    ${cells}\n</tr>`;
  }

  private renderTableCell(node: TableCellNode, isHeader: boolean): string {
    const tag = isHeader ? 'th' : 'td';
    const align = node.align !== AlignType.None ? ` align="${node.align}"` : '';
    const content = this.renderInlineChildren(node.children);
    return `<${tag}${align}>${content}</${tag}>`;
  }

  // ── 行内渲染 ────────────────────────────────────

  private renderInlineChildren(children: InlineNode[]): string {
    return children.map(child => this.renderInline(child)).join('');
  }

  private renderInline(node: InlineNode): string {
    switch (node.type) {
      case InlineType.Text:
        return this.escapeHtml((node as TextNode).content);
      case InlineType.Bold:
        return `<strong>${this.renderInlineChildren((node as BoldNode).children)}</strong>`;
      case InlineType.Italic:
        return `<em>${this.renderInlineChildren((node as ItalicNode).children)}</em>`;
      case InlineType.Strikethrough:
        return `<del>${this.renderInlineChildren((node as StrikethroughNode).children)}</del>`;
      case InlineType.InlineCode:
        return `<code>${this.escapeHtml((node as InlineCodeNode).content)}</code>`;
      case InlineType.Link:
        return this.renderLink(node as LinkNode);
      case InlineType.Image:
        return this.renderImage(node as ImageNode);
      case InlineType.AutoLink:
        return this.renderAutoLink(node as AutoLinkNode);
      case InlineType.LineBreak:
        return '<br>';
      case InlineType.HtmlInline:
        return (node as HtmlInlineNode).html;
      case InlineType.MathInline:
        return this.renderMathInline(node as MathInlineNode);
      default:
        return '';
    }
  }

  private renderLink(node: LinkNode): string {
    const url = this.escapeHtml(node.url);
    const title = node.title ? ` title="${this.escapeHtml(node.title)}"` : '';
    const content = this.renderInlineChildren(node.children);
    return `<a href="${url}"${title}>${content}</a>`;
  }

  private renderImage(node: ImageNode): string {
    const url = this.escapeHtml(node.url);
    const alt = this.escapeHtml(node.alt);
    const title = node.title ? ` title="${this.escapeHtml(node.title)}"` : '';
    return `<img src="${url}" alt="${alt}"${title} loading="lazy">`;
  }

  private renderAutoLink(node: AutoLinkNode): string {
    const url = this.escapeHtml(node.url);
    return `<a href="${url}">${url}</a>`;
  }

  // ── 语法高亮 (简易版) ────────────────────────────

  /** 简易语法高亮（支持常见语言关键字的着色） */
  private highlightCode(code: string, lang: string): string {
    const escaped = this.escapeHtml(code);
    const langLower = lang.toLowerCase();

    // 语言关键字映射
    const keywords = this.getKeywords(langLower);
    if (!keywords) return escaped;

    // 逐行处理
    return escaped.replace(
      /\b([a-zA-Z_]\w*)\b/g,
      (match) => {
        if (keywords.includes(match)) return `<span class="hl-keyword">${match}</span>`;
        return match;
      },
    );
  }

  private getKeywords(lang: string): string[] | null {
    const map: Record<string, string[]> = {
      javascript: ['function', 'const', 'let', 'var', 'if', 'else', 'for', 'while',
        'do', 'switch', 'case', 'break', 'continue', 'return', 'import', 'export',
        'from', 'class', 'extends', 'new', 'this', 'async', 'await', 'try', 'catch',
        'throw', 'typeof', 'instanceof', 'in', 'of', 'true', 'false', 'null', 'undefined'],
      typescript: ['function', 'const', 'let', 'var', 'if', 'else', 'for', 'while',
        'do', 'switch', 'case', 'break', 'continue', 'return', 'import', 'export',
        'from', 'class', 'extends', 'new', 'this', 'async', 'await', 'try', 'catch',
        'throw', 'typeof', 'instanceof', 'in', 'of', 'true', 'false', 'null', 'undefined',
        'interface', 'type', 'enum', 'implements', 'abstract', 'readonly', 'public',
        'private', 'protected', 'static', 'as', 'any', 'void', 'never', 'string',
        'number', 'boolean', 'Record', 'Partial', 'Required', 'Pick', 'Omit', 'keyof'],
      python: ['def', 'class', 'import', 'from', 'if', 'elif', 'else', 'for', 'while',
        'break', 'continue', 'return', 'yield', 'try', 'except', 'finally', 'raise',
        'with', 'as', 'in', 'is', 'not', 'and', 'or', 'True', 'False', 'None', 'self',
        'lambda', 'pass', 'del', 'global', 'nonlocal', 'assert', 'async', 'await'],
      java: ['public', 'private', 'protected', 'static', 'final', 'class', 'interface',
        'extends', 'implements', 'abstract', 'new', 'this', 'super', 'return', 'if',
        'else', 'for', 'while', 'do', 'switch', 'case', 'break', 'continue', 'try',
        'catch', 'finally', 'throw', 'throws', 'import', 'package', 'void', 'int',
        'long', 'double', 'float', 'boolean', 'char', 'String', 'true', 'false', 'null'],
      c: ['int', 'long', 'double', 'float', 'char', 'void', 'short', 'unsigned',
        'signed', 'if', 'else', 'for', 'while', 'do', 'switch', 'case', 'break',
        'continue', 'return', 'struct', 'union', 'enum', 'typedef', 'const', 'static',
        'extern', 'volatile', 'register', 'sizeof', 'true', 'false', 'NULL'],
      cpp: ['int', 'long', 'double', 'float', 'char', 'void', 'bool', 'short',
        'unsigned', 'signed', 'if', 'else', 'for', 'while', 'do', 'switch', 'case',
        'break', 'continue', 'return', 'class', 'struct', 'union', 'enum', 'typedef',
        'const', 'static', 'extern', 'virtual', 'override', 'template', 'typename',
        'namespace', 'using', 'public', 'private', 'protected', 'new', 'delete',
        'this', 'true', 'false', 'nullptr', 'include', 'define', 'ifdef', 'ifndef',
        'endif', 'pragma'],
      go: ['func', 'type', 'struct', 'interface', 'map', 'chan', 'go', 'defer',
        'select', 'range', 'if', 'else', 'for', 'switch', 'case', 'break', 'continue',
        'return', 'var', 'const', 'package', 'import', 'true', 'false', 'nil',
        'make', 'new', 'append', 'len', 'cap', 'error', 'string', 'int', 'bool',
        'byte', 'rune', 'float64', 'float32'],
      rust: ['fn', 'let', 'mut', 'const', 'if', 'else', 'for', 'while', 'loop',
        'match', 'return', 'break', 'continue', 'struct', 'enum', 'impl', 'trait',
        'pub', 'use', 'mod', 'crate', 'self', 'super', 'where', 'as', 'in', 'ref',
        'move', 'async', 'await', 'true', 'false', 'Some', 'None', 'Ok', 'Err',
        'i32', 'i64', 'u32', 'u64', 'f32', 'f64', 'bool', 'char', 'String', 'str',
        'Vec', 'Box', 'Option', 'Result'],
      sql: ['SELECT', 'FROM', 'WHERE', 'INSERT', 'INTO', 'VALUES', 'UPDATE', 'SET',
        'DELETE', 'CREATE', 'TABLE', 'ALTER', 'DROP', 'INDEX', 'VIEW', 'JOIN',
        'LEFT', 'RIGHT', 'INNER', 'OUTER', 'ON', 'AND', 'OR', 'NOT', 'IN', 'IS',
        'NULL', 'LIKE', 'BETWEEN', 'ORDER', 'BY', 'GROUP', 'HAVING', 'LIMIT',
        'OFFSET', 'AS', 'DISTINCT', 'COUNT', 'SUM', 'AVG', 'MAX', 'MIN', 'EXISTS',
        'UNION', 'ALL', 'CASE', 'WHEN', 'THEN', 'ELSE', 'END', 'PRIMARY', 'KEY',
        'FOREIGN', 'REFERENCES', 'CASCADE'],
    };
    // 匹配广义语言名
    const langLower = lang.toLowerCase();
    for (const [key, words] of Object.entries(map)) {
      if (langLower.includes(key)) return words;
    }
    return null;
  }

  // ── CSS 样式生成 ─────────────────────────────────

  private getStyles(): string {
    const { darkMode, fontSize, lineHeight, codeFontFamily } = this.config;
    const bg = darkMode ? '#1a1a2e' : '#ffffff';
    const fg = darkMode ? '#e0e0e0' : '#24292e';
    const headingFg = darkMode ? '#f0f0f0' : '#1a1a2e';
    const codeBg = darkMode ? '#2d2d44' : '#f6f8fa';
    const codeFg = darkMode ? '#e6e6e6' : '#24292e';
    const border = darkMode ? '#3a3a5c' : '#dfe2e5';
    const blockquoteBg = darkMode ? '#1e1e38' : '#f8f9fa';
    const blockquoteBorder = darkMode ? '#5a5a8a' : '#dfe2e5';
    const linkColor = darkMode ? '#7ec8e3' : '#0366d6';
    const tableBg = darkMode ? '#1e1e38' : '#f8f9fa';
    const tableAltBg = darkMode ? '#252545' : '#f0f2f5';
    const hrColor = darkMode ? '#3a3a5c' : '#e1e4e8';

    return `
* { margin: 0; padding: 0; box-sizing: border-box; }
body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', 'Microsoft YaHei', sans-serif; font-size: ${fontSize}px; line-height: ${lineHeight}; color: ${fg}; background: ${bg}; padding: 16px; }
.markdown-body { max-width: 100%; overflow-x: hidden; }

/* 标题 */
h1 { font-size: ${fontSize * 2}px; font-weight: 700; margin: 24px 0 16px; padding-bottom: 8px; border-bottom: 1px solid ${border}; color: ${headingFg}; }
h2 { font-size: ${fontSize * 1.5}px; font-weight: 600; margin: 20px 0 12px; padding-bottom: 6px; border-bottom: 1px solid ${border}; color: ${headingFg}; }
h3 { font-size: ${fontSize * 1.25}px; font-weight: 600; margin: 16px 0 8px; color: ${headingFg}; }
h4 { font-size: ${fontSize * 1.1}px; font-weight: 600; margin: 14px 0 8px; color: ${headingFg}; }
h5 { font-size: ${fontSize}px; font-weight: 600; margin: 12px 0 6px; color: ${headingFg}; }
h6 { font-size: ${fontSize * 0.9}px; font-weight: 600; margin: 10px 0 6px; color: ${headingFg}; }

/* 段落 */
p { margin: 8px 0; }
p + p { margin-top: 12px; }

/* 链接 */
a { color: ${linkColor}; text-decoration: none; }
a:hover { text-decoration: underline; }

/* 列表 */
ul, ol { padding-left: 24px; margin: 8px 0; }
li { margin: 4px 0; }
li > ul, li > ol { margin: 2px 0; }

/* 任务列表 */
.task-list { list-style: none; padding-left: 0; }
.task-list-item { display: flex; align-items: flex-start; gap: 8px; margin: 4px 0; }
.task-list-item input[type="checkbox"] { margin-top: 4px; flex-shrink: 0; }

/* 引用 */
blockquote { margin: 12px 0; padding: 8px 16px; border-left: 4px solid ${blockquoteBorder}; background: ${blockquoteBg}; border-radius: 0 4px 4px 0; }
blockquote p { margin: 4px 0; }

/* 代码 */
code { font-family: ${codeFontFamily}; font-size: 0.9em; background: ${codeBg}; color: ${codeFg}; padding: 2px 6px; border-radius: 3px; }
pre { margin: 12px 0; background: ${codeBg}; border-radius: 6px; padding: 14px 16px; overflow-x: auto; }
pre code { background: none; padding: 0; font-size: 0.9em; line-height: 1.5; }
pre code .hl-keyword { color: ${darkMode ? '#c792ea' : '#d73a49'}; font-weight: 500; }

/* 表格 */
.table-wrapper { overflow-x: auto; margin: 12px 0; }
table { width: 100%; border-collapse: collapse; font-size: 0.95em; }
th, td { padding: 8px 12px; border: 1px solid ${border}; text-align: left; }
thead { background: ${tableBg}; }
thead th { font-weight: 600; }
tbody tr:nth-child(even) { background: ${tableAltBg}; }

/* 分割线 */
hr { margin: 20px 0; border: none; border-top: 1px solid ${hrColor}; }

/* 图片 */
img { max-width: 100%; height: auto; border-radius: 4px; margin: 8px 0; }

/* 行内元素 */
strong { font-weight: 600; }
em { font-style: italic; }
del { text-decoration: line-through; }

/* 数学公式 */
.math-block { display: block; width: 100%; text-align: center; margin: 16px 0; overflow-x: auto; }
.math-inline { display: inline; }

/* 响应式 */
@media (max-width: 480px) {
  body { padding: 10px; font-size: ${fontSize * 0.9}px; }
  pre { padding: 10px 12px; }
}`;
  }

  // ── 工具方法 ────────────────────────────────────

  /** HTML 转义 */
  private escapeHtml(text: string): string {
    return text
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#39;');
  }

  /** 获取节点纯文本内容 */
  private getTextContent(node: BlockNode | InlineNode): string {
    if ('content' in node) return (node as any).content || '';
    if ('children' in node && node.children) {
      return node.children.map((c: any) => this.getTextContent(c)).join('');
    }
    if ('code' in node) return (node as any).code;
    return '';
  }

  /** 生成 slug（用于标题锚点） */
  private slugify(text: string): string {
    return text
      .toLowerCase()
      .trim()
      .replace(/[^\w\u4e00-\u9fff\u3040-\u309f\u30a0-\u30ff-]/g, '-')
      .replace(/-+/g, '-')
      .replace(/^-|-$/g, '');
  }
}

/**
 * Markdown 解析器 (Parser)
 *
 * 将 Token 流解析为 AST（抽象语法树）。
 * 多遍扫描策略：
 *   第1遍：块级结构分析（标题、列表、代码块、引用、表格等）
 *   第2遍：行内元素解析（粗体、斜体、链接、行内代码等）
 */

import {
  BlockType, InlineType, ListType, AlignType,
  DocumentNode, BlockNode, InlineNode,
  HeadingNode, ParagraphNode, BlockquoteNode,
  ListNode, ListItemNode, CodeBlockNode,
  TableNode, TableRowNode, TableCellNode,
  ThematicBreakNode, HtmlBlockNode, MathBlockNode,
  TextNode, BoldNode, ItalicNode, StrikethroughNode,
  InlineCodeNode, LinkNode, ImageNode,
  AutoLinkNode, LineBreakNode, HtmlInlineNode, MathInlineNode,
} from './MarkdownAST';
import { Tokenizer, Token, TokenType, TokenMeta } from './MarkdownTokenizer';

// ─── 解析器配置 ───────────────────────────────────

export interface ParserConfig {
  /** 是否启用 GFM 表格 */
  enableTables: boolean;
  /** 是否启用任务列表 */
  enableTaskLists: boolean;
  /** 是否启用删除线 */
  enableStrikethrough: boolean;
  /** 是否启用自动链接 */
  enableAutoLinks: boolean;
  /** 是否启用数学公式 ($...$ / $$...$$) */
  enableMath: boolean;
}

const DefaultConfig: ParserConfig = {
  enableTables: true,
  enableTaskLists: true,
  enableStrikethrough: true,
  enableAutoLinks: true,
  enableMath: true,
};

// ─── 解析器主类 ───────────────────────────────────

export class MarkdownParser {
  private input: string;
  private config: ParserConfig;
  private tokenizer: Tokenizer;
  private tokens: Token[];
  private pos: number = 0;

  constructor(input: string, config?: Partial<ParserConfig>) {
    this.input = input;
    this.config = { ...DefaultConfig, ...config };
    this.tokenizer = new Tokenizer(input);
    this.tokens = this.tokenizer.tokenize();
  }

  /** 主入口：解析文档，返回 AST 根节点 */
  parse(): DocumentNode {
    const children: BlockNode[] = [];
    const lines = this.input.split('\n');

    let i = 0;
    while (i < lines.length) {
      const result = this.parseBlockInLines(lines, i);
      if (result) {
        children.push(result.node);
        i = result.nextLine;
      } else {
        i++;
      }
    }

    return {
      type: BlockType.Document,
      children,
    };
  }

  // ── 块级解析（基于行扫描） ──────────────────────

  private parseBlockInLines(lines: string[], start: number): { node: BlockNode; nextLine: number } | null {
    // 跳过空行
    if (start >= lines.length) return null;
    const rawLine = lines[start];
    if (rawLine.trim() === '') return null;

    const line = rawLine;
    const trimmed = line.trim();
    let i = start;

    // ── ATX 标题 ──
    const headingMatch = trimmed.match(/^(#{1,6})(?:\s+|$)(.*)$/);
    if (headingMatch) {
      const level = headingMatch[1].length;
      const content = headingMatch[2].replace(/\s+#+\s*$/, '').trim();
      return {
        node: this.makeHeading(level, content),
        nextLine: i + 1,
      };
    }

    // ── Setext 标题（下一行是 === 或 ---）──
    if (i + 1 < lines.length) {
      const nextTrimmed = lines[i + 1].trim();
      if (/^={3,}\s*$/.test(nextTrimmed)) {
        return {
          node: this.makeHeading(1, trimmed),
          nextLine: i + 2,
        };
      }
      if (/^-{3,}\s*$/.test(nextTrimmed) && !trimmed.startsWith('-')) {
        // 避免误判分割线
        return {
          node: this.makeHeading(2, trimmed),
          nextLine: i + 2,
        };
      }
    }

    // ── 分割线 ──
    if (/^(-{3,}|\*{3,}|_{3,})\s*$/.test(trimmed)) {
      return {
        node: { type: BlockType.ThematicBreak },
        nextLine: i + 1,
      };
    }

    // ── 围栏代码块 ──
    const fenceMatch = trimmed.match(/^(```+|~~~+)(\S*)\s*$/);
    if (fenceMatch) {
      const fenceChar = fenceMatch[1][0];
      const fenceLen = fenceMatch[1].length;
      const lang = fenceMatch[2] || undefined;
      const codeLines: string[] = [];
      i++;
      while (i < lines.length) {
        const cl = lines[i];
        if (cl.trim().startsWith(fenceChar) && this.isFenceClose(cl, fenceChar, fenceLen)) {
          i++;
          break;
        }
        codeLines.push(cl);
        i++;
      }
      return {
        node: {
          type: BlockType.CodeBlock,
          lang,
          code: codeLines.join('\n'),
        } as CodeBlockNode,
        nextLine: i,
      };
    }

    // ── 数学公式块 $$...$$ ──
    if (this.config.enableMath && trimmed.startsWith('$$')) {
      const formulaLines: string[] = [];
      i++;
      while (i < lines.length) {
        const cl = lines[i].trim();
        if (cl.endsWith('$$')) {
          // 可能有尾部公式
          formulaLines.push(cl.replace(/\$\$$/, ''));
          i++;
          break;
        }
        formulaLines.push(lines[i]);
        i++;
      }
      return {
        node: {
          type: BlockType.MathBlock,
          formula: formulaLines.join('\n'),
        } as MathBlockNode,
        nextLine: i,
      };
    }

    // ── 缩进代码块（4空格/1制表符）──
    if (this.isIndented(line)) {
      const codeLines: string[] = [];
      while (i < lines.length) {
        if (this.isIndented(lines[i]) || lines[i].trim() === '') {
          codeLines.push(lines[i].replace(/^ {1,4}/, ''));
          i++;
        } else {
          break;
        }
      }
      return {
        node: {
          type: BlockType.CodeBlock,
          code: codeLines.join('\n'),
        } as CodeBlockNode,
        nextLine: i,
      };
    }

    // ── 引用块 ──
    if (trimmed.startsWith('>')) {
      const quoteLines: string[] = [];
      while (i < lines.length) {
        const l = lines[i].trim();
        if (l.startsWith('>')) {
          quoteLines.push(l.replace(/^>\s?/, ''));
          i++;
        } else if (lines[i].trim() === '') {
          quoteLines.push('');
          i++;
          if (i < lines.length && !lines[i].trim().startsWith('>')) break;
        } else {
          break;
        }
      }
      // 递归解析引用块内容
      const subParser = new MarkdownParser(quoteLines.join('\n'), this.config);
      const subDoc = subParser.parse();
      return {
        node: {
          type: BlockType.Blockquote,
          children: subDoc.children,
        } as BlockquoteNode,
        nextLine: i,
      };
    }

    // ── 表格 ├──
    if (this.config.enableTables && trimmed.includes('|')) {
      // 检查下一行是否表格分隔符
      if (i + 1 < lines.length) {
        const nextLine = lines[i + 1].trim();
        if (/^\|?[\s:]?-{3,}[\s:]?(?:\|[\s:]?-{3,}[\s:]?)+\|?$/.test(nextLine)) {
          return this.parseTable(lines, i);
        }
      }
    }

    // ── 列表 ──
    const listResult = this.tryParseList(lines, i);
    if (listResult) return listResult;

    // ── 段落（默认） ──
    const paraLines: string[] = [line];
    i++;
    while (i < lines.length) {
      const l = lines[i];
      if (l.trim() === '') break;
      // 如果遇到新的块级标记则停止
      if (/^(#{1,6}\s|>|```|~~~|\d+[.)]\s+|[-*+]\s+)/.test(l.trim())) break;
      if (/^\|.*\|/.test(l.trim()) && this.config.enableTables) {
        if (i + 1 < lines.length && /^\|?[\s:]?-{3,}/.test(lines[i + 1].trim())) break;
      }
      if (this.isIndented(l)) break;
      paraLines.push(l);
      i++;
    }
    return {
      node: this.makeParagraph(paraLines.join('\n')),
      nextLine: i,
    };
  }

  // ── 列表解析 ────────────────────────────────────

  private tryParseList(lines: string[], start: number): { node: ListNode; nextLine: number } | null {
    const trimmed = lines[start].trim();
    let listType: ListType;
    let orderedStart: number | undefined;

    const ulMatch = trimmed.match(/^([-*+])\s+/);
    const olMatch = trimmed.match(/^(\d{1,9})([.)])\s+/);
    const taskMatch = trimmed.match(/^\s*[-*+]\s+\[([ xX])\]\s+/);

    if (taskMatch && this.config.enableTaskLists) {
      listType = ListType.Task;
    } else if (ulMatch) {
      listType = ListType.Unordered;
    } else if (olMatch) {
      listType = ListType.Ordered;
      orderedStart = parseInt(olMatch[1]);
    } else {
      return null;
    }

    // 确定缩进基准
    const baseIndent = lines[start].search(/\S/);
    const items: ListItemNode[] = [];
    let i = start;

    while (i < lines.length) {
      const l = lines[i];
      const lt = l.trim();

      // 空行：如果是紧凑列表且后续有列表项则继续
      if (lt === '') {
        // 检查下一行是否还有列表项
        if (i + 1 >= lines.length) break;
        const nextIndent = lines[i + 1].search(/\S/);
        const nextTrimmed = lines[i + 1].trim();
        const isNextItem = /^[-*+]\s+/.test(nextTrimmed) ||
          /^\d+[.)]\s+/.test(nextTrimmed) ||
          /^\s*[-*+]\s+\[[ xX]\]\s+/.test(nextTrimmed);
        if (isNextItem && nextIndent >= baseIndent) {
          items[items.length - 1].children.push({
            type: BlockType.Paragraph,
            children: this.parseInlines(''),
          } as ParagraphNode);
          i++;
          continue;
        }
        break;
      }

      // 当前缩进
      const indent = l.search(/\S/);

      // 检测新的列表项
      const isItem = /^([-*+])\s+/.test(lt) ||
        /^(\d{1,9}[.)])\s+/.test(lt) ||
        /^[-*+]\s+\[[ xX]\]\s+/.test(lt);

      if (isItem && indent === baseIndent) {
        // 检查是否是同一列表类型
        let sameType = false;
        if (listType === ListType.Task && /^[-*+]\s+\[[ xX]\]\s+/.test(lt)) sameType = true;
        else if (listType === ListType.Unordered && /^[-*+]\s+/.test(lt) && !/^[-*+]\s+\[[ xX]\]\s+/.test(lt)) sameType = true;
        else if (listType === ListType.Ordered && /^\d+[.)]\s+/.test(lt)) sameType = true;

        if (sameType) {
          // 提取列表项内容
          let content: string;
          let checked: boolean | undefined;
          if (listType === ListType.Task) {
            const m = lt.match(/^[-*+]\s+\[([ xX])\]\s+(.*)$/);
            if (m) {
              checked = m[1].toLowerCase() === 'x';
              content = m[2];
            } else {
              content = lt.replace(/^[-*+]\s+\[[ xX]\]\s+/, '');
            }
          } else if (listType === ListType.Unordered) {
            content = lt.replace(/^[-*+]\s+/, '');
          } else {
            content = lt.replace(/^\d+[.)]\s+/, '');
          }

          // 解析该列表项的子内容（可能包含嵌套段落）
          const itemChildren = this.parseListItemContent(content);
          items.push({
            type: BlockType.ListItem,
            checked,
            children: itemChildren,
          } as ListItemNode);
          i++;
          continue;
        }
      }

      // 续行（同一段落或缩进的子内容）
      if (items.length > 0) {
        // 如果是缩进内容（子列表或续行）
        const lastItem = items[items.length - 1];
        // 简单处理：作为段落追加
        const contentParser = (() => {
          const text = lt;
          if (lastItem.children.length > 0) {
            const lastChild = lastItem.children[lastItem.children.length - 1];
            if (lastChild.type === BlockType.Paragraph) {
              (lastChild as ParagraphNode).children.push(
                { type: InlineType.LineBreak } as LineBreakNode,
                ...this.parseInlines(text),
              );
            } else {
              lastItem.children.push(this.makeParagraph(text));
            }
          } else {
            lastItem.children.push(this.makeParagraph(text));
          }
        })();
        i++;
      } else {
        break;
      }
    }

    return {
      node: {
        type: BlockType.List,
        listType,
        orderedStart,
        tight: true, // 简单处理
        children: items,
      } as ListNode,
      nextLine: i,
    };
  }

  /** 解析列表项内容（转换为块节点数组） */
  private parseListItemContent(content: string): BlockNode[] {
    if (!content.trim()) return [];
    return [this.makeParagraph(content)];
  }

  /** 解析嵌套列表 */

  // ── 表格解析 ────────────────────────────────────

  private parseTable(lines: string[], start: number): { node: TableNode; nextLine: number } {
    const headerRow = this.parseTableRow(lines[start]);
    const alignLine = lines[start + 1];
    const aligns = this.parseAligns(alignLine);
    const rows: TableRowNode[] = [];
    let i = start + 2;

    while (i < lines.length) {
      const l = lines[i].trim();
      if (!l.includes('|') || l.startsWith('|') === false && l.endsWith('|') === false && l.split('|').length < 2) break;
      // 检查是否是另一个表格的分隔行
      if (/^\|?[\s:]?-{3,}/.test(l) && l.includes('|')) break;
      rows.push(this.parseTableRow(l));
      i++;
    }

    return {
      node: {
        type: BlockType.Table,
        aligns,
        header: headerRow,
        rows,
      } as TableNode,
      nextLine: i,
    };
  }

  private parseTableRow(line: string): TableRowNode {
    const cells = line.split('|').filter(c => c.trim().length > 0 || true);
    // 去掉首尾空
    let parts = line.split('|');
    if (line.trim().startsWith('|')) parts = parts.slice(1);
    if (line.trim().endsWith('|')) parts = parts.slice(0, -1);

    return {
      type: BlockType.TableRow,
      children: parts.map(cell => ({
        type: BlockType.TableCell,
        align: AlignType.None,
        children: this.parseInlines(cell.trim()),
      } as TableCellNode)),
    } as TableRowNode;
  }

  private parseAligns(line: string): AlignType[] {
    const parts = line.split('|').filter(p => p.trim().length > 0);
    // 从 line 中精确提取
    let cols: string[];
    if (line.trim().startsWith('|')) {
      cols = line.split('|').slice(1, -1);
    } else {
      cols = line.split('|');
    }
    return cols.map(c => {
      const cell = c.trim();
      const left = cell.startsWith(':');
      const right = cell.endsWith(':');
      if (left && right) return AlignType.Center;
      if (right) return AlignType.Right;
      if (left) return AlignType.Left;
      return AlignType.None;
    });
  }

  // ── 行内解析 ────────────────────────────────────

  /** 解析一行文本中的行内元素 */
  parseInlines(text: string): InlineNode[] {
    const nodes: InlineNode[] = [];
    let i = 0;

    while (i < text.length) {
      const ch = text[i];

      // ── 转义 ──
      if (ch === '\\' && i + 1 < text.length) {
        nodes.push({ type: InlineType.Text, content: text[i + 1] } as TextNode);
        i += 2;
        continue;
      }

      // ──硬换行（两个空格+换行或 \）──
      if (ch === '\\' && i + 1 < text.length && text[i + 1] === '\n') {
        nodes.push({ type: InlineType.LineBreak } as LineBreakNode);
        i += 2;
        continue;
      }

      // ──行内代码 ──
      if (ch === '`') {
        const codeResult = this.parseInlineCode(text, i);
        if (codeResult) {
          nodes.push(codeResult.node);
          i = codeResult.next;
          continue;
        }
      }

      // ──行内数学公式 $...$ ──
      if (ch === '$' && this.config.enableMath) {
        const mathResult = this.parseInlineMath(text, i);
        if (mathResult) {
          nodes.push(mathResult.node);
          i = mathResult.next;
          continue;
        }
      }

      // ──自动链接 <url> ──
      if (ch === '<' && this.config.enableAutoLinks) {
        const autoLinkResult = this.parseAutoLink(text, i);
        if (autoLinkResult) {
          nodes.push(autoLinkResult.node);
          i = autoLinkResult.next;
          continue;
        }
      }

      // ──图片 ![alt](url) ──
      if (ch === '!' && i + 1 < text.length && text[i + 1] === '[') {
        const imgResult = this.parseImage(text, i);
        if (imgResult) {
          nodes.push(imgResult.node);
          i = imgResult.next;
          continue;
        }
      }

      // ──链接 [text](url) ──
      if (ch === '[') {
        const linkResult = this.parseLink(text, i);
        if (linkResult) {
          nodes.push(linkResult.node);
          i = linkResult.next;
          continue;
        }
        // 如果不是合法链接，作为普通文本
        nodes.push({ type: InlineType.Text, content: '[' } as TextNode);
        i++;
        continue;
      }

      // ──删除线 ~~text~~ ──
      if (ch === '~' && i + 1 < text.length && text[i + 1] === '~' && this.config.enableStrikethrough) {
        const strikeResult = this.parseStrikethrough(text, i);
        if (strikeResult) {
          nodes.push(strikeResult.node);
          i = strikeResult.next;
          continue;
        }
      }

      // ──粗体 **text** 或 __text__ ──
      if ((ch === '*' && i + 1 < text.length && text[i + 1] === '*') ||
        (ch === '_' && i + 1 < text.length && text[i + 1] === '_')) {
        const boldResult = this.parseBold(text, i);
        if (boldResult) {
          nodes.push(boldResult.node);
          i = boldResult.next;
          continue;
        }
      }

      // ──斜体 *text* 或 _text_ ──
      if (ch === '*' || ch === '_') {
        const italicResult = this.parseItalic(text, i);
        if (italicResult) {
          nodes.push(italicResult.node);
          i = italicResult.next;
          continue;
        }
      }

      // ──默认文本 ──
      nodes.push({ type: InlineType.Text, content: ch } as TextNode);
      i++;
    }

    // 合并相邻的 TextNode
    return this.mergeTextNodes(nodes);
  }

  /** 解析行内代码 */
  private parseInlineCode(text: string, start: number): { node: InlineCodeNode; next: number } | null {
    if (text[start] !== '`') return null;
    // 统计开头反引号数
    let count = 0;
    while (start + count < text.length && text[start + count] === '`') count++;
    const pattern = '`'.repeat(count);
    const endIdx = text.indexOf(pattern, start + count);
    if (endIdx === -1) return null;
    const content = text.slice(start + count, endIdx);
    return {
      node: { type: InlineType.InlineCode, content } as InlineCodeNode,
      next: endIdx + count,
    };
  }

  /** 解析行内数学公式 $...$ */
  private parseInlineMath(text: string, start: number): { node: MathInlineNode; next: number } | null {
    if (text[start] !== '$') return null;
    // 跳过 $$（块级数学）
    if (start + 1 < text.length && text[start + 1] === '$') return null;
    // $ 后紧跟数字或空格 → 当作普通美元符号
    if (start + 1 >= text.length) return null;
    if (/\d|\s/.test(text[start + 1])) return null;
    // 查找闭合 $
    const endIdx = text.indexOf('$', start + 1);
    if (endIdx === -1) return null;
    // 闭合 $ 前不能是空格
    if (endIdx > start + 1 && text[endIdx - 1] === ' ') return null;
    const formula = text.slice(start + 1, endIdx);
    if (formula.length === 0) return null;
    return {
      node: { type: InlineType.MathInline, formula } as MathInlineNode,
      next: endIdx + 1,
    };
  }

  /** 解析自动链接 */
  private parseAutoLink(text: string, start: number): { node: AutoLinkNode | HtmlInlineNode; next: number } | null {
    if (text[start] !== '<') return null;
    const endIdx = text.indexOf('>', start + 1);
    if (endIdx === -1) return null;
    const content = text.slice(start + 1, endIdx);
    // 判断是 URL 还是 HTML 标签
    if (content.startsWith('http://') || content.startsWith('https://') || content.startsWith('mailto:')) {
      return {
        node: { type: InlineType.AutoLink, url: content } as AutoLinkNode,
        next: endIdx + 1,
      };
    }
    // 否则当做 HTML 行内元素
    return {
      node: { type: InlineType.HtmlInline, html: content } as HtmlInlineNode,
      next: endIdx + 1,
    };
  }

  /** 解析图片 */
  private parseImage(text: string, start: number): { node: ImageNode; next: number } | null {
    if (text[start] !== '!' || text[start + 1] !== '[') return null;
    const altEnd = text.indexOf(']', start + 2);
    if (altEnd === -1) return null;
    const alt = text.slice(start + 2, altEnd);
    if (text[altEnd + 1] !== '(') return null;
    const urlEnd = text.indexOf(')', altEnd + 2);
    if (urlEnd === -1) return null;
    const urlContent = text.slice(altEnd + 2, urlEnd);
    const [url, ...titleParts] = urlContent.split(/\s+/);
    const title = titleParts.join(' ').replace(/^["']|["']$/g, '') || undefined;
    return {
      node: { type: InlineType.Image, url, alt, title } as ImageNode,
      next: urlEnd + 1,
    };
  }

  /** 解析链接 */
  private parseLink(text: string, start: number): { node: LinkNode; next: number } | null {
    if (text[start] !== '[') return null;
    // 查找 ] 和后续 (
    const closeBracket = text.indexOf(']', start + 1);
    if (closeBracket === -1) return null;
    const linkText = text.slice(start + 1, closeBracket);
    if (text[closeBracket + 1] !== '(') return null;
    const closeParen = this.findCloseParen(text, closeBracket + 2);
    if (closeParen === -1) return null;
    const urlContent = text.slice(closeBracket + 2, closeParen);
    // 分离 url 和 title
    const parts = urlContent.match(/^(\S+?)(?:\s+["'(](.+?)["')])?\s*$/);
    if (!parts) return null;
    const url = parts[1];
    const title = parts[2] || undefined;
    return {
      node: {
        type: InlineType.Link,
        url,
        title,
        children: this.parseInlines(linkText),
      } as LinkNode,
      next: closeParen + 1,
    };
  }

  /** 找到匹配的右括号（跳过内部嵌套括号） */
  private findCloseParen(text: string, start: number): number {
    let depth = 1;
    for (let i = start; i < text.length; i++) {
      if (text[i] === '(') depth++;
      else if (text[i] === ')') {
        depth--;
        if (depth === 0) return i;
      }
      // 遇到引号则跳过引号内容
      if (text[i] === '"' || text[i] === "'") {
        const quote = text[i];
        i++;
        while (i < text.length && text[i] !== quote) {
          if (text[i] === '\\') i++;
          i++;
        }
      }
    }
    return -1;
  }

  /** 解析删除线 */
  private parseStrikethrough(text: string, start: number): { node: StrikethroughNode; next: number } | null {
    if (!text.startsWith('~~', start)) return null;
    const endIdx = text.indexOf('~~', start + 2);
    if (endIdx === -1) return null;
    const inner = text.slice(start + 2, endIdx);
    return {
      node: {
        type: InlineType.Strikethrough,
        children: this.parseInlines(inner),
      } as StrikethroughNode,
      next: endIdx + 2,
    };
  }

  /** 解析粗体 */
  private parseBold(text: string, start: number): { node: BoldNode; next: number } | null {
    const marker = text.slice(start, start + 2);
    if (marker !== '**' && marker !== '__') return null;
    const endIdx = text.indexOf(marker, start + 2);
    if (endIdx === -1) return null;
    const inner = text.slice(start + 2, endIdx);
    return {
      node: {
        type: InlineType.Bold,
        children: this.parseInlines(inner),
      } as BoldNode,
      next: endIdx + 2,
    };
  }

  /** 解析斜体 */
  private parseItalic(text: string, start: number): { node: ItalicNode; next: number } | null {
    const marker = text[start];
    // 跳过粗体
    if (start + 1 < text.length && text[start + 1] === marker) return null;
    const endIdx = text.indexOf(marker, start + 1);
    if (endIdx === -1) return null;
    // 不允许空斜体
    if (endIdx === start + 1) return null;
    const inner = text.slice(start + 1, endIdx);
    return {
      node: {
        type: InlineType.Italic,
        children: this.parseInlines(inner),
      } as ItalicNode,
      next: endIdx + 1,
    };
  }

  // ── 工具方法 ────────────────────────────────────

  private makeHeading(level: number, content: string): HeadingNode {
    return {
      type: BlockType.Heading,
      level,
      children: this.parseInlines(content),
    };
  }

  private makeParagraph(content: string): ParagraphNode {
    return {
      type: BlockType.Paragraph,
      children: this.parseInlines(content),
    };
  }

  private isIndented(line: string): boolean {
    return line.startsWith('    ') || line.startsWith('\t');
  }

  private isFenceClose(line: string, char: string, minLen: number): boolean {
    const trimmed = line.trim();
    return trimmed.startsWith(char) && trimmed.length >= minLen && isAllChar(trimmed, char, minLen);
  }

  /** 合并相邻 TextNode */
  private mergeTextNodes(nodes: InlineNode[]): InlineNode[] {
    const result: InlineNode[] = [];
    for (const node of nodes) {
      if (node.type === InlineType.Text && result.length > 0 &&
        result[result.length - 1].type === InlineType.Text) {
        (result[result.length - 1] as TextNode).content += (node as TextNode).content;
      } else {
        result.push(node);
      }
    }
    return result;
  }
}

function isAllChar(line: string, ch: string, minCount: number = 3): boolean {
  for (const c of line) {
    if (c !== ch) return false;
  }
  return line.length >= minCount;
}

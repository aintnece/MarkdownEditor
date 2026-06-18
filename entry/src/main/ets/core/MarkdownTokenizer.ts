/**
 * Markdown 词法分析器 (Tokenizer)
 *
 * 将原始 Markdown 文本分解为 Token 流。
 * 每个 Token 携带类型、文本内容和位置信息。
 * 支持 GFM 全部语法元素的词法切分。
 */

import { ListType, AlignType } from './MarkdownAST';

// ─── Token 类型枚举 ───────────────────────────────

export enum TokenType {
  // 块级 Token
  HeadingMarker = 'HeadingMarker',
  ThematicBreak = 'ThematicBreak',
  FenceOpen = 'FenceOpen',
  FenceClose = 'FenceClose',
  BlockquoteMarker = 'BlockquoteMarker',
  UnorderedListMarker = 'UnorderedListMarker',
  OrderedListMarker = 'OrderedListMarker',
  TaskMarker = 'TaskMarker',
  TableRow = 'TableRow',
  TableDivider = 'TableDivider',
  HtmlBlock = 'HtmlBlock',
  Paragraph = 'Paragraph',
  BlankLine = 'BlankLine',

  // 行内 Token（解析器内部分解用）
  Text = 'Text',
  BoldMarker = 'BoldMarker',
  ItalicMarker = 'ItalicMarker',
  StrikethroughMarker = 'StrikethroughMarker',
  InlineCode = 'InlineCode',
  LinkStart = 'LinkStart',
  LinkEnd = 'LinkEnd',
  ImageStart = 'ImageStart',
  AutoLink = 'AutoLink',
  HardBreak = 'HardBreak',
  HtmlInline = 'HtmlInline',
  Escape = 'Escape',

  EOF = 'EOF',
}

// ─── Token 接口 ───────────────────────────────────

export interface Token {
  type: TokenType;
  /** 原始文本 */
  raw: string;
  /** 行号（从 1 开始） */
  line: number;
  /** 列号 */
  col: number;
  /** 附加元数据 */
  meta?: TokenMeta;
}

export interface TokenMeta {
  /** 标题级别 */
  headingLevel?: number;
  /** 围栏语言 */
  fenceLang?: string;
  /** 有序列表起始数字 */
  orderedStart?: number;
  /** 任务列表勾选状态 */
  taskChecked?: boolean;
  /** 表格对齐方式 */
  aligns?: AlignType[];
  /** 转义字符 */
  escapedChar?: string;
}

// ─── 工具函数 ─────────────────────────────────────

/** 判断一行是否全部为某个字符（分割线和表格分隔符检测用） */
function isAllChar(line: string, ch: string, minCount: number = 3): boolean {
  if (line.length < minCount) return false;
  for (let i = 0; i < line.length; i++) {
    if (line[i] !== ch && line[i] !== ' ') return false;
  }
  return true;
}

/** 计算行首缩进空格数 */
function leadingSpaces(line: string): number {
  let count = 0;
  for (const ch of line) {
    if (ch === ' ') count++;
    else if (ch === '\t') count += 4;
    else break;
  }
  return count;
}

/** 移除行首空格 */
function trimStart(line: string): string {
  let i = 0;
  while (i < line.length && (line[i] === ' ' || line[i] === '\t')) i++;
  return line.slice(i);
}

/** 检测有序列表 "N. " 或 "N) " */
function matchOrderedStart(line: string): { num: number; rest: string } | null {
  const m = line.match(/^(\d{1,9})([.)])\s+/);
  if (m) return { num: parseInt(m[1]), rest: line.slice(m[0].length) };
  return null;
}

// ─── Tokenizer 主类 ───────────────────────────────

export class Tokenizer {
  private lines: string[];
  private pos: number = 0; // 当前行索引
  private lineCount: number;

  constructor(input: string) {
    // 按行分割，保留空行
    this.lines = input.split('\n');
    this.lineCount = this.lines.length;
  }

  /** 获取所有块级 Token */
  tokenize(): Token[] {
    const tokens: Token[] = [];

    while (this.pos < this.lineCount) {
      const token = this.nextToken();
      if (token) tokens.push(token);
      this.pos++;
    }

    tokens.push({ type: TokenType.EOF, raw: '', line: this.lineCount + 1, col: 1 });
    return tokens;
  }

  /** 获取下一个 Token */
  private nextToken(): Token | null {
    const line = this.lines[this.pos];
    const lineNum = this.pos + 1;

    // 空行
    if (line === '' || line.trim() === '') {
      return { type: TokenType.BlankLine, raw: line, line: lineNum, col: 1 };
    }

    const trimmed = line.trim();

    // ── ATX 标题： # ~ ###### ──
    const headingMatch = trimmed.match(/^(#{1,6})(?:\s+|$)(.*)$/);
    if (headingMatch) {
      return {
        type: TokenType.HeadingMarker,
        raw: line,
        line: lineNum,
        col: line.indexOf('#') + 1,
        meta: { headingLevel: headingMatch[1].length },
      };
    }

    // ── 分割线： --- / *** / ___ ──
    if (/^(-{3,}|\*{3,}|_{3,})\s*$/.test(trimmed)) {
      return { type: TokenType.ThematicBreak, raw: line, line: lineNum, col: 1 };
    }

    // ── 围栏式代码块开始 ──
    const fenceMatch = trimmed.match(/^(```+|~~~+)(\S*)\s*$/);
    if (fenceMatch) {
      return {
        type: TokenType.FenceOpen,
        raw: line,
        line: lineNum,
        col: line.indexOf(fenceMatch[1]) + 1,
        meta: { fenceLang: fenceMatch[2] || undefined },
      };
    }

    // ── 引用标记 ──
    if (/^>/.test(trimmed)) {
      return {
        type: TokenType.BlockquoteMarker,
        raw: line,
        line: lineNum,
        col: line.indexOf('>') + 1,
      };
    }

    // ── 无序列表 ──
    if (/^[-*+]\s+/.test(trimmed) && !/^[-*+]\s*$/.test(trimmed)) {
      return {
        type: TokenType.UnorderedListMarker,
        raw: line,
        line: lineNum,
        col: line.indexOf(trimmed[0]) + 1,
      };
    }

    // ── 有序列表 ──
    const olMatch = matchOrderedStart(trimmed);
    if (olMatch) {
      return {
        type: TokenType.OrderedListMarker,
        raw: line,
        line: lineNum,
        col: line.indexOf(trimmed[0]) + 1,
        meta: { orderedStart: olMatch.num },
      };
    }

    // ── 任务列表 ──
    const taskMatch = trimmed.match(/^\s*[-*+]\s+\[([ xX])\]\s+/);
    if (taskMatch) {
      return {
        type: TokenType.TaskMarker,
        raw: line,
        line: lineNum,
        col: line.indexOf(taskMatch[0]) + 1,
        meta: { taskChecked: taskMatch[1].toLowerCase() === 'x' },
      };
    }

    // ── GFM 表格 ──
    if (trimmed.includes('|')) {
      // 表格分隔行：  | :--- | :--: | ---: |
      const divMatch = trimmed.match(/^\|?[\s:]?-{3,}[\s:]?(?:\|[\s:]?-{3,}[\s:]?)+\|?$/);
      if (divMatch) {
        const aligns = this.parseTableAligns(trimmed);
        return {
          type: TokenType.TableDivider,
          raw: line,
          line: lineNum,
          col: 1,
          meta: { aligns },
        };
      }
      // 普通表格行（有至少两个单元格）
      const cells = trimmed.split('|').filter(c => c.trim().length > 0);
      if (cells.length >= 2) {
        return {
          type: TokenType.TableRow,
          raw: line,
          line: lineNum,
          col: 1,
        };
      }
    }

    // ── 缩进代码块（4个空格或1个制表符）──
    // 留到解析阶段处理

    // ── 默认：段落 ──
    return { type: TokenType.Paragraph, raw: line, line: lineNum, col: 1 };
  }

  /** 解析表格分隔符对齐方式 */
  private parseTableAligns(line: string): AlignType[] {
    const parts = line.split('|').filter(p => p.trim().length > 0);
    return parts.map(p => {
      const cell = p.trim();
      const left = cell.startsWith(':');
      const right = cell.endsWith(':');
      if (left && right) return AlignType.Center;
      if (right) return AlignType.Right;
      if (left) return AlignType.Left;
      return AlignType.None;
    });
  }

  /** 获取围栏代码块全部内容（含结束标记检测） */
  consumeFenceContent(fenceChar: string, fenceLen: number): { code: string; endLine: number } {
    const codeLines: string[] = [];
    while (this.pos < this.lineCount) {
      this.pos++;
      if (this.pos >= this.lineCount) break;
      const line = this.lines[this.pos];
      const trimmed = line.trim();
      // 检测结束标记：相同或更多的围栏字符
      if (trimmed.startsWith(fenceChar) && isAllChar(trimmed, fenceChar[0])) {
        return { code: codeLines.join('\n'), endLine: this.pos + 1 };
      }
      codeLines.push(line);
    }
    return { code: codeLines.join('\n'), endLine: this.pos + 1 };
  }

  /** 获取引用块内容（多层嵌套时递归） */
  getQuoteContent(startLine: number): string[] {
    const quoteLines: string[] = [];
    let i = startLine;
    while (i < this.lineCount) {
      const line = this.lines[i];
      const trimmed = trimStart(line);
      if (trimmed.startsWith('>')) {
        quoteLines.push(trimmed.replace(/^>\s?/, ''));
        i++;
      } else if (line.trim() === '') {
        // 空行后如果还有引用则继续
        quoteLines.push('');
        i++;
        if (i < this.lineCount) {
          const next = trimStart(this.lines[i]);
          if (!next.startsWith('>')) break;
        }
      } else {
        break;
      }
    }
    return quoteLines;
  }

  /** 获取缩进代码块 */
  getIndentedCode(startLine: number): string[] {
    const codeLines: string[] = [];
    let i = startLine;
    while (i < this.lineCount) {
      const line = this.lines[i];
      if (line.trim() === '') {
        codeLines.push('');
        i++;
      } else if (leadingSpaces(line) >= 4) {
        codeLines.push(line.slice(Math.min(leadingSpaces(line), 4)));
        i++;
      } else {
        break;
      }
    }
    return codeLines;
  }
}

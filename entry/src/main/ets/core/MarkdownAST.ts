/**
 * Markdown AST 节点类型定义
 *
 * 完整的节点类型体系，覆盖 GFM (GitHub Flavored Markdown) 子集。
 * 所有节点通过 type 区分，children 表示子节点，textContent 缓存文本内容。
 */

// ─── 节点类型枚举 ─────────────────────────────────

/** 块级节点类型 */
export enum BlockType {
  Document = 'document',
  Paragraph = 'paragraph',
  Heading = 'heading',
  Blockquote = 'blockquote',
  List = 'list',
  ListItem = 'listItem',
  CodeBlock = 'codeBlock',
  Table = 'table',
  TableRow = 'tableRow',
  TableCell = 'tableCell',
  ThematicBreak = 'thematicBreak',
  HtmlBlock = 'htmlBlock',
  MathBlock = 'mathBlock',
}

/** 行内节点类型 */
export enum InlineType {
  Text = 'text',
  Bold = 'bold',
  Italic = 'italic',
  Strikethrough = 'strikethrough',
  InlineCode = 'inlineCode',
  Link = 'link',
  Image = 'image',
  AutoLink = 'autoLink',
  LineBreak = 'lineBreak',
  HtmlInline = 'htmlInline',
  MathInline = 'mathInline',
}

// ─── 列表类型 ─────────────────────────────────────

export enum ListType {
  Unordered = 'unordered',
  Ordered = 'ordered',
  Task = 'task',
}

// ─── 表格对齐方式 ─────────────────────────────────

export enum AlignType {
  Left = 'left',
  Center = 'center',
  Right = 'right',
  None = 'none',
}

// ─── 节点接口 ─────────────────────────────────────

/** 基础节点接口 */
export interface BaseNode {
  type: string;
  children?: ASTNode[];
  /** 纯文本表示（渲染时未必直接用，但调试有用） */
  textContent?: string;
  /** 源代码位置（可选，用于错误定位） */
  sourcePos?: { start: number; end: number };
}

/** 段落节点 */
export interface ParagraphNode extends BaseNode {
  type: BlockType.Paragraph;
  children: InlineNode[];
}

/** 标题节点 */
export interface HeadingNode extends BaseNode {
  type: BlockType.Heading;
  level: number; // 1-6
  children: InlineNode[];
}

/** 引用节点 */
export interface BlockquoteNode extends BaseNode {
  type: BlockType.Blockquote;
  children: BlockNode[];
}

/** 列表节点 */
export interface ListNode extends BaseNode {
  type: BlockType.List;
  listType: ListType;
  orderedStart?: number; // 有序列表起始数字
  tight: boolean; // 紧凑列表
  children: ListItemNode[];
}

/** 列表项节点 */
export interface ListItemNode extends BaseNode {
  type: BlockType.ListItem;
  checked?: boolean; // 任务列表
  children: BlockNode[];
}

/** 代码块节点 */
export interface CodeBlockNode extends BaseNode {
  type: BlockType.CodeBlock;
  lang?: string; // 语言标识
  code: string; // 原始代码文本
}

/** 分割线节点 */
export interface ThematicBreakNode extends BaseNode {
  type: BlockType.ThematicBreak;
}

/** HTML 块节点 */
export interface HtmlBlockNode extends BaseNode {
  type: BlockType.HtmlBlock;
  html: string;
}

/** 数学公式块节点 ($$...$$) */
export interface MathBlockNode extends BaseNode {
  type: BlockType.MathBlock;
  formula: string;
}

/** 表格节点 */
export interface TableNode extends BaseNode {
  type: BlockType.Table;
  aligns: AlignType[];
  header: TableRowNode;
  rows: TableRowNode[];
}

/** 表格行节点 */
export interface TableRowNode extends BaseNode {
  type: BlockType.TableRow;
  children: TableCellNode[];
}

/** 表格单元节点 */
export interface TableCellNode extends BaseNode {
  type: BlockType.TableCell;
  align: AlignType;
  children: InlineNode[];
}

// ─── 行内节点 ─────────────────────────────────────

export interface TextNode extends BaseNode {
  type: InlineType.Text;
  content: string;
}

export interface BoldNode extends BaseNode {
  type: InlineType.Bold;
  children: InlineNode[];
}

export interface ItalicNode extends BaseNode {
  type: InlineType.Italic;
  children: InlineNode[];
}

export interface StrikethroughNode extends BaseNode {
  type: InlineType.Strikethrough;
  children: InlineNode[];
}

export interface InlineCodeNode extends BaseNode {
  type: InlineType.InlineCode;
  content: string;
}

export interface LinkNode extends BaseNode {
  type: InlineType.Link;
  url: string;
  title?: string;
  children: InlineNode[];
}

export interface ImageNode extends BaseNode {
  type: InlineType.Image;
  url: string;
  alt: string;
  title?: string;
}

export interface AutoLinkNode extends BaseNode {
  type: InlineType.AutoLink;
  url: string;
}

export interface LineBreakNode extends BaseNode {
  type: InlineType.LineBreak;
}

export interface HtmlInlineNode extends BaseNode {
  type: InlineType.HtmlInline;
  html: string;
}

/** 行内数学公式节点 ($...$) */
export interface MathInlineNode extends BaseNode {
  type: InlineType.MathInline;
  formula: string;
}

// ─── 联合类型 ─────────────────────────────────────

export type BlockNode =
  | ParagraphNode
  | HeadingNode
  | BlockquoteNode
  | ListNode
  | ListItemNode
  | CodeBlockNode
  | TableNode
  | TableRowNode
  | TableCellNode
  | ThematicBreakNode
  | HtmlBlockNode
  | MathBlockNode
  | DocumentNode;

export type InlineNode =
  | TextNode
  | BoldNode
  | ItalicNode
  | StrikethroughNode
  | InlineCodeNode
  | LinkNode
  | ImageNode
  | AutoLinkNode
  | LineBreakNode
  | HtmlInlineNode
  | MathInlineNode;

export type ASTNode = BlockNode | InlineNode;

/** 文档根节点 */
export interface DocumentNode extends BaseNode {
  type: BlockType.Document;
  children: BlockNode[];
}

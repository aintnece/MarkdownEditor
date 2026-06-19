/**
 * 简易 LaTeX 转 Unicode 转换器
 *
 * 在 HTML 渲染前处理常见 LaTeX 命令使其显示为 Unicode 字符。
 * KaTeX (CDN) 加载后覆盖渲染为高质量公式，此转换作为离线回退。
 */

/** 查找 LaTeX 命令对应的 Unicode 字符 */
function lookupLatex(cmd: string): string {
  if (cmd === '\\int') return '∫';
  if (cmd === '\\iint') return '∬';
  if (cmd === '\\iiint') return '∭';
  if (cmd === '\\oint') return '∮';
  if (cmd === '\\sum') return '∑';
  if (cmd === '\\prod') return '∏';
  if (cmd === '\\infty') return '∞';
  if (cmd === '\\partial') return '∂';
  if (cmd === '\\nabla') return '∇';
  if (cmd === '\\emptyset') return '∅';
  if (cmd === '\\forall') return '∀';
  if (cmd === '\\exists') return '∃';
  if (cmd === '\\in') return '∈';
  if (cmd === '\\notin') return '∉';
  if (cmd === '\\subset') return '⊂';
  if (cmd === '\\subseteq') return '⊆';
  if (cmd === '\\supset') return '⊃';
  if (cmd === '\\supseteq') return '⊇';
  if (cmd === '\\cup') return '∪';
  if (cmd === '\\cap') return '∩';
  if (cmd === '\\wedge') return '∧';
  if (cmd === '\\vee') return '∨';
  if (cmd === '\\neg') return '¬';
  if (cmd === '\\rightarrow') return '→';
  if (cmd === '\\leftarrow') return '←';
  if (cmd === '\\Rightarrow') return '⇒';
  if (cmd === '\\to') return '→';
  if (cmd === '\\mapsto') return '↦';
  if (cmd === '\\approx') return '≈';
  if (cmd === '\\equiv') return '≡';
  if (cmd === '\\sim') return '∼';
  if (cmd === '\\propto') return '∝';
  if (cmd === '\\cong') return '≅';
  if (cmd === '\\neq') return '≠';
  if (cmd === '\\leq') return '≤';
  if (cmd === '\\geq') return '≥';
  if (cmd === '\\pm') return '±';
  if (cmd === '\\mp') return '∓';
  if (cmd === '\\times') return '×';
  if (cmd === '\\div') return '÷';
  if (cmd === '\\cdot') return '·';
  if (cmd === '\\perp') return '⊥';
  if (cmd === '\\parallel') return '∥';
  if (cmd === '\\angle') return '∠';
  if (cmd === '\\triangle') return '△';
  if (cmd === '\\oplus') return '⊕';
  if (cmd === '\\otimes') return '⊗';
  if (cmd === '\\dots') return '…';
  if (cmd === '\\cdots') return '⋯';
  if (cmd === '\\vdots') return '⋮';
  if (cmd === '\\ddots') return '⋱';
  if (cmd === '\\prime') return '′';
  if (cmd === '\\hbar') return 'ℏ';
  if (cmd === '\\ell') return 'ℓ';
  if (cmd === '\\Re') return 'ℜ';
  if (cmd === '\\Im') return 'ℑ';
  if (cmd === '\\aleph') return 'ℵ';
  if (cmd === '\\surd') return '√';
  // Thin spaces
  if (cmd === '\\,') return ' ';
  if (cmd === '\\:') return ' ';
  if (cmd === '\\;') return ' ';
  if (cmd === '\\!') return '';
  if (cmd === '\\quad') return '  ';
  if (cmd === '\\qquad') return '    ';
  // Styling commands (strip them)
  if (cmd === '\\left' || cmd === '\\right') return '';
  if (cmd === '\\text' || cmd === '\\mathrm' || cmd === '\\mathbf') return '';
  if (cmd === '\\mathit' || cmd === '\\mathbb' || cmd === '\\mathcal') return '';
  if (cmd === '\\displaystyle' || cmd === '\\textstyle') return '';
  // Function names (just return the text without backslash)
  if (cmd === '\\sin' || cmd === '\\cos' || cmd === '\\tan') return cmd.slice(1);
  if (cmd === '\\cot' || cmd === '\\sec' || cmd === '\\csc') return cmd.slice(1);
  if (cmd === '\\log' || cmd === '\\ln' || cmd === '\\lg') return cmd.slice(1);
  if (cmd === '\\exp' || cmd === '\\det' || cmd === '\\dim') return cmd.slice(1);
  if (cmd === '\\lim' || cmd === '\\sup' || cmd === '\\inf') return cmd.slice(1);
  if (cmd === '\\max' || cmd === '\\min' || cmd === '\\arg' || cmd === '\\deg') return cmd.slice(1);
  // Greek uppercase
  if (cmd === '\\Gamma') return 'Γ';
  if (cmd === '\\Delta') return 'Δ';
  if (cmd === '\\Theta') return 'Θ';
  if (cmd === '\\Lambda') return 'Λ';
  if (cmd === '\\Xi') return 'Ξ';
  if (cmd === '\\Pi') return 'Π';
  if (cmd === '\\Sigma') return 'Σ';
  if (cmd === '\\Phi') return 'Φ';
  if (cmd === '\\Psi') return 'Ψ';
  if (cmd === '\\Omega') return 'Ω';
  // Greek lowercase - single letter commands (after backslash)
  // These are all followed by a non-letter character, matched by regex
  if (cmd === '\\alpha') return 'α';
  if (cmd === '\\beta') return 'β';
  if (cmd === '\\gamma') return 'γ';
  if (cmd === '\\delta') return 'δ';
  if (cmd === '\\epsilon') return 'ε';
  if (cmd === '\\zeta') return 'ζ';
  if (cmd === '\\eta') return 'η';
  if (cmd === '\\theta') return 'θ';
  if (cmd === '\\iota') return 'ι';
  if (cmd === '\\kappa') return 'κ';
  if (cmd === '\\lambda') return 'λ';
  if (cmd === '\\mu') return 'μ';
  if (cmd === '\\nu') return 'ν';
  if (cmd === '\\xi') return 'ξ';
  if (cmd === '\\pi') return 'π';
  if (cmd === '\\rho') return 'ρ';
  if (cmd === '\\sigma') return 'σ';
  if (cmd === '\\tau') return 'τ';
  if (cmd === '\\upsilon') return 'υ';
  if (cmd === '\\phi') return 'φ';
  if (cmd === '\\chi') return 'χ';
  if (cmd === '\\psi') return 'ψ';
  if (cmd === '\\omega') return 'ω';
  return ''; // Unknown command, strip it
}

/** 将 LaTeX 公式文本转换为带 Unicode 的简易文本 */
export function latexToUnicode(latex: string): string {
  let result: string = latex;

  // 处理 \frac{a}{b} → (a)/(b)
  result = result.replace(/\\frac\s*\{([^}]*)\}\s*\{([^}]*)\}/g, '($1)/($2)');

  // 处理 \sqrt[n]{x} → √(x)
  result = result.replace(/\\sqrt(?:\[([^\]]*)\])?\s*\{([^}]*)\}/g, '√($2)');

  // 处理上标 ^{...} → ^(...)
  result = result.replace(/\^\{([^}]*)\}/g, '^($1)');
  // 处理下标 _{...} → _(...)
  result = result.replace(/\_\{([^}]*)\}/g, '_($1)');
  // 单个字符上标
  result = result.replace(/\^([a-zA-Z0-9])/g, '^($1)');
  // 单个字符下标
  result = result.replace(/\_([a-zA-Z0-9])/g, '_($1)');

  // 替换已知 LaTeX 命令
  // 匹配所有 \command 模式
  result = result.replace(/\\([a-zA-Z]+)/g, (_m: string, name: string) => {
    return lookupLatex('\\' + name);
  });

  // 替换 \, \; \: \! \quad 等特殊命令
  result = result.replace(/\\([,;:!])/g, (_m: string, ch: string) => {
    return lookupLatex('\\' + ch);
  });

  // 清理残留的花括号
  result = result.replace(/[\{\}]/g, '');

  return result;
}

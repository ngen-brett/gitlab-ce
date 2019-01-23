/* eslint-disable class-methods-use-this */

import { CodeBlock as BaseCodeBlock } from 'tiptap-extensions';

const PLAINTEXT_LANG = 'plaintext';

// Transforms generated HTML back to GFM for:
// - Banzai::Filter::SyntaxHighlightFilter
// - Banzai::Filter::MathFilter
// - Banzai::Filter::MermaidFilter
export default class CodeBlock extends BaseCodeBlock {
  get schema() {
    return {
      content: 'text*',
      marks: '',
      group: 'block',
      code: true,
      defining: true,
      attrs: {
        lang: { default: PLAINTEXT_LANG },
      },
      parseDOM: [
        // Matches HTML generated by Banzai::Filter::SyntaxHighlightFilter, Banzai::Filter::MathFilter or Banzai::Filter::MermaidFilter
        {
          tag: 'pre.code.highlight',
          preserveWhitespace: 'full',
          getAttrs: el => {
            const lang = el.getAttribute('lang');
            if (!lang || lang === '') return {};

            return { lang };
          },
        },
        // Matches HTML generated by Banzai::Filter::MathFilter,
        // after being transformed by app/assets/javascripts/behaviors/markdown/render_math.js
        {
          tag: 'span.katex-display',
          preserveWhitespace: 'full',
          contentElement: 'annotation[encoding="application/x-tex"]',
          attrs: { lang: 'math' },
        },
        // Matches HTML generated by Banzai::Filter::MathFilter,
        // after being transformed by app/assets/javascripts/behaviors/markdown/render_mermaid.js
        {
          tag: 'svg.mermaid',
          preserveWhitespace: 'full',
          contentElement: 'text.source',
          attrs: { lang: 'mermaid' }
        }
      ],
      toDOM: node => ['pre', { class: 'code highlight', lang: node.attrs.lang }, ['code', 0]],
    };
  }

  toMarkdown(state, node) {
    if (!node.childCount) return;

    const { textContent: text, attrs: { lang } } = node;

    // Prefixes lines with 4 spaces if the code contains a line that starts with triple backticks
    if (lang === PLAINTEXT_LANG && text.match(/^```/gm)) {
      state.wrapBlock('    ', null, node, () => state.text(text, false));
      return;
    }

    state.write('```');
    if (lang !== PLAINTEXT_LANG) state.write(lang);

    state.ensureNewLine();
    state.text(text, false);
    state.ensureNewLine();

    state.write('```');
    state.closeBlock(node);
  }
}

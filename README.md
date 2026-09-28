# h_da Thesis Template for Typst

An independent native Typst thesis template informed by [Trigus42/thesis-template](https://github.com/Trigus42/thesis-template), a fork of the upstream [mbredel/thesis-template](https://github.com/mbredel/thesis-template). It implements the layout directly in Typst rather than using a generic ClassicThesis package.

## Build

```sh
mise install
mise run build
```

The output is `thesis.pdf`. Use `mise run watch` while writing.

## Configure

Edit the arguments to `thesis.with(...)` in `thesis.typ`. Content is split between `chapters/`, `frontmatter/`, `assets/`, and `bibliography.bib`.

The reusable API supports German and English labels, thesis metadata, optional subtitle, declaration, abstracts, contents and float lists, acronyms, glossary, bibliography, part pages, appendix numbering, margin notes, theorem/proof blocks, and ClassicThesis-style headings.

Start appendices with `#appendix()` followed by `#set heading(numbering: "A.1")`. The stateful call resets chapter numbering and switches float prefixes; the set rule controls heading and outline labels from that point onward.

## Visual Review

The optional macOS tools can render a PDF into page images and submit those images to any OpenAI-compatible multimodal endpoint:

```sh
swift tools/render-pdf.swift thesis.pdf review/pages
OPENAI_BASE_URL=... OPENAI_API_KEY=... OPENAI_MODEL=... \
  swift tools/visual-review.swift "Review the document layout." review/pages/*.png
```

The endpoint, credentials, model, prompt, and image selection are intentionally left to the caller.

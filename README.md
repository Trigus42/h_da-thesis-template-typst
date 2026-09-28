# h_da Thesis Template for Typst

An independent native Typst thesis template informed by [Trigus42/thesis-template](https://github.com/Trigus42/thesis-template), a fork of the upstream [mbredel/thesis-template](https://github.com/mbredel/thesis-template). It implements the layout directly in Typst rather than using a generic ClassicThesis package.

## Build

```sh
mise install
mise run build
```

The output is `thesis.pdf`. Use `mise run watch` while writing.

## Configure

Edit the arguments to `thesis.with(...)` in `thesis.typ`. Content is split between `chapters/`, `frontmatter/`, `assets/`, and `bibliography.bib`. The declaration, abbreviations, and glossary live in their own files under `frontmatter/`.

The reusable API supports German and English labels, thesis metadata, optional subtitle, declaration, abstracts, contents and float lists, acronyms, glossary, bibliography, part pages, appendix numbering, margin notes, theorem/proof blocks, and ClassicThesis-style headings. Import `thesis-table` and `thesis-listing` for captioned tables and source listings; both forward native `figure` options such as `placement` and `outlined`.

Start appendices with `#appendix()`. It resets chapter numbering and switches heading, outline, and float labels to alphabetic chapter prefixes.

`acronyms` and `glossary` are arrays of two-item arrays, for example `(("API", "Application Programming Interface"),)`. Omit optional text with `none`; required metadata must be non-empty strings. Part pages and table, listing, theorem, and proof labels follow the thesis language automatically.

## Visual Review

The optional macOS tools can render a PDF into page images and submit those images to any OpenAI-compatible multimodal endpoint:

```sh
swift tools/render-pdf.swift thesis.pdf review/pages
OPENAI_BASE_URL=... OPENAI_API_KEY=... OPENAI_MODEL=... \
  swift tools/visual-review.swift "Review the document layout." review/pages/*.png
```

The endpoint, credentials, model, prompt, and image selection are intentionally left to the caller.

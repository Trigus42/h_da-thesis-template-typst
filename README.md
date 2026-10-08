# h_da Thesis Template for Typst

An independent native Typst thesis template informed by [Trigus42/h_da-thesis-template](https://github.com/Trigus42/h_da-thesis-template), a fork of [mbredel/thesis-template](https://github.com/mbredel/thesis-template). It implements the layout directly in Typst rather than using a generic ClassicThesis package.

> [!IMPORTANT]
> **No Support** — This project is built and maintained strictly for my personal work. It is shared in case it is useful to others, but I do not offer technical support, troubleshooting, or feature maintenance.

## Build

```sh
mise install
mise run build
```

The output is `thesis.pdf`. Use `mise run watch` while writing.

To update a thesis repository with the latest template changes, run:

```sh
mise run update-template
```

This fetches the template's `main` branch directly from GitHub and rebases the current branch onto it. Uncommitted changes are temporarily stashed and restored automatically; resolve any conflicts before continuing.

## Configure

Set thesis metadata in `thesis.with(...)` at the top of `thesis.typ`; the body of `thesis.typ` then includes each section in reading order. Content is split between `chapters/` (the body) and `matter/` (front- and back-matter sections), plus `assets/` and `bibliography.bib`.

Each front- and back-matter section owns its own title and layout in its file under `matter/`, and `thesis.typ` decides whether it appears before or after the chapters. Edit each section where it is read:

- `declaration.typ` renders its heading, body, and signature block; `#thesis-info(data => ...)` supplies the author, location, and date.
- `blocking-notice.typ` contains the optional confidentiality notice; uncomment its include in `thesis.typ` when required.
- `abstract-en.typ` and `abstract-de.typ` set their own language and heading.
- `abbreviations.typ` defines the acronyms and prints the ones referenced with `#acronym("API")`.
- `glossary.typ` defines and prints the glossary.
- `bibliography.typ` prints the bibliography from `bibliography.bib`.

To reorder or omit a section, move or comment out its `#include` in `thesis.typ`. The abbreviation and glossary lists only show entries actually referenced through Glossarium; referencing an undefined entry is a compile error.

The line above the degree on the title page is omitted unless you set `degree-line` in `thesis.with(...)`. Pass `degree-line: auto` for the language default, or a string to set custom wording; omitting the parameter (like `second-supervisor`) leaves the line out.

The reusable document options in `thesis.with(...)` include:

- `two-sided`: uses mirrored `inside` and `outside` margins for duplex printing.
- `open-right`: starts parts and numbered chapters on odd pages, inserting blank pages when necessary; this requires `two-sided: true`.
- `line-spacing`: controls line spacing and defaults to the reference template's `1.5` setting.
- `description` and `keywords`: populate the corresponding PDF metadata fields.

`#outlines(figures: ..., tables: ..., listings: ...)` controls the three float lists independently. Each enabled list is still omitted automatically when no matching figures exist.

`template.typ` provides the reusable pieces: `thesis` (metadata, page layout, German/English labels for the outlines and automatic labels), `mainmatter` (starts Arabic body pagination and running headers), `outlines` (contents and float lists), `part`, `appendix`, `unnumbered-heading`, `thesis-info`, `acronym`/`acronyms-used`, `glossary-used`, `margin-note`, and `thesis-table`/`thesis-listing` for captioned tables and source listings (both forward native `figure` options such as `placement` and `outlined`). The front matter uses Roman page numbers. Theorem and proof environments come from the pinned `ctheorems` package imported in `thesis.typ` and the chapter that uses them.

Subfigures use the pinned `subpar` package. Its `subpar.grid` helper provides individual captions, labels, and references while retaining one parent figure and caption.

Start appendices with `#appendix()`. It resets chapter numbering and switches heading, outline, and float labels to alphabetic chapter prefixes.

Acronym and glossary definitions are arrays of two-item arrays, for example `(("API", "Application Programming Interface"),)`. Optional metadata may be `none`; required metadata must be non-empty strings. Part pages and table, listing, theorem, and proof labels follow the thesis language automatically.

## Visual Review

The optional macOS tools can render a PDF into page images and submit those images to any OpenAI-compatible multimodal endpoint:

```sh
swift tools/render-pdf.swift thesis.pdf review/pages
OPENAI_BASE_URL=... OPENAI_API_KEY=... OPENAI_MODEL=... \
  swift tools/visual-review.swift "Review the document layout." review/pages/*.png
```

The endpoint, credentials, model, prompt, and image selection are intentionally left to the caller.

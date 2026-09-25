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

## Visual Regression

```sh
REFERENCE_PDF=/path/to/reference.pdf mise run compare
```

On macOS this matches pages by semantic text anchors, rasterizes complete pages at identical dimensions and 72 DPI, and writes `comparison/index.html`. The report includes side-by-side pages, a red/blue ink overlay, strict zero-tolerance differences, anti-aliasing-resistant perceptual differences, ink bounds, and translation diagnostics. Chapter pages additionally report heading, numeral, and body regions, so missing or malformed chapter numbers cannot disappear into a whole-page average.

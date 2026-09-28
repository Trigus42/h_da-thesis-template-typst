# Contributor Guidelines

## Scope

- This is an independent native Typst thesis template informed by [Trigus42/thesis-template](https://github.com/Trigus42/thesis-template), a fork of [mbredel/thesis-template](https://github.com/mbredel/thesis-template), not a generic ClassicThesis implementation.
- Use the Trigus42 fork as the direct visual and behavioral reference while crediting mbredel's repository as the upstream project; do not imply source-code derivation.
- Preserve the split between reusable layout (`template.typ`), configuration (`thesis.typ`), content, and assets.

## Implementation

- Prefer small, direct Typst changes over new abstractions or dependencies.
- Use normal installed fonts. Do not extract glyphs or fonts from the reference PDF.
- Keep chapter openings restrained: large gray margin numeral, black tracked title, thin rule, and no stale running header.
- Preserve numbered section hierarchy, Roman part labels, alphabetic appendices, and chapter-scoped float labels such as `3.1` and `B.1`.
- Keep margin notes clear of chapter numerals and page edges.
- Do not delete or broadly replace the project when refining it.

## Validation

- Use the pinned toolchain through `mise`; run `mise run check` after changes.
- For layout changes, render representative pages and inspect them directly; optional visual-review tooling is available under `tools/`.
- Aim for close, polished visual similarity rather than pixel-perfect output.
- Check representative pages: title, declaration, abstracts, contents/lists, part pages, chapter openings, appendix floats, glossary, and bibliography.
- Pay particular attention to visible/clipped numerals, heading placement, text-block margins, page-number leakage, overlaps, and appendix numbering.

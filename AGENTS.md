# Agent Guidance

## Document-Specific Guidance

<!-- Add rules for this thesis document here after copying the template. -->

## Template Guidance

### Project Context

- This repository contains a polished native Typst thesis template informed by [Trigus42/thesis-template](https://github.com/Trigus42/thesis-template), a fork of [mbredel/thesis-template](https://github.com/mbredel/thesis-template). It is not a generic ClassicThesis implementation.
- The guidance under "Template Guidance" concerns the reusable template. It is not document-specific guidance for a thesis created from this repository.
- Use the Trigus42 fork as the direct visual and behavioral reference while crediting mbredel's repository as the upstream project; do not imply source-code derivation.
- Favor correctness, clarity, and maintainability over cleverness, abstraction, or line-count reduction.
- Preserve the split between reusable layout (`template.typ`), configuration (`thesis.typ`), content, and assets.

### Implementation

- Prefer small, direct, idiomatic Typst changes over helpers, state machines, or custom rendering.
- Do not hand-roll functionality that Typst's standard library or a mature, actively maintained Typst package already provides well. Check Typst Universe before implementing document infrastructure such as glossaries, acronyms, theorem systems, citations, indexes, or advanced counters; use a pinned package version unless a documented project-specific requirement makes the package unsuitable.
- Preserve native Typst behavior for headings, figures, references, outlines, counters, and selectors unless a verified limitation requires a narrow workaround.
- Use semantic intermediate variables when they explain intent, such as `indent`, `chapter-title`, or `floats-in-chapter`. Do not inline meaningful calculations merely to reduce lines.
- Do not introduce aliases for already-readable Typst expressions such as `figure.where(kind: image)` unless reuse or abstraction materially improves the code.
- When reconciling prior work, compare behavior and keep the simplest robust solution; do not stack compensating mechanisms for state, counters, references, or outlines.
- Use normal installed fonts. Do not extract glyphs or fonts from the reference PDF.
- Keep chapter openings restrained: large gray margin numeral, black tracked title, thin rule, and no stale running header.
- Preserve numbered section hierarchy, Roman part labels, alphabetic appendices, and chapter-scoped float labels such as `3.1` and `B.1`.
- Keep captions, references, contents, and float lists consistent in normal chapters and appendices.
- Keep margin notes clear of chapter numerals and page edges.
- Do not delete or broadly replace the project when refining it.

### Validation

- Use the pinned toolchain through `mise`; run `mise run check` after changes.
- For substantial visual changes, render representative pages with `tools/render-pdf.swift` and review them through `tools/visual-review.swift` using a capable vision model. Do not inspect or interpret page images directly.
- Aim for close, polished visual similarity rather than pixel-perfect output.
- Check representative pages: title, declaration, abstracts, contents/lists, part pages, chapter openings, appendix floats, glossary, and bibliography.
- Verify labels across captions, references, contents, and float lists, not merely successful compilation.
- Pay particular attention to clipped numerals, heading placement, text-block margins, page-number leakage, overlaps, stale headers, and appendix numbering.

### Commits

- Use Conventional Commit subjects in the form `type(scope): description`.
- Scope reusable template changes by template area, using path-like scopes such as `template/glossary`; keep document-specific changes scoped separately.

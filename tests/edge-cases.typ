#import "../template.typ": thesis, mainmatter, outlines, appendix, part, thesis-listing, thesis-table
#import "../template.typ": acronym, acronyms-used
#import "../template.typ": float-number, heading-number-at, part-entry
#import "@preview/glossarium:0.5.10": make-glossary, register-glossary
#import "@preview/ctheorems:2.0.0": thm-rules

#let abbreviations = ((key: "api", short: "API", long: "Application Programming Interface"),)
#register-glossary(abbreviations)

#show: thesis.with(
  title: "Edge Cases",
  author: "Test Author",
  supervisor: "Test Supervisor",
  faculty: "Test Faculty",
  university: "Test University",
  location: "Test Location",
  date: "28 September 2026",
  language: "en",
)
#show: make-glossary
#show: thm-rules.with(qed-symbol: sym.square.stroked)

#outlines()
#acronyms-used("Abbreviations", abbreviations)
#mainmatter()

#part("Body")

// Compile-time checks for the numbering assigned at each labeled element. These
// resolve the number at the target's own location, so a regression in
// chapter-scoped, appendix, or query-derived numbering fails the build instead
// of silently producing a wrong label.
#let expect-heading(label, value) = context assert.eq(
  str(heading-number-at(query(label).first().location())),
  value,
  message: "heading " + repr(label) + " expected " + value,
)
#let expect-float(label, kind, value) = context assert.eq(
  str(float-number(figure.where(kind: kind), query(label).first().location())),
  value,
  message: "float " + repr(label) + " expected " + value,
)

#figure(rect(width: 20mm, height: 10mm), caption: [Before the first chapter]) <preface-figure>

= First Chapter <first-chapter>

== A Section <first-section>

The #acronym("api") is linked to its abbreviation entry. Later uses show #acronym("api").

#figure(rect(width: 20mm, height: 10mm), caption: [First chapter figure]) <first-figure>
#figure(rect(width: 20mm, height: 10mm), caption: [Excluded from the outline], outlined: false)

#figure(
  table(columns: 2, [Raw], [Table]),
  caption: [A raw table figure],
) <raw-table>

// A bare figure wrapping a raw block (kind: raw). Its caption and reference must
// agree on the chapter-scoped listing number.
#figure(
  raw("let answer = 42", lang: "typ"),
  caption: [A raw code figure],
) <raw-figure>

#thesis-table(
  table(columns: 2, [A], [B]),
  caption: [A table],
  outlined: false,
) <thesis-table-ref>

#thesis-listing(
  raw("let answer = 42", lang: "typ"),
  caption: [A listing],
  outlined: false,
) <thesis-listing-ref>

= Second Chapter <second-chapter>

#figure(rect(width: 20mm, height: 10mm), caption: [Second chapter figure])

// Header selection must stay within the current chapter. The second chapter has
// no sections, so a continuation page must fall back to its chapter heading
// rather than selecting the following appendix section.
#pagebreak()
#lorem(180)
#metadata(none) <second-chapter-continuation>

#part("Appendix")
#appendix()

= Appendix Chapter <appendix-chapter>

== Later Appendix Section

#figure(rect(width: 20mm, height: 10mm), caption: [Appendix figure]) <appendix-figure>

// Auto-supplement references to figures of every managed kind.
References: @preface-figure, @first-figure, @raw-table, @raw-figure, and @appendix-figure.

// Labeled thesis-table and thesis-listing must be referenceable (they are not
// wrapped in a context node) and localized.
Custom floats: @thesis-table-ref and @thesis-listing-ref.

// Heading references across the appendix boundary must resolve the number at the
// heading's location, not at the reference's location.
Headings: @first-chapter, @first-section, @second-chapter, and @appendix-chapter.

// Non-auto supplements must still use the target's number, not the reference's.
Custom supplement: #ref(<first-figure>, supplement: [Abb.]).
Suppressed supplement: #ref(<first-figure>, supplement: none).

// Numbering assertions.
#expect-heading(<first-chapter>, "1")
#expect-heading(<first-section>, "1.1")
#expect-heading(<second-chapter>, "2")
#expect-heading(<appendix-chapter>, "A")
#expect-float(<preface-figure>, image, "1")
#expect-float(<first-figure>, image, "1.1")
#expect-float(<raw-table>, table, "1.1")
#expect-float(<raw-figure>, raw, "1.1")
#expect-float(<thesis-table-ref>, table, "1.2")
#expect-float(<thesis-listing-ref>, "listing", "1.1")
#expect-float(<appendix-figure>, image, "A.1")

// Parts must be recorded in reading order with roman numerals so the contents
// outline can interleave them; a regression here breaks the part rows in the ToC.
#context {
  let parts = query(part-entry).map(it => (it.value.number, it.value.title))
  assert.eq(parts, (("I", "Body"), ("II", "Appendix")), message: "part entries: " + repr(parts))
}

// Glossarium emits the abbreviation destination and links every use to it.
#context {
  let entry = query(<api>).first()
  let first-use = query(label("__gls:api")).first()
  assert.eq(query(link.where(dest: <api>)).len(), 2, message: "acronym uses are not linked to the abbreviation entry")
  assert.eq(query(link.where(dest: first-use.location())).len(), 1, message: "abbreviation entry does not link to its first use")
  assert(entry.func() == figure, message: "Glossarium did not emit the abbreviation entry")
}

// The running header must actually be bound to the body pages (the defect that
// dropped every header and folio bound it only inside a non-propagating block;
// an unbound header stays at its `auto` default rather than our function).
#context assert(
  page.header not in (auto, none),
  message: "running header is not bound on body pages: " + repr(page.header),
)

#context {
  let second-chapter = query(<second-chapter>).first()
  let appendix-chapter = query(<appendix-chapter>).first()
  let sections = query(
    heading.where(level: 2)
      .after(second-chapter.location())
      .before(appendix-chapter.location()),
  ).filter(it => it.numbering != none)
  assert.eq(sections, (), message: "later chapter sections leaked into the second chapter")
}

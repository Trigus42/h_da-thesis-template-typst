#import "../template.typ": thesis, mainmatter, outlines, appendix, thesis-listing, thesis-table
#import "../template.typ": float-number, heading-number-at

#show: thesis.with(
  title: "Edge Cases",
  author: "Test Author",
  degree: "Bachelor of Science",
  supervisor: "Test Supervisor",
  faculty: "Test Faculty",
  university: "Test University",
  location: "Test Location",
  date: "28 September 2026",
  language: "en",
)

#outlines()
#mainmatter()

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

#appendix()

= Appendix Chapter <appendix-chapter>

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

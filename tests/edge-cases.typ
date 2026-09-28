#import "../template.typ": thesis, appendix, thesis-listing, thesis-table

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
  show-declaration: false,
  show-outlines: true,
)

#figure(rect(width: 20mm, height: 10mm), caption: [Before the first chapter]) <preface-figure>

= First Chapter

#figure(rect(width: 20mm, height: 10mm), caption: [First chapter figure]) <first-figure>
#figure(rect(width: 20mm, height: 10mm), caption: [Excluded from the outline], outlined: false)

#figure(
  table(columns: 2, [Raw], [Table]),
  caption: [A raw table figure],
) <raw-table>

#thesis-table(
  table(columns: 2, [A], [B]),
  caption: [A table],
  outlined: false,
)

#thesis-listing(
  raw("let answer = 42", lang: "typ"),
  caption: [A listing],
  outlined: false,
)

= Second Chapter

#figure(rect(width: 20mm, height: 10mm), caption: [Second chapter figure])

#appendix()

= Appendix Chapter

#figure(rect(width: 20mm, height: 10mm), caption: [Appendix figure]) <appendix-figure>

References: @preface-figure, @first-figure, @raw-table, and @appendix-figure.

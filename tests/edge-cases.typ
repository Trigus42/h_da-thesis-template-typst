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

#figure(rect(width: 20mm, height: 10mm), caption: [Before the first chapter])

= First Chapter

#figure(rect(width: 20mm, height: 10mm), caption: [First chapter figure])
#figure(rect(width: 20mm, height: 10mm), caption: [Excluded from the outline], outlined: false)

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

#figure(rect(width: 20mm, height: 10mm), caption: [Appendix figure])

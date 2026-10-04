#import "../template.typ": thesis, mainmatter, part

#show: thesis.with(
  title: "Two-Sided Layout",
  author: "Test Author",
  supervisor: "Test Supervisor",
  faculty: "Test Faculty",
  university: "Test University",
  location: "Test Location",
  date: "4 October 2026",
  language: "en",
  two-sided: true,
  open-right: true,
)

= Front Matter

Front matter content.

#mainmatter()
#part("Body")

= First Chapter <first-two-sided-chapter>

#lorem(220)

= Second Chapter <second-two-sided-chapter>

#lorem(20)

#context {
  let first = query(<first-two-sided-chapter>).first().location().page()
  let second = query(<second-two-sided-chapter>).first().location().page()
  assert(calc.odd(first), message: "first chapter does not start on an odd page")
  assert(calc.odd(second), message: "second chapter does not start on an odd page")
}

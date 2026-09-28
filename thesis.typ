#import "template.typ": thesis, mainmatter, outlines, part, appendix

#show: thesis.with(
  title: "A Classic Thesis Style",
  author: "André Miede",
  student-id: "081542",
  degree: "Bachelor of Science (B. Sc.)",
  supervisor: "Prof. Dr.-Ing. Michael von Rüden",
  second-supervisor: "Prof. Dr. Martin Stiemerling",
  faculty: "Fachbereich Informatik",
  university: "Hochschule Darmstadt",
  location: "Darmstadt",
  date: "24. September 2026",
  language: "de",
)

#include "matter/declaration.typ"
#include "matter/abstract-en.typ"
#include "matter/abstract-de.typ"
#outlines()
#include "matter/abbreviations.typ"

#mainmatter()

#part("Thesis")
#include "chapters/introduction.typ"
#include "chapters/background.typ"
#include "chapters/examples.typ"

#part("Appendix")
#appendix()
#include "chapters/appendix.typ"

#include "matter/glossary.typ"
#include "matter/bibliography.typ"

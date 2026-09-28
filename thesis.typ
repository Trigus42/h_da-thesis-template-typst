#import "template.typ": thesis, mainmatter, declaration, abstract
#import "template.typ": outlines, print-acronyms, print-glossary, print-bibliography
#import "template.typ": part, appendix
#import "frontmatter/abbreviations.typ": abbreviations
#import "frontmatter/glossary.typ": glossary

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

#declaration(include "frontmatter/declaration.typ")
#abstract("Abstract", "en", include "frontmatter/abstract-en.typ")
#abstract("Zusammenfassung", "de", include "frontmatter/abstract-de.typ")
#outlines()
#print-acronyms(abbreviations)

#mainmatter()

#part("Thesis")
#include "chapters/introduction.typ"
#include "chapters/background.typ"
#include "chapters/examples.typ"

#part("Appendix")
#appendix()
#include "chapters/appendix.typ"

#print-glossary(glossary)
#print-bibliography("bibliography.bib")

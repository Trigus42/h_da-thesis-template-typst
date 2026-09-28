#import "template.typ": thesis, part, appendix
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
  declaration-body: include "frontmatter/declaration.typ",
  abstract-en: include "frontmatter/abstract-en.typ",
  abstract-de: include "frontmatter/abstract-de.typ",
  bibliography-file: "bibliography.bib",
  acronyms: abbreviations,
  glossary: glossary,
)

#part("Thesis")
#include "chapters/introduction.typ"
#include "chapters/background.typ"
#include "chapters/examples.typ"

#part("Appendix")
#appendix()
#include "chapters/appendix.typ"

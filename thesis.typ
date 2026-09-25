#import "template.typ": *

#let acronyms = (
  ("API", "Application Programming Interface"),
  ("UML", "Unified Modeling Language"),
)

#let glossary = (
  ("Central Limit Theorem", "A theorem stating that sums of independent random variables tend toward a normal distribution."),
  ("Normal Distribution", [A continuous bell-shaped probability distribution $N(mu, sigma^2)$.]),
  ("i.i.d.", "Independent and identically distributed random variables."),
  ("Variance", [A measure of dispersion, denoted $sigma^2$.]),
  ("PMF", "Probability Mass Function."),
)

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
  date: "25. September 2026",
  language: "de",
  abstract-en: include "frontmatter/abstract-en.typ",
  abstract-de: include "frontmatter/abstract-de.typ",
  bibliography-file: "bibliography.bib",
  acronyms: acronyms,
  glossary: glossary,
)

#part("Thesis")
#include "chapters/introduction.typ"
#include "chapters/background.typ"
#include "chapters/examples.typ"

#part("Appendix")
#appendix()
#set heading(numbering: "A.1")
#include "chapters/appendix.typ"

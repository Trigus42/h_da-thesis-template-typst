#import "../template.typ": acronyms-used

// Reference an acronym in the text with `#acronym("API")`; only referenced
// acronyms appear below. Edit the definitions here.
#let abbreviations = (
  ("API", "Application Programming Interface"),
  ("UML", "Unified Modeling Language"),
)

#acronyms-used("Abkürzungsverzeichnis", abbreviations)

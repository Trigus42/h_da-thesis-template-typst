#let maroon = rgb("800000")
#let halfgray = rgb("8c8c8c")
#let royalblue = rgb("4169e1")
#let webgreen = rgb("008000")
#let body-font = ("Palatino", "Libertinus Serif")
#let mono-font = ("DejaVu Sans Mono", "Courier New")
#let appendix-mode = state("appendix-mode", false)

#let words = (
  de: (
    degree-line: "Abschlussarbeit zur Erlangung des akademischen Grades",
    submitted: "vorgelegt von",
    student-id: "Matrikelnummer",
    first: "Referent",
    second: "Korreferent",
    declaration: "Erklärung",
    contents: "Inhaltsverzeichnis",
    figures: "Abbildungsverzeichnis",
    tables: "Tabellenverzeichnis",
    listings: "Listings",
    acronyms: "Abkürzungsverzeichnis",
    glossary: "Glossar",
    bibliography: "Literatur",
    part: "Teil",
  ),
  en: (
    degree-line: "Thesis submitted in partial fulfillment of the requirements for the degree",
    submitted: "submitted by",
    student-id: "Student ID",
    first: "Supervisor",
    second: "Second supervisor",
    declaration: "Declaration",
    contents: "Contents",
    figures: "List of Figures",
    tables: "List of Tables",
    listings: "List of Listings",
    acronyms: "List of Acronyms",
    glossary: "Glossary",
    bibliography: "Bibliography",
    part: "Part",
  ),
)

#let smallcaps(body, size: 10pt, fill: black) = text(
  font: body-font,
  size: size,
  fill: fill,
  tracking: 0.11em,
  features: ("smcp",),
  body,
)

#let allcaps(body, size: 17pt, fill: maroon) = text(
  font: body-font,
  size: size,
  fill: fill,
  tracking: 0.13em,
  weight: "regular",
  upper(body),
)

#let chapter-glyph(number) = {
  text(
    font: body-font,
    size: 82pt,
    weight: "regular",
    fill: halfgray,
    str(number),
  )
}

#let clear-page() = pagebreak(weak: true)

#let clear-to-odd() = {
  pagebreak(weak: true)
  context if calc.even(here().page()) { pagebreak() }
}

#let unnumbered-page(title, body) = {
  clear-page()
  heading(level: 1, numbering: none, outlined: false, title)
  body
}

#let title-page(data, lang) = {
  page(
    margin: (top: 18mm, bottom: 19mm, left: 25mm, right: 25mm),
    header: none,
    footer: none,
  )[
    #align(center)[
      #v(7mm)
      #image("assets/logo_h-da_rot.pdf", width: 77mm)
      #v(8mm)
      #text(size: 20.5pt, weight: "bold", data.university)
      #v(4mm)
      #text(size: 16pt)[-- #data.faculty --]
      #v(1fr)
      #text(size: 17pt, weight: "bold", data.title)
      #if data.subtitle != none [#v(3mm)#text(size: 13pt, style: "italic", data.subtitle)]
      #v(1fr)
      #text(size: 14pt, words.at(lang).degree-line)
      #v(3mm)
      #text(size: 14pt, data.degree)
      #v(1fr)
      #text(size: 14pt, words.at(lang).submitted)
      #v(3mm)
      #text(size: 14pt, weight: "bold", data.author)
      #v(3mm)
      #text(size: 11pt)[#words.at(lang).student-id: #data.student-id]
      #v(1fr)
      #table(
        columns: (auto, 5mm, auto),
        align: (left, center, left),
        stroke: none,
        inset: 1.5pt,
        [#words.at(lang).first], [:], [#data.supervisor],
        [#words.at(lang).second], [:], [#data.second-supervisor],
      )
    ]
  ]
  pagebreak()
}

#let title-back(data) = {
  page(header: none, footer: none)[
    #v(1fr)
    #data.author: #emph(data.title)#if data.subtitle != none [, #data.subtitle], \© #data.date
  ]
  pagebreak()
}

#let declaration(data, lang) = {
  heading(level: 1, numbering: none, outlined: false, words.at(lang).declaration)
  if lang == "de" [
    Ich versichere hiermit, dass ich die vorliegende Arbeit selbstständig verfasst und keine anderen als die im Literaturverzeichnis angegebenen Quellen benutzt habe.

    #v(0.8em)
    Alle Stellen, die wörtlich oder sinngemäß aus veröffentlichten oder noch nicht veröffentlichten Quellen entnommen sind, sind als solche kenntlich gemacht.

    #v(0.8em)
    Die Zeichnungen oder Abbildungen in dieser Arbeit sind von mir selbst erstellt worden oder mit einem entsprechenden Quellennachweis versehen.

    #v(0.8em)
    Diese Arbeit ist in gleicher oder ähnlicher Form noch bei keiner anderen Prüfungsbehörde eingereicht worden.
  ] else [
    I hereby declare that I have written this thesis independently and have used no sources other than those listed in the bibliography. All passages taken verbatim or in substance from published or unpublished sources are identified as such. This thesis has not been submitted in the same or similar form to another examination authority.
  ]
  v(2em)
  emph[#data.location, #data.date]
  v(17mm)
  align(right, block(width: 50mm)[#line(length: 100%) #align(center, data.author)])
  clear-page()
}

#let part-counter = counter("part")
#let part(title, lang: "de") = {
  clear-page()
  part-counter.step()
  page(header: none, footer: none)[
    #v(0.31fr)
    #align(center)[
    #text(size: 11pt)[#words.at(lang).part #context part-counter.display("I")]
    #v(1em)
    #allcaps(title, size: 12pt)
    ]
    #v(0.69fr)
  ]
  pagebreak()
}

#let appendix() = {
  appendix-mode.update(true)
  counter(heading).update(0)
}

#let margin-note(body) = place(
  right + top,
  dx: 31mm,
  dy: 34mm,
  float: true,
  block(width: 27mm, text(size: 7.8pt, style: "italic", fill: rgb("555555"), body)),
)

#let float-label(kind) = context {
  let chapter = counter(heading).get().first()
  let sequence = counter(kind).get().first() + 1
  if appendix-mode.get() {
    numbering("A.1", chapter, sequence)
  } else {
    numbering("1.1", chapter, sequence)
  }
}

#let thesis-table(body, caption: none) = figure(
  body,
  kind: "thesis-table",
  supplement: "Tabelle",
  numbering: _ => float-label("thesis-table"),
  caption: caption,
)

#let listing(body, caption: none) = figure(
  kind: "listing",
  numbering: _ => float-label("listing"),
  caption: caption,
  supplement: "Listing",
  block(width: 100%)[
    #line(length: 100%, stroke: 0.45pt)
    #v(4pt)
    #body
    #v(4pt)
    #line(length: 100%, stroke: 0.45pt)
  ],
)

#let theorem(title: none, body) = block(above: 1em, below: 1em)[
  #strong[Theorem#if title != none [ (#title)].] #body
]

#let proof(body) = block(above: 0.7em, below: 0.9em)[
  #strong[Proof.] #body #h(1fr) #sym.square.stroked
]

#let thesis(
  title: "Thesis Title",
  subtitle: none,
  author: "Author Name",
  student-id: "000000",
  degree: "Bachelor of Science (B. Sc.)",
  supervisor: "First supervisor",
  second-supervisor: "Second supervisor",
  faculty: "Fachbereich Informatik",
  university: "Hochschule Darmstadt",
  location: "Darmstadt",
  date: datetime.today().display("[day]. [month repr:long] [year]"),
  language: "de",
  abstract-en: none,
  abstract-de: none,
  bibliography-file: none,
  acronyms: (),
  glossary: (),
  show-declaration: true,
  show-outlines: true,
  body,
) = {
  let lang = if language == "en" { "en" } else { "de" }
  let data = (
    title: title,
    subtitle: subtitle,
    author: author,
    student-id: student-id,
    degree: degree,
    supervisor: supervisor,
    second-supervisor: second-supervisor,
    faculty: faculty,
    university: university,
    location: location,
    date: date,
  )

  set document(title: title, author: (author,))
  set page(
    paper: "a4",
    margin: (top: 27mm, bottom: 24mm, left: 42mm, right: 38mm),
    numbering: none,
    number-align: center,
    header-ascent: 12mm,
    footer-descent: 12mm,
  )
  set text(font: body-font, size: 11pt, lang: lang)
  set par(justify: true, leading: 0.69em)
  set heading(numbering: "1.1")
  set list(indent: 1.2em, body-indent: 0.65em, spacing: 0.55em)
  set enum(indent: 1.2em, body-indent: 0.65em, spacing: 0.55em)
  set math.equation(numbering: "(1)")
  set figure(numbering: n => context {
    let chapter = counter(heading).get().first()
    numbering("1.1", chapter, n)
  })
  set table(stroke: none)

  show link: set text(fill: royalblue)
  show raw: set text(font: mono-font, size: 8.5pt)
  show figure.caption: it => block(above: 5pt, text(size: 9pt, it))
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    v(0pt)
    block(height: 25mm, above: 0pt, below: 0.8em)[
      #if it.numbering != none {
        place(
          right + top,
          dx: 28mm,
          dy: -6mm,
          context chapter-glyph(counter(heading).display()),
        )
      }
      #text(font: body-font, size: 12pt, fill: black, tracking: 0.085em, weight: "regular", upper(it.body))
      #v(0.35em)
      #line(length: 100%, stroke: 0.45pt + halfgray)
    ]
  }
  show heading.where(level: 2): it => block(above: 1.4em, below: 0.9em)[
    #smallcaps[#if it.numbering != none [#context counter(heading).display() #h(1em)]#it.body]
  ]
  show heading.where(level: 3): it => block(above: 1.1em, below: 0.7em)[
    #text(style: "italic")[#if it.numbering != none [#context counter(heading).display() #h(1em)]#it.body]
  ]
  show heading.where(level: 4): it => block(above: 1em, below: 0.6em)[
    #text(style: "italic")[#if it.numbering != none [#context counter(heading).display() #h(1em)]#it.body]
  ]

  title-page(data, lang)
  title-back(data)
  if show-declaration { declaration(data, lang) }
  if abstract-en != none { unnumbered-page("Abstract", abstract-en) }
  if abstract-de != none { unnumbered-page("Zusammenfassung", abstract-de) }
  clear-page()

  set page(header: context {
    let hs = query(heading.where(level: 1).before(here())).filter(h => h.numbering != none)
    let opening = query(heading.where(level: 1).after(here())).any(h => h.location().page() == here().page())
    if hs.len() > 0 and not opening {
      align(if calc.odd(here().page()) { right } else { left }, smallcaps(hs.last().body, size: 8pt, fill: rgb("444444")))
      v(2pt)
      line(length: 100%, stroke: 0.35pt + rgb("aaaaaa"))
    }
  })

  if show-outlines {
    heading(level: 1, numbering: none, outlined: false, words.at(lang).contents)
    outline(title: none, depth: 3, indent: auto)
    clear-page()
    heading(level: 1, numbering: none, outlined: false, words.at(lang).figures)
    outline(title: none, target: figure.where(kind: image))
    clear-page()
    heading(level: 1, numbering: none, outlined: false, words.at(lang).tables)
    outline(title: none, target: figure.where(kind: table))
    clear-page()
    heading(level: 1, numbering: none, outlined: false, words.at(lang).listings)
    outline(title: none, target: figure.where(kind: raw))
    clear-page()
  }
  if acronyms.len() > 0 {
    heading(level: 1, numbering: none, outlined: false, words.at(lang).acronyms)
    table(
      columns: (27mm, 1fr),
      inset: (x: 0pt, y: 4pt),
      ..acronyms.map(x => (smallcaps(x.at(0)), x.at(1))).flatten(),
    )
    clear-page()
  }

  counter(page).update(1)
  set page(numbering: none)
  body

  if glossary.len() > 0 {
    heading(level: 1, numbering: none, outlined: false, words.at(lang).glossary)
    for entry in glossary {
      block(below: 0.75em)[#strong(entry.at(0)) #h(0.6em) #entry.at(1)]
    }
    clear-page()
  }
  if bibliography-file != none {
    heading(level: 1, numbering: none, outlined: false, words.at(lang).bibliography)
    bibliography(bibliography-file, title: none, style: "ieee", full: true)
  }
}

#let maroon = rgb("800000")
#let halfgray = rgb("8c8c8c")
#let royalblue = rgb("4169e1")
#let webbrown = rgb("990000")
#let body-font = ("Palatino", "Libertinus Serif")
#let mono-font = ("DejaVu Sans Mono", "Courier New")
#let appendix-mode = state("hda-thesis.appendix-mode", false)
#let thesis-language = state("hda-thesis.language", "de")
#let used-acronyms = state("hda-thesis.used-acronyms", ())
#let thesis-data = state("hda-thesis.data", none)

#let words = (
  de: (
    degree-line: "Abschlussarbeit zur Erlangung des akademischen Grades",
    submitted: "vorgelegt von",
    student-id: "Matrikelnummer",
    first: "Referent",
    second: "Korreferent",
    contents: "Inhaltsverzeichnis",
    figures: "Abbildungsverzeichnis",
    tables: "Tabellenverzeichnis",
    listings: "Listings",
    part: "Teil",
    table: "Tabelle",
    listing: "Listing",
    theorem: "Satz",
    proof: "Beweis",
  ),
  en: (
    degree-line: "Thesis submitted in partial fulfillment of the requirements for the degree",
    submitted: "submitted by",
    student-id: "Student ID",
    first: "Supervisor",
    second: "Second supervisor",
    contents: "Contents",
    figures: "List of Figures",
    tables: "List of Tables",
    listings: "List of Listings",
    part: "Part",
    table: "Table",
    listing: "Listing",
    theorem: "Theorem",
    proof: "Proof",
  ),
)

#let tracked-small-caps(body, size: 10pt, fill: black) = text(
  font: body-font,
  size: size,
  fill: fill,
  tracking: 0.11em,
  smallcaps(body),
)

#let allcaps(body, size: 17pt, fill: maroon) = text(
  font: body-font,
  size: size,
  fill: fill,
  tracking: 0.13em,
  weight: "regular",
  upper(body),
)

#let chapter-glyph(number) = text(
  font: body-font,
  size: 82pt,
  weight: "regular",
  fill: halfgray,
  number,
)

#let clear-page() = pagebreak(weak: true)

// Start an unnumbered, unlisted top-level section on a fresh page. Content
// files (declaration, abstracts, glossary, bibliography, ...) call this to open
// their own section, so section titles live with the content rather than here.
#let unnumbered-heading(title) = {
  clear-page()
  heading(level: 1, numbering: none, outlined: false, title)
}

// Run `render` with the thesis metadata (author, location, date, ...) so content
// files can render document-specific details such as the declaration signature.
#let thesis-info(render) = context {
  let data = thesis-data.get()
  assert(data != none, message: "thesis-info is only available inside a thesis document")
  render(data)
}

#let title-page(data, lang) = {
  page(
    margin: (top: 11mm, bottom: 31mm, left: 25mm, right: 25mm),
    header: none,
    footer: none,
  )[
    #align(center)[
      #v(2mm)
      #image("assets/logo_h-da_rot.pdf", width: 77mm)
      #v(8mm)
      #text(size: 20.5pt, weight: "bold", data.university)
      #v(1mm)
      #text(size: 16pt)[-- #data.faculty --]
      #v(1fr)
      #text(size: 17pt, weight: "bold", data.title)
      #if data.subtitle != none and data.subtitle != "" [#v(3mm)#text(size: 13pt, style: "italic", data.subtitle)]
      #v(1fr)
      #if data.degree-line != none [
        #text(size: 14pt, data.degree-line)
        #v(1mm)
      ]
      #text(size: 14pt, data.degree)
      #v(1fr)
      #text(size: 14pt, words.at(lang).submitted)
      #v(1mm)
      #text(size: 14pt, weight: "bold", data.author)
      #v(1mm)
      #if data.student-id != none and data.student-id != "" [
        #text(size: 11pt)[#words.at(lang).student-id: #data.student-id]
      ]
      #v(1fr)
      #table(
        columns: (auto, 5mm, auto),
        align: (left, center, left),
        stroke: none,
        inset: 1.5pt,
        [#words.at(lang).first], [:], [#data.supervisor],
        ..if data.second-supervisor != none and data.second-supervisor != "" {
          ([#words.at(lang).second], [:], [#data.second-supervisor])
        } else {
          ()
        },
      )
    ]
  ]
  pagebreak()
}

#let title-back(data) = {
  page(header: none, footer: none)[
    #v(1fr)
    #data.author: #emph(data.title)#if data.subtitle != none and data.subtitle != "" [, #data.subtitle], \© #data.date
  ]
  pagebreak()
}

#let acronym(short) = context {
  used-acronyms.update(current => if current.contains(short) {
    current
  } else {
    current + (short,)
  })
  short
}

// Begin the numbered body: restart pagination. The running header is bound once
// on the global page setup in `thesis`; it renders only on the body pages of
// numbered chapters, so front matter (queried before any numbered chapter) stays
// bare. Restarting the counter here makes the part divider page 1 and the first
// chapter page 2, as in the reference.
#let mainmatter() = {
  clear-page()
  counter(page).update(1)
}

#let part-counter = counter("hda-thesis.part")
// Marker emitted at each part so `heading-outline` can list the parts in reading
// order; parts are not headings, so they are recorded separately here.
#let part-entry = <hda-thesis.part-entry>
#let part(title, lang: auto) = {
  assert(type(title) == str and title.trim() != "", message: "part title must be a non-empty string")
  if lang != auto {
    assert(lang in ("de", "en"), message: "part language must be either \"de\" or \"en\"")
  }
  clear-page()
  part-counter.step()
  context [#metadata((number: part-counter.display("I"), title: title))#part-entry]
  page(header: none, footer: none)[
    #v(0.31fr)
    #align(center)[
    #context {
      let language = if lang == auto { thesis-language.get() } else { lang }
      text(size: 11pt)[#words.at(language).part #part-counter.display("I")]
    }
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

#let format-chapter-number(in-appendix, ..numbers) = numbering(
  if in-appendix { "A.1" } else { "1.1" },
  ..numbers,
)

#let chapter-numbering(..numbers) = context {
  format-chapter-number(appendix-mode.get(), ..numbers)
}

#let heading-number-at(location) = {
  let numbers = counter(heading).at(location)
  let in-appendix = appendix-mode.at(location)
  format-chapter-number(in-appendix, ..numbers)
}

// Running header for body pages: the current section label and title in spaced
// small caps at the top-right, with the page number at the far right on the same
// line and no rule, matching the reference. It is suppressed on chapter and
// unnumbered-section openings (whose heading sits on the page) and on the pages
// of unnumbered sections such as the glossary and bibliography, which carry no
// running title. The running section mirrors the reference: the first numbered
// section that begins on the page, or the most recent one before it.
#let running-header = context {
  let page-number = here().page()
  let opens-here = query(heading.where(level: 1)).any(it => it.location().page() == page-number)
  if opens-here { return }
  let chapters-before = query(heading.where(level: 1)).filter(it => it.location().page() <= page-number)
  let current-chapter = chapters-before.at(-1, default: none)
  if current-chapter == none or current-chapter.numbering == none { return }
  let later-chapters = query(heading.where(level: 1).after(current-chapter.location()))
  let next-chapter = later-chapters.at(0, default: none)
  let section-selector = heading.where(level: 2).after(current-chapter.location())
  let sections = query(if next-chapter == none {
    section-selector
  } else {
    section-selector.before(next-chapter.location())
  }).filter(it => it.numbering != none)
  let sections-on-page = sections.filter(it => it.location().page() == page-number)
  let sections-before = sections.filter(it => it.location().page() < page-number)
  let running-heading = if sections-on-page.len() > 0 {
    sections-on-page.first()
  } else {
    sections-before.at(-1, default: current-chapter)
  }
  let mark = [#heading-number-at(running-heading.location()) #running-heading.body]
  align(right)[
    #tracked-small-caps(mark, size: 8pt, fill: rgb("444444"))
    #h(1.2em)
    #text(font: body-font, size: 9pt, fill: rgb("444444"), counter(page).display("1"))
  ]
}

#let float-number(target, location) = {
  let chapter = counter(heading).at(location).first()
  let in-appendix = appendix-mode.at(location)
  let floats-in-chapter = query(target.before(location)).filter(it => (
    counter(heading).at(it.location()).first() == chapter
      and appendix-mode.at(it.location()) == in-appendix
  ))
  let sequence = floats-in-chapter.len()
  if chapter == 0 {
    numbering("1", sequence)
  } else {
    format-chapter-number(in-appendix, chapter, sequence)
  }
}

// Figure kinds that carry chapter-scoped numbering. References to these must
// resolve the number at the target's location; native rendering would instead
// evaluate the numbering closure in the referencing context.
#let float-kinds = (image, table, raw, "listing")

#let labeled-number(supplement, number) = if supplement == none {
  number
} else {
  [#supplement #number]
}

#let reference-handler(reference) = context {
  let target = reference.element
  if target == none {
    reference
  } else if target.func() == heading and target.numbering != none {
    let location = target.location()
    let supplement = if reference.supplement == auto { target.supplement } else { reference.supplement }
    link(location, labeled-number(supplement, heading-number-at(location)))
  } else if target.func() == figure and target.kind in float-kinds {
    let location = target.location()
    let supplement = if reference.supplement == auto { target.supplement } else { reference.supplement }
    let selector = figure.where(kind: target.kind)
    link(location, labeled-number(supplement, float-number(selector, location)))
  } else {
    reference
  }
}

#let float-outline(target) = {
  for figure-element in query(target.and(figure.where(outlined: true))) {
    if figure-element.caption != none {
      let location = figure-element.location()
      let number = float-number(target, location)
      let caption = figure-element.caption.body
      grid(
        columns: (auto, 1fr, auto),
        column-gutter: 0.6em,
        link(location, text(fill: black, [#figure-element.supplement #number])),
        // Caption followed by a dotted leader that fills the row, matching the
        // table of contents and the reference float lists.
        link(location, text(fill: black, caption)) + h(0.6em) + box(width: 1fr, repeat[.]),
        link(location, text(fill: royalblue, context counter(page).display(at: location))),
      )
      parbreak()
      v(-0.25em)
    }
  }
}

// Render the list of acronyms actually referenced through `acronym(...)`. The
// referenced set is only complete once the whole document is processed, so it is
// read with `.final()`; the caller supplies both the section title and the
// acronym definitions.
#let acronyms-used(title, acronyms) = context {
  assert(type(acronyms) == array, message: "acronyms must be an array of two-item arrays")
  for entry in acronyms {
    assert(type(entry) == array and entry.len() == 2, message: "each acronym entry must be a two-item array")
  }
  let used = used-acronyms.final()
  let unknown = used.filter(short => not acronyms.any(it => it.at(0) == short))
  assert(unknown.len() == 0, message: "unknown acronym: " + unknown.join(", "))
  if used.len() > 0 {
    unnumbered-heading(title)
    table(
      columns: (35mm, 1fr),
      inset: (x: 0pt, y: 4pt),
      ..acronyms.filter(x => used.contains(x.at(0))).map(x => (
        box(tracked-small-caps(x.at(0))),
        x.at(1),
      )).flatten(),
    )
    clear-page()
  }
}

// Render a two-column term/definition list under an unnumbered section heading.
#let definition-list(title, entries) = {
  assert(type(entries) == array, message: "definition list entries must be an array of two-item arrays")
  for entry in entries {
    assert(type(entry) == array and entry.len() == 2, message: "each entry must be a two-item array")
  }
  if entries.len() > 0 {
    unnumbered-heading(title)
    for entry in entries {
      grid(
        columns: (43mm, 1fr),
        column-gutter: 2mm,
        row-gutter: 0.75em,
        text(hyphenate: false, strong(entry.at(0))),
        entry.at(1),
      )
    }
    clear-page()
  }
}

#let heading-outline(depth: 3) = {
  // Query parts and outlined headings together so both appear in reading order.
  for element in query(selector(heading.where(outlined: true)).or(part-entry)) {
    if element.func() == metadata {
      // Part row: red numeral and title, no leader and no page number, matching
      // the reference. A little extra space sets it off from the chapters.
      v(0.5em)
      text(fill: maroon)[#element.value.number #h(1em) #element.value.title]
      parbreak()
      v(-0.25em)
    } else if element.level <= depth {
      let location = element.location()
      let indent = (element.level - 1) * 1.5em
      h(indent)
      link(location, text(fill: black)[
        #if element.numbering != none [#heading-number-at(location) #h(1em)]
        #element.body
      ])
      box(width: 1fr, repeat[.])
      link(location, text(fill: royalblue, context counter(page).display(at: location)))
      parbreak()
      v(-0.25em)
    }
  }
}

#let outlines() = context {
  let lang = thesis-language.get()
  heading(level: 1, numbering: none, outlined: false, words.at(lang).contents)
  heading-outline(depth: 3)
  clear-page()
  if query(figure.where(kind: image, outlined: true)).len() > 0 {
    heading(level: 1, numbering: none, outlined: false, words.at(lang).figures)
    float-outline(figure.where(kind: image))
    clear-page()
  }
  if query(figure.where(kind: table, outlined: true)).len() > 0 {
    heading(level: 1, numbering: none, outlined: false, words.at(lang).tables)
    float-outline(figure.where(kind: table))
    clear-page()
  }
  if query(figure.where(kind: "listing", outlined: true)).len() > 0 {
    heading(level: 1, numbering: none, outlined: false, words.at(lang).listings)
    float-outline(figure.where(kind: "listing"))
    clear-page()
  }
}

#let thesis-table(body, caption: none, supplement: auto, ..options) = figure(
  body,
  kind: table,
  supplement: if supplement == auto { context words.at(thesis-language.get()).table } else { supplement },
  caption: caption,
  ..options,
)

#let thesis-listing(body, caption: none, supplement: auto, ..options) = figure(
  kind: "listing",
  caption: caption,
  supplement: if supplement == auto { context words.at(thesis-language.get()).listing } else { supplement },
  block(width: 100%)[
    #line(length: 100%, stroke: 0.45pt)
    #v(4pt)
    #body
    #v(4pt)
    #line(length: 100%, stroke: 0.45pt)
  ],
  ..options,
)

#let theorem(title: none, body) = context block(above: 1em, below: 1em)[
  #strong[#words.at(thesis-language.get()).theorem#if title != none [ (#title)].] #body
]

#let proof(body) = context block(above: 0.7em, below: 0.9em)[
  #strong[#words.at(thesis-language.get()).proof.] #body #h(1fr) #sym.square.stroked
]

#let thesis(
  title: "Thesis Title",
  subtitle: none,
  author: "Author Name",
  student-id: none,
  degree: "Bachelor of Science (B. Sc.)",
  degree-line: none,
  supervisor: "First supervisor",
  second-supervisor: none,
  faculty: "Fachbereich Informatik",
  university: "Hochschule Darmstadt",
  location: "Darmstadt",
  date: datetime.today().display("[day]. [month repr:long] [year]"),
  language: "de",
  body,
) = {
  assert(language in ("de", "en"), message: "language must be either \"de\" or \"en\"")
  for (name, value) in (
    ("title", title),
    ("author", author),
    ("degree", degree),
    ("supervisor", supervisor),
    ("faculty", faculty),
    ("university", university),
    ("location", location),
    ("date", date),
  ) {
    assert(type(value) == str and value.trim() != "", message: name + " must be a non-empty string")
  }
  for (name, value) in (
    ("subtitle", subtitle),
    ("student-id", student-id),
    ("second-supervisor", second-supervisor),
  ) {
    assert(value == none or type(value) == str, message: name + " must be a string or none")
  }
  assert(
    degree-line == auto or degree-line == none or type(degree-line) == str,
    message: "degree-line must be auto, none, or a string",
  )
  let lang = language
  // auto keeps the language default line; none omits it; a string overrides it.
  let resolved-degree-line = if degree-line == auto { words.at(lang).degree-line } else { degree-line }
  let data = (
    title: title,
    subtitle: subtitle,
    author: author,
    student-id: student-id,
    degree: degree,
    degree-line: resolved-degree-line,
    supervisor: supervisor,
    second-supervisor: second-supervisor,
    faculty: faculty,
    university: university,
    location: location,
    date: date,
  )

  set document(title: title, author: (author,))
  thesis-language.update(lang)
  thesis-data.update(data)
  appendix-mode.update(false)
  part-counter.update(0)
  set page(
    paper: "a4",
    margin: (top: 27mm, bottom: 24mm, left: 42mm, right: 38mm),
    numbering: none,
    header: running-header,
    header-ascent: 12mm,
    footer-descent: 12mm,
  )
  set text(font: body-font, size: 11pt, lang: lang)
  set par(justify: true, leading: 0.58em)
  set heading(numbering: chapter-numbering)
  set list(indent: 1.2em, body-indent: 0.65em, spacing: 0.55em)
  set enum(indent: 1.2em, body-indent: 0.65em, spacing: 0.55em)
  set math.equation(numbering: "(1)")
  set figure(numbering: "1")
  show figure.where(kind: image): set figure(numbering: _ => context float-number(figure.where(kind: image), here()))
  show figure.where(kind: table): set figure(numbering: _ => context float-number(figure.where(kind: table), here()))
  show figure.where(kind: raw): set figure(numbering: _ => context float-number(figure.where(kind: raw), here()))
  show figure.where(kind: "listing"): set figure(numbering: _ => context float-number(figure.where(kind: "listing"), here()))
  set table(stroke: none)

  show link: set text(fill: webbrown)
  show ref: reference-handler
  show raw: set text(font: mono-font, size: 8.5pt)
  show figure.caption: it => block(above: 5pt, text(size: 9pt, it))
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    v(if it.numbering == none { 8mm } else { 0mm })
    block(above: 0pt, below: 1.2em)[
      #if it.numbering != none {
        place(
          right + top,
          dx: 26mm,
          dy: -20mm,
          text(font: body-font, size: 70pt, weight: "regular", fill: halfgray, heading-number-at(it.location())),
        )
      }
      #text(font: body-font, size: 12pt, fill: black, tracking: 0.085em, weight: "regular", upper(it.body))
      #v(0.25em)
      #line(length: 100%, stroke: 0.55pt + halfgray)
    ]
  }
  show heading.where(level: 2): it => block(above: 1.4em, below: 0.9em)[
    #text(size: 10pt, tracking: 0.11em, weight: "regular", upper[#if it.numbering != none [#heading-number-at(it.location()) #h(1em)]#it.body])
  ]
  show heading.where(level: 3): it => block(above: 1.1em, below: 0.7em)[
    #text(style: "italic")[#if it.numbering != none [#heading-number-at(it.location()) #h(1em)]#it.body]
  ]
  show heading.where(level: 4): it => block(above: 1em, below: 0.6em)[
    #text(style: "italic")[#if it.numbering != none [#heading-number-at(it.location()) #h(1em)]#it.body]
  ]

  title-page(data, lang)
  title-back(data)

  body
  appendix-mode.update(false)
}

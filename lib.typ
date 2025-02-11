// global
#import "@preview/great-theorems:0.1.1": great-theorems-init
#import "@preview/hydra:0.5.2": hydra
#import "@preview/equate:0.3.0": equate
#import "@preview/i-figured:0.2.4": reset-counters, show-equation

#let split_name(str) = {
  let arr = str.split(" ")
  (arr.at(0), arr.slice(1).join(" "))
}

#let display_jury_member(acc, mem) = {
  let (name, role, status, affiliation) = mem
  let (first, last) = split_name(name)
  (acc + (grid.cell(first), grid.cell(smallcaps(last)), grid.cell(role), grid.cell(status), grid.cell(affiliation)))
}

#let display_jury(jury) = {
  align(center,
  grid(columns: (10%, 13%, 14%, 25%, 54%), rows: auto, gutter: 6pt, align: left,
    ..jury.fold(none, display_jury_member)))
}

#let template(
  // personal/subject related stuff
  author: "Stuart Dent",
  title: "My Very Fancy and Good-Looking Thesis About Interesting Stuff",
  title-fr: none,
  supervisor1: "Prof. Dr. Sue Persmart",
  supervisor2: "Prof. Dr. Ian Telligent",
  degree: "Example",
  program: "Example-Studies",
  university: "Example University",
  institute: "Example Institute",
  deadline: datetime.today().display(),
  city: "Example City",
  defense: none,
  jury: (("John Doe", "University of Paris"), ),
  cover-header: none,
  // file paths for logos etc.
  uni-logo: none,
  institute-logo: none,

  // formatting settings
  body-font: "New Computer Modern",
  //body-font: "CMU Serif",
  cover-font: "New Computer Modern",
  title-font: "Instrument Rocq",

  // content that needs to be placed differently then normal chapters
  abstract: none,

  // colors
  cover-color: rgb("#800080"),
  heading-color: rgb("#0000ff"),
  link-color: rgb("#000000"),

  // equation settings
  equate-settings: none,
  equation-numbering-pattern: "(1.1)",

  // the content of the thesis
  body
) = {
// ------------------- settings -------------------
set document(author: author, title: title)
set heading(numbering: "1.1")  // Heading numbering
set enum(numbering: "(i)") // Enumerated lists
show link: set text(fill: link-color)
show ref: set text(fill: link-color)

// ------------------- Math equation settings -------------------

// either use equate if equate-settings is set or use i-figured if equate-settings is none
// i-figured settings
show math.equation: it => {
  if equate-settings == none {
    show-equation(prefix: "eq:", only-labeled: true, numbering: equation-numbering-pattern, it)
  } else {
    it
  }
}
set math.equation(supplement: none) if equate-settings == none

// equate settings
show: it => {
  if equate-settings != none {
    equate(..equate-settings, it)
  } else {
    it
  }
}
set math.equation(numbering: equation-numbering-pattern) if equate-settings != none

// Reference equations with parentheses (for equate)
// cf. https://forum.typst.app/t/how-can-i-set-numbering-for-sub-equations/1603/4
show ref: it => {
  let eq = math.equation
  let el = it.element

  let is-normal-equation = el != none and el.func() == eq
  let with-subnumbers = equate-settings != none and equate-settings.keys().contains("sub-numbering") and equate-settings.sub-numbering
  let is-sub-equation = el != none and el.func() == figure and el.kind == eq
  if equate-settings != none and is-normal-equation {
    link(el.location(), numbering(
      el.numbering,
      ..counter(eq).at(el.location())
    ))
  } else if equate-settings != none and not with-subnumbers and is-sub-equation {
    link(el.location(), numbering(
      el.numbering,
      counter(eq).at(el.location()).at(0) - 1
    ))
  } else if equate-settings != none and is-sub-equation {
    link(el.location(), numbering(
      el.numbering,
      ..el.body.value
    ))
  } else {
    it
  }
}

show math.equation: box  // no line breaks in inline math
show: great-theorems-init  // show rules for theorems


// ------------------- Settings for Chapter headings -------------------
show heading.where(level: 1): set heading(supplement: [Chapter])
show heading.where(
  level: 1,
): it => {
  if it.numbering != none {
    block(width: 100%)[
      #line(length: 100%, stroke: 0.6pt + heading-color)
      #v(1cm)
      #set align(left)
      #set text(22pt)
      #text(heading-color)[Chapter
      #counter(heading).display(
        "1:" + it.numbering
      )]

      #it.body
      #v(-0.5cm)
      #line(length: 100%, stroke: 0.6pt + heading-color)
    ]
  }
  else {
    block(width: 100%)[
      #line(length: 100%, stroke: 0.6pt + heading-color)
      #v(1cm)
      #set align(left)
      #set text(22pt)
      #it.body
      #v(-0.5cm)
      #line(length: 100%, stroke: 0.6pt + heading-color)
    ]
  }
}
// Automatically insert a page break before each chapter
show heading.where(
  level: 1
): it => {
  colbreak(weak: true)
  it
}
// only valid for abstract and declaration
show heading.where(
  outlined: false,
  level: 2
): it => {
  set align(center)
  set text(18pt)
  it.body
  v(0.5cm, weak: true)
}
// Settings for sub-sub-sub-sections e.g. section 1.1.1.1
show heading.where(
  level: 4
): it => {
  it.body
  linebreak()
}
// same for level 5 headings
show heading.where(
  level: 5
): it => {
  it.body
  linebreak()
}

// reset counter from i-figured for section-based equation numbering
show heading: it => {
  if equate-settings == none {
    reset-counters(it)
  } else {
    it
  }
}
// ------------------- other settings -------------------
// Settings for Chapter in the outline
show outline.entry.where(
  level: 1
): it => {
  v(14.75pt, weak: true)
  strong(it)
}

// table label on top and not below the table
show figure.where(
  kind: table
): set figure.caption(position: top)

// ------------------- Cover -------------------
set text(font: cover-font)  // cover font

if cover-header != none {
align(center, text(cover-header))
}
v(0.5fr)
//logos
  if uni-logo != none and institute-logo != none {
    grid(
      columns: (1fr, 1fr),
      rows: (auto),
      column-gutter: 70pt,
      row-gutter: 3pt,
      grid.cell(
        colspan: 1,
        align: center,
        uni-logo,
      ),
      grid.cell(
        colspan: 1,
        align: center,
        institute-logo,
      ),
      // grid.cell(
      //   colspan: 1,
      //   align: center,
      //   text(1.5em, weight: 700, university)
      // ),
      // grid.cell(
      //   colspan: 1,
      //   align: center,
      //   text(1.5em, weight: 700, institute)
      // )
    )
  } else if uni-logo != none {
    grid(
      columns: (0.5fr),
      rows: (auto),
      column-gutter: 100pt,
      row-gutter: 7pt,
      grid.cell(
        colspan: 1,
        align: center,
        uni-logo,
      ),
      grid.cell(
        colspan: 1,
        align: center,
        text(1.5em, weight: 700, university)
      )
    )
  } else if institute-logo != none {
    grid(
      columns: (0.5fr),
      rows: (auto),
      column-gutter: 100pt,
      row-gutter: 7pt,
      grid.cell(
        colspan: 1,
        align: center,
        institute-logo,
      ),
      grid.cell(
        colspan: 1,
        align: center,
        text(1.5em, weight: 700, institute)
      )
    )
  }
v(0.5fr)
align(center, text(1.5em, weight: 500, smallcaps(degree)))
v(0.5fr)
//title
line(length: 100%, stroke: cover-color)
align(center, text(2em, weight: 700, text(font: title-font, title)))
if title-fr != none {
  align(center, text(1em, weight: 500, style: "italic", text(font: title-font, title-fr)))
}
line(start: (0%, 0pt), length: 100%, stroke: cover-color)
align(center, text(1.3em, weight: 100, "Version du " + deadline))
v(0.5fr)
align(center, text(1em, weight: 500, style: "italic", "Présentée et soutenue publiquement par"))
let (first, last) = split_name(author)
align(center, text(1.5em, weight: 500, first + " ") + text(1.5em, weight: 500, smallcaps(last)))
align(center, text("le " + defense))
v(0.7fr)
// No french.display("[day] [month repr:short] [year]")))
//university
//align(center, text(1.3em, weight: 100, university + ", " + institute))
// supervisors
align(center + bottom, text(1.3em, weight: 100, style: "italic", "devant le jury composé de" + linebreak()) +
display_jury(jury))
pagebreak()

// ------------------- Abstract -------------------
set text(font: body-font)  // body font
if abstract != none{
  abstract
}


set page(
  numbering: "1",
  number-align: center,
  header: context {
    align(center, emph(hydra(1)))
    v(0.2cm)
  },
)  // Page numbering after cover & abstract => they have no page number
pagebreak()

// ------------------- Tables of ... -------------------

// Table of contents
outline(depth: 3, indent: 1em, fill: line(length: 100%, stroke: (thickness: 1pt, dash: "loosely-dotted")))
pagebreak()

// List of figures
outline(
  title: [List of Figures],
  target: figure.where(kind: image),
  fill: line(length: 100%, stroke: (thickness: 1pt, dash: "loosely-dotted"))
)
pagebreak()


// List of Tables
outline(
  title: [List of Tables],
  target: figure.where(kind: table),
  fill: line(length: 100%, stroke: (thickness: 1pt, dash: "loosely-dotted"))
)
pagebreak()

set raw(syntaxes: ("../lib/Rocq.sublime-syntax", "../lib/Gallina.sublime-syntax"),    theme: "../lib/Rocq.tmTheme")

show raw.where(lang: "gallina"): it => { 
  set text(font: "SourceCodePro", ligatures: true)
  it
}

show raw.where(lang: "rocq"): it => { 
  set text(font: "SourceCodePro", ligatures: true, discretionary-ligatures: true, features: (COQX: 1, dlig: 1, XV00: 1))
  it
}

let varpurple = rgb("#660066")
let constrmaroon = rgb("#990000")
let defgreen = rgb("#006600")
let indblue = rgb("#0000cc")
let kwred = rgb("#cc1a1a")

show "Γ_arities": name => "Γ" + sub("ar")
show "Γ_param": _ => "Γ" + sub("param")
show "Γ_args": _ => "Γ" + sub("args")
show "=s" : _ => "=" + sub("s")
// let gallinakw(it) = text(fill: kwred, it)
// show "Prop": name => gallinakw("Prop")
// show "Type": name => gallinakw("Type")
// show "Set": name => gallinakw("Set")


// ------------------- Content -------------------
body
}

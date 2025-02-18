// global
#import "@preview/great-theorems:0.1.1": great-theorems-init
#import "@preview/hydra:0.5.2": hydra
#import "@preview/equate:0.3.0": equate
#import "@preview/i-figured:0.2.4": reset-counters, show-equation

#let in-outline = state("in-outline", false)

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
  header-font: "Instrument Rocq",

  // content that needs to be placed differently then normal chapters
  abstract: none,

  // colors
  cover-color: rgb("#800080"),
  heading-color: rgb("#0000ff"),
  link-color: blue,

  // equation settings
  equate-settings: none,
  equation-numbering-pattern: "(1.1)",

  // the content of the thesis
  body
) = {
// ------------------- settings -------------------
set document(author: author, title: title)
set heading(numbering: "1.1.1")  // Heading numbering
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
      #v(0.4cm)
      #set align(left)
      #set text(22pt, font: title-font)
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
      #v(0.2cm)
      #set align(left)
      #set text(22pt)
      #it.body
      #v(-0.5cm)
      #line(length: 100%, stroke: 0.6pt + heading-color)
    ]
  }
}
// Automatically insert a page break before each chapter
show heading.where(level: 1): it => if it.numbering != none { colbreak(weak: true) + it } else { it }

// only valid for abstract and declaration
show heading.where(
  level: 2,
  outlined: false
): it => {
  set align(center)
  set text(18pt)
  it.body
  v(0.5cm, weak: true)
}

show heading.where(
  level: 2,
  outlined: true
): it => {
  set align(left)
  set text(14pt)
  v(0.5cm)
  h(-1em)

  if it.numbering != none { counter(heading).display("1." + it.numbering) }
  
  " " + it.body
  v(0.5cm, weak: true)
}

// show heading.where(
//   level: 3
// ): it => {
//   // set align(left)
//   set text(11pt)
//   v(0.5cm, weak: true)
//   if it.numbering != none { 
//     h(-1em)

//     counter(heading).display("1." + it.numbering) + " " + it.body
//   }
//   else { it.body }
//   v(0.5cm, weak: true)
// }

// Settings for sub-sub-sub-sections e.g. section 1.1.1.1
show heading.where(
  level: 4
): it => {
  text(style: "italic", it.body + ".")
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

show outline: it => {
  in-outline.update(true)
  it
  in-outline.update(false)
} 

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

/// Display a heading's numbering and body.
///
/// - ctx (context): The context in which the element was found.
/// - candidate (content): The heading to display, panics if this is not a heading.
/// -> content
let display_header(ctx, candidate) = {
  if calc.even(ctx.anchor-loc.page()) {
  if candidate.has("numbering") and candidate.numbering != none {
    place(bottom + left, dx : -2em, dy: -0.55em,
      text(weight: "bold", numbering(candidate.numbering, ..counter(heading).at(candidate.location()))))
  }

  emph(candidate.body) }
  else {
    emph(candidate.body)
    if candidate.has("numbering") and candidate.numbering != none {
      place(bottom + right, dx: 2em, dy: -0.55em,
        text(weight: "bold", numbering(candidate.numbering, ..counter(heading).at(candidate.location()))))
    }
  }
}

set page(
  numbering: "1",
  number-align: center,
  header: context {
    if calc.odd(here().page()) {
      align(right, text(font: header-font, hydra(book: true, display: display_header, 1)))
    } else {
      align(left, text(font: header-font, hydra(book: true, display: display_header, 2)))
    }
    //line(length: 100%)
    v(0.2cm)
  }
) 

pagebreak()

// ------------------- Tables of ... -------------------

// Table of contents
outline(depth: 3, indent: 1em)
// fill: line(length: 100%, stroke: (thickness: 1pt, dash: "loosely-dotted")))
pagebreak()

// List of figures
outline(
  title: [List of Figures],
  target: figure.where(kind: image),
//  fill: line(length: 100%, stroke: (thickness: 1pt, dash: "loosely-dotted")))
)

outline(
  title: [List of Specifications],
  target: figure.where(kind: "Specification"),
//  fill: line(length: 100%, stroke: (thickness: 1pt, dash: "loosely-dotted"))
)

// List of Tables
outline(
  title: [List of Tables],
  target: figure.where(kind: table),
  //fill: line(length: 100%, stroke: (thickness: 1pt, dash: "loosely-dotted"))
)

outline(
  title: [List of Listings],
  target: figure.where(kind: raw),
  //fill: line(length: 100%, stroke: (thickness: 1pt, dash: "loosely-dotted"))
)
pagebreak()

set raw(syntaxes: ("../lib/Rocq.sublime-syntax", "../lib/Gallina.sublime-syntax"),    theme: "../lib/Rocq.tmTheme")

show raw.where(lang: "gallina"): it => { 
  set text(font: "SourceCodePro", ligatures: true)
  it
}

show raw.where(lang: "rocq"): it => { 
  let size = if it.block { 0.8em } else { 1em } 
  set text(font: ("Fira Code", "New Computer Modern Math", ), size: size, style: "normal", 
  discretionary-ligatures: true, 
  ligatures: true, 
    features: (COQX: 1, dlig: 1, XV00: 1))
  if it.block { align(center, block(breakable: false, fill: rgb("#F6E6E1"), inset: 8pt, radius: 4pt, it)) }
  else { it }
}

show "Rocq": it => smallcaps(it)
show "CertiCoq": it => smallcaps(it)
show "Gallina": it => smallcaps(it)
show "Coq": it => smallcaps(it)
show "PCUIC": it => smallcaps(it)
show "MetaRocq": it => smallcaps(it)
show "OCaml": it => smallcaps(it)

show "Γ_arities": name => "Γ" + sub("ar")
show "Γ_param": _ => "Γ" + sub("param")
show "Γ_args": _ => "Γ" + sub("args")
show "=s" : _ => "=" + sub("s")
show "cumsRle": _ => $scripts(prec.eq)_s^(text("Rle"))$

show "<=[Rle]": _ => $scripts(prec.eq)_s^(text("Rle"))$
show "<=[Re]": _ => $scripts(prec.eq)_s^(text("Re"))$
show "<==[Re,Rle,0]": _ => $scripts(prec.eq)_s^(text("Re, Rle, 0"))$
show "<==[Re,Rle,S napp]": _ => $scripts(prec.eq)_s^(text("Re, Rle, napp+1"))$
show "<==[Re,Rle,napp]": _ => $scripts(prec.eq)_s^(text("Re, Rle, napp"))$
show "<==[Re,Re,0]": _ => $scripts(prec.eq)_s^(text("Re, Re,  0"))$

// let gallinakw(it) = text(fill: kwred, it)
// show "Prop": name => gallinakw("Prop")
// show "Type": name => gallinakw("Type")
// show "Set": name => gallinakw("Set")

show "⇝*": it => text("⇝") + super("*")
// let erase_symbol = text(1.5em, weight: 700, font: "New Computer Modern Math", "ε")
let erase_symbol = $cal(E)$
show "ERASE": it => erase_symbol
show "ERASES": it => text("⇝") + sub(erase_symbol)
show "EVAL": it => sym.arrow.b.double
show ";;;": it => text(";")
show "|-": it => $⊢$
show "abs_env_ext_rel": it => $~_("ext")$
show "PARARED": it => sym.arrow.r.triple
show "vass": it => ":"
show "forall": it  => "∀"

let erase(t) = "(" + erase_symbol + t + ")"
let mkApps(f, args) = $#raw(lang: "rocq", "mkApps")f args$

// ------------------- Content -------------------
body
}

// packages
//#import "@preview/clean-math-thesis:0.2.0": mathcounter
#import "@preview/great-theorems:0.1.1": *
#import "@preview/headcount:0.1.0": *
#import "../../lib.typ": *

// local
#import "colors.typ": *

#let my_mathblock = mathblock.with(
  radius: 0.3em,
  inset: 0.8em,
  counter: mathcounter,
  numbering: dependent-numbering("1.1"),
  breakable: false,
  titlix: title => [(#title):],
)

// theorem etc. settings
#let theorem = my_mathblock(
  blocktitle: "Theorem",
  fill: color1.lighten(90%),
  stroke: color1.darken(20%),
)

#let proposition = my_mathblock(
  blocktitle: "Proposition",
  fill: color2.lighten(90%),
  stroke: color2.darken(20%),
)

#let corollary = my_mathblock(
  blocktitle: "Corollary",
  fill: color3.lighten(90%),
  stroke: color3.darken(20%),
)

#let lemma = my_mathblock(
  blocktitle: "Lemma",
  fill: color4.lighten(90%),
  stroke: color4.darken(20%),
)

#let definition = my_mathblock(
  blocktitle: "Definition",
  fill: color5.lighten(95%),
  stroke: color5.darken(20%),
)

#let remark = my_mathblock(
  blocktitle: "Remark",
  fill: color1.lighten(90%),
  stroke: color1.darken(20%),
)

#let reminder = my_mathblock(
  blocktitle: "Reminder",
  fill: color3.lighten(90%),
  stroke: color3.darken(20%),
)

#let example = my_mathblock(
  blocktitle: "Example",
  fill: color2.lighten(90%),
  stroke: color2.darken(20%),
)

#let question = my_mathblock(
  blocktitle: "Question",
  fill: color3.lighten(75%),
  stroke: color3.darken(20%),
)

#let proof = proofblock()
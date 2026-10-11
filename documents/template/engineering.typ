// Elan8 house layout: A4, branded title page, outline, numbered headings.
// Adapted from the layout Doc42 ships (`doc42 template export sds`). It uses only the fonts
// bundled with Doc42; put font files in `fonts/` to use others.

#import "/doc42.typ": doc42-body, doc42-navy, doc42-teal, doc42-ink, doc42-muted, doc42-rule

#let engineering-document(doc) = [
#let meta = doc.meta
#let field(name) = meta.at(name, default: none)
#let kind = field("subtitle")
#let brand = rgb("#0f766e")

#set document(title: meta.title)
#set text(font: "Libertinus Serif", size: 10.5pt, fill: doc42-ink, lang: "en")
#set par(justify: true, leading: 0.65em)
#set heading(numbering: "1.1")
#show heading.where(level: 1): set text(size: 16pt, weight: "bold", fill: doc42-navy)
#show heading.where(level: 2): set text(size: 12pt, weight: "bold", fill: doc42-teal)
#show heading.where(level: 3): set text(size: 11pt, weight: "bold", fill: doc42-navy)
#show raw: set text(font: "DejaVu Sans Mono", size: 9pt)
#show figure.caption: set text(size: 9pt, fill: doc42-muted)
// A table may continue on the next page; its header row repeats there.
#show figure.where(kind: table): set block(breakable: true)

#set page(
  paper: "a4",
  margin: (top: 20mm, bottom: 18mm, x: 18mm),
  header: context {
    if counter(page).get().first() > 1 {
      set text(size: 8pt, fill: doc42-muted)
      grid(
        columns: (1fr, auto),
        [#meta.title],
        [
          #if field("number") != none { field("number") }
          #if field("revision") != none [ · Rev #field("revision")]
        ],
      )
      line(length: 100%, stroke: 0.6pt + doc42-teal)
    }
  },
  footer: context {
    if counter(page).get().first() > 1 {
      set text(size: 8pt, fill: doc42-muted)
      line(length: 100%, stroke: 0.5pt + doc42-rule)
      grid(
        columns: (1fr, auto),
        [
          #if field("organization") != none { field("organization") }
          #if field("organization") != none and field("status") != none [ · ]
          #if field("status") != none { field("status") }
        ],
        [Page #counter(page).display()],
      )
    }
  },
)

// Title page. The cover is A4, like every following page.
#page(header: none, footer: none)[
  #set par(justify: false)
  #set text(hyphenate: false)
  #place(top + left, dx: -18mm, dy: -20mm, rect(width: 210mm, height: 9mm, fill: brand))
  #v(6mm)
  #text(size: 20pt, weight: "bold", fill: brand, tracking: 0.12em, "ELAN8")
  #h(3mm)
  #text(size: 9pt, fill: doc42-muted, "Model-based systems engineering")
  #v(12%)
  #align(center)[
    #if kind != none {
      text(size: 11pt, weight: "bold", fill: doc42-teal, tracking: 0.06em, upper(kind))
      v(8mm)
    }
    #text(size: 26pt, weight: "bold", fill: doc42-navy, meta.title)
    #v(10mm)
    #line(length: 72%, stroke: 1.2pt + doc42-teal)
  ]
  #v(14mm)
  #let rows = (
    ("Prepared by", field("organization")),
    ("Document number", field("number")),
    ("Revision", field("revision")),
    ("Status", field("status")),
  ).filter(row => row.at(1) != none)
  #grid(
    columns: (42mm, 1fr),
    row-gutter: 4mm,
    ..rows.map(row => (text(weight: "bold", fill: doc42-navy, row.at(0)), row.at(1))).flatten(),
  )
  #v(1fr)
  #text(size: 8.5pt, fill: doc42-muted)[
    Generated from the SysML v2 model of the robot with Doc42. Tables, values and diagrams are
    read from the model at this revision; do not edit this document by hand.
  ]
]

#outline(depth: 3)
#pagebreak()

#doc42-body(doc)

]

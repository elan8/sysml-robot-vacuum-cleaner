// Elan8 house style for engineering documents, after the Elan8 style guide: Inter, the cyan
// primary palette, near-black text on white, restrained and technical.
//
// Fonts are the Inter files in `fonts/` (SIL Open Font License, see INTER-LICENSE.txt); the logo
// is `assets/elan8-logo.svg`. Content comes from Doc42 as data and is rendered by `/doc42.typ`.

#import "/doc42.typ": doc42-body, doc42-theme

// Style guide colours.
#let primary-50 = rgb("#ecfeff")
#let primary-600 = rgb("#0891b2")
#let primary-800 = rgb("#155e75")
#let primary-900 = rgb("#164e63")
#let gray-50 = rgb("#f9fafb")
#let gray-200 = rgb("#e5e7eb")
#let gray-600 = rgb("#4b5563")
#let gray-700 = rgb("#374151")
#let gray-900 = rgb("#111827")

#let logo(height) = image("/assets/elan8-logo.svg", height: height)

// The logo with the company name beside it.
#let wordmark(height) = box(baseline: 22%, grid(
  columns: 2,
  column-gutter: height * 0.32,
  align: horizon,
  logo(height),
  text(size: height * 0.78, weight: "bold", fill: gray-900, tracking: -0.01em, "Elan8"),
))

#let elan8-document(doc) = [
#let meta = doc.meta
#let field(name) = meta.at(name, default: none)
#let kind = field("subtitle")

#set document(title: meta.title, author: field("organization"))
#set text(font: "Inter", size: 9.5pt, fill: gray-700, lang: "en")
#set par(justify: false, leading: 0.68em, spacing: 1.05em)
#set list(indent: 2pt, marker: text(fill: primary-600, sym.bullet))
#set enum(indent: 2pt)
#set heading(numbering: "1.1")
#show heading: set block(sticky: true)
#show heading.where(level: 1): it => block(above: 9mm, below: 4.5mm, {
  set text(size: 17pt, weight: "bold", fill: gray-900)
  if it.numbering != none {
    text(fill: primary-600, counter(heading).display(it.numbering))
    h(3mm)
  }
  it.body
})
#show heading.where(level: 2): set text(size: 12.5pt, weight: "semibold", fill: gray-900)
#show heading.where(level: 2): set block(above: 7mm, below: 3.5mm)
#show heading.where(level: 3): set text(size: 10.5pt, weight: "semibold", fill: primary-800)
#show heading.where(level: 3): set block(above: 5mm, below: 3mm)
#show raw: set text(font: "DejaVu Sans Mono", size: 8.5pt)
#show link: set text(fill: primary-600)
#show figure.caption: set text(size: 8.5pt, fill: gray-600)
#show figure: set block(above: 5mm, below: 5mm)
// A table may continue on the next page; its header row repeats there.
#show figure.where(kind: table): set block(breakable: true)
#show outline.entry.where(level: 1): set text(weight: "semibold", fill: gray-900)
#show outline.entry.where(level: 1): set block(above: 3.2mm)

// Generated tables, quotes and code blocks take their colours from the house palette.
#doc42-theme.update(theme => {
  theme.table-header = primary-800
  theme.table-header-text = white
  theme.table-stripe = gray-50
  theme.table-rule = gray-200
  theme.quote-rule = primary-600
  theme.quote-text = gray-600
  theme.code-fill = gray-50
  theme
})

#set page(
  paper: "a4",
  margin: (top: 26mm, bottom: 22mm, x: 20mm),
  header: context {
    if counter(page).get().first() > 1 {
      set text(size: 8pt, fill: gray-600)
      grid(
        columns: (auto, 1fr, auto),
        column-gutter: 3mm,
        align: horizon,
        logo(5.2mm),
        [#text(weight: "semibold", fill: gray-900, meta.title)#if kind != none [ · #kind]],
        [
          #if field("number") != none { field("number") }
          #if field("revision") != none [ · Rev #field("revision")]
        ],
      )
      v(-1.5mm)
      line(length: 100%, stroke: 0.5pt + gray-200)
    }
  },
  footer: context {
    if counter(page).get().first() > 1 {
      set text(size: 8pt, fill: gray-600)
      line(length: 100%, stroke: 0.5pt + gray-200)
      v(-1.5mm)
      grid(
        columns: (1fr, auto),
        [
          #if field("organization") != none { field("organization") }
          #if field("organization") != none and field("status") != none [ · ]
          #if field("status") != none { field("status") }
        ],
        [Page #counter(page).display() of #context counter(page).final().first()],
      )
    }
  },
)

// Cover.
#page(header: none, footer: none, margin: (top: 22mm, bottom: 20mm, x: 22mm))[
  #set par(justify: false)
  #set text(hyphenate: false)
  #wordmark(11mm)
  #v(58mm)
  #if kind != none {
    text(size: 10.5pt, weight: "semibold", fill: primary-600, tracking: 0.08em, upper(kind))
    v(3mm)
  }
  #text(size: 30pt, weight: "bold", fill: gray-900, tracking: -0.015em, meta.title)
  #v(7mm)
  #line(length: 34mm, stroke: 2.2pt + primary-600)
  #v(16mm)
  #let rows = (
    ("Document number", field("number")),
    ("Revision", field("revision")),
    ("Status", field("status")),
    ("Prepared by", field("organization")),
  ).filter(row => row.at(1) != none)
  #grid(
    columns: (40mm, 1fr),
    row-gutter: 4.2mm,
    ..rows.map(row => (
      text(size: 9pt, fill: gray-600, row.at(0)),
      text(size: 10pt, weight: "medium", fill: gray-900, row.at(1)),
    )).flatten(),
  )
  #v(1fr)
  #line(length: 100%, stroke: 0.5pt + gray-200)
  #v(1mm)
  #text(size: 8pt, fill: gray-600)[
    Generated from the SysML v2 model of the product with Doc42. Tables, values and diagrams are
    read from the model at this revision; change the model, not this document.
  ]
]

#outline(depth: 2, indent: 5mm)
#pagebreak()

#doc42-body(doc)

]

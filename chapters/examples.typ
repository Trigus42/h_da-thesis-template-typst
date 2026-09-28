#import "../template.typ": theorem, proof, thesis-listing, thesis-table

= Ein weiteres Kapitel

Aliquam facilisis convallis nibh. Ut accumsan malesuada nisi, eget luctus ante dignissim at. Integer dignissim rutrum feugiat. Mauris sit amet leo id ligula fringilla pharetra. Suspendisse egestas imperdiet nulla, in blandit dolor venenatis vel.

== Listen

- Enumeration with bullets
- Cras cursus ligula et tellus viverra sit amet accumsan orci consequat.
- Etiam a orci tellus. Cum sociis natoque penatibus et magnis dis parturient montes.

+ Enumeration with small numbers
+ Nulla dapibus, ante ac sagittis molestie, neque nulla venenatis turpis.
+ Nunc ut tortor massa. Fusce ullamcorper mauris eget tellus egestas faucibus.

== Grafiken

Morbi magna augue, scelerisque in eleifend a, tristique vitae lorem. Vivamus non elementum nisi.

=== Einfache Grafiken

#figure(image("../assets/setup.pdf", width: 50%), caption: [Dies ist eine einfache Grafik])

Aenean blandit neque eget nunc euismod ac dignissim enim euismod. Nullam semper, orci vitae elementum pretium, est lorem sodales justo.

=== Grafiken mit Subfloat

#figure(
  grid(
    columns: (1fr, 1fr), gutter: 6mm,
    image("../assets/qq-plot_gaus_vs_160.pdf", width: 100%),
    image("../assets/pdf_gaus_vs_uni_vs_10_40_160.pdf", width: 100%),
    image("../assets/pdf_gaus_vs_uni_vs_10_40_160.pdf", width: 100%),
    image("../assets/qq-plot_gaus_vs_160.pdf", width: 100%),
  ),
  caption: [Mehrere Grafiken lassen sich neben- und untereinander darstellen.],
)

== Tabellen

#thesis-table(
  table(
    columns: (1.7fr, 1fr, 1fr),
    align: (left, center, center),
    stroke: (x: none, y: 0.45pt),
    inset: 5pt,
    table.header([*Messung*], [*Mittelwert*], [*Varianz*]),
    [Versuchsreihe A], [12,4], [0,42],
    [Versuchsreihe B], [13,1], [0,37],
    [Versuchsreihe C], [11,9], [0,51],
  ),
  caption: [Beispiel einer Tabelle ohne vertikale Linien],
)

== Listings

#thesis-listing(
  ```typ
  #let square(x) = x * x
  #for value in range(1, 5) {
    [The square of #value is #square(value).]
  }
  ```,
  caption: [Ein einfaches Typst-Listing],
)

== Equations

Das Ohmsche Gesetz lautet $U = R dot I$ und entsprechend $I = U/R$.

$ P(K = k | l) = P(sum_(i=1)^(M-1) K_i = k | l). $ <pmf-equation>

== Theorem and Proof

#theorem(title: "Gaussian approximation")[Let the $b_i(j)$ be independent and identically distributed random variables with mean $mu$ and variance $sigma^2$. For large $k$ and $l$, @pmf-equation is approximately Gaussian.]

#proof[For $M = 2$, expansion and normalization followed by the central limit theorem gives the result.]

== Glossary

The Central Limit Theorem, normal distribution, i.i.d. variables, variance, and probability mass functions are listed in the glossary.

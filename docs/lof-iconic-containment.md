# Iconic and Symbolic Containment in *Laws of Form* (LoF)

This note aligns William Bricken’s “Iconic and Symbolic Containment in Laws of Form” (Dec 2009) with `dm6-elm`’s `Feature.Diagram.LoF`.

## TL;DR (synopsis)
LoF can be read as a calculus of containment. Icons (boxes) *look like* containment; symbols encode it as strings. We use one AST (`LoF`) to render both:
- **Symbolic**: `()` for a box; juxtaposition as space; `∅` for void.
- **Iconic**: nested rectangles (our existing SVG).

## Mapping
- `Void` → semantic “unmarked state”; symbolic `∅`; iconic “empty space”.
- `Box x` → containment of `x`; symbolic `(x)`; iconic “a box around x`.
- `Juxt [a,b,…]` → parallel placement; symbolic `a b …`; iconic “siblings”.

## Notes
- Variables in iconic form stand for *patterns* (zero/one/many); in symbolic form for *single expressions*. Our `LoF` keeps them uniform as an Elm ADT, with renderers choosing the presentation.
- The rewrite functions in `Feature.Diagram.LoF` operate on the AST and are representation-neutral; they apply equally to symbolic and iconic views.

## Demo
See `Feature.Diagram.LoFIconic.viewSideBySide` which shows `(symbolic string)` ⇄ (iconic SVG) for `callingExample` and `crossingExample`.

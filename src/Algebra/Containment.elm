module Algebra.Containment exposing
    ( Depth(..)
    , andThen
      -- alias for within (use instead of (</>))
    , fromDepth
    , times
      -- repeated containment (multiplication-like)
    , toDepth
    , within
      -- combine containments (addition-like)
    )

import Model exposing (MapId, MapPath)



-- Depth = how many containers deep you are


type Depth
    = Depth Int



-- combine two containments: Depth a ⊕ Depth b = Depth (a + b)


within : Depth -> Depth -> Depth
within (Depth a) (Depth b) =
    Depth (a + b)



-- alias for within; use this instead of a custom operator


andThen : Depth -> Depth -> Depth
andThen =
    within



-- repeated containment: Depth a ⊗ Depth b = Depth (a * b)


times : Depth -> Depth -> Depth
times (Depth a) (Depth b) =
    Depth (a * b)



-- convert a MapPath to a Depth by counting segments


toDepth : MapPath -> Depth
toDepth path =
    Depth (List.length path)



-- build a synthetic path of given depth under a base MapId
-- (Adjust to your real path-construction as needed.)


fromDepth : Depth -> MapId -> MapPath
fromDepth (Depth n) base =
    List.repeat n base

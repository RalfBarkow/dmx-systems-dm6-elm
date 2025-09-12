module Algebra.Containment exposing
    ( (</>)
    , Depth(..)
      -- conversions from MapPath
    , fromDepth
      -- repeated containment (multiplication-like)
    , times
      -- conversions to MapPath
    , toDepth
      -- containment composition (addition-like)
    , within
    )

import Model exposing (MapId, MapPath)



-- A canonical measure of containment (how many boundaries you’re inside).


type Depth
    = Depth Int


within : Depth -> Depth -> Depth
within (Depth a) (Depth b) =
    Depth (a + b)



-- “addition” = compose containments


(</>) : Depth -> Depth -> Depth
(</>) =
    within


times : Depth -> Depth -> Depth
times (Depth a) (Depth b) =
    Depth (a * b)



-- “multiplication” = repeated containment


toDepth : MapPath -> Depth
toDepth path =
    Depth (List.length path)


fromDepth : Depth -> MapId -> MapPath
fromDepth (Depth n) base =
    -- make a synthetic path n deep under `base`.
    -- Real app: compute/ensure actual descendant ids (ensureMap).
    List.repeat n base

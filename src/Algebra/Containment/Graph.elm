module Algebra.Containment.Graph exposing
    ( isDescendantUsing
    , wouldCreateCycleUsing
    )

import Set exposing (Set)


isDescendantUsing :
    (comparable -> model -> List comparable)
    -> comparable
    -> comparable
    -> model
    -> Bool
isDescendantUsing children root target model =
    let
        go : List comparable -> Set comparable -> Bool
        go queue seen =
            case queue of
                [] ->
                    False

                x :: xs ->
                    if x == target then
                        True

                    else if Set.member x seen then
                        go xs seen

                    else
                        go (children x model ++ xs) (Set.insert x seen)
    in
    go (children root model) Set.empty


wouldCreateCycleUsing :
    (comparable -> model -> List comparable)
    -> { dragged : comparable, target : comparable }
    -> model
    -> Bool
wouldCreateCycleUsing children { dragged, target } model =
    dragged == target || isDescendantUsing children dragged target model

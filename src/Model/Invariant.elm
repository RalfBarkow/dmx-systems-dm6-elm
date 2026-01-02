module Model.Invariant exposing (hasSelfContainment, offendingSelfContainers)

import Dict exposing (Dict)
import Model exposing (Box, BoxId)


{-| Return all map ids that list themselves among their items.
-}
offendingSelfContainers : Dict BoxId Box -> List BoxId
offendingSelfContainers boxes =
    boxes
        |> Dict.foldl
            (\boxId box acc ->
                if Dict.member boxId box.items then
                    boxId :: acc

                else
                    acc
            )
            []
        |> List.reverse


{-| Convenience boolean.
-}
hasSelfContainment : Dict BoxId Box -> Bool
hasSelfContainment boxes =
    not (List.isEmpty (offendingSelfContainers boxes))

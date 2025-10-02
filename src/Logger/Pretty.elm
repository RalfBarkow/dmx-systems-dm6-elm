module Logger.Pretty exposing (summarizeModel)

import AppMain exposing (Model)
import Dict
import Domain.Id exposing (labelMap)


summarizeModel : Model -> String
summarizeModel m =
    let
        mapCounts =
            Dict.toList m.maps
                |> List.map (\( mid, mp ) -> labelMap mid ++ ":" ++ String.fromInt (Dict.size mp.items))
                |> String.join ", "

        pathStr =
            m.mapPath |> List.map String.fromInt |> String.join "→"
    in
    String.join " | "
        [ "maps=" ++ String.fromInt (Dict.size m.maps) ++ " [" ++ mapCounts ++ "]"
        , "items=" ++ String.fromInt (Dict.size m.items)
        , "story=" ++ (List.length m.fedWiki.storyItemIds |> String.fromInt)
        , "path=" ++ pathStr
        ]

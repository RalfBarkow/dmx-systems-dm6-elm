module Feature.Diagram.LoFIconic exposing
    ( toSymbolic
    , viewSideBySide
    , viewSymbolic
    )

import Feature.Diagram.LoF as LoF exposing (LoF(..), viewStructure)
import Html exposing (Html, div, pre, text)
import Html.Attributes as HA
import Svg exposing (Svg)


{-| Symbolic rendering:
Void -> ∅
Box x -> ( <x> )
Juxt [a,b,..] -> <a> <b> ...
-}
toSymbolic : LoF -> String
toSymbolic lof =
    let
        go t =
            case t of
                Void ->
                    "∅"

                Box x ->
                    "(" ++ go x ++ ")"

                Juxt xs ->
                    case xs of
                        [] ->
                            "∅"

                        _ ->
                            String.join " " (List.map go xs)
    in
    go lof


viewSymbolic : LoF -> Html msg
viewSymbolic lof =
    pre [ HA.style "margin" "0", HA.style "font-size" "14px" ]
        [ text (toSymbolic lof) ]


{-| Iconic rendering delegates to existing LoF.viewStructure.
-}
viewIconic : LoF -> Svg msg
viewIconic =
    viewStructure


{-| Simple side-by-side panel for any LoF value.
-}
viewSideBySide : { title : String, term : LoF } -> Html msg
viewSideBySide { title, term } =
    div
        [ HA.style "display" "grid"
        , HA.style "grid-template-columns" "1fr 1fr"
        , HA.style "gap" "16px"
        , HA.style "align-items" "start"
        ]
        [ -- symbolic
          div
            [ HA.style "padding" "12px"
            , HA.style "border" "1px solid #444"
            , HA.style "border-radius" "8px"
            , HA.style "background" "var(--surface, #111)"
            ]
            [ Html.h3 [] [ text (title ++ " — symbolic") ]
            , viewSymbolic term
            ]
        , -- iconic
          div
            [ HA.style "padding" "12px"
            , HA.style "border" "1px solid #444"
            , HA.style "border-radius" "8px"
            , HA.style "background" "var(--surface, #111)"
            , HA.style "overflow" "auto"
            ]
            [ Html.h3 [] [ text (title ++ " — iconic") ]
            , Svg.svg
                [ HA.attribute "viewBox" "0 0 600 400"
                , HA.style "width" "100%"
                , HA.style "height" "auto"
                ]
                [ viewIconic term ]
            ]
        ]

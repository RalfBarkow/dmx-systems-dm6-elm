module Feature.Cross exposing (Msg(..), view)

import Html exposing (Html, button, text)
import Html.Attributes as Attr
import Html.Events exposing (onClick)



-- Local message type for this feature


type Msg
    = CrossClick



-- The button view


view : Html Msg
view =
    button
        [ Attr.id "btn-Cross"
        , onClick CrossClick
        ]
        [ text "Cross" ]



-- ensure the button includes the id "btn-Cross"


crossButton : Model -> Html Msg
crossButton model =
    let
        enabled =
            isEnabled model

        -- whatever your logic is
    in
    button
        ([ Attr.id "btn-Cross"
         , Attr.style "font-family" "sans-serif"
         , Attr.style "font-size" "14px"
         ]
            ++ (if enabled then
                    [ onClick CrossClicked ]

                else
                    [ Attr.disabled True ]
               )
        )
        [ text "Cross" ]

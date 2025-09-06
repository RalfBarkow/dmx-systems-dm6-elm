module IconMenuAPI exposing
    ( closeIconMenu
    , openIconMenu
    , setIcon
    , updateIconMenu
    , viewIcon
    , viewIconMenu
    , viewTopicIcon
    )

import AppModel as AM
import Dict
import FeatherIcons as Icon
import Html as H
import Html.Attributes as HA
import Html.Events as HE
import IconMenu as IM exposing (IconMenuMsg(..))
import Json.Decode as D
import Model as M exposing (IconName, Id)
import String exposing (fromFloat)


viewIcon : String -> Float -> H.Html msg
viewIcon iconName sizePx =
    case Dict.get iconName Icon.icons of
        Just icon ->
            icon |> Icon.withSize sizePx |> Icon.toHtml []

        Nothing ->
            H.text "??"



-- VIEW ----------------------------------------------------------------------


{-| Small button that sits on the topic and opens the icon menu.
-}
viewTopicIcon : M.Id -> AM.Model -> H.Html AM.Msg
viewTopicIcon topicId model =
    let
        titleText =
            "Choose icon"
    in
    H.button
        ([ HE.onClick (AM.IconMenu IM.Open)
         , HA.title titleText
         ]
            ++ topicIconStyle
        )
        [ H.text "…"
        ]


{-| Overlay panel with icon choices. Only rendered when menu is open.
-}
viewIconMenu : AM.Model -> List (H.Html AM.Msg)
viewIconMenu model =
    if model.iconMenu.open then
        [ H.div
            (iconMenuStyle ++ [ onContextMenuPrevent (AM.IconMenu IM.Close) ])
            [ H.div closeButtonStyle
                [ H.button [ HE.onClick (AM.IconMenu IM.Close) ] [ H.text "×" ] ]
            , H.div (iconListStyle ++ [ HA.title "Pick an icon" ])
                viewIconList
            ]
        ]

    else
        []



-- A tiny “catalog” of icon names for now. Swap with your real list later.


viewIconList : List (H.Html AM.Msg)
viewIconList =
    let
        iconNames : List IconName
        iconNames =
            [ "circle", "square", "triangle", "star", "note" ]

        viewOne iconName =
            H.button
                ([ HE.onClick (AM.IconMenu (IM.SetIcon (Just iconName)))
                 , HA.title iconName
                 ]
                    ++ iconButtonStyle
                )
                [ viewIcon iconName 18 ]
    in
    List.map viewOne iconNames



-- STYLE ---------------------------------------------------------------------


iconMenuStyle : List (H.Attribute AM.Msg)
iconMenuStyle =
    [ HA.style "position" "absolute"
    , HA.style "top" "291px"
    , HA.style "width" "320px"
    , HA.style "height" "320px"
    , HA.style "background-color" "white"
    , HA.style "border" "1px solid lightgray"
    , HA.style "z-index" "1"
    ]


iconListStyle : List (H.Attribute AM.Msg)
iconListStyle =
    [ HA.style "height" "100%"
    , HA.style "overflow" "auto"
    ]


closeButtonStyle : List (H.Attribute AM.Msg)
closeButtonStyle =
    [ HA.style "position" "absolute"
    , HA.style "top" "0"
    , HA.style "right" "0"
    ]


iconButtonStyle : List (H.Attribute AM.Msg)
iconButtonStyle =
    [ HA.style "border-width" "0"
    , HA.style "margin" "8px"
    ]


topicIconStyle : List (H.Attribute AM.Msg)
topicIconStyle =
    [ HA.style "position" "relative"
    , HA.style "top" "0px"
    , HA.style "left" "0px"
    , HA.style "color" "white"
    ]



-- EVENTS --------------------------------------------------------------------


{-| Prevent native context menu if you wire this to `onContextMenu`.
-}
onContextMenuPrevent : msg -> H.Attribute msg
onContextMenuPrevent msg =
    HE.custom "contextmenu"
        (D.succeed
            { message = msg
            , stopPropagation = True
            , preventDefault = True
            }
        )



-- UPDATE --------------------------------------------------------------------


updateIconMenu : IM.IconMenuMsg -> AM.Model -> ( AM.Model, Cmd AM.Msg )
updateIconMenu msg model =
    case msg of
        IM.Open ->
            ( openIconMenu model, Cmd.none )

        IM.Close ->
            ( closeIconMenu model, Cmd.none )

        IM.SetIcon maybeIcon ->
            ( setIcon maybeIcon model, Cmd.none )

        -- new constructors — safe defaults for now
        IM.OpenAt _ _ ->
            ( openIconMenu model, Cmd.none )

        IM.Hover _ ->
            ( model, Cmd.none )

        IM.Pick _ ->
            ( model, Cmd.none )

        IM.Picked action ->
            -- if you later map actions to real AM.Msg, do it here
            ( closeIconMenu model, Cmd.none )

        IM.OutsideClick ->
            ( closeIconMenu model, Cmd.none )

        IM.KeyDown key ->
            if key == "Escape" then
                ( closeIconMenu model, Cmd.none )

            else
                ( model, Cmd.none )

        IM.NoOp ->
            ( model, Cmd.none )


openIconMenu : AM.Model -> AM.Model
openIconMenu model =
    let
        m =
            model.iconMenu
    in
    { model | iconMenu = { m | open = True } }


closeIconMenu : AM.Model -> AM.Model
closeIconMenu model =
    let
        m =
            model.iconMenu
    in
    { model | iconMenu = { m | open = False } }


setIcon : Maybe M.IconName -> AM.Model -> AM.Model
setIcon maybeIcon model =
    let
        m =
            model.iconMenu
    in
    -- TODO: apply icon selection to topic; for now just close the menu
    { model | iconMenu = { m | open = False } }

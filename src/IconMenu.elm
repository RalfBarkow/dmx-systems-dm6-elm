module IconMenu exposing
    ( IconMenuModel
    , IconMenuMsg(..)
    , close
    , iconMenuOverlay
      -- <- optional alias for your API stability
    , init
    , openAt
    , update
    , view
      -- <- add
    )

-- use H.text to avoid ambiguity

import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Json.Decode as D
import Svg as S
import Svg.Attributes as SA
import Task



-- PUBLIC TYPES


type alias Point =
    { x : Float, y : Float }


type alias IconMenuModel =
    { open : Bool
    , center : Point
    , topicId : Maybe Int
    , hover : Maybe Int
    , icon : Maybe IconName
    }


type alias IconName =
    String


type Action
    = ShowDetails
    | ShowRelated
    | Edit
    | Hide
    | Delete


type IconMenuMsg
    = Open -- (back-compat) opens at last center
    | Close
    | SetIcon (Maybe IconName)
    | OpenAt Int Point -- open on a topic at screen coords
    | Hover (Maybe Int) -- highlight wedge index
    | Pick Int -- click wedge index
    | Picked Action -- bubble chosen action outward
    | OutsideClick
    | KeyDown String
    | NoOp



-- MODEL


init : IconMenuModel
init =
    { open = False
    , center = { x = 0, y = 0 }
    , topicId = Nothing
    , hover = Nothing
    , icon = Nothing
    }


openAt : Int -> Point -> IconMenuModel -> IconMenuModel
openAt tid p m =
    { m | open = True, center = p, topicId = Just tid, hover = Nothing }


close : IconMenuModel -> IconMenuModel
close m =
    { m | open = False, hover = Nothing }



-- UPDATE


update : IconMenuMsg -> IconMenuModel -> ( IconMenuModel, Cmd IconMenuMsg )
update msg m =
    case msg of
        Open ->
            ( { m | open = True }, Cmd.none )

        Close ->
            ( close m, Cmd.none )

        SetIcon mi ->
            ( { m | icon = mi }, Cmd.none )

        OpenAt tid p ->
            ( openAt tid p m, Cmd.none )

        Hover hi ->
            ( { m | hover = hi }, Cmd.none )

        Pick i ->
            ( close m
            , Task.succeed ()
                |> Task.perform (\_ -> Picked (actionAt i))
            )

        OutsideClick ->
            ( close m, Cmd.none )

        KeyDown key ->
            if not m.open then
                ( m, Cmd.none )

            else
                case key of
                    "Escape" ->
                        ( close m, Cmd.none )

                    "ArrowLeft" ->
                        ( { m | hover = Just (cycleIndex -1 m.hover) }, Cmd.none )

                    "ArrowRight" ->
                        ( { m | hover = Just (cycleIndex 1 m.hover) }, Cmd.none )

                    "Enter" ->
                        case m.hover of
                            Just i ->
                                ( close m
                                , Task.succeed ()
                                    |> Task.perform (\_ -> Picked (actionAt i))
                                )

                            Nothing ->
                                ( m, Cmd.none )

                    _ ->
                        ( m, Cmd.none )

        Picked _ ->
            -- this goes to Main via App Msg; nothing to do locally
            ( m, Cmd.none )

        NoOp ->
            ( m, Cmd.none )



-- VIEW (full-screen overlay with an SVG ring)


view : IconMenuModel -> H.Html IconMenuMsg
view m =
    if m.open then
        -- TODO render your overlay/menu here
        H.text ""

    else
        H.text ""


iconMenuOverlay : IconMenuModel -> H.Html IconMenuMsg
iconMenuOverlay =
    view


viewOverlay : IconMenuModel -> H.Html IconMenuMsg
viewOverlay m =
    if not m.open then
        H.text ""
        -- was: text ""

    else
        H.div
            [ HA.style "position" "fixed"
            , HA.style "inset" "0"
            , HA.style "z-index" "9999"
            , onContextMenuPrevent OutsideClick
            , HE.onClick OutsideClick
            ]
            [ S.svg
                [ SA.width "100%"
                , SA.height "100%"
                , SA.viewBox "0 0 1 1"
                , HA.style "pointer-events" "none"
                ]
                [ S.g
                    [ SA.transform <| "translate(" ++ f m.center.x ++ "," ++ f m.center.y ++ ")"
                    ]
                    (ring m)
                ]
            ]



-- PIE GEOMETRY / RENDERING


outerR : Float
outerR =
    96


innerR : Float
innerR =
    34


gapDeg : Float
gapDeg =
    2


wedgeActions : List ( Action, String )
wedgeActions =
    [ ( ShowDetails, "Details" )
    , ( ShowRelated, "Related" )
    , ( Edit, "Edit" )
    , ( Hide, "Hide" )
    , ( Delete, "Delete" )
    ]


ring : IconMenuModel -> List (S.Svg IconMenuMsg)
ring m =
    let
        n =
            List.length wedgeActions

        span =
            360 / toFloat n
    in
    List.indexedMap
        (\i ( act, label ) ->
            let
                a0 =
                    toFloat i * span + gapDeg / 2

                a1 =
                    toFloat (i + 1) * span - gapDeg / 2

                hot =
                    m.hover == Just i

                seg =
                    S.path
                        [ SA.d (annularWedge innerR outerR a0 a1)
                        , SA.fill
                            (if hot then
                                "#3d8bfd"

                             else
                                "#555"
                            )
                        , SA.fillOpacity
                            (if hot then
                                "0.90"

                             else
                                "1"
                            )
                        , SA.stroke "white"
                        , SA.strokeWidth "2"
                        , SA.pointerEvents "auto"
                        , HE.onMouseEnter (Hover (Just i))
                        , HE.onMouseLeave (Hover Nothing)
                        , HE.onClick (Pick i)
                        ]
                        []

                mid =
                    (a0 + a1) / 2

                rLab =
                    (innerR + outerR) / 2

                pos =
                    polar rLab mid

                lbl =
                    S.text_
                        [ SA.x (f pos.x)
                        , SA.y (f pos.y)
                        , SA.textAnchor "middle"
                        , SA.dominantBaseline "central"
                        , SA.fontFamily "system-ui"
                        , SA.fontSize "13px"
                        , SA.fill "white"
                        , SA.pointerEvents "none"
                        ]
                        [ S.text label ]
            in
            [ seg, lbl ]
        )
        wedgeActions
        |> List.concat



-- HELPERS


actionAt : Int -> Action
actionAt i =
    wedgeActions
        |> List.drop (modBy (List.length wedgeActions) i)
        |> List.head
        |> Maybe.map Tuple.first
        |> Maybe.withDefault ShowDetails


cycleIndex : Int -> Maybe Int -> Int
cycleIndex step mIdx =
    let
        n =
            List.length wedgeActions

        base =
            Maybe.withDefault 0 mIdx
    in
    modBy n (base + step)


polar : Float -> Float -> { x : Float, y : Float }
polar r angDeg =
    let
        t =
            angDeg * pi / 180
    in
    { x = r * cos t, y = -r * sin t }


annularWedge : Float -> Float -> Float -> Float -> String
annularWedge r0 r1 a0 a1 =
    let
        large =
            if abs (a1 - a0) > 180 then
                "1"

            else
                "0"

        p0o =
            polar r1 a0

        p1o =
            polar r1 a1

        p1i =
            polar r0 a1

        p0i =
            polar r0 a0
    in
    "M "
        ++ at p0o
        ++ " A "
        ++ f r1
        ++ " "
        ++ f r1
        ++ " 0 "
        ++ large
        ++ " 0 "
        ++ at p1o
        ++ " L "
        ++ at p1i
        ++ " A "
        ++ f r0
        ++ " "
        ++ f r0
        ++ " 0 "
        ++ large
        ++ " 1 "
        ++ at p0i
        ++ " Z"


at : { x : Float, y : Float } -> String
at p =
    f p.x ++ " " ++ f p.y


f : Float -> String
f =
    String.fromFloat


onContextMenuPrevent : msg -> H.Attribute msg
onContextMenuPrevent msg =
    HE.custom "contextmenu"
        (D.succeed
            { message = msg
            , stopPropagation = True
            , preventDefault = True
            }
        )


onContextMenuAt : (Float -> Float -> msg) -> H.Attribute msg
onContextMenuAt tagger =
    HE.custom "contextmenu"
        (D.map2
            (\x y ->
                { message = tagger x y
                , stopPropagation = True
                , preventDefault = True
                }
            )
            (D.field "clientX" D.float)
            (D.field "clientY" D.float)
        )

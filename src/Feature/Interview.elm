port module Feature.Interview exposing
    ( Model
    , Msg(..)
    , init
    , subscriptions
    , update
    , view
    )

import Html exposing (Html, button, div, input, label, span, text, textarea)
import Html.Attributes as HA
import Html.Events as HE
import Http
import Json.Decode as D
import Json.Encode as E
import Regex
import String



-- PORTS


port requestContext : () -> Cmd msg


port receiveContext : (D.Value -> msg) -> Sub msg


port requestInterviewMarkdowns : E.Value -> Cmd msg


port receiveInterviewMarkdowns : (List String -> msg) -> Sub msg


port frameLink : E.Value -> Cmd msg


port frameOpen : E.Value -> Cmd msg



-- TYPES


type alias Context =
    { site : String
    , title : String
    }


type alias Choice =
    { option : String
    , next : Maybe String
    }


type alias Ask =
    { summary : String
    , details : String
    , choices : List Choice
    }


type alias Place =
    { site : String
    , title : String
    , step : Int
    , ask : Maybe Ask
    , report : Maybe String
    , value : Maybe String
    }


type alias Model =
    { ctx : Maybe Context
    , path : List Place
    , asks : List Ask
    , loading : Bool
    , error : Maybe String
    }


type Msg
    = GotContext D.Value
    | FetchedPage Place (Result Http.Error Page)
    | GotInterview (List String)
    | ToggleWhy Int
    | Choose Int String
    | EditText Int String
    | Next Int
    | Save



-- INIT / SUBS


init : () -> ( Model, Cmd Msg )
init _ =
    ( { ctx = Nothing, path = [], asks = [], loading = True, error = Nothing }
    , requestContext ()
    )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ receiveContext GotContext
        , receiveInterviewMarkdowns GotInterview
        ]



-- HELPERS


re : String -> Regex.Regex
re p =
    case Regex.fromString p of
        Just r ->
            r

        -- Fallback to a regex that never matches (valid in JS/Elm)
        Nothing ->
            Regex.fromString "(?!)"
                |> Maybe.withDefault
                    -- This should never fail, but keep one more safe fallback
                    (Regex.fromString "."
                        |> Maybe.withDefault (Debug.todo "Regex fallback failed")
                    )


asSlug : String -> String
asSlug s =
    s
        |> String.toLower
        |> Regex.replace (re " +") (\_ -> "-")
        |> Regex.replace (re "[^a-z0-9-]") (\_ -> "")


asId : String -> String
asId s =
    Regex.replace (re "[^A-Za-z]") (\_ -> "_") s


firstWords : Int -> String -> String
firstWords n s =
    s
        |> Regex.find (re "[A-Za-z]+")
        |> List.map .match
        |> List.take n
        |> String.join " "


extractLinkTitle : String -> Maybe String
extractLinkTitle s =
    case Regex.find (re "\\[\\[(.*?)\\]\\]") s |> List.head of
        Just m ->
            case m.submatches of
                (Just t) :: _ ->
                    Just t

                _ ->
                    Nothing

        Nothing ->
            Nothing



-- PAGE DECODING (minimal)


type alias Item =
    { itemType : String
    , text : Maybe String
    }


type alias Page =
    { story : List Item
    }


itemDecoder : D.Decoder Item
itemDecoder =
    D.map2 Item
        (D.field "type" D.string)
        (D.maybe (D.field "text" D.string))


pageDecoder : D.Decoder Page
pageDecoder =
    D.field "story" (D.list itemDecoder)
        |> D.map Page


fetchPage : Place -> Cmd Msg
fetchPage place =
    let
        url =
            "//" ++ place.site ++ "/" ++ asSlug place.title ++ ".json"
    in
    Http.get
        { url = url
        , expect = Http.expectJson (FetchedPage place) pageDecoder
        }



-- PARSE ONE MARKDOWN BLOCK → Ask


parseAsk : String -> Ask
parseAsk raw =
    let
        lines =
            raw |> String.trim |> String.lines

        ( summary, rest1 ) =
            case lines of
                s :: xs ->
                    ( s, xs )

                [] ->
                    ( "", [] )

        ( details, rest2 ) =
            case rest1 of
                d :: xs ->
                    ( d, xs )

                [] ->
                    ( "", [] )

        parseChoiceLine : String -> Choice
        parseChoiceLine l0 =
            let
                trimmed =
                    String.trim l0

                withoutDash =
                    if String.startsWith "-" trimmed then
                        String.trim (String.dropLeft 1 trimmed)

                    else
                        trimmed

                parts =
                    String.split "⇒" withoutDash
            in
            case parts of
                [ opt, nxt ] ->
                    { option = String.trim opt, next = Just (String.trim nxt) }

                _ ->
                    { option = String.trim withoutDash, next = Nothing }

        choices =
            rest2
                |> List.filter (\l -> String.trim l |> String.startsWith "-")
                |> List.map parseChoiceLine
    in
    { summary = summary, details = details, choices = choices }



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotContext val ->
            let
                ctxDec =
                    D.map2 Context
                        (D.field "site" D.string)
                        (D.field "title" D.string)
            in
            case D.decodeValue ctxDec val of
                Ok ctx ->
                    let
                        start =
                            { site = ctx.site
                            , title = ctx.title
                            , step = 0
                            , ask = Nothing
                            , report = Nothing
                            , value = Nothing
                            }
                    in
                    ( { model | ctx = Just ctx, path = [ start ], loading = True, error = Nothing }
                    , fetchPage start
                    )

                Err _ ->
                    ( { model | error = Just "Bad context", loading = False }, Cmd.none )

        FetchedPage place (Ok page) ->
            let
                storyJson =
                    E.list
                        (\i ->
                            E.object
                                [ ( "type", E.string i.itemType )
                                , ( "text", E.string (Maybe.withDefault "" i.text) )
                                ]
                        )
                        page.story
            in
            ( model, requestInterviewMarkdowns storyJson )

        FetchedPage _ (Err _) ->
            ( { model | loading = False, error = Just "Page fetch failed" }, Cmd.none )

        GotInterview markdowns ->
            let
                asks =
                    markdowns |> List.map parseAsk

                model1 =
                    { model | asks = asks, loading = False }

                model2 =
                    case model1.path of
                        [] ->
                            model1

                        p :: ps ->
                            let
                                ask =
                                    List.drop p.step asks |> List.head
                            in
                            { model1 | path = { p | ask = ask } :: ps }
            in
            ( model2, Cmd.none )

        ToggleWhy here ->
            case nth here model.path of
                Just place ->
                    ( model
                    , frameLink (E.object [ ( "site", E.string place.site ), ( "title", E.string place.title ) ])
                    )

                Nothing ->
                    ( model, Cmd.none )

        Choose here opt ->
            ( updatePlace here (\p -> { p | report = Just opt }) model, Cmd.none )

        EditText here val ->
            ( updatePlace here (\p -> { p | value = Just val }) model, Cmd.none )

        Next here ->
            case nth here model.path of
                Nothing ->
                    ( model, Cmd.none )

                Just place ->
                    let
                        reportText : Maybe String
                        reportText =
                            case ( place.ask, place.report, place.value ) of
                                ( Just a, Nothing, Just v ) ->
                                    if List.isEmpty a.choices then
                                        Just (firstWords 4 v)

                                    else
                                        Nothing

                                ( _, r, _ ) ->
                                    r

                        nextPlace : Maybe Place
                        nextPlace =
                            case ( place.ask, reportText ) of
                                ( Just a, Just r ) ->
                                    let
                                        target =
                                            a.choices
                                                |> List.filter (\c -> c.option == r)
                                                |> List.head
                                    in
                                    case target of
                                        Just c ->
                                            case c.next of
                                                Just nxt ->
                                                    case extractLinkTitle nxt of
                                                        Just linked ->
                                                            Just
                                                                { site = place.site
                                                                , title = linked
                                                                , step = 0
                                                                , ask = Nothing
                                                                , report = Nothing
                                                                , value = Nothing
                                                                }

                                                        Nothing ->
                                                            aSummaryToStep nxt model.asks
                                                                |> Maybe.map
                                                                    (\ix ->
                                                                        { site = place.site
                                                                        , title = place.title
                                                                        , step = ix
                                                                        , ask = Nothing
                                                                        , report = Nothing
                                                                        , value = Nothing
                                                                        }
                                                                    )

                                                Nothing ->
                                                    Just
                                                        { site = place.site
                                                        , title = place.title
                                                        , step = place.step + 1
                                                        , ask = Nothing
                                                        , report = Nothing
                                                        , value = Nothing
                                                        }

                                        Nothing ->
                                            Just
                                                { site = place.site
                                                , title = place.title
                                                , step = place.step + 1
                                                , ask = Nothing
                                                , report = Nothing
                                                , value = Nothing
                                                }

                                _ ->
                                    Nothing
                    in
                    case ( reportText, nextPlace ) of
                        ( Just r, Just np ) ->
                            let
                                m1 =
                                    updatePlace here (\p -> { p | report = Just r }) model

                                m2 =
                                    -- Close previous panels like JS erase(): keep 0..here then append next
                                    let
                                        kept =
                                            List.take (here + 1) m1.path
                                    in
                                    { m1 | path = kept ++ [ np ], loading = True }
                            in
                            ( m2, fetchPage np )

                        _ ->
                            ( model, Cmd.none )

        Save ->
            case model.ctx of
                Nothing ->
                    ( model, Cmd.none )

                Just ctx ->
                    let
                        title =
                            "Saved " ++ ctx.title

                        textItem =
                            E.object
                                [ ( "type", E.string "paragraph" )
                                , ( "text", E.string ("Saved interview from [[" ++ ctx.title ++ "]].") )
                                ]

                        frameItem =
                            E.object
                                [ ( "type", E.string "frame" )
                                , ( "path", encodePath model.path )
                                ]

                        story =
                            E.list identity [ textItem, frameItem ]
                    in
                    ( model
                    , frameOpen (E.object [ ( "title", E.string title ), ( "story", story ) ])
                    )



-- SMALL UPDATE HELPERS


nth : Int -> List a -> Maybe a
nth i xs =
    xs |> List.drop i |> List.head


splitAt : Int -> List a -> ( List a, List a )
splitAt n xs =
    ( List.take n xs, List.drop n xs )


updatePlace : Int -> (Place -> Place) -> Model -> Model
updatePlace here f model =
    let
        ( before, rest ) =
            splitAt here model.path
    in
    case rest of
        p :: after ->
            { model | path = before ++ (f p :: after) }

        [] ->
            model


aSummaryToStep : String -> List Ask -> Maybe Int
aSummaryToStep target allAsks =
    allAsks
        |> List.indexedMap Tuple.pair
        |> List.filter (\( _, a ) -> a.summary == target)
        |> List.head
        |> Maybe.map Tuple.first


encodePath : List Place -> E.Value
encodePath path =
    path
        |> List.map
            (\p ->
                E.object
                    [ ( "site", E.string p.site )
                    , ( "title", E.string p.title )
                    , ( "step", E.int p.step )
                    , ( "report", E.string (Maybe.withDefault "" p.report) )
                    , ( "value", E.string (Maybe.withDefault "" p.value) )
                    ]
            )
        |> E.list identity



-- VIEW


view : Model -> Html Msg
view model =
    let
        lastIndex =
            List.length model.path - 1

        panels =
            model.path
                |> List.indexedMap (viewPlace lastIndex)

        donePanel =
            if isDone model then
                [ viewDone ]

            else
                []
    in
    div [ HA.id "result" ] (panels ++ donePanel)


isDone : Model -> Bool
isDone model =
    case ( List.reverse model.path |> List.head, model.asks ) of
        ( Just p, asks ) ->
            case p.ask of
                Nothing ->
                    False

                Just _ ->
                    p.step >= List.length asks

        _ ->
            False


viewPlace : Int -> Int -> Place -> Html Msg
viewPlace last here place =
    let
        openAttr =
            if here == last then
                [ HA.attribute "open" "" ]

            else
                []

        detailsHeader =
            Html.node "summary"
                []
                [ text (place.ask |> Maybe.map .summary |> Maybe.withDefault "")
                , span [ HA.style "color" "#666", HA.style "margin-left" "0.5rem" ]
                    [ text (Maybe.withDefault "" place.report) ]
                ]

        formPart =
            case place.ask of
                Nothing ->
                    text ""

                Just a ->
                    Html.node "div"
                        [ HA.class "content" ]
                        [ Html.node "hr" [] []
                        , formFor here a place
                        , Html.node "hr" [] []
                        ]
    in
    div [ HA.id (String.fromInt here) ]
        [ Html.node "details"
            (openAttr ++ [ HA.attribute "name" "interview" ])
            [ detailsHeader, formPart ]
        ]


formFor : Int -> Ask -> Place -> Html Msg
formFor here ask place =
    let
        buttons =
            Html.node "center"
                []
                [ button [ HE.onClick (ToggleWhy here) ] [ text "why" ]
                , text " "
                , button [ HE.onClick (Next here) ] [ text "next" ]
                ]
    in
    if List.isEmpty ask.choices then
        div []
            [ pText ask.details
            , textarea
                [ HA.style "width" "100%"
                , HA.style "height" "160px"
                , HE.onInput (EditText here)
                ]
                [ text (Maybe.withDefault "" place.value) ]
            , buttons
            ]

    else
        div []
            (pText ask.details
                :: (ask.choices
                        |> List.map
                            (\c ->
                                div []
                                    [ input
                                        [ HA.type_ "radio"
                                        , HA.name ("choice-" ++ String.fromInt here)
                                        , HA.id (asId c.option)
                                        , HA.checked (place.report == Just c.option)
                                        , HE.onClick (Choose here c.option)
                                        ]
                                        []
                                    , text " "
                                    , label [ HA.for (asId c.option) ] [ text c.option ]
                                    ]
                            )
                   )
                ++ [ buttons ]
            )


pText : String -> Html msg
pText s =
    Html.node "p" [] [ text s ]


viewDone : Html Msg
viewDone =
    Html.node "div"
        []
        [ Html.node "center"
            []
            [ text "done, thank you"
            , Html.node "br" [] []
            , button [ HE.onClick Save ] [ text "save" ]
            ]
        ]

port module AppEmbed exposing (main)

import AppModel as AM
import AppRunner as R
import Browser
import Html as H
import Json.Encode as E
import Platform.Sub as Sub



-- Ports exposed to JS (frame)


port pageJson : (String -> msg) -> Sub.Sub msg


port importJSON : () -> Cmd msg


port exportJSON : () -> Cmd msg


port persist : String -> Cmd msg



-- AppEmbed wraps AppRunner’s Msg so we can map Cmd/Sub safely


type Msg
    = Up AM.Msg
    | FedWikiPage String
    | NoOp


main : Program E.Value AM.UndoModel Msg
main =
    Browser.element
        { init = \flags -> mapInit R.init flags
        , update = update
        , subscriptions = subscriptions
        , view = \m -> H.map Up (R.view m) -- R.view already returns Html Msg
        }


subscriptions : AM.UndoModel -> Sub.Sub Msg
subscriptions m =
    Sub.batch
        [ Sub.map Up (R.subscriptions m)
        , pageJson FedWikiPage
        ]


update : Msg -> AM.UndoModel -> ( AM.UndoModel, Cmd Msg )
update msg model =
    case msg of
        Up inner ->
            mapUpdate R.update inner model

        FedWikiPage raw ->
            R.onFedWikiPage raw model

        NoOp ->
            ( model, Cmd.none )



-- Tiny helpers to map init/update tuples between Msg types


mapInit :
    (E.Value -> ( AM.UndoModel, Cmd AM.Msg ))
    -> E.Value
    -> ( AM.UndoModel, Cmd Msg )
mapInit init flags =
    let
        ( m, cmd ) =
            init flags
    in
    ( m, Cmd.map Up cmd )


mapUpdate :
    (AM.Msg -> AM.UndoModel -> ( AM.UndoModel, Cmd AM.Msg ))
    -> AM.Msg
    -> AM.UndoModel
    -> ( AM.UndoModel, Cmd Msg )
mapUpdate f inner m =
    let
        ( next, cmd ) =
            f inner m
    in
    ( next, Cmd.map Up cmd )

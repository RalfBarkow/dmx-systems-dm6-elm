port module AppRunner exposing (main)

import AppModel as AM
import Browser
import Compat.FedWiki as CFW
import Dict
import Html as H
import Json.Decode as D
import Json.Encode as E
import Main
import ModelAPI exposing (push)
import MouseAPI exposing (mouseSubs)
import Platform.Cmd as Cmd
import Platform.Sub as Sub



-- Ports you need here (don’t put them in Main)


port pageJson : (String -> msg) -> Sub msg


port importJSON : () -> Cmd msg


port exportJSON : () -> Cmd msg



-- Wrap upstream messages


type Msg
    = Up AM.Msg
    | PageJson String


type alias Model =
    AM.UndoModel


init : E.Value -> ( AM.UndoModel, Cmd Msg )
init flags =
    let
        ( u, c ) =
            Main.init flags
    in
    ( u, Cmd.map Up c )


subscriptions : AM.UndoModel -> Sub Msg
subscriptions m =
    Sub.batch
        [ Sub.map Up (mouseSubs m)
        , pageJson PageJson
        ]


update : Msg -> AM.UndoModel -> ( AM.UndoModel, Cmd Msg )
update msg undoModel =
    case msg of
        Up sub ->
            let
                ( next, cmd ) =
                    Main.update sub undoModel
            in
            ( next, Cmd.map Up cmd )

        PageJson raw ->
            case D.decodeString CFW.decodePage raw of
                Ok val ->
                    let
                        before =
                            Dict.size undoModel.present.items

                        ( m1, cmdImport ) =
                            CFW.pageToModel val undoModel.present

                        after =
                            Dict.size m1.items

                        -- push expects (AM.Model, Cmd AM.Msg)
                        ( u1, cmdPushed ) =
                            push undoModel ( { m1 | fedWikiRaw = raw }, cmdImport )
                    in
                    ( u1, Cmd.map Up cmdPushed )

                Err _ ->
                    ( undoModel, Cmd.none )


view : AM.UndoModel -> H.Html Msg
view u =
    -- use Main’s map-only view to keep the frame clean
    H.map Up (Main.viewElementMap u)


main : Program E.Value AM.UndoModel Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }

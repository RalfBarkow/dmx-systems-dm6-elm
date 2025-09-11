module AppMain exposing
    ( Model
    , Msg
    , UndoModel
    , init
    , main
    , subscriptions
    , update
    , view
    )

import AppModel as AM exposing (Model, Msg, UndoModel)
import Browser exposing (Document)
import Json.Encode as E
import Main
import MouseAPI exposing (mouseSubs)



-- Re-exposed types via local aliases (required to expose from this module)


type alias Model =
    AM.Model


type alias UndoModel =
    AM.UndoModel


type alias Msg =
    AM.Msg



-- Wire up program parts


init : E.Value -> ( UndoModel, Cmd Msg )
init =
    Main.init


update : Msg -> UndoModel -> ( UndoModel, Cmd Msg )
update =
    Main.update


view : UndoModel -> Document Msg
view =
    Main.view


subscriptions : UndoModel -> Sub Msg
subscriptions =
    mouseSubs


main : Program E.Value UndoModel Msg
main =
    Main.main

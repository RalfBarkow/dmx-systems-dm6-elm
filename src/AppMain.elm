module AppMain exposing
    ( Model
    , Msg
    , UndoModel
    , init
    , main
    , prettyMsg
    , subscriptions
    , update
    , view
    )

import AppModel as AM exposing (Msg(..), UndoModel)
import Browser exposing (Document)
import Json.Encode as E
import Logger exposing (toString)
import Main
import Mouse.Pretty as MousePretty
import MouseAPI exposing (mouseSubs)
import String exposing (fromInt)



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


prettyMsg : AM.Msg -> String
prettyMsg msg =
    case msg of
        Mouse m ->
            "Mouse." ++ MousePretty.pretty m

        Search m ->
            "Search." ++ toString m

        IconMenu m ->
            "IconMenu." ++ toString m

        Edit m ->
            "Edit." ++ toString m

        Nav m ->
            "Nav." ++ toString m

        -- 🔧 Missing branch added here
        MoveTopicToMap topicId mapId origPos targetId targetPath dropWorld ->
            let
                pathStr =
                    "[" ++ String.join "," (List.map fromInt targetPath) ++ "]"
            in
            "MoveTopicToMap T"
                ++ fromInt topicId
                ++ " from M"
                ++ fromInt mapId
                ++ " orig="
                ++ toString origPos
                ++ " → T"
                ++ fromInt targetId
                ++ " path="
                ++ pathStr
                ++ " drop="
                ++ toString dropWorld

        AddTopic ->
            "AddTopic"

        SwitchDisplay mode ->
            "SwitchDisplay." ++ toString mode

        Hide ->
            "Hide"

        Delete ->
            "Delete"

        Undo ->
            "Undo"

        Redo ->
            "Redo"

        Import ->
            "Import"

        Export ->
            "Export"

        NoOp ->
            "NoOp"

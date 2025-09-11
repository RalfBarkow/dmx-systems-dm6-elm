module View.ToolbarButtonsTest exposing (tests)

import Compat.TestDefault exposing (defaultModel)
import Compat.TestUtil exposing (asUndo)
import Html
import Html.Attributes as Attr
import Main exposing (view)
import Test exposing (..)
import Test.Html.Query as Query
import Test.Html.Selector as Sel


isDisabled : Sel.Selector
isDisabled =
    Sel.attribute (Attr.disabled True)


tests : Test
tests =
    describe "Toolbar buttons"
        [ test "\"Edit\" is disabled when no selection" <|
            \_ ->
                Html.div [] (view (asUndo defaultModel)).body
                    |> Query.fromHtml
                    |> Query.find
                        [ Sel.tag "button"
                        , Sel.containing [ Sel.text "Edit" ]
                        ]
                    |> Query.has [ isDisabled ]
        , test "\"Add Topic\" is enabled" <|
            \_ ->
                Html.div [] (view (asUndo defaultModel)).body
                    |> Query.fromHtml
                    |> Query.find
                        [ Sel.tag "button"
                        , Sel.containing [ Sel.text "Add Topic" ]
                        ]
                    |> Query.hasNot [ isDisabled ]
        ]

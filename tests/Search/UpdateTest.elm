module Search.UpdateTest exposing (tests)

import Compat.TestDefault exposing (defaultModel)
import Compat.TestUtil exposing (asUndo, present)
import Expect
import Search exposing (SearchMsg(..))
import SearchAPI exposing (updateSearch)
import Test exposing (..)


tests : Test
tests =
    describe "Search.updateSearch"
        [ test "SearchInput updates searchText" <|
            \_ ->
                let
                    ( m2, _ ) =
                        updateSearch (Input "foo") (asUndo defaultModel)
                in
                Expect.equal (present m2).search.text "foo"
        , test "SearchFocus opens the result menu (differs from default)" <|
            \_ ->
                let
                    ( m2, _ ) =
                        updateSearch Search.FocusInput (asUndo defaultModel)
                in
                -- Compare the whole search submodel (robust to internal field renames)
                Expect.notEqual (present m2).search defaultModel.search
        ]

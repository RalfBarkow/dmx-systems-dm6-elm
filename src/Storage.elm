module Storage exposing
    ( exportJSON
    , importJSON
    , initFromStorage
    , modelDecoder
    , store
    , storeModel
    , storeWith
    )

{-| FedWiki-embed shim: disable persistence.

  - `initFromStorage` returns the model unchanged.

  - `storeModel` is a no-op (Cmd.none).

    Keep the API surface tiny. If the compiler later asks for more
    functions from Storage, add thin stubs here (still no-op).

-}

import AppModel as AM
import Json.Decode as D


{-| Called once at startup in some apps. Keep identity.
-}
initFromStorage : AM.UndoModel -> ( AM.UndoModel, Cmd AM.Msg )
initFromStorage undo =
    ( undo, Cmd.none )


{-| Upstream calls this after state changes; we ignore it.
Keep for any direct callers that only want a side effect (we do none).
-}
storeModel : AM.Model -> Cmd AM.Msg
storeModel _ =
    Cmd.none



-- IMPORTANT: Pipeline-friendly alias used like:
--   model |> ... |> store |> push undoModel
-- Must return (Model, Cmd Msg).


store : AM.Model -> ( AM.Model, Cmd AM.Msg )
store model =
    ( model, Cmd.none )



-- IMPORTANT: Upstream pipes a (Model, Cmd) into this.
-- Make it a pure pass-through.


storeWith : ( AM.Model, Cmd AM.Msg ) -> ( AM.Model, Cmd AM.Msg )
storeWith tuple =
    tuple



-- ===== Compatibility for Main.elm =====
-- Upstream calls:
--   ( present, importJSON () ) |> swap undoModel
--   ( present, exportJSON () ) |> swap undoModel
-- so these must be unit -> Cmd Msg.


importJSON : () -> Cmd AM.Msg
importJSON _ =
    Cmd.none


exportJSON : () -> Cmd AM.Msg
exportJSON _ =
    Cmd.none



-- A decoder for AM.Model is not available in the embed; always fail.


modelDecoder : D.Decoder AM.Model
modelDecoder =
    D.fail "Storage shim: modelDecoder not supported in FedWiki embed"

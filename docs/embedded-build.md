# Build the embedded `elm.js` (for FedWiki frames)

This builds the **embedded** Elm bundle used by `cold-boot.html` (or any FedWiki page that loads `elm.js`). The embedded entrypoint must be a **`Browser.element`** (not `Browser.document`) and export a top-level module named **`AppEmbed`** so the page can find `Elm.AppEmbed`.

---

## 1) Ensure you have an element entrypoint

Minimal `src/AppEmbed.elm` (ports optional but recommended):

```elm
module AppEmbed exposing (main)

import Browser
import Json.Decode as D
import Json.Encode as E
import Main -- reuse your core app Model/Msg/update/view if you like


-- Flags expected by cold-boot.html
type alias Flags =
    { slug : String
    , stored : String
    }

flagsDecoder : D.Decoder Flags
flagsDecoder =
    D.map2 Flags
        (D.field "slug" D.string)
        (D.field "stored" D.string)


main : Program E.Value Main.Model Main.Msg
main =
    Browser.element
        { init = init
        , update = Main.update
        , subscriptions = Main.subscriptions
        , view = \model -> Main.view model |> .body |> List.head |> Maybe.withDefault (Html.text "")
          -- For element: return Html Msg. If Main.view returns Browser.Document,
          -- either expose a separate Element view, or wrap a minimal element view here.
        }


init : E.Value -> ( Main.Model, Cmd Main.Msg )
init flagsVal =
    case D.decodeValue flagsDecoder flagsVal of
        Ok _ ->
            -- Pass through original JSON flags
            Main.init flagsVal

        Err _ ->
            -- Fallback for safety
            Main.init <|
                E.object
                    [ ( "slug", E.string "empty" )
                    , ( "stored", E.string "{}" )
                    ]
```

> Notes
>
> * If your `Main.view` returns a `Browser.Document`, add a thin element-view adapter (e.g., render only the map area) or expose an element view in `Main`.
> * If you use ports like `pageJson`, keep them in `AppEmbed` (or re-expose from `Main`) so `cold-boot.html` can feed FedWiki page JSON in.

---

## 2) Dev build (quick compile)

Compile straight to wherever your FedWiki page loads `elm.js` from.

**Option A: write to your `public/` (then copy manually):**

```bash
npx elm make src/AppEmbed.elm --output=public/elm.js
```

**Option B: write directly into your FedWiki assets (quickest feedback):**

```bash
ELM_OUT="$HOME/.wiki/wiki.ralfbarkow.ch/assets/pages/cold-boot/elm.js"
npx elm make src/AppEmbed.elm --output="$ELM_OUT"
```

Add a watcher if you like:

```bash
# macOS (fswatch)
fswatch -o src | xargs -n1 -I{} sh -c 'npx elm make src/AppEmbed.elm --output="$HOME/.wiki/wiki.ralfbarkow.ch/assets/pages/cold-boot/elm.js"'
```

**npm script idea:**

```json
{
  "scripts": {
    "embed:dev": "elm make src/AppEmbed.elm --output=$HOME/.wiki/wiki.ralfbarkow.ch/assets/pages/cold-boot/elm.js"
  }
}
```

Run: `npm run embed:dev`

---

## 3) Production build (optimized)

Elm requires removing `Debug.*` in any transitive module if you use `--optimize`.

```bash
# 1) Compile optimized
npx elm make src/AppEmbed.elm --optimize --output=elm.js

# 2) (Optional) Minify
npx uglify-js elm.js -c "pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe" \
  | npx uglify-js -m -o elm.min.js

# 3) Copy to FedWiki (or your host path)
cp elm.min.js "$HOME/.wiki/wiki.ralfbarkow.ch/assets/pages/cold-boot/elm.js"
```

**npm script idea:**

```json
{
  "scripts": {
    "embed:build": "elm make src/AppEmbed.elm --optimize --output=elm.js && uglify-js elm.js -c pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe | uglify-js -m -o elm.min.js"
  }
}
```

---

## 4) Wire-up expectations in `cold-boot.html`

That page will:

* Load `elm.js` via `<script src="elm.js"></script>` (not `type="module"`).
* Look for **`Elm.AppEmbed`** first. If present, it calls:

  ```js
  const app = Elm.AppEmbed.init({ node: mount, flags: { slug, stored } })
  ```
* Optionally send `pageJson` via `app.ports.pageJson.send(raw)` if your ports expose it.

So **ensure** your compiled JS defines `window.Elm.AppEmbed`. If you see “`Elm is not defined`”:

* The script didn’t load (wrong path / CSP / sandbox).
* Or you compiled to `public/elm.js` but the page points somewhere else.

If you see “`No Elm module found.`”:

* The bundle compiled, but the module name is different (e.g., `Elm.Main` only). Rebuild from `src/AppEmbed.elm`.

---

## 5) Flags shape (what the page passes)

`cold-boot.html` sends:

```js
bootElm({ slug, stored: JSON.stringify(window.data ?? {}) })
```

Your `AppEmbed` must accept flags with two string fields:

* `slug : String`
* `stored : String` (FedWiki page JSON stringified; `"{}"` when cold)

Make your decoder lenient if needed (fall back to `{ slug = "empty", stored = "{}" }`).

---

## 6) Ports you can (optionally) support

* `port pageJson : (String -> msg) -> Sub msg` — page JSON pushed in by the frame.
* `port store : E.Value -> Cmd msg` — if you want to persist outward.
* `port log : { level : String, tag : String, text : String } -> Cmd msg` — to forward logs.

`cold-boot.html` already tries to send `pageJson` and listens to `log` if present.

---

## 7) Quick checklist

* [ ] `src/AppEmbed.elm` exists and uses `Browser.element`.
* [ ] Build `elm.js` into the exact path the FedWiki page loads.
* [ ] No `Debug.*` in prod builds (`--optimize`).
* [ ] Flags decoder accepts `{ slug, stored }`.
* [ ] Optional ports (`pageJson`, `store`, `log`) wired if you need them.
* [ ] Open the FedWiki page; the header shows: `Elm(AppEmbed) flags { … }`.

That’s it—once `elm.js` is in place and `Elm.AppEmbed` exists, `cold-boot.html` will boot the embedded app with the page JSON or `{}`.

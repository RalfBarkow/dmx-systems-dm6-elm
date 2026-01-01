This file is a merged representation of a subset of the codebase, containing specifically included files and files not matching ignore patterns, combined into a single document by Repomix.

# File Summary

## Purpose
This file contains a packed representation of a subset of the repository's contents that is considered the most important context.
It is designed to be easily consumable by AI systems for analysis, code review,
or other automated processes.

## File Format
The content is organized as follows:
1. This summary section
2. Repository information
3. Directory structure
4. Repository files (if enabled)
5. Multiple file entries, each consisting of:
  a. A header with the file path (## File: path/to/file)
  b. The full contents of the file in a code block

## Usage Guidelines
- This file should be treated as read-only. Any changes should be made to the
  original repository files, not this packed version.
- When processing this file, use the file path to distinguish
  between different files in the repository.
- Be aware that this file may contain sensitive information. Handle it with
  the same level of security as you would the original repository.

## Notes
- Some files may have been excluded based on .gitignore rules and Repomix's configuration
- Binary files are not included in this packed representation. Please refer to the Repository Structure section for a complete list of file paths, including binary files
- Only files matching these patterns are included: src/**/*, tests/**/*, scripts/**/*, examples/**/*, docs/**/*, public/**/*, README.md, elm.json, build-dev.sh, build-prod.sh, index.html
- Files matching these patterns are excluded: **/elm-stuff/**, **/node_modules/**, **/dist/**, **/build/**, **/coverage/**, **/*.log, **/*.lock
- Files matching patterns in .gitignore are excluded
- Files matching default ignore patterns are excluded
- Files are sorted by Git change count (files with more changes are at the bottom)

# Directory Structure
```
docs/
  embedded-build.md
  journal.md
  pinning.md
examples/
  dm6-elm-a-f.json
  dm6-elm-adorno-zitat.json
  dm6-elm-export.json
  dm6-elm-model-a-f.json
  dm6-elm-model.json
  dm6-elm-pinned-state.json
  dm6-elm-unbox.json
  dm6-elm.json
public/
  .editorconfig
  app.html
  cold-boot.html
  index.html
scripts/
  contract-smoke.sh
  integrate-upstream.sh
  localstorage-tools.js
src/
  Algebra/
    Containment/
      Graph.elm
    Containment.elm
  Compat/
    WikiLink/
      Parser.elm
      Regex.elm
    ContainmentOps.elm
    ContractSmoke.elm
    CoreModel.elm
    Display.elm
    DmxImport.elm
    FedWiki.elm
    FedWikiImport.elm
    Model.elm
    ModelAPI.elm
    Storage.elm
  Domain/
    Id.elm
    Reparent.elm
    TopicId.elm
  Feature/
    Connection/
      Channel.elm
      Journal.elm
      README.md
    Facade/
      Graph.elm
    OpenDoor/
      Access.elm
      Copy.elm
      Decide.elm
      Move.elm
    WikiLink/
      Demo.elm
    Cross.elm
    Move.elm
  js/
    exportLS.js
    importLSFile.js
  Logger/
    Dev/
      Logger.elm
    Prod/
      Logger.elm
    Pretty.elm
  Model/
    Invariant.elm
    Reparent.elm
  Mouse/
    Pretty.elm
  Ports/
    Console.elm
  UI/
    Action.elm
    Icon.elm
    Toolbar.elm
  AppEmbed.elm
  AppMain.elm
  AppModel.elm
  AppRunner.elm
  Boxing.elm
  CallGraph.elm
  Config.elm
  Console.elm
  Defaults.elm
  Extensions.elm
  FedWiki.elm
  IconMenu.elm
  IconMenuAPI.elm
  Logger.elm
  Main.elm
  MapAutoSize.elm
  MapRenderer.elm
  Model.elm
  ModelAPI.elm
  Mouse.elm
  MouseAPI.elm
  Search.elm
  SearchAPI.elm
  Storage.elm
  SvgExtras.elm
  Toolbar.elm
  Types.elm
  Utils.elm
tests/
  Algebra/
    ContainmentTest.elm
  Compat/
    WikiLink/
      ParserTest.elm
      RegexTest.elm
    TestDefault.elm
    TestUtil.elm
  Domain/
    ReparentRulesTest.elm
  Feature/
    OpenDoor/
      ButtonTest.elm
      CopyTest.elm
      StayVisibleTest.elm
  Generated/
    Fixtures.elm
  Import/
    DmxCoreTopicTest.elm
  Model/
    AddItemToMapCycleTest.elm
    DefaultModelTest.elm
    SelfContainmentInvariantTest.elm
  Search/
    UpdateTest.elm
  Storage/
    InitDecodeTest.elm
  Tests/
    Main.elm
    Master.elm
  View/
    ToolbarButtonsTest.elm
build-dev.sh
build-prod.sh
elm.json
index.html
README.md
```

# Files

## File: docs/pinning.md
````markdown
# DM6 Elm — Pinned Visibility (Per-Map)

This document explains the new **`pinned : Bool`** flag on `MapItem` and how it changes visibility behavior during **Boxing** (BlackBox/WhiteBox) and **Unboxing**. It also provides demo steps you can follow in the running dev server.

---

## What is `pinned`?

Each map-specific item (`MapItem`) now has two visibility dimensions:

- `hidden : Bool` — whether the item is rendered in that map.
- `pinned : Bool` — whether the item is **protected from auto-hiding** by Boxing in that map.

This separation fixes cases where topics *unexpectedly disappeared* from the top map after re-boxing, even though the user had explicitly revealed them there.

---

## Rules

- **Reveal (explicit user intent):** when a user reveals an item in a map (e.g., Search → click), the item becomes `hidden=False` and **`pinned=True`** in that map.
- **Boxing (BlackBox/WhiteBox):** auto-hides only **non-pinned** items in the parent map (`pinned=False`). **Pinned items remain visible**.
- **Unboxing:** reveals items as before. (Optional rule: if an item was already visible in the parent map during unbox, keep/set `pinned=True` there.)
- **Hide:** when the user explicitly hides an item, it becomes `hidden=True` and **`pinned=False`** in that map (the protection is removed).

> Persistence: `pinned` is serialized in `Storage.elm`. Older stored models default `pinned=False` on load.

---

## Mental model

```
Per-map MapItem state: [hidden] / [pinned]

[hidden=False, pinned=True]   → visible AND protected from Boxing in this map
[hidden=False, pinned=False]  → visible but may be auto-hidden by Boxing later
[hidden=True,  pinned=False]  → not visible
```

**Boxing rule:** Only items with `pinned=False` are auto-hidden in the parent map.  
**Hide rule:** Hiding an item also clears `pinned` (set to False).

---

## Demo scenarios

> Run the dev server (`npm run dev`) and open http://localhost:8000.  
> Use **Search** to reveal topics; use **Display** to switch containers between WhiteBox/BlackBox/Unboxed.

### 1) Reveal → Box (fixed disappearance)

1. In the **top map**, use **Search** to find a topic not currently visible and click it (Reveal).
2. Switch a related container to **BlackBox** and back to **WhiteBox** a few times.
3. **Expected:** the revealed topic **stays visible** in the top map.  
   (It is now `pinned=True` and Boxing skips it.)

### 2) Already visible in parent → Unbox → Box

1. Ensure **Topic A** is visible in the top map.
2. Unbox a container that also contains **Topic A** (WhiteBox → Unboxed).
3. Box it again (Unboxed → WhiteBox/BlackBox).
4. **Expected:** Topic A remains visible in the top map.  
   (Either it was previously pinned by Reveal, or the unboxing path preserved pin.)

### 3) Hide overrides pin

1. Pick a topic visible in top map (pinned).
2. Use **Hide**.
3. **Expected:** the topic disappears and becomes eligible for auto-hiding (state `[hidden=True, pinned=False]`).  
   Re-boxing later will not preserve it.

---

## Code changes summary

- `src/Model.elm`
  - `type alias MapItem = { id, hidden, props, parentAssocId, pinned }`
  - `addItemToMap` now constructs `MapItem … False` (pinned default False).
  - `hideItem_` sets `{ hidden = True, pinned = False }` on hide.

- `src/Storage.elm`
  - Encoder/decoder include `pinned` (decoder defaults to False for older saves).

- `src/Boxing.elm` *(Step 2)*
  - When **boxing**, skip hiding items where `viewItem.pinned == True`.
  - `targetAssocItem` constructs with `… False` for pinned.

- `src/Search.elm` *(Step 3)*
  - On **reveal**, set `pinned=True` in that map (explicit intent).

> If you are rolling changes incrementally, ensure Steps 2 and 3 are applied to see the behavior above.

---

## Seeding a demo model

You can seed localStorage with a tiny model that shows a single topic on the top map.

### Console one-liner

Open the app, DevTools → Console, then paste:

```js
(function () {
  var KEY = 'dm6-elm-model';
  var value = {
    "items": {
      "1": { "topic": { "id": 1, "text": "Ralf Barkow", "iconName": "user" } },
      "2": { "assoc": { "id": 2, "itemType": "dmx.composition", "player1": 1, "role1": "dmx.child", "player2": 0, "role2": "dmx.parent" } }
    },
    "maps": {
      "0": {
        "id": 0,
        "items": {
          "1": {
            "id": 1,
            "hidden": false,
            "topicProps": {
              "pos": { "x": 372, "y": 277 },
              "size": { "w": 128, "h": 37.5 },
              "displayMode": "Detail"
            },
            "parentAssocId": 2
          }
        },
        "rect": { "x1": 0, "y1": 0, "x2": 0, "y2": 0 },
        "parentMapId": -1
      }
    },
    "mapPath": [0],
    "nextId": 3
  };
  localStorage.setItem(KEY, JSON.stringify(value));
  location.reload();
})();
```

### Helper scripts

To export the current model from localStorage, use the helper in `scripts/localstorage-tools.js`.

Usage:
```js
exportLS('dm6-elm-model')
importLSFile('dm6-elm-model')
```
---

## Example resource

An example model JSON file is included in the repo:
examples/dm6-elm-model.json

You can import it via the browser console using the helper:

```js
importLSFile('dm6-elm-model')
```

Or export your own edits with:
```js
exportLS('dm6-elm-model')
```

This makes it easy to share or restore pinned-visibility demo states.

---

## FAQ

**Q:** Why not just rely on `hidden`?  
**A:** Because `hidden` is about *visibility*, not *intent*. `pinned` captures intent (“keep this visible here”) so Boxing does not undo explicit reveals.

**Q:** Does `pinned` affect child maps?  
**A:** No, it is **per map**. Pinning a topic in the top map does not pin it elsewhere.

**Q:** Is `pinned` persisted?  
**A:** Yes. Older saves default `pinned=False` when decoded.

---

Happy mapping!
````

## File: examples/dm6-elm-a-f.json
````json
{
  "dm6-elm": "{\"items\":{\"1\":{\"topic\":{\"id\":1,\"text\":\"A\",\"iconName\":\"\"}},\"2\":{\"assoc\":{\"id\":2,\"itemType\":\"dmx.composition\",\"player1\":1,\"role1\":\"dmx.child\",\"player2\":0,\"role2\":\"dmx.parent\"}},\"3\":{\"topic\":{\"id\":3,\"text\":\"B\",\"iconName\":\"\"}},\"4\":{\"assoc\":{\"id\":4,\"itemType\":\"dmx.composition\",\"player1\":3,\"role1\":\"dmx.child\",\"player2\":0,\"role2\":\"dmx.parent\"}},\"5\":{\"topic\":{\"id\":5,\"text\":\"C\",\"iconName\":\"\"}},\"6\":{\"assoc\":{\"id\":6,\"itemType\":\"dmx.composition\",\"player1\":5,\"role1\":\"dmx.child\",\"player2\":0,\"role2\":\"dmx.parent\"}},\"7\":{\"topic\":{\"id\":7,\"text\":\"D\",\"iconName\":\"\"}},\"8\":{\"assoc\":{\"id\":8,\"itemType\":\"dmx.composition\",\"player1\":7,\"role1\":\"dmx.child\",\"player2\":0,\"role2\":\"dmx.parent\"}}},\"maps\":{\"0\":{\"id\":0,\"items\":{\"1\":{\"id\":1,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":432,\"y\":172},\"size\":{\"w\":128,\"h\":36.600006103515625},\"displayMode\":\"Detail\"},\"parentAssocId\":2},\"3\":{\"id\":3,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":416,\"y\":273},\"size\":{\"w\":128,\"h\":36.600006103515625},\"displayMode\":\"Detail\"},\"parentAssocId\":4},\"5\":{\"id\":5,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":691,\"y\":170},\"size\":{\"w\":128,\"h\":36.600006103515625},\"displayMode\":\"Detail\"},\"parentAssocId\":6},\"7\":{\"id\":7,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":688,\"y\":254},\"size\":{\"w\":128,\"h\":37.5},\"displayMode\":\"Detail\"},\"parentAssocId\":8}},\"rect\":{\"x1\":0,\"y1\":0,\"x2\":0,\"y2\":0},\"parentMapId\":-1}},\"mapPath\":[0],\"nextId\":9}"
}
````

## File: examples/dm6-elm-adorno-zitat.json
````json
{
  "dm6-elm": "{\"items\":{\"1\":{\"topic\":{\"id\":1,\"text\":\"Theodor W. Adorno\",\"iconName\":\"\"}},\"2\":{\"assoc\":{\"id\":2,\"itemType\":\"dmx.composition\",\"player1\":1,\"role1\":\"dmx.child\",\"player2\":0,\"role2\":\"dmx.parent\"}},\"3\":{\"topic\":{\"id\":3,\"text\":\"Minima Moralia\",\"iconName\":\"\"}},\"4\":{\"assoc\":{\"id\":4,\"itemType\":\"dmx.composition\",\"player1\":3,\"role1\":\"dmx.child\",\"player2\":0,\"role2\":\"dmx.parent\"}},\"5\":{\"topic\":{\"id\":5,\"text\":\"Kein Gedanke ist immun ... (S.21)\\n\\n»Kein Gedanke ist immun gegen seine Kommunikation, und es genügt bereits, ihn an falscher Stelle und in falschem Einverständnis zu sagen, um seine Wahrheit zu unterhöhlen.«\",\"iconName\":\"\"}},\"6\":{\"assoc\":{\"id\":6,\"itemType\":\"dmx.composition\",\"player1\":5,\"role1\":\"dmx.child\",\"player2\":0,\"role2\":\"dmx.parent\"}},\"7\":{\"topic\":{\"id\":7,\"text\":\"Kommunikation und Wahrheit\",\"iconName\":\"\"}},\"8\":{\"assoc\":{\"id\":8,\"itemType\":\"dmx.composition\",\"player1\":7,\"role1\":\"dmx.child\",\"player2\":0,\"role2\":\"dmx.parent\"}},\"9\":{\"assoc\":{\"id\":9,\"itemType\":\"dmx.composition\",\"player1\":3,\"role1\":\"dmx.child\",\"player2\":1,\"role2\":\"dmx.parent\"}},\"10\":{\"assoc\":{\"id\":10,\"itemType\":\"dmx.composition\",\"player1\":5,\"role1\":\"dmx.child\",\"player2\":3,\"role2\":\"dmx.parent\"}},\"11\":{\"assoc\":{\"id\":11,\"itemType\":\"dmx.association\",\"player1\":5,\"role1\":\"dmx.related\",\"player2\":7,\"role2\":\"dmx.related\"}},\"12\":{\"assoc\":{\"id\":12,\"itemType\":\"dmx.association\",\"player1\":5,\"role1\":\"dmx.default\",\"player2\":3,\"role2\":\"dmx.default\"}},\"13\":{\"assoc\":{\"id\":13,\"itemType\":\"dmx.composition\",\"player1\":12,\"role1\":\"dmx.child\",\"player2\":0,\"role2\":\"dmx.parent\"}},\"14\":{\"assoc\":{\"id\":14,\"itemType\":\"dmx.association\",\"player1\":1,\"role1\":\"dmx.default\",\"player2\":3,\"role2\":\"dmx.default\"}},\"15\":{\"assoc\":{\"id\":15,\"itemType\":\"dmx.composition\",\"player1\":14,\"role1\":\"dmx.child\",\"player2\":0,\"role2\":\"dmx.parent\"}},\"16\":{\"assoc\":{\"id\":16,\"itemType\":\"dmx.composition\",\"player1\":5,\"role1\":\"dmx.child\",\"player2\":3,\"role2\":\"dmx.parent\"}},\"17\":{\"assoc\":{\"id\":17,\"itemType\":\"dmx.composition\",\"player1\":7,\"role1\":\"dmx.child\",\"player2\":3,\"role2\":\"dmx.parent\"}},\"18\":{\"assoc\":{\"id\":18,\"itemType\":\"dmx.composition\",\"player1\":1,\"role1\":\"dmx.child\",\"player2\":7,\"role2\":\"dmx.parent\"}},\"19\":{\"assoc\":{\"id\":19,\"itemType\":\"dmx.composition\",\"player1\":3,\"role1\":\"dmx.child\",\"player2\":7,\"role2\":\"dmx.parent\"}},\"20\":{\"assoc\":{\"id\":20,\"itemType\":\"dmx.composition\",\"player1\":5,\"role1\":\"dmx.child\",\"player2\":3,\"role2\":\"dmx.parent\"}},\"21\":{\"assoc\":{\"id\":21,\"itemType\":\"dmx.association\",\"player1\":1,\"role1\":\"dmx.default\",\"player2\":3,\"role2\":\"dmx.default\"}},\"22\":{\"assoc\":{\"id\":22,\"itemType\":\"dmx.composition\",\"player1\":21,\"role1\":\"dmx.child\",\"player2\":7,\"role2\":\"dmx.parent\"}},\"23\":{\"assoc\":{\"id\":23,\"itemType\":\"dmx.composition\",\"player1\":5,\"role1\":\"dmx.child\",\"player2\":7,\"role2\":\"dmx.parent\"}},\"24\":{\"assoc\":{\"id\":24,\"itemType\":\"dmx.composition\",\"player1\":5,\"role1\":\"dmx.child\",\"player2\":3,\"role2\":\"dmx.parent\"}},\"25\":{\"assoc\":{\"id\":25,\"itemType\":\"dmx.association\",\"player1\":1,\"role1\":\"dmx.default\",\"player2\":5,\"role2\":\"dmx.default\"}},\"26\":{\"assoc\":{\"id\":26,\"itemType\":\"dmx.composition\",\"player1\":25,\"role1\":\"dmx.child\",\"player2\":0,\"role2\":\"dmx.parent\"}}},\"maps\":{\"0\":{\"id\":0,\"items\":{\"1\":{\"id\":1,\"hidden\":false,\"pinned\":true,\"topicProps\":{\"pos\":{\"x\":366,\"y\":177},\"size\":{\"w\":128,\"h\":36.600006103515625},\"displayMode\":\"Detail\"},\"parentAssocId\":2},\"3\":{\"id\":3,\"hidden\":true,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":532.4486162046369,\"y\":374.88948475457255},\"size\":{\"w\":128,\"h\":36.600006103515625},\"displayMode\":\"WhiteBox\"},\"parentAssocId\":4},\"5\":{\"id\":5,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":623.5584837168362,\"y\":182.2982347455242},\"size\":{\"w\":220,\"h\":60},\"displayMode\":\"LabelOnly\"},\"parentAssocId\":-1},\"7\":{\"id\":7,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":371.1694062026355,\"y\":280.42481354766846},\"size\":{\"w\":200,\"h\":60},\"displayMode\":\"WhiteBox\"},\"parentAssocId\":-1},\"12\":{\"id\":12,\"hidden\":true,\"pinned\":false,\"assocProps\":{},\"parentAssocId\":13},\"14\":{\"id\":14,\"hidden\":true,\"pinned\":false,\"assocProps\":{},\"parentAssocId\":15},\"18\":{\"id\":18,\"hidden\":true,\"pinned\":false,\"assocProps\":{},\"parentAssocId\":-1},\"19\":{\"id\":19,\"hidden\":true,\"pinned\":false,\"assocProps\":{},\"parentAssocId\":-1},\"21\":{\"id\":21,\"hidden\":true,\"pinned\":false,\"assocProps\":{},\"parentAssocId\":-1},\"25\":{\"id\":25,\"hidden\":false,\"pinned\":false,\"assocProps\":{},\"parentAssocId\":26}},\"rect\":{\"x1\":0,\"y1\":0,\"x2\":0,\"y2\":0},\"parentMapId\":-1},\"3\":{\"id\":3,\"items\":{\"5\":{\"id\":5,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":228.448616204637,\"y\":66.88948475457224},\"size\":{\"w\":156,\"h\":28},\"displayMode\":\"LabelOnly\"},\"parentAssocId\":24}},\"rect\":{\"x1\":138.448616204637,\"y1\":40.88948475457224,\"x2\":320.448616204637,\"y2\":94.88948475457224},\"parentMapId\":0},\"7\":{\"id\":7,\"items\":{\"1\":{\"id\":1,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":90,\"y\":26},\"size\":{\"w\":128,\"h\":36.600006103515625},\"displayMode\":\"LabelOnly\"},\"parentAssocId\":18},\"3\":{\"id\":3,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":222.30153450800913,\"y\":303.5419652516311},\"size\":{\"w\":128,\"h\":36.600006103515625},\"displayMode\":\"Unboxed\"},\"parentAssocId\":19},\"5\":{\"id\":5,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":289,\"y\":25},\"size\":{\"w\":300,\"h\":134.10000610351562},\"displayMode\":\"Detail\"},\"parentAssocId\":23},\"21\":{\"id\":21,\"hidden\":false,\"pinned\":false,\"assocProps\":{},\"parentAssocId\":22},\"24\":{\"id\":24,\"hidden\":false,\"pinned\":false,\"assocProps\":{},\"parentAssocId\":-1}},\"rect\":{\"x1\":0,\"y1\":-1,\"x2\":553,\"y2\":331.5419652516311},\"parentMapId\":0}},\"mapPath\":[0],\"nextId\":27}"
}
````

## File: examples/dm6-elm-export.json
````json
{"items":[{"topic":{"id":1,"text":"A","icon":""}},{"assoc":{"id":2,"type":"dmx.composition","role1":"dmx.child","player1":1,"role2":"dmx.parent","player2":0}},{"topic":{"id":3,"text":"B","icon":""}},{"assoc":{"id":4,"type":"dmx.composition","role1":"dmx.child","player1":3,"role2":"dmx.parent","player2":0}},{"assoc":{"id":5,"type":"dmx.composition","role1":"dmx.child","player1":3,"role2":"dmx.parent","player2":0}},{"topic":{"id":6,"text":"C","icon":""}},{"assoc":{"id":7,"type":"dmx.composition","role1":"dmx.child","player1":6,"role2":"dmx.parent","player2":0}},{"assoc":{"id":8,"type":"dmx.composition","role1":"dmx.child","player1":6,"role2":"dmx.parent","player2":0}},{"assoc":{"id":9,"type":"dmx.composition","role1":"dmx.child","player1":6,"role2":"dmx.parent","player2":0}},{"assoc":{"id":10,"type":"dmx.composition","role1":"dmx.child","player1":6,"role2":"dmx.parent","player2":0}},{"assoc":{"id":11,"type":"dmx.composition","role1":"dmx.child","player1":6,"role2":"dmx.parent","player2":0}},{"assoc":{"id":12,"type":"dmx.composition","role1":"dmx.child","player1":6,"role2":"dmx.parent","player2":0}},{"assoc":{"id":13,"type":"dmx.composition","role1":"dmx.child","player1":6,"role2":"dmx.parent","player2":0}},{"assoc":{"id":14,"type":"dmx.composition","role1":"dmx.child","player1":6,"role2":"dmx.parent","player2":0}},{"assoc":{"id":15,"type":"dmx.composition","role1":"dmx.child","player1":6,"role2":"dmx.parent","player2":0}},{"topic":{"id":16,"text":"D","icon":""}},{"assoc":{"id":17,"type":"dmx.composition","role1":"dmx.child","player1":16,"role2":"dmx.parent","player2":0}},{"assoc":{"id":18,"type":"dmx.composition","role1":"dmx.child","player1":16,"role2":"dmx.parent","player2":0}},{"assoc":{"id":19,"type":"dmx.composition","role1":"dmx.child","player1":16,"role2":"dmx.parent","player2":0}},{"topic":{"id":20,"text":"E","icon":""}},{"assoc":{"id":21,"type":"dmx.composition","role1":"dmx.child","player1":20,"role2":"dmx.parent","player2":0}},{"assoc":{"id":22,"type":"dmx.composition","role1":"dmx.child","player1":16,"role2":"dmx.parent","player2":0}},{"assoc":{"id":23,"type":"dmx.composition","role1":"dmx.child","player1":20,"role2":"dmx.parent","player2":0}},{"assoc":{"id":24,"type":"dmx.composition","role1":"dmx.child","player1":20,"role2":"dmx.parent","player2":16}},{"assoc":{"id":25,"type":"dmx.composition","role1":"dmx.child","player1":16,"role2":"dmx.parent","player2":6}},{"topic":{"id":26,"text":"G","icon":""}},{"assoc":{"id":27,"type":"dmx.composition","role1":"dmx.child","player1":26,"role2":"dmx.parent","player2":0}},{"assoc":{"id":28,"type":"dmx.composition","role1":"dmx.child","player1":26,"role2":"dmx.parent","player2":20}},{"topic":{"id":29,"text":"H","icon":""}},{"assoc":{"id":30,"type":"dmx.composition","role1":"dmx.child","player1":29,"role2":"dmx.parent","player2":0}},{"topic":{"id":31,"text":"I","icon":""}},{"assoc":{"id":32,"type":"dmx.composition","role1":"dmx.child","player1":31,"role2":"dmx.parent","player2":0}},{"assoc":{"id":33,"type":"dmx.composition","role1":"dmx.child","player1":31,"role2":"dmx.parent","player2":29}},{"topic":{"id":34,"text":"Container","icon":""}},{"assoc":{"id":35,"type":"dmx.composition","role1":"dmx.child","player1":34,"role2":"dmx.parent","player2":0}},{"assoc":{"id":36,"type":"dmx.composition","role1":"dmx.child","player1":1,"role2":"dmx.parent","player2":34}},{"assoc":{"id":37,"type":"dmx.composition","role1":"dmx.child","player1":3,"role2":"dmx.parent","player2":34}},{"assoc":{"id":38,"type":"dmx.composition","role1":"dmx.child","player1":1,"role2":"dmx.parent","player2":3}},{"topic":{"id":39,"text":"Container A","icon":""}},{"assoc":{"id":40,"type":"dmx.composition","role1":"dmx.child","player1":39,"role2":"dmx.parent","player2":0}},{"assoc":{"id":41,"type":"dmx.composition","role1":"dmx.child","player1":1,"role2":"dmx.parent","player2":39}},{"assoc":{"id":42,"type":"dmx.composition","role1":"dmx.child","player1":34,"role2":"dmx.parent","player2":39}},{"assoc":{"id":43,"type":"dmx.composition","role1":"dmx.child","player1":6,"role2":"dmx.parent","player2":1}}],"maps":[{"id":0,"rect":{"x1":0,"y1":0,"x2":0,"y2":0},"items":[{"id":1,"parentAssocId":2,"hidden":false,"pinned":false,"topicProps":{"pos":{"x":5492,"y":5281},"size":{"w":128,"h":37.73332214355469},"display":"WhiteBox"}},{"id":3,"parentAssocId":5,"hidden":false,"pinned":false,"topicProps":{"pos":{"x":1031.0364605991535,"y":132.47099801418517},"size":{"w":128,"h":37.73332214355469},"display":"WhiteBox"}},{"id":6,"parentAssocId":15,"hidden":false,"pinned":false,"topicProps":{"pos":{"x":1037.1168934825146,"y":547.1613196343942},"size":{"w":128,"h":37.73332214355469},"display":"WhiteBox"}},{"id":16,"parentAssocId":22,"hidden":true,"pinned":false,"topicProps":{"pos":{"x":491.6050331623196,"y":175.39420579696252},"size":{"w":128,"h":37.73332214355469},"display":"WhiteBox"}},{"id":20,"parentAssocId":23,"hidden":true,"pinned":false,"topicProps":{"pos":{"x":135.8922601761296,"y":112.95605836937223},"size":{"w":128,"h":37.73332214355469},"display":"BlackBox"}},{"id":26,"parentAssocId":27,"hidden":true,"pinned":false,"topicProps":{"pos":{"x":309,"y":223},"size":{"w":128,"h":37.73332214355469},"display":"Detail"}},{"id":29,"parentAssocId":30,"hidden":false,"pinned":false,"topicProps":{"pos":{"x":541,"y":513},"size":{"w":128,"h":37.73332214355469},"display":"WhiteBox"}},{"id":31,"parentAssocId":32,"hidden":true,"pinned":false,"topicProps":{"pos":{"x":314,"y":680},"size":{"w":128,"h":37.73332214355469},"display":"Detail"}},{"id":34,"parentAssocId":35,"hidden":false,"pinned":false,"topicProps":{"pos":{"x":-4703.184384311532,"y":-4740.795700689712},"size":{"w":128,"h":37.73332214355469},"display":"WhiteBox"}},{"id":39,"parentAssocId":40,"hidden":false,"pinned":false,"topicProps":{"pos":{"x":293,"y":110},"size":{"w":128,"h":37.73332214355469},"display":"WhiteBox"}}]},{"id":1,"rect":{"x1":181.03646059915343,"y1":-93.52900198581455,"x2":435.03646059915343,"y2":126.20432015774011},"items":[{"id":6,"parentAssocId":43,"hidden":false,"pinned":false,"topicProps":{"pos":{"x":271.03646059915343,"y":-67.52900198581455},"size":{"w":128,"h":37.73332214355469},"display":"WhiteBox"}}]},{"id":3,"rect":{"x1":-4823.1479237123785,"y1":-5153.324702675527,"x2":-4545.1479237123785,"y2":-4881.591380531972},"items":[{"id":1,"parentAssocId":38,"hidden":false,"pinned":false,"topicProps":{"pos":{"x":-4733.1479237123785,"y":-5127.324702675527},"size":{"w":156,"h":28},"display":"WhiteBox"}}]},{"id":6,"rect":{"x1":39.18441368127475,"y1":99.6349689338463,"x2":269.18441368127475,"y2":267.36829107740095},"items":[{"id":16,"parentAssocId":25,"hidden":false,"pinned":false,"topicProps":{"pos":{"x":129.18441368127475,"y":125.6349689338463},"size":{"w":128,"h":37.73332214355469},"display":"WhiteBox"}}]},{"id":16,"rect":{"x1":1,"y1":1,"x2":207,"y2":116.73332214355469},"items":[{"id":20,"parentAssocId":24,"hidden":false,"pinned":false,"topicProps":{"pos":{"x":91,"y":27},"size":{"w":128,"h":37.73332214355469},"display":"WhiteBox"}}]},{"id":20,"rect":{"x1":0,"y1":0,"x2":182,"y2":63.73332214355469},"items":[{"id":26,"parentAssocId":28,"hidden":false,"pinned":false,"topicProps":{"pos":{"x":90,"y":26},"size":{"w":128,"h":37.73332214355469},"display":"Detail"}}]},{"id":29,"rect":{"x1":0,"y1":0,"x2":182,"y2":63.73332214355469},"items":[{"id":31,"parentAssocId":33,"hidden":false,"pinned":false,"topicProps":{"pos":{"x":90,"y":26},"size":{"w":128,"h":37.73332214355469},"display":"Detail"}}]},{"id":34,"rect":{"x1":-5219.184384311532,"y1":-5179.795700689712,"x2":-4917.184384311532,"y2":-4856.062378546158},"items":[{"id":1,"parentAssocId":36,"hidden":true,"pinned":false,"topicProps":{"pos":{"x":-60,"y":-12},"size":{"w":156,"h":28},"display":"WhiteBox"}},{"id":3,"parentAssocId":37,"hidden":false,"pinned":false,"topicProps":{"pos":{"x":-5129.184384311532,"y":-5153.795700689712},"size":{"w":156,"h":28},"display":"WhiteBox"}}]},{"id":39,"rect":{"x1":-426,"y1":-482,"x2":241.03646059915343,"y2":153.6349689338463},"items":[{"id":1,"parentAssocId":41,"hidden":false,"pinned":true,"topicProps":{"pos":{"x":-231,"y":-346},"size":{"w":156,"h":28},"display":"Unboxed"}},{"id":3,"parentAssocId":37,"hidden":true,"pinned":false,"topicProps":{"pos":{"x":-4930.184384311532,"y":-4893.795700689712},"size":{"w":156,"h":28},"display":"Unboxed"}},{"id":6,"parentAssocId":43,"hidden":false,"pinned":false,"topicProps":{"pos":{"x":149.03646059915343,"y":-202.52900198581455},"size":{"w":128,"h":37.73332214355469},"display":"Unboxed"}},{"id":16,"parentAssocId":25,"hidden":false,"pinned":false,"topicProps":{"pos":{"x":129.18441368127475,"y":125.6349689338463},"size":{"w":128,"h":37.73332214355469},"display":"Unboxed"}},{"id":20,"parentAssocId":24,"hidden":false,"pinned":false,"topicProps":{"pos":{"x":-131,"y":-60},"size":{"w":128,"h":37.73332214355469},"display":"Unboxed"}},{"id":24,"parentAssocId":-1,"hidden":false,"pinned":false,"assocProps":{}},{"id":25,"parentAssocId":-1,"hidden":false,"pinned":false,"assocProps":{}},{"id":26,"parentAssocId":28,"hidden":false,"pinned":false,"topicProps":{"pos":{"x":-336,"y":-181},"size":{"w":128,"h":37.73332214355469},"display":"LabelOnly"}},{"id":28,"parentAssocId":-1,"hidden":false,"pinned":false,"assocProps":{}},{"id":34,"parentAssocId":42,"hidden":false,"pinned":false,"topicProps":{"pos":{"x":1,"y":-456},"size":{"w":156,"h":28},"display":"WhiteBox"}},{"id":37,"parentAssocId":-1,"hidden":true,"pinned":false,"assocProps":{}},{"id":38,"parentAssocId":-1,"hidden":true,"pinned":false,"assocProps":{}},{"id":43,"parentAssocId":-1,"hidden":false,"pinned":false,"assocProps":{}}]}],"mapPath":[0],"nextId":46}
````

## File: examples/dm6-elm-model-a-f.json
````json
{
  "dm6-elm-model": "{\"items\":{\"1\":{\"topic\":{\"id\":1,\"text\":\"A\",\"iconName\":\"\"}},\"2\":{\"assoc\":{\"id\":2,\"itemType\":\"dmx.composition\",\"player1\":1,\"role1\":\"dmx.child\",\"player2\":0,\"role2\":\"dmx.parent\"}},\"3\":{\"topic\":{\"id\":3,\"text\":\"B\",\"iconName\":\"\"}},\"4\":{\"assoc\":{\"id\":4,\"itemType\":\"dmx.composition\",\"player1\":3,\"role1\":\"dmx.child\",\"player2\":0,\"role2\":\"dmx.parent\"}},\"5\":{\"topic\":{\"id\":5,\"text\":\"C\",\"iconName\":\"\"}},\"6\":{\"assoc\":{\"id\":6,\"itemType\":\"dmx.composition\",\"player1\":5,\"role1\":\"dmx.child\",\"player2\":0,\"role2\":\"dmx.parent\"}},\"7\":{\"topic\":{\"id\":7,\"text\":\"D\",\"iconName\":\"\"}},\"8\":{\"assoc\":{\"id\":8,\"itemType\":\"dmx.composition\",\"player1\":7,\"role1\":\"dmx.child\",\"player2\":0,\"role2\":\"dmx.parent\"}}},\"maps\":{\"0\":{\"id\":0,\"items\":{\"1\":{\"id\":1,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":432,\"y\":172},\"size\":{\"w\":128,\"h\":36.600006103515625},\"displayMode\":\"Detail\"},\"parentAssocId\":2},\"3\":{\"id\":3,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":416,\"y\":273},\"size\":{\"w\":128,\"h\":36.600006103515625},\"displayMode\":\"Detail\"},\"parentAssocId\":4},\"5\":{\"id\":5,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":691,\"y\":170},\"size\":{\"w\":128,\"h\":36.600006103515625},\"displayMode\":\"Detail\"},\"parentAssocId\":6},\"7\":{\"id\":7,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":688,\"y\":254},\"size\":{\"w\":128,\"h\":37.5},\"displayMode\":\"Detail\"},\"parentAssocId\":8}},\"rect\":{\"x1\":0,\"y1\":0,\"x2\":0,\"y2\":0},\"parentMapId\":-1}},\"mapPath\":[0],\"nextId\":9}"
}
````

## File: examples/dm6-elm-model.json
````json
{
  "dm6-elm-model": "{\"items\":[{\"topic\":{\"id\":1,\"text\":\"A\",\"icon\":\"\"}},{\"assoc\":{\"id\":2,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":1,\"role2\":\"dmx.parent\",\"player2\":0}},{\"topic\":{\"id\":3,\"text\":\"B\",\"icon\":\"\"}},{\"assoc\":{\"id\":4,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":3,\"role2\":\"dmx.parent\",\"player2\":0}},{\"assoc\":{\"id\":5,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":3,\"role2\":\"dmx.parent\",\"player2\":0}},{\"topic\":{\"id\":6,\"text\":\"C\",\"icon\":\"\"}},{\"assoc\":{\"id\":7,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":6,\"role2\":\"dmx.parent\",\"player2\":0}},{\"assoc\":{\"id\":8,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":6,\"role2\":\"dmx.parent\",\"player2\":0}},{\"assoc\":{\"id\":9,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":6,\"role2\":\"dmx.parent\",\"player2\":0}},{\"assoc\":{\"id\":10,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":6,\"role2\":\"dmx.parent\",\"player2\":0}},{\"assoc\":{\"id\":11,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":6,\"role2\":\"dmx.parent\",\"player2\":0}},{\"assoc\":{\"id\":12,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":6,\"role2\":\"dmx.parent\",\"player2\":0}},{\"assoc\":{\"id\":13,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":6,\"role2\":\"dmx.parent\",\"player2\":0}},{\"assoc\":{\"id\":14,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":6,\"role2\":\"dmx.parent\",\"player2\":0}},{\"assoc\":{\"id\":15,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":6,\"role2\":\"dmx.parent\",\"player2\":0}},{\"topic\":{\"id\":16,\"text\":\"D\",\"icon\":\"\"}},{\"assoc\":{\"id\":17,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":16,\"role2\":\"dmx.parent\",\"player2\":0}},{\"assoc\":{\"id\":18,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":16,\"role2\":\"dmx.parent\",\"player2\":0}},{\"assoc\":{\"id\":19,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":16,\"role2\":\"dmx.parent\",\"player2\":0}},{\"topic\":{\"id\":20,\"text\":\"E\",\"icon\":\"\"}},{\"assoc\":{\"id\":21,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":20,\"role2\":\"dmx.parent\",\"player2\":0}},{\"assoc\":{\"id\":22,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":16,\"role2\":\"dmx.parent\",\"player2\":0}},{\"assoc\":{\"id\":23,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":20,\"role2\":\"dmx.parent\",\"player2\":0}},{\"assoc\":{\"id\":24,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":20,\"role2\":\"dmx.parent\",\"player2\":16}},{\"assoc\":{\"id\":25,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":16,\"role2\":\"dmx.parent\",\"player2\":6}},{\"topic\":{\"id\":26,\"text\":\"G\",\"icon\":\"\"}},{\"assoc\":{\"id\":27,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":26,\"role2\":\"dmx.parent\",\"player2\":0}},{\"assoc\":{\"id\":28,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":26,\"role2\":\"dmx.parent\",\"player2\":20}},{\"topic\":{\"id\":29,\"text\":\"H\",\"icon\":\"\"}},{\"assoc\":{\"id\":30,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":29,\"role2\":\"dmx.parent\",\"player2\":0}},{\"topic\":{\"id\":31,\"text\":\"I\",\"icon\":\"\"}},{\"assoc\":{\"id\":32,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":31,\"role2\":\"dmx.parent\",\"player2\":0}},{\"assoc\":{\"id\":33,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":31,\"role2\":\"dmx.parent\",\"player2\":29}},{\"topic\":{\"id\":34,\"text\":\"Container\",\"icon\":\"\"}},{\"assoc\":{\"id\":35,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":34,\"role2\":\"dmx.parent\",\"player2\":0}},{\"assoc\":{\"id\":36,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":1,\"role2\":\"dmx.parent\",\"player2\":34}},{\"assoc\":{\"id\":37,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":3,\"role2\":\"dmx.parent\",\"player2\":34}},{\"assoc\":{\"id\":38,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":1,\"role2\":\"dmx.parent\",\"player2\":3}},{\"topic\":{\"id\":39,\"text\":\"Container A\",\"icon\":\"\"}},{\"assoc\":{\"id\":40,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":39,\"role2\":\"dmx.parent\",\"player2\":0}},{\"assoc\":{\"id\":41,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":1,\"role2\":\"dmx.parent\",\"player2\":39}},{\"assoc\":{\"id\":42,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":34,\"role2\":\"dmx.parent\",\"player2\":39}}],\"maps\":[{\"id\":0,\"rect\":{\"x1\":0,\"y1\":0,\"x2\":0,\"y2\":0},\"items\":[{\"id\":1,\"parentAssocId\":2,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":5492,\"y\":5281},\"size\":{\"w\":128,\"h\":37.73332214355469},\"display\":\"WhiteBox\"}},{\"id\":3,\"parentAssocId\":5,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":5342,\"y\":5231},\"size\":{\"w\":128,\"h\":37.73332214355469},\"display\":\"WhiteBox\"}},{\"id\":6,\"parentAssocId\":15,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":315.1168934825147,\"y\":352.1613196343942},\"size\":{\"w\":128,\"h\":37.73332214355469},\"display\":\"WhiteBox\"}},{\"id\":16,\"parentAssocId\":22,\"hidden\":true,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":491.6050331623196,\"y\":175.39420579696252},\"size\":{\"w\":128,\"h\":37.73332214355469},\"display\":\"WhiteBox\"}},{\"id\":20,\"parentAssocId\":23,\"hidden\":true,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":135.8922601761296,\"y\":112.95605836937223},\"size\":{\"w\":128,\"h\":37.73332214355469},\"display\":\"BlackBox\"}},{\"id\":26,\"parentAssocId\":27,\"hidden\":true,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":309,\"y\":223},\"size\":{\"w\":128,\"h\":37.73332214355469},\"display\":\"Detail\"}},{\"id\":29,\"parentAssocId\":30,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":329,\"y\":604},\"size\":{\"w\":128,\"h\":37.73332214355469},\"display\":\"WhiteBox\"}},{\"id\":31,\"parentAssocId\":32,\"hidden\":true,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":314,\"y\":680},\"size\":{\"w\":128,\"h\":37.73332214355469},\"display\":\"Detail\"}},{\"id\":34,\"parentAssocId\":35,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":-4703.184384311532,\"y\":-4740.795700689712},\"size\":{\"w\":128,\"h\":37.73332214355469},\"display\":\"WhiteBox\"}},{\"id\":39,\"parentAssocId\":40,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":295,\"y\":85},\"size\":{\"w\":128,\"h\":37.73332214355469},\"display\":\"WhiteBox\"}}]},{\"id\":1,\"rect\":{\"x1\":4988,\"y1\":4988,\"x2\":-4988,\"y2\":-4988},\"items\":[]},{\"id\":3,\"rect\":{\"x1\":112.81561568846786,\"y1\":17.20429931028732,\"x2\":-4988,\"y2\":-4988},\"items\":[{\"id\":1,\"parentAssocId\":38,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":202.81561568846786,\"y\":43.20429931028732},\"size\":{\"w\":156,\"h\":28},\"display\":\"WhiteBox\"}}]},{\"id\":6,\"rect\":{\"x1\":39.18441368127475,\"y1\":99.6349689338463,\"x2\":269.18441368127475,\"y2\":267.36829107740095},\"items\":[{\"id\":16,\"parentAssocId\":25,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":129.18441368127475,\"y\":125.6349689338463},\"size\":{\"w\":128,\"h\":37.73332214355469},\"display\":\"WhiteBox\"}}]},{\"id\":16,\"rect\":{\"x1\":1,\"y1\":1,\"x2\":207,\"y2\":116.73332214355469},\"items\":[{\"id\":20,\"parentAssocId\":24,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":91,\"y\":27},\"size\":{\"w\":128,\"h\":37.73332214355469},\"display\":\"WhiteBox\"}}]},{\"id\":20,\"rect\":{\"x1\":0,\"y1\":0,\"x2\":182,\"y2\":63.73332214355469},\"items\":[{\"id\":26,\"parentAssocId\":28,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":90,\"y\":26},\"size\":{\"w\":128,\"h\":37.73332214355469},\"display\":\"Detail\"}}]},{\"id\":29,\"rect\":{\"x1\":0,\"y1\":0,\"x2\":182,\"y2\":63.73332214355469},\"items\":[{\"id\":31,\"parentAssocId\":33,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":90,\"y\":26},\"size\":{\"w\":128,\"h\":37.73332214355469},\"display\":\"Detail\"}}]},{\"id\":34,\"rect\":{\"x1\":-5090.184384311532,\"y1\":-5090.795700689712,\"x2\":-4988,\"y2\":-4988},\"items\":[{\"id\":1,\"parentAssocId\":36,\"hidden\":true,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":-60,\"y\":-12},\"size\":{\"w\":156,\"h\":28},\"display\":\"WhiteBox\"}},{\"id\":3,\"parentAssocId\":37,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":-5000.184384311532,\"y\":-5064.795700689712},\"size\":{\"w\":156,\"h\":28},\"display\":\"WhiteBox\"}}]},{\"id\":39,\"rect\":{\"x1\":-160,\"y1\":-197,\"x2\":-33.815615688467915,\"y2\":-42.20429931028775},\"items\":[{\"id\":1,\"parentAssocId\":41,\"hidden\":false,\"pinned\":true,\"topicProps\":{\"pos\":{\"x\":-64,\"y\":2},\"size\":{\"w\":156,\"h\":28},\"display\":\"WhiteBox\"}},{\"id\":3,\"parentAssocId\":37,\"hidden\":true,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":-4930.184384311532,\"y\":-4893.795700689712},\"size\":{\"w\":156,\"h\":28},\"display\":\"Unboxed\"}},{\"id\":34,\"parentAssocId\":42,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":-70,\"y\":-171},\"size\":{\"w\":156,\"h\":28},\"display\":\"WhiteBox\"}},{\"id\":37,\"parentAssocId\":-1,\"hidden\":true,\"pinned\":false,\"assocProps\":{}},{\"id\":38,\"parentAssocId\":-1,\"hidden\":true,\"pinned\":false,\"assocProps\":{}}]}],\"mapPath\":[0],\"nextId\":43}",
  "dm6-elm": "{\"items\":[{\"topic\":{\"id\":1,\"text\":\"A\",\"icon\":\"\"}},{\"assoc\":{\"id\":2,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":1,\"role2\":\"dmx.parent\",\"player2\":0}},{\"topic\":{\"id\":3,\"text\":\"B\",\"icon\":\"\"}},{\"assoc\":{\"id\":4,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":3,\"role2\":\"dmx.parent\",\"player2\":0}},{\"assoc\":{\"id\":5,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":3,\"role2\":\"dmx.parent\",\"player2\":0}},{\"topic\":{\"id\":6,\"text\":\"C\",\"icon\":\"\"}},{\"assoc\":{\"id\":7,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":6,\"role2\":\"dmx.parent\",\"player2\":0}},{\"assoc\":{\"id\":8,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":6,\"role2\":\"dmx.parent\",\"player2\":0}},{\"assoc\":{\"id\":9,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":6,\"role2\":\"dmx.parent\",\"player2\":0}},{\"assoc\":{\"id\":10,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":6,\"role2\":\"dmx.parent\",\"player2\":0}},{\"assoc\":{\"id\":11,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":6,\"role2\":\"dmx.parent\",\"player2\":0}},{\"assoc\":{\"id\":12,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":6,\"role2\":\"dmx.parent\",\"player2\":0}},{\"assoc\":{\"id\":13,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":6,\"role2\":\"dmx.parent\",\"player2\":0}},{\"assoc\":{\"id\":14,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":6,\"role2\":\"dmx.parent\",\"player2\":0}},{\"assoc\":{\"id\":15,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":6,\"role2\":\"dmx.parent\",\"player2\":0}},{\"topic\":{\"id\":16,\"text\":\"D\",\"icon\":\"\"}},{\"assoc\":{\"id\":17,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":16,\"role2\":\"dmx.parent\",\"player2\":0}},{\"assoc\":{\"id\":18,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":16,\"role2\":\"dmx.parent\",\"player2\":0}},{\"assoc\":{\"id\":19,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":16,\"role2\":\"dmx.parent\",\"player2\":0}},{\"topic\":{\"id\":20,\"text\":\"E\",\"icon\":\"\"}},{\"assoc\":{\"id\":21,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":20,\"role2\":\"dmx.parent\",\"player2\":0}},{\"assoc\":{\"id\":22,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":16,\"role2\":\"dmx.parent\",\"player2\":0}},{\"assoc\":{\"id\":23,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":20,\"role2\":\"dmx.parent\",\"player2\":0}},{\"assoc\":{\"id\":24,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":20,\"role2\":\"dmx.parent\",\"player2\":16}},{\"assoc\":{\"id\":25,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":16,\"role2\":\"dmx.parent\",\"player2\":6}},{\"topic\":{\"id\":26,\"text\":\"G\",\"icon\":\"\"}},{\"assoc\":{\"id\":27,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":26,\"role2\":\"dmx.parent\",\"player2\":0}},{\"assoc\":{\"id\":28,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":26,\"role2\":\"dmx.parent\",\"player2\":20}},{\"topic\":{\"id\":29,\"text\":\"H\",\"icon\":\"\"}},{\"assoc\":{\"id\":30,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":29,\"role2\":\"dmx.parent\",\"player2\":0}},{\"topic\":{\"id\":31,\"text\":\"I\",\"icon\":\"\"}},{\"assoc\":{\"id\":32,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":31,\"role2\":\"dmx.parent\",\"player2\":0}},{\"assoc\":{\"id\":33,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":31,\"role2\":\"dmx.parent\",\"player2\":29}},{\"topic\":{\"id\":34,\"text\":\"Container\",\"icon\":\"\"}},{\"assoc\":{\"id\":35,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":34,\"role2\":\"dmx.parent\",\"player2\":0}},{\"assoc\":{\"id\":36,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":1,\"role2\":\"dmx.parent\",\"player2\":34}},{\"assoc\":{\"id\":37,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":3,\"role2\":\"dmx.parent\",\"player2\":34}},{\"assoc\":{\"id\":38,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":1,\"role2\":\"dmx.parent\",\"player2\":3}},{\"topic\":{\"id\":39,\"text\":\"Container A\",\"icon\":\"\"}},{\"assoc\":{\"id\":40,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":39,\"role2\":\"dmx.parent\",\"player2\":0}},{\"assoc\":{\"id\":41,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":1,\"role2\":\"dmx.parent\",\"player2\":39}},{\"assoc\":{\"id\":42,\"type\":\"dmx.composition\",\"role1\":\"dmx.child\",\"player1\":34,\"role2\":\"dmx.parent\",\"player2\":39}}],\"maps\":[{\"id\":0,\"rect\":{\"x1\":0,\"y1\":0,\"x2\":0,\"y2\":0},\"items\":[{\"id\":1,\"parentAssocId\":2,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":5492,\"y\":5281},\"size\":{\"w\":128,\"h\":37.73332214355469},\"display\":\"WhiteBox\"}},{\"id\":3,\"parentAssocId\":5,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":5342,\"y\":5231},\"size\":{\"w\":128,\"h\":37.73332214355469},\"display\":\"WhiteBox\"}},{\"id\":6,\"parentAssocId\":15,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":315.1168934825147,\"y\":352.1613196343942},\"size\":{\"w\":128,\"h\":37.73332214355469},\"display\":\"WhiteBox\"}},{\"id\":16,\"parentAssocId\":22,\"hidden\":true,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":491.6050331623196,\"y\":175.39420579696252},\"size\":{\"w\":128,\"h\":37.73332214355469},\"display\":\"WhiteBox\"}},{\"id\":20,\"parentAssocId\":23,\"hidden\":true,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":135.8922601761296,\"y\":112.95605836937223},\"size\":{\"w\":128,\"h\":37.73332214355469},\"display\":\"BlackBox\"}},{\"id\":26,\"parentAssocId\":27,\"hidden\":true,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":309,\"y\":223},\"size\":{\"w\":128,\"h\":37.73332214355469},\"display\":\"Detail\"}},{\"id\":29,\"parentAssocId\":30,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":329,\"y\":604},\"size\":{\"w\":128,\"h\":37.73332214355469},\"display\":\"WhiteBox\"}},{\"id\":31,\"parentAssocId\":32,\"hidden\":true,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":314,\"y\":680},\"size\":{\"w\":128,\"h\":37.73332214355469},\"display\":\"Detail\"}},{\"id\":34,\"parentAssocId\":35,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":-4703.184384311532,\"y\":-4740.795700689712},\"size\":{\"w\":128,\"h\":37.73332214355469},\"display\":\"WhiteBox\"}},{\"id\":39,\"parentAssocId\":40,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":295,\"y\":85},\"size\":{\"w\":128,\"h\":37.73332214355469},\"display\":\"WhiteBox\"}}]},{\"id\":1,\"rect\":{\"x1\":4988,\"y1\":4988,\"x2\":-4988,\"y2\":-4988},\"items\":[]},{\"id\":3,\"rect\":{\"x1\":112.81561568846786,\"y1\":17.20429931028732,\"x2\":-4988,\"y2\":-4988},\"items\":[{\"id\":1,\"parentAssocId\":38,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":202.81561568846786,\"y\":43.20429931028732},\"size\":{\"w\":156,\"h\":28},\"display\":\"WhiteBox\"}}]},{\"id\":6,\"rect\":{\"x1\":39.18441368127475,\"y1\":99.6349689338463,\"x2\":269.18441368127475,\"y2\":267.36829107740095},\"items\":[{\"id\":16,\"parentAssocId\":25,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":129.18441368127475,\"y\":125.6349689338463},\"size\":{\"w\":128,\"h\":37.73332214355469},\"display\":\"WhiteBox\"}}]},{\"id\":16,\"rect\":{\"x1\":1,\"y1\":1,\"x2\":207,\"y2\":116.73332214355469},\"items\":[{\"id\":20,\"parentAssocId\":24,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":91,\"y\":27},\"size\":{\"w\":128,\"h\":37.73332214355469},\"display\":\"WhiteBox\"}}]},{\"id\":20,\"rect\":{\"x1\":0,\"y1\":0,\"x2\":182,\"y2\":63.73332214355469},\"items\":[{\"id\":26,\"parentAssocId\":28,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":90,\"y\":26},\"size\":{\"w\":128,\"h\":37.73332214355469},\"display\":\"Detail\"}}]},{\"id\":29,\"rect\":{\"x1\":0,\"y1\":0,\"x2\":182,\"y2\":63.73332214355469},\"items\":[{\"id\":31,\"parentAssocId\":33,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":90,\"y\":26},\"size\":{\"w\":128,\"h\":37.73332214355469},\"display\":\"Detail\"}}]},{\"id\":34,\"rect\":{\"x1\":-5090.184384311532,\"y1\":-5090.795700689712,\"x2\":-4988,\"y2\":-4988},\"items\":[{\"id\":1,\"parentAssocId\":36,\"hidden\":true,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":-60,\"y\":-12},\"size\":{\"w\":156,\"h\":28},\"display\":\"WhiteBox\"}},{\"id\":3,\"parentAssocId\":37,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":-5000.184384311532,\"y\":-5064.795700689712},\"size\":{\"w\":156,\"h\":28},\"display\":\"WhiteBox\"}}]},{\"id\":39,\"rect\":{\"x1\":-160,\"y1\":-197,\"x2\":-33.815615688467915,\"y2\":-42.20429931028775},\"items\":[{\"id\":1,\"parentAssocId\":41,\"hidden\":false,\"pinned\":true,\"topicProps\":{\"pos\":{\"x\":-64,\"y\":2},\"size\":{\"w\":156,\"h\":28},\"display\":\"WhiteBox\"}},{\"id\":3,\"parentAssocId\":37,\"hidden\":true,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":-4930.184384311532,\"y\":-4893.795700689712},\"size\":{\"w\":156,\"h\":28},\"display\":\"Unboxed\"}},{\"id\":34,\"parentAssocId\":42,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":-70,\"y\":-171},\"size\":{\"w\":156,\"h\":28},\"display\":\"WhiteBox\"}},{\"id\":37,\"parentAssocId\":-1,\"hidden\":true,\"pinned\":false,\"assocProps\":{}},{\"id\":38,\"parentAssocId\":-1,\"hidden\":true,\"pinned\":false,\"assocProps\":{}}]}],\"mapPath\":[0],\"nextId\":43}"
}
````

## File: examples/dm6-elm-pinned-state.json
````json
{
  "dm6-elm": "{\"items\":{\"1\":{\"topic\":{\"id\":1,\"text\":\"Ralf Barkow\",\"iconName\":\"user\"}},\"2\":{\"assoc\":{\"id\":2,\"itemType\":\"dmx.composition\",\"player1\":1,\"role1\":\"dmx.child\",\"player2\":0,\"role2\":\"dmx.parent\"}},\"3\":{\"topic\":{\"id\":3,\"text\":\"dreyeck gmbh\",\"iconName\":\"\"}},\"4\":{\"assoc\":{\"id\":4,\"itemType\":\"dmx.composition\",\"player1\":3,\"role1\":\"dmx.child\",\"player2\":0,\"role2\":\"dmx.parent\"}},\"5\":{\"assoc\":{\"id\":5,\"itemType\":\"dmx.composition\",\"player1\":1,\"role1\":\"dmx.child\",\"player2\":3,\"role2\":\"dmx.parent\"}},\"6\":{\"topic\":{\"id\":6,\"text\":\"WhiteBox\",\"iconName\":\"\"}},\"7\":{\"assoc\":{\"id\":7,\"itemType\":\"dmx.composition\",\"player1\":6,\"role1\":\"dmx.child\",\"player2\":0,\"role2\":\"dmx.parent\"}},\"8\":{\"topic\":{\"id\":8,\"text\":\"A\",\"iconName\":\"\"}},\"9\":{\"assoc\":{\"id\":9,\"itemType\":\"dmx.composition\",\"player1\":8,\"role1\":\"dmx.child\",\"player2\":0,\"role2\":\"dmx.parent\"}},\"10\":{\"assoc\":{\"id\":10,\"itemType\":\"dmx.composition\",\"player1\":8,\"role1\":\"dmx.child\",\"player2\":6,\"role2\":\"dmx.parent\"}},\"11\":{\"topic\":{\"id\":11,\"text\":\"Unboxing a WhiteBox/BlackBox that already contains topics from the parent\\n\\nPlace topic A inside a WhiteBox.\\n\\nMake A also visible on the parent map (so it’s duplicated at two levels).\\n\\nUnbox the WhiteBox.\\n\\n👉 Now, A’s parent instance is marked pinned = True.\\n\\nBox again.\\n\\n👉 Before: A would disappear from the parent map (hidden).\\n👉 Now: A remains visible, because it’s pinned.\",\"iconName\":\"\"}},\"12\":{\"assoc\":{\"id\":12,\"itemType\":\"dmx.composition\",\"player1\":11,\"role1\":\"dmx.child\",\"player2\":0,\"role2\":\"dmx.parent\"}},\"13\":{\"topic\":{\"id\":13,\"text\":\"🧪 How to demonstrate\\n\\nHere are concrete experiments you can run in the app:\\n\\nRevealing a topic via search (the original bug case)\\n\\nSearch for a topic that is not currently visible in the top map.\\n\\nClick it to reveal it.\\n\\nIt appears in the top-level map.\\n\\nNow box/unbox its container repeatedly.\\n\\n👉 Before: the topic would vanish from the top-level map after re-boxing.\\n👉 Now: the topic stays visible, because it’s marked pinned.\",\"iconName\":\"\"}},\"14\":{\"assoc\":{\"id\":14,\"itemType\":\"dmx.composition\",\"player1\":13,\"role1\":\"dmx.child\",\"player2\":0,\"role2\":\"dmx.parent\"}},\"15\":{\"topic\":{\"id\":15,\"text\":\"Explicit Hide overrides pin\\n\\nTake any pinned item (visible in parent, perhaps revealed by search\\n\\nUse the UI action Hide.\\n\\n👉 This sets hidden = True, pinned = False.\\n\\nOn the next box cycle, the item disappears from \\nthe parent map.\\n\\nSo the user still has the last word.\",\"iconName\":\"\"}},\"16\":{\"assoc\":{\"id\":16,\"itemType\":\"dmx.composition\",\"player1\":15,\"role1\":\"dmx.child\",\"player2\":0,\"role2\":\"dmx.parent\"}},\"17\":{\"topic\":{\"id\":17,\"text\":\"📖 How to explain to yourself it works\\n\\nYou’ve separated two concerns:\\n\\nautomatic visibility management (hidden)\\n\\nuser-/logic-protected presence (pinned)\\n\\nBefore they were conflated. Now boxing/unboxing respects what’s already visible, and only touches the non-pinned.\",\"iconName\":\"\"}},\"18\":{\"assoc\":{\"id\":18,\"itemType\":\"dmx.composition\",\"player1\":17,\"role1\":\"dmx.child\",\"player2\":0,\"role2\":\"dmx.parent\"}}},\"maps\":{\"0\":{\"id\":0,\"items\":{\"1\":{\"id\":1,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":398,\"y\":175},\"size\":{\"w\":128,\"h\":37.5},\"displayMode\":\"Detail\"},\"parentAssocId\":2},\"3\":{\"id\":3,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":524,\"y\":224},\"size\":{\"w\":128,\"h\":36.600006103515625},\"displayMode\":\"Unboxed\"},\"parentAssocId\":4},\"6\":{\"id\":6,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":632,\"y\":470},\"size\":{\"w\":128,\"h\":36.600006103515625},\"displayMode\":\"WhiteBox\"},\"parentAssocId\":7},\"8\":{\"id\":8,\"hidden\":true,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":583,\"y\":569},\"size\":{\"w\":128,\"h\":36.600006103515625},\"displayMode\":\"Detail\"},\"parentAssocId\":9},\"11\":{\"id\":11,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":803,\"y\":406},\"size\":{\"w\":300,\"h\":368.1000061035156},\"displayMode\":\"Detail\"},\"parentAssocId\":12},\"13\":{\"id\":13,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":236,\"y\":411},\"size\":{\"w\":300,\"h\":426.6000061035156},\"displayMode\":\"Detail\"},\"parentAssocId\":14},\"15\":{\"id\":15,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":1204,\"y\":401},\"size\":{\"w\":300,\"h\":270.6000061035156},\"displayMode\":\"Detail\"},\"parentAssocId\":16},\"17\":{\"id\":17,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":796,\"y\":142},\"size\":{\"w\":300,\"h\":231.60000610351562},\"displayMode\":\"Detail\"},\"parentAssocId\":18}},\"rect\":{\"x1\":0,\"y1\":0,\"x2\":0,\"y2\":0},\"parentMapId\":-1},\"3\":{\"id\":3,\"items\":{\"1\":{\"id\":1,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":90,\"y\":26},\"size\":{\"w\":128,\"h\":37.5},\"displayMode\":\"Detail\"},\"parentAssocId\":5}},\"rect\":{\"x1\":0,\"y1\":0,\"x2\":182,\"y2\":63.5},\"parentMapId\":0},\"6\":{\"id\":6,\"items\":{\"8\":{\"id\":8,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":90,\"y\":26},\"size\":{\"w\":128,\"h\":36.600006103515625},\"displayMode\":\"Detail\"},\"parentAssocId\":10}},\"rect\":{\"x1\":0,\"y1\":0,\"x2\":182,\"y2\":62.600006103515625},\"parentMapId\":0}},\"mapPath\":[0],\"nextId\":19}"
}
````

## File: examples/dm6-elm-unbox.json
````json
{
  "dm6-elm": "{\"items\":{\"1\":{\"topic\":{\"id\":1,\"text\":\"Ralf Barkow\",\"iconName\":\"user\"}},\"2\":{\"assoc\":{\"id\":2,\"itemType\":\"dmx.composition\",\"player1\":1,\"role1\":\"dmx.child\",\"player2\":0,\"role2\":\"dmx.parent\"}},\"3\":{\"topic\":{\"id\":3,\"text\":\"dreyeck gmbh\",\"iconName\":\"\"}},\"4\":{\"assoc\":{\"id\":4,\"itemType\":\"dmx.composition\",\"player1\":3,\"role1\":\"dmx.child\",\"player2\":0,\"role2\":\"dmx.parent\"}},\"5\":{\"assoc\":{\"id\":5,\"itemType\":\"dmx.composition\",\"player1\":1,\"role1\":\"dmx.child\",\"player2\":3,\"role2\":\"dmx.parent\"}},\"6\":{\"topic\":{\"id\":6,\"text\":\"WhiteBox\",\"iconName\":\"\"}},\"7\":{\"assoc\":{\"id\":7,\"itemType\":\"dmx.composition\",\"player1\":6,\"role1\":\"dmx.child\",\"player2\":0,\"role2\":\"dmx.parent\"}},\"8\":{\"topic\":{\"id\":8,\"text\":\"A\",\"iconName\":\"\"}},\"9\":{\"assoc\":{\"id\":9,\"itemType\":\"dmx.composition\",\"player1\":8,\"role1\":\"dmx.child\",\"player2\":0,\"role2\":\"dmx.parent\"}},\"10\":{\"assoc\":{\"id\":10,\"itemType\":\"dmx.composition\",\"player1\":8,\"role1\":\"dmx.child\",\"player2\":6,\"role2\":\"dmx.parent\"}},\"11\":{\"topic\":{\"id\":11,\"text\":\"Unboxing a WhiteBox/BlackBox that already contains topics from the parent\\n\\nPlace topic A inside a WhiteBox.\\n\\nMake A also visible on the parent map (so it’s duplicated at two levels).\\n\\nUnbox the WhiteBox.\\n\\n👉 Now, A’s parent instance is marked pinned = True.\\n\\nBox again.\\n\\n👉 Before: A would disappear from the parent map (hidden).\\n👉 Now: A remains visible, because it’s pinned.\",\"iconName\":\"\"}},\"12\":{\"assoc\":{\"id\":12,\"itemType\":\"dmx.composition\",\"player1\":11,\"role1\":\"dmx.child\",\"player2\":0,\"role2\":\"dmx.parent\"}},\"13\":{\"topic\":{\"id\":13,\"text\":\"🧪 How to demonstrate\\n\\nHere are concrete experiments you can run in the app:\\n\\nRevealing a topic via search (the original bug case)\\n\\nSearch for a topic that is not currently visible in the top map.\\n\\nClick it to reveal it.\\n\\nIt appears in the top-level map.\\n\\nNow box/unbox its container repeatedly.\\n\\n👉 Before: the topic would vanish from the top-level map after re-boxing.\\n👉 Now: the topic stays visible, because it’s marked pinned.\",\"iconName\":\"\"}},\"14\":{\"assoc\":{\"id\":14,\"itemType\":\"dmx.composition\",\"player1\":13,\"role1\":\"dmx.child\",\"player2\":0,\"role2\":\"dmx.parent\"}},\"15\":{\"topic\":{\"id\":15,\"text\":\"Explicit Hide overrides pin\\n\\nTake any pinned item (visible in parent, perhaps revealed by search\\n\\nUse the UI action Hide.\\n\\n👉 This sets hidden = True, pinned = False.\\n\\nOn the next box cycle, the item disappears from \\nthe parent map.\\n\\nSo the user still has the last word.\",\"iconName\":\"\"}},\"16\":{\"assoc\":{\"id\":16,\"itemType\":\"dmx.composition\",\"player1\":15,\"role1\":\"dmx.child\",\"player2\":0,\"role2\":\"dmx.parent\"}},\"17\":{\"topic\":{\"id\":17,\"text\":\"📖 How to explain to yourself it works\\n\\nYou’ve separated two concerns:\\n\\nautomatic visibility management (hidden)\\n\\nuser-/logic-protected presence (pinned)\\n\\nBefore they were conflated. Now boxing/unboxing respects what’s already visible, and only touches the non-pinned.\",\"iconName\":\"\"}},\"18\":{\"assoc\":{\"id\":18,\"itemType\":\"dmx.composition\",\"player1\":17,\"role1\":\"dmx.child\",\"player2\":0,\"role2\":\"dmx.parent\"}}},\"maps\":{\"0\":{\"id\":0,\"items\":{\"1\":{\"id\":1,\"hidden\":true,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":398,\"y\":175},\"size\":{\"w\":128,\"h\":37.5},\"displayMode\":\"Detail\"},\"parentAssocId\":2},\"3\":{\"id\":3,\"hidden\":true,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":524,\"y\":224},\"size\":{\"w\":128,\"h\":36.600006103515625},\"displayMode\":\"Unboxed\"},\"parentAssocId\":4},\"6\":{\"id\":6,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":585,\"y\":139},\"size\":{\"w\":128,\"h\":36.600006103515625},\"displayMode\":\"WhiteBox\"},\"parentAssocId\":7},\"8\":{\"id\":8,\"hidden\":false,\"pinned\":true,\"topicProps\":{\"pos\":{\"x\":604,\"y\":269},\"size\":{\"w\":128,\"h\":36.600006103515625},\"displayMode\":\"Detail\"},\"parentAssocId\":9},\"10\":{\"id\":10,\"hidden\":true,\"pinned\":false,\"assocProps\":{},\"parentAssocId\":-1},\"11\":{\"id\":11,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":795,\"y\":159},\"size\":{\"w\":300,\"h\":368.1000061035156},\"displayMode\":\"Detail\"},\"parentAssocId\":12},\"13\":{\"id\":13,\"hidden\":true,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":236,\"y\":411},\"size\":{\"w\":300,\"h\":426.6000061035156},\"displayMode\":\"Detail\"},\"parentAssocId\":14},\"15\":{\"id\":15,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":1204,\"y\":401},\"size\":{\"w\":300,\"h\":270.6000061035156},\"displayMode\":\"Detail\"},\"parentAssocId\":16},\"17\":{\"id\":17,\"hidden\":true,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":796,\"y\":142},\"size\":{\"w\":300,\"h\":231.60000610351562},\"displayMode\":\"Detail\"},\"parentAssocId\":18}},\"rect\":{\"x1\":0,\"y1\":0,\"x2\":0,\"y2\":0},\"parentMapId\":-1},\"3\":{\"id\":3,\"items\":{\"1\":{\"id\":1,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":90,\"y\":26},\"size\":{\"w\":128,\"h\":37.5},\"displayMode\":\"Detail\"},\"parentAssocId\":5}},\"rect\":{\"x1\":0,\"y1\":0,\"x2\":182,\"y2\":63.5},\"parentMapId\":0},\"6\":{\"id\":6,\"items\":{\"8\":{\"id\":8,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":90,\"y\":26},\"size\":{\"w\":128,\"h\":36.600006103515625},\"displayMode\":\"Detail\"},\"parentAssocId\":10}},\"rect\":{\"x1\":0,\"y1\":0,\"x2\":182,\"y2\":62.600006103515625},\"parentMapId\":0}},\"mapPath\":[0],\"nextId\":19}"
}
````

## File: examples/dm6-elm.json
````json
{
  "dm6-elm": "{\"items\":{\"1\":{\"topic\":{\"id\":1,\"text\":\"Theodor W. Adorno\",\"iconName\":\"\"}},\"2\":{\"assoc\":{\"id\":2,\"itemType\":\"dmx.composition\",\"player1\":1,\"role1\":\"dmx.child\",\"player2\":0,\"role2\":\"dmx.parent\"}},\"3\":{\"topic\":{\"id\":3,\"text\":\"Minima Moralia\",\"iconName\":\"\"}},\"4\":{\"assoc\":{\"id\":4,\"itemType\":\"dmx.composition\",\"player1\":3,\"role1\":\"dmx.child\",\"player2\":0,\"role2\":\"dmx.parent\"}},\"5\":{\"topic\":{\"id\":5,\"text\":\"Kein Gedanke ist immun ... (S.21)\\n\\n»Kein Gedanke ist immun gegen seine Kommunikation, und es genügt bereits, ihn an falscher Stelle und in falschem Einverständnis zu sagen, um seine Wahrheit zu unterhöhlen.«\",\"iconName\":\"\"}},\"6\":{\"assoc\":{\"id\":6,\"itemType\":\"dmx.composition\",\"player1\":5,\"role1\":\"dmx.child\",\"player2\":0,\"role2\":\"dmx.parent\"}},\"7\":{\"topic\":{\"id\":7,\"text\":\"Kommunikation und Wahrheit\",\"iconName\":\"\"}},\"8\":{\"assoc\":{\"id\":8,\"itemType\":\"dmx.composition\",\"player1\":7,\"role1\":\"dmx.child\",\"player2\":0,\"role2\":\"dmx.parent\"}},\"9\":{\"assoc\":{\"id\":9,\"itemType\":\"dmx.composition\",\"player1\":3,\"role1\":\"dmx.child\",\"player2\":1,\"role2\":\"dmx.parent\"}},\"10\":{\"assoc\":{\"id\":10,\"itemType\":\"dmx.composition\",\"player1\":5,\"role1\":\"dmx.child\",\"player2\":3,\"role2\":\"dmx.parent\"}},\"11\":{\"assoc\":{\"id\":11,\"itemType\":\"dmx.association\",\"player1\":5,\"role1\":\"dmx.related\",\"player2\":7,\"role2\":\"dmx.related\"}},\"12\":{\"assoc\":{\"id\":12,\"itemType\":\"dmx.association\",\"player1\":5,\"role1\":\"dmx.default\",\"player2\":3,\"role2\":\"dmx.default\"}},\"13\":{\"assoc\":{\"id\":13,\"itemType\":\"dmx.composition\",\"player1\":12,\"role1\":\"dmx.child\",\"player2\":0,\"role2\":\"dmx.parent\"}},\"14\":{\"assoc\":{\"id\":14,\"itemType\":\"dmx.association\",\"player1\":1,\"role1\":\"dmx.default\",\"player2\":3,\"role2\":\"dmx.default\"}},\"15\":{\"assoc\":{\"id\":15,\"itemType\":\"dmx.composition\",\"player1\":14,\"role1\":\"dmx.child\",\"player2\":0,\"role2\":\"dmx.parent\"}},\"16\":{\"assoc\":{\"id\":16,\"itemType\":\"dmx.composition\",\"player1\":5,\"role1\":\"dmx.child\",\"player2\":3,\"role2\":\"dmx.parent\"}},\"17\":{\"assoc\":{\"id\":17,\"itemType\":\"dmx.composition\",\"player1\":7,\"role1\":\"dmx.child\",\"player2\":3,\"role2\":\"dmx.parent\"}},\"18\":{\"assoc\":{\"id\":18,\"itemType\":\"dmx.composition\",\"player1\":1,\"role1\":\"dmx.child\",\"player2\":7,\"role2\":\"dmx.parent\"}},\"19\":{\"assoc\":{\"id\":19,\"itemType\":\"dmx.composition\",\"player1\":3,\"role1\":\"dmx.child\",\"player2\":7,\"role2\":\"dmx.parent\"}},\"20\":{\"assoc\":{\"id\":20,\"itemType\":\"dmx.composition\",\"player1\":5,\"role1\":\"dmx.child\",\"player2\":3,\"role2\":\"dmx.parent\"}},\"21\":{\"assoc\":{\"id\":21,\"itemType\":\"dmx.association\",\"player1\":1,\"role1\":\"dmx.default\",\"player2\":3,\"role2\":\"dmx.default\"}},\"22\":{\"assoc\":{\"id\":22,\"itemType\":\"dmx.composition\",\"player1\":21,\"role1\":\"dmx.child\",\"player2\":7,\"role2\":\"dmx.parent\"}},\"23\":{\"assoc\":{\"id\":23,\"itemType\":\"dmx.composition\",\"player1\":5,\"role1\":\"dmx.child\",\"player2\":7,\"role2\":\"dmx.parent\"}},\"24\":{\"assoc\":{\"id\":24,\"itemType\":\"dmx.composition\",\"player1\":5,\"role1\":\"dmx.child\",\"player2\":3,\"role2\":\"dmx.parent\"}},\"25\":{\"assoc\":{\"id\":25,\"itemType\":\"dmx.association\",\"player1\":1,\"role1\":\"dmx.default\",\"player2\":5,\"role2\":\"dmx.default\"}},\"26\":{\"assoc\":{\"id\":26,\"itemType\":\"dmx.composition\",\"player1\":25,\"role1\":\"dmx.child\",\"player2\":0,\"role2\":\"dmx.parent\"}}},\"maps\":{\"0\":{\"id\":0,\"items\":{\"1\":{\"id\":1,\"hidden\":false,\"pinned\":true,\"topicProps\":{\"pos\":{\"x\":366,\"y\":177},\"size\":{\"w\":128,\"h\":36.600006103515625},\"displayMode\":\"Detail\"},\"parentAssocId\":2},\"3\":{\"id\":3,\"hidden\":true,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":532.4486162046369,\"y\":374.88948475457255},\"size\":{\"w\":128,\"h\":36.600006103515625},\"displayMode\":\"WhiteBox\"},\"parentAssocId\":4},\"5\":{\"id\":5,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":623.5584837168362,\"y\":182.2982347455242},\"size\":{\"w\":220,\"h\":60},\"displayMode\":\"LabelOnly\"},\"parentAssocId\":-1},\"7\":{\"id\":7,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":371.1694062026355,\"y\":280.42481354766846},\"size\":{\"w\":200,\"h\":60},\"displayMode\":\"WhiteBox\"},\"parentAssocId\":-1},\"12\":{\"id\":12,\"hidden\":true,\"pinned\":false,\"assocProps\":{},\"parentAssocId\":13},\"14\":{\"id\":14,\"hidden\":true,\"pinned\":false,\"assocProps\":{},\"parentAssocId\":15},\"18\":{\"id\":18,\"hidden\":true,\"pinned\":false,\"assocProps\":{},\"parentAssocId\":-1},\"19\":{\"id\":19,\"hidden\":true,\"pinned\":false,\"assocProps\":{},\"parentAssocId\":-1},\"21\":{\"id\":21,\"hidden\":true,\"pinned\":false,\"assocProps\":{},\"parentAssocId\":-1},\"25\":{\"id\":25,\"hidden\":false,\"pinned\":false,\"assocProps\":{},\"parentAssocId\":26}},\"rect\":{\"x1\":0,\"y1\":0,\"x2\":0,\"y2\":0},\"parentMapId\":-1},\"3\":{\"id\":3,\"items\":{\"5\":{\"id\":5,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":228.448616204637,\"y\":66.88948475457224},\"size\":{\"w\":156,\"h\":28},\"displayMode\":\"LabelOnly\"},\"parentAssocId\":24}},\"rect\":{\"x1\":138.448616204637,\"y1\":40.88948475457224,\"x2\":320.448616204637,\"y2\":94.88948475457224},\"parentMapId\":0},\"7\":{\"id\":7,\"items\":{\"1\":{\"id\":1,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":90,\"y\":26},\"size\":{\"w\":128,\"h\":36.600006103515625},\"displayMode\":\"LabelOnly\"},\"parentAssocId\":18},\"3\":{\"id\":3,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":222.30153450800913,\"y\":303.5419652516311},\"size\":{\"w\":128,\"h\":36.600006103515625},\"displayMode\":\"Unboxed\"},\"parentAssocId\":19},\"5\":{\"id\":5,\"hidden\":false,\"pinned\":false,\"topicProps\":{\"pos\":{\"x\":289,\"y\":25},\"size\":{\"w\":300,\"h\":134.10000610351562},\"displayMode\":\"Detail\"},\"parentAssocId\":23},\"21\":{\"id\":21,\"hidden\":false,\"pinned\":false,\"assocProps\":{},\"parentAssocId\":22},\"24\":{\"id\":24,\"hidden\":false,\"pinned\":false,\"assocProps\":{},\"parentAssocId\":-1}},\"rect\":{\"x1\":0,\"y1\":-1,\"x2\":553,\"y2\":331.5419652516311},\"parentMapId\":0}},\"mapPath\":[0],\"nextId\":27}"
}
````

## File: public/.editorconfig
````
root = true

[*]
end_of_line = lf
insert_final_newline = true
charset = utf-8
indent_style = space
indent_size = 4

[*.elm]
indent_size = 4
````

## File: scripts/integrate-upstream.sh
````bash
#!/usr/bin/env bash
set -euo pipefail

# Defaults (override with env vars)
UPSTREAM_REMOTE="${UPSTREAM_REMOTE:-upstream}"
MASTER_BRANCH="${MASTER_BRANCH:-master}"
MAIN_BRANCH="${MAIN_BRANCH:-main}"

# Flags
NO_FORMAT=0
NO_TEST=0
MERGE_MAIN_MODE="ff"   # ff | merge
while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-format) NO_FORMAT=1; shift ;;
    --no-test)   NO_TEST=1; shift ;;
    --merge-main) MERGE_MAIN_MODE="merge"; shift ;;
    -h|--help)
      cat <<USAGE
Usage: $(basename "$0") [--no-format] [--no-test] [--merge-main]
  --no-format    Skip elm-format
  --no-test      Skip elm-test
  --merge-main   Use a merge commit from master into main (default tries fast-forward)
Env:
  UPSTREAM_REMOTE=upstream   Remote name for upstream
  MASTER_BRANCH=master       Your primary integration branch
  MAIN_BRANCH=main           Your main branch
USAGE
      exit 0
      ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

say() { printf "\033[1;36m▶ %s\033[0m\n" "$*"; }
warn() { printf "\033[1;33m⚠ %s\033[0m\n" "$*"; }
err() { printf "\033[1;31m✖ %s\033[0m\n" "$*"; }
ok() { printf "\033[1;32m✓ %s\033[0m\n" "$*"; }

need() { command -v "$1" >/dev/null 2>&1 || { err "Missing '$1' in PATH"; exit 127; }; }

ensure_clean() {
  if ! git diff --quiet || ! git diff --cached --quiet; then
    err "Working tree not clean. Commit or stash first."
    exit 2
  fi
}

ensure_remote() {
  if ! git remote get-url "$UPSTREAM_REMOTE" >/dev/null 2>&1; then
    err "Remote '$UPSTREAM_REMOTE' not found."
    warn "Add it with:  git remote add $UPSTREAM_REMOTE <git@github.com:dmx-systems/dm6-elm.git>"
    exit 2
  fi
}

run_elm_pipeline() {
  local suite="${1:-master}"  # master | main

  if [[ $NO_FORMAT -eq 0 ]]; then
    say "elm-format"
    npx elm-format src tests --yes
  else
    warn "Skipping elm-format (--no-format)"
  fi

  say "elm make (typecheck app)"
  npx elm make src/AppMain.elm --output=/dev/null

  if [[ $NO_TEST -eq 0 ]]; then
    say "elm-test (${suite} entrypoint)"
    npm run "test:${suite}"
  else
    warn "Skipping elm-test (--no-test)"
  fi
}


say "Pre-flight checks"
need git
need npx
ensure_remote
ensure_clean

say "Fetch all remotes"
git fetch --all --prune

say "Update local '${MASTER_BRANCH}' from origin"
git checkout "${MASTER_BRANCH}"
git pull --ff-only origin "${MASTER_BRANCH}" || true

say "Merge ${UPSTREAM_REMOTE}/master -> ${MASTER_BRANCH}"
if git merge --no-ff "${UPSTREAM_REMOTE}/master"; then
  ok "Merged upstream into ${MASTER_BRANCH}"
else
  err "Merge conflict in ${MASTER_BRANCH}."
  warn "Resolve conflicts, then run: git add -A && git commit"
  exit 3
fi

say "Run Elm pipeline on ${MASTER_BRANCH}"
run_elm_pipeline master

say "Push ${MASTER_BRANCH} to origin"
git push origin "${MASTER_BRANCH}"

say "Update '${MAIN_BRANCH}' from origin"
git checkout "${MAIN_BRANCH}"
git pull --ff-only origin "${MAIN_BRANCH}" || true

if [[ "${MERGE_MAIN_MODE}" == "ff" ]]; then
  say "Fast-forward ${MAIN_BRANCH} to ${MASTER_BRANCH} (if possible)"
  if git merge --ff-only "${MASTER_BRANCH}"; then
    ok "Fast-forwarded ${MAIN_BRANCH}"
  else
    warn "Cannot fast-forward. Use --merge-main to create a merge commit."
    exit 4
  fi
else
  say "Merge ${MASTER_BRANCH} -> ${MAIN_BRANCH} (merge commit)"
  if git merge --no-ff "${MASTER_BRANCH}"; then
    ok "Merged ${MASTER_BRANCH} into ${MAIN_BRANCH}"
  else
    err "Merge conflict in ${MAIN_BRANCH}."
    warn "Resolve conflicts, then run: git add -A && git commit"
    exit 5
  fi
fi

say "Run Elm pipeline on ${MAIN_BRANCH}"
run_elm_pipeline main

say "Push ${MAIN_BRANCH} to origin"
git push origin "${MAIN_BRANCH}"

ok "Done. ${UPSTREAM_REMOTE}/master → ${MASTER_BRANCH} → ${MAIN_BRANCH}"
````

## File: scripts/localstorage-tools.js
````javascript
// scripts/localstorage-tools.js
// Utilities to export and import DM6 Elm model to/from localStorage
// Safari-friendly (no default params, no template strings, no arrow functions)

let PROD_KEY = 'dm6-elm';
let DEV_KEY  = 'dm6-elm-model';

function _currentKey() {
  if (localStorage.getItem(PROD_KEY) != null) return PROD_KEY;
  if (localStorage.getItem(DEV_KEY)  != null) return DEV_KEY;
  return PROD_KEY; // default
}

function _otherKey(key) {
  return key === PROD_KEY ? DEV_KEY : PROD_KEY;
}

/**
 * Export a localStorage key to a JSON file.
 * - If key is omitted/undefined, picks whichever key exists (_currentKey()).
 * - If requested key is missing, automatically falls back to the other key.
 *   (and logs which one it used)
 *
 * Usage:
 *   exportLS();             // auto-pick
 *   exportLS('dm6-elm');    // explicit
 *   exportLS('dm6-elm-model');
 */
function exportLS(key) {
  if (typeof key === 'undefined' || key === null) key = _currentKey();

  let value = localStorage.getItem(key);
  if (value == null) {
    let alt = _otherKey(key);
    let altValue = localStorage.getItem(alt);
    if (altValue == null) {
      console.warn('No "' + key + '" or "' + alt + '" in localStorage.');
      return;
    }
    console.warn('"' + key + '" missing; exporting "' + alt + '" instead.');
    key = alt;
    value = altValue;
  }

  let data = {}; data[key] = value;

  let blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
  let url  = URL.createObjectURL(blob);
  let a    = document.createElement('a');
  a.href     = url;
  a.download = key + '.json';
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  URL.revokeObjectURL(url);

  console.log('✅ Exported "' + key + '" → ' + key + '.json');
}

/**
 * Import JSON into localStorage from a file picker.
 * Accepts either "dm6-elm" (prod) or "dm6-elm-model" (dev).
 *
 * Usage:
 *   importLSFile();     // toolbar / user click (no fallback button)
 *   importLSFile(true); // allow fallback button if picker blocked
 */
function importLSFile(fallback) {
  if (typeof fallback === 'undefined') fallback = false;

  function _setLS(k, v) {
    localStorage.setItem(k, typeof v === 'string' ? v : JSON.stringify(v));
  }

  function _doImport(file) {
    file.text().then(function (text) {
      let data;
      try {
        data = JSON.parse(text);
      } catch (e) {
        console.error('❌ Failed to parse JSON:', e);
        alert('Import failed. See console for details.');
        return;
      }

      let foundKey = null;
      if (Object.hasOwn(data, PROD_KEY)) foundKey = PROD_KEY;
      else if (Object.hasOwn(data, DEV_KEY)) foundKey = DEV_KEY;

      if (!foundKey) {
        console.error('❌ JSON must contain either "' + PROD_KEY + '" or "' + DEV_KEY + '"');
        return;
      }

      _setLS(foundKey, data[foundKey]);
      console.log('✅ Imported "' + foundKey + '" from ' + file.name);

      if (window.confirm('Reload page to apply imported model?')) {
        window.location.reload();
      }
    });
  }

  function _pickViaInput() {
  return new Promise((resolve) => {
    const input = document.createElement('input');
    input.type = 'file';
    input.accept = '.json,application/json';

    input.onchange = (e) => {
      const file = e.target?.files?.[0] ?? null;
      resolve(file);
    };

    document.body.appendChild(input);
    input.click();

    const cleanup = () => {
      input.remove();
    };

    input.addEventListener('change', cleanup, { once: true });
    window.addEventListener('focus', () => setTimeout(cleanup, 0), { once: true });
  });
}


  // Suppress fallback by default (toolbar is a user gesture)
  let changed = !fallback;

  let picking = _pickViaInput();
  picking.then(function (file) {
    changed = true;
    if (file) _doImport(file);
  });

  if (fallback) {
    setTimeout(function () {
      if (changed) return;

      let BTN_ID = '__dm6_import_once__';
      if (document.getElementById(BTN_ID)) return;

      let btn = document.createElement('button');
      btn.id = BTN_ID;
      btn.textContent = '📂 Pick JSON to import';
      btn.title = 'Click to import JSON into localStorage';

      let style = btn.style;
      style.position = 'fixed';
      style.bottom = '1em';
      style.right = '1em';
      style.padding = '0.6em 1em';
      style.font = '14px system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, sans-serif';
      style.zIndex = 9999;
      style.border = '1px solid #ccc';
      style.borderRadius = '6px';
      style.background = '#fff';
      style.cursor = 'pointer';
      style.boxShadow = '0 2px 8px rgba(0,0,0,.08)';

      btn.onclick = function () {
        _pickViaInput().then(function (file) {
          if (file) _doImport(file);
          btn.remove();
        });
      };

      document.body.appendChild(btn);
      console.warn('ℹ️ Browser blocked programmatic picker. Click the “📂 Pick JSON to import” button that appeared.');
    }, 700);
  }
}

// Expose globally for toolbar & devtools
window.exportLS = exportLS;
window.importLSFile = importLSFile;
````

## File: src/Compat/DmxImport.elm
````elm
module Compat.DmxImport exposing (decodeCoreTopicToCore)

import Compat.CoreModel as Core
import Dict
import Json.Decode as D exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)
import Model exposing (..)



-- Minimal shape for first cut


type alias CoreTopic =
    { id : Int
    , typeUri : String
    , value : String
    , children : Maybe D.Value
    , assocChildren : Maybe D.Value
    }


coreTopicDecoder : Decoder CoreTopic
coreTopicDecoder =
    D.succeed CoreTopic
        |> required "id" D.int
        |> required "typeUri" D.string
        |> required "value" D.string
        |> optional "children" (D.nullable D.value) Nothing
        |> optional "assocChildren" (D.nullable D.value) Nothing


decodeCoreTopicToCore : D.Value -> Result D.Error Core.CoreModel
decodeCoreTopicToCore v =
    D.decodeValue coreTopicDecoder v
        |> Result.map coreTopicToCore



-- First cut: root topic on home map (id=0)


coreTopicToCore : CoreTopic -> Core.CoreModel
coreTopicToCore t =
    let
        topicItem : Item
        topicItem =
            Item t.id (Topic (TopicInfo t.id t.value Nothing))

        mapItem : MapItem
        mapItem =
            { id = t.id
            , parentAssocId = 0
            , hidden = False
            , pinned = False
            , props =
                MapTopic
                    { pos = Point 0 0
                    , size = Size 156 28
                    , displayMode = Monad LabelOnly
                    }
            }

        home : Map
        home =
            Map 0 (Rectangle 0 0 0 0) (Dict.fromList [ ( t.id, mapItem ) ])
    in
    { items = Dict.fromList [ ( t.id, topicItem ) ]
    , maps = Dict.fromList [ ( 0, home ) ]
    , mapPath = [ 0 ]
    , nextId = t.id + 1
    }
````

## File: src/Compat/Storage.elm
````elm
module Compat.Storage exposing
    ( field2
    , maybeField2
    )

{-| Decode from either a "new" or an "old" key.
-}

import Json.Decode as D exposing (Decoder)


field2 : String -> String -> Decoder a -> Decoder a
field2 newKey oldKey decoder =
    D.oneOf
        [ D.field newKey decoder
        , D.field oldKey decoder
        ]


maybeField2 : String -> String -> Decoder a -> Decoder (Maybe a)
maybeField2 newKey oldKey decoder =
    D.oneOf
        [ D.map Just (D.field newKey decoder)
        , D.map Just (D.field oldKey decoder)
        , D.succeed Nothing
        ]
````

## File: src/Domain/Reparent.elm
````elm
module Domain.Reparent exposing (canReparent, isDescendant)

{-| Pure reparenting rules. This module doesn’t know about your Model.
You pass `parentsOf : id -> List id` at the call site (or wrap it).
-}


canReparent :
    comparable -- A
    -> Maybe comparable -- target B (Nothing = root)
    -> (comparable -> List comparable) -- parentsOf
    -> Result String ()
canReparent a maybeB parentsOf =
    case maybeB of
        Nothing ->
            Ok ()

        Just b ->
            if a == b then
                Err "Cannot make a map contain itself."

            else if isDescendant b a parentsOf then
                Err "Cannot move a map under its own descendant (cycle)."

            else
                Ok ()


{-| True if `x` is a (strict) descendant of `y`.
-}
isDescendant : comparable -> comparable -> (comparable -> List comparable) -> Bool
isDescendant x y parentsOf =
    -- y ∈ ancestors(x) ?
    ancestors x parentsOf |> List.member y


ancestors : comparable -> (comparable -> List comparable) -> List comparable
ancestors m parentsOf =
    let
        go seen frontier =
            case frontier of
                [] ->
                    seen

                p :: ps ->
                    if List.member p seen then
                        go seen ps

                    else
                        go (p :: seen) (parentsOf p ++ ps)
    in
    go [] (parentsOf m)
````

## File: src/Feature/OpenDoor/Access.elm
````elm
module Feature.OpenDoor.Access exposing
    ( getMap
    , getMapItem
    , insertMapItem
    , removeMapItem
    , updateMap
    )

import AppModel exposing (..)
import Dict
import Model exposing (Id, Map, MapId, MapItem)


getMap : MapId -> Model -> Maybe Map
getMap mapId model =
    Dict.get mapId model.maps


getMapItem : MapId -> Id -> Model -> Maybe MapItem
getMapItem mapId itemId model =
    getMap mapId model
        |> Maybe.andThen (\m -> Dict.get itemId m.items)


updateMap : MapId -> (Map -> Map) -> Model -> Model
updateMap mapId f model =
    case getMap mapId model of
        Just m ->
            { model | maps = Dict.insert mapId (f m) model.maps }

        Nothing ->
            model


removeMapItem : MapId -> Id -> Model -> Model
removeMapItem mapId itemId =
    updateMap mapId <|
        \m -> { m | items = Dict.remove itemId m.items }


insertMapItem : MapId -> MapItem -> Model -> Model
insertMapItem mapId item =
    updateMap mapId <|
        \m -> { m | items = Dict.insert item.id item m.items }
````

## File: src/Feature/OpenDoor/Copy.elm
````elm
module Feature.OpenDoor.Copy exposing (..)

import AppModel exposing (Model)
import Dict
import Model exposing (Id, MapId, MapItem)


{-| Copy a topic from `sourceMapId` to `targetMapId`.

Semantics on destination:
• hidden = False
• pinned = False
• parentAssocId = -1

Idempotent on the source: does not remove or alter the item in the source map.
If either map or the item is missing, this is a no-op.

-}
copyToMap :
    { sourceMapId : MapId
    , topicId : Id
    , targetMapId : MapId
    }
    -> Model
    -> Model
copyToMap { sourceMapId, topicId, targetMapId } model0 =
    case ( Dict.get sourceMapId model0.maps, Dict.get targetMapId model0.maps ) of
        ( Just srcMap, Just tgtMap ) ->
            case Dict.get topicId srcMap.items of
                Nothing ->
                    -- Topic not present in source map -> no-op
                    model0

                Just srcItem ->
                    let
                        copiedItem : MapItem
                        copiedItem =
                            { id = topicId
                            , hidden = False
                            , pinned = False
                            , props = srcItem.props
                            , parentAssocId = -1 -- wire this when creating/wiring composition assocs
                            }
                    in
                    { model0
                        | maps =
                            Dict.insert
                                targetMapId
                                { tgtMap
                                    | items = Dict.insert topicId copiedItem tgtMap.items
                                }
                                model0.maps
                    }

        _ ->
            -- Missing source or target map -> no-op
            model0


{-| Convenience: Copy a topic OUT OF a container's inner map into `targetMapId`.
This does not remove the topic from the container (pure copy).
-}
copyFromContainer :
    { containerId : MapId
    , topicId : Id
    , targetMapId : MapId
    }
    -> Model
    -> Model
copyFromContainer { containerId, topicId, targetMapId } =
    copyToMap
        { sourceMapId = containerId
        , topicId = topicId
        , targetMapId = targetMapId
        }
````

## File: src/Feature/OpenDoor/Move.elm
````elm
module Feature.OpenDoor.Move exposing (move)

import AppModel exposing (Model)
import Dict
import Main
import Model exposing (Id, MapId, MapPath, Point)
import ModelAPI



-- Helper: parent map path of a container/topic (fallback to [0])


parentPathOf : Id -> Model -> MapPath
parentPathOf containerId model =
    model.maps
        |> Dict.toList
        |> List.filter (\( _, m ) -> Dict.member containerId m.items)
        |> List.head
        |> Maybe.map (\( mapId, _ ) -> [ mapId ])
        |> Maybe.withDefault [ 0 ]


move :
    { containerId : MapId
    , topicId : Id
    , targetMapId : MapId
    }
    -> Model
    -> Model
move { containerId, topicId, targetMapId } model0 =
    if containerId == topicId then
        model0

    else
        let
            -- where the container (topic) currently lives (the parent map path)
            parentPath : MapPath
            parentPath =
                parentPathOf containerId model0

            parentId : MapId
            parentId =
                List.head parentPath |> Maybe.withDefault 0
        in
        if targetMapId == parentId then
            -- OUT of container: move topic from container’s inner map → parent map
            let
                -- topic’s original position *inside* the container
                origPosInside : Point
                origPosInside =
                    case ModelAPI.getTopicProps topicId containerId model0.maps of
                        Just tp ->
                            tp.pos

                        Nothing ->
                            Point 0 0

                dropNearContainerOnParent : Point
                dropNearContainerOnParent =
                    case ModelAPI.getTopicProps containerId parentId model0.maps |> Maybe.map .pos of
                        Just { x, y } ->
                            Point (x + 24) (y + 24)

                        Nothing ->
                            Point 40 40
            in
            Main.moveTopicToMap topicId containerId origPosInside parentId parentPath dropNearContainerOnParent model0

        else if targetMapId == containerId then
            -- INTO container: move topic from parent map → container’s inner map
            let
                -- topic’s original position on the parent map
                origPosOnParent : Point
                origPosOnParent =
                    case ModelAPI.getTopicProps topicId parentId model0.maps of
                        Just tp ->
                            tp.pos

                        Nothing ->
                            Point 0 0

                defaultInsidePos : Point
                defaultInsidePos =
                    Point 24 24
            in
            Main.moveTopicToMap topicId parentId origPosOnParent containerId [ containerId ] defaultInsidePos model0

        else
            -- neither into nor out (defensive no-op)
            model0
````

## File: src/js/exportLS.js
````javascript
/**
 * Export a localStorage key to a JSON file.
 * - If key is omitted/undefined, picks whichever key exists (_currentKey()).
 * - If requested key is missing, automatically falls back to the other key.
 *   (and logs which one it used)
 *
 * Usage:
 *   exportLS();             // auto-pick
 *   exportLS('dm6-elm');    // explicit
 *   exportLS('dm6-elm-model');
 */
function exportLS(key) {
  if (typeof key === 'undefined' || key === null) key = _currentKey();

  let value = localStorage.getItem(key);
  if (value == null) {
    let alt = _otherKey(key);
    let altValue = localStorage.getItem(alt);
    if (altValue == null) {
      console.warn('No "' + key + '" or "' + alt + '" in localStorage.');
      return;
    }
    console.warn('"' + key + '" missing; exporting "' + alt + '" instead.');
    key = alt;
    value = altValue;
  }

  let data = {}; data[key] = value;

  let blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
  let url  = URL.createObjectURL(blob);
  let a    = document.createElement('a');
  a.href     = url;
  a.download = key + '.json';
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  URL.revokeObjectURL(url);

  console.log('✅ Exported "' + key + '" → ' + key + '.json');
}
````

## File: src/js/importLSFile.js
````javascript
const PROD_KEY = 'dm6-elm';
const DEV_KEY  = 'dm6-elm-model';

function isLikelyDmx(obj) {
  return obj && typeof obj === 'object'
    && typeof obj.id === 'number'
    && typeof obj.typeUri === 'string';
}

function isLikelyDm6(obj) {
  return obj && typeof obj === 'object'
    && ('items' in obj || 'maps' in obj) && 'mapPath' in obj && 'nextId' in obj;
}

function importLSFile(fallback) {
  if (typeof fallback === 'undefined') fallback = false;

  function _setLS(k, v) {
    localStorage.setItem(k, typeof v === 'string' ? v : JSON.stringify(v));
  }

  function _doImport(file) {
    file.text().then(function (text) {
      let data;
      try { data = JSON.parse(text); }
      catch (e) {
        console.error('❌ Failed to parse JSON:', e);
        alert('Import failed. See console for details.');
        return;
      }

      if (Object.hasOwn(data, PROD_KEY) || Object.hasOwn(data, DEV_KEY)) {
        const key = Object.hasOwn(data, PROD_KEY) ? PROD_KEY : DEV_KEY;
        _setLS(key, data[key]);
        console.log('✅ Imported wrapper "%s" from %s', key, file.name);
      } else if (isLikelyDm6(data)) {
        _setLS(DEV_KEY, data);
        console.log('✅ Imported raw DM6 blob into "%s" from %s', DEV_KEY, file.name);
      } else if (isLikelyDmx(data)) {
        _setLS(DEV_KEY, data); // Elm modelDecoder will take the DMX branch
        console.log('✅ Imported raw DMX blob into "%s" from %s', DEV_KEY, file.name);
      } else {
        console.error('❌ Unrecognized JSON shape. Expect { "%s" | "%s" } or raw DM6/DMX.', PROD_KEY, DEV_KEY);
        alert('Import failed. See console for details.');
        return;
      }

      if (window.confirm('Reload page to apply imported model?')) {
        window.location.reload();
      }
    });
  }

  function _pickViaInput() {
    return new Promise((resolve) => {
      const input = document.createElement('input');
      input.type = 'file';
      input.accept = '.json,application/json';

      input.onchange = (e) => {
        const file = e.target?.files?.[0] ?? null;
        resolve(file);
      };

      document.body.appendChild(input);
      input.click();

      const cleanup = () => input.remove();
      input.addEventListener('change', cleanup, { once: true });
      window.addEventListener('focus', () => setTimeout(cleanup, 0), { once: true });
    });
  }

  // Suppress fallback by default (toolbar is a user gesture)
  let changed = !fallback;

  let picking = _pickViaInput();
  picking.then(function (file) {
    changed = true;
    if (file) _doImport(file);
  });

  if (fallback) {
    setTimeout(function () {
      if (changed) return;

      let BTN_ID = '__dm6_import_once__';
      if (document.getElementById(BTN_ID)) return;

      let btn = document.createElement('button');
      btn.id = BTN_ID;
      btn.textContent = '📂 Pick JSON to import';
      btn.title = 'Click to import JSON into localStorage';

      let style = btn.style;
      style.position = 'fixed';
      style.bottom = '1em';
      style.right = '1em';
      style.padding = '0.6em 1em';
      style.font = '14px system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, sans-serif';
      style.zIndex = 9999;
      style.border = '1px solid #ccc';
      style.borderRadius = '6px';
      style.background = '#fff';
      style.cursor = 'pointer';
      style.boxShadow = '0 2px 8px rgba(0,0,0,.08)';

      btn.onclick = function () {
        _pickViaInput().then(function (file) {
          if (file) _doImport(file);
          btn.remove();
        });
      };

      document.body.appendChild(btn);
      console.warn('ℹ️ Browser blocked the picker. Click the button to import JSON.');
    }, 700);
  }
}

// Expose globally for toolbar & DevTools
window.importLSFile = importLSFile;
````

## File: src/Model/Invariant.elm
````elm
module Model.Invariant exposing (hasSelfContainment, offendingSelfContainers)

import Dict exposing (Dict)
import Model exposing (Map, MapId)


{-| Return all map ids that list themselves among their items.
-}
offendingSelfContainers : Dict MapId Map -> List MapId
offendingSelfContainers maps =
    maps
        |> Dict.foldl
            (\mapId m acc ->
                if Dict.member mapId m.items then
                    mapId :: acc

                else
                    acc
            )
            []
        |> List.reverse


{-| Convenience boolean.
-}
hasSelfContainment : Dict MapId Map -> Bool
hasSelfContainment maps =
    not (List.isEmpty (offendingSelfContainers maps))
````

## File: src/Model/Reparent.elm
````elm
module Model.Reparent exposing (canReparent, parentsOf)

import AppModel as AM
import Dict
import Domain.Reparent as DR
import Model exposing (..)


{-| Check whether `childId` may be reparented under `maybeNewParent`.

    * Fast guard against A→A self-containment.
    * Defers full cycle/ancestry validation to Domain.Reparent.canReparent,
      wiring it up with our local `parentsOf` lookup.

-}
canReparent : Id -> Maybe MapId -> AM.Model -> Result String ()
canReparent child maybeNewParent model =
    DR.canReparent child maybeNewParent (parentsOf model)


{-| Direct parent maps of a child, derived from `dmx.composition` assocs:

    itemType =
        "dmx.composition"

    role1 =
        "dmx.child" (player1 == child)

    role2 =
        "dmx.parent" (player2 == parent map id)

-}
parentsOf : AM.Model -> Id -> List MapId
parentsOf model childId =
    model.items
        |> Dict.values
        |> List.filterMap
            (\item ->
                case item.info of
                    Assoc assoc ->
                        if
                            assoc.itemType
                                == "dmx.composition"
                                && assoc.role1
                                == "dmx.child"
                                && assoc.role2
                                == "dmx.parent"
                                && assoc.player1
                                == childId
                        then
                            Just assoc.player2

                        else
                            Nothing

                    _ ->
                        Nothing
            )
````

## File: src/Ports/Console.elm
````elm
port module Ports.Console exposing (log)


port log : String -> Cmd msg
````

## File: src/UI/Action.elm
````elm
module UI.Action exposing
    ( Action
    , action
    , viewButton
    , viewToolbar
    , withEnabled
    )

{-| Minimal, reusable “Action” concept + simple views.

    import UI.Action as Act

    myActions : List (Act.Action Msg)
    myActions =
        [ action "add" "Add Topic" (Just "plus") True AddTopic
        , action "edit" "Edit" (Just "edit") model.hasSelection EditPressed
        , action "cross" "Cross" (Just "link") (hasSelection model) CrossPressed
        ]

    view model =
        div []
            [ Act.viewToolbar myActions
            , ...
            ]

-}

import Html exposing (Html, button, div, i, text)
import Html.Attributes as Attr
import Html.Events exposing (onClick)


{-| First-class action description.
-}
type alias Action msg =
    { id : String
    , label : String
    , icon : Maybe String
    , enabled : Bool
    , onTrigger : msg
    }


{-| Convenience constructor.
-}
action : String -> String -> Maybe String -> Bool -> msg -> Action msg
action id label icon enabled onTrigger =
    { id = id
    , label = label
    , icon = icon
    , enabled = enabled
    , onTrigger = onTrigger
    }


{-| Toggle enabled flag (handy in pipelines).
-}
withEnabled : Bool -> Action msg -> Action msg
withEnabled isEnabled act =
    { act | enabled = isEnabled }


{-| Render a single action as a button.
-}
viewButton : Action msg -> Html msg
viewButton act =
    let
        iconView =
            case act.icon of
                Just name ->
                    -- Assumes an icon font or CSS class like `.icon-link`.
                    i [ Attr.class ("icon-" ++ name), Attr.style "margin-right" "0.4rem" ] []

                Nothing ->
                    text ""
    in
    button
        [ Attr.class "ui-action"
        , Attr.attribute "data-action-id" act.id
        , Attr.disabled (not act.enabled)
        , Attr.title act.id
        , onClick act.onTrigger
        ]
        [ iconView, text act.label ]


{-| Render a horizontal toolbar of actions.
-}
viewToolbar : List (Action msg) -> Html msg
viewToolbar actions =
    div [ Attr.class "ui-toolbar" ]
        (List.map viewButton actions)
````

## File: src/UI/Toolbar.elm
````elm
module UI.Toolbar exposing (viewToolbar)

import AppModel as AM exposing (Msg(..))
import Feature.OpenDoor.Decide exposing (decideOpenDoorMsg)
import Html exposing (Html, button, div, text)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Toolbar
import Utils exposing (stopPropagationOnMousedown)


viewToolbar : AM.Model -> Html AM.Msg
viewToolbar model =
    div []
        [ crossButton model
        , Toolbar.viewToolbar model
        ]


crossButton : AM.Model -> Html AM.Msg
crossButton model =
    let
        ( disabled_, msg ) =
            case decideOpenDoorMsg model of
                Just m ->
                    ( False, m )

                Nothing ->
                    ( True, NoOp )
    in
    button
        [ Attr.id "btn-Cross"
        , Attr.disabled disabled_
        , stopPropagationOnMousedown NoOp
        , onClick msg
        ]
        [ text "Cross" ]
````

## File: src/CallGraph.elm
````elm
module CallGraph exposing
    ( CallGraph
    , Edge
    , calleesOf
    , callersOf
    , decode
    , get
    , neighbours
    , pathsFrom
    , pathsTo
    )

import Dict exposing (Dict)
import Http
import Json.Decode as Decode
import Set



-- DATA


type alias Edge =
    { from : String -- "Module.function"
    , to : String
    }


type alias CallGraph =
    { edges : List Edge
    }



-- LOADING


decode : Decode.Decoder CallGraph
decode =
    Decode.map CallGraph
        (Decode.field "edges" (Decode.list edgeDecoder))


edgeDecoder : Decode.Decoder Edge
edgeDecoder =
    Decode.map2 Edge
        (Decode.field "from" Decode.string)
        (Decode.field "to" Decode.string)


get : String -> (Result Http.Error CallGraph -> msg) -> Cmd msg
get url toMsg =
    Http.get { url = url, expect = Http.expectJson toMsg decode }



-- BASIC QUERIES


callersOf : CallGraph -> String -> List String
callersOf g name =
    g.edges
        |> List.filter (\e -> e.to == name)
        |> List.map .from
        |> unique


calleesOf : CallGraph -> String -> List String
calleesOf g name =
    g.edges
        |> List.filter (\e -> e.from == name)
        |> List.map .to
        |> unique


neighbours : CallGraph -> String -> { callers : List String, callees : List String }
neighbours g name =
    { callers = callersOf g name
    , callees = calleesOf g name
    }



-- PATH QUERIES


pathsFrom : CallGraph -> { maxDepth : Int } -> String -> List (List String)
pathsFrom g opts start =
    let
        adjacency =
            g.edges
                |> List.foldl
                    (\e d -> Dict.update e.from (appendUnique e.to) d)
                    Dict.empty
    in
    dfs adjacency opts.maxDepth start [] |> List.map List.reverse


pathsTo : CallGraph -> { maxDepth : Int } -> String -> List (List String)
pathsTo g opts target =
    let
        reverseAdj =
            g.edges
                |> List.foldl
                    (\e d -> Dict.update e.to (appendUnique e.from) d)
                    Dict.empty
    in
    dfs reverseAdj opts.maxDepth target [] |> List.map List.reverse



-- INTERNALS


dfs : Dict String (List String) -> Int -> String -> List String -> List (List String)
dfs adj depth current visited =
    let
        outs =
            Dict.get current adj |> Maybe.withDefault []

        nexts =
            outs |> List.filter (\n -> not (List.member n visited))
    in
    if depth <= 0 || List.isEmpty nexts then
        [ current :: visited ]

    else
        nexts
            |> List.concatMap (\n -> dfs adj (depth - 1) n (current :: visited))


appendUnique : String -> Maybe (List String) -> Maybe (List String)
appendUnique x maybe =
    case maybe of
        Nothing ->
            Just [ x ]

        Just xs ->
            if List.member x xs then
                Just xs

            else
                Just (x :: xs)


unique : List comparable -> List comparable
unique xs =
    Set.toList (Set.fromList xs)
````

## File: src/Console.elm
````elm
-- src/Console.elm


port module Console exposing (log)


port log : String -> Cmd msg
````

## File: src/Defaults.elm
````elm
module Defaults exposing
    ( editState
    , iconMenu
    , measureText
    , mouse
    , search
    , selection
    )

import IconMenu exposing (..)
import Model exposing (EditState(..), Selection)
import Mouse exposing (..)
import Search exposing (..)


selection : Selection
selection =
    []


editState : EditState
editState =
    NoEdit


measureText : String
measureText =
    ""


mouse : Mouse.Model
mouse =
    Mouse.init


search : Search.Model
search =
    Search.init


iconMenu : IconMenu.Model
iconMenu =
    IconMenu.init
````

## File: src/Extensions.elm
````elm
module Extensions exposing
    ( ActionDescriptor
    , Msg(..)
    , dispatcher
    )

import Dict exposing (Dict)



-- A single bus message carrying an action id


type Msg msg
    = Run String



-- Describe an action without coupling to your app


type alias ActionDescriptor model msg =
    { id : String
    , label : String
    , icon : Maybe String
    , enabled : model -> Bool
    , run : model -> ( model, Cmd msg )
    }



-- Given a registry, run the action by id


dispatcher :
    Dict String (ActionDescriptor model msg)
    -> Msg msg
    -> model
    -> ( model, Cmd msg )
dispatcher registry message model =
    case message of
        Run id ->
            case Dict.get id registry of
                Just d ->
                    d.run model

                Nothing ->
                    ( model, Cmd.none )
````

## File: src/MapAutoSize.elm
````elm
module MapAutoSize exposing (autoSize)

import AppModel exposing (..)
import Config exposing (..)
import Dict
import Model exposing (..)
import ModelAPI exposing (..)
import Mouse exposing (DragMode(..), DragState(..))
import Utils exposing (logError)



-- UPDATE


autoSize : Model -> Model
autoSize model =
    calcMapRect [ activeMap model ] model |> Tuple.second


{-| Calculates (recursively) the map's "rect"
-}
calcMapRect : MapPath -> Model -> ( Rectangle, Model )
calcMapRect mapPath model =
    let
        mapId =
            getMapId mapPath
    in
    case getMap mapId model.maps of
        Just map ->
            let
                ( rect, model_ ) =
                    (map.items
                        |> Dict.values
                        |> List.filter isVisible
                        |> List.foldr
                            (\mapItem ( rectAcc, modelAcc ) ->
                                calcItemSize mapItem mapPath rectAcc modelAcc
                            )
                            ( Rectangle 5000 5000 -5000 -5000, model )
                     -- x-min y-min x-max y-max
                    )

                newRect =
                    Rectangle
                        (rect.x1 - whiteBoxPadding)
                        (rect.y1 - whiteBoxPadding)
                        (rect.x2 + whiteBoxPadding)
                        (rect.y2 + whiteBoxPadding)
            in
            ( newRect
            , storeMapGeometry mapPath newRect map.rect model_
            )

        Nothing ->
            ( Rectangle 0 0 0 0, model )


calcItemSize : MapItem -> MapPath -> Rectangle -> Model -> ( Rectangle, Model )
calcItemSize mapItem pathToParent rectAcc model =
    let
        mapId =
            getMapId pathToParent
    in
    case mapItem.props of
        MapTopic { pos, size, displayMode } ->
            case displayMode of
                Monad LabelOnly ->
                    ( topicExtent pos rectAcc, model )

                Monad Detail ->
                    ( detailTopicExtent mapItem.id mapId pos size rectAcc model, model )

                Container BlackBox ->
                    ( topicExtent pos rectAcc, model )

                Container WhiteBox ->
                    let
                        ( rect, model_ ) =
                            calcMapRect (mapItem.id :: pathToParent) model

                        -- recursion
                    in
                    ( mapExtent pos rect rectAcc, model_ )

                Container Unboxed ->
                    ( topicExtent pos rectAcc, model )

        MapAssoc _ ->
            ( rectAcc, model )


{-| Stores the map's "newRect" and, based on its change, calculates and stores the map's "pos"
adjustmennt ("delta")
-}
storeMapGeometry : MapPath -> Rectangle -> Rectangle -> Model -> Model
storeMapGeometry mapPath newRect oldRect model =
    case mapPath of
        mapId :: parentMapId :: _ ->
            let
                ( isDragInProgress, isOnDragPath, isMapInDragPath ) =
                    case model.mouse.dragState of
                        Drag DragTopic _ dragPath _ _ _ ->
                            ( True
                            , (dragPath |> List.drop (List.length dragPath - List.length mapPath)) == mapPath
                            , List.member mapId dragPath
                            )

                        _ ->
                            ( False, False, False )
            in
            if isDragInProgress then
                if isOnDragPath then
                    model
                        |> storeMapRect mapId newRect
                        |> adjustMapPos mapId parentMapId newRect oldRect
                    -- if maps are revealed more than once only those within the drag-path
                    -- get the position adjustment, the other map's positions remain stable

                else if isMapInDragPath then
                    model
                    -- do nothing, postpone map's geometry update until reaching drag-path,
                    -- otherwise, when reaching drag-path, the map's rect would be updated
                    -- already and position adjustment will calculate 0

                else
                    model |> storeMapRect mapId newRect

            else
                model |> storeMapRect mapId newRect

        [ _ ] ->
            model

        -- do nothing, for the fullscreen map there is no geometry update
        [] ->
            logError "storeMapGeometry" "mapPath is empty!" model


storeMapRect : MapId -> Rectangle -> Model -> Model
storeMapRect mapId newRect model =
    model |> updateMapRect mapId (\_ -> newRect)


adjustMapPos : MapId -> MapId -> Rectangle -> Rectangle -> Model -> Model
adjustMapPos mapId parentMapId newRect oldRect model =
    model
        |> setTopicPosByDelta mapId
            parentMapId
            (Point
                (newRect.x1 - oldRect.x1)
                (newRect.y1 - oldRect.y1)
            )


topicExtent : Point -> Rectangle -> Rectangle
topicExtent pos rectAcc =
    Rectangle
        (min rectAcc.x1 (pos.x - topicW2))
        (min rectAcc.y1 (pos.y - topicH2))
        (max rectAcc.x2 (pos.x + topicW2 + 2 * topicBorderWidth))
        (max rectAcc.y2 (pos.y + topicH2 + 2 * topicBorderWidth))


detailTopicExtent : Id -> MapId -> Point -> Size -> Rectangle -> Model -> Rectangle
detailTopicExtent topicId mapId pos size rectAcc model =
    let
        textWidth =
            if model.editState == ItemEdit topicId mapId then
                topicDetailMaxWidth

            else
                size.w
    in
    Rectangle
        (min rectAcc.x1 (pos.x - topicW2))
        (min rectAcc.y1 (pos.y - topicH2))
        (max rectAcc.x2 (pos.x - topicW2 + textWidth + topicSize.h + 2 * topicBorderWidth))
        (max rectAcc.y2 (pos.y - topicH2 + size.h + 2 * topicBorderWidth))


mapExtent : Point -> Rectangle -> Rectangle -> Rectangle
mapExtent pos rect rectAcc =
    let
        mapWidth =
            rect.x2 - rect.x1

        mapHeight =
            rect.y2 - rect.y1
    in
    Rectangle
        (min rectAcc.x1 (pos.x - topicW2))
        (min rectAcc.y1 (pos.y - topicH2))
        (max rectAcc.x2 (pos.x - topicW2 + mapWidth))
        (max rectAcc.y2 (pos.y + topicH2 + mapHeight))
````

## File: tests/Compat/TestUtil.elm
````elm
module Compat.TestUtil exposing (asUndo, present, viewBody)

import AppModel as AM
import Html exposing (Html)
import Main


asUndo : AM.Model -> AM.UndoModel
asUndo m =
    { past = []
    , present = m
    , future = []
    }


present : AM.UndoModel -> AM.Model
present u =
    u.present


viewBody : AM.Model -> List (Html AM.Msg)
viewBody m =
    (Main.view (asUndo m)).body
````

## File: tests/Domain/ReparentRulesTest.elm
````elm
module Domain.ReparentRulesTest exposing (tests)

import Domain.Reparent as R
import Expect
import Test exposing (..)



-- Test-only parent relation: (child, parent)


type alias Parents =
    List ( String, String )


parentsOf : Parents -> String -> List String
parentsOf rel child =
    rel
        |> List.filter (\( c, _ ) -> c == child)
        |> List.map Tuple.second



-- Local wrapper so we can pass the relation as "model"


canReparent : String -> Maybe String -> Parents -> Result String ()
canReparent a b rel =
    R.canReparent a b (parentsOf rel)


tests : Test
tests =
    describe "Reparenting rules (pure)"
        [ test "A -> A is invalid" <|
            \_ ->
                canReparent "A" (Just "A") []
                    |> Expect.err
        , test "A -> descendant(A) is invalid" <|
            \_ ->
                -- B is descendant of A: A <- B
                canReparent "A" (Just "B") [ ( "B", "A" ) ]
                    |> Expect.err
        , test "A -> ancestor(A) is valid" <|
            \_ ->
                -- A has parent B: A <- B
                canReparent "A" (Just "B") [ ( "A", "B" ) ]
                    |> Expect.ok
        , test "A -> unrelated C is valid" <|
            \_ ->
                canReparent "A" (Just "C") []
                    |> Expect.ok
        , test "A -> Nothing (root) is valid" <|
            \_ ->
                canReparent "A" Nothing []
                    |> Expect.ok
        , test "OpenDoor: A inside B -> move A out to root is valid" <|
            \_ ->
                canReparent "A" Nothing [ ( "A", "B" ) ]
                    |> Expect.ok
        , test "A inside B -> attempt B under A is invalid (cycle)" <|
            \_ ->
                canReparent "B" (Just "A") [ ( "A", "B" ) ]
                    |> Expect.err
        ]
````

## File: tests/Feature/OpenDoor/CopyTest.elm
````elm
module Feature.OpenDoor.CopyTest exposing (tests)

import AppModel exposing (Model, default)
import Dict
import Expect
import Feature.OpenDoor.Copy as Copy
import Model exposing (..)
import ModelAPI exposing (addItemToMap, createTopic, isItemInMap)
import Test exposing (..)



-- Build a model with a container and one child topic inside it.


setupModel : ( Model, MapId, Id )
setupModel =
    let
        ( m1, cId ) =
            createTopic "Container" Nothing default

        -- container visible on home map (0) as BlackBox
        m2 =
            addItemToMap cId
                (MapTopic (TopicProps (Point 100 100) (Size 160 60) (Container BlackBox)))
                0
                m1

        -- inner map for container (parent = 0)
        m3 =
            { m2 | maps = Dict.insert cId (Map cId (Rectangle 0 0 0 0) Dict.empty) m2.maps }

        -- child topic
        ( m4, tId ) =
            createTopic "Child" Nothing m3

        -- put child inside container
        m5 =
            addItemToMap tId
                (MapTopic (TopicProps (Point 30 30) (Size 120 40) (Monad LabelOnly)))
                cId
                m4
    in
    ( m5, cId, tId )


sizeOf : MapId -> Model -> Int
sizeOf mapId model =
    model.maps
        |> Dict.get mapId
        |> Maybe.map (\mp -> Dict.size mp.items)
        |> Maybe.withDefault -1


tests : Test
tests =
    describe "Feature.OpenDoor.Copy.copyFromContainer"
        [ test "copies topic from container into parent map but keeps it in the container" <|
            \_ ->
                let
                    ( m0, containerId, topicId ) =
                        setupModel

                    targetId =
                        0

                    preSizeSrc =
                        sizeOf containerId m0

                    preSizeTgt =
                        sizeOf targetId m0

                    -- perform the copy
                    m1 =
                        Copy.copyFromContainer
                            { containerId = containerId
                            , topicId = topicId
                            , targetMapId = targetId
                            }
                            m0

                    postSizeSrc =
                        sizeOf containerId m1

                    postSizeTgt =
                        sizeOf targetId m1
                in
                Expect.all
                    [ \_ -> Expect.equal (isItemInMap topicId containerId m1) True
                    , \_ -> Expect.equal (isItemInMap topicId targetId m1) True
                    , \_ -> Expect.equal postSizeSrc preSizeSrc
                    , \_ ->
                        let
                            expected =
                                if isItemInMap topicId targetId m0 then
                                    preSizeTgt

                                else
                                    preSizeTgt + 1
                        in
                        Expect.equal postSizeTgt expected
                    ]
                    ()

        -- ★ provide the subject
        ]
````

## File: tests/Feature/OpenDoor/StayVisibleTest.elm
````elm
module Feature.OpenDoor.StayVisibleTest exposing (tests)

import AppModel exposing (Model)
import Compat.ModelAPI as M exposing (createTopic, getMapItemById)
import Compat.TestDefault exposing (defaultModel)
import Dict
import Expect
import Feature.OpenDoor.Move as OpenDoor
import Model exposing (..)
import Test exposing (..)


setup : ( Model, MapId, Id )
setup =
    let
        ( _, cId ) =
            createTopic "Container" Nothing defaultModel

        -- change the initial map placement:
        m2 =
            M.addItemToMapDefault cId 0 defaultModel

        m3 =
            { m2 | maps = Dict.insert cId (Map cId (Rectangle 0 0 0 0) Dict.empty) m2.maps }

        ( m4, tId ) =
            createTopic "A" Nothing m3

        m5 =
            M.addItemToMapDefault tId
                cId
                m4
    in
    ( m5, cId, tId )


tests : Test
tests =
    test "After OpenDoor.move: container still visible on parent, topic visible on parent" <|
        \_ ->
            let
                ( m0, containerId, topicId ) =
                    setup

                m1 =
                    OpenDoor.move { containerId = containerId, topicId = topicId, targetMapId = 0 } m0

                containerStillThere =
                    M.isItemInMap containerId 0 m1
                        && (getMapItemById containerId 0 m1.maps
                                |> Maybe.map .hidden
                                |> Maybe.withDefault True
                           )
                        == False

                topicVisibleOnParent =
                    M.isItemInMap topicId 0 m1
                        && (getMapItemById topicId 0 m1.maps
                                |> Maybe.map .hidden
                                |> Maybe.withDefault True
                           )
                        == False
            in
            Expect.equal ( containerStillThere, topicVisibleOnParent ) ( True, True )
````

## File: tests/Generated/Fixtures.elm
````elm
module Generated.Fixtures exposing (dmxCoreTopic830082)

{-| Paste the JSON from
<https://dmx.ralfbarkow.ch/core/topic/830082?children=true&assocChildren=true>
between the triple quotes.
-}


dmxCoreTopic830082 : String
dmxCoreTopic830082 =
    """
{ "id": 830082, "typeUri": "dmx.core.topic", "value": "…", "children": [], "assocChildren": [] }
    """
````

## File: tests/Import/DmxCoreTopicTest.elm
````elm
module Import.DmxCoreTopicTest exposing (tests)

import Compat.CoreModel as Core
import Compat.DmxImport as Import
import Dict
import Expect
import Generated.Fixtures as Fx
import Json.Decode as D
import Model exposing (..)
import Test exposing (..)


tests : Test
tests =
    describe "DMX core topic importer"
        [ test "830082 imports into a coherent CoreModel" <|
            \_ ->
                case
                    D.decodeString D.value Fx.dmxCoreTopic830082
                        |> Result.andThen Import.decodeCoreTopicToCore
                of
                    Ok core ->
                        Expect.all
                            [ \_ -> Expect.equal True (hasNoIllegalMapIds core)
                            , \_ -> Expect.equal True (mapItemsBelongToItems core)
                            ]
                            ()

                    Err e ->
                        Expect.fail (D.errorToString e)
        ]


hasNoIllegalMapIds : Core.CoreModel -> Bool
hasNoIllegalMapIds c =
    List.all (\mid -> Dict.member mid c.maps) c.mapPath


mapItemsBelongToItems : Core.CoreModel -> Bool
mapItemsBelongToItems c =
    c.maps
        |> Dict.values
        |> List.concatMap (\mp -> Dict.values mp.items)
        |> List.all (\mi -> Dict.member mi.id c.items)
````

## File: tests/Model/AddItemToMapCycleTest.elm
````elm
module Model.AddItemToMapCycleTest exposing (tests)

import AppModel exposing (Model, default)
import Compat.ModelAPI as ModelAPI exposing (addItemToMap, defaultProps)
import Dict
import Expect
import Model exposing (MapProps(..), Size)
import Test exposing (..)


{-| Build a model that has an empty child map with id=1 (no parent field needed).
-}
seedModelWithMaps : Model
seedModelWithMaps =
    let
        base =
            default

        root0 =
            case Dict.get 0 base.maps of
                Just m ->
                    m

                Nothing ->
                    Debug.todo "root map id=0 missing"

        -- child map id=1 (empty)
        map1 =
            { root0 | id = 1, items = Dict.empty }
    in
    { base | maps = base.maps |> Dict.insert 1 map1 }


tests : Test
tests =
    describe "addItemToMap cycle-guard"
        [ test "refuses direct self-containment (A→A)" <|
            \_ ->
                let
                    model0 =
                        seedModelWithMaps

                    tp =
                        defaultProps 1 (Size 0 0) model0

                    props : MapProps
                    props =
                        MapTopic tp

                    -- try to place map 1 into map 1
                    model1 =
                        ModelAPI.addItemToMap 1 props 1 model0
                in
                -- must be rejected -> model unchanged
                Expect.equal model1 model0
        , test "refuses ancestral cycle (A→descendant(A))" <|
            \_ ->
                let
                    base =
                        default

                    root0 =
                        case Dict.get 0 base.maps of
                            Just m ->
                                m

                            Nothing ->
                                Debug.todo "root map id=0 missing"

                    -- two empty maps
                    map1 =
                        { root0 | id = 1, items = Dict.empty }

                    map2 =
                        { root0 | id = 2, items = Dict.empty }

                    model0 =
                        { base
                            | maps =
                                base.maps
                                    |> Dict.insert 1 map1
                                    |> Dict.insert 2 map2
                        }

                    -- establish 1 → 2 (put 2 inside 1)
                    tp2 =
                        defaultProps 2 (Size 0 0) model0

                    props2 : MapProps
                    props2 =
                        MapTopic tp2

                    model1 =
                        addItemToMap 2 props2 1 model0

                    -- now try to create a cycle by putting 1 inside 2 (must be rejected)
                    tp1 =
                        defaultProps 1 (Size 0 0) model1

                    props1 : MapProps
                    props1 =
                        MapTopic tp1

                    model2 =
                        addItemToMap 1 props1 2 model1

                    itemsIn2After =
                        case Dict.get 2 model2.maps of
                            Just m ->
                                m.items

                            Nothing ->
                                Dict.empty
                in
                -- item 1 must NOT appear in map 2
                Expect.equal (Dict.member 1 itemsIn2After) False
        ]
````

## File: tests/Model/DefaultModelTest.elm
````elm
module Model.DefaultModelTest exposing (tests)

import Compat.TestDefault exposing (defaultModel)
import Dict
import Expect
import Model
import Test exposing (..)


tests : Test
tests =
    describe "defaultModel"
        [ test "has root mapPath [0]" <|
            \_ -> Expect.equal defaultModel.mapPath [ 0 ]
        , test "has root map (id 0)" <|
            \_ ->
                case Dict.get 0 defaultModel.maps of
                    Just root ->
                        -- parentMapId was removed; assert root id instead
                        Expect.equal root.id 0

                    Nothing ->
                        Expect.fail "Root map 0 not found"
        , test "starts empty selection and items" <|
            \_ ->
                Expect.all
                    [ \_ -> Expect.equal defaultModel.selection []
                    , \_ -> Expect.equal (Dict.size defaultModel.items) 0
                    ]
                    ()
        , test "search text and measure text are empty" <|
            \_ ->
                Expect.all
                    [ \_ -> Expect.equal defaultModel.search.text ""
                    , \_ -> Expect.equal defaultModel.measureText ""
                    ]
                    ()
        , test "nextId starts at 1" <|
            \_ -> Expect.equal defaultModel.nextId 1
        ]
````

## File: tests/Model/SelfContainmentInvariantTest.elm
````elm
module Model.SelfContainmentInvariantTest exposing (tests)

import Dict
import Expect
import Model
    exposing
        ( DisplayMode(..)
        , Map
        , MapItem
        , MapProps(..)
        , Point
        , Rectangle
        , Size
        , TopicProps
        )
import Model.Invariant as Invariant
import Test exposing (..)


tests : Test
tests =
    describe "Global invariant: no map contains itself"
        [ test "deliberate self-containment is detected" <|
            \_ ->
                let
                    emptyRect : Rectangle
                    emptyRect =
                        Rectangle 0 0 100 80

                    bogusAssocId : Int
                    bogusAssocId =
                        0

                    map1 : Map
                    map1 =
                        { id = 1
                        , rect = emptyRect
                        , items =
                            Dict.fromList
                                [ ( 1
                                  , MapItem
                                        1
                                        bogusAssocId
                                        False
                                        False
                                        (MapTopic (TopicProps (Point 0 0) (Size 60 40) (Container Model.WhiteBox)))
                                  )
                                ]
                        }

                    maps =
                        Dict.fromList [ ( 1, map1 ) ]
                in
                Expect.equal [ 1 ] (Invariant.offendingSelfContainers maps)
        ]
````

## File: tests/Search/UpdateTest.elm
````elm
module Search.UpdateTest exposing (tests)

import Compat.TestDefault exposing (defaultModel)
import Compat.TestUtil exposing (asUndo, present)
import Expect
import Search exposing (..)
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
````

## File: tests/Storage/InitDecodeTest.elm
````elm
module Storage.InitDecodeTest exposing (tests)

import Expect
import Json.Decode as Decode
import Storage exposing (modelDecoder)
import Test exposing (..)


tests : Test
tests =
    describe "Storage.modelDecoder init paths"
        [ test "new list blob -> decode" <|
            \_ ->
                let
                    json =
                        -- New canonical schema:
                        -- - maps: List
                        -- - topicProps.display (not displayMode)
                        -- - requires nextId and mapPath
                        """
                        {
                          "items": [
                            { "topic": { "id": 1, "text": "Hello", "icon": "" } },
                            { "assoc": { "id": 2, "type": "dmx.composition",
                                         "role1": "dmx.child", "player1": 1,
                                         "role2": "dmx.parent", "player2": 0 } }
                          ],
                          "maps": [
                            {
                              "id": 0,
                              "rect": { "x1": 0, "y1": 0, "x2": 0, "y2": 0 },
                              "items": [
                                {
                                  "id": 1,
                                  "parentAssocId": 2,
                                  "hidden": false,
                                  "pinned": false,
                                  "topicProps": {
                                    "pos":   { "x": 0, "y": 0 },
                                    "size":  { "w": 100, "h": 30 },
                                    "display": "LabelOnly"
                                  }
                                }
                              ]
                            }
                          ],
                          "mapPath": [0],
                          "nextId": 3
                        }
                        """
                in
                case Decode.decodeString modelDecoder json of
                    Ok _ ->
                        Expect.pass

                    Err e ->
                        Expect.fail <| "expected Ok, got Err: " ++ Decode.errorToString e
        , test "legacy dict blob -> decode" <|
            \_ ->
                let
                    legacyDict =
                        """
                {
                  "items": {
                    "1": { "topic": { "id": 1, "text": "Hello", "iconName": "" } },
                    "2": { "assoc": { "id": 2, "itemType": "dmx.composition",
                                      "player1": 1, "role1": "dmx.child",
                                      "player2": 0, "role2": "dmx.parent" } }
                  },
                  "maps": {
                    "0": {
                      "id": 0,
                      "items": {
                        "1": {
                          "id": 1,
                          "hidden": false,
                          "pinned": false,
                          "topicProps": {
                            "pos": { "x": 0, "y": 0 },
                            "size": { "w": 100, "h": 30 },
                            "displayMode": "LabelOnly"
                          },
                          "parentAssocId": 2
                        }
                      },
                      "rect": { "x1": 0, "y1": 0, "x2": 0, "y2": 0 }
                    }
                  },
                  "mapPath": [0],
                  "nextId": 3
                }
                """
                in
                case Decode.decodeString modelDecoder legacyDict of
                    Ok _ ->
                        Expect.pass

                    Err e ->
                        Expect.fail <| "expected legacy dict blob to decode, got Err: " ++ Decode.errorToString e
        , test "{} -> home map" <|
            \_ ->
                case Decode.decodeString modelDecoder "{}" of
                    Ok _ ->
                        Expect.pass

                    Err e ->
                        Expect.fail <| "Expected {} to decode to default model. Got: " ++ Decode.errorToString e
        ]
````

## File: tests/Tests/Master.elm
````elm
module Tests.Master exposing (tests)

import Domain.ReparentRulesTest
import Model.DefaultModelTest
import Search.UpdateTest
import Test exposing (..)
import View.ToolbarButtonsTest


tests : Test
tests =
    describe "Master (compat + invariants)"
        [ Domain.ReparentRulesTest.tests
        , Model.DefaultModelTest.tests
        , Search.UpdateTest.tests
        , View.ToolbarButtonsTest.tests
        ]
````

## File: tests/View/ToolbarButtonsTest.elm
````elm
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
````

## File: README.md
````markdown
# DM6 Elm

## Version History

**0.2** -- *unreleased*

* Features:
    * Search
        * Preview result items on hover
        * Internal *pinned* state for topics/assocs
    * Hide topics/assocs
    * Import/Export JSON
* Fixes:
    * Drag topic in double revealed nested map
    * Draw assoc in double revealed nested map
    * Drop container on container
    * On drop set container display in *all* maps
    * Auto-size container on delete-topic
    * Toolbar radio buttons don't fire twice
* Code/Build:
    * Modularization: "components" with state and messages
    * `build-dev`/`build-prod` scripts (swaps logger)

**0.1** -- Aug 6, 2025

* Features:
    * Map display (DOM/SVG)
        * Create topics, draw assocs
        * Edit topics, plain text
        * Icon menu (for topic decoration)
        * Delete topics
    * Nested maps
        * Add topics to container
        * 2 Monad Display modes: *Label Only*, *Detail*
        * 3 Container Display modes: *Black Box*, *White Box*, *Unboxed*
        * Map auto-sizing
    * Fullscreen
        * For both, monads and containers
        * Back-navigation (multi-step)

Project begin -- Jun 11, 2025

---
Jörg Richter  
Sep 7, 2025
````

## File: docs/embedded-build.md
````markdown
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
````

## File: docs/journal.md
````markdown
Love this direction. Here’s a compact, “add-and-see-it” plan to get a **meta view of moves inside DM6**, with a tiny in-app **Journal** (list + mini path sketch), plus hooks to **record explicit `topicId` / `mapPath` from the event**, and a foundation for **replay/undo**.

---

# 1) Data: add a lightweight Journal

### `src/Journal.elm`

```elm
module Journal exposing (Entry(..), Path, record, viewList, viewSketch)

import Html exposing (..)
import Html.Attributes exposing (..)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Model exposing (Id, MapId, Point)
import ModelAPI exposing (MapPath)

type alias Path =
    { selection : Maybe ( Id, MapPath )  -- what UI focused on (anchor)
    , computed  : List MapPath           -- what findPaths returned
    }

type Entry
    = CrossIn
        { topicId : Id, from : MapId, to : MapId, pos : Point, path : Path, note : String }
    | CrossOut
        { topicId : Id, from : MapId, to : MapId, pos : Point, path : Path, note : String }
    | CrossNoop { reason : String, topicId : Id, parent : MapId }
    | ErrorText String

record : Entry -> List Entry -> List Entry
record e acc =
    e :: acc |> List.take 200  -- keep it bounded

viewList : List Entry -> Html msg
viewList entries =
    div [ style "font-family" "monospace", style "font-size" "12px"
        , style "max-height" "220px", style "overflow" "auto"
        , style "border" "1px solid #ddd", style "padding" "6px" ]
        (entries |> List.map viewLine)

viewLine : Entry -> Html msg
viewLine e =
    case e of
        CrossIn r ->
            div [] [ text <| "IN: topic " ++ String.fromInt r.topicId
                         ++ " " ++ fromTo r.from r.to
                         ++ " pos=" ++ showPt r.pos
                         ++ note r.note ]

        CrossOut r ->
            div [] [ text <| "OUT: topic " ++ String.fromInt r.topicId
                         ++ " " ++ fromTo r.from r.to
                         ++ " pos=" ++ showPt r.pos
                         ++ note r.note ]

        CrossNoop r ->
            div [] [ text <| "NO-OP: topic " ++ String.fromInt r.topicId
                         ++ " parent=" ++ String.fromInt r.parent
                         ++ " reason=" ++ r.reason ]

        ErrorText s ->
            div [ style "color" "#a00" ] [ text ("ERR: " ++ s) ]

fromTo : MapId -> MapId -> String
fromTo a b = "(from " ++ String.fromInt a ++ " → " ++ String.fromInt b ++ ")"

showPt : Point -> String
showPt p = "(" ++ String.fromFloat p.x ++ "," ++ String.fromFloat p.y ++ ")"

note : String -> String
note s = if s == "" then "" else "  · " ++ s

-- very small, schematic path sketch: each MapPath becomes a dot row
viewSketch : List Entry -> Html msg
viewSketch entries =
    let
        dots =
            entries
                |> List.take 1 -- sketch most recent only (cheap & legible)
                |> List.concatMap
                    (\e ->
                        case e of
                            CrossIn r  -> r.path.computed
                            CrossOut r -> r.path.computed
                            _          -> []
                    )
    in
    svg [ width "160", height "60", viewBox "0 0 160 60", style "border" "1px solid #eee" ]
        (dots
            |> List.indexedMap
                (\row path ->
                    let
                        y = 20 + toFloat row * 16
                        xs = List.indexedMap (\i _ -> 10 + toFloat i * 18) path
                    in
                    List.concat
                        [ [ Svg.text_ [ x "4", y (String.fromFloat (y - 7)), fontSize "8" ] [ Svg.text "path" ] ]
                        , xs
                            |> List.map
                                (\xv -> circle [ cx (String.fromFloat xv), cy (String.fromFloat y), r "3", fill "#333" ] [])
                        ]
                )
            |> List.concat
        )
```

### Extend `AppModel.Model`

Add a journal buffer and a dev overlay toggle:

```elm
-- in AppModel.elm (or Model.elm if that’s your core)
type alias Model =
    { ... -- existing fields
    , journal : List Journal.Entry
    , showJournal : Bool
    }
```

Initialize to:

```elm
initModel =
    { ... -- existing
    , journal = []
    , showJournal = True  -- default on; you can wire it to a toolbar toggle later
    }
```

---

# 2) Recording from Channel/Update (no selection needed)

**Key idea**: Cross doesn’t rely on `selection`. We *explicitly* record the `topicId`, computed `fromMap`/`toMap`, drop `pos`, and the **path context**:

* `selection` part of `Path` = the anchor you just “decided” (e.g., moved topic for OUT, target container for IN).
* `computed` part = the list from `findPaths model'` immediately **after** you do the move and **after** a quick `select anchor`.

### In `Main.update` (or wherever you dispatch `Channel.cross`)

Right after a successful cross:

```elm
import Journal
import MapAutoSize exposing (findPaths) -- you have this already
import ModelAPI exposing (select)       -- explicit select to set an anchor

-- ... inside the Ok branch where you currently return (model1, cmd)
let
    -- choose anchor explicitly:
    -- IN: anchor on target container; OUT: anchor on moved topic
    anchor : ( Id, MapPath )
    anchor =
        case ( req.from, req.to ) of
            ( Channel.Root, Channel.Container containerId ) ->
                ( containerId, [ containerId ] )

            ( Channel.Container _, Channel.Root ) ->
                ( req.topicId, [ activeMap model1 ] ) -- or build better path if you have it

            _ ->
                ( req.topicId, [ activeMap model1 ] )

    model2 =
        model1
            |> select (Tuple.first anchor) (Tuple.second anchor)

    paths =
        findPaths model2

    entry =
        case ( req.from, req.to ) of
            ( Channel.Root, Channel.Container containerId ) ->
                Journal.CrossIn
                    { topicId = req.topicId
                    , from = 0
                    , to = containerId
                    , pos = req.pos
                    , path = { selection = Just anchor, computed = paths }
                    , note = "explicit select before autoSize"
                    }

            ( Channel.Container c, Channel.Root ) ->
                Journal.CrossOut
                    { topicId = req.topicId
                    , from = c
                    , to = 0
                    , pos = req.pos
                    , path = { selection = Just anchor, computed = paths }
                    , note = "explicit select before autoSize"
                    }

            _ ->
                Journal.ErrorText "unexpected cross request"

    model3 =
        { model2 | journal = Journal.record entry model2.journal }
in
( MapAutoSize.autoSize model3, cmd )
```

### On failures / no-op

When Channel decides **no-op** (guards or missing preconditions), append:

```elm
{ model
    | journal =
        Journal.record
            (Journal.CrossNoop { topicId = req.topicId, parent = ???, reason = "…" })
            model.journal
}
```

…and return the unchanged model as you already do.

---

# 3) Show it in the app (inline dev overlay)

Add a tiny **overlay** that you can leave on during tests and builds:

```elm
-- in Main.view (root)
div []
    [ ... existing UI ...
    , if model.showJournal then
        div [ style "position" "fixed", style "right" "10px", style "bottom" "10px"
            , style "background" "white", style "box-shadow" "0 2px 10px rgba(0,0,0,0.15)"
            , style "padding" "8px", style "border-radius" "8px", style "z-index" "9999"
            , style "width" "380px" ]
            [ h4 [ style "margin" "0 0 6px 0", style "font-family" "sans-serif" ] [ text "Cross Journal" ]
            , Journal.viewSketch model.journal
            , Journal.viewList model.journal
            ]
      else
        text ""
    ]
```

(You can add a `Msg.ToggleJournal` to turn it on/off; tests won’t care since it’s just rendering.)

---

# 4) Why this works with “no selection”

* **Cross** doesn’t *read* `model.selection` at all.
* We **explicitly `select` an anchor** (moved topic for OUT, target container for IN) **before** `autoSize`.
* `findPaths` uses that selection to compute the resizing path; if tests ask the toolbar again, the anchor selection also makes the button state consistent.
* The **Journal entry stores both**: the selection anchor (what we chose) and the computed paths (what the sizing code uses). That’s the “location in the network of message paths” captured and visible.

---

# 5) Seeds for Replay / Undo

You now have stable entries with:

* `topicId`, `from`, `to`, `pos`
* `path.selection` (anchor) + `path.computed` (for sizing)

Add two simple `Msg`s and handlers later:

```elm
type Msg
    = ReplayLast
    | UndoLast
    | ...

-- ReplayLast: re-run Channel.cross with the stored fields (deterministic)
-- UndoLast: implement inverse move (swap from/to); or keep a pre-move snapshot in Entry if you prefer snapshot-based undo.
```

Because you **don’t depend on ambient selection**, replay is robust: each entry contains everything needed to act and re-size predictably.

---

## TL;DR

* Add `Journal` module (entries + simple views).
* On **every Cross** success/failure: **append an Entry**, and **explicitly select** an anchor before `autoSize`.
* Render a tiny **in-app overlay** (list + tiny SVG path sketch).
* You’ve now got an immediate, visual “meta view” of moves, and a clean foundation for **FedWiki-style journal / replay / undo**.
````

## File: public/app.html
````html
<!doctype html>
<html>
  <head>
    <meta charset="utf-8">
    <title>WikiLink Demo</title>
    <style>
      body { font: 14px/1.4 system-ui, sans-serif; margin: 0; padding: 1rem; }
    </style>
  </head>
  <body>
    <script src="app.js"></script>
    <script>
      var app = Elm.Feature.WikiLink.Demo.init({
        node: document.body
      });
    </script>
  </body>
</html>
````

## File: scripts/contract-smoke.sh
````bash
# Build the façade modules directly
npx elm make src/Compat/ModelAPI.elm --output=/dev/null
npx elm make src/Compat/FedWikiImport.elm --output=/dev/null

# Smoke-test a tiny “contract” module that references the public API you promise:
cat > src/Compat/ContractSmoke.elm <<'EOF'
module Compat.ContractSmoke exposing (ok)
import Compat.ModelAPI as CMA
import Compat.FedWikiImport as CFWI
import Json.Decode as D
ok : Bool
ok =
    let _ = (CFWI.importPage) in True
EOF
npx elm make src/Compat/ContractSmoke.elm --output=/dev/null
````

## File: src/Algebra/Containment/Graph.elm
````elm
module Algebra.Containment.Graph exposing
    ( isDescendantUsing
    , wouldCreateCycleUsing
    )

import Set exposing (Set)


isDescendantUsing :
    (comparable -> model -> List comparable)
    -> comparable
    -> comparable
    -> model
    -> Bool
isDescendantUsing children root target model =
    let
        go : List comparable -> Set comparable -> Bool
        go queue seen =
            case queue of
                [] ->
                    False

                x :: xs ->
                    if x == target then
                        True

                    else if Set.member x seen then
                        go xs seen

                    else
                        go (children x model ++ xs) (Set.insert x seen)
    in
    go (children root model) Set.empty


wouldCreateCycleUsing :
    (comparable -> model -> List comparable)
    -> { dragged : comparable, target : comparable }
    -> model
    -> Bool
wouldCreateCycleUsing children { dragged, target } model =
    dragged == target || isDescendantUsing children dragged target model
````

## File: src/Algebra/Containment.elm
````elm
module Algebra.Containment exposing
    ( Depth(..)
    , andThen
      -- alias for within (use instead of (</>))
    , fromDepth
    , times
      -- repeated containment (multiplication-like)
    , toDepth
    , within
      -- combine containments (addition-like)
    )

import Model exposing (MapId, MapPath)



-- Depth = how many containers deep you are


type Depth
    = Depth Int



-- combine two containments: Depth a ⊕ Depth b = Depth (a + b)


within : Depth -> Depth -> Depth
within (Depth a) (Depth b) =
    Depth (a + b)



-- alias for within; use this instead of a custom operator


andThen : Depth -> Depth -> Depth
andThen =
    within



-- repeated containment: Depth a ⊗ Depth b = Depth (a * b)


times : Depth -> Depth -> Depth
times (Depth a) (Depth b) =
    Depth (a * b)



-- convert a MapPath to a Depth by counting segments


toDepth : MapPath -> Depth
toDepth path =
    Depth (List.length path)



-- build a synthetic path of given depth under a base MapId
-- (Adjust to your real path-construction as needed.)


fromDepth : Depth -> MapId -> MapPath
fromDepth (Depth n) base =
    List.repeat n base
````

## File: src/Compat/WikiLink/Parser.elm
````elm
module Compat.WikiLink.Parser exposing (Segment(..), parseLine, slug)

import Parser
    exposing
        ( (|.)
        , (|=)
        , Parser
        , Step(..)
        , chompUntil
        , chompWhile
        , end
        , getChompedString
        , loop
        , oneOf
        , run
        , succeed
        , symbol
        )


type Segment
    = Plain String
    | Wiki String
    | ExtLink String String


parseLine : String -> Result (List Parser.DeadEnd) (List Segment)
parseLine input =
    run segments input


segments : Parser (List Segment)
segments =
    loop [] <|
        \rev ->
            oneOf
                [ end
                    |> Parser.map (\_ -> Done (List.reverse rev))
                , segmentParser
                    |> Parser.map (\seg -> Loop (seg :: rev))
                ]


segmentParser : Parser Segment
segmentParser =
    oneOf
        [ wikiLink
        , extLink
        , plainText
        ]


wikiLink : Parser Segment
wikiLink =
    succeed Wiki
        |. symbol "[["
        |= getChompedString (chompUntil "]]")
        |. symbol "]]"


extLink : Parser Segment
extLink =
    succeed ExtLink
        |. symbol "["
        |= getChompedString (chompWhile (\c -> c /= ' ' && c /= ']'))
        -- URL
        |= oneOf
            [ succeed identity
                |. chompWhile (\c -> c == ' ')
                |= getChompedString (chompUntil "]")

            -- label
            , succeed "" -- no label
            ]
        |. symbol "]"


plainText : Parser Segment
plainText =
    getChompedString (chompWhile (\c -> c /= '['))
        |> Parser.map Plain


slug : String -> String
slug =
    String.toLower
        >> String.trim
        >> String.split " "
        >> String.join "-"
````

## File: src/Compat/WikiLink/Regex.elm
````elm
module Compat.WikiLink.Regex exposing (parse, slug)

import Regex


parse : String -> List String
parse s =
    let
        re =
            Regex.fromString "\\[\\[([^\\]]+)\\]\\]"
                |> Maybe.withDefault Regex.never
    in
    Regex.find re s
        |> List.filterMap
            (\m ->
                case m.submatches of
                    first :: _ ->
                        first

                    [] ->
                        Nothing
            )
        |> List.filter (\t -> t /= "")


slug : String -> String
slug title =
    title
        |> String.toLower
        |> String.trim
        |> Regex.replace (Maybe.withDefault Regex.never (Regex.fromString "\\s+")) (\_ -> "-")
        |> Regex.replace (Maybe.withDefault Regex.never (Regex.fromString "[^a-z0-9-]")) (\_ -> "")
        |> Regex.replace (Maybe.withDefault Regex.never (Regex.fromString "-+")) (\_ -> "-")
````

## File: src/Compat/Display.elm
````elm
module Compat.Display exposing
    ( DisplayConfig
    , Shape(..)
    , boxMonad
    , circleMonad
    , default
    )

{-| Small, app-wide display knobs.
Keep this as a compat shim so upstream refactors don’t leak.
-}


type Shape
    = Box
    | Circle
    | Rounded Int


type alias DisplayConfig =
    { monad : Shape
    , container : Shape
    , stroke : Float
    , padding : Float
    }


default : DisplayConfig
default =
    { monad = Circle
    , container = Rounded 10
    , stroke = 1.5
    , padding = 8
    }


{-| Prebaked variants you might enable from flags later.
-}
circleMonad : DisplayConfig -> DisplayConfig
circleMonad cfg =
    { cfg | monad = Circle }


boxMonad : DisplayConfig -> DisplayConfig
boxMonad cfg =
    { cfg | monad = Box }
````

## File: src/Domain/Id.elm
````elm
module Domain.Id exposing (isAssocId, isTopicId, labelId, labelMap)

import Types exposing (Id, MapId)



-- Add near your other exposes in Types.elm
-- (and export them if you want to use outside)


isTopicId : Id -> Bool
isTopicId id =
    modBy 2 id == 1


isAssocId : Id -> Bool
isAssocId id =
    modBy 2 id == 0


labelId : Id -> String
labelId id =
    (if isTopicId id then
        "T"

     else
        "A"
    )
        ++ String.fromInt id


labelMap : MapId -> String
labelMap mid =
    "M" ++ String.fromInt mid
````

## File: src/Domain/TopicId.elm
````elm
module Domain.TopicId exposing (TopicId, fromInt, toInt)


type TopicId
    = TopicId Int


fromInt : Int -> Maybe TopicId
fromInt i =
    if modBy 2 i == 1 then
        Just (TopicId i)

    else
        Nothing


toInt : TopicId -> Int
toInt (TopicId i) =
    i
````

## File: src/Feature/Connection/Channel.elm
````elm
module Feature.Connection.Channel exposing
    ( Boundary(..)
    , CrossError(..)
    , CrossPlan
    , CrossRequest
    , Effect(..)
    , cross
    , crossIn
    , crossOut
    , defaultPermit
    )

{-| Minimal compile-baseline of Connection Channel.

NOTE: Guards and actual move semantics are intentionally NO-OP to avoid
dependency mismatches. This gets the project compiling again. Reintroduce
real checks and ModelAPI mutations incrementally once stable.

-}

import AppModel as AM exposing (Model)
import Model as M exposing (Id, MapId, Point)



-- BOUNDARIES


type Boundary
    = Root
    | Container Id



-- ERRORS


type CrossError
    = Other String



-- PERMIT (placeholder)


type alias CrossPermit =
    {}



-- placeholder; keep shape for Main compatibility


defaultPermit : CrossPermit
defaultPermit =
    {}



-- REQUEST / PLAN


type alias CrossRequest =
    { topicId : Id
    , from : Boundary
    , to : Boundary
    , pos : Point
    , permit : CrossPermit
    }


type alias CrossPlan =
    { topicId : Id
    , fromMap : MapId
    , toMap : MapId
    , pos : Point
    }



-- EFFECTS (for future ports)


type Effect
    = None
    | Out_Crossed { topicId : Int, fromMap : Int, toMap : Int }



-- PUBLIC API


crossIn : Id -> Id -> Point -> AM.Model -> Result CrossError ( AM.Model, CrossPlan, Effect )
crossIn topicId containerId pos model =
    cross
        { topicId = topicId
        , from = Root
        , to = Container containerId
        , pos = pos
        , permit = defaultPermit
        }
        model


crossOut : Id -> Id -> Point -> AM.Model -> Result CrossError ( AM.Model, CrossPlan, Effect )
crossOut topicId containerId pos model =
    cross
        { topicId = topicId
        , from = Container containerId
        , to = Root
        , pos = pos
        , permit = defaultPermit
        }
        model


cross : CrossRequest -> AM.Model -> Result CrossError ( AM.Model, CrossPlan, Effect )
cross req model0 =
    case plan req of
        Ok plan_ ->
            let
                -- APPLY IS A NO-OP FOR NOW: return model unchanged, but emit effect
                eff =
                    Out_Crossed
                        { topicId = plan_.topicId
                        , fromMap = plan_.fromMap
                        , toMap = plan_.toMap
                        }
            in
            Ok ( model0, plan_, eff )

        Err e ->
            Err e



-- PLANNING


plan : CrossRequest -> Result CrossError CrossPlan
plan req =
    case ( boundaryToMap req.from, boundaryToMap req.to ) of
        ( Just fromMapId, Just toMapId ) ->
            Ok
                { topicId = req.topicId
                , fromMap = fromMapId
                , toMap = toMapId
                , pos = req.pos
                }

        ( Nothing, _ ) ->
            Err (Other "Unknown source boundary")

        ( _, Nothing ) ->
            Err (Other "Unknown target boundary")



-- HELPERS


boundaryToMap : Boundary -> Maybe MapId
boundaryToMap b =
    case b of
        Root ->
            Just 0

        Container tid ->
            Just tid
````

## File: src/Feature/Connection/Journal.elm
````elm
module Feature.Connection.Journal exposing (Entry(..), Path, record, viewList, viewSketch)

import Html exposing (..)
import Html.Attributes exposing (..)
import Model exposing (Id, MapId, Point)
import ModelAPI exposing (MapPath)
import Svg exposing (..)
import Svg.Attributes exposing (..)


type alias Path =
    { selection : Maybe ( Id, MapPath ) -- what UI focused on (anchor)
    , computed : List MapPath -- what findPaths returned
    }


type Entry
    = CrossIn { topicId : Id, from : MapId, to : MapId, pos : Point, path : Path, note : String }
    | CrossOut { topicId : Id, from : MapId, to : MapId, pos : Point, path : Path, note : String }
    | CrossNoop { reason : String, topicId : Id, parent : MapId }
    | ErrorText String


record : Entry -> List Entry -> List Entry
record e acc =
    e :: acc |> List.take 200



-- keep it bounded


viewList : List Entry -> Html msg
viewList entries =
    div
        [ style "font-family" "monospace"
        , style "font-size" "12px"
        , style "max-height" "220px"
        , style "overflow" "auto"
        , style "border" "1px solid #ddd"
        , style "padding" "6px"
        ]
        (entries |> List.map viewLine)


viewLine : Entry -> Html msg
viewLine e =
    case e of
        CrossIn r ->
            div []
                [ text <|
                    "IN: topic "
                        ++ String.fromInt r.topicId
                        ++ " "
                        ++ fromTo r.from r.to
                        ++ " pos="
                        ++ showPt r.pos
                        ++ note r.note
                ]

        CrossOut r ->
            div []
                [ text <|
                    "OUT: topic "
                        ++ String.fromInt r.topicId
                        ++ " "
                        ++ fromTo r.from r.to
                        ++ " pos="
                        ++ showPt r.pos
                        ++ note r.note
                ]

        CrossNoop r ->
            div []
                [ text <|
                    "NO-OP: topic "
                        ++ String.fromInt r.topicId
                        ++ " parent="
                        ++ String.fromInt r.parent
                        ++ " reason="
                        ++ r.reason
                ]

        ErrorText s ->
            div [ style "color" "#a00" ] [ text ("ERR: " ++ s) ]


fromTo : MapId -> MapId -> String
fromTo a b =
    "(from " ++ String.fromInt a ++ " → " ++ String.fromInt b ++ ")"


showPt : Point -> String
showPt p =
    "(" ++ String.fromFloat p.x ++ "," ++ String.fromFloat p.y ++ ")"


note : String -> String
note s =
    if s == "" then
        ""

    else
        "  · " ++ s



-- very small, schematic path sketch: each MapPath becomes a dot row


viewSketch : List Entry -> Html msg
viewSketch entries =
    let
        dots =
            entries
                |> List.take 1
                -- sketch most recent only (cheap & legible)
                |> List.concatMap
                    (\e ->
                        case e of
                            CrossIn r ->
                                r.path.computed

                            CrossOut r ->
                                r.path.computed

                            _ ->
                                []
                    )
    in
    svg [ width "160", height "60", viewBox "0 0 160 60", style "border" "1px solid #eee" ]
        (dots
            |> List.indexedMap
                (\row path ->
                    let
                        y =
                            20 + toFloat row * 16

                        xs =
                            List.indexedMap (\i _ -> 10 + toFloat i * 18) path
                    in
                    List.concat
                        [ [ Svg.text_ [ x "4", y (String.fromFloat (y - 7)), fontSize "8" ] [ Svg.text "path" ] ]
                        , xs
                            |> List.map
                                (\xv -> circle [ cx (String.fromFloat xv), cy (String.fromFloat y), r "3", fill "#333" ] [])
                        ]
                )
            |> List.concat
        )
````

## File: src/Feature/Connection/README.md
````markdown
[…] connect the failed “cross” behavior to a missing selection. Here’s what upstream’s change does and why it matters for Cross:

### What upstream changed

* They added `resetSelection : Model -> Model` in `ModelAPI`, and started using it in **`hide`** and **`delete`**:

  ```elm
  newModel
      |> autoSize
      |> resetSelection
  ```

  So after hiding or deleting, the model’s `selection` is explicitly cleared.

### Why that breaks Cross (and a couple tests)

* **Feature.Cross** (and the toolbar “Cross” button) depend on there being **exactly one selection**.

  * If there’s **no selection**, the button isn’t rendered/enabled and the Cross flow returns something like `Cross: { reason = "no selection" }` (you saw that in the logs).

* Your logs also show `@autoSize: []`. That’s because the **new `MapAutoSize`** uses `getSingleSelection` to find the path to resize. With **no selection**, it finds no paths, and prints `[]`.

Put together:

1. An earlier step in the test or flow (often a hide/delete or a flow that calls those) clears the selection via `resetSelection`.

2. When Cross tries to run, there is **no active selection**, so:

   * The toolbar **doesn’t show** a Cross button → `Feature.OpenDoor.ButtonTest` can’t find `#btn-Cross`.
   * The Cross request bails → `ℹ️ Cross: { reason = "no selection" }`.
   * `autoSize` has nothing to anchor its path-calculation on → `@autoSize: []`.

### What’s **not** caused by `resetSelection`

* The OpenDoor “move into/out of container” failures you saw earlier were primarily due to the `moveTopicToMap` refactor (map id/props lookup changed) — that’s separate. But Cross failing due to “no selection” is directly tied to the new selection clearing.

### How to make Cross work again (minimal options)

Pick any one (or a combo) that fits your intent:

1. **Re-establish selection before Cross**

   * Wherever you trigger Cross (in tests or UI flow), ensure you call `ModelAPI.select` right before, so `getSingleSelection` sees something.

2. **Don’t clear selection for ops that will immediately need it**

   * Move `resetSelection` later (or conditionally) if a subsequent action depends on selection.
   * For example, keep `autoSize` but delay `resetSelection` until after Cross-related actions complete.

3. **Make Cross independent of selection**

   * Change `Feature.Cross` (or your `Channel.cross` entrypoint) to take explicit `topicId`/`mapPath` from the event rather than reading `getSingleSelection`. That way it can operate even if selection is empty.

4. **Re-select after Cross/move**

   * After performing the cross/move, explicitly `select` the relevant item (moved topic or target container) before calling `autoSize`, so follow-up autosizes have a path anchor (and the button reappears if tests inspect the toolbar again).

In short: upstream’s `resetSelection` is the reason your Cross button vanishes and the Cross flow says “no selection.” Either reintroduce (or delay) a selection at the right moment, or make Cross not depend on selection.

  –– ChatGPT 5
````

## File: src/Feature/Facade/Graph.elm
````elm
module Feature.Facade.Graph exposing
    ( Edge
    , Geometry
    , Layout
    , NodeId
    , Point
    , Stage
    , Topology
    , adjacency
    , uniqueEdges
    )

import Dict exposing (Dict)
import Set exposing (Set)



-- BASICS


type alias NodeId =
    Int


type alias Edge =
    { from : NodeId
    , to : NodeId
    }


type alias Topology =
    { nodes : List NodeId
    , edges : List Edge
    }


type alias Point =
    { x : Float
    , y : Float
    }


type alias Geometry =
    { pos : Dict NodeId Point
    , pinned : Set NodeId
    }


type alias Stage =
    { x : Float, y : Float, w : Float, h : Float }


type alias Layout =
    { topology : Topology
    , geometry : Geometry
    }



-- HELPERS


adjacency : Topology -> Dict NodeId (Set NodeId)
adjacency topo =
    let
        -- add one edge (undirected) into the adjacency dict
        add : Edge -> Dict NodeId (Set NodeId) -> Dict NodeId (Set NodeId)
        add e adj =
            adj
                |> Dict.update e.from
                    (\m -> Just (Set.insert e.to (Maybe.withDefault Set.empty m)))
                |> Dict.update e.to
                    (\m -> Just (Set.insert e.from (Maybe.withDefault Set.empty m)))
    in
    List.foldl add Dict.empty topo.edges


uniqueEdges : List Edge -> List Edge
uniqueEdges es =
    es
        |> List.map
            (\e ->
                if e.from <= e.to then
                    ( e.from, e.to )

                else
                    ( e.to, e.from )
            )
        |> Set.fromList
        |> Set.toList
        |> List.map (\( a, b ) -> { from = a, to = b })
````

## File: src/Feature/OpenDoor/Decide.elm
````elm
module Feature.OpenDoor.Decide exposing (decideOpenDoorMsg)

import AppModel exposing (Model, Msg(..))
import Dict
import Logger as L
import Model exposing (..)
import ModelAPI exposing (activeMap, getSingleSelection)


mapIdOf : MapPath -> MapId
mapIdOf path =
    case path of
        id :: _ ->
            id

        [] ->
            0


parentPathOf : MapPath -> Maybe MapPath
parentPathOf path =
    case path of
        _ :: rest ->
            Just rest

        [] ->
            Nothing


{-| Decide what the Cross button should do.

    - Containers (topicId is also a map id): navigate (enter/exit).
    - Monads: move across the nearest boundary (parent ↔ inner).
      If no owning container exists on the parent, fall back to a no-op move,
      so the button still dispatches a predictable message.

    Every branch emits a Log.info for traceability.

-}
decideOpenDoorMsg : Model -> Maybe Msg
decideOpenDoorMsg model =
    case getSingleSelection model of
        Nothing ->
            let
                _ =
                    L.log "Cross" { reason = "no selection" }
            in
            Nothing

        Just ( topicId, selectionPath ) ->
            let
                here : MapId
                here =
                    activeMap model

                origin : Point
                origin =
                    Point 0 0

                selectionMapId : MapId
                selectionMapId =
                    mapIdOf selectionPath

                -- A topic is a container iff there is a map with the same id
                isContainer : Bool
                isContainer =
                    Dict.member topicId model.maps
            in
            if isContainer then
                -- Containers never move; cross by navigation (enter/exit).
                if selectionMapId == here then
                    let
                        _ =
                            L.log "Cross (enter container)" { container = topicId }
                    in
                    Just (Nav Fullscreen)

                else
                    let
                        _ =
                            L.log "Cross (exit container)" { container = selectionMapId }
                    in
                    Just (Nav Back)

            else if selectionMapId == here then
                -- parent → inner (into owning container if any)
                case findContainerForChild here topicId model of
                    Just containerId ->
                        let
                            _ =
                                L.log "Cross (parent→inner)" { topicId = topicId, src = here, dst = containerId }
                        in
                        Just (MoveTopicToMap topicId here origin topicId (containerId :: model.mapPath) origin)

                    Nothing ->
                        -- no container on parent; do a no-op move for consistency
                        let
                            _ =
                                L.log "Cross (no-op)" { reason = "no owning container on parent", topicId = topicId, parent = here }
                        in
                        Just (MoveTopicToMap topicId here origin topicId model.mapPath origin)

            else
                -- inner → parent
                case parentPathOf selectionPath of
                    Just parentPath ->
                        let
                            parentId =
                                mapIdOf parentPath

                            _ =
                                L.log "Cross (inner→parent)" { topicId = topicId, src = selectionMapId, dst = parentId }
                        in
                        Just (MoveTopicToMap topicId selectionMapId origin topicId parentPath origin)

                    Nothing ->
                        let
                            _ =
                                L.log "Cross disabled" { reason = "inner map has no parent", inner = selectionMapId }
                        in
                        Nothing


{-| Does `parentId` contain the inner map `childId`?
-}
isChildOf : MapId -> MapId -> Model -> Bool
isChildOf childId parentId model =
    case Dict.get parentId model.maps of
        Just parentMap ->
            Dict.member childId parentMap.items

        Nothing ->
            False


{-| Find the container (its inner-map id equals the container topic id) under `parentId`
that contains `topicId` in its inner map.
-}
findContainerForChild : MapId -> Id -> Model -> Maybe MapId
findContainerForChild parentId topicId model =
    model.maps
        |> Dict.values
        |> List.filter (\m -> Dict.member topicId m.items)
        -- inner map contains the topic
        |> List.filter (\m -> isChildOf m.id parentId model)
        -- and that inner map belongs to the parent view
        |> List.head
        |> Maybe.map .id
````

## File: src/Feature/WikiLink/Demo.elm
````elm
module Feature.WikiLink.Demo exposing (main)

import Browser
import Compat.WikiLink.Parser as P
import Compat.WikiLink.Regex as R
import Html exposing (Html, button, div, h2, pre, text, textarea)
import Html.Attributes as HA
import Html.Events exposing (onClick, onInput)



-- MODEL


type alias Model =
    { input : String
    , parsedSegments : List P.Segment
    , wikiOnly : List String
    , slugs : List String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { input = "A [[One]] and [https://ex.com ext] and [[Two Three]]!"
      , parsedSegments = []
      , wikiOnly = []
      , slugs = []
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = SetInput String
    | RunParse


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetInput s ->
            ( { model | input = s }, Cmd.none )

        RunParse ->
            let
                segments =
                    case P.parseLine model.input of
                        Ok segs ->
                            segs

                        Err _ ->
                            []

                onlyWiki =
                    R.parse model.input

                slugs =
                    List.map R.slug onlyWiki
            in
            ( { model | parsedSegments = segments, wikiOnly = onlyWiki, slugs = slugs }
            , Cmd.none
            )



-- VIEW


view : Model -> Html Msg
view model =
    div [ HA.style "padding" "12px", HA.style "font" "14px/1.4 system-ui" ]
        [ h2 [] [ text "WikiLink Demo (Regex + Parser)" ]
        , textarea
            [ HA.value model.input
            , onInput SetInput
            , HA.style "width" "100%"
            , HA.style "height" "6rem"
            ]
            []
        , div [ HA.style "margin" "8px 0" ]
            [ button [ onClick RunParse ] [ text "Parse" ] ]
        , div []
            [ h2 [] [ text "Parser.parseLine → segments" ]
            , pre [] [ text (segmentsToString model.parsedSegments) ]
            , h2 [] [ text "Regex.parse → [[...]] only" ]
            , pre [] [ text (fromListString model.wikiOnly) ]
            , h2 [] [ text "Slug (Regex.slug over [[...]] results)" ]
            , pre [] [ text (fromListString model.slugs) ]
            ]
        ]


segmentsToString : List P.Segment -> String
segmentsToString segs =
    segs
        |> List.map
            (\s ->
                case s of
                    P.Plain t ->
                        "Plain " ++ Debug.toString t

                    P.Wiki t ->
                        "Wiki  " ++ Debug.toString t

                    P.ExtLink url label ->
                        "Ext   " ++ Debug.toString ( url, label )
            )
        |> String.join "\n"


fromListString : List String -> String
fromListString =
    Debug.toString



-- MAIN


main : Program () Model Msg
main =
    Browser.element { init = init, update = update, view = view, subscriptions = \_ -> Sub.none }
````

## File: src/Feature/Cross.elm
````elm
module Feature.Cross exposing (Msg(..), view)

import Html exposing (Html, button, text)
import Html.Attributes as Attr
import Html.Events exposing (onClick)



-- Local message type for this feature


type Msg
    = CrossClick



-- The button view


view : Html Msg
view =
    button
        [ Attr.id "btn-Cross"
        , onClick CrossClick
        ]
        [ text "Cross" ]



-- ensure the button includes the id "btn-Cross"


crossButton : Model -> Html Msg
crossButton model =
    let
        enabled =
            isEnabled model

        -- whatever your logic is
    in
    button
        ([ Attr.id "btn-Cross"
         , Attr.style "font-family" "sans-serif"
         , Attr.style "font-size" "14px"
         ]
            ++ (if enabled then
                    [ onClick CrossClicked ]

                else
                    [ Attr.disabled True ]
               )
        )
        [ text "Cross" ]
````

## File: src/Logger/Dev/Logger.elm
````elm
module Dev.Logger exposing (debug, info, log, toString, warn, withConsole)

import Debug


info : String -> a -> a
info label v =
    Debug.log ("ℹ️ " ++ label) v


warn : String -> a -> a
warn label v =
    Debug.log ("⚠️ " ++ label) v


debug : String -> a -> a
debug label v =
    Debug.log ("🐛 " ++ label) v


withConsole : String -> a -> a
withConsole message v =
    let
        _ =
            Debug.log message ()
    in
    v



-- Back-compat alias


log : String -> a -> a
log =
    debug



-- Used by Utils to pretty-print values


toString : a -> String
toString =
    Debug.toString
````

## File: src/Logger/Prod/Logger.elm
````elm
module Prod.Logger exposing (..)

--- PROD LOGGER


log : String -> a -> a
log _ val =
    val


toString : a -> String
toString _ =
    ""
````

## File: src/Logger/Pretty.elm
````elm
module Logger.Pretty exposing (summarizeModel)

import AppMain exposing (Model)
import Dict
import Domain.Id exposing (labelMap)


summarizeModel : Model -> String
summarizeModel m =
    let
        mapCounts =
            Dict.toList m.maps
                |> List.map (\( mid, mp ) -> labelMap mid ++ ":" ++ String.fromInt (Dict.size mp.items))
                |> String.join ", "

        pathStr =
            m.mapPath |> List.map String.fromInt |> String.join "→"
    in
    String.join " | "
        [ "maps=" ++ String.fromInt (Dict.size m.maps) ++ " [" ++ mapCounts ++ "]"
        , "items=" ++ String.fromInt (Dict.size m.items)
        , "story=" ++ (List.length m.fedWiki.storyItemIds |> String.fromInt)
        , "path=" ++ pathStr
        ]
````

## File: src/Mouse/Pretty.elm
````elm
module Mouse.Pretty exposing (pretty)

import Mouse
import String


pretty : Mouse.Msg -> String
pretty m =
    case m of
        Mouse.Down ->
            "Down"

        Mouse.DownOnItem cls id path pos ->
            "DownOnItem "
                ++ cls
                ++ " "
                ++ String.fromInt id
                ++ " path="
                ++ pathString path
                ++ " pos="
                ++ posString pos

        Mouse.Move pos ->
            "Move " ++ posString pos

        Mouse.Up ->
            "Up"

        Mouse.Over cls id path ->
            "Over " ++ cls ++ " " ++ String.fromInt id ++ " path=" ++ pathString path

        Mouse.Out cls id path ->
            "Out " ++ cls ++ " " ++ String.fromInt id ++ " path=" ++ pathString path

        Mouse.Time _ ->
            "Time"


posString : { x : Float, y : Float } -> String
posString p =
    "{ x = " ++ String.fromFloat p.x ++ ", y = " ++ String.fromFloat p.y ++ " }"


pathString : List Int -> String
pathString ints =
    "[" ++ (ints |> List.map String.fromInt |> String.join ",") ++ "]"
````

## File: src/UI/Icon.elm
````elm
module UI.Icon exposing (sprite)

import Html exposing (Html)
import Html.Attributes as Attr
import Svg exposing (circle, defs, marker, path, svg, symbol)
import Svg.Attributes as SA


sprite : String -> Html msg
sprite prefix =
    svg
        [ SA.style "position:absolute;width:0;height:0;overflow:hidden"
        , Attr.attribute "aria-hidden" "true"
        , Attr.attribute "focusable" "false" -- ← Optional: prevents focus in older browsers
        ]
        [ defs []
            [ symbol [ SA.id (prefix ++ "topic-icon"), SA.viewBox "0 0 24 24" ]
                [ circle [ SA.cx "12", SA.cy "12", SA.r "8", SA.fill "currentColor" ] [] ]
            , marker
                [ SA.id (prefix ++ "arrow-marker")
                , SA.viewBox "0 0 10 10"
                , SA.refX "9"
                , SA.refY "5"
                , SA.markerWidth "6"
                , SA.markerHeight "6"
                , SA.orient "auto-start-reverse"
                ]
                [ path [ SA.d "M0,0 L10,5 L0,10 z", SA.fill "currentColor" ] [] ]
            ]
        ]
````

## File: src/Logger.elm
````elm
module Logger exposing (debug, info, log, toString, warn, withConsole)

import Debug


info : String -> a -> a
info label v =
    Debug.log ("ℹ️ " ++ label) v


warn : String -> a -> a
warn label v =
    Debug.log ("⚠️ " ++ label) v


debug : String -> a -> a
debug label v =
    Debug.log ("🐛 " ++ label) v


withConsole : String -> a -> a
withConsole message v =
    let
        _ =
            Debug.log message ()
    in
    v



-- Back-compat alias


log : String -> a -> a
log =
    debug



-- Used by Utils to pretty-print values


toString : a -> String
toString =
    Debug.toString
````

## File: src/Model.elm
````elm
module Model exposing (..)

import Dict exposing (Dict)


type alias Items =
    Dict Id Item


type alias Item =
    { id : Id
    , info : ItemInfo

    -- TODO: add "assocIds", the item's associations
    }


type ItemInfo
    = Topic TopicInfo
    | Assoc AssocInfo


type alias TopicInfo =
    { id : Id
    , text : String
    , iconName : Maybe IconName -- serialzed as "icon"
    }


type alias AssocInfo =
    { id : Id
    , itemType : ItemType -- serialzed as "type", field can't be named "type", a reserved word
    , role1 : RoleType
    , player1 : Id
    , role2 : RoleType
    , player2 : Id
    }


type alias MapPath =
    List MapId


type alias Maps =
    Dict Id Map


type alias Map =
    { id : MapId
    , rect : Rectangle
    , items : MapItems
    }


type alias MapItems =
    Dict Id MapItem


type alias MapItem =
    { id : Id
    , parentAssocId : Id
    , hidden : Bool -- TODO: replace hidden/pinned by custom type: Hidden/Visible/Pinned?
    , pinned : Bool
    , props : MapProps
    }


type MapProps
    = MapTopic TopicProps
    | MapAssoc AssocProps


type alias TopicProps =
    { pos : Point
    , size : Size
    , displayMode : DisplayMode -- serialized as "display"
    }


type alias AssocProps =
    {}


type DisplayMode
    = Monad MonadDisplay
    | Container ContainerDisplay


type MonadDisplay
    = LabelOnly
    | Detail


type ContainerDisplay
    = BlackBox
    | WhiteBox
    | Unboxed


type alias Point =
    { x : Float
    , y : Float
    }


type alias Rectangle =
    { x1 : Float
    , y1 : Float
    , x2 : Float
    , y2 : Float
    }


type alias Size =
    { w : Float
    , h : Float
    }


type alias Selection =
    List ( Id, MapPath )


type alias Id =
    Int


type alias MapId =
    Id


type alias Class =
    String



-- a CSS class, e.g. "dmx-topic"


type alias ItemType =
    String



-- a type URI, e.g. "dmx.association"


type alias RoleType =
    String



-- a role type URI, e.g. "dmx.default"


type alias Delta =
    Point


type alias IconName =
    String



-- name of feather icon, https://feathericons.com


type EditState
    = ItemEdit Id MapId
    | NoEdit


type EditMsg
    = EditStart
    | OnTextInput String
    | OnTextareaInput String
    | SetTopicSize Id MapId Size
    | EditEnd


type NavMsg
    = Fullscreen
    | Back



-- In the embed we don’t keep any transient UI caches to reset; identity is fine.


resetTransientState m =
    m
````

## File: src/Mouse.elm
````elm
module Mouse exposing (..)

import Model exposing (Class, Id, MapPath, Point)
import Time


type alias Model =
    { dragState : DragState }


init : Model
init =
    { dragState = NoDrag }


type DragState
    = WaitForStartTime Class Id MapPath Point -- start point (mouse)
    | DragEngaged Time.Posix Class Id MapPath Point -- start point (mouse)
    | WaitForEndTime Time.Posix Class Id MapPath Point -- start point (mouse)
    | Drag DragMode Id MapPath Point Point (Maybe ( Id, MapPath )) -- orig topic pos,
      -- last point (mouse)
    | NoDrag


type DragMode
    = DragTopic
    | DrawAssoc


type Msg
    = Down -- mouse down somewhere
    | DownOnItem Class Id MapPath Point -- mouse down on an item where a drag can be engaged
    | Move Point
    | Up
    | Over Class Id MapPath
    | Out Class Id MapPath
    | Time Time.Posix
````

## File: src/Search.elm
````elm
module Search exposing (..)

import Model exposing (Id)


type alias Model =
    { text : String
    , result : List Id -- topic Ids
    , menu : ResultMenu
    }


init : Model
init =
    { text = ""
    , result = []
    , menu = Closed
    }


type ResultMenu
    = Open (Maybe Id) -- hovered topic
    | Closed


type Msg
    = Input String
    | FocusInput
    | HoverItem Id
    | UnhoverItem Id
    | ClickItem Id
````

## File: src/Types.elm
````elm
module Types exposing
    ( ContainerDisplay
    , DisplayMode
    , Id
    , MapId
    , MapItem
    , MapPath
    , MapProps
    , Maps
    , MonadDisplay
    , Point
    , TopicProps
    )

import Model as M



-- primitives / records


type alias Id =
    M.Id


type alias MapId =
    M.MapId


type alias MapPath =
    M.MapPath


type alias Point =
    M.Point



-- collections


type alias Maps =
    M.Maps



-- domain


type alias MapItem =
    M.MapItem


type alias MapProps =
    M.MapProps


type alias TopicProps =
    M.TopicProps



-- unions (constructors stay in `Model`)


type alias DisplayMode =
    M.DisplayMode


type alias MonadDisplay =
    M.MonadDisplay


type alias ContainerDisplay =
    M.ContainerDisplay
````

## File: tests/Algebra/ContainmentTest.elm
````elm
module Algebra.ContainmentTest exposing (tests)

import Algebra.Containment as C
import Expect
import Test exposing (..)


d : Int -> C.Depth
d n =
    C.Depth n


tests : Test
tests =
    describe "Containment arithmetic (depth)"
        [ test "within is associative" <|
            \_ ->
                let
                    lhs =
                        C.within (d 1) (C.within (d 2) (d 3))

                    rhs =
                        C.within (C.within (d 1) (d 2)) (d 3)
                in
                Expect.equal lhs rhs
        , test "depth addition and multiplication basic laws" <|
            \_ ->
                Expect.all
                    [ \_ -> Expect.equal (C.within (d 2) (d 3)) (d 5)
                    , \_ -> Expect.equal (C.times (d 2) (d 3)) (d 6)
                    ]
                    ()
        , test "distributivity over depth (Int semantics)" <|
            \_ ->
                let
                    a =
                        d 2

                    b =
                        d 3

                    c =
                        d 4
                in
                Expect.equal
                    (C.times a (C.within b c))
                    (C.within (C.times a b) (C.times a c))
        ]
````

## File: tests/Compat/WikiLink/ParserTest.elm
````elm
module Compat.WikiLink.ParserTest exposing (tests)

import Compat.WikiLink.Parser as P
import Expect
import Test exposing (..)


expectOk : Result x a -> a
expectOk r =
    case r of
        Ok a ->
            a

        Err _ ->
            Debug.todo "Parser failed; see the test diff for details."


tests : Test
tests =
    describe "Compat.WikiLink.Parser.parseLine"
        [ test "plain text only" <|
            \_ ->
                "hello"
                    |> P.parseLine
                    |> expectOk
                    |> Expect.equal [ P.Plain "hello" ]
        , test "single wiki link in the middle" <|
            \_ ->
                "a [[DM6 Elm]] app"
                    |> P.parseLine
                    |> expectOk
                    |> Expect.equal
                        [ P.Plain "a "
                        , P.Wiki "DM6 Elm"
                        , P.Plain " app"
                        ]
        , test "multiple mixed with external link that has label" <|
            \_ ->
                "A [[One]] and [https://ex.com ext] and [[Two Three]]!"
                    |> P.parseLine
                    |> expectOk
                    |> Expect.equal
                        [ P.Plain "A "
                        , P.Wiki "One"
                        , P.Plain " and "
                        , P.ExtLink "https://ex.com" "ext"
                        , P.Plain " and "
                        , P.Wiki "Two Three"
                        , P.Plain "!"
                        ]
        , test "external link without label" <|
            \_ ->
                "go [https://ex.com] now"
                    |> P.parseLine
                    |> expectOk
                    |> Expect.equal
                        [ P.Plain "go "
                        , P.ExtLink "https://ex.com" ""
                        , P.Plain " now"
                        ]
        , test "starts with link" <|
            \_ ->
                "[[Start]] then text"
                    |> P.parseLine
                    |> expectOk
                    |> Expect.equal
                        [ P.Wiki "Start"
                        , P.Plain " then text"
                        ]
        , test "ends with link" <|
            \_ ->
                "text then [[End]]"
                    |> P.parseLine
                    |> expectOk
                    |> Expect.equal
                        [ P.Plain "text then "
                        , P.Wiki "End"
                        ]
        , test "consecutive wiki links" <|
            \_ ->
                "[[A]][[B]]"
                    |> P.parseLine
                    |> expectOk
                    |> Expect.equal
                        [ P.Wiki "A"
                        , P.Wiki "B"
                        ]
        , test "unicode inside wiki link preserved" <|
            \_ ->
                "see [[Zürich Café]]"
                    |> P.parseLine
                    |> expectOk
                    |> Expect.equal
                        [ P.Plain "see "
                        , P.Wiki "Zürich Café"
                        ]
        ]
````

## File: tests/Compat/WikiLink/RegexTest.elm
````elm
module Compat.WikiLink.RegexTest exposing (tests)

import Compat.WikiLink.Regex as WL
import Expect
import Test exposing (..)


tests : Test
tests =
    describe "Compat.WikiLink.Regex"
        [ describe "parse"
            [ test "extracts a single [[Title]]" <|
                \_ ->
                    "[[DM6 Elm]] app"
                        |> WL.parse
                        |> Expect.equal [ "DM6 Elm" ]
            , test "extracts multiple links in order" <|
                \_ ->
                    "foo [[One]] bar [[Two Three]] baz"
                        |> WL.parse
                        |> Expect.equal [ "One", "Two Three" ]
            , test "returns [] when there are no links" <|
                \_ ->
                    "no links here"
                        |> WL.parse
                        |> Expect.equal []
            , test "ignores external link tokens like [https://… label]" <|
                \_ ->
                    "mix [[Alpha]] and [https://example.com label] then [[Beta]]"
                        |> WL.parse
                        |> Expect.equal [ "Alpha", "Beta" ]
            , test "keeps Unicode and inner spaces as-is" <|
                \_ ->
                    "see [[  Montréal Café  ]] and [[Zürich]]"
                        |> WL.parse
                        |> Expect.equal [ "  Montréal Café  ", "Zürich" ]
            ]
        , describe "slug"
            [ test "basic punctuation removed, spaces collapsed to dashes" <|
                \_ ->
                    "Federated Wiki!"
                        |> WL.slug
                        |> Expect.equal "federated-wiki"
            , test "multiple spaces collapse to a single dash" <|
                \_ ->
                    "  DM6   Elm  "
                        |> WL.slug
                        |> Expect.equal "dm6-elm"
            , test "non-ascii letters dropped by minimal slug rule" <|
                \_ ->
                    "Zürich Café"
                        |> WL.slug
                        |> Expect.equal "zrich-caf"
            ]
        ]
````

## File: tests/Feature/OpenDoor/ButtonTest.elm
````elm
module Feature.OpenDoor.ButtonTest exposing (tests)

import AppModel as AM exposing (Msg(..))
import Compat.Display as CDisp
import Compat.TestUtil exposing (asUndo)
import Dict
import Expect
import Html
import Html.Attributes as Attr
import Main exposing (view)
import Model exposing (Id, MapId, MapPath, Point, Size)
import ModelAPI exposing (..)
import Test exposing (..)
import Test.Html.Event as Event
import Test.Html.Query as Query
import Test.Html.Selector as Sel


{-| Build a model where:

  - there is a container with an inner map (parent = 0)
  - a child topic lives inside that container
  - we are currently viewing the container’s inner map
  - that child is selected in that inner map

-}
setupModel : ( AM.Model, MapId, Id )
setupModel =
    let
        -- start with default model
        ( m1, containerId ) =
            createTopic "Container" Nothing AM.default

        -- container visible on home map (0) as a container
        m2 =
            addItemToMap containerId
                (Model.MapTopic (Model.TopicProps (Point 100 100) (Size 160 60) (Model.Container Model.BlackBox)))
                0
                m1

        -- give the container its inner map (parent = 0)
        m3 =
            { m2
                | maps =
                    Dict.insert containerId (Model.Map containerId (Model.Rectangle 0 0 0 0) Dict.empty) m2.maps
            }

        -- create a child topic inside the container
        ( m4, topicId ) =
            createTopic "Child" Nothing m3

        m5 =
            addItemToMap topicId
                (Model.MapTopic (Model.TopicProps (Point 30 30) (Size 120 40) (Model.Monad Model.LabelOnly)))
                containerId
                m4

        -- We are *inside* the container and the child is selected there
        m6 =
            let
                path : MapPath
                path =
                    containerId :: m5.mapPath
            in
            { m5 | mapPath = path }
                |> ModelAPI.select topicId path
    in
    ( m6, containerId, topicId )


tests : Test
tests =
    describe "Toolbar Cross button"
        [ test "Clicking 'Cross' dispatches MoveTopicToMap with correct ids (and is enabled)" <|
            \_ ->
                let
                    ( model0, containerId, topicId ) =
                        setupModel

                    -- Render document body
                    root =
                        Html.div [] (view (asUndo model0)).body
                            |> Query.fromHtml

                    openDoorBtn =
                        root
                            |> Query.find [ Sel.id "btn-Cross" ]
                in
                Expect.all
                    [ -- 1) The button must be enabled (no 'disabled' attribute)
                      \btn -> Query.hasNot [ Sel.attribute (Attr.disabled True) ] btn

                    -- 2) Clicking it must dispatch the expected 6-arg message
                    , \btn ->
                        let
                            origin : Point
                            origin =
                                { x = 0, y = 0 }
                        in
                        btn
                            |> Event.simulate Event.click
                            |> Event.expect
                                (MoveTopicToMap
                                    topicId
                                    containerId
                                    origin
                                    topicId
                                    model0.mapPath
                                    origin
                                )
                    ]
                    openDoorBtn
        ]
````

## File: tests/Tests/Main.elm
````elm
module Tests.Main exposing (tests)

-- Everything master has…
-- …plus feature tests present only on main

import Domain.ReparentRulesTest
import Feature.OpenDoor.CopyTest
import Feature.OpenDoor.StayVisibleTest
import Import.DmxCoreTopicTest
import Model.AddItemToMapCycleTest
import Model.DefaultModelTest
import Model.SelfContainmentInvariantTest
import Search.UpdateTest
import Storage.InitDecodeTest
import Test exposing (..)
import View.ToolbarButtonsTest


tests : Test
tests =
    describe "Main (feature) test suite"
        [ Domain.ReparentRulesTest.tests
        , Import.DmxCoreTopicTest.tests
        , Model.AddItemToMapCycleTest.tests
        , Model.DefaultModelTest.tests
        , Model.SelfContainmentInvariantTest.tests
        , Search.UpdateTest.tests
        , Storage.InitDecodeTest.tests
        , View.ToolbarButtonsTest.tests

        -- Feature-only:
        , Feature.OpenDoor.CopyTest.tests
        , Feature.OpenDoor.StayVisibleTest.tests
        ]
````

## File: build-dev.sh
````bash
#!/bin/sh

set -e

js="main.js"
logger="DevLogger.elm"

cp src/Logger/$logger src/Logger.elm
elm make src/Main.elm --output=$js
````

## File: elm.json
````json
{
    "type": "application",
    "source-directories": [
        "src"
    ],
    "elm-version": "0.19.1",
    "dependencies": {
        "direct": {
            "NoRedInk/elm-json-decode-pipeline": "1.0.1",
            "elm/browser": "1.0.2",
            "elm/core": "1.0.5",
            "elm/html": "1.0.0",
            "elm/json": "1.1.3",
            "elm/parser": "1.1.0",
            "elm/random": "1.0.0",
            "elm/regex": "1.0.0",
            "elm/svg": "1.0.1",
            "elm/time": "1.0.0",
            "elm-community/undo-redo": "3.0.0",
            "feathericons/elm-feather": "1.5.0"
        },
        "indirect": {
            "elm/url": "1.0.0",
            "elm/virtual-dom": "1.0.3"
        }
    },
    "test-dependencies": {
        "direct": {
            "elm-explorations/test": "2.2.0"
        },
        "indirect": {
            "elm/bytes": "1.0.8"
        }
    }
}
````

## File: src/Compat/Model.elm
````elm
module Compat.Model exposing
    ( Ext
    , createAssoc
    , createAssocAndAddToMap
    , defaultExt
    , makeMap
    , makeMapItem
    , makeMapItemR
    , makeMapR
    )

{-| A tiny compatibility layer to isolate upstream refactors.

A constructor/record convenience layer so
your app/tests don’t use raw constructors or upstream argument ordering directly.

Use these helpers instead of calling constructors / ModelAPI directly.

-}

import AppModel as AM exposing (Model)
import Compat.ModelAPI as ModelAPI
import Model as M exposing (Delta, Id, MapId, MapItem, MapItems, MapProps, Rectangle)



-- MAP ------------------------------------------------------------------------
-- Upstream (Sep 2025): Map id rect items


makeMap : MapId -> Rectangle -> MapItems -> M.Map
makeMap id rect items =
    M.Map id rect items


makeMapR : { a | id : MapId, rect : Rectangle, items : MapItems } -> M.Map
makeMapR r =
    M.Map r.id r.rect r.items



-- MAP ITEM -------------------------------------------------------------------


{-| Upstream (Aug 2025): MapItem id parentAssocId hidden pinned props
-}
makeMapItem : Id -> Id -> Bool -> Bool -> MapProps -> MapItem
makeMapItem id parentAssocId hidden pinned props =
    MapItem id parentAssocId hidden pinned props


makeMapItemR : { a | id : Id, parentAssocId : Id, hidden : Bool, pinned : Bool, props : MapProps } -> MapItem
makeMapItemR r =
    MapItem r.id r.parentAssocId r.hidden r.pinned r.props



-- ASSOC CREATION -------------------------------------------------------------


{-| Record-style wrapper; stable call-site even if upstream reorders args.
-}
createAssoc : { a | itemType : String, role1 : String, player1 : Id, role2 : String, player2 : Id } -> Model -> ( Model, Id )
createAssoc r model =
    -- Upstream: createAssoc itemType role1 player1 role2 player2 model
    ModelAPI.createAssoc r.itemType r.role1 r.player1 r.role2 r.player2 model


createAssocAndAddToMap : { a | itemType : String, role1 : String, player1 : Id, role2 : String, player2 : Id, mapId : MapId } -> Model -> ( Model, Id )
createAssocAndAddToMap r model =
    -- Upstream: createAssocAndAddToMap itemType role1 player1 role2 player2 mapId model
    ModelAPI.createAssocAndAddToMap r.itemType r.role1 r.player1 r.role2 r.player2 r.mapId model


type alias Ext =
    { journal : List Delta -- or List M.Delta if you prefer to qualify
    , showJournal : Bool
    }


defaultExt : Ext
defaultExt =
    { journal = [], showJournal = False }
````

## File: src/Feature/Move.elm
````elm
module Feature.Move exposing
    ( Config
    , Deps
    , MoveArgs
    , Report
    , moveTopicToMap
    , moveTopicToMap_
    )

import AppModel exposing (Model)
import Model exposing (ContainerDisplay(..), DisplayMode(..), MapProps(..))
import Types
    exposing
        ( ContainerDisplay
        , DisplayMode
        , Id
        , MapId
        , MapItem
        , MapPath
        , MapProps
        , Maps
        , MonadDisplay
        , Point
        , TopicProps
        )



-- POLICY KNOBS


type alias Config =
    { whiteBoxPadding : Float
    , respectBlackBox : Bool
    , selectAfterMove : Bool
    , autosizeAfterMove : Bool
    }



-- HOST DEPS


type alias Deps =
    { createMapIfNeeded : Id -> Model -> ( Model, Bool )
    , getTopicProps : Id -> MapId -> Model -> Maybe TopicProps
    , addItemToMap : Id -> MapProps -> MapId -> Model -> Model
    , hideItem : Id -> MapId -> Model -> Model
    , setTopicPos : Id -> MapId -> Point -> Model -> Model
    , select : Id -> MapPath -> Model -> Model
    , autoSize : Model -> Model
    , getItem : Id -> Model -> Maybe MapItem
    , updateItem : Id -> (MapItem -> MapItem) -> Model -> Model
    , worldToLocal : Id -> Point -> Model -> Maybe Point
    , ownerToMapId :
        Id
        -> Model
        -> MapId -- NEW: map owner topic → MapId
    }



-- CALL ARGS


type alias MoveArgs =
    { topicId : Id
    , srcMapId : MapId
    , srcPos : Point
    , targetId : Id
    , targetMapPath : MapPath
    , dropWorld : Point
    }


type alias Report =
    { createdMap : Bool
    , promotedTarget : Bool
    , finalLocalPos : Point
    }



-- PUBLIC


moveTopicToMap : Deps -> Config -> MoveArgs -> Model -> ( Model, Report )
moveTopicToMap deps cfg args model0 =
    let
        ( model1, created ) =
            deps.createMapIfNeeded args.targetId model0

        beforePromote =
            deps.getItem args.targetId model1

        model2 =
            deps.updateItem args.targetId (promoteToWhiteBoxUnlessBlack cfg.respectBlackBox) model1

        afterPromote =
            deps.getItem args.targetId model2

        promoted =
            case ( beforePromote, afterPromote ) of
                ( Just a, Just b ) ->
                    a /= b

                _ ->
                    False

        localPos =
            deps.worldToLocal args.targetId args.dropWorld model2
                |> Maybe.withDefault (fallbackLocalPos cfg)

        props_ =
            deps.getTopicProps args.topicId args.srcMapId model2
                |> Maybe.map (\tp -> MapTopic { tp | pos = localPos })

        destMapId : MapId
        destMapId =
            deps.ownerToMapId args.targetId model2
    in
    case props_ of
        Nothing ->
            ( model0
            , { createdMap = False, promotedTarget = False, finalLocalPos = localPos }
            )

        Just newItemProps ->
            let
                model3 =
                    model2
                        |> deps.hideItem args.topicId args.srcMapId
                        |> deps.setTopicPos args.topicId args.srcMapId args.srcPos
                        |> deps.addItemToMap args.topicId newItemProps destMapId
                        |> (\m ->
                                if cfg.selectAfterMove then
                                    deps.select args.targetId args.targetMapPath m

                                else
                                    m
                           )
                        |> (\m ->
                                if cfg.autosizeAfterMove then
                                    deps.autoSize m

                                else
                                    m
                           )
            in
            ( model3
            , { createdMap = created
              , promotedTarget = promoted
              , finalLocalPos = localPos
              }
            )



-- Pipeline-friendly wrapper


moveTopicToMap_ :
    Deps
    -> Config
    -> Id
    -> MapId
    -> Point
    -> Id
    -> MapPath
    -> Point
    -> Model
    -> Model
moveTopicToMap_ deps cfg topicId mapId origPos targetId targetPath worldPos model =
    let
        ( m, _ ) =
            moveTopicToMap deps
                cfg
                { topicId = topicId
                , srcMapId = mapId
                , srcPos = origPos
                , targetId = targetId
                , targetMapPath = targetPath
                , dropWorld = worldPos
                }
                model
    in
    m



-- HELPERS


promoteToWhiteBoxUnlessBlack : Bool -> MapItem -> MapItem
promoteToWhiteBoxUnlessBlack respectBlackBox item =
    case item.props of
        MapTopic mt ->
            let
                newMode =
                    case mt.displayMode of
                        Container BlackBox ->
                            if respectBlackBox then
                                Container BlackBox

                            else
                                Container WhiteBox

                        Container _ ->
                            Container WhiteBox

                        Monad _ ->
                            Container WhiteBox
            in
            { item
                | hidden = False
                , props = MapTopic { mt | displayMode = newMode }
            }

        _ ->
            item


fallbackLocalPos : Config -> Point
fallbackLocalPos cfg =
    { x = cfg.whiteBoxPadding + 78
    , y = cfg.whiteBoxPadding + 12
    }
````

## File: src/Boxing.elm
````elm
module Boxing exposing (boxContainer, unboxContainer)

import AppModel exposing (..)
import Dict
import Model exposing (..)
import ModelAPI
    exposing
        ( getDisplayMode
        , getMap
        , getMapIfExists
        , hasMap
        , hideItem_
        , isVisible
        , updateMaps
        )
import Utils exposing (..)



-- MODEL


type alias TransferFunc =
    MapItems -> MapItems -> Model -> MapItems



-- UPDATE


{-| Hides a container content from its parent map.
(Any target map can be given but de-facto it's the container's parent map)
-}
boxContainer : MapId -> MapId -> Model -> Maps
boxContainer containerId targetMapId model =
    case getDisplayMode containerId targetMapId model.maps of
        -- box only if currently unboxed
        Just (Container Unboxed) ->
            transferContent containerId targetMapId boxItems model

        _ ->
            model.maps


{-| Reveals a container content on its parent map.
(Any target map can be given but de-facto it's the container's parent map)
-}
unboxContainer : MapId -> MapId -> Model -> Maps
unboxContainer containerId targetMapId model =
    case getDisplayMode containerId targetMapId model.maps of
        -- unbox only if currently boxed
        Just (Container BlackBox) ->
            transferContent containerId targetMapId unboxItems model

        Just (Container WhiteBox) ->
            transferContent containerId targetMapId unboxItems model

        _ ->
            model.maps


transferContent : MapId -> MapId -> TransferFunc -> Model -> Maps
transferContent containerId targetMapId transferFunc model =
    case getMap containerId model.maps of
        Just containerMap ->
            model.maps
                |> updateMaps
                    targetMapId
                    (\targetMap ->
                        { targetMap | items = transferFunc containerMap.items targetMap.items model }
                    )

        Nothing ->
            model.maps


{-| Transfer function, Boxing.
Iterates the container items (recursively) and sets corresponding target items to hidden.
Returns the updated target items.
-}
boxItems : MapItems -> MapItems -> Model -> MapItems
boxItems containerItems targetItems model =
    containerItems
        |> Dict.values
        |> List.foldr
            -- FIXME: apply isVisible filter?
            (\containerItem targetItemsAcc ->
                case targetItemsAcc |> Dict.get containerItem.id of
                    Just { pinned } ->
                        if pinned then
                            -- don't box pinned items, only hide the assoc
                            hideItem_ containerItem.parentAssocId targetItemsAcc model

                        else
                            let
                                items =
                                    hideItem_ containerItem.id targetItemsAcc model
                            in
                            case getMapIfExists containerItem.id model.maps of
                                Just map ->
                                    boxItems map.items items model

                                -- recursion
                                Nothing ->
                                    items

                    Nothing ->
                        targetItemsAcc
             -- FIXME: continue unboxing containers?
            )
            targetItems


{-| Transfer function, Unboxing.
Iterates the container items (recursively) and reveals corresponding target items.
Returns the updated target items.
-}
unboxItems : MapItems -> MapItems -> Model -> MapItems
unboxItems containerItems targetItems model =
    containerItems
        |> Dict.values
        |> List.filter isVisible
        |> List.foldr
            (\containerItem targetItemsAcc ->
                case containerItem.props of
                    MapTopic _ ->
                        let
                            ( items, abort ) =
                                unboxTopic containerItem targetItemsAcc model
                        in
                        if abort then
                            items

                        else
                            case getMapIfExists containerItem.id model.maps of
                                Just map ->
                                    unboxItems map.items items model

                                -- recursion
                                Nothing ->
                                    items

                    MapAssoc _ ->
                        unboxAssoc containerItem targetItemsAcc
            )
            targetItems


{-| Returns the target item to reveal that corresponds to the container item.
Part of unboxing. FIXDOC
-}
unboxTopic : MapItem -> MapItems -> Model -> ( MapItems, Bool )
unboxTopic containerItem targetItems model =
    let
        ( topicToInsert, abort ) =
            case targetItems |> Dict.get containerItem.id of
                Just item ->
                    -- Item already exists on target map.
                    -- If it's a container, force WhiteBox unless it's explicitly BlackBox.
                    let
                        item1 =
                            if hasMap containerItem.id model.maps then
                                case item.props of
                                    MapTopic props ->
                                        case props.displayMode of
                                            Container BlackBox ->
                                                item

                                            Container WhiteBox ->
                                                item

                                            _ ->
                                                setWhiteBox item

                                    _ ->
                                        item

                            else
                                item

                        item2 =
                            { item1 | hidden = False, pinned = not item1.hidden }

                        _ =
                            info "unboxTopic" item2
                    in
                    ( item2, isAbort item2 )

                Nothing ->
                    -- New on target map: containers appear as WhiteBox by default.
                    if hasMap containerItem.id model.maps then
                        ( setWhiteBox containerItem, False )

                    else
                        ( containerItem, False )

        assocToInsert =
            targetAssocItem containerItem.parentAssocId targetItems
    in
    ( targetItems
        |> Dict.insert topicToInsert.id topicToInsert
        |> Dict.insert assocToInsert.id assocToInsert
    , abort
    )


setWhiteBox : MapItem -> MapItem
setWhiteBox item =
    { item
        | props =
            case item.props of
                MapTopic props ->
                    MapTopic { props | displayMode = Container WhiteBox }

                MapAssoc props ->
                    MapAssoc props
    }


unboxAssoc : MapItem -> MapItems -> MapItems
unboxAssoc containerItem targetItems =
    let
        assocToInsert =
            targetAssocItem containerItem.id targetItems
    in
    targetItems
        |> Dict.insert assocToInsert.id assocToInsert


setUnboxed : MapItem -> MapItem
setUnboxed item =
    { item
        | props =
            case item.props of
                MapTopic props ->
                    MapTopic { props | displayMode = Container Unboxed }

                MapAssoc props ->
                    MapAssoc props
    }


isAbort : MapItem -> Bool
isAbort item =
    case item.props of
        MapTopic props ->
            case props.displayMode of
                Container BlackBox ->
                    True

                Container WhiteBox ->
                    True

                Container Unboxed ->
                    False

                Monad _ ->
                    False

        MapAssoc _ ->
            False


{-| Returns the target item to reveal that corresponds to the container item.
Part of unboxing. FIXDOC
-}
targetAssocItem : Id -> MapItems -> MapItem
targetAssocItem assocId targetItems =
    case targetItems |> Dict.get assocId of
        Just item ->
            { item | hidden = False }

        Nothing ->
            MapItem assocId -1 False False (MapAssoc AssocProps)
````

## File: src/SvgExtras.elm
````elm
module SvgExtras exposing (cursorPointer, peAll, peNone, peStroke)

import Svg exposing (Attribute)
import Svg.Attributes as SA


peNone : Attribute msg
peNone =
    SA.style "pointer-events: none"


peStroke : Attribute msg
peStroke =
    SA.style "pointer-events: visibleStroke"


peAll : Attribute msg
peAll =
    SA.style "pointer-events: all"


cursorPointer : Attribute msg
cursorPointer =
    SA.style "cursor: pointer"
````

## File: tests/Compat/TestDefault.elm
````elm
module Compat.TestDefault exposing (defaultModel, suite)

import AppMain as AdapterMain
import AppModel as AM
import Dict
import Expect
import Json.Encode as E
import Test exposing (..)


defaultModel : AM.Model
defaultModel =
    let
        ( undo, _ ) =
            AdapterMain.init E.null
    in
    undo.present



-- Sanity checks for the adapter that accepts Json.Value (E.null → cold boot)


suite : Test
suite =
    describe "Compat default boot via adapter"
        [ test "init with E.null cold-boots to default model" <|
            \_ ->
                let
                    ( undo, _ ) =
                        AdapterMain.init E.null

                    m =
                        undo.present
                in
                Expect.equal [ 0 ] m.mapPath
        , test "home map (0) exists" <|
            \_ ->
                let
                    ( undo, _ ) =
                        AdapterMain.init E.null

                    m =
                        undo.present
                in
                Expect.equal True (Dict.member 0 m.maps)
        , test "nextId starts at 1" <|
            \_ ->
                let
                    ( undo, _ ) =
                        AdapterMain.init E.null

                    m =
                        undo.present
                in
                Expect.equal 1 m.nextId
        ]
````

## File: src/Compat/ContainmentOps.elm
````elm
module Compat.ContainmentOps exposing
    ( boundaryCross
    , depthOf
    , moveDeeperBy
    , moveShallowerBy
    , multiplyDepth
    )

import Algebra.Containment as C
import AppModel as AM
import Model exposing (Id, MapPath, Point)
import ModelAPI
    exposing
        ( createDefaultAssocIn
        , fromPath
        , getMapId
        , getTopicPos
        , push
        , resetSelection
        , select
        , setTopicPosByDelta
        , swap
        )
import Random
import UndoList


boundaryCross : AM.UndoModel -> ( AM.Model, Cmd AM.Msg ) -> ( AM.UndoModel, Cmd AM.Msg )
boundaryCross =
    push


depthOf : AM.Model -> Id -> C.Depth
depthOf model id =
    let
        path =
            mapPathOf model id

        -- write this: where is the item currently?
    in
    C.toDepth path


moveDeeperBy : AM.Model -> Id -> Int -> AM.Model
moveDeeperBy model id k =
    let
        d0 =
            depthOf model id

        d1 =
            C.within d0 (C.Depth k)
    in
    Tuple.first <|
        recontainToDepth model
            { id = id
            , fromPath = mapPathOf model id
            , toPath = fromDepthToMapPath d1
            , origPos = getTopicPos id model
            , dropPos = getTopicPos id model
            }



-- implement using ensureMap + addItemToMap


moveShallowerBy : AM.Model -> Id -> Int -> AM.Model
moveShallowerBy model id k =
    moveDeeperBy model id -k


multiplyDepth : AM.Model -> Id -> Int -> AM.Model
multiplyDepth model id k =
    let
        d1 =
            C.times (depthOf model id) (C.Depth k)
    in
    recontainToDepth model id d1


{-| Commit a drop by (possibly) crossing a boundary.

Parameters (record):
id : dragged topic id
fromPath : path where drag started (source mapPath)
toPath : path where it is dropped (target mapPath)
origPos : original position (before drag) in source map
dropPos : drop position in target map

Returns: (unchanged model, Cmd Msg)

Note: we return `model` unchanged because the actual move is performed by your
`update` in response to `MoveTopicToMap`. This keeps “where to move” and “how to
apply it” decoupled.

-}
recontainToDepth :
    AM.Model
    ->
        { id : Id
        , fromPath : MapPath
        , toPath : MapPath
        , origPos : Point
        , dropPos : Point
        }
    -> ( AM.Model, Cmd AM.Msg )
recontainToDepth model { id, fromPath, toPath, origPos, dropPos } =
    let
        srcMapId =
            getMapId fromPath

        tgtMapId =
            getMapId toPath
    in
    if srcMapId == tgtMapId then
        -- same container → just keep state; caller may have already updated pos via preview
        ( model, Cmd.none )

    else
        -- cross-container → delegate to existing app message
        let
            mk : Point -> AM.Msg
            mk p =
                AM.MoveTopicToMap id srcMapId origPos id toPath p
        in
        ( model, Random.generate mk (Random.constant dropPos) )


{-| TEMP: resolve an item's map path.
TODO: replace with a real lookup once available upstream/compat.
-}
mapPathOf : AM.Model -> Id -> MapPath
mapPathOf model _ =
    model.mapPath


{-| Converts a C.Depth to a MapPath.
Replace this stub with the actual conversion logic as needed.
-}
fromDepthToMapPath : C.Depth -> MapPath
fromDepthToMapPath depth =
    -- Implement the conversion logic here
    []
````

## File: src/Compat/ContractSmoke.elm
````elm
module Compat.ContractSmoke exposing (ok)

import Compat.FedWikiImport as CFWI
import Compat.ModelAPI as CMA
import Json.Decode as D


ok : Bool
ok =
    let
        _ =
            ( CFWI.importPage, CMA.getExt, CMA.setExt )
    in
    True
````

## File: src/IconMenu.elm
````elm
module IconMenu exposing (..)

import Model exposing (IconName)


type alias Model =
    { open : Bool }


init : Model
init =
    { open = False }


type Msg
    = Open
    | Close
    | SetIcon (Maybe IconName)
````

## File: src/SearchAPI.elm
````elm
module SearchAPI exposing (closeResultMenu, updateSearch, viewResultMenu, viewSearchInput)

import AppModel exposing (Model, Msg(..), UndoModel)
import Config exposing (contentFontSize, topicSize)
import Dict
import Html exposing (Attribute, Html, div, input, text)
import Html.Attributes exposing (attribute, style, value)
import Html.Events exposing (on, onFocus, onInput)
import Json.Decode as D
import Model exposing (Id, ItemInfo(..), MapId, MapProps(..))
import ModelAPI exposing (..)
import Search exposing (ResultMenu(..))
import Storage exposing (store)
import String exposing (fromInt)
import Utils exposing (idDecoder, info, logError, stopPropagationOnMousedown)



-- VIEW


viewSearchInput : Model -> Html Msg
viewSearchInput model =
    div
        []
        [ div
            []
            [ text "Search" ]
        , input
            ([ value model.search.text
             , onInput (Search << Search.Input)
             , onFocus (Search Search.FocusInput)
             ]
                ++ searchInputStyle
            )
            []
        ]


searchInputStyle : List (Attribute Msg)
searchInputStyle =
    [ style "width" "100px" ]


viewResultMenu : Model -> List (Html Msg)
viewResultMenu model =
    case ( model.search.menu, model.search.result |> List.isEmpty ) of
        ( Open _, False ) ->
            [ div
                ([ on "click" (itemDecoder Search.ClickItem)
                 , on "mouseover" (itemDecoder Search.HoverItem)
                 , on "mouseout" (itemDecoder Search.UnhoverItem)
                 , stopPropagationOnMousedown NoOp
                 ]
                    ++ resultMenuStyle
                )
                (model.search.result
                    |> List.map
                        (\id ->
                            case getTopicInfo id model of
                                Just topic ->
                                    div
                                        (attribute "data-id" (fromInt id)
                                            :: resultItemStyle id model
                                        )
                                        [ text topic.text ]

                                Nothing ->
                                    text "??"
                        )
                )
            ]

        _ ->
            []


itemDecoder : (Id -> Search.Msg) -> D.Decoder Msg
itemDecoder msg =
    D.map Search <| D.map msg idDecoder


resultMenuStyle : List (Attribute Msg)
resultMenuStyle =
    [ style "position" "absolute"
    , style "top" "144px"
    , style "width" "240px"
    , style "padding" "3px 0"
    , style "font-size" <| fromInt contentFontSize ++ "px"
    , style "line-height" "2"
    , style "white-space" "nowrap"
    , style "background-color" "white"
    , style "border" "1px solid lightgray"
    , style "z-index" "2"
    ]


resultItemStyle : Id -> Model -> List (Attribute Msg)
resultItemStyle topicId model =
    let
        isHover =
            case model.search.menu of
                Open maybeId ->
                    maybeId == Just topicId

                Closed ->
                    False
    in
    [ style "color"
        (if isHover then
            "white"

         else
            "black"
        )
    , style "background-color"
        (if isHover then
            "black"

         else
            "white"
        )
    , style "overflow" "hidden"
    , style "text-overflow" "ellipsis"
    , style "padding" "0 8px"
    ]



-- UPDATE


updateSearch : Search.Msg -> UndoModel -> ( UndoModel, Cmd Msg )
updateSearch msg ({ present } as undoModel) =
    case msg of
        Search.Input text ->
            ( onTextInput text present, Cmd.none ) |> swap undoModel

        Search.FocusInput ->
            ( onFocusInput present, Cmd.none ) |> swap undoModel

        Search.HoverItem topicId ->
            ( onHoverItem topicId present, Cmd.none ) |> swap undoModel

        Search.UnhoverItem _ ->
            ( onUnhoverItem present, Cmd.none ) |> swap undoModel

        Search.ClickItem topicId ->
            present
                |> revealTopic topicId (activeMap present)
                |> closeResultMenu
                |> store
                |> push undoModel


onTextInput : String -> Model -> Model
onTextInput text ({ search } as model) =
    { model | search = { search | text = text } }
        |> searchTopics


onFocusInput : Model -> Model
onFocusInput ({ search } as model) =
    { model | search = { search | menu = Open Nothing } }


onHoverItem : Id -> Model -> Model
onHoverItem topicId ({ search } as model) =
    case model.search.menu of
        Open _ ->
            -- update hovered topic
            { model | search = { search | menu = Open (Just topicId) } }

        Closed ->
            logError "onHoverItem"
                "Received \"HoverItem\" message when search.menu is Closed"
                model


onUnhoverItem : Model -> Model
onUnhoverItem ({ search } as model) =
    case model.search.menu of
        Open _ ->
            -- update hovered topic
            { model | search = { search | menu = Open Nothing } }

        Closed ->
            logError "onUnhoverItem"
                "Received \"UnhoverItem\" message when search.menu is Closed"
                model


searchTopics : Model -> Model
searchTopics ({ search } as model) =
    { model
        | search =
            { search
                | result =
                    model.items
                        |> Dict.foldr
                            (\id item topicIds ->
                                case item.info of
                                    Topic { text } ->
                                        if isMatch model.search.text text then
                                            id :: topicIds

                                        else
                                            topicIds

                                    Assoc _ ->
                                        topicIds
                            )
                            []
                , menu = Open Nothing
            }
    }


isMatch : String -> String -> Bool
isMatch searchText text =
    not (searchText |> String.isEmpty)
        && String.contains (String.toLower searchText) (String.toLower text)


revealTopic : Id -> MapId -> Model -> Model
revealTopic topicId mapId model =
    if isItemInMap topicId mapId model then
        let
            _ =
                info "revealTopic" ( topicId, "set visible" )
        in
        showItem topicId mapId model

    else
        let
            _ =
                info "revealTopic" ( topicId, "add to map" )

            props =
                MapTopic <| defaultProps topicId topicSize model
        in
        addItemToMap topicId props mapId model


closeResultMenu : Model -> Model
closeResultMenu ({ search } as model) =
    { model | search = { search | menu = Closed } }
````

## File: src/Toolbar.elm
````elm
module Toolbar exposing (viewToolbar)

-- components

import AppModel exposing (Model, Msg(..), UndoModel)
import Config exposing (date, footerFontSize, homeMapName, mainFont, toolbarFontSize, version)
import Html exposing (Attribute, Html, a, button, div, input, label, span, text)
import Html.Attributes exposing (checked, disabled, href, name, style, type_)
import Html.Events exposing (onClick)
import IconMenu
import IconMenuAPI exposing (viewIcon)
import Model
    exposing
        ( ContainerDisplay(..)
        , DisplayMode(..)
        , EditMsg(..)
        , MonadDisplay(..)
        , NavMsg(..)
        )
import ModelAPI
    exposing
        ( activeMap
        , getDisplayMode
        , getMapId
        , getSingleSelection
        , getTopicInfo
        , getTopicLabel
        , isHome
        )
import SearchAPI exposing (viewSearchInput)
import String exposing (fromInt)
import UndoList
import Utils exposing (info, stopPropagationOnMousedown)



-- VIEW


viewToolbar : UndoModel -> Html Msg
viewToolbar ({ present } as undoModel) =
    let
        _ =
            info "viewToolbar" [ UndoList.lengthPast undoModel, UndoList.lengthFuture undoModel ]
    in
    div
        toolbarStyle
        [ viewMapNav present
        , viewSearchInput present
        , viewToolbarButton "Add Topic" AddTopic always undoModel
        , viewToolbarButton "Edit" (Edit EditStart) hasSelection undoModel
        , viewToolbarButton "Choose Icon" (IconMenu IconMenu.Open) hasSelection undoModel
        , viewMonadDisplay present
        , viewContainerDisplay present
        , viewToolbarButton "Hide" Hide hasSelection undoModel
        , viewToolbarButton "Fullscreen" (Nav Fullscreen) hasSelection undoModel
        , viewToolbarButton "Delete" Delete hasSelection undoModel
        , div
            []
            [ viewToolbarButton "Undo" Undo hasPast undoModel
            , viewToolbarButton "Redo" Redo hasFuture undoModel
            ]
        , div
            []
            [ viewToolbarButton "Import" Import always undoModel
            , viewToolbarButton "Export" Export always undoModel
            ]
        , viewFooter
        ]


toolbarStyle : List (Attribute Msg)
toolbarStyle =
    [ style "font-size" <| fromInt toolbarFontSize ++ "px"
    , style "display" "flex"
    , style "flex-direction" "column"
    , style "align-items" "flex-start"
    , style "gap" "20px"
    , style "position" "fixed"
    , style "z-index" "1"
    ]


viewMapNav : Model -> Html Msg
viewMapNav model =
    let
        backDisabled =
            isHome model
    in
    div
        mapNavStyle
        [ button
            [ onClick (Nav Back)
            , disabled backDisabled
            ]
            [ viewIcon "arrow-left" 20 ]
        , span
            mapTitleStyle
            [ text <| getMapName model ]
        ]


mapNavStyle : List (Attribute Msg)
mapNavStyle =
    [ style "margin-top" "20px"
    , style "margin-bottom" "12px"
    ]


mapTitleStyle : List (Attribute Msg)
mapTitleStyle =
    [ style "font-size" "36px"
    , style "font-weight" "bold"
    , style "vertical-align" "top"
    , style "margin-left" "12px"
    ]


getMapName : Model -> String
getMapName model =
    if isHome model then
        -- home map has no corresponding topic
        homeMapName

    else
        case getTopicInfo (activeMap model) model of
            Just topic ->
                getTopicLabel topic

            Nothing ->
                "??"


viewToolbarButton : String -> Msg -> (UndoModel -> Bool) -> UndoModel -> Html Msg
viewToolbarButton label msg isEnabled undoModel =
    let
        buttonAttr =
            [ stopPropagationOnMousedown NoOp
            , disabled <| not <| isEnabled undoModel
            ]
    in
    button
        ([ onClick msg ]
            ++ buttonAttr
            ++ buttonStyle
        )
        [ text label ]


{-| isEnabled predicate
-}
hasSelection : UndoModel -> Bool
hasSelection undoModel =
    not (undoModel.present.selection |> List.isEmpty)


{-| isEnabled predicate
-}
hasPast : UndoModel -> Bool
hasPast undoModel =
    undoModel |> UndoList.hasPast


{-| isEnabled predicate
-}
hasFuture : UndoModel -> Bool
hasFuture undoModel =
    undoModel |> UndoList.hasFuture


{-| isEnabled predicate
-}
always : UndoModel -> Bool
always _ =
    True


buttonStyle : List (Attribute Msg)
buttonStyle =
    [ style "font-family" mainFont
    , style "font-size" <| fromInt toolbarFontSize ++ "px"
    ]


viewMonadDisplay : Model -> Html Msg
viewMonadDisplay model =
    let
        displayMode =
            case getSingleSelection model of
                Just ( topicId, mapPath ) ->
                    getDisplayMode topicId (getMapId mapPath) model.maps

                Nothing ->
                    Nothing

        ( checked1, checked2, disabled_ ) =
            case displayMode of
                Just (Monad LabelOnly) ->
                    ( True, False, False )

                Just (Monad Detail) ->
                    ( False, True, False )

                _ ->
                    ( False, False, True )
    in
    div
        (displayModeStyle disabled_)
        [ div
            []
            [ text "Monad Display" ]
        , viewRadioButton "Label Only" (SwitchDisplay <| Monad LabelOnly) checked1 disabled_
        , viewRadioButton "Detail" (SwitchDisplay <| Monad Detail) checked2 disabled_
        ]


viewContainerDisplay : Model -> Html Msg
viewContainerDisplay model =
    let
        displayMode =
            case getSingleSelection model of
                Just ( topicId, mapPath ) ->
                    getDisplayMode topicId (getMapId mapPath) model.maps

                Nothing ->
                    Nothing

        ( checked1, checked2, checked3 ) =
            case displayMode of
                Just (Container BlackBox) ->
                    ( True, False, False )

                Just (Container WhiteBox) ->
                    ( False, True, False )

                Just (Container Unboxed) ->
                    ( False, False, True )

                _ ->
                    ( False, False, False )

        disabled_ =
            case displayMode of
                Just (Container _) ->
                    False

                _ ->
                    True
    in
    div
        (displayModeStyle disabled_)
        [ div
            []
            [ text "Container Display" ]
        , viewRadioButton "Black Box" (SwitchDisplay <| Container BlackBox) checked1 disabled_
        , viewRadioButton "White Box" (SwitchDisplay <| Container WhiteBox) checked2 disabled_
        , viewRadioButton "Unboxed" (SwitchDisplay <| Container Unboxed) checked3 disabled_
        ]


displayModeStyle : Bool -> List (Attribute Msg)
displayModeStyle disabled =
    let
        ( color, pointerEvents ) =
            if disabled then
                ( "gray", "none" )

            else
                ( "unset", "unset" )
    in
    [ style "display" "flex"
    , style "flex-direction" "column"
    , style "gap" "6px"
    , style "color" color
    , style "pointer-events" pointerEvents
    ]


viewRadioButton : String -> Msg -> Bool -> Bool -> Html Msg
viewRadioButton label_ msg isChecked isDisabled =
    label
        [ stopPropagationOnMousedown NoOp ]
        [ input
            [ type_ "radio"
            , name "display-mode"
            , checked isChecked
            , disabled isDisabled
            , onClick msg
            ]
            []
        , text label_
        ]


viewFooter : Html Msg
viewFooter =
    div
        footerStyle
        [ div
            []
            [ text version ]
        , div
            []
            [ text date ]
        , div
            []
            [ text "Source: "
            , a
                ([ href "https://github.com/dmx-systems/dm6-elm" ]
                    ++ linkStyle
                )
                [ text "GitHub" ]
            ]
        , a
            ([ href "https://dmx.berlin" ]
                ++ linkStyle
            )
            [ text "DMX Systems" ]
        ]


footerStyle : List (Attribute Msg)
footerStyle =
    [ style "font-size" <| fromInt footerFontSize ++ "px"
    , style "color" "lightgray"
    ]


linkStyle : List (Attribute Msg)
linkStyle =
    [ style "color" "lightgray" ]
````

## File: src/Utils.elm
````elm
module Utils exposing (..)

import Html exposing (Attribute, Html, br, text)
import Html.Events exposing (keyCode, on, stopPropagationOn)
import Json.Decode as D
import Logger
import Model exposing (Class, Id, MapPath, Point)



-- Events


onEsc : msg -> Attribute msg
onEsc msg_ =
    on "keydown" (keyDecoder 27 msg_)


onEnterOrEsc : msg -> Attribute msg
onEnterOrEsc msg_ =
    on "keydown"
        (D.oneOf
            [ keyDecoder 13 msg_
            , keyDecoder 27 msg_
            ]
        )


keyDecoder : Int -> msg -> D.Decoder msg
keyDecoder key msg_ =
    let
        isKey code =
            if code == key then
                D.succeed msg_

            else
                D.fail "not that key"
    in
    keyCode |> D.andThen isKey


stopPropagationOnMousedown : msg -> Attribute msg
stopPropagationOnMousedown msg_ =
    stopPropagationOn "mousedown" <| D.succeed ( msg_, True )



-- Decoder


classDecoder : D.Decoder Class
classDecoder =
    D.oneOf
        [ D.at [ "target", "className" ] D.string -- HTML elements
        , D.at [ "target", "className", "baseVal" ] D.string -- SVG elements
        ]


idDecoder : D.Decoder Id
idDecoder =
    D.at [ "target", "dataset", "id" ] D.string
        |> D.andThen toIntDecoder


pathDecoder : D.Decoder MapPath
pathDecoder =
    D.at [ "target", "dataset", "path" ] D.string
        |> D.andThen toIntListDecoder


pointDecoder : D.Decoder Point
pointDecoder =
    D.map2 Point
        (D.field "clientX" D.float)
        (D.field "clientY" D.float)


toIntDecoder : String -> D.Decoder Int
toIntDecoder str =
    case String.toInt str of
        Just int ->
            D.succeed int

        Nothing ->
            D.fail <| "\"" ++ str ++ "\" is not an Int"


sequenceDecoders : List (D.Decoder a) -> D.Decoder (List a)
sequenceDecoders =
    List.foldr (D.map2 (::)) (D.succeed [])


toIntListDecoder : String -> D.Decoder (List Int)
toIntListDecoder str =
    let
        parseOne s =
            case String.toInt (String.trim s) of
                Just n ->
                    D.succeed n

                Nothing ->
                    D.fail <| "\"" ++ s ++ "\" is not an Int"
    in
    str
        |> String.trim
        |> String.split ","
        |> List.filter (\s -> s /= "")
        |> List.map parseOne
        |> sequenceDecoders



-- HTML


multilineHtml : String -> List (Html msg)
multilineHtml str =
    String.lines str
        |> List.foldr
            (\line linesAcc ->
                [ text line, br [] [] ] ++ linesAcc
            )
            []



-- Debug


logError : String -> String -> v -> v
logError funcName text val =
    Logger.log ("### ERROR @" ++ funcName ++ ": " ++ text) val


fail : String -> a -> v -> v
fail funcName args val =
    Logger.log ("--> @" ++ funcName ++ " failed " ++ Logger.toString args) val


call : String -> a -> v -> v
call funcName args val =
    Logger.log ("@" ++ funcName ++ " " ++ Logger.toString args ++ " -->") val


info : String -> v -> v
info funcName val =
    Logger.log ("@" ++ funcName) val


toString : a -> String
toString =
    Logger.toString
````

## File: build-prod.sh
````bash
#!/bin/sh
set -euo pipefail

# --- paths & files ------------------------------------------------------------
js="main.js"
min="main.min.js"
template="public/index.html"           # HTML template containing <script src="main.js">
html="public/dm6-elm.html"      # final standalone output
tools_js_src="scripts/localstorage-tools.js"

log_dst="src/Logger.elm"
log_prod_src="src/Logger/Prod/Logger.elm"
log_dev_src="src/Logger/Dev/Logger.elm"   # must exist

# --- guards -------------------------------------------------------------------
in_git() { git rev-parse --is-inside-work-tree >/dev/null 2>&1; }
is_tracked() { git ls-files --error-unmatch "$1" >/dev/null 2>&1; }

if ! in_git; then
  echo "ERROR: build-prod.sh expects to run inside a git worktree." >&2
  exit 1
fi

[ -f "$log_prod_src" ] || { echo "ERROR: $log_prod_src missing." >&2; exit 1; }
[ -f "$log_dev_src" ]  || { echo "ERROR: $log_dev_src missing."  >&2; exit 1; }
[ -f "$template" ]     || { echo "ERROR: $template missing."     >&2; exit 1; }
command -v pnpm >/dev/null 2>&1 || { echo "ERROR: pnpm not found. Use the Nix devshell or run 'corepack enable'."; exit 1; }
pnpm exec uglifyjs --version >/dev/null 2>&1 || { echo "ERROR: uglify-js not found in devDependencies. Run: pnpm add -D uglify-js"; exit 1; }

# --- cleanup: restore tracked file via git; fallback to Dev copy ------------
cleanup() {
  set +e
  if in_git && is_tracked "$log_dst"; then
    git restore --worktree --staged -- "$log_dst" || git checkout -- "$log_dst"
  else
    # Fallback for non-git or untracked file: restore Dev variant and normalize header
    cp -f "$log_dev_src" "$log_dst"
    awk 'NR==1{
           if ($0 ~ /^module[[:space:]]+[^[:space:]]+[[:space:]]+exposing[[:space:]]*\(.*\)/) {
             sub(/^module[[:space:]]+[^[:space:]]+/, "module Logger")
           } else {
             $0 = "module Logger exposing (..)"
           }
         }1' "$log_dst" > "$log_dst.tmp" && mv "$log_dst.tmp" "$log_dst"
  fi
  set -e
}
trap cleanup EXIT


# --- put PROD logger in place -------------------------------------------------
cp -f "$log_prod_src" "$log_dst"

# Ensure module header matches file path: change only the module name, keep exposing list
awk 'NR==1 {
        # Cases:
        # 1) module Logger.Prod exposing (...)
        if ($0 ~ /^module[[:space:]]+Logger\.Prod[[:space:]]+exposing[[:space:]]*\(.*\)/) {
            sub(/^module[[:space:]]+Logger\.Prod/, "module Logger")
        }
        # 2) module <Anything> exposing (...)  -> rename to Logger, keep exposing list
        else if ($0 ~ /^module[[:space:]]+[^[:space:]]+[[:space:]]+exposing[[:space:]]*\(.*\)/) {
            sub(/^module[[:space:]]+[^[:space:]]+/, "module Logger")
        }
        # 3) Fallback: if header is weird/missing exposing, use (..)
        if ($0 !~ /^module[[:space:]]+Logger[[:space:]]+exposing[[:space:]]*\(.*\)/) {
            $0 = "module Logger exposing (..)"
        }
     } { print }' "$log_dst" > "$log_dst.tmp" && mv "$log_dst.tmp" "$log_dst"


# Back-compat alias (older code might import Logger.log explicitly)
grep -q '^log[[:space:]]*:' "$log_dst" 2>/dev/null || cat >> "$log_dst" <<'EOF'

-- Back-compat alias (older code imports `Logger.log`)
log : String -> a -> a
log =
    debug
EOF

# --- build & minify -----------------------------------------------------------
elm make src/AppMain.elm --optimize --output="$js"

pnpm exec uglifyjs "$js" \
  --compress "pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe" \
  | uglifyjs --mangle --output "$min"

echo "Initial size: $(wc -c < "$js") bytes ($js)"
echo "Minified size: $(wc -c < "$min") bytes ($min)"

# --- inline bundle into template ---------------------------------------------
tmp_js_escaped="$(mktemp)"
sed 's#</script>#<\\/script>#g' "$min" > "$tmp_js_escaped"

tmp_tools_escaped="$(mktemp)"
sed 's#</script>#<\\/script>#g' "$tools_js_src" > "$tmp_tools_escaped"

awk -v jsfile="$tmp_js_escaped" -v toolsfile="$tmp_tools_escaped" '
  BEGIN {
    while ((getline l < jsfile)    > 0) js = js l ORS;     close(jsfile)
    while ((getline t < toolsfile) > 0) tools = tools t ORS; close(toolsfile)
  }
  {
    if ($0 ~ /<script[[:space:]]+src=["'\''"]main\.js["'\''"][^>]*><\/script>[[:space:]]*$/ \
     || $0 ~ /<script[[:space:]]+src=["'\''"]main\.js["'\''"][^>]*>[[:space:]]*$/) {
      print "  <script>"
      printf "%s", js
      print "  </script>"
      replaced = 1
      next
    }

    if ($0 ~ /<\/body>/ && !injected) {
      print "  <div id=\"dm6-dev-tools\""
      print "       style=\"position:fixed;bottom:10px;right:10px;"
      print "              display:flex;gap:.5em;z-index:9999;"
      print "              background:#fff;border:1px solid #ddd;border-radius:8px;"
      print "              padding:.4em .6em;box-shadow:0 2px 10px rgba(0,0,0,.08);\">"
      print "    <button type=\"button\" onclick='\''exportLS()'\'' title=\"Export model\">⤓ Export</button>"
      print "    <button type=\"button\" onclick='\''importLSFile()'\'' title=\"Import model\">📂 Import</button>"
      print "  </div>"
      print "  <script>"
      printf "%s", tools
      print "  </script>"

      # Subscribe to Logger port if present (safe no-op otherwise)
      print "  <script>"
      print "    (function(){"
      print "      try {"
      print "        if (window.app && window.app.ports && window.app.ports.log && window.app.ports.log.subscribe) {"
      print "          window.app.ports.log.subscribe(function(line){ console.log(line); });"
      print "        }"
      print "      } catch (e) { /* ignore */ }"
      print "    })();"
      print "  </script>"

      injected = 1
      print
      next
    }

    print
  }
  END {
    if (!replaced)  { print "ERROR: Could not find <script src=\"main.js\"> in template to inline." > "/dev/stderr"; exit 42 }
    if (!injected)  { print "ERROR: Could not inject tools (no </body> seen)." > "/dev/stderr"; exit 43 }
  }
' "$template" > "$html"

rm -f "$tmp_js_escaped" "$tmp_tools_escaped"

grep -q "</script>" "$html" || { echo "ERROR: Missing </script> in $html" >&2; exit 1; }
printf "Standalone written to: %s\n" "$html"
printf "Size: %s bytes (gzipped: %s bytes)\n" "$(wc -c < "$html")" "$(gzip -c "$html" | wc -c)"

# --- open in browser ----------------------------------------------------------
if command -v open >/dev/null 2>&1; then
  open "$html"
elif command -v xdg-open >/dev/null 2>&1; then
  xdg-open "$html"
else
  echo "Open $html manually in your browser."
fi
````

## File: public/index.html
````html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>DM6 Elm</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <!-- silence 404 favicon -->
    <link rel="icon" href="data:,">
    <style>
      html, body { height: 100%; margin: 0; }
      body { font-family: system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, sans-serif;
             user-select: none; -webkit-user-select: none; }
    </style>
  </head>
  <body>
    <noscript>This app requires JavaScript.</noscript>

    <!-- 1) load bundle -->
    <script src="main.js"></script>

    <!-- 2) init AFTER window 'load' -->
    <script>
      (function () {
        function init() {
          if (!window.Elm) {
            console.error('Elm bundle not loaded. window.Elm =', window.Elm);
            return;
          }
          var Boot = (Elm.AppMain || Elm.Main);
          if (!Boot) {
            console.error('No Elm root found. Keys:', Object.keys(Elm));
            return;
          }

          var flags = null;
          try {
            var raw = localStorage.getItem('dm6-elm');
            flags = raw ? JSON.parse(raw) : null;
          } catch (_) {}

          try {
            window.app = Boot.init({ flags: flags });
          } catch (e) {
            try { window.app = Boot.init(); }
            catch (e2) { console.error('Failed to init Elm app', e2); }
          }
          // optional legacy alias
          window._dm6 = window.app;
        }

        if (document.readyState === 'complete') init();
        else window.addEventListener('load', init);
      })();
    </script>
    <script>
      // Dev-only: make the Elm debugger overlay always visible and on top.
      if (location.hostname === 'localhost') {
        (function ensureElmDebuggerOnTop() {
          function promote() {
            var ov = document.querySelector('.elm-overlay');
            if (!ov) return;
            // Move overlay to <body> to escape transformed/overflow parents
            if (ov.parentNode !== document.body) {
              document.body.appendChild(ov);
            }
            // Force on-top & clickable
            ov.style.position = 'fixed';
            ov.style.zIndex = '2147483647';
            ov.style.pointerEvents = 'auto';
            // Avoid accidental clipping
            ov.style.inset = 'auto'; // keep default positions
          }

          // Try now and on future DOM changes (Elm hot reload, route changes, etc.)
          var mo = new MutationObserver(promote);
          mo.observe(document.documentElement, { childList: true, subtree: true });
          // Also re-run after load
          if (document.readyState === 'complete') promote();
          else window.addEventListener('load', promote);
        })();
      }
    </script>
  </body>
</html>
````

## File: src/Compat/CoreModel.elm
````elm
module Compat.CoreModel exposing
    ( CoreModel
    , empty
    , fromAppModel
    , toAppModel
    )

import AppModel as AM
import Compat.Display as CDisp
import Defaults as Def
import Dict
import Model exposing (..)



-- Minimal persistent model, independent of AppModel/UI.


type alias CoreModel =
    { items : Items
    , maps : Maps
    , mapPath : List MapId
    , nextId : Id
    }


empty : CoreModel
empty =
    { items = Dict.empty
    , maps = Dict.empty
    , mapPath = [ 0 ]
    , nextId = 1
    }



-- Project just the persistent bits from the full app model.


fromAppModel : AM.Model -> CoreModel
fromAppModel m =
    { items = m.items
    , maps = m.maps
    , mapPath = m.mapPath
    , nextId = m.nextId
    }



-- Lift a CoreModel into the full app model for rendering/storage.
-- Transient/UI fields are taken from AM.default.


toAppModel : { items : Items, maps : Maps, mapPath : MapPath, nextId : Id } -> AM.Model
toAppModel c =
    { items = c.items
    , maps = c.maps
    , mapPath = c.mapPath
    , nextId = c.nextId
    , selection = Def.selection
    , editState = Def.editState
    , measureText = Def.measureText
    , mouse = Def.mouse
    , search = Def.search
    , iconMenu = Def.iconMenu
    , display = CDisp.default
    , fedWikiRaw = "" -- or whatever raw you want to seed with
    , fedWiki =
        { storyItemIds = []
        , containerId = Nothing
        }
    }
````

## File: index.html
````html
<!DOCTYPE HTML>
<html>
<head>
  <meta charset="UTF-8">
  <title>Main</title>
  <style>body { padding: 0; margin: 0; }</style>
</head>

<body>

<pre id="elm"></pre>

<script>
try {
(function(scope){
'use strict';

function F(arity, fun, wrapper) {
  wrapper.a = arity;
  wrapper.f = fun;
  return wrapper;
}

function F2(fun) {
  return F(2, fun, function(a) { return function(b) { return fun(a,b); }; })
}
function F3(fun) {
  return F(3, fun, function(a) {
    return function(b) { return function(c) { return fun(a, b, c); }; };
  });
}
function F4(fun) {
  return F(4, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return fun(a, b, c, d); }; }; };
  });
}
function F5(fun) {
  return F(5, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return fun(a, b, c, d, e); }; }; }; };
  });
}
function F6(fun) {
  return F(6, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return fun(a, b, c, d, e, f); }; }; }; }; };
  });
}
function F7(fun) {
  return F(7, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return fun(a, b, c, d, e, f, g); }; }; }; }; }; };
  });
}
function F8(fun) {
  return F(8, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) {
    return fun(a, b, c, d, e, f, g, h); }; }; }; }; }; }; };
  });
}
function F9(fun) {
  return F(9, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) { return function(i) {
    return fun(a, b, c, d, e, f, g, h, i); }; }; }; }; }; }; }; };
  });
}

function A2(fun, a, b) {
  return fun.a === 2 ? fun.f(a, b) : fun(a)(b);
}
function A3(fun, a, b, c) {
  return fun.a === 3 ? fun.f(a, b, c) : fun(a)(b)(c);
}
function A4(fun, a, b, c, d) {
  return fun.a === 4 ? fun.f(a, b, c, d) : fun(a)(b)(c)(d);
}
function A5(fun, a, b, c, d, e) {
  return fun.a === 5 ? fun.f(a, b, c, d, e) : fun(a)(b)(c)(d)(e);
}
function A6(fun, a, b, c, d, e, f) {
  return fun.a === 6 ? fun.f(a, b, c, d, e, f) : fun(a)(b)(c)(d)(e)(f);
}
function A7(fun, a, b, c, d, e, f, g) {
  return fun.a === 7 ? fun.f(a, b, c, d, e, f, g) : fun(a)(b)(c)(d)(e)(f)(g);
}
function A8(fun, a, b, c, d, e, f, g, h) {
  return fun.a === 8 ? fun.f(a, b, c, d, e, f, g, h) : fun(a)(b)(c)(d)(e)(f)(g)(h);
}
function A9(fun, a, b, c, d, e, f, g, h, i) {
  return fun.a === 9 ? fun.f(a, b, c, d, e, f, g, h, i) : fun(a)(b)(c)(d)(e)(f)(g)(h)(i);
}

console.warn('Compiled in DEV mode. Follow the advice at https://elm-lang.org/0.19.1/optimize for better performance and smaller assets.');


// EQUALITY

function _Utils_eq(x, y)
{
	for (
		var pair, stack = [], isEqual = _Utils_eqHelp(x, y, 0, stack);
		isEqual && (pair = stack.pop());
		isEqual = _Utils_eqHelp(pair.a, pair.b, 0, stack)
		)
	{}

	return isEqual;
}

function _Utils_eqHelp(x, y, depth, stack)
{
	if (x === y)
	{
		return true;
	}

	if (typeof x !== 'object' || x === null || y === null)
	{
		typeof x === 'function' && _Debug_crash(5);
		return false;
	}

	if (depth > 100)
	{
		stack.push(_Utils_Tuple2(x,y));
		return true;
	}

	/**/
	if (x.$ === 'Set_elm_builtin')
	{
		x = $elm$core$Set$toList(x);
		y = $elm$core$Set$toList(y);
	}
	if (x.$ === 'RBNode_elm_builtin' || x.$ === 'RBEmpty_elm_builtin')
	{
		x = $elm$core$Dict$toList(x);
		y = $elm$core$Dict$toList(y);
	}
	//*/

	/**_UNUSED/
	if (x.$ < 0)
	{
		x = $elm$core$Dict$toList(x);
		y = $elm$core$Dict$toList(y);
	}
	//*/

	for (var key in x)
	{
		if (!_Utils_eqHelp(x[key], y[key], depth + 1, stack))
		{
			return false;
		}
	}
	return true;
}

var _Utils_equal = F2(_Utils_eq);
var _Utils_notEqual = F2(function(a, b) { return !_Utils_eq(a,b); });



// COMPARISONS

// Code in Generate/JavaScript.hs, Basics.js, and List.js depends on
// the particular integer values assigned to LT, EQ, and GT.

function _Utils_cmp(x, y, ord)
{
	if (typeof x !== 'object')
	{
		return x === y ? /*EQ*/ 0 : x < y ? /*LT*/ -1 : /*GT*/ 1;
	}

	/**/
	if (x instanceof String)
	{
		var a = x.valueOf();
		var b = y.valueOf();
		return a === b ? 0 : a < b ? -1 : 1;
	}
	//*/

	/**_UNUSED/
	if (typeof x.$ === 'undefined')
	//*/
	/**/
	if (x.$[0] === '#')
	//*/
	{
		return (ord = _Utils_cmp(x.a, y.a))
			? ord
			: (ord = _Utils_cmp(x.b, y.b))
				? ord
				: _Utils_cmp(x.c, y.c);
	}

	// traverse conses until end of a list or a mismatch
	for (; x.b && y.b && !(ord = _Utils_cmp(x.a, y.a)); x = x.b, y = y.b) {} // WHILE_CONSES
	return ord || (x.b ? /*GT*/ 1 : y.b ? /*LT*/ -1 : /*EQ*/ 0);
}

var _Utils_lt = F2(function(a, b) { return _Utils_cmp(a, b) < 0; });
var _Utils_le = F2(function(a, b) { return _Utils_cmp(a, b) < 1; });
var _Utils_gt = F2(function(a, b) { return _Utils_cmp(a, b) > 0; });
var _Utils_ge = F2(function(a, b) { return _Utils_cmp(a, b) >= 0; });

var _Utils_compare = F2(function(x, y)
{
	var n = _Utils_cmp(x, y);
	return n < 0 ? $elm$core$Basics$LT : n ? $elm$core$Basics$GT : $elm$core$Basics$EQ;
});


// COMMON VALUES

var _Utils_Tuple0_UNUSED = 0;
var _Utils_Tuple0 = { $: '#0' };

function _Utils_Tuple2_UNUSED(a, b) { return { a: a, b: b }; }
function _Utils_Tuple2(a, b) { return { $: '#2', a: a, b: b }; }

function _Utils_Tuple3_UNUSED(a, b, c) { return { a: a, b: b, c: c }; }
function _Utils_Tuple3(a, b, c) { return { $: '#3', a: a, b: b, c: c }; }

function _Utils_chr_UNUSED(c) { return c; }
function _Utils_chr(c) { return new String(c); }


// RECORDS

function _Utils_update(oldRecord, updatedFields)
{
	var newRecord = {};

	for (var key in oldRecord)
	{
		newRecord[key] = oldRecord[key];
	}

	for (var key in updatedFields)
	{
		newRecord[key] = updatedFields[key];
	}

	return newRecord;
}


// APPEND

var _Utils_append = F2(_Utils_ap);

function _Utils_ap(xs, ys)
{
	// append Strings
	if (typeof xs === 'string')
	{
		return xs + ys;
	}

	// append Lists
	if (!xs.b)
	{
		return ys;
	}
	var root = _List_Cons(xs.a, ys);
	xs = xs.b
	for (var curr = root; xs.b; xs = xs.b) // WHILE_CONS
	{
		curr = curr.b = _List_Cons(xs.a, ys);
	}
	return root;
}



var _List_Nil_UNUSED = { $: 0 };
var _List_Nil = { $: '[]' };

function _List_Cons_UNUSED(hd, tl) { return { $: 1, a: hd, b: tl }; }
function _List_Cons(hd, tl) { return { $: '::', a: hd, b: tl }; }


var _List_cons = F2(_List_Cons);

function _List_fromArray(arr)
{
	var out = _List_Nil;
	for (var i = arr.length; i--; )
	{
		out = _List_Cons(arr[i], out);
	}
	return out;
}

function _List_toArray(xs)
{
	for (var out = []; xs.b; xs = xs.b) // WHILE_CONS
	{
		out.push(xs.a);
	}
	return out;
}

var _List_map2 = F3(function(f, xs, ys)
{
	for (var arr = []; xs.b && ys.b; xs = xs.b, ys = ys.b) // WHILE_CONSES
	{
		arr.push(A2(f, xs.a, ys.a));
	}
	return _List_fromArray(arr);
});

var _List_map3 = F4(function(f, xs, ys, zs)
{
	for (var arr = []; xs.b && ys.b && zs.b; xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A3(f, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_map4 = F5(function(f, ws, xs, ys, zs)
{
	for (var arr = []; ws.b && xs.b && ys.b && zs.b; ws = ws.b, xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A4(f, ws.a, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_map5 = F6(function(f, vs, ws, xs, ys, zs)
{
	for (var arr = []; vs.b && ws.b && xs.b && ys.b && zs.b; vs = vs.b, ws = ws.b, xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A5(f, vs.a, ws.a, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_sortBy = F2(function(f, xs)
{
	return _List_fromArray(_List_toArray(xs).sort(function(a, b) {
		return _Utils_cmp(f(a), f(b));
	}));
});

var _List_sortWith = F2(function(f, xs)
{
	return _List_fromArray(_List_toArray(xs).sort(function(a, b) {
		var ord = A2(f, a, b);
		return ord === $elm$core$Basics$EQ ? 0 : ord === $elm$core$Basics$LT ? -1 : 1;
	}));
});



var _JsArray_empty = [];

function _JsArray_singleton(value)
{
    return [value];
}

function _JsArray_length(array)
{
    return array.length;
}

var _JsArray_initialize = F3(function(size, offset, func)
{
    var result = new Array(size);

    for (var i = 0; i < size; i++)
    {
        result[i] = func(offset + i);
    }

    return result;
});

var _JsArray_initializeFromList = F2(function (max, ls)
{
    var result = new Array(max);

    for (var i = 0; i < max && ls.b; i++)
    {
        result[i] = ls.a;
        ls = ls.b;
    }

    result.length = i;
    return _Utils_Tuple2(result, ls);
});

var _JsArray_unsafeGet = F2(function(index, array)
{
    return array[index];
});

var _JsArray_unsafeSet = F3(function(index, value, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = array[i];
    }

    result[index] = value;
    return result;
});

var _JsArray_push = F2(function(value, array)
{
    var length = array.length;
    var result = new Array(length + 1);

    for (var i = 0; i < length; i++)
    {
        result[i] = array[i];
    }

    result[length] = value;
    return result;
});

var _JsArray_foldl = F3(function(func, acc, array)
{
    var length = array.length;

    for (var i = 0; i < length; i++)
    {
        acc = A2(func, array[i], acc);
    }

    return acc;
});

var _JsArray_foldr = F3(function(func, acc, array)
{
    for (var i = array.length - 1; i >= 0; i--)
    {
        acc = A2(func, array[i], acc);
    }

    return acc;
});

var _JsArray_map = F2(function(func, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = func(array[i]);
    }

    return result;
});

var _JsArray_indexedMap = F3(function(func, offset, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = A2(func, offset + i, array[i]);
    }

    return result;
});

var _JsArray_slice = F3(function(from, to, array)
{
    return array.slice(from, to);
});

var _JsArray_appendN = F3(function(n, dest, source)
{
    var destLen = dest.length;
    var itemsToCopy = n - destLen;

    if (itemsToCopy > source.length)
    {
        itemsToCopy = source.length;
    }

    var size = destLen + itemsToCopy;
    var result = new Array(size);

    for (var i = 0; i < destLen; i++)
    {
        result[i] = dest[i];
    }

    for (var i = 0; i < itemsToCopy; i++)
    {
        result[i + destLen] = source[i];
    }

    return result;
});



// LOG

var _Debug_log_UNUSED = F2(function(tag, value)
{
	return value;
});

var _Debug_log = F2(function(tag, value)
{
	console.log(tag + ': ' + _Debug_toString(value));
	return value;
});


// TODOS

function _Debug_todo(moduleName, region)
{
	return function(message) {
		_Debug_crash(8, moduleName, region, message);
	};
}

function _Debug_todoCase(moduleName, region, value)
{
	return function(message) {
		_Debug_crash(9, moduleName, region, value, message);
	};
}


// TO STRING

function _Debug_toString_UNUSED(value)
{
	return '<internals>';
}

function _Debug_toString(value)
{
	return _Debug_toAnsiString(false, value);
}

function _Debug_toAnsiString(ansi, value)
{
	if (typeof value === 'function')
	{
		return _Debug_internalColor(ansi, '<function>');
	}

	if (typeof value === 'boolean')
	{
		return _Debug_ctorColor(ansi, value ? 'True' : 'False');
	}

	if (typeof value === 'number')
	{
		return _Debug_numberColor(ansi, value + '');
	}

	if (value instanceof String)
	{
		return _Debug_charColor(ansi, "'" + _Debug_addSlashes(value, true) + "'");
	}

	if (typeof value === 'string')
	{
		return _Debug_stringColor(ansi, '"' + _Debug_addSlashes(value, false) + '"');
	}

	if (typeof value === 'object' && '$' in value)
	{
		var tag = value.$;

		if (typeof tag === 'number')
		{
			return _Debug_internalColor(ansi, '<internals>');
		}

		if (tag[0] === '#')
		{
			var output = [];
			for (var k in value)
			{
				if (k === '$') continue;
				output.push(_Debug_toAnsiString(ansi, value[k]));
			}
			return '(' + output.join(',') + ')';
		}

		if (tag === 'Set_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Set')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Set$toList(value));
		}

		if (tag === 'RBNode_elm_builtin' || tag === 'RBEmpty_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Dict')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Dict$toList(value));
		}

		if (tag === 'Array_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Array')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Array$toList(value));
		}

		if (tag === '::' || tag === '[]')
		{
			var output = '[';

			value.b && (output += _Debug_toAnsiString(ansi, value.a), value = value.b)

			for (; value.b; value = value.b) // WHILE_CONS
			{
				output += ',' + _Debug_toAnsiString(ansi, value.a);
			}
			return output + ']';
		}

		var output = '';
		for (var i in value)
		{
			if (i === '$') continue;
			var str = _Debug_toAnsiString(ansi, value[i]);
			var c0 = str[0];
			var parenless = c0 === '{' || c0 === '(' || c0 === '[' || c0 === '<' || c0 === '"' || str.indexOf(' ') < 0;
			output += ' ' + (parenless ? str : '(' + str + ')');
		}
		return _Debug_ctorColor(ansi, tag) + output;
	}

	if (typeof DataView === 'function' && value instanceof DataView)
	{
		return _Debug_stringColor(ansi, '<' + value.byteLength + ' bytes>');
	}

	if (typeof File !== 'undefined' && value instanceof File)
	{
		return _Debug_internalColor(ansi, '<' + value.name + '>');
	}

	if (typeof value === 'object')
	{
		var output = [];
		for (var key in value)
		{
			var field = key[0] === '_' ? key.slice(1) : key;
			output.push(_Debug_fadeColor(ansi, field) + ' = ' + _Debug_toAnsiString(ansi, value[key]));
		}
		if (output.length === 0)
		{
			return '{}';
		}
		return '{ ' + output.join(', ') + ' }';
	}

	return _Debug_internalColor(ansi, '<internals>');
}

function _Debug_addSlashes(str, isChar)
{
	var s = str
		.replace(/\\/g, '\\\\')
		.replace(/\n/g, '\\n')
		.replace(/\t/g, '\\t')
		.replace(/\r/g, '\\r')
		.replace(/\v/g, '\\v')
		.replace(/\0/g, '\\0');

	if (isChar)
	{
		return s.replace(/\'/g, '\\\'');
	}
	else
	{
		return s.replace(/\"/g, '\\"');
	}
}

function _Debug_ctorColor(ansi, string)
{
	return ansi ? '\x1b[96m' + string + '\x1b[0m' : string;
}

function _Debug_numberColor(ansi, string)
{
	return ansi ? '\x1b[95m' + string + '\x1b[0m' : string;
}

function _Debug_stringColor(ansi, string)
{
	return ansi ? '\x1b[93m' + string + '\x1b[0m' : string;
}

function _Debug_charColor(ansi, string)
{
	return ansi ? '\x1b[92m' + string + '\x1b[0m' : string;
}

function _Debug_fadeColor(ansi, string)
{
	return ansi ? '\x1b[37m' + string + '\x1b[0m' : string;
}

function _Debug_internalColor(ansi, string)
{
	return ansi ? '\x1b[36m' + string + '\x1b[0m' : string;
}

function _Debug_toHexDigit(n)
{
	return String.fromCharCode(n < 10 ? 48 + n : 55 + n);
}


// CRASH


function _Debug_crash_UNUSED(identifier)
{
	throw new Error('https://github.com/elm/core/blob/1.0.0/hints/' + identifier + '.md');
}


function _Debug_crash(identifier, fact1, fact2, fact3, fact4)
{
	switch(identifier)
	{
		case 0:
			throw new Error('What node should I take over? In JavaScript I need something like:\n\n    Elm.Main.init({\n        node: document.getElementById("elm-node")\n    })\n\nYou need to do this with any Browser.sandbox or Browser.element program.');

		case 1:
			throw new Error('Browser.application programs cannot handle URLs like this:\n\n    ' + document.location.href + '\n\nWhat is the root? The root of your file system? Try looking at this program with `elm reactor` or some other server.');

		case 2:
			var jsonErrorString = fact1;
			throw new Error('Problem with the flags given to your Elm program on initialization.\n\n' + jsonErrorString);

		case 3:
			var portName = fact1;
			throw new Error('There can only be one port named `' + portName + '`, but your program has multiple.');

		case 4:
			var portName = fact1;
			var problem = fact2;
			throw new Error('Trying to send an unexpected type of value through port `' + portName + '`:\n' + problem);

		case 5:
			throw new Error('Trying to use `(==)` on functions.\nThere is no way to know if functions are "the same" in the Elm sense.\nRead more about this at https://package.elm-lang.org/packages/elm/core/latest/Basics#== which describes why it is this way and what the better version will look like.');

		case 6:
			var moduleName = fact1;
			throw new Error('Your page is loading multiple Elm scripts with a module named ' + moduleName + '. Maybe a duplicate script is getting loaded accidentally? If not, rename one of them so I know which is which!');

		case 8:
			var moduleName = fact1;
			var region = fact2;
			var message = fact3;
			throw new Error('TODO in module `' + moduleName + '` ' + _Debug_regionToString(region) + '\n\n' + message);

		case 9:
			var moduleName = fact1;
			var region = fact2;
			var value = fact3;
			var message = fact4;
			throw new Error(
				'TODO in module `' + moduleName + '` from the `case` expression '
				+ _Debug_regionToString(region) + '\n\nIt received the following value:\n\n    '
				+ _Debug_toString(value).replace('\n', '\n    ')
				+ '\n\nBut the branch that handles it says:\n\n    ' + message.replace('\n', '\n    ')
			);

		case 10:
			throw new Error('Bug in https://github.com/elm/virtual-dom/issues');

		case 11:
			throw new Error('Cannot perform mod 0. Division by zero error.');
	}
}

function _Debug_regionToString(region)
{
	if (region.start.line === region.end.line)
	{
		return 'on line ' + region.start.line;
	}
	return 'on lines ' + region.start.line + ' through ' + region.end.line;
}



// MATH

var _Basics_add = F2(function(a, b) { return a + b; });
var _Basics_sub = F2(function(a, b) { return a - b; });
var _Basics_mul = F2(function(a, b) { return a * b; });
var _Basics_fdiv = F2(function(a, b) { return a / b; });
var _Basics_idiv = F2(function(a, b) { return (a / b) | 0; });
var _Basics_pow = F2(Math.pow);

var _Basics_remainderBy = F2(function(b, a) { return a % b; });

// https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/divmodnote-letter.pdf
var _Basics_modBy = F2(function(modulus, x)
{
	var answer = x % modulus;
	return modulus === 0
		? _Debug_crash(11)
		:
	((answer > 0 && modulus < 0) || (answer < 0 && modulus > 0))
		? answer + modulus
		: answer;
});


// TRIGONOMETRY

var _Basics_pi = Math.PI;
var _Basics_e = Math.E;
var _Basics_cos = Math.cos;
var _Basics_sin = Math.sin;
var _Basics_tan = Math.tan;
var _Basics_acos = Math.acos;
var _Basics_asin = Math.asin;
var _Basics_atan = Math.atan;
var _Basics_atan2 = F2(Math.atan2);


// MORE MATH

function _Basics_toFloat(x) { return x; }
function _Basics_truncate(n) { return n | 0; }
function _Basics_isInfinite(n) { return n === Infinity || n === -Infinity; }

var _Basics_ceiling = Math.ceil;
var _Basics_floor = Math.floor;
var _Basics_round = Math.round;
var _Basics_sqrt = Math.sqrt;
var _Basics_log = Math.log;
var _Basics_isNaN = isNaN;


// BOOLEANS

function _Basics_not(bool) { return !bool; }
var _Basics_and = F2(function(a, b) { return a && b; });
var _Basics_or  = F2(function(a, b) { return a || b; });
var _Basics_xor = F2(function(a, b) { return a !== b; });



var _String_cons = F2(function(chr, str)
{
	return chr + str;
});

function _String_uncons(string)
{
	var word = string.charCodeAt(0);
	return !isNaN(word)
		? $elm$core$Maybe$Just(
			0xD800 <= word && word <= 0xDBFF
				? _Utils_Tuple2(_Utils_chr(string[0] + string[1]), string.slice(2))
				: _Utils_Tuple2(_Utils_chr(string[0]), string.slice(1))
		)
		: $elm$core$Maybe$Nothing;
}

var _String_append = F2(function(a, b)
{
	return a + b;
});

function _String_length(str)
{
	return str.length;
}

var _String_map = F2(function(func, string)
{
	var len = string.length;
	var array = new Array(len);
	var i = 0;
	while (i < len)
	{
		var word = string.charCodeAt(i);
		if (0xD800 <= word && word <= 0xDBFF)
		{
			array[i] = func(_Utils_chr(string[i] + string[i+1]));
			i += 2;
			continue;
		}
		array[i] = func(_Utils_chr(string[i]));
		i++;
	}
	return array.join('');
});

var _String_filter = F2(function(isGood, str)
{
	var arr = [];
	var len = str.length;
	var i = 0;
	while (i < len)
	{
		var char = str[i];
		var word = str.charCodeAt(i);
		i++;
		if (0xD800 <= word && word <= 0xDBFF)
		{
			char += str[i];
			i++;
		}

		if (isGood(_Utils_chr(char)))
		{
			arr.push(char);
		}
	}
	return arr.join('');
});

function _String_reverse(str)
{
	var len = str.length;
	var arr = new Array(len);
	var i = 0;
	while (i < len)
	{
		var word = str.charCodeAt(i);
		if (0xD800 <= word && word <= 0xDBFF)
		{
			arr[len - i] = str[i + 1];
			i++;
			arr[len - i] = str[i - 1];
			i++;
		}
		else
		{
			arr[len - i] = str[i];
			i++;
		}
	}
	return arr.join('');
}

var _String_foldl = F3(function(func, state, string)
{
	var len = string.length;
	var i = 0;
	while (i < len)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		i++;
		if (0xD800 <= word && word <= 0xDBFF)
		{
			char += string[i];
			i++;
		}
		state = A2(func, _Utils_chr(char), state);
	}
	return state;
});

var _String_foldr = F3(function(func, state, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		state = A2(func, _Utils_chr(char), state);
	}
	return state;
});

var _String_split = F2(function(sep, str)
{
	return str.split(sep);
});

var _String_join = F2(function(sep, strs)
{
	return strs.join(sep);
});

var _String_slice = F3(function(start, end, str) {
	return str.slice(start, end);
});

function _String_trim(str)
{
	return str.trim();
}

function _String_trimLeft(str)
{
	return str.replace(/^\s+/, '');
}

function _String_trimRight(str)
{
	return str.replace(/\s+$/, '');
}

function _String_words(str)
{
	return _List_fromArray(str.trim().split(/\s+/g));
}

function _String_lines(str)
{
	return _List_fromArray(str.split(/\r\n|\r|\n/g));
}

function _String_toUpper(str)
{
	return str.toUpperCase();
}

function _String_toLower(str)
{
	return str.toLowerCase();
}

var _String_any = F2(function(isGood, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		if (isGood(_Utils_chr(char)))
		{
			return true;
		}
	}
	return false;
});

var _String_all = F2(function(isGood, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		if (!isGood(_Utils_chr(char)))
		{
			return false;
		}
	}
	return true;
});

var _String_contains = F2(function(sub, str)
{
	return str.indexOf(sub) > -1;
});

var _String_startsWith = F2(function(sub, str)
{
	return str.indexOf(sub) === 0;
});

var _String_endsWith = F2(function(sub, str)
{
	return str.length >= sub.length &&
		str.lastIndexOf(sub) === str.length - sub.length;
});

var _String_indexes = F2(function(sub, str)
{
	var subLen = sub.length;

	if (subLen < 1)
	{
		return _List_Nil;
	}

	var i = 0;
	var is = [];

	while ((i = str.indexOf(sub, i)) > -1)
	{
		is.push(i);
		i = i + subLen;
	}

	return _List_fromArray(is);
});


// TO STRING

function _String_fromNumber(number)
{
	return number + '';
}


// INT CONVERSIONS

function _String_toInt(str)
{
	var total = 0;
	var code0 = str.charCodeAt(0);
	var start = code0 == 0x2B /* + */ || code0 == 0x2D /* - */ ? 1 : 0;

	for (var i = start; i < str.length; ++i)
	{
		var code = str.charCodeAt(i);
		if (code < 0x30 || 0x39 < code)
		{
			return $elm$core$Maybe$Nothing;
		}
		total = 10 * total + code - 0x30;
	}

	return i == start
		? $elm$core$Maybe$Nothing
		: $elm$core$Maybe$Just(code0 == 0x2D ? -total : total);
}


// FLOAT CONVERSIONS

function _String_toFloat(s)
{
	// check if it is a hex, octal, or binary number
	if (s.length === 0 || /[\sxbo]/.test(s))
	{
		return $elm$core$Maybe$Nothing;
	}
	var n = +s;
	// faster isNaN check
	return n === n ? $elm$core$Maybe$Just(n) : $elm$core$Maybe$Nothing;
}

function _String_fromList(chars)
{
	return _List_toArray(chars).join('');
}




function _Char_toCode(char)
{
	var code = char.charCodeAt(0);
	if (0xD800 <= code && code <= 0xDBFF)
	{
		return (code - 0xD800) * 0x400 + char.charCodeAt(1) - 0xDC00 + 0x10000
	}
	return code;
}

function _Char_fromCode(code)
{
	return _Utils_chr(
		(code < 0 || 0x10FFFF < code)
			? '\uFFFD'
			:
		(code <= 0xFFFF)
			? String.fromCharCode(code)
			:
		(code -= 0x10000,
			String.fromCharCode(Math.floor(code / 0x400) + 0xD800, code % 0x400 + 0xDC00)
		)
	);
}

function _Char_toUpper(char)
{
	return _Utils_chr(char.toUpperCase());
}

function _Char_toLower(char)
{
	return _Utils_chr(char.toLowerCase());
}

function _Char_toLocaleUpper(char)
{
	return _Utils_chr(char.toLocaleUpperCase());
}

function _Char_toLocaleLower(char)
{
	return _Utils_chr(char.toLocaleLowerCase());
}



/**/
function _Json_errorToString(error)
{
	return $elm$json$Json$Decode$errorToString(error);
}
//*/


// CORE DECODERS

function _Json_succeed(msg)
{
	return {
		$: 0,
		a: msg
	};
}

function _Json_fail(msg)
{
	return {
		$: 1,
		a: msg
	};
}

function _Json_decodePrim(decoder)
{
	return { $: 2, b: decoder };
}

var _Json_decodeInt = _Json_decodePrim(function(value) {
	return (typeof value !== 'number')
		? _Json_expecting('an INT', value)
		:
	(-2147483647 < value && value < 2147483647 && (value | 0) === value)
		? $elm$core$Result$Ok(value)
		:
	(isFinite(value) && !(value % 1))
		? $elm$core$Result$Ok(value)
		: _Json_expecting('an INT', value);
});

var _Json_decodeBool = _Json_decodePrim(function(value) {
	return (typeof value === 'boolean')
		? $elm$core$Result$Ok(value)
		: _Json_expecting('a BOOL', value);
});

var _Json_decodeFloat = _Json_decodePrim(function(value) {
	return (typeof value === 'number')
		? $elm$core$Result$Ok(value)
		: _Json_expecting('a FLOAT', value);
});

var _Json_decodeValue = _Json_decodePrim(function(value) {
	return $elm$core$Result$Ok(_Json_wrap(value));
});

var _Json_decodeString = _Json_decodePrim(function(value) {
	return (typeof value === 'string')
		? $elm$core$Result$Ok(value)
		: (value instanceof String)
			? $elm$core$Result$Ok(value + '')
			: _Json_expecting('a STRING', value);
});

function _Json_decodeList(decoder) { return { $: 3, b: decoder }; }
function _Json_decodeArray(decoder) { return { $: 4, b: decoder }; }

function _Json_decodeNull(value) { return { $: 5, c: value }; }

var _Json_decodeField = F2(function(field, decoder)
{
	return {
		$: 6,
		d: field,
		b: decoder
	};
});

var _Json_decodeIndex = F2(function(index, decoder)
{
	return {
		$: 7,
		e: index,
		b: decoder
	};
});

function _Json_decodeKeyValuePairs(decoder)
{
	return {
		$: 8,
		b: decoder
	};
}

function _Json_mapMany(f, decoders)
{
	return {
		$: 9,
		f: f,
		g: decoders
	};
}

var _Json_andThen = F2(function(callback, decoder)
{
	return {
		$: 10,
		b: decoder,
		h: callback
	};
});

function _Json_oneOf(decoders)
{
	return {
		$: 11,
		g: decoders
	};
}


// DECODING OBJECTS

var _Json_map1 = F2(function(f, d1)
{
	return _Json_mapMany(f, [d1]);
});

var _Json_map2 = F3(function(f, d1, d2)
{
	return _Json_mapMany(f, [d1, d2]);
});

var _Json_map3 = F4(function(f, d1, d2, d3)
{
	return _Json_mapMany(f, [d1, d2, d3]);
});

var _Json_map4 = F5(function(f, d1, d2, d3, d4)
{
	return _Json_mapMany(f, [d1, d2, d3, d4]);
});

var _Json_map5 = F6(function(f, d1, d2, d3, d4, d5)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5]);
});

var _Json_map6 = F7(function(f, d1, d2, d3, d4, d5, d6)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6]);
});

var _Json_map7 = F8(function(f, d1, d2, d3, d4, d5, d6, d7)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6, d7]);
});

var _Json_map8 = F9(function(f, d1, d2, d3, d4, d5, d6, d7, d8)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6, d7, d8]);
});


// DECODE

var _Json_runOnString = F2(function(decoder, string)
{
	try
	{
		var value = JSON.parse(string);
		return _Json_runHelp(decoder, value);
	}
	catch (e)
	{
		return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, 'This is not valid JSON! ' + e.message, _Json_wrap(string)));
	}
});

var _Json_run = F2(function(decoder, value)
{
	return _Json_runHelp(decoder, _Json_unwrap(value));
});

function _Json_runHelp(decoder, value)
{
	switch (decoder.$)
	{
		case 2:
			return decoder.b(value);

		case 5:
			return (value === null)
				? $elm$core$Result$Ok(decoder.c)
				: _Json_expecting('null', value);

		case 3:
			if (!_Json_isArray(value))
			{
				return _Json_expecting('a LIST', value);
			}
			return _Json_runArrayDecoder(decoder.b, value, _List_fromArray);

		case 4:
			if (!_Json_isArray(value))
			{
				return _Json_expecting('an ARRAY', value);
			}
			return _Json_runArrayDecoder(decoder.b, value, _Json_toElmArray);

		case 6:
			var field = decoder.d;
			if (typeof value !== 'object' || value === null || !(field in value))
			{
				return _Json_expecting('an OBJECT with a field named `' + field + '`', value);
			}
			var result = _Json_runHelp(decoder.b, value[field]);
			return ($elm$core$Result$isOk(result)) ? result : $elm$core$Result$Err(A2($elm$json$Json$Decode$Field, field, result.a));

		case 7:
			var index = decoder.e;
			if (!_Json_isArray(value))
			{
				return _Json_expecting('an ARRAY', value);
			}
			if (index >= value.length)
			{
				return _Json_expecting('a LONGER array. Need index ' + index + ' but only see ' + value.length + ' entries', value);
			}
			var result = _Json_runHelp(decoder.b, value[index]);
			return ($elm$core$Result$isOk(result)) ? result : $elm$core$Result$Err(A2($elm$json$Json$Decode$Index, index, result.a));

		case 8:
			if (typeof value !== 'object' || value === null || _Json_isArray(value))
			{
				return _Json_expecting('an OBJECT', value);
			}

			var keyValuePairs = _List_Nil;
			// TODO test perf of Object.keys and switch when support is good enough
			for (var key in value)
			{
				if (value.hasOwnProperty(key))
				{
					var result = _Json_runHelp(decoder.b, value[key]);
					if (!$elm$core$Result$isOk(result))
					{
						return $elm$core$Result$Err(A2($elm$json$Json$Decode$Field, key, result.a));
					}
					keyValuePairs = _List_Cons(_Utils_Tuple2(key, result.a), keyValuePairs);
				}
			}
			return $elm$core$Result$Ok($elm$core$List$reverse(keyValuePairs));

		case 9:
			var answer = decoder.f;
			var decoders = decoder.g;
			for (var i = 0; i < decoders.length; i++)
			{
				var result = _Json_runHelp(decoders[i], value);
				if (!$elm$core$Result$isOk(result))
				{
					return result;
				}
				answer = answer(result.a);
			}
			return $elm$core$Result$Ok(answer);

		case 10:
			var result = _Json_runHelp(decoder.b, value);
			return (!$elm$core$Result$isOk(result))
				? result
				: _Json_runHelp(decoder.h(result.a), value);

		case 11:
			var errors = _List_Nil;
			for (var temp = decoder.g; temp.b; temp = temp.b) // WHILE_CONS
			{
				var result = _Json_runHelp(temp.a, value);
				if ($elm$core$Result$isOk(result))
				{
					return result;
				}
				errors = _List_Cons(result.a, errors);
			}
			return $elm$core$Result$Err($elm$json$Json$Decode$OneOf($elm$core$List$reverse(errors)));

		case 1:
			return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, decoder.a, _Json_wrap(value)));

		case 0:
			return $elm$core$Result$Ok(decoder.a);
	}
}

function _Json_runArrayDecoder(decoder, value, toElmValue)
{
	var len = value.length;
	var array = new Array(len);
	for (var i = 0; i < len; i++)
	{
		var result = _Json_runHelp(decoder, value[i]);
		if (!$elm$core$Result$isOk(result))
		{
			return $elm$core$Result$Err(A2($elm$json$Json$Decode$Index, i, result.a));
		}
		array[i] = result.a;
	}
	return $elm$core$Result$Ok(toElmValue(array));
}

function _Json_isArray(value)
{
	return Array.isArray(value) || (typeof FileList !== 'undefined' && value instanceof FileList);
}

function _Json_toElmArray(array)
{
	return A2($elm$core$Array$initialize, array.length, function(i) { return array[i]; });
}

function _Json_expecting(type, value)
{
	return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, 'Expecting ' + type, _Json_wrap(value)));
}


// EQUALITY

function _Json_equality(x, y)
{
	if (x === y)
	{
		return true;
	}

	if (x.$ !== y.$)
	{
		return false;
	}

	switch (x.$)
	{
		case 0:
		case 1:
			return x.a === y.a;

		case 2:
			return x.b === y.b;

		case 5:
			return x.c === y.c;

		case 3:
		case 4:
		case 8:
			return _Json_equality(x.b, y.b);

		case 6:
			return x.d === y.d && _Json_equality(x.b, y.b);

		case 7:
			return x.e === y.e && _Json_equality(x.b, y.b);

		case 9:
			return x.f === y.f && _Json_listEquality(x.g, y.g);

		case 10:
			return x.h === y.h && _Json_equality(x.b, y.b);

		case 11:
			return _Json_listEquality(x.g, y.g);
	}
}

function _Json_listEquality(aDecoders, bDecoders)
{
	var len = aDecoders.length;
	if (len !== bDecoders.length)
	{
		return false;
	}
	for (var i = 0; i < len; i++)
	{
		if (!_Json_equality(aDecoders[i], bDecoders[i]))
		{
			return false;
		}
	}
	return true;
}


// ENCODE

var _Json_encode = F2(function(indentLevel, value)
{
	return JSON.stringify(_Json_unwrap(value), null, indentLevel) + '';
});

function _Json_wrap(value) { return { $: 0, a: value }; }
function _Json_unwrap(value) { return value.a; }

function _Json_wrap_UNUSED(value) { return value; }
function _Json_unwrap_UNUSED(value) { return value; }

function _Json_emptyArray() { return []; }
function _Json_emptyObject() { return {}; }

var _Json_addField = F3(function(key, value, object)
{
	object[key] = _Json_unwrap(value);
	return object;
});

function _Json_addEntry(func)
{
	return F2(function(entry, array)
	{
		array.push(_Json_unwrap(func(entry)));
		return array;
	});
}

var _Json_encodeNull = _Json_wrap(null);



// TASKS

function _Scheduler_succeed(value)
{
	return {
		$: 0,
		a: value
	};
}

function _Scheduler_fail(error)
{
	return {
		$: 1,
		a: error
	};
}

function _Scheduler_binding(callback)
{
	return {
		$: 2,
		b: callback,
		c: null
	};
}

var _Scheduler_andThen = F2(function(callback, task)
{
	return {
		$: 3,
		b: callback,
		d: task
	};
});

var _Scheduler_onError = F2(function(callback, task)
{
	return {
		$: 4,
		b: callback,
		d: task
	};
});

function _Scheduler_receive(callback)
{
	return {
		$: 5,
		b: callback
	};
}


// PROCESSES

var _Scheduler_guid = 0;

function _Scheduler_rawSpawn(task)
{
	var proc = {
		$: 0,
		e: _Scheduler_guid++,
		f: task,
		g: null,
		h: []
	};

	_Scheduler_enqueue(proc);

	return proc;
}

function _Scheduler_spawn(task)
{
	return _Scheduler_binding(function(callback) {
		callback(_Scheduler_succeed(_Scheduler_rawSpawn(task)));
	});
}

function _Scheduler_rawSend(proc, msg)
{
	proc.h.push(msg);
	_Scheduler_enqueue(proc);
}

var _Scheduler_send = F2(function(proc, msg)
{
	return _Scheduler_binding(function(callback) {
		_Scheduler_rawSend(proc, msg);
		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
});

function _Scheduler_kill(proc)
{
	return _Scheduler_binding(function(callback) {
		var task = proc.f;
		if (task.$ === 2 && task.c)
		{
			task.c();
		}

		proc.f = null;

		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
}


/* STEP PROCESSES

type alias Process =
  { $ : tag
  , id : unique_id
  , root : Task
  , stack : null | { $: SUCCEED | FAIL, a: callback, b: stack }
  , mailbox : [msg]
  }

*/


var _Scheduler_working = false;
var _Scheduler_queue = [];


function _Scheduler_enqueue(proc)
{
	_Scheduler_queue.push(proc);
	if (_Scheduler_working)
	{
		return;
	}
	_Scheduler_working = true;
	while (proc = _Scheduler_queue.shift())
	{
		_Scheduler_step(proc);
	}
	_Scheduler_working = false;
}


function _Scheduler_step(proc)
{
	while (proc.f)
	{
		var rootTag = proc.f.$;
		if (rootTag === 0 || rootTag === 1)
		{
			while (proc.g && proc.g.$ !== rootTag)
			{
				proc.g = proc.g.i;
			}
			if (!proc.g)
			{
				return;
			}
			proc.f = proc.g.b(proc.f.a);
			proc.g = proc.g.i;
		}
		else if (rootTag === 2)
		{
			proc.f.c = proc.f.b(function(newRoot) {
				proc.f = newRoot;
				_Scheduler_enqueue(proc);
			});
			return;
		}
		else if (rootTag === 5)
		{
			if (proc.h.length === 0)
			{
				return;
			}
			proc.f = proc.f.b(proc.h.shift());
		}
		else // if (rootTag === 3 || rootTag === 4)
		{
			proc.g = {
				$: rootTag === 3 ? 0 : 1,
				b: proc.f.b,
				i: proc.g
			};
			proc.f = proc.f.d;
		}
	}
}



function _Process_sleep(time)
{
	return _Scheduler_binding(function(callback) {
		var id = setTimeout(function() {
			callback(_Scheduler_succeed(_Utils_Tuple0));
		}, time);

		return function() { clearTimeout(id); };
	});
}




// PROGRAMS


var _Platform_worker = F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.init,
		impl.update,
		impl.subscriptions,
		function() { return function() {} }
	);
});



// INITIALIZE A PROGRAM


function _Platform_initialize(flagDecoder, args, init, update, subscriptions, stepperBuilder)
{
	var result = A2(_Json_run, flagDecoder, _Json_wrap(args ? args['flags'] : undefined));
	$elm$core$Result$isOk(result) || _Debug_crash(2 /**/, _Json_errorToString(result.a) /**/);
	var managers = {};
	var initPair = init(result.a);
	var model = initPair.a;
	var stepper = stepperBuilder(sendToApp, model);
	var ports = _Platform_setupEffects(managers, sendToApp);

	function sendToApp(msg, viewMetadata)
	{
		var pair = A2(update, msg, model);
		stepper(model = pair.a, viewMetadata);
		_Platform_enqueueEffects(managers, pair.b, subscriptions(model));
	}

	_Platform_enqueueEffects(managers, initPair.b, subscriptions(model));

	return ports ? { ports: ports } : {};
}



// TRACK PRELOADS
//
// This is used by code in elm/browser and elm/http
// to register any HTTP requests that are triggered by init.
//


var _Platform_preload;


function _Platform_registerPreload(url)
{
	_Platform_preload.add(url);
}



// EFFECT MANAGERS


var _Platform_effectManagers = {};


function _Platform_setupEffects(managers, sendToApp)
{
	var ports;

	// setup all necessary effect managers
	for (var key in _Platform_effectManagers)
	{
		var manager = _Platform_effectManagers[key];

		if (manager.a)
		{
			ports = ports || {};
			ports[key] = manager.a(key, sendToApp);
		}

		managers[key] = _Platform_instantiateManager(manager, sendToApp);
	}

	return ports;
}


function _Platform_createManager(init, onEffects, onSelfMsg, cmdMap, subMap)
{
	return {
		b: init,
		c: onEffects,
		d: onSelfMsg,
		e: cmdMap,
		f: subMap
	};
}


function _Platform_instantiateManager(info, sendToApp)
{
	var router = {
		g: sendToApp,
		h: undefined
	};

	var onEffects = info.c;
	var onSelfMsg = info.d;
	var cmdMap = info.e;
	var subMap = info.f;

	function loop(state)
	{
		return A2(_Scheduler_andThen, loop, _Scheduler_receive(function(msg)
		{
			var value = msg.a;

			if (msg.$ === 0)
			{
				return A3(onSelfMsg, router, value, state);
			}

			return cmdMap && subMap
				? A4(onEffects, router, value.i, value.j, state)
				: A3(onEffects, router, cmdMap ? value.i : value.j, state);
		}));
	}

	return router.h = _Scheduler_rawSpawn(A2(_Scheduler_andThen, loop, info.b));
}



// ROUTING


var _Platform_sendToApp = F2(function(router, msg)
{
	return _Scheduler_binding(function(callback)
	{
		router.g(msg);
		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
});


var _Platform_sendToSelf = F2(function(router, msg)
{
	return A2(_Scheduler_send, router.h, {
		$: 0,
		a: msg
	});
});



// BAGS


function _Platform_leaf(home)
{
	return function(value)
	{
		return {
			$: 1,
			k: home,
			l: value
		};
	};
}


function _Platform_batch(list)
{
	return {
		$: 2,
		m: list
	};
}


var _Platform_map = F2(function(tagger, bag)
{
	return {
		$: 3,
		n: tagger,
		o: bag
	}
});



// PIPE BAGS INTO EFFECT MANAGERS
//
// Effects must be queued!
//
// Say your init contains a synchronous command, like Time.now or Time.here
//
//   - This will produce a batch of effects (FX_1)
//   - The synchronous task triggers the subsequent `update` call
//   - This will produce a batch of effects (FX_2)
//
// If we just start dispatching FX_2, subscriptions from FX_2 can be processed
// before subscriptions from FX_1. No good! Earlier versions of this code had
// this problem, leading to these reports:
//
//   https://github.com/elm/core/issues/980
//   https://github.com/elm/core/pull/981
//   https://github.com/elm/compiler/issues/1776
//
// The queue is necessary to avoid ordering issues for synchronous commands.


// Why use true/false here? Why not just check the length of the queue?
// The goal is to detect "are we currently dispatching effects?" If we
// are, we need to bail and let the ongoing while loop handle things.
//
// Now say the queue has 1 element. When we dequeue the final element,
// the queue will be empty, but we are still actively dispatching effects.
// So you could get queue jumping in a really tricky category of cases.
//
var _Platform_effectsQueue = [];
var _Platform_effectsActive = false;


function _Platform_enqueueEffects(managers, cmdBag, subBag)
{
	_Platform_effectsQueue.push({ p: managers, q: cmdBag, r: subBag });

	if (_Platform_effectsActive) return;

	_Platform_effectsActive = true;
	for (var fx; fx = _Platform_effectsQueue.shift(); )
	{
		_Platform_dispatchEffects(fx.p, fx.q, fx.r);
	}
	_Platform_effectsActive = false;
}


function _Platform_dispatchEffects(managers, cmdBag, subBag)
{
	var effectsDict = {};
	_Platform_gatherEffects(true, cmdBag, effectsDict, null);
	_Platform_gatherEffects(false, subBag, effectsDict, null);

	for (var home in managers)
	{
		_Scheduler_rawSend(managers[home], {
			$: 'fx',
			a: effectsDict[home] || { i: _List_Nil, j: _List_Nil }
		});
	}
}


function _Platform_gatherEffects(isCmd, bag, effectsDict, taggers)
{
	switch (bag.$)
	{
		case 1:
			var home = bag.k;
			var effect = _Platform_toEffect(isCmd, home, taggers, bag.l);
			effectsDict[home] = _Platform_insert(isCmd, effect, effectsDict[home]);
			return;

		case 2:
			for (var list = bag.m; list.b; list = list.b) // WHILE_CONS
			{
				_Platform_gatherEffects(isCmd, list.a, effectsDict, taggers);
			}
			return;

		case 3:
			_Platform_gatherEffects(isCmd, bag.o, effectsDict, {
				s: bag.n,
				t: taggers
			});
			return;
	}
}


function _Platform_toEffect(isCmd, home, taggers, value)
{
	function applyTaggers(x)
	{
		for (var temp = taggers; temp; temp = temp.t)
		{
			x = temp.s(x);
		}
		return x;
	}

	var map = isCmd
		? _Platform_effectManagers[home].e
		: _Platform_effectManagers[home].f;

	return A2(map, applyTaggers, value)
}


function _Platform_insert(isCmd, newEffect, effects)
{
	effects = effects || { i: _List_Nil, j: _List_Nil };

	isCmd
		? (effects.i = _List_Cons(newEffect, effects.i))
		: (effects.j = _List_Cons(newEffect, effects.j));

	return effects;
}



// PORTS


function _Platform_checkPortName(name)
{
	if (_Platform_effectManagers[name])
	{
		_Debug_crash(3, name)
	}
}



// OUTGOING PORTS


function _Platform_outgoingPort(name, converter)
{
	_Platform_checkPortName(name);
	_Platform_effectManagers[name] = {
		e: _Platform_outgoingPortMap,
		u: converter,
		a: _Platform_setupOutgoingPort
	};
	return _Platform_leaf(name);
}


var _Platform_outgoingPortMap = F2(function(tagger, value) { return value; });


function _Platform_setupOutgoingPort(name)
{
	var subs = [];
	var converter = _Platform_effectManagers[name].u;

	// CREATE MANAGER

	var init = _Process_sleep(0);

	_Platform_effectManagers[name].b = init;
	_Platform_effectManagers[name].c = F3(function(router, cmdList, state)
	{
		for ( ; cmdList.b; cmdList = cmdList.b) // WHILE_CONS
		{
			// grab a separate reference to subs in case unsubscribe is called
			var currentSubs = subs;
			var value = _Json_unwrap(converter(cmdList.a));
			for (var i = 0; i < currentSubs.length; i++)
			{
				currentSubs[i](value);
			}
		}
		return init;
	});

	// PUBLIC API

	function subscribe(callback)
	{
		subs.push(callback);
	}

	function unsubscribe(callback)
	{
		// copy subs into a new array in case unsubscribe is called within a
		// subscribed callback
		subs = subs.slice();
		var index = subs.indexOf(callback);
		if (index >= 0)
		{
			subs.splice(index, 1);
		}
	}

	return {
		subscribe: subscribe,
		unsubscribe: unsubscribe
	};
}



// INCOMING PORTS


function _Platform_incomingPort(name, converter)
{
	_Platform_checkPortName(name);
	_Platform_effectManagers[name] = {
		f: _Platform_incomingPortMap,
		u: converter,
		a: _Platform_setupIncomingPort
	};
	return _Platform_leaf(name);
}


var _Platform_incomingPortMap = F2(function(tagger, finalTagger)
{
	return function(value)
	{
		return tagger(finalTagger(value));
	};
});


function _Platform_setupIncomingPort(name, sendToApp)
{
	var subs = _List_Nil;
	var converter = _Platform_effectManagers[name].u;

	// CREATE MANAGER

	var init = _Scheduler_succeed(null);

	_Platform_effectManagers[name].b = init;
	_Platform_effectManagers[name].c = F3(function(router, subList, state)
	{
		subs = subList;
		return init;
	});

	// PUBLIC API

	function send(incomingValue)
	{
		var result = A2(_Json_run, converter, _Json_wrap(incomingValue));

		$elm$core$Result$isOk(result) || _Debug_crash(4, name, result.a);

		var value = result.a;
		for (var temp = subs; temp.b; temp = temp.b) // WHILE_CONS
		{
			sendToApp(temp.a(value));
		}
	}

	return { send: send };
}



// EXPORT ELM MODULES
//
// Have DEBUG and PROD versions so that we can (1) give nicer errors in
// debug mode and (2) not pay for the bits needed for that in prod mode.
//


function _Platform_export_UNUSED(exports)
{
	scope['Elm']
		? _Platform_mergeExportsProd(scope['Elm'], exports)
		: scope['Elm'] = exports;
}


function _Platform_mergeExportsProd(obj, exports)
{
	for (var name in exports)
	{
		(name in obj)
			? (name == 'init')
				? _Debug_crash(6)
				: _Platform_mergeExportsProd(obj[name], exports[name])
			: (obj[name] = exports[name]);
	}
}


function _Platform_export(exports)
{
	scope['Elm']
		? _Platform_mergeExportsDebug('Elm', scope['Elm'], exports)
		: scope['Elm'] = exports;
}


function _Platform_mergeExportsDebug(moduleName, obj, exports)
{
	for (var name in exports)
	{
		(name in obj)
			? (name == 'init')
				? _Debug_crash(6, moduleName)
				: _Platform_mergeExportsDebug(moduleName + '.' + name, obj[name], exports[name])
			: (obj[name] = exports[name]);
	}
}




// HELPERS


var _VirtualDom_divertHrefToApp;

var _VirtualDom_doc = typeof document !== 'undefined' ? document : {};


function _VirtualDom_appendChild(parent, child)
{
	parent.appendChild(child);
}

var _VirtualDom_init = F4(function(virtualNode, flagDecoder, debugMetadata, args)
{
	// NOTE: this function needs _Platform_export available to work

	/**_UNUSED/
	var node = args['node'];
	//*/
	/**/
	var node = args && args['node'] ? args['node'] : _Debug_crash(0);
	//*/

	node.parentNode.replaceChild(
		_VirtualDom_render(virtualNode, function() {}),
		node
	);

	return {};
});



// TEXT


function _VirtualDom_text(string)
{
	return {
		$: 0,
		a: string
	};
}



// NODE


var _VirtualDom_nodeNS = F2(function(namespace, tag)
{
	return F2(function(factList, kidList)
	{
		for (var kids = [], descendantsCount = 0; kidList.b; kidList = kidList.b) // WHILE_CONS
		{
			var kid = kidList.a;
			descendantsCount += (kid.b || 0);
			kids.push(kid);
		}
		descendantsCount += kids.length;

		return {
			$: 1,
			c: tag,
			d: _VirtualDom_organizeFacts(factList),
			e: kids,
			f: namespace,
			b: descendantsCount
		};
	});
});


var _VirtualDom_node = _VirtualDom_nodeNS(undefined);



// KEYED NODE


var _VirtualDom_keyedNodeNS = F2(function(namespace, tag)
{
	return F2(function(factList, kidList)
	{
		for (var kids = [], descendantsCount = 0; kidList.b; kidList = kidList.b) // WHILE_CONS
		{
			var kid = kidList.a;
			descendantsCount += (kid.b.b || 0);
			kids.push(kid);
		}
		descendantsCount += kids.length;

		return {
			$: 2,
			c: tag,
			d: _VirtualDom_organizeFacts(factList),
			e: kids,
			f: namespace,
			b: descendantsCount
		};
	});
});


var _VirtualDom_keyedNode = _VirtualDom_keyedNodeNS(undefined);



// CUSTOM


function _VirtualDom_custom(factList, model, render, diff)
{
	return {
		$: 3,
		d: _VirtualDom_organizeFacts(factList),
		g: model,
		h: render,
		i: diff
	};
}



// MAP


var _VirtualDom_map = F2(function(tagger, node)
{
	return {
		$: 4,
		j: tagger,
		k: node,
		b: 1 + (node.b || 0)
	};
});



// LAZY


function _VirtualDom_thunk(refs, thunk)
{
	return {
		$: 5,
		l: refs,
		m: thunk,
		k: undefined
	};
}

var _VirtualDom_lazy = F2(function(func, a)
{
	return _VirtualDom_thunk([func, a], function() {
		return func(a);
	});
});

var _VirtualDom_lazy2 = F3(function(func, a, b)
{
	return _VirtualDom_thunk([func, a, b], function() {
		return A2(func, a, b);
	});
});

var _VirtualDom_lazy3 = F4(function(func, a, b, c)
{
	return _VirtualDom_thunk([func, a, b, c], function() {
		return A3(func, a, b, c);
	});
});

var _VirtualDom_lazy4 = F5(function(func, a, b, c, d)
{
	return _VirtualDom_thunk([func, a, b, c, d], function() {
		return A4(func, a, b, c, d);
	});
});

var _VirtualDom_lazy5 = F6(function(func, a, b, c, d, e)
{
	return _VirtualDom_thunk([func, a, b, c, d, e], function() {
		return A5(func, a, b, c, d, e);
	});
});

var _VirtualDom_lazy6 = F7(function(func, a, b, c, d, e, f)
{
	return _VirtualDom_thunk([func, a, b, c, d, e, f], function() {
		return A6(func, a, b, c, d, e, f);
	});
});

var _VirtualDom_lazy7 = F8(function(func, a, b, c, d, e, f, g)
{
	return _VirtualDom_thunk([func, a, b, c, d, e, f, g], function() {
		return A7(func, a, b, c, d, e, f, g);
	});
});

var _VirtualDom_lazy8 = F9(function(func, a, b, c, d, e, f, g, h)
{
	return _VirtualDom_thunk([func, a, b, c, d, e, f, g, h], function() {
		return A8(func, a, b, c, d, e, f, g, h);
	});
});



// FACTS


var _VirtualDom_on = F2(function(key, handler)
{
	return {
		$: 'a0',
		n: key,
		o: handler
	};
});
var _VirtualDom_style = F2(function(key, value)
{
	return {
		$: 'a1',
		n: key,
		o: value
	};
});
var _VirtualDom_property = F2(function(key, value)
{
	return {
		$: 'a2',
		n: key,
		o: value
	};
});
var _VirtualDom_attribute = F2(function(key, value)
{
	return {
		$: 'a3',
		n: key,
		o: value
	};
});
var _VirtualDom_attributeNS = F3(function(namespace, key, value)
{
	return {
		$: 'a4',
		n: key,
		o: { f: namespace, o: value }
	};
});



// XSS ATTACK VECTOR CHECKS
//
// For some reason, tabs can appear in href protocols and it still works.
// So '\tjava\tSCRIPT:alert("!!!")' and 'javascript:alert("!!!")' are the same
// in practice. That is why _VirtualDom_RE_js and _VirtualDom_RE_js_html look
// so freaky.
//
// Pulling the regular expressions out to the top level gives a slight speed
// boost in small benchmarks (4-10%) but hoisting values to reduce allocation
// can be unpredictable in large programs where JIT may have a harder time with
// functions are not fully self-contained. The benefit is more that the js and
// js_html ones are so weird that I prefer to see them near each other.


var _VirtualDom_RE_script = /^script$/i;
var _VirtualDom_RE_on_formAction = /^(on|formAction$)/i;
var _VirtualDom_RE_js = /^\s*j\s*a\s*v\s*a\s*s\s*c\s*r\s*i\s*p\s*t\s*:/i;
var _VirtualDom_RE_js_html = /^\s*(j\s*a\s*v\s*a\s*s\s*c\s*r\s*i\s*p\s*t\s*:|d\s*a\s*t\s*a\s*:\s*t\s*e\s*x\s*t\s*\/\s*h\s*t\s*m\s*l\s*(,|;))/i;


function _VirtualDom_noScript(tag)
{
	return _VirtualDom_RE_script.test(tag) ? 'p' : tag;
}

function _VirtualDom_noOnOrFormAction(key)
{
	return _VirtualDom_RE_on_formAction.test(key) ? 'data-' + key : key;
}

function _VirtualDom_noInnerHtmlOrFormAction(key)
{
	return key == 'innerHTML' || key == 'formAction' ? 'data-' + key : key;
}

function _VirtualDom_noJavaScriptUri(value)
{
	return _VirtualDom_RE_js.test(value)
		? /**_UNUSED/''//*//**/'javascript:alert("This is an XSS vector. Please use ports or web components instead.")'//*/
		: value;
}

function _VirtualDom_noJavaScriptOrHtmlUri(value)
{
	return _VirtualDom_RE_js_html.test(value)
		? /**_UNUSED/''//*//**/'javascript:alert("This is an XSS vector. Please use ports or web components instead.")'//*/
		: value;
}

function _VirtualDom_noJavaScriptOrHtmlJson(value)
{
	return (typeof _Json_unwrap(value) === 'string' && _VirtualDom_RE_js_html.test(_Json_unwrap(value)))
		? _Json_wrap(
			/**_UNUSED/''//*//**/'javascript:alert("This is an XSS vector. Please use ports or web components instead.")'//*/
		) : value;
}



// MAP FACTS


var _VirtualDom_mapAttribute = F2(function(func, attr)
{
	return (attr.$ === 'a0')
		? A2(_VirtualDom_on, attr.n, _VirtualDom_mapHandler(func, attr.o))
		: attr;
});

function _VirtualDom_mapHandler(func, handler)
{
	var tag = $elm$virtual_dom$VirtualDom$toHandlerInt(handler);

	// 0 = Normal
	// 1 = MayStopPropagation
	// 2 = MayPreventDefault
	// 3 = Custom

	return {
		$: handler.$,
		a:
			!tag
				? A2($elm$json$Json$Decode$map, func, handler.a)
				:
			A3($elm$json$Json$Decode$map2,
				tag < 3
					? _VirtualDom_mapEventTuple
					: _VirtualDom_mapEventRecord,
				$elm$json$Json$Decode$succeed(func),
				handler.a
			)
	};
}

var _VirtualDom_mapEventTuple = F2(function(func, tuple)
{
	return _Utils_Tuple2(func(tuple.a), tuple.b);
});

var _VirtualDom_mapEventRecord = F2(function(func, record)
{
	return {
		message: func(record.message),
		stopPropagation: record.stopPropagation,
		preventDefault: record.preventDefault
	}
});



// ORGANIZE FACTS


function _VirtualDom_organizeFacts(factList)
{
	for (var facts = {}; factList.b; factList = factList.b) // WHILE_CONS
	{
		var entry = factList.a;

		var tag = entry.$;
		var key = entry.n;
		var value = entry.o;

		if (tag === 'a2')
		{
			(key === 'className')
				? _VirtualDom_addClass(facts, key, _Json_unwrap(value))
				: facts[key] = _Json_unwrap(value);

			continue;
		}

		var subFacts = facts[tag] || (facts[tag] = {});
		(tag === 'a3' && key === 'class')
			? _VirtualDom_addClass(subFacts, key, value)
			: subFacts[key] = value;
	}

	return facts;
}

function _VirtualDom_addClass(object, key, newClass)
{
	var classes = object[key];
	object[key] = classes ? classes + ' ' + newClass : newClass;
}



// RENDER


function _VirtualDom_render(vNode, eventNode)
{
	var tag = vNode.$;

	if (tag === 5)
	{
		return _VirtualDom_render(vNode.k || (vNode.k = vNode.m()), eventNode);
	}

	if (tag === 0)
	{
		return _VirtualDom_doc.createTextNode(vNode.a);
	}

	if (tag === 4)
	{
		var subNode = vNode.k;
		var tagger = vNode.j;

		while (subNode.$ === 4)
		{
			typeof tagger !== 'object'
				? tagger = [tagger, subNode.j]
				: tagger.push(subNode.j);

			subNode = subNode.k;
		}

		var subEventRoot = { j: tagger, p: eventNode };
		var domNode = _VirtualDom_render(subNode, subEventRoot);
		domNode.elm_event_node_ref = subEventRoot;
		return domNode;
	}

	if (tag === 3)
	{
		var domNode = vNode.h(vNode.g);
		_VirtualDom_applyFacts(domNode, eventNode, vNode.d);
		return domNode;
	}

	// at this point `tag` must be 1 or 2

	var domNode = vNode.f
		? _VirtualDom_doc.createElementNS(vNode.f, vNode.c)
		: _VirtualDom_doc.createElement(vNode.c);

	if (_VirtualDom_divertHrefToApp && vNode.c == 'a')
	{
		domNode.addEventListener('click', _VirtualDom_divertHrefToApp(domNode));
	}

	_VirtualDom_applyFacts(domNode, eventNode, vNode.d);

	for (var kids = vNode.e, i = 0; i < kids.length; i++)
	{
		_VirtualDom_appendChild(domNode, _VirtualDom_render(tag === 1 ? kids[i] : kids[i].b, eventNode));
	}

	return domNode;
}



// APPLY FACTS


function _VirtualDom_applyFacts(domNode, eventNode, facts)
{
	for (var key in facts)
	{
		var value = facts[key];

		key === 'a1'
			? _VirtualDom_applyStyles(domNode, value)
			:
		key === 'a0'
			? _VirtualDom_applyEvents(domNode, eventNode, value)
			:
		key === 'a3'
			? _VirtualDom_applyAttrs(domNode, value)
			:
		key === 'a4'
			? _VirtualDom_applyAttrsNS(domNode, value)
			:
		((key !== 'value' && key !== 'checked') || domNode[key] !== value) && (domNode[key] = value);
	}
}



// APPLY STYLES


function _VirtualDom_applyStyles(domNode, styles)
{
	var domNodeStyle = domNode.style;

	for (var key in styles)
	{
		domNodeStyle[key] = styles[key];
	}
}



// APPLY ATTRS


function _VirtualDom_applyAttrs(domNode, attrs)
{
	for (var key in attrs)
	{
		var value = attrs[key];
		typeof value !== 'undefined'
			? domNode.setAttribute(key, value)
			: domNode.removeAttribute(key);
	}
}



// APPLY NAMESPACED ATTRS


function _VirtualDom_applyAttrsNS(domNode, nsAttrs)
{
	for (var key in nsAttrs)
	{
		var pair = nsAttrs[key];
		var namespace = pair.f;
		var value = pair.o;

		typeof value !== 'undefined'
			? domNode.setAttributeNS(namespace, key, value)
			: domNode.removeAttributeNS(namespace, key);
	}
}



// APPLY EVENTS


function _VirtualDom_applyEvents(domNode, eventNode, events)
{
	var allCallbacks = domNode.elmFs || (domNode.elmFs = {});

	for (var key in events)
	{
		var newHandler = events[key];
		var oldCallback = allCallbacks[key];

		if (!newHandler)
		{
			domNode.removeEventListener(key, oldCallback);
			allCallbacks[key] = undefined;
			continue;
		}

		if (oldCallback)
		{
			var oldHandler = oldCallback.q;
			if (oldHandler.$ === newHandler.$)
			{
				oldCallback.q = newHandler;
				continue;
			}
			domNode.removeEventListener(key, oldCallback);
		}

		oldCallback = _VirtualDom_makeCallback(eventNode, newHandler);
		domNode.addEventListener(key, oldCallback,
			_VirtualDom_passiveSupported
			&& { passive: $elm$virtual_dom$VirtualDom$toHandlerInt(newHandler) < 2 }
		);
		allCallbacks[key] = oldCallback;
	}
}



// PASSIVE EVENTS


var _VirtualDom_passiveSupported;

try
{
	window.addEventListener('t', null, Object.defineProperty({}, 'passive', {
		get: function() { _VirtualDom_passiveSupported = true; }
	}));
}
catch(e) {}



// EVENT HANDLERS


function _VirtualDom_makeCallback(eventNode, initialHandler)
{
	function callback(event)
	{
		var handler = callback.q;
		var result = _Json_runHelp(handler.a, event);

		if (!$elm$core$Result$isOk(result))
		{
			return;
		}

		var tag = $elm$virtual_dom$VirtualDom$toHandlerInt(handler);

		// 0 = Normal
		// 1 = MayStopPropagation
		// 2 = MayPreventDefault
		// 3 = Custom

		var value = result.a;
		var message = !tag ? value : tag < 3 ? value.a : value.message;
		var stopPropagation = tag == 1 ? value.b : tag == 3 && value.stopPropagation;
		var currentEventNode = (
			stopPropagation && event.stopPropagation(),
			(tag == 2 ? value.b : tag == 3 && value.preventDefault) && event.preventDefault(),
			eventNode
		);
		var tagger;
		var i;
		while (tagger = currentEventNode.j)
		{
			if (typeof tagger == 'function')
			{
				message = tagger(message);
			}
			else
			{
				for (var i = tagger.length; i--; )
				{
					message = tagger[i](message);
				}
			}
			currentEventNode = currentEventNode.p;
		}
		currentEventNode(message, stopPropagation); // stopPropagation implies isSync
	}

	callback.q = initialHandler;

	return callback;
}

function _VirtualDom_equalEvents(x, y)
{
	return x.$ == y.$ && _Json_equality(x.a, y.a);
}



// DIFF


// TODO: Should we do patches like in iOS?
//
// type Patch
//   = At Int Patch
//   | Batch (List Patch)
//   | Change ...
//
// How could it not be better?
//
function _VirtualDom_diff(x, y)
{
	var patches = [];
	_VirtualDom_diffHelp(x, y, patches, 0);
	return patches;
}


function _VirtualDom_pushPatch(patches, type, index, data)
{
	var patch = {
		$: type,
		r: index,
		s: data,
		t: undefined,
		u: undefined
	};
	patches.push(patch);
	return patch;
}


function _VirtualDom_diffHelp(x, y, patches, index)
{
	if (x === y)
	{
		return;
	}

	var xType = x.$;
	var yType = y.$;

	// Bail if you run into different types of nodes. Implies that the
	// structure has changed significantly and it's not worth a diff.
	if (xType !== yType)
	{
		if (xType === 1 && yType === 2)
		{
			y = _VirtualDom_dekey(y);
			yType = 1;
		}
		else
		{
			_VirtualDom_pushPatch(patches, 0, index, y);
			return;
		}
	}

	// Now we know that both nodes are the same $.
	switch (yType)
	{
		case 5:
			var xRefs = x.l;
			var yRefs = y.l;
			var i = xRefs.length;
			var same = i === yRefs.length;
			while (same && i--)
			{
				same = xRefs[i] === yRefs[i];
			}
			if (same)
			{
				y.k = x.k;
				return;
			}
			y.k = y.m();
			var subPatches = [];
			_VirtualDom_diffHelp(x.k, y.k, subPatches, 0);
			subPatches.length > 0 && _VirtualDom_pushPatch(patches, 1, index, subPatches);
			return;

		case 4:
			// gather nested taggers
			var xTaggers = x.j;
			var yTaggers = y.j;
			var nesting = false;

			var xSubNode = x.k;
			while (xSubNode.$ === 4)
			{
				nesting = true;

				typeof xTaggers !== 'object'
					? xTaggers = [xTaggers, xSubNode.j]
					: xTaggers.push(xSubNode.j);

				xSubNode = xSubNode.k;
			}

			var ySubNode = y.k;
			while (ySubNode.$ === 4)
			{
				nesting = true;

				typeof yTaggers !== 'object'
					? yTaggers = [yTaggers, ySubNode.j]
					: yTaggers.push(ySubNode.j);

				ySubNode = ySubNode.k;
			}

			// Just bail if different numbers of taggers. This implies the
			// structure of the virtual DOM has changed.
			if (nesting && xTaggers.length !== yTaggers.length)
			{
				_VirtualDom_pushPatch(patches, 0, index, y);
				return;
			}

			// check if taggers are "the same"
			if (nesting ? !_VirtualDom_pairwiseRefEqual(xTaggers, yTaggers) : xTaggers !== yTaggers)
			{
				_VirtualDom_pushPatch(patches, 2, index, yTaggers);
			}

			// diff everything below the taggers
			_VirtualDom_diffHelp(xSubNode, ySubNode, patches, index + 1);
			return;

		case 0:
			if (x.a !== y.a)
			{
				_VirtualDom_pushPatch(patches, 3, index, y.a);
			}
			return;

		case 1:
			_VirtualDom_diffNodes(x, y, patches, index, _VirtualDom_diffKids);
			return;

		case 2:
			_VirtualDom_diffNodes(x, y, patches, index, _VirtualDom_diffKeyedKids);
			return;

		case 3:
			if (x.h !== y.h)
			{
				_VirtualDom_pushPatch(patches, 0, index, y);
				return;
			}

			var factsDiff = _VirtualDom_diffFacts(x.d, y.d);
			factsDiff && _VirtualDom_pushPatch(patches, 4, index, factsDiff);

			var patch = y.i(x.g, y.g);
			patch && _VirtualDom_pushPatch(patches, 5, index, patch);

			return;
	}
}

// assumes the incoming arrays are the same length
function _VirtualDom_pairwiseRefEqual(as, bs)
{
	for (var i = 0; i < as.length; i++)
	{
		if (as[i] !== bs[i])
		{
			return false;
		}
	}

	return true;
}

function _VirtualDom_diffNodes(x, y, patches, index, diffKids)
{
	// Bail if obvious indicators have changed. Implies more serious
	// structural changes such that it's not worth it to diff.
	if (x.c !== y.c || x.f !== y.f)
	{
		_VirtualDom_pushPatch(patches, 0, index, y);
		return;
	}

	var factsDiff = _VirtualDom_diffFacts(x.d, y.d);
	factsDiff && _VirtualDom_pushPatch(patches, 4, index, factsDiff);

	diffKids(x, y, patches, index);
}



// DIFF FACTS


// TODO Instead of creating a new diff object, it's possible to just test if
// there *is* a diff. During the actual patch, do the diff again and make the
// modifications directly. This way, there's no new allocations. Worth it?
function _VirtualDom_diffFacts(x, y, category)
{
	var diff;

	// look for changes and removals
	for (var xKey in x)
	{
		if (xKey === 'a1' || xKey === 'a0' || xKey === 'a3' || xKey === 'a4')
		{
			var subDiff = _VirtualDom_diffFacts(x[xKey], y[xKey] || {}, xKey);
			if (subDiff)
			{
				diff = diff || {};
				diff[xKey] = subDiff;
			}
			continue;
		}

		// remove if not in the new facts
		if (!(xKey in y))
		{
			diff = diff || {};
			diff[xKey] =
				!category
					? (typeof x[xKey] === 'string' ? '' : null)
					:
				(category === 'a1')
					? ''
					:
				(category === 'a0' || category === 'a3')
					? undefined
					:
				{ f: x[xKey].f, o: undefined };

			continue;
		}

		var xValue = x[xKey];
		var yValue = y[xKey];

		// reference equal, so don't worry about it
		if (xValue === yValue && xKey !== 'value' && xKey !== 'checked'
			|| category === 'a0' && _VirtualDom_equalEvents(xValue, yValue))
		{
			continue;
		}

		diff = diff || {};
		diff[xKey] = yValue;
	}

	// add new stuff
	for (var yKey in y)
	{
		if (!(yKey in x))
		{
			diff = diff || {};
			diff[yKey] = y[yKey];
		}
	}

	return diff;
}



// DIFF KIDS


function _VirtualDom_diffKids(xParent, yParent, patches, index)
{
	var xKids = xParent.e;
	var yKids = yParent.e;

	var xLen = xKids.length;
	var yLen = yKids.length;

	// FIGURE OUT IF THERE ARE INSERTS OR REMOVALS

	if (xLen > yLen)
	{
		_VirtualDom_pushPatch(patches, 6, index, {
			v: yLen,
			i: xLen - yLen
		});
	}
	else if (xLen < yLen)
	{
		_VirtualDom_pushPatch(patches, 7, index, {
			v: xLen,
			e: yKids
		});
	}

	// PAIRWISE DIFF EVERYTHING ELSE

	for (var minLen = xLen < yLen ? xLen : yLen, i = 0; i < minLen; i++)
	{
		var xKid = xKids[i];
		_VirtualDom_diffHelp(xKid, yKids[i], patches, ++index);
		index += xKid.b || 0;
	}
}



// KEYED DIFF


function _VirtualDom_diffKeyedKids(xParent, yParent, patches, rootIndex)
{
	var localPatches = [];

	var changes = {}; // Dict String Entry
	var inserts = []; // Array { index : Int, entry : Entry }
	// type Entry = { tag : String, vnode : VNode, index : Int, data : _ }

	var xKids = xParent.e;
	var yKids = yParent.e;
	var xLen = xKids.length;
	var yLen = yKids.length;
	var xIndex = 0;
	var yIndex = 0;

	var index = rootIndex;

	while (xIndex < xLen && yIndex < yLen)
	{
		var x = xKids[xIndex];
		var y = yKids[yIndex];

		var xKey = x.a;
		var yKey = y.a;
		var xNode = x.b;
		var yNode = y.b;

		var newMatch = undefined;
		var oldMatch = undefined;

		// check if keys match

		if (xKey === yKey)
		{
			index++;
			_VirtualDom_diffHelp(xNode, yNode, localPatches, index);
			index += xNode.b || 0;

			xIndex++;
			yIndex++;
			continue;
		}

		// look ahead 1 to detect insertions and removals.

		var xNext = xKids[xIndex + 1];
		var yNext = yKids[yIndex + 1];

		if (xNext)
		{
			var xNextKey = xNext.a;
			var xNextNode = xNext.b;
			oldMatch = yKey === xNextKey;
		}

		if (yNext)
		{
			var yNextKey = yNext.a;
			var yNextNode = yNext.b;
			newMatch = xKey === yNextKey;
		}


		// swap x and y
		if (newMatch && oldMatch)
		{
			index++;
			_VirtualDom_diffHelp(xNode, yNextNode, localPatches, index);
			_VirtualDom_insertNode(changes, localPatches, xKey, yNode, yIndex, inserts);
			index += xNode.b || 0;

			index++;
			_VirtualDom_removeNode(changes, localPatches, xKey, xNextNode, index);
			index += xNextNode.b || 0;

			xIndex += 2;
			yIndex += 2;
			continue;
		}

		// insert y
		if (newMatch)
		{
			index++;
			_VirtualDom_insertNode(changes, localPatches, yKey, yNode, yIndex, inserts);
			_VirtualDom_diffHelp(xNode, yNextNode, localPatches, index);
			index += xNode.b || 0;

			xIndex += 1;
			yIndex += 2;
			continue;
		}

		// remove x
		if (oldMatch)
		{
			index++;
			_VirtualDom_removeNode(changes, localPatches, xKey, xNode, index);
			index += xNode.b || 0;

			index++;
			_VirtualDom_diffHelp(xNextNode, yNode, localPatches, index);
			index += xNextNode.b || 0;

			xIndex += 2;
			yIndex += 1;
			continue;
		}

		// remove x, insert y
		if (xNext && xNextKey === yNextKey)
		{
			index++;
			_VirtualDom_removeNode(changes, localPatches, xKey, xNode, index);
			_VirtualDom_insertNode(changes, localPatches, yKey, yNode, yIndex, inserts);
			index += xNode.b || 0;

			index++;
			_VirtualDom_diffHelp(xNextNode, yNextNode, localPatches, index);
			index += xNextNode.b || 0;

			xIndex += 2;
			yIndex += 2;
			continue;
		}

		break;
	}

	// eat up any remaining nodes with removeNode and insertNode

	while (xIndex < xLen)
	{
		index++;
		var x = xKids[xIndex];
		var xNode = x.b;
		_VirtualDom_removeNode(changes, localPatches, x.a, xNode, index);
		index += xNode.b || 0;
		xIndex++;
	}

	while (yIndex < yLen)
	{
		var endInserts = endInserts || [];
		var y = yKids[yIndex];
		_VirtualDom_insertNode(changes, localPatches, y.a, y.b, undefined, endInserts);
		yIndex++;
	}

	if (localPatches.length > 0 || inserts.length > 0 || endInserts)
	{
		_VirtualDom_pushPatch(patches, 8, rootIndex, {
			w: localPatches,
			x: inserts,
			y: endInserts
		});
	}
}



// CHANGES FROM KEYED DIFF


var _VirtualDom_POSTFIX = '_elmW6BL';


function _VirtualDom_insertNode(changes, localPatches, key, vnode, yIndex, inserts)
{
	var entry = changes[key];

	// never seen this key before
	if (!entry)
	{
		entry = {
			c: 0,
			z: vnode,
			r: yIndex,
			s: undefined
		};

		inserts.push({ r: yIndex, A: entry });
		changes[key] = entry;

		return;
	}

	// this key was removed earlier, a match!
	if (entry.c === 1)
	{
		inserts.push({ r: yIndex, A: entry });

		entry.c = 2;
		var subPatches = [];
		_VirtualDom_diffHelp(entry.z, vnode, subPatches, entry.r);
		entry.r = yIndex;
		entry.s.s = {
			w: subPatches,
			A: entry
		};

		return;
	}

	// this key has already been inserted or moved, a duplicate!
	_VirtualDom_insertNode(changes, localPatches, key + _VirtualDom_POSTFIX, vnode, yIndex, inserts);
}


function _VirtualDom_removeNode(changes, localPatches, key, vnode, index)
{
	var entry = changes[key];

	// never seen this key before
	if (!entry)
	{
		var patch = _VirtualDom_pushPatch(localPatches, 9, index, undefined);

		changes[key] = {
			c: 1,
			z: vnode,
			r: index,
			s: patch
		};

		return;
	}

	// this key was inserted earlier, a match!
	if (entry.c === 0)
	{
		entry.c = 2;
		var subPatches = [];
		_VirtualDom_diffHelp(vnode, entry.z, subPatches, index);

		_VirtualDom_pushPatch(localPatches, 9, index, {
			w: subPatches,
			A: entry
		});

		return;
	}

	// this key has already been removed or moved, a duplicate!
	_VirtualDom_removeNode(changes, localPatches, key + _VirtualDom_POSTFIX, vnode, index);
}



// ADD DOM NODES
//
// Each DOM node has an "index" assigned in order of traversal. It is important
// to minimize our crawl over the actual DOM, so these indexes (along with the
// descendantsCount of virtual nodes) let us skip touching entire subtrees of
// the DOM if we know there are no patches there.


function _VirtualDom_addDomNodes(domNode, vNode, patches, eventNode)
{
	_VirtualDom_addDomNodesHelp(domNode, vNode, patches, 0, 0, vNode.b, eventNode);
}


// assumes `patches` is non-empty and indexes increase monotonically.
function _VirtualDom_addDomNodesHelp(domNode, vNode, patches, i, low, high, eventNode)
{
	var patch = patches[i];
	var index = patch.r;

	while (index === low)
	{
		var patchType = patch.$;

		if (patchType === 1)
		{
			_VirtualDom_addDomNodes(domNode, vNode.k, patch.s, eventNode);
		}
		else if (patchType === 8)
		{
			patch.t = domNode;
			patch.u = eventNode;

			var subPatches = patch.s.w;
			if (subPatches.length > 0)
			{
				_VirtualDom_addDomNodesHelp(domNode, vNode, subPatches, 0, low, high, eventNode);
			}
		}
		else if (patchType === 9)
		{
			patch.t = domNode;
			patch.u = eventNode;

			var data = patch.s;
			if (data)
			{
				data.A.s = domNode;
				var subPatches = data.w;
				if (subPatches.length > 0)
				{
					_VirtualDom_addDomNodesHelp(domNode, vNode, subPatches, 0, low, high, eventNode);
				}
			}
		}
		else
		{
			patch.t = domNode;
			patch.u = eventNode;
		}

		i++;

		if (!(patch = patches[i]) || (index = patch.r) > high)
		{
			return i;
		}
	}

	var tag = vNode.$;

	if (tag === 4)
	{
		var subNode = vNode.k;

		while (subNode.$ === 4)
		{
			subNode = subNode.k;
		}

		return _VirtualDom_addDomNodesHelp(domNode, subNode, patches, i, low + 1, high, domNode.elm_event_node_ref);
	}

	// tag must be 1 or 2 at this point

	var vKids = vNode.e;
	var childNodes = domNode.childNodes;
	for (var j = 0; j < vKids.length; j++)
	{
		low++;
		var vKid = tag === 1 ? vKids[j] : vKids[j].b;
		var nextLow = low + (vKid.b || 0);
		if (low <= index && index <= nextLow)
		{
			i = _VirtualDom_addDomNodesHelp(childNodes[j], vKid, patches, i, low, nextLow, eventNode);
			if (!(patch = patches[i]) || (index = patch.r) > high)
			{
				return i;
			}
		}
		low = nextLow;
	}
	return i;
}



// APPLY PATCHES


function _VirtualDom_applyPatches(rootDomNode, oldVirtualNode, patches, eventNode)
{
	if (patches.length === 0)
	{
		return rootDomNode;
	}

	_VirtualDom_addDomNodes(rootDomNode, oldVirtualNode, patches, eventNode);
	return _VirtualDom_applyPatchesHelp(rootDomNode, patches);
}

function _VirtualDom_applyPatchesHelp(rootDomNode, patches)
{
	for (var i = 0; i < patches.length; i++)
	{
		var patch = patches[i];
		var localDomNode = patch.t
		var newNode = _VirtualDom_applyPatch(localDomNode, patch);
		if (localDomNode === rootDomNode)
		{
			rootDomNode = newNode;
		}
	}
	return rootDomNode;
}

function _VirtualDom_applyPatch(domNode, patch)
{
	switch (patch.$)
	{
		case 0:
			return _VirtualDom_applyPatchRedraw(domNode, patch.s, patch.u);

		case 4:
			_VirtualDom_applyFacts(domNode, patch.u, patch.s);
			return domNode;

		case 3:
			domNode.replaceData(0, domNode.length, patch.s);
			return domNode;

		case 1:
			return _VirtualDom_applyPatchesHelp(domNode, patch.s);

		case 2:
			if (domNode.elm_event_node_ref)
			{
				domNode.elm_event_node_ref.j = patch.s;
			}
			else
			{
				domNode.elm_event_node_ref = { j: patch.s, p: patch.u };
			}
			return domNode;

		case 6:
			var data = patch.s;
			for (var i = 0; i < data.i; i++)
			{
				domNode.removeChild(domNode.childNodes[data.v]);
			}
			return domNode;

		case 7:
			var data = patch.s;
			var kids = data.e;
			var i = data.v;
			var theEnd = domNode.childNodes[i];
			for (; i < kids.length; i++)
			{
				domNode.insertBefore(_VirtualDom_render(kids[i], patch.u), theEnd);
			}
			return domNode;

		case 9:
			var data = patch.s;
			if (!data)
			{
				domNode.parentNode.removeChild(domNode);
				return domNode;
			}
			var entry = data.A;
			if (typeof entry.r !== 'undefined')
			{
				domNode.parentNode.removeChild(domNode);
			}
			entry.s = _VirtualDom_applyPatchesHelp(domNode, data.w);
			return domNode;

		case 8:
			return _VirtualDom_applyPatchReorder(domNode, patch);

		case 5:
			return patch.s(domNode);

		default:
			_Debug_crash(10); // 'Ran into an unknown patch!'
	}
}


function _VirtualDom_applyPatchRedraw(domNode, vNode, eventNode)
{
	var parentNode = domNode.parentNode;
	var newNode = _VirtualDom_render(vNode, eventNode);

	if (!newNode.elm_event_node_ref)
	{
		newNode.elm_event_node_ref = domNode.elm_event_node_ref;
	}

	if (parentNode && newNode !== domNode)
	{
		parentNode.replaceChild(newNode, domNode);
	}
	return newNode;
}


function _VirtualDom_applyPatchReorder(domNode, patch)
{
	var data = patch.s;

	// remove end inserts
	var frag = _VirtualDom_applyPatchReorderEndInsertsHelp(data.y, patch);

	// removals
	domNode = _VirtualDom_applyPatchesHelp(domNode, data.w);

	// inserts
	var inserts = data.x;
	for (var i = 0; i < inserts.length; i++)
	{
		var insert = inserts[i];
		var entry = insert.A;
		var node = entry.c === 2
			? entry.s
			: _VirtualDom_render(entry.z, patch.u);
		domNode.insertBefore(node, domNode.childNodes[insert.r]);
	}

	// add end inserts
	if (frag)
	{
		_VirtualDom_appendChild(domNode, frag);
	}

	return domNode;
}


function _VirtualDom_applyPatchReorderEndInsertsHelp(endInserts, patch)
{
	if (!endInserts)
	{
		return;
	}

	var frag = _VirtualDom_doc.createDocumentFragment();
	for (var i = 0; i < endInserts.length; i++)
	{
		var insert = endInserts[i];
		var entry = insert.A;
		_VirtualDom_appendChild(frag, entry.c === 2
			? entry.s
			: _VirtualDom_render(entry.z, patch.u)
		);
	}
	return frag;
}


function _VirtualDom_virtualize(node)
{
	// TEXT NODES

	if (node.nodeType === 3)
	{
		return _VirtualDom_text(node.textContent);
	}


	// WEIRD NODES

	if (node.nodeType !== 1)
	{
		return _VirtualDom_text('');
	}


	// ELEMENT NODES

	var attrList = _List_Nil;
	var attrs = node.attributes;
	for (var i = attrs.length; i--; )
	{
		var attr = attrs[i];
		var name = attr.name;
		var value = attr.value;
		attrList = _List_Cons( A2(_VirtualDom_attribute, name, value), attrList );
	}

	var tag = node.tagName.toLowerCase();
	var kidList = _List_Nil;
	var kids = node.childNodes;

	for (var i = kids.length; i--; )
	{
		kidList = _List_Cons(_VirtualDom_virtualize(kids[i]), kidList);
	}
	return A3(_VirtualDom_node, tag, attrList, kidList);
}

function _VirtualDom_dekey(keyedNode)
{
	var keyedKids = keyedNode.e;
	var len = keyedKids.length;
	var kids = new Array(len);
	for (var i = 0; i < len; i++)
	{
		kids[i] = keyedKids[i].b;
	}

	return {
		$: 1,
		c: keyedNode.c,
		d: keyedNode.d,
		e: kids,
		f: keyedNode.f,
		b: keyedNode.b
	};
}




// ELEMENT


var _Debugger_element;

var _Browser_element = _Debugger_element || F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.init,
		impl.update,
		impl.subscriptions,
		function(sendToApp, initialModel) {
			var view = impl.view;
			/**_UNUSED/
			var domNode = args['node'];
			//*/
			/**/
			var domNode = args && args['node'] ? args['node'] : _Debug_crash(0);
			//*/
			var currNode = _VirtualDom_virtualize(domNode);

			return _Browser_makeAnimator(initialModel, function(model)
			{
				var nextNode = view(model);
				var patches = _VirtualDom_diff(currNode, nextNode);
				domNode = _VirtualDom_applyPatches(domNode, currNode, patches, sendToApp);
				currNode = nextNode;
			});
		}
	);
});



// DOCUMENT


var _Debugger_document;

var _Browser_document = _Debugger_document || F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.init,
		impl.update,
		impl.subscriptions,
		function(sendToApp, initialModel) {
			var divertHrefToApp = impl.setup && impl.setup(sendToApp)
			var view = impl.view;
			var title = _VirtualDom_doc.title;
			var bodyNode = _VirtualDom_doc.body;
			var currNode = _VirtualDom_virtualize(bodyNode);
			return _Browser_makeAnimator(initialModel, function(model)
			{
				_VirtualDom_divertHrefToApp = divertHrefToApp;
				var doc = view(model);
				var nextNode = _VirtualDom_node('body')(_List_Nil)(doc.body);
				var patches = _VirtualDom_diff(currNode, nextNode);
				bodyNode = _VirtualDom_applyPatches(bodyNode, currNode, patches, sendToApp);
				currNode = nextNode;
				_VirtualDom_divertHrefToApp = 0;
				(title !== doc.title) && (_VirtualDom_doc.title = title = doc.title);
			});
		}
	);
});



// ANIMATION


var _Browser_cancelAnimationFrame =
	typeof cancelAnimationFrame !== 'undefined'
		? cancelAnimationFrame
		: function(id) { clearTimeout(id); };

var _Browser_requestAnimationFrame =
	typeof requestAnimationFrame !== 'undefined'
		? requestAnimationFrame
		: function(callback) { return setTimeout(callback, 1000 / 60); };


function _Browser_makeAnimator(model, draw)
{
	draw(model);

	var state = 0;

	function updateIfNeeded()
	{
		state = state === 1
			? 0
			: ( _Browser_requestAnimationFrame(updateIfNeeded), draw(model), 1 );
	}

	return function(nextModel, isSync)
	{
		model = nextModel;

		isSync
			? ( draw(model),
				state === 2 && (state = 1)
				)
			: ( state === 0 && _Browser_requestAnimationFrame(updateIfNeeded),
				state = 2
				);
	};
}



// APPLICATION


function _Browser_application(impl)
{
	var onUrlChange = impl.onUrlChange;
	var onUrlRequest = impl.onUrlRequest;
	var key = function() { key.a(onUrlChange(_Browser_getUrl())); };

	return _Browser_document({
		setup: function(sendToApp)
		{
			key.a = sendToApp;
			_Browser_window.addEventListener('popstate', key);
			_Browser_window.navigator.userAgent.indexOf('Trident') < 0 || _Browser_window.addEventListener('hashchange', key);

			return F2(function(domNode, event)
			{
				if (!event.ctrlKey && !event.metaKey && !event.shiftKey && event.button < 1 && !domNode.target && !domNode.hasAttribute('download'))
				{
					event.preventDefault();
					var href = domNode.href;
					var curr = _Browser_getUrl();
					var next = $elm$url$Url$fromString(href).a;
					sendToApp(onUrlRequest(
						(next
							&& curr.protocol === next.protocol
							&& curr.host === next.host
							&& curr.port_.a === next.port_.a
						)
							? $elm$browser$Browser$Internal(next)
							: $elm$browser$Browser$External(href)
					));
				}
			});
		},
		init: function(flags)
		{
			return A3(impl.init, flags, _Browser_getUrl(), key);
		},
		view: impl.view,
		update: impl.update,
		subscriptions: impl.subscriptions
	});
}

function _Browser_getUrl()
{
	return $elm$url$Url$fromString(_VirtualDom_doc.location.href).a || _Debug_crash(1);
}

var _Browser_go = F2(function(key, n)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function() {
		n && history.go(n);
		key();
	}));
});

var _Browser_pushUrl = F2(function(key, url)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function() {
		history.pushState({}, '', url);
		key();
	}));
});

var _Browser_replaceUrl = F2(function(key, url)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function() {
		history.replaceState({}, '', url);
		key();
	}));
});



// GLOBAL EVENTS


var _Browser_fakeNode = { addEventListener: function() {}, removeEventListener: function() {} };
var _Browser_doc = typeof document !== 'undefined' ? document : _Browser_fakeNode;
var _Browser_window = typeof window !== 'undefined' ? window : _Browser_fakeNode;

var _Browser_on = F3(function(node, eventName, sendToSelf)
{
	return _Scheduler_spawn(_Scheduler_binding(function(callback)
	{
		function handler(event)	{ _Scheduler_rawSpawn(sendToSelf(event)); }
		node.addEventListener(eventName, handler, _VirtualDom_passiveSupported && { passive: true });
		return function() { node.removeEventListener(eventName, handler); };
	}));
});

var _Browser_decodeEvent = F2(function(decoder, event)
{
	var result = _Json_runHelp(decoder, event);
	return $elm$core$Result$isOk(result) ? $elm$core$Maybe$Just(result.a) : $elm$core$Maybe$Nothing;
});



// PAGE VISIBILITY


function _Browser_visibilityInfo()
{
	return (typeof _VirtualDom_doc.hidden !== 'undefined')
		? { hidden: 'hidden', change: 'visibilitychange' }
		:
	(typeof _VirtualDom_doc.mozHidden !== 'undefined')
		? { hidden: 'mozHidden', change: 'mozvisibilitychange' }
		:
	(typeof _VirtualDom_doc.msHidden !== 'undefined')
		? { hidden: 'msHidden', change: 'msvisibilitychange' }
		:
	(typeof _VirtualDom_doc.webkitHidden !== 'undefined')
		? { hidden: 'webkitHidden', change: 'webkitvisibilitychange' }
		: { hidden: 'hidden', change: 'visibilitychange' };
}



// ANIMATION FRAMES


function _Browser_rAF()
{
	return _Scheduler_binding(function(callback)
	{
		var id = _Browser_requestAnimationFrame(function() {
			callback(_Scheduler_succeed(Date.now()));
		});

		return function() {
			_Browser_cancelAnimationFrame(id);
		};
	});
}


function _Browser_now()
{
	return _Scheduler_binding(function(callback)
	{
		callback(_Scheduler_succeed(Date.now()));
	});
}



// DOM STUFF


function _Browser_withNode(id, doStuff)
{
	return _Scheduler_binding(function(callback)
	{
		_Browser_requestAnimationFrame(function() {
			var node = document.getElementById(id);
			callback(node
				? _Scheduler_succeed(doStuff(node))
				: _Scheduler_fail($elm$browser$Browser$Dom$NotFound(id))
			);
		});
	});
}


function _Browser_withWindow(doStuff)
{
	return _Scheduler_binding(function(callback)
	{
		_Browser_requestAnimationFrame(function() {
			callback(_Scheduler_succeed(doStuff()));
		});
	});
}


// FOCUS and BLUR


var _Browser_call = F2(function(functionName, id)
{
	return _Browser_withNode(id, function(node) {
		node[functionName]();
		return _Utils_Tuple0;
	});
});



// WINDOW VIEWPORT


function _Browser_getViewport()
{
	return {
		scene: _Browser_getScene(),
		viewport: {
			x: _Browser_window.pageXOffset,
			y: _Browser_window.pageYOffset,
			width: _Browser_doc.documentElement.clientWidth,
			height: _Browser_doc.documentElement.clientHeight
		}
	};
}

function _Browser_getScene()
{
	var body = _Browser_doc.body;
	var elem = _Browser_doc.documentElement;
	return {
		width: Math.max(body.scrollWidth, body.offsetWidth, elem.scrollWidth, elem.offsetWidth, elem.clientWidth),
		height: Math.max(body.scrollHeight, body.offsetHeight, elem.scrollHeight, elem.offsetHeight, elem.clientHeight)
	};
}

var _Browser_setViewport = F2(function(x, y)
{
	return _Browser_withWindow(function()
	{
		_Browser_window.scroll(x, y);
		return _Utils_Tuple0;
	});
});



// ELEMENT VIEWPORT


function _Browser_getViewportOf(id)
{
	return _Browser_withNode(id, function(node)
	{
		return {
			scene: {
				width: node.scrollWidth,
				height: node.scrollHeight
			},
			viewport: {
				x: node.scrollLeft,
				y: node.scrollTop,
				width: node.clientWidth,
				height: node.clientHeight
			}
		};
	});
}


var _Browser_setViewportOf = F3(function(id, x, y)
{
	return _Browser_withNode(id, function(node)
	{
		node.scrollLeft = x;
		node.scrollTop = y;
		return _Utils_Tuple0;
	});
});



// ELEMENT


function _Browser_getElement(id)
{
	return _Browser_withNode(id, function(node)
	{
		var rect = node.getBoundingClientRect();
		var x = _Browser_window.pageXOffset;
		var y = _Browser_window.pageYOffset;
		return {
			scene: _Browser_getScene(),
			viewport: {
				x: x,
				y: y,
				width: _Browser_doc.documentElement.clientWidth,
				height: _Browser_doc.documentElement.clientHeight
			},
			element: {
				x: x + rect.left,
				y: y + rect.top,
				width: rect.width,
				height: rect.height
			}
		};
	});
}



// LOAD and RELOAD


function _Browser_reload(skipCache)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function(callback)
	{
		_VirtualDom_doc.location.reload(skipCache);
	}));
}

function _Browser_load(url)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function(callback)
	{
		try
		{
			_Browser_window.location = url;
		}
		catch(err)
		{
			// Only Firefox can throw a NS_ERROR_MALFORMED_URI exception here.
			// Other browsers reload the page, so let's be consistent about that.
			_VirtualDom_doc.location.reload(false);
		}
	}));
}



function _Time_now(millisToPosix)
{
	return _Scheduler_binding(function(callback)
	{
		callback(_Scheduler_succeed(millisToPosix(Date.now())));
	});
}

var _Time_setInterval = F2(function(interval, task)
{
	return _Scheduler_binding(function(callback)
	{
		var id = setInterval(function() { _Scheduler_rawSpawn(task); }, interval);
		return function() { clearInterval(id); };
	});
});

function _Time_here()
{
	return _Scheduler_binding(function(callback)
	{
		callback(_Scheduler_succeed(
			A2($elm$time$Time$customZone, -(new Date().getTimezoneOffset()), _List_Nil)
		));
	});
}


function _Time_getZoneName()
{
	return _Scheduler_binding(function(callback)
	{
		try
		{
			var name = $elm$time$Time$Name(Intl.DateTimeFormat().resolvedOptions().timeZone);
		}
		catch (e)
		{
			var name = $elm$time$Time$Offset(new Date().getTimezoneOffset());
		}
		callback(_Scheduler_succeed(name));
	});
}



var _Bitwise_and = F2(function(a, b)
{
	return a & b;
});

var _Bitwise_or = F2(function(a, b)
{
	return a | b;
});

var _Bitwise_xor = F2(function(a, b)
{
	return a ^ b;
});

function _Bitwise_complement(a)
{
	return ~a;
};

var _Bitwise_shiftLeftBy = F2(function(offset, a)
{
	return a << offset;
});

var _Bitwise_shiftRightBy = F2(function(offset, a)
{
	return a >> offset;
});

var _Bitwise_shiftRightZfBy = F2(function(offset, a)
{
	return a >>> offset;
});
var $elm$core$Basics$EQ = {$: 'EQ'};
var $elm$core$Basics$GT = {$: 'GT'};
var $elm$core$Basics$LT = {$: 'LT'};
var $elm$core$List$cons = _List_cons;
var $elm$core$Dict$foldr = F3(
	function (func, acc, t) {
		foldr:
		while (true) {
			if (t.$ === 'RBEmpty_elm_builtin') {
				return acc;
			} else {
				var key = t.b;
				var value = t.c;
				var left = t.d;
				var right = t.e;
				var $temp$func = func,
					$temp$acc = A3(
					func,
					key,
					value,
					A3($elm$core$Dict$foldr, func, acc, right)),
					$temp$t = left;
				func = $temp$func;
				acc = $temp$acc;
				t = $temp$t;
				continue foldr;
			}
		}
	});
var $elm$core$Dict$toList = function (dict) {
	return A3(
		$elm$core$Dict$foldr,
		F3(
			function (key, value, list) {
				return A2(
					$elm$core$List$cons,
					_Utils_Tuple2(key, value),
					list);
			}),
		_List_Nil,
		dict);
};
var $elm$core$Dict$keys = function (dict) {
	return A3(
		$elm$core$Dict$foldr,
		F3(
			function (key, value, keyList) {
				return A2($elm$core$List$cons, key, keyList);
			}),
		_List_Nil,
		dict);
};
var $elm$core$Set$toList = function (_v0) {
	var dict = _v0.a;
	return $elm$core$Dict$keys(dict);
};
var $elm$core$Elm$JsArray$foldr = _JsArray_foldr;
var $elm$core$Array$foldr = F3(
	function (func, baseCase, _v0) {
		var tree = _v0.c;
		var tail = _v0.d;
		var helper = F2(
			function (node, acc) {
				if (node.$ === 'SubTree') {
					var subTree = node.a;
					return A3($elm$core$Elm$JsArray$foldr, helper, acc, subTree);
				} else {
					var values = node.a;
					return A3($elm$core$Elm$JsArray$foldr, func, acc, values);
				}
			});
		return A3(
			$elm$core$Elm$JsArray$foldr,
			helper,
			A3($elm$core$Elm$JsArray$foldr, func, baseCase, tail),
			tree);
	});
var $elm$core$Array$toList = function (array) {
	return A3($elm$core$Array$foldr, $elm$core$List$cons, _List_Nil, array);
};
var $elm$core$Result$Err = function (a) {
	return {$: 'Err', a: a};
};
var $elm$json$Json$Decode$Failure = F2(
	function (a, b) {
		return {$: 'Failure', a: a, b: b};
	});
var $elm$json$Json$Decode$Field = F2(
	function (a, b) {
		return {$: 'Field', a: a, b: b};
	});
var $elm$json$Json$Decode$Index = F2(
	function (a, b) {
		return {$: 'Index', a: a, b: b};
	});
var $elm$core$Result$Ok = function (a) {
	return {$: 'Ok', a: a};
};
var $elm$json$Json$Decode$OneOf = function (a) {
	return {$: 'OneOf', a: a};
};
var $elm$core$Basics$False = {$: 'False'};
var $elm$core$Basics$add = _Basics_add;
var $elm$core$Maybe$Just = function (a) {
	return {$: 'Just', a: a};
};
var $elm$core$Maybe$Nothing = {$: 'Nothing'};
var $elm$core$String$all = _String_all;
var $elm$core$Basics$and = _Basics_and;
var $elm$core$Basics$append = _Utils_append;
var $elm$json$Json$Encode$encode = _Json_encode;
var $elm$core$String$fromInt = _String_fromNumber;
var $elm$core$String$join = F2(
	function (sep, chunks) {
		return A2(
			_String_join,
			sep,
			_List_toArray(chunks));
	});
var $elm$core$String$split = F2(
	function (sep, string) {
		return _List_fromArray(
			A2(_String_split, sep, string));
	});
var $elm$json$Json$Decode$indent = function (str) {
	return A2(
		$elm$core$String$join,
		'\n    ',
		A2($elm$core$String$split, '\n', str));
};
var $elm$core$List$foldl = F3(
	function (func, acc, list) {
		foldl:
		while (true) {
			if (!list.b) {
				return acc;
			} else {
				var x = list.a;
				var xs = list.b;
				var $temp$func = func,
					$temp$acc = A2(func, x, acc),
					$temp$list = xs;
				func = $temp$func;
				acc = $temp$acc;
				list = $temp$list;
				continue foldl;
			}
		}
	});
var $elm$core$List$length = function (xs) {
	return A3(
		$elm$core$List$foldl,
		F2(
			function (_v0, i) {
				return i + 1;
			}),
		0,
		xs);
};
var $elm$core$List$map2 = _List_map2;
var $elm$core$Basics$le = _Utils_le;
var $elm$core$Basics$sub = _Basics_sub;
var $elm$core$List$rangeHelp = F3(
	function (lo, hi, list) {
		rangeHelp:
		while (true) {
			if (_Utils_cmp(lo, hi) < 1) {
				var $temp$lo = lo,
					$temp$hi = hi - 1,
					$temp$list = A2($elm$core$List$cons, hi, list);
				lo = $temp$lo;
				hi = $temp$hi;
				list = $temp$list;
				continue rangeHelp;
			} else {
				return list;
			}
		}
	});
var $elm$core$List$range = F2(
	function (lo, hi) {
		return A3($elm$core$List$rangeHelp, lo, hi, _List_Nil);
	});
var $elm$core$List$indexedMap = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$map2,
			f,
			A2(
				$elm$core$List$range,
				0,
				$elm$core$List$length(xs) - 1),
			xs);
	});
var $elm$core$Char$toCode = _Char_toCode;
var $elm$core$Char$isLower = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (97 <= code) && (code <= 122);
};
var $elm$core$Char$isUpper = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (code <= 90) && (65 <= code);
};
var $elm$core$Basics$or = _Basics_or;
var $elm$core$Char$isAlpha = function (_char) {
	return $elm$core$Char$isLower(_char) || $elm$core$Char$isUpper(_char);
};
var $elm$core$Char$isDigit = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (code <= 57) && (48 <= code);
};
var $elm$core$Char$isAlphaNum = function (_char) {
	return $elm$core$Char$isLower(_char) || ($elm$core$Char$isUpper(_char) || $elm$core$Char$isDigit(_char));
};
var $elm$core$List$reverse = function (list) {
	return A3($elm$core$List$foldl, $elm$core$List$cons, _List_Nil, list);
};
var $elm$core$String$uncons = _String_uncons;
var $elm$json$Json$Decode$errorOneOf = F2(
	function (i, error) {
		return '\n\n(' + ($elm$core$String$fromInt(i + 1) + (') ' + $elm$json$Json$Decode$indent(
			$elm$json$Json$Decode$errorToString(error))));
	});
var $elm$json$Json$Decode$errorToString = function (error) {
	return A2($elm$json$Json$Decode$errorToStringHelp, error, _List_Nil);
};
var $elm$json$Json$Decode$errorToStringHelp = F2(
	function (error, context) {
		errorToStringHelp:
		while (true) {
			switch (error.$) {
				case 'Field':
					var f = error.a;
					var err = error.b;
					var isSimple = function () {
						var _v1 = $elm$core$String$uncons(f);
						if (_v1.$ === 'Nothing') {
							return false;
						} else {
							var _v2 = _v1.a;
							var _char = _v2.a;
							var rest = _v2.b;
							return $elm$core$Char$isAlpha(_char) && A2($elm$core$String$all, $elm$core$Char$isAlphaNum, rest);
						}
					}();
					var fieldName = isSimple ? ('.' + f) : ('[\'' + (f + '\']'));
					var $temp$error = err,
						$temp$context = A2($elm$core$List$cons, fieldName, context);
					error = $temp$error;
					context = $temp$context;
					continue errorToStringHelp;
				case 'Index':
					var i = error.a;
					var err = error.b;
					var indexName = '[' + ($elm$core$String$fromInt(i) + ']');
					var $temp$error = err,
						$temp$context = A2($elm$core$List$cons, indexName, context);
					error = $temp$error;
					context = $temp$context;
					continue errorToStringHelp;
				case 'OneOf':
					var errors = error.a;
					if (!errors.b) {
						return 'Ran into a Json.Decode.oneOf with no possibilities' + function () {
							if (!context.b) {
								return '!';
							} else {
								return ' at json' + A2(
									$elm$core$String$join,
									'',
									$elm$core$List$reverse(context));
							}
						}();
					} else {
						if (!errors.b.b) {
							var err = errors.a;
							var $temp$error = err,
								$temp$context = context;
							error = $temp$error;
							context = $temp$context;
							continue errorToStringHelp;
						} else {
							var starter = function () {
								if (!context.b) {
									return 'Json.Decode.oneOf';
								} else {
									return 'The Json.Decode.oneOf at json' + A2(
										$elm$core$String$join,
										'',
										$elm$core$List$reverse(context));
								}
							}();
							var introduction = starter + (' failed in the following ' + ($elm$core$String$fromInt(
								$elm$core$List$length(errors)) + ' ways:'));
							return A2(
								$elm$core$String$join,
								'\n\n',
								A2(
									$elm$core$List$cons,
									introduction,
									A2($elm$core$List$indexedMap, $elm$json$Json$Decode$errorOneOf, errors)));
						}
					}
				default:
					var msg = error.a;
					var json = error.b;
					var introduction = function () {
						if (!context.b) {
							return 'Problem with the given value:\n\n';
						} else {
							return 'Problem with the value at json' + (A2(
								$elm$core$String$join,
								'',
								$elm$core$List$reverse(context)) + ':\n\n    ');
						}
					}();
					return introduction + ($elm$json$Json$Decode$indent(
						A2($elm$json$Json$Encode$encode, 4, json)) + ('\n\n' + msg));
			}
		}
	});
var $elm$core$Array$branchFactor = 32;
var $elm$core$Array$Array_elm_builtin = F4(
	function (a, b, c, d) {
		return {$: 'Array_elm_builtin', a: a, b: b, c: c, d: d};
	});
var $elm$core$Elm$JsArray$empty = _JsArray_empty;
var $elm$core$Basics$ceiling = _Basics_ceiling;
var $elm$core$Basics$fdiv = _Basics_fdiv;
var $elm$core$Basics$logBase = F2(
	function (base, number) {
		return _Basics_log(number) / _Basics_log(base);
	});
var $elm$core$Basics$toFloat = _Basics_toFloat;
var $elm$core$Array$shiftStep = $elm$core$Basics$ceiling(
	A2($elm$core$Basics$logBase, 2, $elm$core$Array$branchFactor));
var $elm$core$Array$empty = A4($elm$core$Array$Array_elm_builtin, 0, $elm$core$Array$shiftStep, $elm$core$Elm$JsArray$empty, $elm$core$Elm$JsArray$empty);
var $elm$core$Elm$JsArray$initialize = _JsArray_initialize;
var $elm$core$Array$Leaf = function (a) {
	return {$: 'Leaf', a: a};
};
var $elm$core$Basics$apL = F2(
	function (f, x) {
		return f(x);
	});
var $elm$core$Basics$apR = F2(
	function (x, f) {
		return f(x);
	});
var $elm$core$Basics$eq = _Utils_equal;
var $elm$core$Basics$floor = _Basics_floor;
var $elm$core$Elm$JsArray$length = _JsArray_length;
var $elm$core$Basics$gt = _Utils_gt;
var $elm$core$Basics$max = F2(
	function (x, y) {
		return (_Utils_cmp(x, y) > 0) ? x : y;
	});
var $elm$core$Basics$mul = _Basics_mul;
var $elm$core$Array$SubTree = function (a) {
	return {$: 'SubTree', a: a};
};
var $elm$core$Elm$JsArray$initializeFromList = _JsArray_initializeFromList;
var $elm$core$Array$compressNodes = F2(
	function (nodes, acc) {
		compressNodes:
		while (true) {
			var _v0 = A2($elm$core$Elm$JsArray$initializeFromList, $elm$core$Array$branchFactor, nodes);
			var node = _v0.a;
			var remainingNodes = _v0.b;
			var newAcc = A2(
				$elm$core$List$cons,
				$elm$core$Array$SubTree(node),
				acc);
			if (!remainingNodes.b) {
				return $elm$core$List$reverse(newAcc);
			} else {
				var $temp$nodes = remainingNodes,
					$temp$acc = newAcc;
				nodes = $temp$nodes;
				acc = $temp$acc;
				continue compressNodes;
			}
		}
	});
var $elm$core$Tuple$first = function (_v0) {
	var x = _v0.a;
	return x;
};
var $elm$core$Array$treeFromBuilder = F2(
	function (nodeList, nodeListSize) {
		treeFromBuilder:
		while (true) {
			var newNodeSize = $elm$core$Basics$ceiling(nodeListSize / $elm$core$Array$branchFactor);
			if (newNodeSize === 1) {
				return A2($elm$core$Elm$JsArray$initializeFromList, $elm$core$Array$branchFactor, nodeList).a;
			} else {
				var $temp$nodeList = A2($elm$core$Array$compressNodes, nodeList, _List_Nil),
					$temp$nodeListSize = newNodeSize;
				nodeList = $temp$nodeList;
				nodeListSize = $temp$nodeListSize;
				continue treeFromBuilder;
			}
		}
	});
var $elm$core$Array$builderToArray = F2(
	function (reverseNodeList, builder) {
		if (!builder.nodeListSize) {
			return A4(
				$elm$core$Array$Array_elm_builtin,
				$elm$core$Elm$JsArray$length(builder.tail),
				$elm$core$Array$shiftStep,
				$elm$core$Elm$JsArray$empty,
				builder.tail);
		} else {
			var treeLen = builder.nodeListSize * $elm$core$Array$branchFactor;
			var depth = $elm$core$Basics$floor(
				A2($elm$core$Basics$logBase, $elm$core$Array$branchFactor, treeLen - 1));
			var correctNodeList = reverseNodeList ? $elm$core$List$reverse(builder.nodeList) : builder.nodeList;
			var tree = A2($elm$core$Array$treeFromBuilder, correctNodeList, builder.nodeListSize);
			return A4(
				$elm$core$Array$Array_elm_builtin,
				$elm$core$Elm$JsArray$length(builder.tail) + treeLen,
				A2($elm$core$Basics$max, 5, depth * $elm$core$Array$shiftStep),
				tree,
				builder.tail);
		}
	});
var $elm$core$Basics$idiv = _Basics_idiv;
var $elm$core$Basics$lt = _Utils_lt;
var $elm$core$Array$initializeHelp = F5(
	function (fn, fromIndex, len, nodeList, tail) {
		initializeHelp:
		while (true) {
			if (fromIndex < 0) {
				return A2(
					$elm$core$Array$builderToArray,
					false,
					{nodeList: nodeList, nodeListSize: (len / $elm$core$Array$branchFactor) | 0, tail: tail});
			} else {
				var leaf = $elm$core$Array$Leaf(
					A3($elm$core$Elm$JsArray$initialize, $elm$core$Array$branchFactor, fromIndex, fn));
				var $temp$fn = fn,
					$temp$fromIndex = fromIndex - $elm$core$Array$branchFactor,
					$temp$len = len,
					$temp$nodeList = A2($elm$core$List$cons, leaf, nodeList),
					$temp$tail = tail;
				fn = $temp$fn;
				fromIndex = $temp$fromIndex;
				len = $temp$len;
				nodeList = $temp$nodeList;
				tail = $temp$tail;
				continue initializeHelp;
			}
		}
	});
var $elm$core$Basics$remainderBy = _Basics_remainderBy;
var $elm$core$Array$initialize = F2(
	function (len, fn) {
		if (len <= 0) {
			return $elm$core$Array$empty;
		} else {
			var tailLen = len % $elm$core$Array$branchFactor;
			var tail = A3($elm$core$Elm$JsArray$initialize, tailLen, len - tailLen, fn);
			var initialFromIndex = (len - tailLen) - $elm$core$Array$branchFactor;
			return A5($elm$core$Array$initializeHelp, fn, initialFromIndex, len, _List_Nil, tail);
		}
	});
var $elm$core$Basics$True = {$: 'True'};
var $elm$core$Result$isOk = function (result) {
	if (result.$ === 'Ok') {
		return true;
	} else {
		return false;
	}
};
var $elm$json$Json$Decode$map = _Json_map1;
var $elm$json$Json$Decode$map2 = _Json_map2;
var $elm$json$Json$Decode$succeed = _Json_succeed;
var $elm$virtual_dom$VirtualDom$toHandlerInt = function (handler) {
	switch (handler.$) {
		case 'Normal':
			return 0;
		case 'MayStopPropagation':
			return 1;
		case 'MayPreventDefault':
			return 2;
		default:
			return 3;
	}
};
var $elm$browser$Browser$External = function (a) {
	return {$: 'External', a: a};
};
var $elm$browser$Browser$Internal = function (a) {
	return {$: 'Internal', a: a};
};
var $elm$core$Basics$identity = function (x) {
	return x;
};
var $elm$browser$Browser$Dom$NotFound = function (a) {
	return {$: 'NotFound', a: a};
};
var $elm$url$Url$Http = {$: 'Http'};
var $elm$url$Url$Https = {$: 'Https'};
var $elm$url$Url$Url = F6(
	function (protocol, host, port_, path, query, fragment) {
		return {fragment: fragment, host: host, path: path, port_: port_, protocol: protocol, query: query};
	});
var $elm$core$String$contains = _String_contains;
var $elm$core$String$length = _String_length;
var $elm$core$String$slice = _String_slice;
var $elm$core$String$dropLeft = F2(
	function (n, string) {
		return (n < 1) ? string : A3(
			$elm$core$String$slice,
			n,
			$elm$core$String$length(string),
			string);
	});
var $elm$core$String$indexes = _String_indexes;
var $elm$core$String$isEmpty = function (string) {
	return string === '';
};
var $elm$core$String$left = F2(
	function (n, string) {
		return (n < 1) ? '' : A3($elm$core$String$slice, 0, n, string);
	});
var $elm$core$String$toInt = _String_toInt;
var $elm$url$Url$chompBeforePath = F5(
	function (protocol, path, params, frag, str) {
		if ($elm$core$String$isEmpty(str) || A2($elm$core$String$contains, '@', str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, ':', str);
			if (!_v0.b) {
				return $elm$core$Maybe$Just(
					A6($elm$url$Url$Url, protocol, str, $elm$core$Maybe$Nothing, path, params, frag));
			} else {
				if (!_v0.b.b) {
					var i = _v0.a;
					var _v1 = $elm$core$String$toInt(
						A2($elm$core$String$dropLeft, i + 1, str));
					if (_v1.$ === 'Nothing') {
						return $elm$core$Maybe$Nothing;
					} else {
						var port_ = _v1;
						return $elm$core$Maybe$Just(
							A6(
								$elm$url$Url$Url,
								protocol,
								A2($elm$core$String$left, i, str),
								port_,
								path,
								params,
								frag));
					}
				} else {
					return $elm$core$Maybe$Nothing;
				}
			}
		}
	});
var $elm$url$Url$chompBeforeQuery = F4(
	function (protocol, params, frag, str) {
		if ($elm$core$String$isEmpty(str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, '/', str);
			if (!_v0.b) {
				return A5($elm$url$Url$chompBeforePath, protocol, '/', params, frag, str);
			} else {
				var i = _v0.a;
				return A5(
					$elm$url$Url$chompBeforePath,
					protocol,
					A2($elm$core$String$dropLeft, i, str),
					params,
					frag,
					A2($elm$core$String$left, i, str));
			}
		}
	});
var $elm$url$Url$chompBeforeFragment = F3(
	function (protocol, frag, str) {
		if ($elm$core$String$isEmpty(str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, '?', str);
			if (!_v0.b) {
				return A4($elm$url$Url$chompBeforeQuery, protocol, $elm$core$Maybe$Nothing, frag, str);
			} else {
				var i = _v0.a;
				return A4(
					$elm$url$Url$chompBeforeQuery,
					protocol,
					$elm$core$Maybe$Just(
						A2($elm$core$String$dropLeft, i + 1, str)),
					frag,
					A2($elm$core$String$left, i, str));
			}
		}
	});
var $elm$url$Url$chompAfterProtocol = F2(
	function (protocol, str) {
		if ($elm$core$String$isEmpty(str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, '#', str);
			if (!_v0.b) {
				return A3($elm$url$Url$chompBeforeFragment, protocol, $elm$core$Maybe$Nothing, str);
			} else {
				var i = _v0.a;
				return A3(
					$elm$url$Url$chompBeforeFragment,
					protocol,
					$elm$core$Maybe$Just(
						A2($elm$core$String$dropLeft, i + 1, str)),
					A2($elm$core$String$left, i, str));
			}
		}
	});
var $elm$core$String$startsWith = _String_startsWith;
var $elm$url$Url$fromString = function (str) {
	return A2($elm$core$String$startsWith, 'http://', str) ? A2(
		$elm$url$Url$chompAfterProtocol,
		$elm$url$Url$Http,
		A2($elm$core$String$dropLeft, 7, str)) : (A2($elm$core$String$startsWith, 'https://', str) ? A2(
		$elm$url$Url$chompAfterProtocol,
		$elm$url$Url$Https,
		A2($elm$core$String$dropLeft, 8, str)) : $elm$core$Maybe$Nothing);
};
var $elm$core$Basics$never = function (_v0) {
	never:
	while (true) {
		var nvr = _v0.a;
		var $temp$_v0 = nvr;
		_v0 = $temp$_v0;
		continue never;
	}
};
var $elm$core$Task$Perform = function (a) {
	return {$: 'Perform', a: a};
};
var $elm$core$Task$succeed = _Scheduler_succeed;
var $elm$core$Task$init = $elm$core$Task$succeed(_Utils_Tuple0);
var $elm$core$List$foldrHelper = F4(
	function (fn, acc, ctr, ls) {
		if (!ls.b) {
			return acc;
		} else {
			var a = ls.a;
			var r1 = ls.b;
			if (!r1.b) {
				return A2(fn, a, acc);
			} else {
				var b = r1.a;
				var r2 = r1.b;
				if (!r2.b) {
					return A2(
						fn,
						a,
						A2(fn, b, acc));
				} else {
					var c = r2.a;
					var r3 = r2.b;
					if (!r3.b) {
						return A2(
							fn,
							a,
							A2(
								fn,
								b,
								A2(fn, c, acc)));
					} else {
						var d = r3.a;
						var r4 = r3.b;
						var res = (ctr > 500) ? A3(
							$elm$core$List$foldl,
							fn,
							acc,
							$elm$core$List$reverse(r4)) : A4($elm$core$List$foldrHelper, fn, acc, ctr + 1, r4);
						return A2(
							fn,
							a,
							A2(
								fn,
								b,
								A2(
									fn,
									c,
									A2(fn, d, res))));
					}
				}
			}
		}
	});
var $elm$core$List$foldr = F3(
	function (fn, acc, ls) {
		return A4($elm$core$List$foldrHelper, fn, acc, 0, ls);
	});
var $elm$core$List$map = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$foldr,
			F2(
				function (x, acc) {
					return A2(
						$elm$core$List$cons,
						f(x),
						acc);
				}),
			_List_Nil,
			xs);
	});
var $elm$core$Task$andThen = _Scheduler_andThen;
var $elm$core$Task$map = F2(
	function (func, taskA) {
		return A2(
			$elm$core$Task$andThen,
			function (a) {
				return $elm$core$Task$succeed(
					func(a));
			},
			taskA);
	});
var $elm$core$Task$map2 = F3(
	function (func, taskA, taskB) {
		return A2(
			$elm$core$Task$andThen,
			function (a) {
				return A2(
					$elm$core$Task$andThen,
					function (b) {
						return $elm$core$Task$succeed(
							A2(func, a, b));
					},
					taskB);
			},
			taskA);
	});
var $elm$core$Task$sequence = function (tasks) {
	return A3(
		$elm$core$List$foldr,
		$elm$core$Task$map2($elm$core$List$cons),
		$elm$core$Task$succeed(_List_Nil),
		tasks);
};
var $elm$core$Platform$sendToApp = _Platform_sendToApp;
var $elm$core$Task$spawnCmd = F2(
	function (router, _v0) {
		var task = _v0.a;
		return _Scheduler_spawn(
			A2(
				$elm$core$Task$andThen,
				$elm$core$Platform$sendToApp(router),
				task));
	});
var $elm$core$Task$onEffects = F3(
	function (router, commands, state) {
		return A2(
			$elm$core$Task$map,
			function (_v0) {
				return _Utils_Tuple0;
			},
			$elm$core$Task$sequence(
				A2(
					$elm$core$List$map,
					$elm$core$Task$spawnCmd(router),
					commands)));
	});
var $elm$core$Task$onSelfMsg = F3(
	function (_v0, _v1, _v2) {
		return $elm$core$Task$succeed(_Utils_Tuple0);
	});
var $elm$core$Task$cmdMap = F2(
	function (tagger, _v0) {
		var task = _v0.a;
		return $elm$core$Task$Perform(
			A2($elm$core$Task$map, tagger, task));
	});
_Platform_effectManagers['Task'] = _Platform_createManager($elm$core$Task$init, $elm$core$Task$onEffects, $elm$core$Task$onSelfMsg, $elm$core$Task$cmdMap);
var $elm$core$Task$command = _Platform_leaf('Task');
var $elm$core$Task$perform = F2(
	function (toMessage, task) {
		return $elm$core$Task$command(
			$elm$core$Task$Perform(
				A2($elm$core$Task$map, toMessage, task)));
	});
var $elm$browser$Browser$document = _Browser_document;
var $elm$json$Json$Decode$decodeValue = _Json_run;
var $author$project$Model$Map = F3(
	function (id, rect, items) {
		return {id: id, items: items, rect: rect};
	});
var $author$project$Model$NoEdit = {$: 'NoEdit'};
var $author$project$Model$Rectangle = F4(
	function (x1, y1, x2, y2) {
		return {x1: x1, x2: x2, y1: y1, y2: y2};
	});
var $author$project$Compat$Display$Circle = {$: 'Circle'};
var $author$project$Compat$Display$Rounded = function (a) {
	return {$: 'Rounded', a: a};
};
var $author$project$Compat$Display$default = {
	container: $author$project$Compat$Display$Rounded(10),
	monad: $author$project$Compat$Display$Circle,
	padding: 8,
	stroke: 1.5
};
var $elm$core$Dict$RBEmpty_elm_builtin = {$: 'RBEmpty_elm_builtin'};
var $elm$core$Dict$empty = $elm$core$Dict$RBEmpty_elm_builtin;
var $author$project$IconMenu$init = {
	center: {x: 0, y: 0},
	hover: $elm$core$Maybe$Nothing,
	icon: $elm$core$Maybe$Nothing,
	open: false,
	topicId: $elm$core$Maybe$Nothing
};
var $author$project$Mouse$NoDrag = {$: 'NoDrag'};
var $author$project$Mouse$init = {dragState: $author$project$Mouse$NoDrag};
var $author$project$Search$Closed = {$: 'Closed'};
var $author$project$Search$init = {menu: $author$project$Search$Closed, result: _List_Nil, text: ''};
var $elm$core$Dict$Black = {$: 'Black'};
var $elm$core$Dict$RBNode_elm_builtin = F5(
	function (a, b, c, d, e) {
		return {$: 'RBNode_elm_builtin', a: a, b: b, c: c, d: d, e: e};
	});
var $elm$core$Dict$singleton = F2(
	function (key, value) {
		return A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, key, value, $elm$core$Dict$RBEmpty_elm_builtin, $elm$core$Dict$RBEmpty_elm_builtin);
	});
var $author$project$AppModel$default = {
	display: $author$project$Compat$Display$default,
	editState: $author$project$Model$NoEdit,
	fedWikiRaw: '',
	iconMenu: $author$project$IconMenu$init,
	items: $elm$core$Dict$empty,
	mapPath: _List_fromArray(
		[0]),
	maps: A2(
		$elm$core$Dict$singleton,
		0,
		A3(
			$author$project$Model$Map,
			0,
			A4($author$project$Model$Rectangle, 0, 0, 0, 0),
			$elm$core$Dict$empty)),
	measureText: '',
	mouse: $author$project$Mouse$init,
	nextId: 1,
	search: $author$project$Search$init,
	selection: _List_Nil
};
var $elm$core$Debug$log = _Debug_log;
var $author$project$Logger$log = $elm$core$Debug$log;
var $author$project$Utils$logError = F3(
	function (funcName, text, val) {
		return A2($author$project$Logger$log, '### ERROR @' + (funcName + (': ' + text)), val);
	});
var $author$project$AppModel$Model = function (items) {
	return function (maps) {
		return function (mapPath) {
			return function (nextId) {
				return function (selection) {
					return function (editState) {
						return function (measureText) {
							return function (mouse) {
								return function (search) {
									return function (iconMenu) {
										return function (display) {
											return function (fedWikiRaw) {
												return {display: display, editState: editState, fedWikiRaw: fedWikiRaw, iconMenu: iconMenu, items: items, mapPath: mapPath, maps: maps, measureText: measureText, mouse: mouse, nextId: nextId, search: search, selection: selection};
											};
										};
									};
								};
							};
						};
					};
				};
			};
		};
	};
};
var $elm$json$Json$Decode$andThen = _Json_andThen;
var $elm$core$Basics$composeR = F3(
	function (f, g, x) {
		return g(
			f(x));
	});
var $NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$custom = $elm$json$Json$Decode$map2($elm$core$Basics$apR);
var $NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$hardcoded = A2($elm$core$Basics$composeR, $elm$json$Json$Decode$succeed, $NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$custom);
var $elm$json$Json$Decode$int = _Json_decodeInt;
var $author$project$Model$Assoc = function (a) {
	return {$: 'Assoc', a: a};
};
var $author$project$Model$AssocInfo = F6(
	function (id, itemType, role1, player1, role2, player2) {
		return {id: id, itemType: itemType, player1: player1, player2: player2, role1: role1, role2: role2};
	});
var $author$project$Model$Topic = function (a) {
	return {$: 'Topic', a: a};
};
var $author$project$Model$TopicInfo = F3(
	function (id, text, iconName) {
		return {iconName: iconName, id: id, text: text};
	});
var $elm$json$Json$Decode$field = _Json_decodeField;
var $elm$json$Json$Decode$map3 = _Json_map3;
var $elm$json$Json$Decode$map6 = _Json_map6;
var $author$project$Storage$maybeString = function (str) {
	return $elm$json$Json$Decode$succeed(
		function () {
			if (str === '') {
				return $elm$core$Maybe$Nothing;
			} else {
				return $elm$core$Maybe$Just(str);
			}
		}());
};
var $elm$json$Json$Decode$oneOf = _Json_oneOf;
var $elm$core$Tuple$pair = F2(
	function (a, b) {
		return _Utils_Tuple2(a, b);
	});
var $elm$json$Json$Decode$string = _Json_decodeString;
var $author$project$Storage$itemDecoder = $elm$json$Json$Decode$oneOf(
	_List_fromArray(
		[
			A2(
			$elm$json$Json$Decode$field,
			'topic',
			A3(
				$elm$json$Json$Decode$map2,
				$elm$core$Tuple$pair,
				A2($elm$json$Json$Decode$field, 'id', $elm$json$Json$Decode$int),
				A2(
					$elm$json$Json$Decode$map,
					$author$project$Model$Topic,
					A4(
						$elm$json$Json$Decode$map3,
						$author$project$Model$TopicInfo,
						A2($elm$json$Json$Decode$field, 'id', $elm$json$Json$Decode$int),
						A2($elm$json$Json$Decode$field, 'text', $elm$json$Json$Decode$string),
						A2(
							$elm$json$Json$Decode$andThen,
							$author$project$Storage$maybeString,
							A2($elm$json$Json$Decode$field, 'icon', $elm$json$Json$Decode$string)))))),
			A2(
			$elm$json$Json$Decode$field,
			'assoc',
			A3(
				$elm$json$Json$Decode$map2,
				$elm$core$Tuple$pair,
				A2($elm$json$Json$Decode$field, 'id', $elm$json$Json$Decode$int),
				A2(
					$elm$json$Json$Decode$map,
					$author$project$Model$Assoc,
					A7(
						$elm$json$Json$Decode$map6,
						$author$project$Model$AssocInfo,
						A2($elm$json$Json$Decode$field, 'id', $elm$json$Json$Decode$int),
						A2($elm$json$Json$Decode$field, 'type', $elm$json$Json$Decode$string),
						A2($elm$json$Json$Decode$field, 'role1', $elm$json$Json$Decode$string),
						A2($elm$json$Json$Decode$field, 'player1', $elm$json$Json$Decode$int),
						A2($elm$json$Json$Decode$field, 'role2', $elm$json$Json$Decode$string),
						A2($elm$json$Json$Decode$field, 'player2', $elm$json$Json$Decode$int)))))
		]));
var $elm$json$Json$Decode$list = _Json_decodeList;
var $elm$json$Json$Decode$float = _Json_decodeFloat;
var $elm$json$Json$Decode$map4 = _Json_map4;
var $author$project$Model$AssocProps = {};
var $author$project$Model$MapAssoc = function (a) {
	return {$: 'MapAssoc', a: a};
};
var $author$project$Model$MapItem = F5(
	function (id, parentAssocId, hidden, pinned, props) {
		return {hidden: hidden, id: id, parentAssocId: parentAssocId, pinned: pinned, props: props};
	});
var $author$project$Model$MapTopic = function (a) {
	return {$: 'MapTopic', a: a};
};
var $author$project$Model$Point = F2(
	function (x, y) {
		return {x: x, y: y};
	});
var $author$project$Model$Size = F2(
	function (w, h) {
		return {h: h, w: w};
	});
var $author$project$Model$TopicProps = F3(
	function (pos, size, displayMode) {
		return {displayMode: displayMode, pos: pos, size: size};
	});
var $elm$json$Json$Decode$bool = _Json_decodeBool;
var $author$project$Model$BlackBox = {$: 'BlackBox'};
var $author$project$Model$Container = function (a) {
	return {$: 'Container', a: a};
};
var $author$project$Model$Detail = {$: 'Detail'};
var $author$project$Model$LabelOnly = {$: 'LabelOnly'};
var $author$project$Model$Monad = function (a) {
	return {$: 'Monad', a: a};
};
var $author$project$Model$Unboxed = {$: 'Unboxed'};
var $author$project$Model$WhiteBox = {$: 'WhiteBox'};
var $elm$json$Json$Decode$fail = _Json_fail;
var $author$project$Storage$displayModeDecoder = function (str) {
	switch (str) {
		case 'LabelOnly':
			return $elm$json$Json$Decode$succeed(
				$author$project$Model$Monad($author$project$Model$LabelOnly));
		case 'Detail':
			return $elm$json$Json$Decode$succeed(
				$author$project$Model$Monad($author$project$Model$Detail));
		case 'BlackBox':
			return $elm$json$Json$Decode$succeed(
				$author$project$Model$Container($author$project$Model$BlackBox));
		case 'WhiteBox':
			return $elm$json$Json$Decode$succeed(
				$author$project$Model$Container($author$project$Model$WhiteBox));
		case 'Unboxed':
			return $elm$json$Json$Decode$succeed(
				$author$project$Model$Container($author$project$Model$Unboxed));
		default:
			return $elm$json$Json$Decode$fail('\"' + (str + '\" is an invalid display mode'));
	}
};
var $elm$json$Json$Decode$map5 = _Json_map5;
var $author$project$Storage$mapItemDecoder = A6(
	$elm$json$Json$Decode$map5,
	$author$project$Model$MapItem,
	A2($elm$json$Json$Decode$field, 'id', $elm$json$Json$Decode$int),
	A2($elm$json$Json$Decode$field, 'parentAssocId', $elm$json$Json$Decode$int),
	A2($elm$json$Json$Decode$field, 'hidden', $elm$json$Json$Decode$bool),
	A2($elm$json$Json$Decode$field, 'pinned', $elm$json$Json$Decode$bool),
	$elm$json$Json$Decode$oneOf(
		_List_fromArray(
			[
				A2(
				$elm$json$Json$Decode$field,
				'topicProps',
				A2(
					$elm$json$Json$Decode$map,
					$author$project$Model$MapTopic,
					A4(
						$elm$json$Json$Decode$map3,
						$author$project$Model$TopicProps,
						A2(
							$elm$json$Json$Decode$field,
							'pos',
							A3(
								$elm$json$Json$Decode$map2,
								$author$project$Model$Point,
								A2($elm$json$Json$Decode$field, 'x', $elm$json$Json$Decode$float),
								A2($elm$json$Json$Decode$field, 'y', $elm$json$Json$Decode$float))),
						A2(
							$elm$json$Json$Decode$field,
							'size',
							A3(
								$elm$json$Json$Decode$map2,
								$author$project$Model$Size,
								A2($elm$json$Json$Decode$field, 'w', $elm$json$Json$Decode$float),
								A2($elm$json$Json$Decode$field, 'h', $elm$json$Json$Decode$float))),
						A2(
							$elm$json$Json$Decode$andThen,
							$author$project$Storage$displayModeDecoder,
							A2($elm$json$Json$Decode$field, 'display', $elm$json$Json$Decode$string))))),
				A2(
				$elm$json$Json$Decode$field,
				'assocProps',
				$elm$json$Json$Decode$succeed(
					$author$project$Model$MapAssoc($author$project$Model$AssocProps)))
			])));
var $elm$core$Dict$Red = {$: 'Red'};
var $elm$core$Dict$balance = F5(
	function (color, key, value, left, right) {
		if ((right.$ === 'RBNode_elm_builtin') && (right.a.$ === 'Red')) {
			var _v1 = right.a;
			var rK = right.b;
			var rV = right.c;
			var rLeft = right.d;
			var rRight = right.e;
			if ((left.$ === 'RBNode_elm_builtin') && (left.a.$ === 'Red')) {
				var _v3 = left.a;
				var lK = left.b;
				var lV = left.c;
				var lLeft = left.d;
				var lRight = left.e;
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Red,
					key,
					value,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, rK, rV, rLeft, rRight));
			} else {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					color,
					rK,
					rV,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, key, value, left, rLeft),
					rRight);
			}
		} else {
			if ((((left.$ === 'RBNode_elm_builtin') && (left.a.$ === 'Red')) && (left.d.$ === 'RBNode_elm_builtin')) && (left.d.a.$ === 'Red')) {
				var _v5 = left.a;
				var lK = left.b;
				var lV = left.c;
				var _v6 = left.d;
				var _v7 = _v6.a;
				var llK = _v6.b;
				var llV = _v6.c;
				var llLeft = _v6.d;
				var llRight = _v6.e;
				var lRight = left.e;
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Red,
					lK,
					lV,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, llK, llV, llLeft, llRight),
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, key, value, lRight, right));
			} else {
				return A5($elm$core$Dict$RBNode_elm_builtin, color, key, value, left, right);
			}
		}
	});
var $elm$core$Basics$compare = _Utils_compare;
var $elm$core$Dict$insertHelp = F3(
	function (key, value, dict) {
		if (dict.$ === 'RBEmpty_elm_builtin') {
			return A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, key, value, $elm$core$Dict$RBEmpty_elm_builtin, $elm$core$Dict$RBEmpty_elm_builtin);
		} else {
			var nColor = dict.a;
			var nKey = dict.b;
			var nValue = dict.c;
			var nLeft = dict.d;
			var nRight = dict.e;
			var _v1 = A2($elm$core$Basics$compare, key, nKey);
			switch (_v1.$) {
				case 'LT':
					return A5(
						$elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						A3($elm$core$Dict$insertHelp, key, value, nLeft),
						nRight);
				case 'EQ':
					return A5($elm$core$Dict$RBNode_elm_builtin, nColor, nKey, value, nLeft, nRight);
				default:
					return A5(
						$elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						nLeft,
						A3($elm$core$Dict$insertHelp, key, value, nRight));
			}
		}
	});
var $elm$core$Dict$insert = F3(
	function (key, value, dict) {
		var _v0 = A3($elm$core$Dict$insertHelp, key, value, dict);
		if ((_v0.$ === 'RBNode_elm_builtin') && (_v0.a.$ === 'Red')) {
			var _v1 = _v0.a;
			var k = _v0.b;
			var v = _v0.c;
			var l = _v0.d;
			var r = _v0.e;
			return A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, k, v, l, r);
		} else {
			var x = _v0;
			return x;
		}
	});
var $elm$core$Dict$fromList = function (assocs) {
	return A3(
		$elm$core$List$foldl,
		F2(
			function (_v0, dict) {
				var key = _v0.a;
				var value = _v0.b;
				return A3($elm$core$Dict$insert, key, value, dict);
			}),
		$elm$core$Dict$empty,
		assocs);
};
var $author$project$Storage$toDictDecoder = function (items) {
	return $elm$json$Json$Decode$succeed(
		$elm$core$Dict$fromList(
			A2(
				$elm$core$List$map,
				function (item) {
					return _Utils_Tuple2(item.id, item);
				},
				items)));
};
var $author$project$Storage$mapDecoder = A4(
	$elm$json$Json$Decode$map3,
	$author$project$Model$Map,
	A2($elm$json$Json$Decode$field, 'id', $elm$json$Json$Decode$int),
	A2(
		$elm$json$Json$Decode$field,
		'rect',
		A5(
			$elm$json$Json$Decode$map4,
			$author$project$Model$Rectangle,
			A2($elm$json$Json$Decode$field, 'x1', $elm$json$Json$Decode$float),
			A2($elm$json$Json$Decode$field, 'y1', $elm$json$Json$Decode$float),
			A2($elm$json$Json$Decode$field, 'x2', $elm$json$Json$Decode$float),
			A2($elm$json$Json$Decode$field, 'y2', $elm$json$Json$Decode$float))),
	A2(
		$elm$json$Json$Decode$field,
		'items',
		A2(
			$elm$json$Json$Decode$andThen,
			$author$project$Storage$toDictDecoder,
			$elm$json$Json$Decode$list($author$project$Storage$mapItemDecoder))));
var $NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required = F3(
	function (key, valDecoder, decoder) {
		return A2(
			$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$custom,
			A2($elm$json$Json$Decode$field, key, valDecoder),
			decoder);
	});
var $author$project$Model$Item = F2(
	function (id, info) {
		return {id: id, info: info};
	});
var $author$project$Storage$tupleToDictDecoder = function (tuples) {
	return $elm$json$Json$Decode$succeed(
		$elm$core$Dict$fromList(
			A2(
				$elm$core$List$map,
				function (_v0) {
					var id = _v0.a;
					var info = _v0.b;
					return _Utils_Tuple2(
						id,
						A2($author$project$Model$Item, id, info));
				},
				tuples)));
};
var $author$project$Storage$fullModelDecoder = A2(
	$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$hardcoded,
	$author$project$AppModel$default.fedWikiRaw,
	A2(
		$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$hardcoded,
		$author$project$AppModel$default.display,
		A2(
			$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$hardcoded,
			$author$project$AppModel$default.iconMenu,
			A2(
				$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$hardcoded,
				$author$project$AppModel$default.search,
				A2(
					$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$hardcoded,
					$author$project$AppModel$default.mouse,
					A2(
						$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$hardcoded,
						$author$project$AppModel$default.measureText,
						A2(
							$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$hardcoded,
							$author$project$AppModel$default.editState,
							A2(
								$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$hardcoded,
								$author$project$AppModel$default.selection,
								A3(
									$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
									'nextId',
									$elm$json$Json$Decode$int,
									A3(
										$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
										'mapPath',
										$elm$json$Json$Decode$list($elm$json$Json$Decode$int),
										A3(
											$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
											'maps',
											A2(
												$elm$json$Json$Decode$andThen,
												$author$project$Storage$toDictDecoder,
												$elm$json$Json$Decode$list($author$project$Storage$mapDecoder)),
											A3(
												$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
												'items',
												A2(
													$elm$json$Json$Decode$andThen,
													$author$project$Storage$tupleToDictDecoder,
													$elm$json$Json$Decode$list($author$project$Storage$itemDecoder)),
												$elm$json$Json$Decode$succeed($author$project$AppModel$Model)))))))))))));
var $author$project$Storage$modelDecoder = $elm$json$Json$Decode$oneOf(
	_List_fromArray(
		[
			$author$project$Storage$fullModelDecoder,
			$elm$json$Json$Decode$succeed($author$project$AppModel$default)
		]));
var $elm$core$Platform$Cmd$batch = _Platform_batch;
var $elm$core$Platform$Cmd$none = $elm$core$Platform$Cmd$batch(_List_Nil);
var $elm$json$Json$Decode$null = _Json_decodeNull;
var $elm$core$Debug$toString = _Debug_toString;
var $author$project$Logger$toString = $elm$core$Debug$toString;
var $author$project$Utils$toString = $author$project$Logger$toString;
var $author$project$Main$init = function (flags) {
	return _Utils_Tuple2(
		function () {
			var _v0 = A2(
				$elm$json$Json$Decode$decodeValue,
				$elm$json$Json$Decode$null(true),
				flags);
			if ((_v0.$ === 'Ok') && _v0.a) {
				var _v1 = A2($author$project$Logger$log, 'init', 'localStorage: empty');
				return $author$project$AppModel$default;
			} else {
				var _v2 = A2($elm$json$Json$Decode$decodeValue, $author$project$Storage$modelDecoder, flags);
				if (_v2.$ === 'Ok') {
					var model = _v2.a;
					var _v3 = A2(
						$author$project$Logger$log,
						'init',
						'localStorage: ' + ($elm$core$String$fromInt(
							$elm$core$String$length(
								$author$project$Utils$toString(model))) + ' bytes'));
					return model;
				} else {
					var e = _v2.a;
					var _v4 = A3($author$project$Utils$logError, 'init', 'localStorage', e);
					return $author$project$AppModel$default;
				}
			}
		}(),
		$elm$core$Platform$Cmd$none);
};
var $elm$core$Platform$Sub$batch = _Platform_batch;
var $author$project$AppModel$Mouse = function (a) {
	return {$: 'Mouse', a: a};
};
var $author$project$Mouse$Move = function (a) {
	return {$: 'Move', a: a};
};
var $author$project$Mouse$Up = {$: 'Up'};
var $elm$browser$Browser$Events$Document = {$: 'Document'};
var $elm$browser$Browser$Events$MySub = F3(
	function (a, b, c) {
		return {$: 'MySub', a: a, b: b, c: c};
	});
var $elm$browser$Browser$Events$State = F2(
	function (subs, pids) {
		return {pids: pids, subs: subs};
	});
var $elm$browser$Browser$Events$init = $elm$core$Task$succeed(
	A2($elm$browser$Browser$Events$State, _List_Nil, $elm$core$Dict$empty));
var $elm$browser$Browser$Events$nodeToKey = function (node) {
	if (node.$ === 'Document') {
		return 'd_';
	} else {
		return 'w_';
	}
};
var $elm$browser$Browser$Events$addKey = function (sub) {
	var node = sub.a;
	var name = sub.b;
	return _Utils_Tuple2(
		_Utils_ap(
			$elm$browser$Browser$Events$nodeToKey(node),
			name),
		sub);
};
var $elm$core$Process$kill = _Scheduler_kill;
var $elm$core$Dict$foldl = F3(
	function (func, acc, dict) {
		foldl:
		while (true) {
			if (dict.$ === 'RBEmpty_elm_builtin') {
				return acc;
			} else {
				var key = dict.b;
				var value = dict.c;
				var left = dict.d;
				var right = dict.e;
				var $temp$func = func,
					$temp$acc = A3(
					func,
					key,
					value,
					A3($elm$core$Dict$foldl, func, acc, left)),
					$temp$dict = right;
				func = $temp$func;
				acc = $temp$acc;
				dict = $temp$dict;
				continue foldl;
			}
		}
	});
var $elm$core$Dict$merge = F6(
	function (leftStep, bothStep, rightStep, leftDict, rightDict, initialResult) {
		var stepState = F3(
			function (rKey, rValue, _v0) {
				stepState:
				while (true) {
					var list = _v0.a;
					var result = _v0.b;
					if (!list.b) {
						return _Utils_Tuple2(
							list,
							A3(rightStep, rKey, rValue, result));
					} else {
						var _v2 = list.a;
						var lKey = _v2.a;
						var lValue = _v2.b;
						var rest = list.b;
						if (_Utils_cmp(lKey, rKey) < 0) {
							var $temp$rKey = rKey,
								$temp$rValue = rValue,
								$temp$_v0 = _Utils_Tuple2(
								rest,
								A3(leftStep, lKey, lValue, result));
							rKey = $temp$rKey;
							rValue = $temp$rValue;
							_v0 = $temp$_v0;
							continue stepState;
						} else {
							if (_Utils_cmp(lKey, rKey) > 0) {
								return _Utils_Tuple2(
									list,
									A3(rightStep, rKey, rValue, result));
							} else {
								return _Utils_Tuple2(
									rest,
									A4(bothStep, lKey, lValue, rValue, result));
							}
						}
					}
				}
			});
		var _v3 = A3(
			$elm$core$Dict$foldl,
			stepState,
			_Utils_Tuple2(
				$elm$core$Dict$toList(leftDict),
				initialResult),
			rightDict);
		var leftovers = _v3.a;
		var intermediateResult = _v3.b;
		return A3(
			$elm$core$List$foldl,
			F2(
				function (_v4, result) {
					var k = _v4.a;
					var v = _v4.b;
					return A3(leftStep, k, v, result);
				}),
			intermediateResult,
			leftovers);
	});
var $elm$browser$Browser$Events$Event = F2(
	function (key, event) {
		return {event: event, key: key};
	});
var $elm$core$Platform$sendToSelf = _Platform_sendToSelf;
var $elm$browser$Browser$Events$spawn = F3(
	function (router, key, _v0) {
		var node = _v0.a;
		var name = _v0.b;
		var actualNode = function () {
			if (node.$ === 'Document') {
				return _Browser_doc;
			} else {
				return _Browser_window;
			}
		}();
		return A2(
			$elm$core$Task$map,
			function (value) {
				return _Utils_Tuple2(key, value);
			},
			A3(
				_Browser_on,
				actualNode,
				name,
				function (event) {
					return A2(
						$elm$core$Platform$sendToSelf,
						router,
						A2($elm$browser$Browser$Events$Event, key, event));
				}));
	});
var $elm$core$Dict$union = F2(
	function (t1, t2) {
		return A3($elm$core$Dict$foldl, $elm$core$Dict$insert, t2, t1);
	});
var $elm$browser$Browser$Events$onEffects = F3(
	function (router, subs, state) {
		var stepRight = F3(
			function (key, sub, _v6) {
				var deads = _v6.a;
				var lives = _v6.b;
				var news = _v6.c;
				return _Utils_Tuple3(
					deads,
					lives,
					A2(
						$elm$core$List$cons,
						A3($elm$browser$Browser$Events$spawn, router, key, sub),
						news));
			});
		var stepLeft = F3(
			function (_v4, pid, _v5) {
				var deads = _v5.a;
				var lives = _v5.b;
				var news = _v5.c;
				return _Utils_Tuple3(
					A2($elm$core$List$cons, pid, deads),
					lives,
					news);
			});
		var stepBoth = F4(
			function (key, pid, _v2, _v3) {
				var deads = _v3.a;
				var lives = _v3.b;
				var news = _v3.c;
				return _Utils_Tuple3(
					deads,
					A3($elm$core$Dict$insert, key, pid, lives),
					news);
			});
		var newSubs = A2($elm$core$List$map, $elm$browser$Browser$Events$addKey, subs);
		var _v0 = A6(
			$elm$core$Dict$merge,
			stepLeft,
			stepBoth,
			stepRight,
			state.pids,
			$elm$core$Dict$fromList(newSubs),
			_Utils_Tuple3(_List_Nil, $elm$core$Dict$empty, _List_Nil));
		var deadPids = _v0.a;
		var livePids = _v0.b;
		var makeNewPids = _v0.c;
		return A2(
			$elm$core$Task$andThen,
			function (pids) {
				return $elm$core$Task$succeed(
					A2(
						$elm$browser$Browser$Events$State,
						newSubs,
						A2(
							$elm$core$Dict$union,
							livePids,
							$elm$core$Dict$fromList(pids))));
			},
			A2(
				$elm$core$Task$andThen,
				function (_v1) {
					return $elm$core$Task$sequence(makeNewPids);
				},
				$elm$core$Task$sequence(
					A2($elm$core$List$map, $elm$core$Process$kill, deadPids))));
	});
var $elm$core$List$maybeCons = F3(
	function (f, mx, xs) {
		var _v0 = f(mx);
		if (_v0.$ === 'Just') {
			var x = _v0.a;
			return A2($elm$core$List$cons, x, xs);
		} else {
			return xs;
		}
	});
var $elm$core$List$filterMap = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$foldr,
			$elm$core$List$maybeCons(f),
			_List_Nil,
			xs);
	});
var $elm$browser$Browser$Events$onSelfMsg = F3(
	function (router, _v0, state) {
		var key = _v0.key;
		var event = _v0.event;
		var toMessage = function (_v2) {
			var subKey = _v2.a;
			var _v3 = _v2.b;
			var node = _v3.a;
			var name = _v3.b;
			var decoder = _v3.c;
			return _Utils_eq(subKey, key) ? A2(_Browser_decodeEvent, decoder, event) : $elm$core$Maybe$Nothing;
		};
		var messages = A2($elm$core$List$filterMap, toMessage, state.subs);
		return A2(
			$elm$core$Task$andThen,
			function (_v1) {
				return $elm$core$Task$succeed(state);
			},
			$elm$core$Task$sequence(
				A2(
					$elm$core$List$map,
					$elm$core$Platform$sendToApp(router),
					messages)));
	});
var $elm$browser$Browser$Events$subMap = F2(
	function (func, _v0) {
		var node = _v0.a;
		var name = _v0.b;
		var decoder = _v0.c;
		return A3(
			$elm$browser$Browser$Events$MySub,
			node,
			name,
			A2($elm$json$Json$Decode$map, func, decoder));
	});
_Platform_effectManagers['Browser.Events'] = _Platform_createManager($elm$browser$Browser$Events$init, $elm$browser$Browser$Events$onEffects, $elm$browser$Browser$Events$onSelfMsg, 0, $elm$browser$Browser$Events$subMap);
var $elm$browser$Browser$Events$subscription = _Platform_leaf('Browser.Events');
var $elm$browser$Browser$Events$on = F3(
	function (node, name, decoder) {
		return $elm$browser$Browser$Events$subscription(
			A3($elm$browser$Browser$Events$MySub, node, name, decoder));
	});
var $elm$browser$Browser$Events$onMouseMove = A2($elm$browser$Browser$Events$on, $elm$browser$Browser$Events$Document, 'mousemove');
var $elm$browser$Browser$Events$onMouseUp = A2($elm$browser$Browser$Events$on, $elm$browser$Browser$Events$Document, 'mouseup');
var $author$project$MouseAPI$dragSub = $elm$core$Platform$Sub$batch(
	_List_fromArray(
		[
			$elm$browser$Browser$Events$onMouseMove(
			A2(
				$elm$json$Json$Decode$map,
				$author$project$AppModel$Mouse,
				A2(
					$elm$json$Json$Decode$map,
					$author$project$Mouse$Move,
					A3(
						$elm$json$Json$Decode$map2,
						$author$project$Model$Point,
						A2($elm$json$Json$Decode$field, 'clientX', $elm$json$Json$Decode$float),
						A2($elm$json$Json$Decode$field, 'clientY', $elm$json$Json$Decode$float))))),
			$elm$browser$Browser$Events$onMouseUp(
			$elm$json$Json$Decode$succeed(
				$author$project$AppModel$Mouse($author$project$Mouse$Up)))
		]));
var $author$project$Mouse$Down = {$: 'Down'};
var $author$project$Mouse$DownItem = F4(
	function (a, b, c, d) {
		return {$: 'DownItem', a: a, b: b, c: c, d: d};
	});
var $elm$json$Json$Decode$at = F2(
	function (fields, decoder) {
		return A3($elm$core$List$foldr, $elm$json$Json$Decode$field, decoder, fields);
	});
var $author$project$ModelAPI$idDecoder = function (str) {
	var _v0 = $elm$core$String$toInt(str);
	if (_v0.$ === 'Just') {
		var _int = _v0.a;
		return $elm$json$Json$Decode$succeed(_int);
	} else {
		return $elm$json$Json$Decode$fail('\"' + (str + '\" is a malformed ID'));
	}
};
var $elm$browser$Browser$Events$onMouseDown = A2($elm$browser$Browser$Events$on, $elm$browser$Browser$Events$Document, 'mousedown');
var $elm$core$Basics$negate = function (n) {
	return -n;
};
var $author$project$ModelAPI$pathDecoder = function (str) {
	return $elm$json$Json$Decode$succeed(
		A2(
			$elm$core$List$map,
			function (mapIdStr) {
				var _v0 = $elm$core$String$toInt(mapIdStr);
				if (_v0.$ === 'Just') {
					var mapId = _v0.a;
					return mapId;
				} else {
					return A3($author$project$Utils$logError, 'pathDecoder', '\"' + (mapIdStr + '\" is a malformed ID'), -1);
				}
			},
			A2($elm$core$String$split, ',', str)));
};
var $author$project$MouseAPI$mouseDownSub = $elm$browser$Browser$Events$onMouseDown(
	$elm$json$Json$Decode$oneOf(
		_List_fromArray(
			[
				A2(
				$elm$json$Json$Decode$map,
				$author$project$AppModel$Mouse,
				A5(
					$elm$json$Json$Decode$map4,
					$author$project$Mouse$DownItem,
					$elm$json$Json$Decode$oneOf(
						_List_fromArray(
							[
								A2(
								$elm$json$Json$Decode$at,
								_List_fromArray(
									['target', 'className']),
								$elm$json$Json$Decode$string),
								A2(
								$elm$json$Json$Decode$at,
								_List_fromArray(
									['target', 'className', 'baseVal']),
								$elm$json$Json$Decode$string)
							])),
					A2(
						$elm$json$Json$Decode$andThen,
						$author$project$ModelAPI$idDecoder,
						A2(
							$elm$json$Json$Decode$at,
							_List_fromArray(
								['target', 'dataset', 'id']),
							$elm$json$Json$Decode$string)),
					A2(
						$elm$json$Json$Decode$andThen,
						$author$project$ModelAPI$pathDecoder,
						A2(
							$elm$json$Json$Decode$at,
							_List_fromArray(
								['target', 'dataset', 'path']),
							$elm$json$Json$Decode$string)),
					A3(
						$elm$json$Json$Decode$map2,
						$author$project$Model$Point,
						A2($elm$json$Json$Decode$field, 'clientX', $elm$json$Json$Decode$float),
						A2($elm$json$Json$Decode$field, 'clientY', $elm$json$Json$Decode$float)))),
				$elm$json$Json$Decode$succeed(
				$author$project$AppModel$Mouse($author$project$Mouse$Down))
			])));
var $author$project$Mouse$Time = function (a) {
	return {$: 'Time', a: a};
};
var $elm$core$Basics$composeL = F3(
	function (g, f, x) {
		return g(
			f(x));
	});
var $elm$time$Time$Every = F2(
	function (a, b) {
		return {$: 'Every', a: a, b: b};
	});
var $elm$time$Time$State = F2(
	function (taggers, processes) {
		return {processes: processes, taggers: taggers};
	});
var $elm$time$Time$init = $elm$core$Task$succeed(
	A2($elm$time$Time$State, $elm$core$Dict$empty, $elm$core$Dict$empty));
var $elm$core$Dict$get = F2(
	function (targetKey, dict) {
		get:
		while (true) {
			if (dict.$ === 'RBEmpty_elm_builtin') {
				return $elm$core$Maybe$Nothing;
			} else {
				var key = dict.b;
				var value = dict.c;
				var left = dict.d;
				var right = dict.e;
				var _v1 = A2($elm$core$Basics$compare, targetKey, key);
				switch (_v1.$) {
					case 'LT':
						var $temp$targetKey = targetKey,
							$temp$dict = left;
						targetKey = $temp$targetKey;
						dict = $temp$dict;
						continue get;
					case 'EQ':
						return $elm$core$Maybe$Just(value);
					default:
						var $temp$targetKey = targetKey,
							$temp$dict = right;
						targetKey = $temp$targetKey;
						dict = $temp$dict;
						continue get;
				}
			}
		}
	});
var $elm$time$Time$addMySub = F2(
	function (_v0, state) {
		var interval = _v0.a;
		var tagger = _v0.b;
		var _v1 = A2($elm$core$Dict$get, interval, state);
		if (_v1.$ === 'Nothing') {
			return A3(
				$elm$core$Dict$insert,
				interval,
				_List_fromArray(
					[tagger]),
				state);
		} else {
			var taggers = _v1.a;
			return A3(
				$elm$core$Dict$insert,
				interval,
				A2($elm$core$List$cons, tagger, taggers),
				state);
		}
	});
var $elm$time$Time$Name = function (a) {
	return {$: 'Name', a: a};
};
var $elm$time$Time$Offset = function (a) {
	return {$: 'Offset', a: a};
};
var $elm$time$Time$Zone = F2(
	function (a, b) {
		return {$: 'Zone', a: a, b: b};
	});
var $elm$time$Time$customZone = $elm$time$Time$Zone;
var $elm$time$Time$setInterval = _Time_setInterval;
var $elm$core$Process$spawn = _Scheduler_spawn;
var $elm$time$Time$spawnHelp = F3(
	function (router, intervals, processes) {
		if (!intervals.b) {
			return $elm$core$Task$succeed(processes);
		} else {
			var interval = intervals.a;
			var rest = intervals.b;
			var spawnTimer = $elm$core$Process$spawn(
				A2(
					$elm$time$Time$setInterval,
					interval,
					A2($elm$core$Platform$sendToSelf, router, interval)));
			var spawnRest = function (id) {
				return A3(
					$elm$time$Time$spawnHelp,
					router,
					rest,
					A3($elm$core$Dict$insert, interval, id, processes));
			};
			return A2($elm$core$Task$andThen, spawnRest, spawnTimer);
		}
	});
var $elm$time$Time$onEffects = F3(
	function (router, subs, _v0) {
		var processes = _v0.processes;
		var rightStep = F3(
			function (_v6, id, _v7) {
				var spawns = _v7.a;
				var existing = _v7.b;
				var kills = _v7.c;
				return _Utils_Tuple3(
					spawns,
					existing,
					A2(
						$elm$core$Task$andThen,
						function (_v5) {
							return kills;
						},
						$elm$core$Process$kill(id)));
			});
		var newTaggers = A3($elm$core$List$foldl, $elm$time$Time$addMySub, $elm$core$Dict$empty, subs);
		var leftStep = F3(
			function (interval, taggers, _v4) {
				var spawns = _v4.a;
				var existing = _v4.b;
				var kills = _v4.c;
				return _Utils_Tuple3(
					A2($elm$core$List$cons, interval, spawns),
					existing,
					kills);
			});
		var bothStep = F4(
			function (interval, taggers, id, _v3) {
				var spawns = _v3.a;
				var existing = _v3.b;
				var kills = _v3.c;
				return _Utils_Tuple3(
					spawns,
					A3($elm$core$Dict$insert, interval, id, existing),
					kills);
			});
		var _v1 = A6(
			$elm$core$Dict$merge,
			leftStep,
			bothStep,
			rightStep,
			newTaggers,
			processes,
			_Utils_Tuple3(
				_List_Nil,
				$elm$core$Dict$empty,
				$elm$core$Task$succeed(_Utils_Tuple0)));
		var spawnList = _v1.a;
		var existingDict = _v1.b;
		var killTask = _v1.c;
		return A2(
			$elm$core$Task$andThen,
			function (newProcesses) {
				return $elm$core$Task$succeed(
					A2($elm$time$Time$State, newTaggers, newProcesses));
			},
			A2(
				$elm$core$Task$andThen,
				function (_v2) {
					return A3($elm$time$Time$spawnHelp, router, spawnList, existingDict);
				},
				killTask));
	});
var $elm$time$Time$Posix = function (a) {
	return {$: 'Posix', a: a};
};
var $elm$time$Time$millisToPosix = $elm$time$Time$Posix;
var $elm$time$Time$now = _Time_now($elm$time$Time$millisToPosix);
var $elm$time$Time$onSelfMsg = F3(
	function (router, interval, state) {
		var _v0 = A2($elm$core$Dict$get, interval, state.taggers);
		if (_v0.$ === 'Nothing') {
			return $elm$core$Task$succeed(state);
		} else {
			var taggers = _v0.a;
			var tellTaggers = function (time) {
				return $elm$core$Task$sequence(
					A2(
						$elm$core$List$map,
						function (tagger) {
							return A2(
								$elm$core$Platform$sendToApp,
								router,
								tagger(time));
						},
						taggers));
			};
			return A2(
				$elm$core$Task$andThen,
				function (_v1) {
					return $elm$core$Task$succeed(state);
				},
				A2($elm$core$Task$andThen, tellTaggers, $elm$time$Time$now));
		}
	});
var $elm$time$Time$subMap = F2(
	function (f, _v0) {
		var interval = _v0.a;
		var tagger = _v0.b;
		return A2(
			$elm$time$Time$Every,
			interval,
			A2($elm$core$Basics$composeL, f, tagger));
	});
_Platform_effectManagers['Time'] = _Platform_createManager($elm$time$Time$init, $elm$time$Time$onEffects, $elm$time$Time$onSelfMsg, 0, $elm$time$Time$subMap);
var $elm$time$Time$subscription = _Platform_leaf('Time');
var $elm$time$Time$every = F2(
	function (interval, tagger) {
		return $elm$time$Time$subscription(
			A2($elm$time$Time$Every, interval, tagger));
	});
var $author$project$MouseAPI$timeTick = A2(
	$elm$time$Time$every,
	16,
	A2($elm$core$Basics$composeL, $author$project$AppModel$Mouse, $author$project$Mouse$Time));
var $author$project$MouseAPI$mouseSubs = function (model) {
	var _v0 = model.mouse.dragState;
	switch (_v0.$) {
		case 'WaitForStartTime':
			return $author$project$MouseAPI$timeTick;
		case 'WaitForEndTime':
			return $author$project$MouseAPI$timeTick;
		case 'DragEngaged':
			return $elm$core$Platform$Sub$batch(
				_List_fromArray(
					[$author$project$MouseAPI$dragSub, $author$project$MouseAPI$timeTick]));
		case 'Drag':
			return $elm$core$Platform$Sub$batch(
				_List_fromArray(
					[$author$project$MouseAPI$dragSub, $author$project$MouseAPI$timeTick]));
		default:
			return $author$project$MouseAPI$mouseDownSub;
	}
};
var $elm$core$List$head = function (list) {
	if (list.b) {
		var x = list.a;
		var xs = list.b;
		return $elm$core$Maybe$Just(x);
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $author$project$ModelAPI$activeMap = function (model) {
	var _v0 = $elm$core$List$head(model.mapPath);
	if (_v0.$ === 'Just') {
		var mapId = _v0.a;
		return mapId;
	} else {
		return A3($author$project$Utils$logError, 'activeMap', 'mapPath is empty!', 0);
	}
};
var $author$project$ModelAPI$nextId = function (model) {
	return _Utils_update(
		model,
		{nextId: model.nextId + 1});
};
var $author$project$ModelAPI$createAssoc = F6(
	function (itemType, role1, player1, role2, player2, model) {
		var id = model.nextId;
		var assoc = A2(
			$author$project$Model$Item,
			id,
			$author$project$Model$Assoc(
				A6($author$project$Model$AssocInfo, id, itemType, role1, player1, role2, player2)));
		return _Utils_Tuple2(
			$author$project$ModelAPI$nextId(
				_Utils_update(
					model,
					{
						items: A3($elm$core$Dict$insert, id, assoc, model.items)
					})),
			id);
	});
var $author$project$ModelAPI$illegalId = F4(
	function (funcName, item, id, val) {
		return A3(
			$author$project$Utils$logError,
			funcName,
			$elm$core$String$fromInt(id) + (' is an illegal ' + (item + ' ID')),
			val);
	});
var $author$project$ModelAPI$illegalMapId = F3(
	function (funcName, id, val) {
		return A4($author$project$ModelAPI$illegalId, funcName, 'Map', id, val);
	});
var $elm$core$Dict$getMin = function (dict) {
	getMin:
	while (true) {
		if ((dict.$ === 'RBNode_elm_builtin') && (dict.d.$ === 'RBNode_elm_builtin')) {
			var left = dict.d;
			var $temp$dict = left;
			dict = $temp$dict;
			continue getMin;
		} else {
			return dict;
		}
	}
};
var $elm$core$Dict$moveRedLeft = function (dict) {
	if (((dict.$ === 'RBNode_elm_builtin') && (dict.d.$ === 'RBNode_elm_builtin')) && (dict.e.$ === 'RBNode_elm_builtin')) {
		if ((dict.e.d.$ === 'RBNode_elm_builtin') && (dict.e.d.a.$ === 'Red')) {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v1 = dict.d;
			var lClr = _v1.a;
			var lK = _v1.b;
			var lV = _v1.c;
			var lLeft = _v1.d;
			var lRight = _v1.e;
			var _v2 = dict.e;
			var rClr = _v2.a;
			var rK = _v2.b;
			var rV = _v2.c;
			var rLeft = _v2.d;
			var _v3 = rLeft.a;
			var rlK = rLeft.b;
			var rlV = rLeft.c;
			var rlL = rLeft.d;
			var rlR = rLeft.e;
			var rRight = _v2.e;
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				$elm$core$Dict$Red,
				rlK,
				rlV,
				A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Black,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, lK, lV, lLeft, lRight),
					rlL),
				A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, rK, rV, rlR, rRight));
		} else {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v4 = dict.d;
			var lClr = _v4.a;
			var lK = _v4.b;
			var lV = _v4.c;
			var lLeft = _v4.d;
			var lRight = _v4.e;
			var _v5 = dict.e;
			var rClr = _v5.a;
			var rK = _v5.b;
			var rV = _v5.c;
			var rLeft = _v5.d;
			var rRight = _v5.e;
			if (clr.$ === 'Black') {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Black,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, rK, rV, rLeft, rRight));
			} else {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Black,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, rK, rV, rLeft, rRight));
			}
		}
	} else {
		return dict;
	}
};
var $elm$core$Dict$moveRedRight = function (dict) {
	if (((dict.$ === 'RBNode_elm_builtin') && (dict.d.$ === 'RBNode_elm_builtin')) && (dict.e.$ === 'RBNode_elm_builtin')) {
		if ((dict.d.d.$ === 'RBNode_elm_builtin') && (dict.d.d.a.$ === 'Red')) {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v1 = dict.d;
			var lClr = _v1.a;
			var lK = _v1.b;
			var lV = _v1.c;
			var _v2 = _v1.d;
			var _v3 = _v2.a;
			var llK = _v2.b;
			var llV = _v2.c;
			var llLeft = _v2.d;
			var llRight = _v2.e;
			var lRight = _v1.e;
			var _v4 = dict.e;
			var rClr = _v4.a;
			var rK = _v4.b;
			var rV = _v4.c;
			var rLeft = _v4.d;
			var rRight = _v4.e;
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				$elm$core$Dict$Red,
				lK,
				lV,
				A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, llK, llV, llLeft, llRight),
				A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Black,
					k,
					v,
					lRight,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, rK, rV, rLeft, rRight)));
		} else {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v5 = dict.d;
			var lClr = _v5.a;
			var lK = _v5.b;
			var lV = _v5.c;
			var lLeft = _v5.d;
			var lRight = _v5.e;
			var _v6 = dict.e;
			var rClr = _v6.a;
			var rK = _v6.b;
			var rV = _v6.c;
			var rLeft = _v6.d;
			var rRight = _v6.e;
			if (clr.$ === 'Black') {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Black,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, rK, rV, rLeft, rRight));
			} else {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Black,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, rK, rV, rLeft, rRight));
			}
		}
	} else {
		return dict;
	}
};
var $elm$core$Dict$removeHelpPrepEQGT = F7(
	function (targetKey, dict, color, key, value, left, right) {
		if ((left.$ === 'RBNode_elm_builtin') && (left.a.$ === 'Red')) {
			var _v1 = left.a;
			var lK = left.b;
			var lV = left.c;
			var lLeft = left.d;
			var lRight = left.e;
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				color,
				lK,
				lV,
				lLeft,
				A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, key, value, lRight, right));
		} else {
			_v2$2:
			while (true) {
				if ((right.$ === 'RBNode_elm_builtin') && (right.a.$ === 'Black')) {
					if (right.d.$ === 'RBNode_elm_builtin') {
						if (right.d.a.$ === 'Black') {
							var _v3 = right.a;
							var _v4 = right.d;
							var _v5 = _v4.a;
							return $elm$core$Dict$moveRedRight(dict);
						} else {
							break _v2$2;
						}
					} else {
						var _v6 = right.a;
						var _v7 = right.d;
						return $elm$core$Dict$moveRedRight(dict);
					}
				} else {
					break _v2$2;
				}
			}
			return dict;
		}
	});
var $elm$core$Dict$removeMin = function (dict) {
	if ((dict.$ === 'RBNode_elm_builtin') && (dict.d.$ === 'RBNode_elm_builtin')) {
		var color = dict.a;
		var key = dict.b;
		var value = dict.c;
		var left = dict.d;
		var lColor = left.a;
		var lLeft = left.d;
		var right = dict.e;
		if (lColor.$ === 'Black') {
			if ((lLeft.$ === 'RBNode_elm_builtin') && (lLeft.a.$ === 'Red')) {
				var _v3 = lLeft.a;
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					color,
					key,
					value,
					$elm$core$Dict$removeMin(left),
					right);
			} else {
				var _v4 = $elm$core$Dict$moveRedLeft(dict);
				if (_v4.$ === 'RBNode_elm_builtin') {
					var nColor = _v4.a;
					var nKey = _v4.b;
					var nValue = _v4.c;
					var nLeft = _v4.d;
					var nRight = _v4.e;
					return A5(
						$elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						$elm$core$Dict$removeMin(nLeft),
						nRight);
				} else {
					return $elm$core$Dict$RBEmpty_elm_builtin;
				}
			}
		} else {
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				color,
				key,
				value,
				$elm$core$Dict$removeMin(left),
				right);
		}
	} else {
		return $elm$core$Dict$RBEmpty_elm_builtin;
	}
};
var $elm$core$Dict$removeHelp = F2(
	function (targetKey, dict) {
		if (dict.$ === 'RBEmpty_elm_builtin') {
			return $elm$core$Dict$RBEmpty_elm_builtin;
		} else {
			var color = dict.a;
			var key = dict.b;
			var value = dict.c;
			var left = dict.d;
			var right = dict.e;
			if (_Utils_cmp(targetKey, key) < 0) {
				if ((left.$ === 'RBNode_elm_builtin') && (left.a.$ === 'Black')) {
					var _v4 = left.a;
					var lLeft = left.d;
					if ((lLeft.$ === 'RBNode_elm_builtin') && (lLeft.a.$ === 'Red')) {
						var _v6 = lLeft.a;
						return A5(
							$elm$core$Dict$RBNode_elm_builtin,
							color,
							key,
							value,
							A2($elm$core$Dict$removeHelp, targetKey, left),
							right);
					} else {
						var _v7 = $elm$core$Dict$moveRedLeft(dict);
						if (_v7.$ === 'RBNode_elm_builtin') {
							var nColor = _v7.a;
							var nKey = _v7.b;
							var nValue = _v7.c;
							var nLeft = _v7.d;
							var nRight = _v7.e;
							return A5(
								$elm$core$Dict$balance,
								nColor,
								nKey,
								nValue,
								A2($elm$core$Dict$removeHelp, targetKey, nLeft),
								nRight);
						} else {
							return $elm$core$Dict$RBEmpty_elm_builtin;
						}
					}
				} else {
					return A5(
						$elm$core$Dict$RBNode_elm_builtin,
						color,
						key,
						value,
						A2($elm$core$Dict$removeHelp, targetKey, left),
						right);
				}
			} else {
				return A2(
					$elm$core$Dict$removeHelpEQGT,
					targetKey,
					A7($elm$core$Dict$removeHelpPrepEQGT, targetKey, dict, color, key, value, left, right));
			}
		}
	});
var $elm$core$Dict$removeHelpEQGT = F2(
	function (targetKey, dict) {
		if (dict.$ === 'RBNode_elm_builtin') {
			var color = dict.a;
			var key = dict.b;
			var value = dict.c;
			var left = dict.d;
			var right = dict.e;
			if (_Utils_eq(targetKey, key)) {
				var _v1 = $elm$core$Dict$getMin(right);
				if (_v1.$ === 'RBNode_elm_builtin') {
					var minKey = _v1.b;
					var minValue = _v1.c;
					return A5(
						$elm$core$Dict$balance,
						color,
						minKey,
						minValue,
						left,
						$elm$core$Dict$removeMin(right));
				} else {
					return $elm$core$Dict$RBEmpty_elm_builtin;
				}
			} else {
				return A5(
					$elm$core$Dict$balance,
					color,
					key,
					value,
					left,
					A2($elm$core$Dict$removeHelp, targetKey, right));
			}
		} else {
			return $elm$core$Dict$RBEmpty_elm_builtin;
		}
	});
var $elm$core$Dict$remove = F2(
	function (key, dict) {
		var _v0 = A2($elm$core$Dict$removeHelp, key, dict);
		if ((_v0.$ === 'RBNode_elm_builtin') && (_v0.a.$ === 'Red')) {
			var _v1 = _v0.a;
			var k = _v0.b;
			var v = _v0.c;
			var l = _v0.d;
			var r = _v0.e;
			return A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, k, v, l, r);
		} else {
			var x = _v0;
			return x;
		}
	});
var $elm$core$Dict$update = F3(
	function (targetKey, alter, dictionary) {
		var _v0 = alter(
			A2($elm$core$Dict$get, targetKey, dictionary));
		if (_v0.$ === 'Just') {
			var value = _v0.a;
			return A3($elm$core$Dict$insert, targetKey, value, dictionary);
		} else {
			return A2($elm$core$Dict$remove, targetKey, dictionary);
		}
	});
var $author$project$ModelAPI$updateMaps = F3(
	function (mapId, mapFunc, maps) {
		return A3(
			$elm$core$Dict$update,
			mapId,
			function (map_) {
				if (map_.$ === 'Just') {
					var map = map_.a;
					return $elm$core$Maybe$Just(
						mapFunc(map));
				} else {
					return A3($author$project$ModelAPI$illegalMapId, 'updateMaps', mapId, $elm$core$Maybe$Nothing);
				}
			},
			maps);
	});
var $author$project$ModelAPI$addItemToMap = F4(
	function (itemId, props, mapId, model) {
		var _v0 = A6($author$project$ModelAPI$createAssoc, 'dmx.composition', 'dmx.child', itemId, 'dmx.parent', mapId, model);
		var newModel = _v0.a;
		var parentAssocId = _v0.b;
		var mapItem = A5($author$project$Model$MapItem, itemId, parentAssocId, false, false, props);
		var _v1 = A2(
			$author$project$Logger$log,
			'addItemToMap',
			{itemId: itemId, mapId: mapId, parentAssocId: parentAssocId, props: props});
		return _Utils_update(
			newModel,
			{
				maps: A3(
					$author$project$ModelAPI$updateMaps,
					mapId,
					function (map) {
						return _Utils_update(
							map,
							{
								items: A3($elm$core$Dict$insert, itemId, mapItem, map.items)
							});
					},
					newModel.maps)
			});
	});
var $author$project$ModelAPI$createTopic = F3(
	function (text, iconName, model) {
		var id = model.nextId;
		var topic = A2(
			$author$project$Model$Item,
			id,
			$author$project$Model$Topic(
				A3($author$project$Model$TopicInfo, id, text, iconName)));
		return _Utils_Tuple2(
			$author$project$ModelAPI$nextId(
				_Utils_update(
					model,
					{
						items: A3($elm$core$Dict$insert, id, topic, model.items)
					})),
			id);
	});
var $author$project$ModelAPI$getMapIfExists = F2(
	function (mapId, maps) {
		return A2($elm$core$Dict$get, mapId, maps);
	});
var $author$project$ModelAPI$getMap = F2(
	function (mapId, maps) {
		var _v0 = A2($author$project$ModelAPI$getMapIfExists, mapId, maps);
		if (_v0.$ === 'Just') {
			var map = _v0.a;
			return $elm$core$Maybe$Just(map);
		} else {
			return A3($author$project$ModelAPI$illegalMapId, 'getMap', mapId, $elm$core$Maybe$Nothing);
		}
	});
var $author$project$ModelAPI$getMapId = function (mapPath) {
	if (mapPath.b) {
		var mapId = mapPath.a;
		return mapId;
	} else {
		return -1;
	}
};
var $author$project$Config$newTopicPos = A2($author$project$Model$Point, 186, 180);
var $author$project$ModelAPI$select = F3(
	function (itemId, mapPath, model) {
		return _Utils_update(
			model,
			{
				selection: _List_fromArray(
					[
						_Utils_Tuple2(itemId, mapPath)
					])
			});
	});
var $author$project$Config$contentFontSize = 13;
var $author$project$Config$topicBorderWidth = 1;
var $author$project$Config$topicDetailPadding = 8;
var $author$project$Config$topicHeight = 28;
var $author$project$Config$topicLineHeight = 1.5;
var $author$project$Config$topicWidth = 156;
var $author$project$Config$topicDetailSize = A2($author$project$Model$Size, $author$project$Config$topicWidth - $author$project$Config$topicHeight, ($author$project$Config$topicLineHeight * $author$project$Config$contentFontSize) + (2 * ($author$project$Config$topicDetailPadding + $author$project$Config$topicBorderWidth)));
var $author$project$ModelAPI$createTopicIn = F4(
	function (text, iconName, mapPath, model) {
		var mapId = $author$project$ModelAPI$getMapId(mapPath);
		var _v0 = A2($author$project$ModelAPI$getMap, mapId, model.maps);
		if (_v0.$ === 'Just') {
			var map = _v0.a;
			var props = $author$project$Model$MapTopic(
				A3(
					$author$project$Model$TopicProps,
					A2($author$project$Model$Point, $author$project$Config$newTopicPos.x + map.rect.x1, $author$project$Config$newTopicPos.y + map.rect.y1),
					$author$project$Config$topicDetailSize,
					$author$project$Model$Monad($author$project$Model$LabelOnly)));
			var _v1 = A3($author$project$ModelAPI$createTopic, text, iconName, model);
			var newModel = _v1.a;
			var topicId = _v1.b;
			return A3(
				$author$project$ModelAPI$select,
				topicId,
				mapPath,
				A4($author$project$ModelAPI$addItemToMap, topicId, props, mapId, newModel));
		} else {
			return model;
		}
	});
var $author$project$Model$ItemEdit = F2(
	function (a, b) {
		return {$: 'ItemEdit', a: a, b: b};
	});
var $elm$core$Basics$min = F2(
	function (x, y) {
		return (_Utils_cmp(x, y) < 0) ? x : y;
	});
var $author$project$Config$topicDetailMaxWidth = 300;
var $author$project$Config$topicH2 = $author$project$Config$topicHeight / 2;
var $author$project$Config$topicSize = A2($author$project$Model$Size, $author$project$Config$topicWidth, $author$project$Config$topicHeight);
var $author$project$Config$topicW2 = $author$project$Config$topicWidth / 2;
var $author$project$MapAutoSize$detailTopicExtent = F6(
	function (topicId, mapId, pos, size, rectAcc, model) {
		var textWidth = _Utils_eq(
			model.editState,
			A2($author$project$Model$ItemEdit, topicId, mapId)) ? $author$project$Config$topicDetailMaxWidth : size.w;
		return A4(
			$author$project$Model$Rectangle,
			A2($elm$core$Basics$min, rectAcc.x1, pos.x - $author$project$Config$topicW2),
			A2($elm$core$Basics$min, rectAcc.y1, pos.y - $author$project$Config$topicH2),
			A2($elm$core$Basics$max, rectAcc.x2, (((pos.x - $author$project$Config$topicW2) + textWidth) + $author$project$Config$topicSize.h) + (2 * $author$project$Config$topicBorderWidth)),
			A2($elm$core$Basics$max, rectAcc.y2, ((pos.y - $author$project$Config$topicH2) + size.h) + (2 * $author$project$Config$topicBorderWidth)));
	});
var $author$project$MapAutoSize$mapExtent = F3(
	function (pos, rect, rectAcc) {
		var mapWidth = rect.x2 - rect.x1;
		var mapHeight = rect.y2 - rect.y1;
		return A4(
			$author$project$Model$Rectangle,
			A2($elm$core$Basics$min, rectAcc.x1, pos.x - $author$project$Config$topicW2),
			A2($elm$core$Basics$min, rectAcc.y1, pos.y - $author$project$Config$topicH2),
			A2($elm$core$Basics$max, rectAcc.x2, (pos.x - $author$project$Config$topicW2) + mapWidth),
			A2($elm$core$Basics$max, rectAcc.y2, (pos.y + $author$project$Config$topicH2) + mapHeight));
	});
var $author$project$MapAutoSize$topicExtent = F2(
	function (pos, rectAcc) {
		return A4(
			$author$project$Model$Rectangle,
			A2($elm$core$Basics$min, rectAcc.x1, pos.x - $author$project$Config$topicW2),
			A2($elm$core$Basics$min, rectAcc.y1, pos.y - $author$project$Config$topicH2),
			A2($elm$core$Basics$max, rectAcc.x2, (pos.x + $author$project$Config$topicW2) + (2 * $author$project$Config$topicBorderWidth)),
			A2($elm$core$Basics$max, rectAcc.y2, (pos.y + $author$project$Config$topicH2) + (2 * $author$project$Config$topicBorderWidth)));
	});
var $author$project$MapAutoSize$accumulateSize = F4(
	function (mapItem, mapId, rectAcc, model) {
		var _v0 = mapItem.props;
		if (_v0.$ === 'MapTopic') {
			var pos = _v0.a.pos;
			var size = _v0.a.size;
			var displayMode = _v0.a.displayMode;
			if (displayMode.$ === 'Monad') {
				if (displayMode.a.$ === 'LabelOnly') {
					var _v2 = displayMode.a;
					return A2($author$project$MapAutoSize$topicExtent, pos, rectAcc);
				} else {
					var _v3 = displayMode.a;
					return A6($author$project$MapAutoSize$detailTopicExtent, mapItem.id, mapId, pos, size, rectAcc, model);
				}
			} else {
				switch (displayMode.a.$) {
					case 'BlackBox':
						var _v4 = displayMode.a;
						return A2($author$project$MapAutoSize$topicExtent, pos, rectAcc);
					case 'WhiteBox':
						var _v5 = displayMode.a;
						var _v6 = A2($author$project$ModelAPI$getMap, mapItem.id, model.maps);
						if (_v6.$ === 'Just') {
							var map = _v6.a;
							return A3($author$project$MapAutoSize$mapExtent, pos, map.rect, rectAcc);
						} else {
							return A4($author$project$Model$Rectangle, 0, 0, 0, 0);
						}
					default:
						var _v7 = displayMode.a;
						return A2($author$project$MapAutoSize$topicExtent, pos, rectAcc);
				}
			}
		} else {
			return rectAcc;
		}
	});
var $elm$core$List$filter = F2(
	function (isGood, list) {
		return A3(
			$elm$core$List$foldr,
			F2(
				function (x, xs) {
					return isGood(x) ? A2($elm$core$List$cons, x, xs) : xs;
				}),
			_List_Nil,
			list);
	});
var $elm$core$Basics$not = _Basics_not;
var $author$project$ModelAPI$isVisible = function (item) {
	return !item.hidden;
};
var $author$project$ModelAPI$illegalItemId = F3(
	function (funcName, id, val) {
		return A4($author$project$ModelAPI$illegalId, funcName, 'Item', id, val);
	});
var $author$project$ModelAPI$topicMismatch = F3(
	function (funcName, id, val) {
		return A3(
			$author$project$Utils$logError,
			funcName,
			$elm$core$String$fromInt(id) + ' is not a Topic but an Assoc',
			val);
	});
var $author$project$ModelAPI$updateTopicProps = F4(
	function (topicId, mapId, propsFunc, model) {
		return _Utils_update(
			model,
			{
				maps: A3(
					$author$project$ModelAPI$updateMaps,
					mapId,
					function (map) {
						return _Utils_update(
							map,
							{
								items: A3(
									$elm$core$Dict$update,
									topicId,
									function (mapItem_) {
										if (mapItem_.$ === 'Just') {
											var mapItem = mapItem_.a;
											var _v1 = mapItem.props;
											if (_v1.$ === 'MapTopic') {
												var props = _v1.a;
												return $elm$core$Maybe$Just(
													_Utils_update(
														mapItem,
														{
															props: $author$project$Model$MapTopic(
																propsFunc(props))
														}));
											} else {
												return A3($author$project$ModelAPI$topicMismatch, 'updateTopicProps', topicId, $elm$core$Maybe$Nothing);
											}
										} else {
											return A3($author$project$ModelAPI$illegalItemId, 'updateTopicProps', topicId, $elm$core$Maybe$Nothing);
										}
									},
									map.items)
							});
					},
					model.maps)
			});
	});
var $author$project$ModelAPI$setTopicPosByDelta = F4(
	function (topicId, mapId, delta, model) {
		return A4(
			$author$project$ModelAPI$updateTopicProps,
			topicId,
			mapId,
			function (props) {
				return _Utils_update(
					props,
					{
						pos: A2($author$project$Model$Point, props.pos.x + delta.x, props.pos.y + delta.y)
					});
			},
			model);
	});
var $author$project$ModelAPI$updateMapRect = F3(
	function (mapId, rectFunc, model) {
		return _Utils_update(
			model,
			{
				maps: A3(
					$author$project$ModelAPI$updateMaps,
					mapId,
					function (map) {
						return _Utils_update(
							map,
							{
								rect: rectFunc(map.rect)
							});
					},
					model.maps)
			});
	});
var $author$project$MapAutoSize$storeMapRect = F5(
	function (mapId, newRect, oldRect, parentMapId, model) {
		return A4(
			$author$project$ModelAPI$setTopicPosByDelta,
			mapId,
			parentMapId,
			A2($author$project$Model$Point, newRect.x1 - oldRect.x1, newRect.y1 - oldRect.y1),
			A3(
				$author$project$ModelAPI$updateMapRect,
				mapId,
				function (_v0) {
					return newRect;
				},
				model));
	});
var $elm$core$Dict$values = function (dict) {
	return A3(
		$elm$core$Dict$foldr,
		F3(
			function (key, value, valueList) {
				return A2($elm$core$List$cons, value, valueList);
			}),
		_List_Nil,
		dict);
};
var $author$project$Config$whiteBoxPadding = 12;
var $author$project$MapAutoSize$calcMapRect = F3(
	function (mapId, parentMapId, model) {
		var _v0 = A2($author$project$ModelAPI$getMap, mapId, model.maps);
		if (_v0.$ === 'Just') {
			var map = _v0.a;
			var rect = A3(
				$elm$core$List$foldr,
				F2(
					function (mapItem, rectAcc) {
						return A4($author$project$MapAutoSize$accumulateSize, mapItem, mapId, rectAcc, model);
					}),
				A4($author$project$Model$Rectangle, 5000, 5000, -5000, -5000),
				A2(
					$elm$core$List$filter,
					$author$project$ModelAPI$isVisible,
					$elm$core$Dict$values(map.items)));
			var newRect = A4($author$project$Model$Rectangle, rect.x1 - $author$project$Config$whiteBoxPadding, rect.y1 - $author$project$Config$whiteBoxPadding, rect.x2 + $author$project$Config$whiteBoxPadding, rect.y2 + $author$project$Config$whiteBoxPadding);
			return A5($author$project$MapAutoSize$storeMapRect, mapId, newRect, map.rect, parentMapId, model);
		} else {
			return model;
		}
	});
var $author$project$MapAutoSize$autoSizeMap = F2(
	function (mapPath, model) {
		if (mapPath.b) {
			if (!mapPath.b.b) {
				return model;
			} else {
				var mapId = mapPath.a;
				var _v1 = mapPath.b;
				var parentMapId = _v1.a;
				var mapIds = _v1.b;
				return A2(
					$author$project$MapAutoSize$autoSizeMap,
					A2($elm$core$List$cons, parentMapId, mapIds),
					A3($author$project$MapAutoSize$calcMapRect, mapId, parentMapId, model));
			}
		} else {
			return A3($author$project$Utils$logError, 'autoSizeMap', 'mapPath is empty!', model);
		}
	});
var $author$project$ModelAPI$getSingleSelection = function (model) {
	var _v0 = model.selection;
	if (_v0.b && (!_v0.b.b)) {
		var selItem = _v0.a;
		return $elm$core$Maybe$Just(selItem);
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $author$project$MapAutoSize$autoSize = function (model) {
	var _v0 = $author$project$ModelAPI$getSingleSelection(model);
	if (_v0.$ === 'Just') {
		var _v1 = _v0.a;
		var mapPath = _v1.b;
		return A2($author$project$MapAutoSize$autoSizeMap, mapPath, model);
	} else {
		return model;
	}
};
var $author$project$ModelAPI$assocMismatch = F3(
	function (funcName, id, val) {
		return A3(
			$author$project$Utils$logError,
			funcName,
			$elm$core$String$fromInt(id) + ' is not an Assoc but a Topic',
			val);
	});
var $author$project$ModelAPI$getAssocInfo = F2(
	function (assocId, model) {
		var _v0 = A2($elm$core$Dict$get, assocId, model.items);
		if (_v0.$ === 'Just') {
			var info = _v0.a.info;
			if (info.$ === 'Topic') {
				return A3($author$project$ModelAPI$assocMismatch, 'getAssocInfo', assocId, $elm$core$Maybe$Nothing);
			} else {
				var assoc = info.a;
				return $elm$core$Maybe$Just(assoc);
			}
		} else {
			return A3($author$project$ModelAPI$illegalItemId, 'getAssocInfo', assocId, $elm$core$Maybe$Nothing);
		}
	});
var $author$project$ModelAPI$hasPlayer = F3(
	function (playerId, model, assocId) {
		var _v0 = A2($author$project$ModelAPI$getAssocInfo, assocId, model);
		if (_v0.$ === 'Just') {
			var assoc = _v0.a;
			return _Utils_eq(assoc.player1, playerId) || _Utils_eq(assoc.player2, playerId);
		} else {
			return false;
		}
	});
var $author$project$ModelAPI$isTopic = function (item) {
	var _v0 = item.info;
	if (_v0.$ === 'Topic') {
		return true;
	} else {
		return false;
	}
};
var $author$project$ModelAPI$isAssoc = function (item) {
	return !$author$project$ModelAPI$isTopic(item);
};
var $author$project$ModelAPI$assocsOfPlayer = F2(
	function (playerId, model) {
		return A2(
			$elm$core$List$filter,
			A2($author$project$ModelAPI$hasPlayer, playerId, model),
			A2(
				$elm$core$List$map,
				function ($) {
					return $.id;
				},
				A2(
					$elm$core$List$filter,
					$author$project$ModelAPI$isAssoc,
					$elm$core$Dict$values(model.items))));
	});
var $elm$core$Dict$map = F2(
	function (func, dict) {
		if (dict.$ === 'RBEmpty_elm_builtin') {
			return $elm$core$Dict$RBEmpty_elm_builtin;
		} else {
			var color = dict.a;
			var key = dict.b;
			var value = dict.c;
			var left = dict.d;
			var right = dict.e;
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				color,
				key,
				A2(func, key, value),
				A2($elm$core$Dict$map, func, left),
				A2($elm$core$Dict$map, func, right));
		}
	});
var $author$project$ModelAPI$deleteItem = F2(
	function (itemId, model) {
		return A3(
			$elm$core$List$foldr,
			$author$project$ModelAPI$deleteItem,
			_Utils_update(
				model,
				{
					items: A2($elm$core$Dict$remove, itemId, model.items),
					maps: A2(
						$elm$core$Dict$map,
						F2(
							function (_v0, map) {
								return _Utils_update(
									map,
									{
										items: A2($elm$core$Dict$remove, itemId, map.items)
									});
							}),
						model.maps)
				}),
			A2($author$project$ModelAPI$assocsOfPlayer, itemId, model));
	});
var $author$project$Main$delete = function (model) {
	var newModel = A3(
		$elm$core$List$foldr,
		F2(
			function (itemId, modelAcc) {
				return A2($author$project$ModelAPI$deleteItem, itemId, modelAcc);
			}),
		model,
		A2($elm$core$List$map, $elm$core$Tuple$first, model.selection));
	return $author$project$MapAutoSize$autoSize(
		_Utils_update(
			newModel,
			{selection: _List_Nil}));
};
var $author$project$Main$describeDisplayMode = function (dm) {
	if (dm.$ === 'Monad') {
		if (dm.a.$ === 'LabelOnly') {
			var _v1 = dm.a;
			return 'Monad(LabelOnly)';
		} else {
			var _v2 = dm.a;
			return 'Monad(Detail)';
		}
	} else {
		switch (dm.a.$) {
			case 'BlackBox':
				var _v3 = dm.a;
				return 'Container(BlackBox)';
			case 'WhiteBox':
				var _v4 = dm.a;
				return 'Container(WhiteBox)';
			default:
				var _v5 = dm.a;
				return 'Container(Unboxed)';
		}
	}
};
var $elm$core$Maybe$map = F2(
	function (f, maybe) {
		if (maybe.$ === 'Just') {
			var value = maybe.a;
			return $elm$core$Maybe$Just(
				f(value));
		} else {
			return $elm$core$Maybe$Nothing;
		}
	});
var $author$project$ModelAPI$isMapTopic = function (item) {
	var _v0 = item.props;
	if (_v0.$ === 'MapTopic') {
		return true;
	} else {
		return false;
	}
};
var $author$project$ModelAPI$isMapAssoc = function (item) {
	return !$author$project$ModelAPI$isMapTopic(item);
};
var $author$project$ModelAPI$mapAssocsOfPlayer_ = F3(
	function (playerId, items, model) {
		return A2(
			$elm$core$List$filter,
			A2($author$project$ModelAPI$hasPlayer, playerId, model),
			A2(
				$elm$core$List$map,
				function ($) {
					return $.id;
				},
				A2(
					$elm$core$List$filter,
					$author$project$ModelAPI$isMapAssoc,
					$elm$core$Dict$values(items))));
	});
var $author$project$ModelAPI$hideItem_ = F3(
	function (itemId, items, model) {
		return A3(
			$elm$core$List$foldr,
			F2(
				function (assocId, itemsAcc) {
					return A3($author$project$ModelAPI$hideItem_, assocId, itemsAcc, model);
				}),
			A3(
				$elm$core$Dict$update,
				itemId,
				$elm$core$Maybe$map(
					function (item) {
						return _Utils_update(
							item,
							{hidden: true});
					}),
				items),
			A3($author$project$ModelAPI$mapAssocsOfPlayer_, itemId, items, model));
	});
var $author$project$ModelAPI$hideItem = F3(
	function (itemId, mapId, model) {
		return _Utils_update(
			model,
			{
				maps: A3(
					$author$project$ModelAPI$updateMaps,
					mapId,
					function (map) {
						return _Utils_update(
							map,
							{
								items: A3($author$project$ModelAPI$hideItem_, itemId, map.items, model)
							});
					},
					model.maps)
			});
	});
var $author$project$Main$hide = function (model) {
	var newModel = A3(
		$elm$core$List$foldr,
		F2(
			function (_v0, modelAcc) {
				var itemId = _v0.a;
				var mapPath = _v0.b;
				return A3(
					$author$project$ModelAPI$hideItem,
					itemId,
					$author$project$ModelAPI$getMapId(mapPath),
					modelAcc);
			}),
		model,
		model.selection);
	return $author$project$MapAutoSize$autoSize(
		_Utils_update(
			newModel,
			{selection: _List_Nil}));
};
var $author$project$Compat$ModelAPI$isSelfContainment = F2(
	function (itemId, mapId) {
		return _Utils_eq(itemId, mapId);
	});
var $elm$core$List$any = F2(
	function (isOkay, list) {
		any:
		while (true) {
			if (!list.b) {
				return false;
			} else {
				var x = list.a;
				var xs = list.b;
				if (isOkay(x)) {
					return true;
				} else {
					var $temp$isOkay = isOkay,
						$temp$list = xs;
					isOkay = $temp$isOkay;
					list = $temp$list;
					continue any;
				}
			}
		}
	});
var $elm$core$List$member = F2(
	function (x, xs) {
		return A2(
			$elm$core$List$any,
			function (a) {
				return _Utils_eq(a, x);
			},
			xs);
	});
var $author$project$Compat$ModelAPI$wouldCreateAncestralCycle = F2(
	function (model, _v0) {
		var parent = _v0.parent;
		var child = _v0.child;
		var childrenOf = function (pid) {
			return A2(
				$elm$core$List$filterMap,
				function (it) {
					var _v1 = it.info;
					if (_v1.$ === 'Assoc') {
						var assoc = _v1.a;
						return ((assoc.itemType === 'dmx.composition') && _Utils_eq(assoc.player2, pid)) ? $elm$core$Maybe$Just(assoc.player1) : $elm$core$Maybe$Nothing;
					} else {
						return $elm$core$Maybe$Nothing;
					}
				},
				$elm$core$Dict$values(model.items));
		};
		var dfs = F2(
			function (seen, cur) {
				return A2($elm$core$List$member, cur, seen) ? false : (_Utils_eq(cur, parent) ? true : A2(
					$elm$core$List$any,
					dfs(
						A2($elm$core$List$cons, cur, seen)),
					childrenOf(cur)));
			});
		return A2(dfs, _List_Nil, child);
	});
var $author$project$Compat$ModelAPI$addItemToMap = F4(
	function (itemId, props, mapId, model) {
		return A2($author$project$Compat$ModelAPI$isSelfContainment, itemId, mapId) ? model : (A2(
			$author$project$Compat$ModelAPI$wouldCreateAncestralCycle,
			model,
			{child: itemId, parent: mapId}) ? model : A4($author$project$ModelAPI$addItemToMap, itemId, props, mapId, model));
	});
var $author$project$ModelAPI$createMap = F2(
	function (mapId, model) {
		return _Utils_update(
			model,
			{
				maps: A3(
					$elm$core$Dict$insert,
					mapId,
					A3(
						$author$project$Model$Map,
						mapId,
						A4($author$project$Model$Rectangle, 0, 0, 0, 0),
						$elm$core$Dict$empty),
					model.maps)
			});
	});
var $elm$core$Dict$member = F2(
	function (key, dict) {
		var _v0 = A2($elm$core$Dict$get, key, dict);
		if (_v0.$ === 'Just') {
			return true;
		} else {
			return false;
		}
	});
var $author$project$ModelAPI$hasMap = F2(
	function (mapId, maps) {
		return A2($elm$core$Dict$member, mapId, maps);
	});
var $author$project$ModelAPI$isItemInMap = F3(
	function (itemId, mapId, model) {
		var _v0 = A2($author$project$ModelAPI$getMap, mapId, model.maps);
		if (_v0.$ === 'Just') {
			var map = _v0.a;
			var _v1 = A2($elm$core$Dict$get, itemId, map.items);
			if (_v1.$ === 'Just') {
				return true;
			} else {
				return false;
			}
		} else {
			return false;
		}
	});
var $author$project$ModelAPI$setDisplayMode = F4(
	function (topicId, mapId, displayMode, model) {
		return A4(
			$author$project$ModelAPI$updateTopicProps,
			topicId,
			mapId,
			function (props) {
				return _Utils_update(
					props,
					{displayMode: displayMode});
			},
			model);
	});
var $author$project$Main$setDisplayModeInAllMaps = F3(
	function (topicId, displayMode, model) {
		return A3(
			$elm$core$Dict$foldr,
			F3(
				function (mapId, _v0, modelAcc) {
					var _v1 = A3($author$project$ModelAPI$isItemInMap, topicId, mapId, model);
					if (_v1) {
						return A4($author$project$ModelAPI$setDisplayMode, topicId, mapId, displayMode, modelAcc);
					} else {
						return modelAcc;
					}
				}),
			model,
			model.maps);
	});
var $author$project$Main$createMapIfNeeded = F2(
	function (topicId, model) {
		return A2($author$project$ModelAPI$hasMap, topicId, model.maps) ? _Utils_Tuple2(model, false) : _Utils_Tuple2(
			A3(
				$author$project$Main$setDisplayModeInAllMaps,
				topicId,
				$author$project$Model$Container($author$project$Model$BlackBox),
				A2($author$project$ModelAPI$createMap, topicId, model)),
			true);
	});
var $author$project$Utils$fail = F3(
	function (funcName, args, val) {
		return A2(
			$author$project$Logger$log,
			'--> @' + (funcName + (' failed ' + $author$project$Logger$toString(args))),
			val);
	});
var $elm$core$Maybe$andThen = F2(
	function (callback, maybeValue) {
		if (maybeValue.$ === 'Just') {
			var value = maybeValue.a;
			return callback(value);
		} else {
			return $elm$core$Maybe$Nothing;
		}
	});
var $author$project$ModelAPI$itemNotInMap = F4(
	function (funcName, itemId, mapId, val) {
		return A3(
			$author$project$Utils$logError,
			funcName,
			'item ' + ($elm$core$String$fromInt(itemId) + (' not in map ' + $elm$core$String$fromInt(mapId))),
			val);
	});
var $author$project$ModelAPI$getMapItem = F2(
	function (itemId, map) {
		var _v0 = A2($elm$core$Dict$get, itemId, map.items);
		if (_v0.$ === 'Just') {
			var mapItem = _v0.a;
			return $elm$core$Maybe$Just(mapItem);
		} else {
			return A4($author$project$ModelAPI$itemNotInMap, 'getMapItem', itemId, map.id, $elm$core$Maybe$Nothing);
		}
	});
var $author$project$ModelAPI$getMapItemById = F3(
	function (itemId, mapId, maps) {
		return A2(
			$elm$core$Maybe$andThen,
			$author$project$ModelAPI$getMapItem(itemId),
			A2($author$project$ModelAPI$getMap, mapId, maps));
	});
var $author$project$ModelAPI$getTopicProps = F3(
	function (topicId, mapId, maps) {
		var _v0 = A3($author$project$ModelAPI$getMapItemById, topicId, mapId, maps);
		if (_v0.$ === 'Just') {
			var mapItem = _v0.a;
			var _v1 = mapItem.props;
			if (_v1.$ === 'MapTopic') {
				var props = _v1.a;
				return $elm$core$Maybe$Just(props);
			} else {
				return A3($author$project$ModelAPI$topicMismatch, 'getTopicProps', topicId, $elm$core$Maybe$Nothing);
			}
		} else {
			return A3(
				$author$project$Utils$fail,
				'getTopicProps',
				{mapId: mapId, topicId: topicId},
				$elm$core$Maybe$Nothing);
		}
	});
var $author$project$ModelAPI$setTopicPos = F4(
	function (topicId, mapId, pos, model) {
		return A4(
			$author$project$ModelAPI$updateTopicProps,
			topicId,
			mapId,
			function (props) {
				return _Utils_update(
					props,
					{pos: pos});
			},
			model);
	});
var $elm$core$Maybe$withDefault = F2(
	function (_default, maybe) {
		if (maybe.$ === 'Just') {
			var value = maybe.a;
			return value;
		} else {
			return _default;
		}
	});
var $author$project$Main$moveTopicToMap = F7(
	function (topicId, containerId, origPos, targetId, targetMapPath, newPos, model0) {
		var targetMapId = A2(
			$elm$core$Maybe$withDefault,
			0,
			$elm$core$List$head(
				$elm$core$List$reverse(targetMapPath)));
		var isSelfTarget = _Utils_eq(targetId, topicId);
		var _v0 = A2($author$project$Main$createMapIfNeeded, targetId, model0);
		var model1 = _v0.a;
		var created = _v0.b;
		var actualPos = created ? A2($author$project$Model$Point, $author$project$Config$topicW2 + $author$project$Config$whiteBoxPadding, $author$project$Config$topicH2 + $author$project$Config$whiteBoxPadding) : newPos;
		var props_ = A2(
			$elm$core$Maybe$map,
			function (p) {
				return $author$project$Model$MapTopic(
					_Utils_update(
						p,
						{pos: actualPos}));
			},
			A3($author$project$ModelAPI$getTopicProps, topicId, containerId, model1.maps));
		if (isSelfTarget) {
			return model0;
		} else {
			if (props_.$ === 'Just') {
				var props = props_.a;
				return $author$project$MapAutoSize$autoSize(
					A3(
						$author$project$ModelAPI$select,
						targetId,
						targetMapPath,
						A4(
							$author$project$Compat$ModelAPI$addItemToMap,
							topicId,
							props,
							targetId,
							A4(
								$author$project$ModelAPI$setTopicPos,
								topicId,
								containerId,
								origPos,
								A3($author$project$ModelAPI$hideItem, topicId, containerId, model1)))));
			} else {
				return model0;
			}
		}
	});
var $elm$json$Json$Decode$decodeString = _Json_runOnString;
var $author$project$FedWiki$titleDecoder = A2($elm$json$Json$Decode$field, 'title', $elm$json$Json$Decode$string);
var $author$project$FedWiki$renderAsMonad = F2(
	function (raw, model) {
		var _v0 = A2($elm$json$Json$Decode$decodeString, $author$project$FedWiki$titleDecoder, raw);
		if (_v0.$ === 'Ok') {
			var title = _v0.a;
			return A4(
				$author$project$ModelAPI$createTopicIn,
				title,
				$elm$core$Maybe$Nothing,
				_List_fromArray(
					[0]),
				model);
		} else {
			return model;
		}
	});
var $elm$json$Json$Encode$int = _Json_wrap;
var $elm$json$Json$Encode$object = function (pairs) {
	return _Json_wrap(
		A3(
			$elm$core$List$foldl,
			F2(
				function (_v0, obj) {
					var k = _v0.a;
					var v = _v0.b;
					return A3(_Json_addField, k, v, obj);
				}),
			_Json_emptyObject(_Utils_Tuple0),
			pairs));
};
var $elm$json$Json$Encode$string = _Json_wrap;
var $author$project$Storage$encodeItem = function (item) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				function () {
				var _v0 = item.info;
				if (_v0.$ === 'Topic') {
					var topic = _v0.a;
					return _Utils_Tuple2(
						'topic',
						$elm$json$Json$Encode$object(
							_List_fromArray(
								[
									_Utils_Tuple2(
									'id',
									$elm$json$Json$Encode$int(topic.id)),
									_Utils_Tuple2(
									'text',
									$elm$json$Json$Encode$string(topic.text)),
									_Utils_Tuple2(
									'icon',
									$elm$json$Json$Encode$string(
										A2($elm$core$Maybe$withDefault, '', topic.iconName)))
								])));
				} else {
					var assoc = _v0.a;
					return _Utils_Tuple2(
						'assoc',
						$elm$json$Json$Encode$object(
							_List_fromArray(
								[
									_Utils_Tuple2(
									'id',
									$elm$json$Json$Encode$int(assoc.id)),
									_Utils_Tuple2(
									'type',
									$elm$json$Json$Encode$string(assoc.itemType)),
									_Utils_Tuple2(
									'role1',
									$elm$json$Json$Encode$string(assoc.role1)),
									_Utils_Tuple2(
									'player1',
									$elm$json$Json$Encode$int(assoc.player1)),
									_Utils_Tuple2(
									'role2',
									$elm$json$Json$Encode$string(assoc.role2)),
									_Utils_Tuple2(
									'player2',
									$elm$json$Json$Encode$int(assoc.player2))
								])));
				}
			}()
			]));
};
var $elm$json$Json$Encode$bool = _Json_wrap;
var $author$project$Storage$encodeDisplayName = function (displayMode) {
	return $elm$json$Json$Encode$string(
		function () {
			if (displayMode.$ === 'Monad') {
				if (displayMode.a.$ === 'LabelOnly') {
					var _v1 = displayMode.a;
					return 'LabelOnly';
				} else {
					var _v2 = displayMode.a;
					return 'Detail';
				}
			} else {
				switch (displayMode.a.$) {
					case 'BlackBox':
						var _v3 = displayMode.a;
						return 'BlackBox';
					case 'WhiteBox':
						var _v4 = displayMode.a;
						return 'WhiteBox';
					default:
						var _v5 = displayMode.a;
						return 'Unboxed';
				}
			}
		}());
};
var $elm$json$Json$Encode$float = _Json_wrap;
var $author$project$Storage$encodeMapItem = function (item) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'id',
				$elm$json$Json$Encode$int(item.id)),
				_Utils_Tuple2(
				'parentAssocId',
				$elm$json$Json$Encode$int(item.parentAssocId)),
				_Utils_Tuple2(
				'hidden',
				$elm$json$Json$Encode$bool(item.hidden)),
				_Utils_Tuple2(
				'pinned',
				$elm$json$Json$Encode$bool(item.pinned)),
				function () {
				var _v0 = item.props;
				if (_v0.$ === 'MapTopic') {
					var topicProps = _v0.a;
					return _Utils_Tuple2(
						'topicProps',
						$elm$json$Json$Encode$object(
							_List_fromArray(
								[
									_Utils_Tuple2(
									'pos',
									$elm$json$Json$Encode$object(
										_List_fromArray(
											[
												_Utils_Tuple2(
												'x',
												$elm$json$Json$Encode$float(topicProps.pos.x)),
												_Utils_Tuple2(
												'y',
												$elm$json$Json$Encode$float(topicProps.pos.y))
											]))),
									_Utils_Tuple2(
									'size',
									$elm$json$Json$Encode$object(
										_List_fromArray(
											[
												_Utils_Tuple2(
												'w',
												$elm$json$Json$Encode$float(topicProps.size.w)),
												_Utils_Tuple2(
												'h',
												$elm$json$Json$Encode$float(topicProps.size.h))
											]))),
									_Utils_Tuple2(
									'display',
									$author$project$Storage$encodeDisplayName(topicProps.displayMode))
								])));
				} else {
					return _Utils_Tuple2(
						'assocProps',
						$elm$json$Json$Encode$object(_List_Nil));
				}
			}()
			]));
};
var $elm$json$Json$Encode$list = F2(
	function (func, entries) {
		return _Json_wrap(
			A3(
				$elm$core$List$foldl,
				_Json_addEntry(func),
				_Json_emptyArray(_Utils_Tuple0),
				entries));
	});
var $author$project$Storage$encodeMap = function (map) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'id',
				$elm$json$Json$Encode$int(map.id)),
				_Utils_Tuple2(
				'rect',
				$elm$json$Json$Encode$object(
					_List_fromArray(
						[
							_Utils_Tuple2(
							'x1',
							$elm$json$Json$Encode$float(map.rect.x1)),
							_Utils_Tuple2(
							'y1',
							$elm$json$Json$Encode$float(map.rect.y1)),
							_Utils_Tuple2(
							'x2',
							$elm$json$Json$Encode$float(map.rect.x2)),
							_Utils_Tuple2(
							'y2',
							$elm$json$Json$Encode$float(map.rect.y2))
						]))),
				_Utils_Tuple2(
				'items',
				A2(
					$elm$json$Json$Encode$list,
					$author$project$Storage$encodeMapItem,
					$elm$core$Dict$values(map.items)))
			]));
};
var $author$project$Storage$encodeModel = function (model) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'items',
				A2(
					$elm$json$Json$Encode$list,
					$author$project$Storage$encodeItem,
					$elm$core$Dict$values(model.items))),
				_Utils_Tuple2(
				'maps',
				A2(
					$elm$json$Json$Encode$list,
					$author$project$Storage$encodeMap,
					$elm$core$Dict$values(model.maps))),
				_Utils_Tuple2(
				'mapPath',
				A2($elm$json$Json$Encode$list, $elm$json$Json$Encode$int, model.mapPath)),
				_Utils_Tuple2(
				'nextId',
				$elm$json$Json$Encode$int(model.nextId))
			]));
};
var $author$project$Storage$store = _Platform_outgoingPort('store', $elm$core$Basics$identity);
var $author$project$Storage$storeModel = function (model) {
	return _Utils_Tuple2(
		model,
		$author$project$Storage$store(
			$author$project$Storage$encodeModel(model)));
};
var $author$project$Boxing$boxItems = F3(
	function (containerItems, targetItems, model) {
		return A3(
			$elm$core$List$foldr,
			F2(
				function (containerItem, targetItemsAcc) {
					var _v0 = A2($elm$core$Dict$get, containerItem.id, targetItemsAcc);
					if (_v0.$ === 'Just') {
						var pinned = _v0.a.pinned;
						if (pinned) {
							return A3($author$project$ModelAPI$hideItem_, containerItem.parentAssocId, targetItemsAcc, model);
						} else {
							var items = A3($author$project$ModelAPI$hideItem_, containerItem.id, targetItemsAcc, model);
							var _v1 = A2($author$project$ModelAPI$getMapIfExists, containerItem.id, model.maps);
							if (_v1.$ === 'Just') {
								var map = _v1.a;
								return A3($author$project$Boxing$boxItems, map.items, items, model);
							} else {
								return items;
							}
						}
					} else {
						return targetItemsAcc;
					}
				}),
			targetItems,
			$elm$core$Dict$values(containerItems));
	});
var $author$project$ModelAPI$getDisplayMode = F3(
	function (topicId, mapId, maps) {
		var _v0 = A3($author$project$ModelAPI$getTopicProps, topicId, mapId, maps);
		if (_v0.$ === 'Just') {
			var displayMode = _v0.a.displayMode;
			return $elm$core$Maybe$Just(displayMode);
		} else {
			return A3(
				$author$project$Utils$fail,
				'getDisplayMode',
				{mapId: mapId, topicId: topicId},
				$elm$core$Maybe$Nothing);
		}
	});
var $author$project$Boxing$transferContent = F4(
	function (containerId, targetMapId, transferFunc, model) {
		var _v0 = A2($author$project$ModelAPI$getMap, containerId, model.maps);
		if (_v0.$ === 'Just') {
			var containerMap = _v0.a;
			return A3(
				$author$project$ModelAPI$updateMaps,
				targetMapId,
				function (targetMap) {
					return _Utils_update(
						targetMap,
						{
							items: A3(transferFunc, containerMap.items, targetMap.items, model)
						});
				},
				model.maps);
		} else {
			return model.maps;
		}
	});
var $author$project$Boxing$boxContainer = F3(
	function (containerId, targetMapId, model) {
		var _v0 = A3($author$project$ModelAPI$getDisplayMode, containerId, targetMapId, model.maps);
		if (((_v0.$ === 'Just') && (_v0.a.$ === 'Container')) && (_v0.a.a.$ === 'Unboxed')) {
			var _v1 = _v0.a.a;
			return A4($author$project$Boxing$transferContent, containerId, targetMapId, $author$project$Boxing$boxItems, model);
		} else {
			return model.maps;
		}
	});
var $author$project$Boxing$targetAssocItem = F2(
	function (assocId, targetItems) {
		var _v0 = A2($elm$core$Dict$get, assocId, targetItems);
		if (_v0.$ === 'Just') {
			var item = _v0.a;
			return _Utils_update(
				item,
				{hidden: false});
		} else {
			return A5(
				$author$project$Model$MapItem,
				assocId,
				-1,
				false,
				false,
				$author$project$Model$MapAssoc($author$project$Model$AssocProps));
		}
	});
var $author$project$Boxing$unboxAssoc = F2(
	function (containerItem, targetItems) {
		var assocToInsert = A2($author$project$Boxing$targetAssocItem, containerItem.id, targetItems);
		return A3($elm$core$Dict$insert, assocToInsert.id, assocToInsert, targetItems);
	});
var $author$project$Utils$info = F2(
	function (funcName, val) {
		return A2($author$project$Logger$log, '@' + funcName, val);
	});
var $author$project$Boxing$isAbort = function (item) {
	var _v0 = item.props;
	if (_v0.$ === 'MapTopic') {
		var props = _v0.a;
		var _v1 = props.displayMode;
		if (_v1.$ === 'Container') {
			switch (_v1.a.$) {
				case 'BlackBox':
					var _v2 = _v1.a;
					return true;
				case 'WhiteBox':
					var _v3 = _v1.a;
					return true;
				default:
					var _v4 = _v1.a;
					return false;
			}
		} else {
			return false;
		}
	} else {
		return false;
	}
};
var $author$project$Boxing$setUnboxed = function (item) {
	return _Utils_update(
		item,
		{
			props: function () {
				var _v0 = item.props;
				if (_v0.$ === 'MapTopic') {
					var props = _v0.a;
					return $author$project$Model$MapTopic(
						_Utils_update(
							props,
							{
								displayMode: $author$project$Model$Container($author$project$Model$Unboxed)
							}));
				} else {
					var props = _v0.a;
					return $author$project$Model$MapAssoc(props);
				}
			}()
		});
};
var $author$project$Boxing$unboxTopic = F3(
	function (containerItem, targetItems, model) {
		var assocToInsert = A2($author$project$Boxing$targetAssocItem, containerItem.parentAssocId, targetItems);
		var _v0 = function () {
			var _v1 = A2($elm$core$Dict$get, containerItem.id, targetItems);
			if (_v1.$ === 'Just') {
				var item = _v1.a;
				var _v2 = A2(
					$author$project$Utils$info,
					'unboxTopic',
					_Utils_update(
						item,
						{hidden: false, pinned: !item.hidden}));
				return _Utils_Tuple2(
					_Utils_update(
						item,
						{hidden: false, pinned: !item.hidden}),
					$author$project$Boxing$isAbort(item));
			} else {
				return A2($author$project$ModelAPI$hasMap, containerItem.id, model.maps) ? _Utils_Tuple2(
					$author$project$Boxing$setUnboxed(containerItem),
					false) : _Utils_Tuple2(containerItem, false);
			}
		}();
		var topicToInsert = _v0.a;
		var abort = _v0.b;
		return _Utils_Tuple2(
			A3(
				$elm$core$Dict$insert,
				assocToInsert.id,
				assocToInsert,
				A3($elm$core$Dict$insert, topicToInsert.id, topicToInsert, targetItems)),
			abort);
	});
var $author$project$Boxing$unboxItems = F3(
	function (containerItems, targetItems, model) {
		return A3(
			$elm$core$List$foldr,
			F2(
				function (containerItem, targetItemsAcc) {
					var _v0 = containerItem.props;
					if (_v0.$ === 'MapTopic') {
						var _v1 = A3($author$project$Boxing$unboxTopic, containerItem, targetItemsAcc, model);
						var items = _v1.a;
						var abort = _v1.b;
						if (abort) {
							return items;
						} else {
							var _v2 = A2($author$project$ModelAPI$getMapIfExists, containerItem.id, model.maps);
							if (_v2.$ === 'Just') {
								var map = _v2.a;
								return A3($author$project$Boxing$unboxItems, map.items, items, model);
							} else {
								return items;
							}
						}
					} else {
						return A2($author$project$Boxing$unboxAssoc, containerItem, targetItemsAcc);
					}
				}),
			targetItems,
			A2(
				$elm$core$List$filter,
				$author$project$ModelAPI$isVisible,
				$elm$core$Dict$values(containerItems)));
	});
var $author$project$Boxing$unboxContainer = F3(
	function (containerId, targetMapId, model) {
		var _v0 = A3($author$project$ModelAPI$getDisplayMode, containerId, targetMapId, model.maps);
		_v0$2:
		while (true) {
			if ((_v0.$ === 'Just') && (_v0.a.$ === 'Container')) {
				switch (_v0.a.a.$) {
					case 'BlackBox':
						var _v1 = _v0.a.a;
						return A4($author$project$Boxing$transferContent, containerId, targetMapId, $author$project$Boxing$unboxItems, model);
					case 'WhiteBox':
						var _v2 = _v0.a.a;
						return A4($author$project$Boxing$transferContent, containerId, targetMapId, $author$project$Boxing$unboxItems, model);
					default:
						break _v0$2;
				}
			} else {
				break _v0$2;
			}
		}
		return model.maps;
	});
var $author$project$Main$switchDisplay = F2(
	function (displayMode, model) {
		return $author$project$MapAutoSize$autoSize(
			function () {
				var _v0 = $author$project$ModelAPI$getSingleSelection(model);
				if (_v0.$ === 'Just') {
					var _v1 = _v0.a;
					var containerId = _v1.a;
					var mapPath = _v1.b;
					var mapId = $author$project$ModelAPI$getMapId(mapPath);
					return A4(
						$author$project$ModelAPI$setDisplayMode,
						containerId,
						mapId,
						displayMode,
						_Utils_update(
							model,
							{
								maps: function () {
									if (displayMode.$ === 'Monad') {
										return model.maps;
									} else {
										switch (displayMode.a.$) {
											case 'BlackBox':
												var _v3 = displayMode.a;
												return A3($author$project$Boxing$boxContainer, containerId, mapId, model);
											case 'WhiteBox':
												var _v4 = displayMode.a;
												return A3($author$project$Boxing$boxContainer, containerId, mapId, model);
											default:
												var _v5 = displayMode.a;
												return A3($author$project$Boxing$unboxContainer, containerId, mapId, model);
										}
									}
								}()
							}));
				} else {
					return model;
				}
			}());
	});
var $author$project$Config$topicDefaultText = 'New Topic';
var $author$project$Main$trace = F2(
	function (tag, result) {
		var m = result.a;
		var cmd = result.b;
		var _v0 = A2($author$project$Logger$log, 'update.' + tag, '');
		return result;
	});
var $author$project$Main$traceWith = F3(
	function (tag, payload, result) {
		var m = result.a;
		var cmd = result.b;
		var _v0 = A2(
			$author$project$Logger$log,
			'update.' + (tag + ((payload === '') ? '' : (' | ' + payload))),
			'');
		return result;
	});
var $author$project$Main$endEdit = function (model) {
	return $author$project$MapAutoSize$autoSize(
		_Utils_update(
			model,
			{editState: $author$project$Model$NoEdit}));
};
var $author$project$ModelAPI$updateTopicInfo = F3(
	function (topicId, topicFunc, model) {
		return _Utils_update(
			model,
			{
				items: A3(
					$elm$core$Dict$update,
					topicId,
					function (maybeItem) {
						if (maybeItem.$ === 'Just') {
							var item = maybeItem.a;
							var _v1 = item.info;
							if (_v1.$ === 'Topic') {
								var topic = _v1.a;
								return $elm$core$Maybe$Just(
									_Utils_update(
										item,
										{
											info: $author$project$Model$Topic(
												topicFunc(topic))
										}));
							} else {
								return A3($author$project$ModelAPI$topicMismatch, 'updateTopicInfo', topicId, $elm$core$Maybe$Nothing);
							}
						} else {
							return A3($author$project$ModelAPI$illegalItemId, 'updateTopicInfo', topicId, $elm$core$Maybe$Nothing);
						}
					},
					model.items)
			});
	});
var $author$project$Main$onTextInput = F2(
	function (text, model) {
		var _v0 = model.editState;
		if (_v0.$ === 'ItemEdit') {
			var topicId = _v0.a;
			return A3(
				$author$project$ModelAPI$updateTopicInfo,
				topicId,
				function (topic) {
					return _Utils_update(
						topic,
						{text: text});
				},
				model);
		} else {
			return A3($author$project$Utils$logError, 'onTextInput', 'called when editState is NoEdit', model);
		}
	});
var $author$project$AppModel$Edit = function (a) {
	return {$: 'Edit', a: a};
};
var $author$project$AppModel$NoOp = {$: 'NoOp'};
var $author$project$Model$SetTopicSize = F3(
	function (a, b, c) {
		return {$: 'SetTopicSize', a: a, b: b, c: c};
	});
var $elm$core$Task$onError = _Scheduler_onError;
var $elm$core$Task$attempt = F2(
	function (resultToMessage, task) {
		return $elm$core$Task$command(
			$elm$core$Task$Perform(
				A2(
					$elm$core$Task$onError,
					A2(
						$elm$core$Basics$composeL,
						A2($elm$core$Basics$composeL, $elm$core$Task$succeed, resultToMessage),
						$elm$core$Result$Err),
					A2(
						$elm$core$Task$andThen,
						A2(
							$elm$core$Basics$composeL,
							A2($elm$core$Basics$composeL, $elm$core$Task$succeed, resultToMessage),
							$elm$core$Result$Ok),
						task))));
	});
var $elm$browser$Browser$Dom$getElement = _Browser_getElement;
var $author$project$Main$measureText = F4(
	function (text, topicId, mapId, model) {
		return _Utils_Tuple2(
			_Utils_update(
				model,
				{measureText: text}),
			A2(
				$elm$core$Task$attempt,
				function (result) {
					if (result.$ === 'Ok') {
						var elem = result.a;
						return $author$project$AppModel$Edit(
							A3(
								$author$project$Model$SetTopicSize,
								topicId,
								mapId,
								A2($author$project$Model$Size, elem.element.width, elem.element.height)));
					} else {
						var err = result.a;
						return A3(
							$author$project$Utils$logError,
							'measureText',
							$author$project$Utils$toString(err),
							$author$project$AppModel$NoOp);
					}
				},
				$elm$browser$Browser$Dom$getElement('measure')));
	});
var $author$project$Main$onTextareaInput = F2(
	function (text, model) {
		var _v0 = model.editState;
		if (_v0.$ === 'ItemEdit') {
			var topicId = _v0.a;
			var mapId = _v0.b;
			return A4(
				$author$project$Main$measureText,
				text,
				topicId,
				mapId,
				A3(
					$author$project$ModelAPI$updateTopicInfo,
					topicId,
					function (topic) {
						return _Utils_update(
							topic,
							{text: text});
					},
					model));
		} else {
			return A3(
				$author$project$Utils$logError,
				'onTextareaInput',
				'called when editState is NoEdit',
				_Utils_Tuple2(model, $elm$core$Platform$Cmd$none));
		}
	});
var $author$project$ModelAPI$setTopicSize = F4(
	function (topicId, mapId, size, model) {
		return A4(
			$author$project$ModelAPI$updateTopicProps,
			topicId,
			mapId,
			function (props) {
				return _Utils_update(
					props,
					{size: size});
			},
			model);
	});
var $elm$browser$Browser$Dom$focus = _Browser_call('focus');
var $author$project$Main$focus = function (model) {
	var nodeId = function () {
		var _v1 = model.editState;
		if (_v1.$ === 'ItemEdit') {
			var id = _v1.a;
			var mapId = _v1.b;
			return 'dmx-input-' + ($elm$core$String$fromInt(id) + ('-' + $elm$core$String$fromInt(mapId)));
		} else {
			return A3($author$project$Utils$logError, 'focus', 'called when editState is NoEdit', '');
		}
	}();
	return A2(
		$elm$core$Task$attempt,
		function (result) {
			if (result.$ === 'Ok') {
				return $author$project$AppModel$NoOp;
			} else {
				var e = result.a;
				return A3(
					$author$project$Utils$logError,
					'focus',
					$author$project$Utils$toString(e),
					$author$project$AppModel$NoOp);
			}
		},
		$elm$browser$Browser$Dom$focus(nodeId));
};
var $author$project$Main$setDetailDisplayIfMonade = F3(
	function (topicId, mapId, model) {
		return A4(
			$author$project$ModelAPI$updateTopicProps,
			topicId,
			mapId,
			function (props) {
				var _v0 = props.displayMode;
				if (_v0.$ === 'Monad') {
					return _Utils_update(
						props,
						{
							displayMode: $author$project$Model$Monad($author$project$Model$Detail)
						});
				} else {
					return props;
				}
			},
			model);
	});
var $author$project$Main$startEdit = function (model) {
	var newModel = function () {
		var _v0 = $author$project$ModelAPI$getSingleSelection(model);
		if (_v0.$ === 'Just') {
			var _v1 = _v0.a;
			var topicId = _v1.a;
			var mapPath = _v1.b;
			return $author$project$MapAutoSize$autoSize(
				A3(
					$author$project$Main$setDetailDisplayIfMonade,
					topicId,
					$author$project$ModelAPI$getMapId(mapPath),
					_Utils_update(
						model,
						{
							editState: A2(
								$author$project$Model$ItemEdit,
								topicId,
								$author$project$ModelAPI$getMapId(mapPath))
						})));
		} else {
			return model;
		}
	}();
	return _Utils_Tuple2(
		newModel,
		$author$project$Main$focus(newModel));
};
var $author$project$Storage$storeModelWith = function (_v0) {
	var model = _v0.a;
	var cmd = _v0.b;
	return _Utils_Tuple2(
		model,
		$elm$core$Platform$Cmd$batch(
			_List_fromArray(
				[
					cmd,
					$author$project$Storage$store(
					$author$project$Storage$encodeModel(model))
				])));
};
var $author$project$Main$updateEdit = F2(
	function (msg, model) {
		switch (msg.$) {
			case 'EditStart':
				return $author$project$Main$startEdit(model);
			case 'OnTextInput':
				var text = msg.a;
				return $author$project$Storage$storeModel(
					A2($author$project$Main$onTextInput, text, model));
			case 'OnTextareaInput':
				var text = msg.a;
				return $author$project$Storage$storeModelWith(
					A2($author$project$Main$onTextareaInput, text, model));
			case 'SetTopicSize':
				var topicId = msg.a;
				var mapId = msg.b;
				var size = msg.c;
				return _Utils_Tuple2(
					$author$project$MapAutoSize$autoSize(
						A4($author$project$ModelAPI$setTopicSize, topicId, mapId, size, model)),
					$elm$core$Platform$Cmd$none);
			default:
				return _Utils_Tuple2(
					$author$project$Main$endEdit(model),
					$elm$core$Platform$Cmd$none);
		}
	});
var $author$project$IconMenuAPI$closeIconMenu = function (model) {
	var m = model.iconMenu;
	return _Utils_update(
		model,
		{
			iconMenu: _Utils_update(
				m,
				{open: false})
		});
};
var $author$project$IconMenuAPI$openIconMenu = function (model) {
	var m = model.iconMenu;
	return _Utils_update(
		model,
		{
			iconMenu: _Utils_update(
				m,
				{open: true})
		});
};
var $author$project$IconMenuAPI$setIcon = F2(
	function (maybeIcon, model) {
		var m = model.iconMenu;
		return _Utils_update(
			model,
			{
				iconMenu: _Utils_update(
					m,
					{open: false})
			});
	});
var $author$project$IconMenuAPI$updateIconMenu = F2(
	function (msg, model) {
		switch (msg.$) {
			case 'Open':
				return _Utils_Tuple2(
					$author$project$IconMenuAPI$openIconMenu(model),
					$elm$core$Platform$Cmd$none);
			case 'Close':
				return _Utils_Tuple2(
					$author$project$IconMenuAPI$closeIconMenu(model),
					$elm$core$Platform$Cmd$none);
			case 'SetIcon':
				var maybeIcon = msg.a;
				return _Utils_Tuple2(
					A2($author$project$IconMenuAPI$setIcon, maybeIcon, model),
					$elm$core$Platform$Cmd$none);
			case 'OpenAt':
				return _Utils_Tuple2(
					$author$project$IconMenuAPI$openIconMenu(model),
					$elm$core$Platform$Cmd$none);
			case 'Hover':
				return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
			case 'Pick':
				return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
			case 'Picked':
				var action = msg.a;
				return _Utils_Tuple2(
					$author$project$IconMenuAPI$closeIconMenu(model),
					$elm$core$Platform$Cmd$none);
			case 'OutsideClick':
				return _Utils_Tuple2(
					$author$project$IconMenuAPI$closeIconMenu(model),
					$elm$core$Platform$Cmd$none);
			case 'KeyDown':
				var key = msg.a;
				return (key === 'Escape') ? _Utils_Tuple2(
					$author$project$IconMenuAPI$closeIconMenu(model),
					$elm$core$Platform$Cmd$none) : _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
			default:
				return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
		}
	});
var $author$project$SearchAPI$closeResultMenu = function (model) {
	var search = model.search;
	return _Utils_update(
		model,
		{
			search: _Utils_update(
				search,
				{menu: $author$project$Search$Closed})
		});
};
var $author$project$MouseAPI$mouseDown = function (model) {
	return $author$project$SearchAPI$closeResultMenu(
		$author$project$IconMenuAPI$closeIconMenu(
			_Utils_update(
				model,
				{selection: _List_Nil})));
};
var $author$project$Mouse$WaitForStartTime = F4(
	function (a, b, c, d) {
		return {$: 'WaitForStartTime', a: a, b: b, c: c, d: d};
	});
var $author$project$MouseAPI$updateDragState = F2(
	function (model, dragState) {
		var mouse = model.mouse;
		return _Utils_update(
			model,
			{
				mouse: _Utils_update(
					mouse,
					{dragState: dragState})
			});
	});
var $author$project$MouseAPI$mouseDownOnItem = F5(
	function (model, cls, id, mapPath, pos) {
		var _v0 = A2(
			$author$project$Logger$log,
			'DownItem',
			{cls: cls, id: id, mapPath: mapPath, pos: pos});
		return _Utils_Tuple2(
			A3(
				$author$project$ModelAPI$select,
				id,
				mapPath,
				A2(
					$author$project$MouseAPI$updateDragState,
					model,
					A4($author$project$Mouse$WaitForStartTime, cls, id, mapPath, pos))),
			A2(
				$elm$core$Task$perform,
				A2($elm$core$Basics$composeL, $author$project$AppModel$Mouse, $author$project$Mouse$Time),
				$elm$time$Time$now));
	});
var $author$project$Mouse$WaitForEndTime = F5(
	function (a, b, c, d, e) {
		return {$: 'WaitForEndTime', a: a, b: b, c: c, d: d, e: e};
	});
var $author$project$Mouse$Drag = F6(
	function (a, b, c, d, e, f) {
		return {$: 'Drag', a: a, b: b, c: c, d: d, e: e, f: f};
	});
var $author$project$MouseAPI$performDrag = F2(
	function (model, pos) {
		var _v0 = A2(
			$author$project$Logger$log,
			'performDrag',
			{dragState: model.mouse.dragState, pos: pos});
		var _v1 = model.mouse.dragState;
		if (_v1.$ === 'Drag') {
			var dragMode = _v1.a;
			var id = _v1.b;
			var mapPath = _v1.c;
			var origPos = _v1.d;
			var lastPos = _v1.e;
			var target = _v1.f;
			var mapId = $author$project$ModelAPI$getMapId(mapPath);
			var delta = A2($author$project$Model$Point, pos.x - lastPos.x, pos.y - lastPos.y);
			var nextModel = function () {
				if (dragMode.$ === 'DragTopic') {
					return A4($author$project$ModelAPI$setTopicPosByDelta, id, mapId, delta, model);
				} else {
					return model;
				}
			}();
			return $author$project$MapAutoSize$autoSize(
				A2(
					$author$project$MouseAPI$updateDragState,
					nextModel,
					A6($author$project$Mouse$Drag, dragMode, id, mapPath, origPos, pos, target)));
		} else {
			return A3($author$project$Utils$logError, 'performDrag', 'Received \"Move\" when dragState is not Drag', model);
		}
	});
var $author$project$MouseAPI$mouseMove = F2(
	function (model, pos) {
		var _v0 = A2(
			$author$project$Logger$log,
			'Move',
			{dragState: model.mouse.dragState, pos: pos});
		var _v1 = model.mouse.dragState;
		switch (_v1.$) {
			case 'DragEngaged':
				var time = _v1.a;
				var _class = _v1.b;
				var id = _v1.c;
				var mapPath = _v1.d;
				var pos_ = _v1.e;
				return _Utils_Tuple2(
					A2(
						$author$project$MouseAPI$updateDragState,
						model,
						A5($author$project$Mouse$WaitForEndTime, time, _class, id, mapPath, pos_)),
					A2(
						$elm$core$Task$perform,
						A2($elm$core$Basics$composeL, $author$project$AppModel$Mouse, $author$project$Mouse$Time),
						$elm$time$Time$now));
			case 'WaitForEndTime':
				return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
			case 'Drag':
				return _Utils_Tuple2(
					A2($author$project$MouseAPI$performDrag, model, pos),
					$elm$core$Platform$Cmd$none);
			default:
				return A3(
					$author$project$Utils$logError,
					'mouseMove',
					'Received \"Move\" when dragState is not engaged/drag',
					_Utils_Tuple2(model, $elm$core$Platform$Cmd$none));
		}
	});
var $author$project$MouseAPI$mouseOut = F4(
	function (model, _v0, _v1, _v2) {
		var _v3 = model.mouse.dragState;
		if (_v3.$ === 'Drag') {
			var dragMode = _v3.a;
			var id = _v3.b;
			var mapPath = _v3.c;
			var origPos = _v3.d;
			var lastPos = _v3.e;
			return A2(
				$author$project$MouseAPI$updateDragState,
				model,
				A6($author$project$Mouse$Drag, dragMode, id, mapPath, origPos, lastPos, $elm$core$Maybe$Nothing));
		} else {
			return model;
		}
	});
var $elm$core$Basics$neq = _Utils_notEqual;
var $author$project$MouseAPI$mouseOver = F4(
	function (model, _v0, targetId, targetMapPath) {
		var _v1 = model.mouse.dragState;
		switch (_v1.$) {
			case 'Drag':
				var dragMode = _v1.a;
				var id = _v1.b;
				var mapPath = _v1.c;
				var origPos = _v1.d;
				var lastPos = _v1.e;
				var targetMapId = $author$project$ModelAPI$getMapId(targetMapPath);
				var mapId = $author$project$ModelAPI$getMapId(mapPath);
				var target = (!_Utils_eq(
					_Utils_Tuple2(id, mapId),
					_Utils_Tuple2(targetId, targetMapId))) ? $elm$core$Maybe$Just(
					_Utils_Tuple2(targetId, targetMapPath)) : $elm$core$Maybe$Nothing;
				return A2(
					$author$project$MouseAPI$updateDragState,
					model,
					A6($author$project$Mouse$Drag, dragMode, id, mapPath, origPos, lastPos, target));
			case 'DragEngaged':
				return A3($author$project$Utils$logError, 'mouseOver', 'Received \"Over\" message when dragState is DragEngaged', model);
			default:
				return model;
		}
	});
var $author$project$AppModel$MoveTopicToMap = F6(
	function (a, b, c, d, e, f) {
		return {$: 'MoveTopicToMap', a: a, b: b, c: c, d: d, e: e, f: f};
	});
var $author$project$ModelAPI$createAssocIn = F7(
	function (itemType, role1, player1, role2, player2, mapId, model) {
		var props = $author$project$Model$MapAssoc($author$project$Model$AssocProps);
		var _v0 = A6($author$project$ModelAPI$createAssoc, itemType, role1, player1, role2, player2, model);
		var newModel = _v0.a;
		var assocId = _v0.b;
		return A4($author$project$ModelAPI$addItemToMap, assocId, props, mapId, newModel);
	});
var $author$project$ModelAPI$createDefaultAssocIn = F4(
	function (player1, player2, mapId, model) {
		return A7($author$project$ModelAPI$createAssocIn, 'dmx.association', 'dmx.default', player1, 'dmx.default', player2, mapId, model);
	});
var $author$project$ModelAPI$fromPath = function (mapPath) {
	return A2(
		$elm$core$String$join,
		',',
		A2($elm$core$List$map, $elm$core$String$fromInt, mapPath));
};
var $elm$random$Random$Generate = function (a) {
	return {$: 'Generate', a: a};
};
var $elm$random$Random$Seed = F2(
	function (a, b) {
		return {$: 'Seed', a: a, b: b};
	});
var $elm$core$Bitwise$shiftRightZfBy = _Bitwise_shiftRightZfBy;
var $elm$random$Random$next = function (_v0) {
	var state0 = _v0.a;
	var incr = _v0.b;
	return A2($elm$random$Random$Seed, ((state0 * 1664525) + incr) >>> 0, incr);
};
var $elm$random$Random$initialSeed = function (x) {
	var _v0 = $elm$random$Random$next(
		A2($elm$random$Random$Seed, 0, 1013904223));
	var state1 = _v0.a;
	var incr = _v0.b;
	var state2 = (state1 + x) >>> 0;
	return $elm$random$Random$next(
		A2($elm$random$Random$Seed, state2, incr));
};
var $elm$time$Time$posixToMillis = function (_v0) {
	var millis = _v0.a;
	return millis;
};
var $elm$random$Random$init = A2(
	$elm$core$Task$andThen,
	function (time) {
		return $elm$core$Task$succeed(
			$elm$random$Random$initialSeed(
				$elm$time$Time$posixToMillis(time)));
	},
	$elm$time$Time$now);
var $elm$random$Random$step = F2(
	function (_v0, seed) {
		var generator = _v0.a;
		return generator(seed);
	});
var $elm$random$Random$onEffects = F3(
	function (router, commands, seed) {
		if (!commands.b) {
			return $elm$core$Task$succeed(seed);
		} else {
			var generator = commands.a.a;
			var rest = commands.b;
			var _v1 = A2($elm$random$Random$step, generator, seed);
			var value = _v1.a;
			var newSeed = _v1.b;
			return A2(
				$elm$core$Task$andThen,
				function (_v2) {
					return A3($elm$random$Random$onEffects, router, rest, newSeed);
				},
				A2($elm$core$Platform$sendToApp, router, value));
		}
	});
var $elm$random$Random$onSelfMsg = F3(
	function (_v0, _v1, seed) {
		return $elm$core$Task$succeed(seed);
	});
var $elm$random$Random$Generator = function (a) {
	return {$: 'Generator', a: a};
};
var $elm$random$Random$map = F2(
	function (func, _v0) {
		var genA = _v0.a;
		return $elm$random$Random$Generator(
			function (seed0) {
				var _v1 = genA(seed0);
				var a = _v1.a;
				var seed1 = _v1.b;
				return _Utils_Tuple2(
					func(a),
					seed1);
			});
	});
var $elm$random$Random$cmdMap = F2(
	function (func, _v0) {
		var generator = _v0.a;
		return $elm$random$Random$Generate(
			A2($elm$random$Random$map, func, generator));
	});
_Platform_effectManagers['Random'] = _Platform_createManager($elm$random$Random$init, $elm$random$Random$onEffects, $elm$random$Random$onSelfMsg, $elm$random$Random$cmdMap);
var $elm$random$Random$command = _Platform_leaf('Random');
var $elm$random$Random$generate = F2(
	function (tagger, generator) {
		return $elm$random$Random$command(
			$elm$random$Random$Generate(
				A2($elm$random$Random$map, tagger, generator)));
	});
var $elm$core$Basics$abs = function (n) {
	return (n < 0) ? (-n) : n;
};
var $elm$core$Bitwise$and = _Bitwise_and;
var $elm$core$Bitwise$xor = _Bitwise_xor;
var $elm$random$Random$peel = function (_v0) {
	var state = _v0.a;
	var word = (state ^ (state >>> ((state >>> 28) + 4))) * 277803737;
	return ((word >>> 22) ^ word) >>> 0;
};
var $elm$random$Random$float = F2(
	function (a, b) {
		return $elm$random$Random$Generator(
			function (seed0) {
				var seed1 = $elm$random$Random$next(seed0);
				var range = $elm$core$Basics$abs(b - a);
				var n1 = $elm$random$Random$peel(seed1);
				var n0 = $elm$random$Random$peel(seed0);
				var lo = (134217727 & n1) * 1.0;
				var hi = (67108863 & n0) * 1.0;
				var val = ((hi * 134217728.0) + lo) / 9007199254740992.0;
				var scaled = (val * range) + a;
				return _Utils_Tuple2(
					scaled,
					$elm$random$Random$next(seed1));
			});
	});
var $elm$random$Random$map2 = F3(
	function (func, _v0, _v1) {
		var genA = _v0.a;
		var genB = _v1.a;
		return $elm$random$Random$Generator(
			function (seed0) {
				var _v2 = genA(seed0);
				var a = _v2.a;
				var seed1 = _v2.b;
				var _v3 = genB(seed1);
				var b = _v3.a;
				var seed2 = _v3.b;
				return _Utils_Tuple2(
					A2(func, a, b),
					seed2);
			});
	});
var $author$project$Config$whiteBoxRange = A2($author$project$Model$Size, 250, 150);
var $author$project$MouseAPI$point = function () {
	var rw = $author$project$Config$whiteBoxRange.w;
	var rh = $author$project$Config$whiteBoxRange.h;
	var cy = $author$project$Config$topicH2 + $author$project$Config$whiteBoxPadding;
	var cx = $author$project$Config$topicW2 + $author$project$Config$whiteBoxPadding;
	return A3(
		$elm$random$Random$map2,
		F2(
			function (x, y) {
				return A2($author$project$Model$Point, cx + x, cy + y);
			}),
		A2($elm$random$Random$float, 0, rw),
		A2($elm$random$Random$float, 0, rh));
}();
var $author$project$MouseAPI$mouseUp = function (model) {
	var _v0 = function () {
		var _v1 = model.mouse.dragState;
		_v1$2:
		while (true) {
			switch (_v1.$) {
				case 'Drag':
					if (_v1.a.$ === 'DragTopic') {
						if (_v1.f.$ === 'Just') {
							var _v2 = _v1.a;
							var id = _v1.b;
							var mapPath = _v1.c;
							var origPos = _v1.d;
							var _v3 = _v1.f.a;
							var targetId = _v3.a;
							var targetMapPath = _v3.b;
							var mapId = $author$project$ModelAPI$getMapId(mapPath);
							var msg = A5($author$project$AppModel$MoveTopicToMap, id, mapId, origPos, targetId, targetMapPath);
							var notDroppedOnOwnMap = !_Utils_eq(mapId, targetId);
							var _v4 = A2(
								$author$project$Logger$log,
								'mouseUp',
								'dropped ' + ($elm$core$String$fromInt(id) + (' (map ' + ($author$project$ModelAPI$fromPath(mapPath) + (') on ' + ($elm$core$String$fromInt(targetId) + (' (map ' + ($author$project$ModelAPI$fromPath(targetMapPath) + (') --> ' + (notDroppedOnOwnMap ? 'move topic' : 'abort'))))))))));
							return notDroppedOnOwnMap ? _Utils_Tuple2(
								model,
								A2($elm$random$Random$generate, msg, $author$project$MouseAPI$point)) : _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
						} else {
							break _v1$2;
						}
					} else {
						if (_v1.f.$ === 'Just') {
							var _v5 = _v1.a;
							var id = _v1.b;
							var mapPath = _v1.c;
							var _v6 = _v1.f.a;
							var targetId = _v6.a;
							var targetMapPath = _v6.b;
							var mapId = $author$project$ModelAPI$getMapId(mapPath);
							var isSameMap = _Utils_eq(
								mapId,
								$author$project$ModelAPI$getMapId(targetMapPath));
							var _v7 = A2(
								$author$project$Logger$log,
								'mouseUp',
								'assoc drawn from ' + ($elm$core$String$fromInt(id) + (' (map ' + ($author$project$ModelAPI$fromPath(mapPath) + (') to ' + ($elm$core$String$fromInt(targetId) + (' (map ' + ($author$project$ModelAPI$fromPath(targetMapPath) + (') --> ' + (isSameMap ? 'create assoc' : 'abort'))))))))));
							return isSameMap ? _Utils_Tuple2(
								A4($author$project$ModelAPI$createDefaultAssocIn, id, targetId, mapId, model),
								$elm$core$Platform$Cmd$none) : _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
						} else {
							break _v1$2;
						}
					}
				case 'DragEngaged':
					var _v9 = A2($author$project$Logger$log, 'mouseUp', 'drag aborted w/o moving');
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
				default:
					return A3(
						$author$project$Utils$logError,
						'mouseUp',
						'Received \"Up\" message when dragState is ' + $author$project$Utils$toString(model.mouse.dragState),
						_Utils_Tuple2(model, $elm$core$Platform$Cmd$none));
			}
		}
		var _v8 = A2($author$project$Logger$log, 'mouseUp', 'drag ended w/o target');
		return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
	}();
	var newModel = _v0.a;
	var cmd = _v0.b;
	return _Utils_Tuple2(
		A2($author$project$MouseAPI$updateDragState, newModel, $author$project$Mouse$NoDrag),
		cmd);
};
var $author$project$Mouse$DragEngaged = F5(
	function (a, b, c, d, e) {
		return {$: 'DragEngaged', a: a, b: b, c: c, d: d, e: e};
	});
var $author$project$Mouse$DragTopic = {$: 'DragTopic'};
var $author$project$Mouse$DrawAssoc = {$: 'DrawAssoc'};
var $author$project$Config$assocDelayMillis = 200;
var $author$project$ModelAPI$getTopicPos = F3(
	function (topicId, mapId, maps) {
		var _v0 = A3($author$project$ModelAPI$getTopicProps, topicId, mapId, maps);
		if (_v0.$ === 'Just') {
			var pos = _v0.a.pos;
			return $elm$core$Maybe$Just(pos);
		} else {
			return A3(
				$author$project$Utils$fail,
				'getTopicPos',
				{mapId: mapId, topicId: topicId},
				$elm$core$Maybe$Nothing);
		}
	});
var $author$project$MouseAPI$timeArrived = F2(
	function (time, model) {
		var _v0 = model.mouse.dragState;
		switch (_v0.$) {
			case 'WaitForStartTime':
				var _class = _v0.a;
				var id = _v0.b;
				var mapPath = _v0.c;
				var pos = _v0.d;
				var _v1 = A2(
					$author$project$Logger$log,
					'Time@WaitForStart',
					{cls: _class, id: id, mapPath: mapPath, pos: pos});
				return A2(
					$author$project$MouseAPI$updateDragState,
					model,
					A5($author$project$Mouse$DragEngaged, time, _class, id, mapPath, pos));
			case 'WaitForEndTime':
				var startTime = _v0.a;
				var _class = _v0.b;
				var id = _v0.c;
				var mapPath = _v0.d;
				var pos = _v0.e;
				var _v2 = A2(
					$author$project$Logger$log,
					'Time@WaitForEnd',
					{cls: _class, id: id, mapPath: mapPath, pos: pos});
				return A2(
					$author$project$MouseAPI$updateDragState,
					model,
					function () {
						if (_class === 'dmx-topic') {
							var mapId = $author$project$ModelAPI$getMapId(mapPath);
							var origPos_ = A3($author$project$ModelAPI$getTopicPos, id, mapId, model.maps);
							var delay = _Utils_cmp(
								$elm$time$Time$posixToMillis(time) - $elm$time$Time$posixToMillis(startTime),
								$author$project$Config$assocDelayMillis) > 0;
							var dragMode = delay ? $author$project$Mouse$DrawAssoc : $author$project$Mouse$DragTopic;
							if (origPos_.$ === 'Just') {
								var origPos = origPos_.a;
								return A6($author$project$Mouse$Drag, dragMode, id, mapPath, origPos, pos, $elm$core$Maybe$Nothing);
							} else {
								return $author$project$Mouse$NoDrag;
							}
						} else {
							return $author$project$Mouse$NoDrag;
						}
					}());
			default:
				return A3($author$project$Utils$logError, 'timeArrived', 'Received \"Time\" when dragState is not waiting', model);
		}
	});
var $author$project$MouseAPI$updateMouse = F2(
	function (msg, model) {
		var _v0 = A2($author$project$Logger$log, 'MouseMsg', msg);
		switch (msg.$) {
			case 'Down':
				return _Utils_Tuple2(
					$author$project$MouseAPI$mouseDown(model),
					$elm$core$Platform$Cmd$none);
			case 'DownItem':
				var _class = msg.a;
				var id = msg.b;
				var mapPath = msg.c;
				var pos = msg.d;
				return A5($author$project$MouseAPI$mouseDownOnItem, model, _class, id, mapPath, pos);
			case 'Move':
				var pos = msg.a;
				return A2($author$project$MouseAPI$mouseMove, model, pos);
			case 'Up':
				return $author$project$Storage$storeModelWith(
					$author$project$MouseAPI$mouseUp(model));
			case 'Over':
				var _class = msg.a;
				var id = msg.b;
				var mapPath = msg.c;
				return _Utils_Tuple2(
					A4($author$project$MouseAPI$mouseOver, model, _class, id, mapPath),
					$elm$core$Platform$Cmd$none);
			case 'Out':
				var _class = msg.a;
				var id = msg.b;
				var mapPath = msg.c;
				return _Utils_Tuple2(
					A4($author$project$MouseAPI$mouseOut, model, _class, id, mapPath),
					$elm$core$Platform$Cmd$none);
			default:
				var time = msg.a;
				return _Utils_Tuple2(
					A2($author$project$MouseAPI$timeArrived, time, model),
					$elm$core$Platform$Cmd$none);
		}
	});
var $author$project$Main$adjustMapRect = F3(
	function (mapId, factor, model) {
		return A3(
			$author$project$ModelAPI$updateMapRect,
			mapId,
			function (rect) {
				return A4($author$project$Model$Rectangle, rect.x1 + (factor * 400), rect.y1 + (factor * 300), rect.x2, rect.y2);
			},
			model);
	});
var $author$project$Main$back = function (model) {
	var _v0 = function () {
		var _v1 = model.mapPath;
		if (_v1.b && _v1.b.b) {
			var prevMapId = _v1.a;
			var _v2 = _v1.b;
			var nextMapId = _v2.a;
			var mapIds = _v2.b;
			return _Utils_Tuple3(
				prevMapId,
				A2($elm$core$List$cons, nextMapId, mapIds),
				_List_fromArray(
					[
						_Utils_Tuple2(prevMapId, nextMapId)
					]));
		} else {
			return A3(
				$author$project$Utils$logError,
				'back',
				'model.mapPath has a problem',
				_Utils_Tuple3(
					0,
					_List_fromArray(
						[0]),
					_List_Nil));
		}
	}();
	var mapId = _v0.a;
	var mapPath = _v0.b;
	var selection = _v0.c;
	return $author$project$MapAutoSize$autoSize(
		A3(
			$author$project$Main$adjustMapRect,
			mapId,
			1,
			_Utils_update(
				model,
				{mapPath: mapPath})));
};
var $author$project$Main$fullscreen = function (model) {
	var _v0 = $author$project$ModelAPI$getSingleSelection(model);
	if (_v0.$ === 'Just') {
		var _v1 = _v0.a;
		var topicId = _v1.a;
		return A3(
			$author$project$Main$adjustMapRect,
			topicId,
			-1,
			A2(
				$author$project$Main$createMapIfNeeded,
				topicId,
				_Utils_update(
					model,
					{
						mapPath: A2($elm$core$List$cons, topicId, model.mapPath),
						selection: _List_Nil
					})).a);
	} else {
		return model;
	}
};
var $author$project$Main$updateNav = F2(
	function (navMsg, model) {
		if (navMsg.$ === 'Fullscreen') {
			return $author$project$Main$fullscreen(model);
		} else {
			return $author$project$Main$back(model);
		}
	});
var $author$project$Search$Open = function (a) {
	return {$: 'Open', a: a};
};
var $author$project$SearchAPI$onFocusInput = function (model) {
	var search = model.search;
	return _Utils_update(
		model,
		{
			search: _Utils_update(
				search,
				{
					menu: $author$project$Search$Open($elm$core$Maybe$Nothing)
				})
		});
};
var $author$project$SearchAPI$onHoverItem = F2(
	function (topicId, model) {
		var search = model.search;
		var _v0 = model.search.menu;
		if (_v0.$ === 'Open') {
			return _Utils_update(
				model,
				{
					search: _Utils_update(
						search,
						{
							menu: $author$project$Search$Open(
								$elm$core$Maybe$Just(topicId))
						})
				});
		} else {
			return A3($author$project$Utils$logError, 'onHoverItem', 'Received \"HoverItem\" message when search.menu is Closed', model);
		}
	});
var $elm$core$String$toLower = _String_toLower;
var $author$project$SearchAPI$isMatch = F2(
	function (searchText, text) {
		return (!$elm$core$String$isEmpty(searchText)) && A2(
			$elm$core$String$contains,
			$elm$core$String$toLower(searchText),
			$elm$core$String$toLower(text));
	});
var $author$project$SearchAPI$searchTopics = function (model) {
	var search = model.search;
	return _Utils_update(
		model,
		{
			search: _Utils_update(
				search,
				{
					menu: $author$project$Search$Open($elm$core$Maybe$Nothing),
					result: A3(
						$elm$core$Dict$foldr,
						F3(
							function (id, item, topicIds) {
								var _v0 = item.info;
								if (_v0.$ === 'Topic') {
									var text = _v0.a.text;
									return A2($author$project$SearchAPI$isMatch, model.search.text, text) ? A2($elm$core$List$cons, id, topicIds) : topicIds;
								} else {
									return topicIds;
								}
							}),
						_List_Nil,
						model.items)
				})
		});
};
var $author$project$SearchAPI$onTextInput = F2(
	function (text, model) {
		var search = model.search;
		return $author$project$SearchAPI$searchTopics(
			_Utils_update(
				model,
				{
					search: _Utils_update(
						search,
						{text: text})
				}));
	});
var $author$project$SearchAPI$onUnhoverItem = function (model) {
	var search = model.search;
	var _v0 = model.search.menu;
	if (_v0.$ === 'Open') {
		return _Utils_update(
			model,
			{
				search: _Utils_update(
					search,
					{
						menu: $author$project$Search$Open($elm$core$Maybe$Nothing)
					})
			});
	} else {
		return A3($author$project$Utils$logError, 'onUnhoverItem', 'Received \"UnhoverItem\" message when search.menu is Closed', model);
	}
};
var $author$project$ModelAPI$defaultProps = F3(
	function (topicId, size, model) {
		return A3(
			$author$project$Model$TopicProps,
			A2($author$project$Model$Point, 0, 0),
			size,
			A2($author$project$ModelAPI$hasMap, topicId, model.maps) ? $author$project$Model$Container($author$project$Model$BlackBox) : $author$project$Model$Monad($author$project$Model$LabelOnly));
	});
var $author$project$ModelAPI$showItem = F3(
	function (itemId, mapId, model) {
		return _Utils_update(
			model,
			{
				maps: A3(
					$author$project$ModelAPI$updateMaps,
					mapId,
					function (map) {
						return _Utils_update(
							map,
							{
								items: A3(
									$elm$core$Dict$update,
									itemId,
									$elm$core$Maybe$map(
										function (mapItem) {
											return _Utils_update(
												mapItem,
												{hidden: false});
										}),
									map.items)
							});
					},
					model.maps)
			});
	});
var $author$project$SearchAPI$revealTopic = F3(
	function (topicId, mapId, model) {
		if (A3($author$project$ModelAPI$isItemInMap, topicId, mapId, model)) {
			var _v0 = A2(
				$author$project$Utils$info,
				'revealTopic',
				_Utils_Tuple2(topicId, 'set visible'));
			return A3($author$project$ModelAPI$showItem, topicId, mapId, model);
		} else {
			var props = $author$project$Model$MapTopic(
				A3($author$project$ModelAPI$defaultProps, topicId, $author$project$Config$topicSize, model));
			var _v1 = A2(
				$author$project$Utils$info,
				'revealTopic',
				_Utils_Tuple2(topicId, 'add to map'));
			return A4($author$project$Compat$ModelAPI$addItemToMap, topicId, props, mapId, model);
		}
	});
var $author$project$SearchAPI$updateSearch = F2(
	function (msg, model) {
		switch (msg.$) {
			case 'Input':
				var text = msg.a;
				return _Utils_Tuple2(
					A2($author$project$SearchAPI$onTextInput, text, model),
					$elm$core$Platform$Cmd$none);
			case 'FocusInput':
				return _Utils_Tuple2(
					$author$project$SearchAPI$onFocusInput(model),
					$elm$core$Platform$Cmd$none);
			case 'HoverItem':
				var topicId = msg.a;
				return _Utils_Tuple2(
					A2($author$project$SearchAPI$onHoverItem, topicId, model),
					$elm$core$Platform$Cmd$none);
			case 'UnhoverItem':
				return _Utils_Tuple2(
					$author$project$SearchAPI$onUnhoverItem(model),
					$elm$core$Platform$Cmd$none);
			default:
				var topicId = msg.a;
				return $author$project$Storage$storeModel(
					$author$project$SearchAPI$closeResultMenu(
						A3(
							$author$project$SearchAPI$revealTopic,
							topicId,
							$author$project$ModelAPI$activeMap(model),
							model)));
		}
	});
var $author$project$Main$update = F2(
	function (msg, model) {
		var _v0 = function () {
			if (msg.$ === 'Mouse') {
				return msg;
			} else {
				return A2($author$project$Logger$log, 'update', msg);
			}
		}();
		switch (msg.$) {
			case 'FedWikiPage':
				var raw = msg.a;
				return A3(
					$author$project$Main$traceWith,
					'fedwiki',
					'len=' + $elm$core$String$fromInt(
						$elm$core$String$length(raw)),
					_Utils_Tuple2(
						function (m) {
							return _Utils_update(
								m,
								{fedWikiRaw: raw});
						}(
							A2($author$project$FedWiki$renderAsMonad, raw, model)),
						$elm$core$Platform$Cmd$none));
			case 'AddTopic':
				return A2(
					$author$project$Main$trace,
					'addTopic',
					$author$project$Storage$storeModel(
						A4(
							$author$project$ModelAPI$createTopicIn,
							$author$project$Config$topicDefaultText,
							$elm$core$Maybe$Nothing,
							_List_fromArray(
								[
									$author$project$ModelAPI$activeMap(model)
								]),
							model)));
			case 'MoveTopicToMap':
				var topicId = msg.a;
				var mapId = msg.b;
				var origPos = msg.c;
				var targetId = msg.d;
				var targetMapPath = msg.e;
				var pos = msg.f;
				return A3(
					$author$project$Main$traceWith,
					'moveTopic',
					'topic=' + ($elm$core$String$fromInt(topicId) + (' -> ' + $elm$core$String$fromInt(targetId))),
					$author$project$Storage$storeModel(
						A7($author$project$Main$moveTopicToMap, topicId, mapId, origPos, targetId, targetMapPath, pos, model)));
			case 'SwitchDisplay':
				var displayMode = msg.a;
				return A3(
					$author$project$Main$traceWith,
					'switchDisplay',
					$author$project$Main$describeDisplayMode(displayMode),
					$author$project$Storage$storeModel(
						A2($author$project$Main$switchDisplay, displayMode, model)));
			case 'Search':
				var searchMsg = msg.a;
				return A2(
					$author$project$Main$trace,
					'search',
					A2($author$project$SearchAPI$updateSearch, searchMsg, model));
			case 'Edit':
				var editMsg = msg.a;
				return A2(
					$author$project$Main$trace,
					'edit',
					A2($author$project$Main$updateEdit, editMsg, model));
			case 'IconMenu':
				var iconMenuMsg = msg.a;
				return A2(
					$author$project$Main$trace,
					'iconMenu',
					A2($author$project$IconMenuAPI$updateIconMenu, iconMenuMsg, model));
			case 'Mouse':
				var mouseMsg = msg.a;
				return A2(
					$author$project$Main$trace,
					'mouse',
					A2($author$project$MouseAPI$updateMouse, mouseMsg, model));
			case 'Nav':
				var navMsg = msg.a;
				return A2(
					$author$project$Main$trace,
					'nav',
					$author$project$Storage$storeModel(
						A2($author$project$Main$updateNav, navMsg, model)));
			case 'Hide':
				return A2(
					$author$project$Main$trace,
					'hide',
					$author$project$Storage$storeModel(
						$author$project$Main$hide(model)));
			case 'Delete':
				return A2(
					$author$project$Main$trace,
					'delete',
					$author$project$Storage$storeModel(
						$author$project$Main$delete(model)));
			default:
				return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
		}
	});
var $elm$json$Json$Decode$value = _Json_decodeValue;
var $elm$browser$Browser$Document = F2(
	function (title, body) {
		return {body: body, title: title};
	});
var $author$project$Config$mainFont = 'sans-serif';
var $elm$virtual_dom$VirtualDom$style = _VirtualDom_style;
var $elm$html$Html$Attributes$style = $elm$virtual_dom$VirtualDom$style;
var $author$project$Main$appStyle = _List_fromArray(
	[
		A2($elm$html$Html$Attributes$style, 'font-family', $author$project$Config$mainFont),
		A2($elm$html$Html$Attributes$style, 'user-select', 'none'),
		A2($elm$html$Html$Attributes$style, '-webkit-user-select', 'none')
	]);
var $elm$html$Html$br = _VirtualDom_node('br');
var $elm$html$Html$div = _VirtualDom_node('div');
var $elm$html$Html$Attributes$stringProperty = F2(
	function (key, string) {
		return A2(
			_VirtualDom_property,
			key,
			$elm$json$Json$Encode$string(string));
	});
var $elm$html$Html$Attributes$id = $elm$html$Html$Attributes$stringProperty('id');
var $elm$core$String$fromFloat = _String_fromNumber;
var $author$project$Main$measureStyle = _List_fromArray(
	[
		A2($elm$html$Html$Attributes$style, 'position', 'fixed'),
		A2($elm$html$Html$Attributes$style, 'visibility', 'hidden'),
		A2($elm$html$Html$Attributes$style, 'white-space', 'pre-wrap'),
		A2($elm$html$Html$Attributes$style, 'font-family', $author$project$Config$mainFont),
		A2(
		$elm$html$Html$Attributes$style,
		'font-size',
		$elm$core$String$fromInt($author$project$Config$contentFontSize) + 'px'),
		A2(
		$elm$html$Html$Attributes$style,
		'line-height',
		$elm$core$String$fromFloat($author$project$Config$topicLineHeight)),
		A2(
		$elm$html$Html$Attributes$style,
		'padding',
		$elm$core$String$fromInt($author$project$Config$topicDetailPadding) + 'px'),
		A2(
		$elm$html$Html$Attributes$style,
		'width',
		$elm$core$String$fromFloat($author$project$Config$topicDetailMaxWidth) + 'px'),
		A2(
		$elm$html$Html$Attributes$style,
		'min-width',
		$elm$core$String$fromFloat($author$project$Config$topicSize.w - $author$project$Config$topicSize.h) + 'px'),
		A2($elm$html$Html$Attributes$style, 'max-width', 'max-content'),
		A2(
		$elm$html$Html$Attributes$style,
		'border-width',
		$elm$core$String$fromFloat($author$project$Config$topicBorderWidth) + 'px'),
		A2($elm$html$Html$Attributes$style, 'border-style', 'solid'),
		A2($elm$html$Html$Attributes$style, 'box-sizing', 'border-box')
	]);
var $author$project$Mouse$Out = F3(
	function (a, b, c) {
		return {$: 'Out', a: a, b: b, c: c};
	});
var $author$project$Mouse$Over = F3(
	function (a, b, c) {
		return {$: 'Over', a: a, b: b, c: c};
	});
var $author$project$MouseAPI$mouseDecoder = function (msg) {
	return A2(
		$elm$json$Json$Decode$map,
		$author$project$AppModel$Mouse,
		A4(
			$elm$json$Json$Decode$map3,
			msg,
			$elm$json$Json$Decode$oneOf(
				_List_fromArray(
					[
						A2(
						$elm$json$Json$Decode$at,
						_List_fromArray(
							['target', 'className']),
						$elm$json$Json$Decode$string),
						A2(
						$elm$json$Json$Decode$at,
						_List_fromArray(
							['target', 'className', 'baseVal']),
						$elm$json$Json$Decode$string)
					])),
			A2(
				$elm$json$Json$Decode$andThen,
				$author$project$ModelAPI$idDecoder,
				A2(
					$elm$json$Json$Decode$at,
					_List_fromArray(
						['target', 'dataset', 'id']),
					$elm$json$Json$Decode$string)),
			A2(
				$elm$json$Json$Decode$andThen,
				$author$project$ModelAPI$pathDecoder,
				A2(
					$elm$json$Json$Decode$at,
					_List_fromArray(
						['target', 'dataset', 'path']),
					$elm$json$Json$Decode$string))));
};
var $elm$virtual_dom$VirtualDom$Normal = function (a) {
	return {$: 'Normal', a: a};
};
var $elm$virtual_dom$VirtualDom$on = _VirtualDom_on;
var $elm$html$Html$Events$on = F2(
	function (event, decoder) {
		return A2(
			$elm$virtual_dom$VirtualDom$on,
			event,
			$elm$virtual_dom$VirtualDom$Normal(decoder));
	});
var $author$project$MouseAPI$mouseHoverHandler = _List_fromArray(
	[
		A2(
		$elm$html$Html$Events$on,
		'mouseover',
		$author$project$MouseAPI$mouseDecoder($author$project$Mouse$Over)),
		A2(
		$elm$html$Html$Events$on,
		'mouseout',
		$author$project$MouseAPI$mouseDecoder($author$project$Mouse$Out))
	]);
var $elm$virtual_dom$VirtualDom$text = _VirtualDom_text;
var $elm$html$Html$text = $elm$virtual_dom$VirtualDom$text;
var $author$project$IconMenu$Close = {$: 'Close'};
var $author$project$AppModel$IconMenu = function (a) {
	return {$: 'IconMenu', a: a};
};
var $elm$html$Html$button = _VirtualDom_node('button');
var $author$project$IconMenuAPI$closeButtonStyle = _List_fromArray(
	[
		A2($elm$html$Html$Attributes$style, 'position', 'absolute'),
		A2($elm$html$Html$Attributes$style, 'top', '0'),
		A2($elm$html$Html$Attributes$style, 'right', '0')
	]);
var $author$project$IconMenuAPI$iconListStyle = _List_fromArray(
	[
		A2($elm$html$Html$Attributes$style, 'height', '100%'),
		A2($elm$html$Html$Attributes$style, 'overflow', 'auto')
	]);
var $author$project$IconMenuAPI$iconMenuStyle = _List_fromArray(
	[
		A2($elm$html$Html$Attributes$style, 'position', 'absolute'),
		A2($elm$html$Html$Attributes$style, 'top', '291px'),
		A2($elm$html$Html$Attributes$style, 'width', '320px'),
		A2($elm$html$Html$Attributes$style, 'height', '320px'),
		A2($elm$html$Html$Attributes$style, 'background-color', 'white'),
		A2($elm$html$Html$Attributes$style, 'border', '1px solid lightgray'),
		A2($elm$html$Html$Attributes$style, 'z-index', '1')
	]);
var $elm$html$Html$Events$onClick = function (msg) {
	return A2(
		$elm$html$Html$Events$on,
		'click',
		$elm$json$Json$Decode$succeed(msg));
};
var $elm$virtual_dom$VirtualDom$Custom = function (a) {
	return {$: 'Custom', a: a};
};
var $elm$html$Html$Events$custom = F2(
	function (event, decoder) {
		return A2(
			$elm$virtual_dom$VirtualDom$on,
			event,
			$elm$virtual_dom$VirtualDom$Custom(decoder));
	});
var $author$project$IconMenuAPI$onContextMenuPrevent = function (msg) {
	return A2(
		$elm$html$Html$Events$custom,
		'contextmenu',
		$elm$json$Json$Decode$succeed(
			{message: msg, preventDefault: true, stopPropagation: true}));
};
var $elm$html$Html$Attributes$title = $elm$html$Html$Attributes$stringProperty('title');
var $author$project$IconMenu$SetIcon = function (a) {
	return {$: 'SetIcon', a: a};
};
var $author$project$IconMenuAPI$iconButtonStyle = _List_fromArray(
	[
		A2($elm$html$Html$Attributes$style, 'border-width', '0'),
		A2($elm$html$Html$Attributes$style, 'margin', '8px')
	]);
var $feathericons$elm_feather$FeatherIcons$Icon = function (a) {
	return {$: 'Icon', a: a};
};
var $feathericons$elm_feather$FeatherIcons$defaultAttributes = function (name) {
	return {
		_class: $elm$core$Maybe$Just('feather feather-' + name),
		size: 24,
		sizeUnit: '',
		strokeWidth: 2,
		viewBox: '0 0 24 24'
	};
};
var $feathericons$elm_feather$FeatherIcons$makeBuilder = F2(
	function (name, src) {
		return $feathericons$elm_feather$FeatherIcons$Icon(
			{
				attrs: $feathericons$elm_feather$FeatherIcons$defaultAttributes(name),
				src: src
			});
	});
var $elm$svg$Svg$Attributes$points = _VirtualDom_attribute('points');
var $elm$svg$Svg$trustedNode = _VirtualDom_nodeNS('http://www.w3.org/2000/svg');
var $elm$svg$Svg$polyline = $elm$svg$Svg$trustedNode('polyline');
var $feathericons$elm_feather$FeatherIcons$activity = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'activity',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('22 12 18 12 15 21 9 3 6 12 2 12')
				]),
			_List_Nil)
		]));
var $elm$svg$Svg$Attributes$d = _VirtualDom_attribute('d');
var $elm$svg$Svg$path = $elm$svg$Svg$trustedNode('path');
var $elm$svg$Svg$polygon = $elm$svg$Svg$trustedNode('polygon');
var $feathericons$elm_feather$FeatherIcons$airplay = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'airplay',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M5 17H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2h-1')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polygon,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('12 15 17 21 7 21 12 15')
				]),
			_List_Nil)
		]));
var $elm$svg$Svg$circle = $elm$svg$Svg$trustedNode('circle');
var $elm$svg$Svg$Attributes$cx = _VirtualDom_attribute('cx');
var $elm$svg$Svg$Attributes$cy = _VirtualDom_attribute('cy');
var $elm$svg$Svg$line = $elm$svg$Svg$trustedNode('line');
var $elm$svg$Svg$Attributes$r = _VirtualDom_attribute('r');
var $elm$svg$Svg$Attributes$x1 = _VirtualDom_attribute('x1');
var $elm$svg$Svg$Attributes$x2 = _VirtualDom_attribute('x2');
var $elm$svg$Svg$Attributes$y1 = _VirtualDom_attribute('y1');
var $elm$svg$Svg$Attributes$y2 = _VirtualDom_attribute('y2');
var $feathericons$elm_feather$FeatherIcons$alertCircle = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'alert-circle',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('10')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('8'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('12')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('16'),
					$elm$svg$Svg$Attributes$x2('12.01'),
					$elm$svg$Svg$Attributes$y2('16')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$alertOctagon = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'alert-octagon',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polygon,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('7.86 2 16.14 2 22 7.86 22 16.14 16.14 22 7.86 22 2 16.14 2 7.86 7.86 2')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('8'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('12')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('16'),
					$elm$svg$Svg$Attributes$x2('12.01'),
					$elm$svg$Svg$Attributes$y2('16')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$alertTriangle = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'alert-triangle',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('9'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('13')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('17'),
					$elm$svg$Svg$Attributes$x2('12.01'),
					$elm$svg$Svg$Attributes$y2('17')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$alignCenter = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'align-center',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('18'),
					$elm$svg$Svg$Attributes$y1('10'),
					$elm$svg$Svg$Attributes$x2('6'),
					$elm$svg$Svg$Attributes$y2('10')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('21'),
					$elm$svg$Svg$Attributes$y1('6'),
					$elm$svg$Svg$Attributes$x2('3'),
					$elm$svg$Svg$Attributes$y2('6')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('21'),
					$elm$svg$Svg$Attributes$y1('14'),
					$elm$svg$Svg$Attributes$x2('3'),
					$elm$svg$Svg$Attributes$y2('14')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('18'),
					$elm$svg$Svg$Attributes$y1('18'),
					$elm$svg$Svg$Attributes$x2('6'),
					$elm$svg$Svg$Attributes$y2('18')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$alignJustify = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'align-justify',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('21'),
					$elm$svg$Svg$Attributes$y1('10'),
					$elm$svg$Svg$Attributes$x2('3'),
					$elm$svg$Svg$Attributes$y2('10')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('21'),
					$elm$svg$Svg$Attributes$y1('6'),
					$elm$svg$Svg$Attributes$x2('3'),
					$elm$svg$Svg$Attributes$y2('6')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('21'),
					$elm$svg$Svg$Attributes$y1('14'),
					$elm$svg$Svg$Attributes$x2('3'),
					$elm$svg$Svg$Attributes$y2('14')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('21'),
					$elm$svg$Svg$Attributes$y1('18'),
					$elm$svg$Svg$Attributes$x2('3'),
					$elm$svg$Svg$Attributes$y2('18')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$alignLeft = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'align-left',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('17'),
					$elm$svg$Svg$Attributes$y1('10'),
					$elm$svg$Svg$Attributes$x2('3'),
					$elm$svg$Svg$Attributes$y2('10')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('21'),
					$elm$svg$Svg$Attributes$y1('6'),
					$elm$svg$Svg$Attributes$x2('3'),
					$elm$svg$Svg$Attributes$y2('6')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('21'),
					$elm$svg$Svg$Attributes$y1('14'),
					$elm$svg$Svg$Attributes$x2('3'),
					$elm$svg$Svg$Attributes$y2('14')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('17'),
					$elm$svg$Svg$Attributes$y1('18'),
					$elm$svg$Svg$Attributes$x2('3'),
					$elm$svg$Svg$Attributes$y2('18')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$alignRight = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'align-right',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('21'),
					$elm$svg$Svg$Attributes$y1('10'),
					$elm$svg$Svg$Attributes$x2('7'),
					$elm$svg$Svg$Attributes$y2('10')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('21'),
					$elm$svg$Svg$Attributes$y1('6'),
					$elm$svg$Svg$Attributes$x2('3'),
					$elm$svg$Svg$Attributes$y2('6')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('21'),
					$elm$svg$Svg$Attributes$y1('14'),
					$elm$svg$Svg$Attributes$x2('3'),
					$elm$svg$Svg$Attributes$y2('14')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('21'),
					$elm$svg$Svg$Attributes$y1('18'),
					$elm$svg$Svg$Attributes$x2('7'),
					$elm$svg$Svg$Attributes$y2('18')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$anchor = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'anchor',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('5'),
					$elm$svg$Svg$Attributes$r('3')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('22'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('8')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M5 12H2a10 10 0 0 0 20 0h-3')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$aperture = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'aperture',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('10')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('14.31'),
					$elm$svg$Svg$Attributes$y1('8'),
					$elm$svg$Svg$Attributes$x2('20.05'),
					$elm$svg$Svg$Attributes$y2('17.94')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('9.69'),
					$elm$svg$Svg$Attributes$y1('8'),
					$elm$svg$Svg$Attributes$x2('21.17'),
					$elm$svg$Svg$Attributes$y2('8')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('7.38'),
					$elm$svg$Svg$Attributes$y1('12'),
					$elm$svg$Svg$Attributes$x2('13.12'),
					$elm$svg$Svg$Attributes$y2('2.06')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('9.69'),
					$elm$svg$Svg$Attributes$y1('16'),
					$elm$svg$Svg$Attributes$x2('3.95'),
					$elm$svg$Svg$Attributes$y2('6.06')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('14.31'),
					$elm$svg$Svg$Attributes$y1('16'),
					$elm$svg$Svg$Attributes$x2('2.83'),
					$elm$svg$Svg$Attributes$y2('16')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('16.62'),
					$elm$svg$Svg$Attributes$y1('12'),
					$elm$svg$Svg$Attributes$x2('10.88'),
					$elm$svg$Svg$Attributes$y2('21.94')
				]),
			_List_Nil)
		]));
var $elm$svg$Svg$Attributes$height = _VirtualDom_attribute('height');
var $elm$svg$Svg$rect = $elm$svg$Svg$trustedNode('rect');
var $elm$svg$Svg$Attributes$width = _VirtualDom_attribute('width');
var $elm$svg$Svg$Attributes$x = _VirtualDom_attribute('x');
var $elm$svg$Svg$Attributes$y = _VirtualDom_attribute('y');
var $feathericons$elm_feather$FeatherIcons$archive = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'archive',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('21 8 21 21 3 21 3 8')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('1'),
					$elm$svg$Svg$Attributes$y('3'),
					$elm$svg$Svg$Attributes$width('22'),
					$elm$svg$Svg$Attributes$height('5')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('10'),
					$elm$svg$Svg$Attributes$y1('12'),
					$elm$svg$Svg$Attributes$x2('14'),
					$elm$svg$Svg$Attributes$y2('12')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$arrowDown = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'arrow-down',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('5'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('19')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('19 12 12 19 5 12')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$arrowDownCircle = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'arrow-down-circle',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('10')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('8 12 12 16 16 12')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('8'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('16')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$arrowDownLeft = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'arrow-down-left',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('17'),
					$elm$svg$Svg$Attributes$y1('7'),
					$elm$svg$Svg$Attributes$x2('7'),
					$elm$svg$Svg$Attributes$y2('17')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('17 17 7 17 7 7')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$arrowDownRight = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'arrow-down-right',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('7'),
					$elm$svg$Svg$Attributes$y1('7'),
					$elm$svg$Svg$Attributes$x2('17'),
					$elm$svg$Svg$Attributes$y2('17')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('17 7 17 17 7 17')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$arrowLeft = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'arrow-left',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('19'),
					$elm$svg$Svg$Attributes$y1('12'),
					$elm$svg$Svg$Attributes$x2('5'),
					$elm$svg$Svg$Attributes$y2('12')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('12 19 5 12 12 5')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$arrowLeftCircle = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'arrow-left-circle',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('10')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('12 8 8 12 12 16')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('16'),
					$elm$svg$Svg$Attributes$y1('12'),
					$elm$svg$Svg$Attributes$x2('8'),
					$elm$svg$Svg$Attributes$y2('12')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$arrowRight = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'arrow-right',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('5'),
					$elm$svg$Svg$Attributes$y1('12'),
					$elm$svg$Svg$Attributes$x2('19'),
					$elm$svg$Svg$Attributes$y2('12')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('12 5 19 12 12 19')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$arrowRightCircle = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'arrow-right-circle',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('10')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('12 16 16 12 12 8')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('8'),
					$elm$svg$Svg$Attributes$y1('12'),
					$elm$svg$Svg$Attributes$x2('16'),
					$elm$svg$Svg$Attributes$y2('12')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$arrowUp = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'arrow-up',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('19'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('5')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('5 12 12 5 19 12')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$arrowUpCircle = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'arrow-up-circle',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('10')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('16 12 12 8 8 12')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('16'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('8')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$arrowUpLeft = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'arrow-up-left',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('17'),
					$elm$svg$Svg$Attributes$y1('17'),
					$elm$svg$Svg$Attributes$x2('7'),
					$elm$svg$Svg$Attributes$y2('7')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('7 17 7 7 17 7')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$arrowUpRight = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'arrow-up-right',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('7'),
					$elm$svg$Svg$Attributes$y1('17'),
					$elm$svg$Svg$Attributes$x2('17'),
					$elm$svg$Svg$Attributes$y2('7')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('7 7 17 7 17 17')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$atSign = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'at-sign',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('4')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M16 8v5a3 3 0 0 0 6 0v-1a10 10 0 1 0-3.92 7.94')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$award = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'award',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('8'),
					$elm$svg$Svg$Attributes$r('7')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('8.21 13.89 7 23 12 20 17 23 15.79 13.88')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$barChart = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'bar-chart',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('20'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('10')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('18'),
					$elm$svg$Svg$Attributes$y1('20'),
					$elm$svg$Svg$Attributes$x2('18'),
					$elm$svg$Svg$Attributes$y2('4')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('6'),
					$elm$svg$Svg$Attributes$y1('20'),
					$elm$svg$Svg$Attributes$x2('6'),
					$elm$svg$Svg$Attributes$y2('16')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$barChart2 = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'bar-chart-2',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('18'),
					$elm$svg$Svg$Attributes$y1('20'),
					$elm$svg$Svg$Attributes$x2('18'),
					$elm$svg$Svg$Attributes$y2('10')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('20'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('4')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('6'),
					$elm$svg$Svg$Attributes$y1('20'),
					$elm$svg$Svg$Attributes$x2('6'),
					$elm$svg$Svg$Attributes$y2('14')
				]),
			_List_Nil)
		]));
var $elm$svg$Svg$Attributes$rx = _VirtualDom_attribute('rx');
var $elm$svg$Svg$Attributes$ry = _VirtualDom_attribute('ry');
var $feathericons$elm_feather$FeatherIcons$battery = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'battery',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('1'),
					$elm$svg$Svg$Attributes$y('6'),
					$elm$svg$Svg$Attributes$width('18'),
					$elm$svg$Svg$Attributes$height('12'),
					$elm$svg$Svg$Attributes$rx('2'),
					$elm$svg$Svg$Attributes$ry('2')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('23'),
					$elm$svg$Svg$Attributes$y1('13'),
					$elm$svg$Svg$Attributes$x2('23'),
					$elm$svg$Svg$Attributes$y2('11')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$batteryCharging = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'battery-charging',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M5 18H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h3.19M15 6h2a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2h-3.19')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('23'),
					$elm$svg$Svg$Attributes$y1('13'),
					$elm$svg$Svg$Attributes$x2('23'),
					$elm$svg$Svg$Attributes$y2('11')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('11 6 7 12 13 12 9 18')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$bell = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'bell',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M13.73 21a2 2 0 0 1-3.46 0')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$bellOff = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'bell-off',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M13.73 21a2 2 0 0 1-3.46 0')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M18.63 13A17.89 17.89 0 0 1 18 8')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M6.26 6.26A5.86 5.86 0 0 0 6 8c0 7-3 9-3 9h14')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M18 8a6 6 0 0 0-9.33-5')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('1'),
					$elm$svg$Svg$Attributes$y1('1'),
					$elm$svg$Svg$Attributes$x2('23'),
					$elm$svg$Svg$Attributes$y2('23')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$bluetooth = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'bluetooth',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('6.5 6.5 17.5 17.5 12 23 12 1 17.5 6.5 6.5 17.5')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$bold = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'bold',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M6 4h8a4 4 0 0 1 4 4 4 4 0 0 1-4 4H6z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M6 12h9a4 4 0 0 1 4 4 4 4 0 0 1-4 4H6z')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$book = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'book',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M4 19.5A2.5 2.5 0 0 1 6.5 17H20')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$bookOpen = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'book-open',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$bookmark = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'bookmark',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$box = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'box',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('3.27 6.96 12 12.01 20.73 6.96')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('22.08'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('12')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$briefcase = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'briefcase',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('2'),
					$elm$svg$Svg$Attributes$y('7'),
					$elm$svg$Svg$Attributes$width('20'),
					$elm$svg$Svg$Attributes$height('14'),
					$elm$svg$Svg$Attributes$rx('2'),
					$elm$svg$Svg$Attributes$ry('2')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$calendar = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'calendar',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('3'),
					$elm$svg$Svg$Attributes$y('4'),
					$elm$svg$Svg$Attributes$width('18'),
					$elm$svg$Svg$Attributes$height('18'),
					$elm$svg$Svg$Attributes$rx('2'),
					$elm$svg$Svg$Attributes$ry('2')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('16'),
					$elm$svg$Svg$Attributes$y1('2'),
					$elm$svg$Svg$Attributes$x2('16'),
					$elm$svg$Svg$Attributes$y2('6')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('8'),
					$elm$svg$Svg$Attributes$y1('2'),
					$elm$svg$Svg$Attributes$x2('8'),
					$elm$svg$Svg$Attributes$y2('6')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('3'),
					$elm$svg$Svg$Attributes$y1('10'),
					$elm$svg$Svg$Attributes$x2('21'),
					$elm$svg$Svg$Attributes$y2('10')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$camera = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'camera',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('13'),
					$elm$svg$Svg$Attributes$r('4')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$cameraOff = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'camera-off',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('1'),
					$elm$svg$Svg$Attributes$y1('1'),
					$elm$svg$Svg$Attributes$x2('23'),
					$elm$svg$Svg$Attributes$y2('23')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M21 21H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h3m3-3h6l2 3h4a2 2 0 0 1 2 2v9.34m-7.72-2.06a4 4 0 1 1-5.56-5.56')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$cast = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'cast',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M2 16.1A5 5 0 0 1 5.9 20M2 12.05A9 9 0 0 1 9.95 20M2 8V6a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2h-6')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('2'),
					$elm$svg$Svg$Attributes$y1('20'),
					$elm$svg$Svg$Attributes$x2('2.01'),
					$elm$svg$Svg$Attributes$y2('20')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$check = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'check',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('20 6 9 17 4 12')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$checkCircle = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'check-circle',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M22 11.08V12a10 10 0 1 1-5.93-9.14')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('22 4 12 14.01 9 11.01')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$checkSquare = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'check-square',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('9 11 12 14 22 4')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$chevronDown = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'chevron-down',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('6 9 12 15 18 9')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$chevronLeft = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'chevron-left',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('15 18 9 12 15 6')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$chevronRight = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'chevron-right',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('9 18 15 12 9 6')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$chevronUp = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'chevron-up',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('18 15 12 9 6 15')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$chevronsDown = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'chevrons-down',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('7 13 12 18 17 13')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('7 6 12 11 17 6')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$chevronsLeft = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'chevrons-left',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('11 17 6 12 11 7')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('18 17 13 12 18 7')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$chevronsRight = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'chevrons-right',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('13 17 18 12 13 7')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('6 17 11 12 6 7')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$chevronsUp = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'chevrons-up',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('17 11 12 6 7 11')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('17 18 12 13 7 18')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$chrome = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'chrome',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('10')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('4')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('21.17'),
					$elm$svg$Svg$Attributes$y1('8'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('8')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('3.95'),
					$elm$svg$Svg$Attributes$y1('6.06'),
					$elm$svg$Svg$Attributes$x2('8.54'),
					$elm$svg$Svg$Attributes$y2('14')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('10.88'),
					$elm$svg$Svg$Attributes$y1('21.94'),
					$elm$svg$Svg$Attributes$x2('15.46'),
					$elm$svg$Svg$Attributes$y2('14')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$circle = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'circle',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('10')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$clipboard = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'clipboard',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('8'),
					$elm$svg$Svg$Attributes$y('2'),
					$elm$svg$Svg$Attributes$width('8'),
					$elm$svg$Svg$Attributes$height('4'),
					$elm$svg$Svg$Attributes$rx('1'),
					$elm$svg$Svg$Attributes$ry('1')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$clock = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'clock',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('10')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('12 6 12 12 16 14')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$cloud = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'cloud',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M18 10h-1.26A8 8 0 1 0 9 20h9a5 5 0 0 0 0-10z')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$cloudDrizzle = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'cloud-drizzle',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('8'),
					$elm$svg$Svg$Attributes$y1('19'),
					$elm$svg$Svg$Attributes$x2('8'),
					$elm$svg$Svg$Attributes$y2('21')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('8'),
					$elm$svg$Svg$Attributes$y1('13'),
					$elm$svg$Svg$Attributes$x2('8'),
					$elm$svg$Svg$Attributes$y2('15')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('16'),
					$elm$svg$Svg$Attributes$y1('19'),
					$elm$svg$Svg$Attributes$x2('16'),
					$elm$svg$Svg$Attributes$y2('21')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('16'),
					$elm$svg$Svg$Attributes$y1('13'),
					$elm$svg$Svg$Attributes$x2('16'),
					$elm$svg$Svg$Attributes$y2('15')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('21'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('23')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('15'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('17')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M20 16.58A5 5 0 0 0 18 7h-1.26A8 8 0 1 0 4 15.25')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$cloudLightning = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'cloud-lightning',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M19 16.9A5 5 0 0 0 18 7h-1.26a8 8 0 1 0-11.62 9')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('13 11 9 17 15 17 11 23')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$cloudOff = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'cloud-off',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M22.61 16.95A5 5 0 0 0 18 10h-1.26a8 8 0 0 0-7.05-6M5 5a8 8 0 0 0 4 15h9a5 5 0 0 0 1.7-.3')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('1'),
					$elm$svg$Svg$Attributes$y1('1'),
					$elm$svg$Svg$Attributes$x2('23'),
					$elm$svg$Svg$Attributes$y2('23')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$cloudRain = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'cloud-rain',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('16'),
					$elm$svg$Svg$Attributes$y1('13'),
					$elm$svg$Svg$Attributes$x2('16'),
					$elm$svg$Svg$Attributes$y2('21')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('8'),
					$elm$svg$Svg$Attributes$y1('13'),
					$elm$svg$Svg$Attributes$x2('8'),
					$elm$svg$Svg$Attributes$y2('21')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('15'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('23')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M20 16.58A5 5 0 0 0 18 7h-1.26A8 8 0 1 0 4 15.25')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$cloudSnow = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'cloud-snow',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M20 17.58A5 5 0 0 0 18 8h-1.26A8 8 0 1 0 4 16.25')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('8'),
					$elm$svg$Svg$Attributes$y1('16'),
					$elm$svg$Svg$Attributes$x2('8.01'),
					$elm$svg$Svg$Attributes$y2('16')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('8'),
					$elm$svg$Svg$Attributes$y1('20'),
					$elm$svg$Svg$Attributes$x2('8.01'),
					$elm$svg$Svg$Attributes$y2('20')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('18'),
					$elm$svg$Svg$Attributes$x2('12.01'),
					$elm$svg$Svg$Attributes$y2('18')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('22'),
					$elm$svg$Svg$Attributes$x2('12.01'),
					$elm$svg$Svg$Attributes$y2('22')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('16'),
					$elm$svg$Svg$Attributes$y1('16'),
					$elm$svg$Svg$Attributes$x2('16.01'),
					$elm$svg$Svg$Attributes$y2('16')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('16'),
					$elm$svg$Svg$Attributes$y1('20'),
					$elm$svg$Svg$Attributes$x2('16.01'),
					$elm$svg$Svg$Attributes$y2('20')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$code = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'code',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('16 18 22 12 16 6')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('8 6 2 12 8 18')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$codepen = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'codepen',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polygon,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('12 2 22 8.5 22 15.5 12 22 2 15.5 2 8.5 12 2')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('22'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('15.5')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('22 8.5 12 15.5 2 8.5')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('2 15.5 12 8.5 22 15.5')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('2'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('8.5')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$codesandbox = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'codesandbox',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('7.5 4.21 12 6.81 16.5 4.21')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('7.5 19.79 7.5 14.6 3 12')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('21 12 16.5 14.6 16.5 19.79')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('3.27 6.96 12 12.01 20.73 6.96')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('22.08'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('12')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$coffee = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'coffee',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M18 8h1a4 4 0 0 1 0 8h-1')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M2 8h16v9a4 4 0 0 1-4 4H6a4 4 0 0 1-4-4V8z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('6'),
					$elm$svg$Svg$Attributes$y1('1'),
					$elm$svg$Svg$Attributes$x2('6'),
					$elm$svg$Svg$Attributes$y2('4')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('10'),
					$elm$svg$Svg$Attributes$y1('1'),
					$elm$svg$Svg$Attributes$x2('10'),
					$elm$svg$Svg$Attributes$y2('4')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('14'),
					$elm$svg$Svg$Attributes$y1('1'),
					$elm$svg$Svg$Attributes$x2('14'),
					$elm$svg$Svg$Attributes$y2('4')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$columns = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'columns',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M12 3h7a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-7m0-18H5a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h7m0-18v18')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$command = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'command',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M18 3a3 3 0 0 0-3 3v12a3 3 0 0 0 3 3 3 3 0 0 0 3-3 3 3 0 0 0-3-3H6a3 3 0 0 0-3 3 3 3 0 0 0 3 3 3 3 0 0 0 3-3V6a3 3 0 0 0-3-3 3 3 0 0 0-3 3 3 3 0 0 0 3 3h12a3 3 0 0 0 3-3 3 3 0 0 0-3-3z')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$compass = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'compass',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('10')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polygon,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('16.24 7.76 14.12 14.12 7.76 16.24 9.88 9.88 16.24 7.76')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$copy = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'copy',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('9'),
					$elm$svg$Svg$Attributes$y('9'),
					$elm$svg$Svg$Attributes$width('13'),
					$elm$svg$Svg$Attributes$height('13'),
					$elm$svg$Svg$Attributes$rx('2'),
					$elm$svg$Svg$Attributes$ry('2')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$cornerDownLeft = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'corner-down-left',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('9 10 4 15 9 20')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M20 4v7a4 4 0 0 1-4 4H4')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$cornerDownRight = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'corner-down-right',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('15 10 20 15 15 20')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M4 4v7a4 4 0 0 0 4 4h12')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$cornerLeftDown = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'corner-left-down',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('14 15 9 20 4 15')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M20 4h-7a4 4 0 0 0-4 4v12')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$cornerLeftUp = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'corner-left-up',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('14 9 9 4 4 9')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M20 20h-7a4 4 0 0 1-4-4V4')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$cornerRightDown = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'corner-right-down',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('10 15 15 20 20 15')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M4 4h7a4 4 0 0 1 4 4v12')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$cornerRightUp = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'corner-right-up',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('10 9 15 4 20 9')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M4 20h7a4 4 0 0 0 4-4V4')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$cornerUpLeft = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'corner-up-left',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('9 14 4 9 9 4')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M20 20v-7a4 4 0 0 0-4-4H4')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$cornerUpRight = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'corner-up-right',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('15 14 20 9 15 4')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M4 20v-7a4 4 0 0 1 4-4h12')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$cpu = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'cpu',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('4'),
					$elm$svg$Svg$Attributes$y('4'),
					$elm$svg$Svg$Attributes$width('16'),
					$elm$svg$Svg$Attributes$height('16'),
					$elm$svg$Svg$Attributes$rx('2'),
					$elm$svg$Svg$Attributes$ry('2')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('9'),
					$elm$svg$Svg$Attributes$y('9'),
					$elm$svg$Svg$Attributes$width('6'),
					$elm$svg$Svg$Attributes$height('6')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('9'),
					$elm$svg$Svg$Attributes$y1('1'),
					$elm$svg$Svg$Attributes$x2('9'),
					$elm$svg$Svg$Attributes$y2('4')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('15'),
					$elm$svg$Svg$Attributes$y1('1'),
					$elm$svg$Svg$Attributes$x2('15'),
					$elm$svg$Svg$Attributes$y2('4')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('9'),
					$elm$svg$Svg$Attributes$y1('20'),
					$elm$svg$Svg$Attributes$x2('9'),
					$elm$svg$Svg$Attributes$y2('23')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('15'),
					$elm$svg$Svg$Attributes$y1('20'),
					$elm$svg$Svg$Attributes$x2('15'),
					$elm$svg$Svg$Attributes$y2('23')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('20'),
					$elm$svg$Svg$Attributes$y1('9'),
					$elm$svg$Svg$Attributes$x2('23'),
					$elm$svg$Svg$Attributes$y2('9')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('20'),
					$elm$svg$Svg$Attributes$y1('14'),
					$elm$svg$Svg$Attributes$x2('23'),
					$elm$svg$Svg$Attributes$y2('14')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('1'),
					$elm$svg$Svg$Attributes$y1('9'),
					$elm$svg$Svg$Attributes$x2('4'),
					$elm$svg$Svg$Attributes$y2('9')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('1'),
					$elm$svg$Svg$Attributes$y1('14'),
					$elm$svg$Svg$Attributes$x2('4'),
					$elm$svg$Svg$Attributes$y2('14')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$creditCard = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'credit-card',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('1'),
					$elm$svg$Svg$Attributes$y('4'),
					$elm$svg$Svg$Attributes$width('22'),
					$elm$svg$Svg$Attributes$height('16'),
					$elm$svg$Svg$Attributes$rx('2'),
					$elm$svg$Svg$Attributes$ry('2')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('1'),
					$elm$svg$Svg$Attributes$y1('10'),
					$elm$svg$Svg$Attributes$x2('23'),
					$elm$svg$Svg$Attributes$y2('10')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$crop = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'crop',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M6.13 1L6 16a2 2 0 0 0 2 2h15')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M1 6.13L16 6a2 2 0 0 1 2 2v15')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$crosshair = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'crosshair',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('10')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('22'),
					$elm$svg$Svg$Attributes$y1('12'),
					$elm$svg$Svg$Attributes$x2('18'),
					$elm$svg$Svg$Attributes$y2('12')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('6'),
					$elm$svg$Svg$Attributes$y1('12'),
					$elm$svg$Svg$Attributes$x2('2'),
					$elm$svg$Svg$Attributes$y2('12')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('6'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('2')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('22'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('18')
				]),
			_List_Nil)
		]));
var $elm$svg$Svg$ellipse = $elm$svg$Svg$trustedNode('ellipse');
var $feathericons$elm_feather$FeatherIcons$database = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'database',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$ellipse,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('5'),
					$elm$svg$Svg$Attributes$rx('9'),
					$elm$svg$Svg$Attributes$ry('3')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M21 12c0 1.66-4 3-9 3s-9-1.34-9-3')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M3 5v14c0 1.66 4 3 9 3s9-1.34 9-3V5')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$delete = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'delete',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M21 4H8l-7 8 7 8h13a2 2 0 0 0 2-2V6a2 2 0 0 0-2-2z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('18'),
					$elm$svg$Svg$Attributes$y1('9'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('15')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('9'),
					$elm$svg$Svg$Attributes$x2('18'),
					$elm$svg$Svg$Attributes$y2('15')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$disc = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'disc',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('10')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('3')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$divide = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'divide',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('6'),
					$elm$svg$Svg$Attributes$r('2')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('5'),
					$elm$svg$Svg$Attributes$y1('12'),
					$elm$svg$Svg$Attributes$x2('19'),
					$elm$svg$Svg$Attributes$y2('12')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('18'),
					$elm$svg$Svg$Attributes$r('2')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$divideCircle = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'divide-circle',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('8'),
					$elm$svg$Svg$Attributes$y1('12'),
					$elm$svg$Svg$Attributes$x2('16'),
					$elm$svg$Svg$Attributes$y2('12')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('16'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('16')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('8'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('8')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('10')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$divideSquare = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'divide-square',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('3'),
					$elm$svg$Svg$Attributes$y('3'),
					$elm$svg$Svg$Attributes$width('18'),
					$elm$svg$Svg$Attributes$height('18'),
					$elm$svg$Svg$Attributes$rx('2'),
					$elm$svg$Svg$Attributes$ry('2')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('8'),
					$elm$svg$Svg$Attributes$y1('12'),
					$elm$svg$Svg$Attributes$x2('16'),
					$elm$svg$Svg$Attributes$y2('12')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('16'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('16')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('8'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('8')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$dollarSign = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'dollar-sign',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('1'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('23')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$download = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'download',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('7 10 12 15 17 10')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('15'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('3')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$downloadCloud = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'download-cloud',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('8 17 12 21 16 17')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('12'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('21')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M20.88 18.09A5 5 0 0 0 18 9h-1.26A8 8 0 1 0 3 16.29')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$dribbble = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'dribbble',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('10')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M8.56 2.75c4.37 6.03 6.02 9.42 8.03 17.72m2.54-15.38c-3.72 4.35-8.94 5.66-16.88 5.85m19.5 1.9c-3.5-.93-6.63-.82-8.94 0-2.58.92-5.01 2.86-7.44 6.32')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$droplet = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'droplet',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M12 2.69l5.66 5.66a8 8 0 1 1-11.31 0z')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$edit = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'edit',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$edit2 = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'edit-2',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M17 3a2.828 2.828 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5L17 3z')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$edit3 = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'edit-3',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M12 20h9')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$externalLink = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'external-link',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('15 3 21 3 21 9')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('10'),
					$elm$svg$Svg$Attributes$y1('14'),
					$elm$svg$Svg$Attributes$x2('21'),
					$elm$svg$Svg$Attributes$y2('3')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$eye = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'eye',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('3')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$eyeOff = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'eye-off',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('1'),
					$elm$svg$Svg$Attributes$y1('1'),
					$elm$svg$Svg$Attributes$x2('23'),
					$elm$svg$Svg$Attributes$y2('23')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$facebook = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'facebook',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M18 2h-3a5 5 0 0 0-5 5v3H7v4h3v8h4v-8h3l1-4h-4V7a1 1 0 0 1 1-1h3z')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$fastForward = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'fast-forward',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polygon,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('13 19 22 12 13 5 13 19')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polygon,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('2 19 11 12 2 5 2 19')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$feather = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'feather',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M20.24 12.24a6 6 0 0 0-8.49-8.49L5 10.5V19h8.5z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('16'),
					$elm$svg$Svg$Attributes$y1('8'),
					$elm$svg$Svg$Attributes$x2('2'),
					$elm$svg$Svg$Attributes$y2('22')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('17.5'),
					$elm$svg$Svg$Attributes$y1('15'),
					$elm$svg$Svg$Attributes$x2('9'),
					$elm$svg$Svg$Attributes$y2('15')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$figma = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'figma',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M5 5.5A3.5 3.5 0 0 1 8.5 2H12v7H8.5A3.5 3.5 0 0 1 5 5.5z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M12 2h3.5a3.5 3.5 0 1 1 0 7H12V2z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M12 12.5a3.5 3.5 0 1 1 7 0 3.5 3.5 0 1 1-7 0z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M5 19.5A3.5 3.5 0 0 1 8.5 16H12v3.5a3.5 3.5 0 1 1-7 0z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M5 12.5A3.5 3.5 0 0 1 8.5 9H12v7H8.5A3.5 3.5 0 0 1 5 12.5z')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$file = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'file',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M13 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('13 2 13 9 20 9')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$fileMinus = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'file-minus',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('14 2 14 8 20 8')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('9'),
					$elm$svg$Svg$Attributes$y1('15'),
					$elm$svg$Svg$Attributes$x2('15'),
					$elm$svg$Svg$Attributes$y2('15')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$filePlus = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'file-plus',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('14 2 14 8 20 8')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('18'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('12')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('9'),
					$elm$svg$Svg$Attributes$y1('15'),
					$elm$svg$Svg$Attributes$x2('15'),
					$elm$svg$Svg$Attributes$y2('15')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$fileText = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'file-text',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('14 2 14 8 20 8')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('16'),
					$elm$svg$Svg$Attributes$y1('13'),
					$elm$svg$Svg$Attributes$x2('8'),
					$elm$svg$Svg$Attributes$y2('13')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('16'),
					$elm$svg$Svg$Attributes$y1('17'),
					$elm$svg$Svg$Attributes$x2('8'),
					$elm$svg$Svg$Attributes$y2('17')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('10 9 9 9 8 9')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$film = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'film',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('2'),
					$elm$svg$Svg$Attributes$y('2'),
					$elm$svg$Svg$Attributes$width('20'),
					$elm$svg$Svg$Attributes$height('20'),
					$elm$svg$Svg$Attributes$rx('2.18'),
					$elm$svg$Svg$Attributes$ry('2.18')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('7'),
					$elm$svg$Svg$Attributes$y1('2'),
					$elm$svg$Svg$Attributes$x2('7'),
					$elm$svg$Svg$Attributes$y2('22')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('17'),
					$elm$svg$Svg$Attributes$y1('2'),
					$elm$svg$Svg$Attributes$x2('17'),
					$elm$svg$Svg$Attributes$y2('22')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('2'),
					$elm$svg$Svg$Attributes$y1('12'),
					$elm$svg$Svg$Attributes$x2('22'),
					$elm$svg$Svg$Attributes$y2('12')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('2'),
					$elm$svg$Svg$Attributes$y1('7'),
					$elm$svg$Svg$Attributes$x2('7'),
					$elm$svg$Svg$Attributes$y2('7')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('2'),
					$elm$svg$Svg$Attributes$y1('17'),
					$elm$svg$Svg$Attributes$x2('7'),
					$elm$svg$Svg$Attributes$y2('17')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('17'),
					$elm$svg$Svg$Attributes$y1('17'),
					$elm$svg$Svg$Attributes$x2('22'),
					$elm$svg$Svg$Attributes$y2('17')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('17'),
					$elm$svg$Svg$Attributes$y1('7'),
					$elm$svg$Svg$Attributes$x2('22'),
					$elm$svg$Svg$Attributes$y2('7')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$filter = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'filter',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polygon,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$flag = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'flag',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M4 15s1-1 4-1 5 2 8 2 4-1 4-1V3s-1 1-4 1-5-2-8-2-4 1-4 1z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('4'),
					$elm$svg$Svg$Attributes$y1('22'),
					$elm$svg$Svg$Attributes$x2('4'),
					$elm$svg$Svg$Attributes$y2('15')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$folder = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'folder',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$folderMinus = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'folder-minus',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('9'),
					$elm$svg$Svg$Attributes$y1('14'),
					$elm$svg$Svg$Attributes$x2('15'),
					$elm$svg$Svg$Attributes$y2('14')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$folderPlus = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'folder-plus',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('11'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('17')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('9'),
					$elm$svg$Svg$Attributes$y1('14'),
					$elm$svg$Svg$Attributes$x2('15'),
					$elm$svg$Svg$Attributes$y2('14')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$framer = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'framer',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M5 16V9h14V2H5l14 14h-7m-7 0l7 7v-7m-7 0h7')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$frown = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'frown',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('10')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M16 16s-1.5-2-4-2-4 2-4 2')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('9'),
					$elm$svg$Svg$Attributes$y1('9'),
					$elm$svg$Svg$Attributes$x2('9.01'),
					$elm$svg$Svg$Attributes$y2('9')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('15'),
					$elm$svg$Svg$Attributes$y1('9'),
					$elm$svg$Svg$Attributes$x2('15.01'),
					$elm$svg$Svg$Attributes$y2('9')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$gift = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'gift',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('20 12 20 22 4 22 4 12')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('2'),
					$elm$svg$Svg$Attributes$y('7'),
					$elm$svg$Svg$Attributes$width('20'),
					$elm$svg$Svg$Attributes$height('5')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('22'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('7')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M12 7H7.5a2.5 2.5 0 0 1 0-5C11 2 12 7 12 7z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M12 7h4.5a2.5 2.5 0 0 0 0-5C13 2 12 7 12 7z')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$gitBranch = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'git-branch',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('6'),
					$elm$svg$Svg$Attributes$y1('3'),
					$elm$svg$Svg$Attributes$x2('6'),
					$elm$svg$Svg$Attributes$y2('15')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('18'),
					$elm$svg$Svg$Attributes$cy('6'),
					$elm$svg$Svg$Attributes$r('3')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('6'),
					$elm$svg$Svg$Attributes$cy('18'),
					$elm$svg$Svg$Attributes$r('3')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M18 9a9 9 0 0 1-9 9')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$gitCommit = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'git-commit',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('4')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('1.05'),
					$elm$svg$Svg$Attributes$y1('12'),
					$elm$svg$Svg$Attributes$x2('7'),
					$elm$svg$Svg$Attributes$y2('12')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('17.01'),
					$elm$svg$Svg$Attributes$y1('12'),
					$elm$svg$Svg$Attributes$x2('22.96'),
					$elm$svg$Svg$Attributes$y2('12')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$gitMerge = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'git-merge',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('18'),
					$elm$svg$Svg$Attributes$cy('18'),
					$elm$svg$Svg$Attributes$r('3')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('6'),
					$elm$svg$Svg$Attributes$cy('6'),
					$elm$svg$Svg$Attributes$r('3')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M6 21V9a9 9 0 0 0 9 9')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$gitPullRequest = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'git-pull-request',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('18'),
					$elm$svg$Svg$Attributes$cy('18'),
					$elm$svg$Svg$Attributes$r('3')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('6'),
					$elm$svg$Svg$Attributes$cy('6'),
					$elm$svg$Svg$Attributes$r('3')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M13 6h3a2 2 0 0 1 2 2v7')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('6'),
					$elm$svg$Svg$Attributes$y1('9'),
					$elm$svg$Svg$Attributes$x2('6'),
					$elm$svg$Svg$Attributes$y2('21')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$github = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'github',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M9 19c-5 1.5-5-2.5-7-3m14 6v-3.87a3.37 3.37 0 0 0-.94-2.61c3.14-.35 6.44-1.54 6.44-7A5.44 5.44 0 0 0 20 4.77 5.07 5.07 0 0 0 19.91 1S18.73.65 16 2.48a13.38 13.38 0 0 0-7 0C6.27.65 5.09 1 5.09 1A5.07 5.07 0 0 0 5 4.77a5.44 5.44 0 0 0-1.5 3.78c0 5.42 3.3 6.61 6.44 7A3.37 3.37 0 0 0 9 18.13V22')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$gitlab = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'gitlab',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M22.65 14.39L12 22.13 1.35 14.39a.84.84 0 0 1-.3-.94l1.22-3.78 2.44-7.51A.42.42 0 0 1 4.82 2a.43.43 0 0 1 .58 0 .42.42 0 0 1 .11.18l2.44 7.49h8.1l2.44-7.51A.42.42 0 0 1 18.6 2a.43.43 0 0 1 .58 0 .42.42 0 0 1 .11.18l2.44 7.51L23 13.45a.84.84 0 0 1-.35.94z')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$globe = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'globe',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('10')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('2'),
					$elm$svg$Svg$Attributes$y1('12'),
					$elm$svg$Svg$Attributes$x2('22'),
					$elm$svg$Svg$Attributes$y2('12')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$grid = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'grid',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('3'),
					$elm$svg$Svg$Attributes$y('3'),
					$elm$svg$Svg$Attributes$width('7'),
					$elm$svg$Svg$Attributes$height('7')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('14'),
					$elm$svg$Svg$Attributes$y('3'),
					$elm$svg$Svg$Attributes$width('7'),
					$elm$svg$Svg$Attributes$height('7')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('14'),
					$elm$svg$Svg$Attributes$y('14'),
					$elm$svg$Svg$Attributes$width('7'),
					$elm$svg$Svg$Attributes$height('7')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('3'),
					$elm$svg$Svg$Attributes$y('14'),
					$elm$svg$Svg$Attributes$width('7'),
					$elm$svg$Svg$Attributes$height('7')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$hardDrive = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'hard-drive',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('22'),
					$elm$svg$Svg$Attributes$y1('12'),
					$elm$svg$Svg$Attributes$x2('2'),
					$elm$svg$Svg$Attributes$y2('12')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M5.45 5.11L2 12v6a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-6l-3.45-6.89A2 2 0 0 0 16.76 4H7.24a2 2 0 0 0-1.79 1.11z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('6'),
					$elm$svg$Svg$Attributes$y1('16'),
					$elm$svg$Svg$Attributes$x2('6.01'),
					$elm$svg$Svg$Attributes$y2('16')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('10'),
					$elm$svg$Svg$Attributes$y1('16'),
					$elm$svg$Svg$Attributes$x2('10.01'),
					$elm$svg$Svg$Attributes$y2('16')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$hash = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'hash',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('4'),
					$elm$svg$Svg$Attributes$y1('9'),
					$elm$svg$Svg$Attributes$x2('20'),
					$elm$svg$Svg$Attributes$y2('9')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('4'),
					$elm$svg$Svg$Attributes$y1('15'),
					$elm$svg$Svg$Attributes$x2('20'),
					$elm$svg$Svg$Attributes$y2('15')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('10'),
					$elm$svg$Svg$Attributes$y1('3'),
					$elm$svg$Svg$Attributes$x2('8'),
					$elm$svg$Svg$Attributes$y2('21')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('16'),
					$elm$svg$Svg$Attributes$y1('3'),
					$elm$svg$Svg$Attributes$x2('14'),
					$elm$svg$Svg$Attributes$y2('21')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$headphones = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'headphones',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M3 18v-6a9 9 0 0 1 18 0v6')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M21 19a2 2 0 0 1-2 2h-1a2 2 0 0 1-2-2v-3a2 2 0 0 1 2-2h3zM3 19a2 2 0 0 0 2 2h1a2 2 0 0 0 2-2v-3a2 2 0 0 0-2-2H3z')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$heart = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'heart',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$helpCircle = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'help-circle',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('10')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('17'),
					$elm$svg$Svg$Attributes$x2('12.01'),
					$elm$svg$Svg$Attributes$y2('17')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$hexagon = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'hexagon',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$home = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'home',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('9 22 9 12 15 12 15 22')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$image = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'image',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('3'),
					$elm$svg$Svg$Attributes$y('3'),
					$elm$svg$Svg$Attributes$width('18'),
					$elm$svg$Svg$Attributes$height('18'),
					$elm$svg$Svg$Attributes$rx('2'),
					$elm$svg$Svg$Attributes$ry('2')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('8.5'),
					$elm$svg$Svg$Attributes$cy('8.5'),
					$elm$svg$Svg$Attributes$r('1.5')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('21 15 16 10 5 21')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$inbox = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'inbox',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('22 12 16 12 14 15 10 15 8 12 2 12')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M5.45 5.11L2 12v6a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-6l-3.45-6.89A2 2 0 0 0 16.76 4H7.24a2 2 0 0 0-1.79 1.11z')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$info = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'info',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('10')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('16'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('12')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('8'),
					$elm$svg$Svg$Attributes$x2('12.01'),
					$elm$svg$Svg$Attributes$y2('8')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$instagram = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'instagram',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('2'),
					$elm$svg$Svg$Attributes$y('2'),
					$elm$svg$Svg$Attributes$width('20'),
					$elm$svg$Svg$Attributes$height('20'),
					$elm$svg$Svg$Attributes$rx('5'),
					$elm$svg$Svg$Attributes$ry('5')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('17.5'),
					$elm$svg$Svg$Attributes$y1('6.5'),
					$elm$svg$Svg$Attributes$x2('17.51'),
					$elm$svg$Svg$Attributes$y2('6.5')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$italic = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'italic',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('19'),
					$elm$svg$Svg$Attributes$y1('4'),
					$elm$svg$Svg$Attributes$x2('10'),
					$elm$svg$Svg$Attributes$y2('4')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('14'),
					$elm$svg$Svg$Attributes$y1('20'),
					$elm$svg$Svg$Attributes$x2('5'),
					$elm$svg$Svg$Attributes$y2('20')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('15'),
					$elm$svg$Svg$Attributes$y1('4'),
					$elm$svg$Svg$Attributes$x2('9'),
					$elm$svg$Svg$Attributes$y2('20')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$key = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'key',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M21 2l-2 2m-7.61 7.61a5.5 5.5 0 1 1-7.778 7.778 5.5 5.5 0 0 1 7.777-7.777zm0 0L15.5 7.5m0 0l3 3L22 7l-3-3m-3.5 3.5L19 4')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$layers = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'layers',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polygon,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('12 2 2 7 12 12 22 7 12 2')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('2 17 12 22 22 17')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('2 12 12 17 22 12')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$layout = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'layout',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('3'),
					$elm$svg$Svg$Attributes$y('3'),
					$elm$svg$Svg$Attributes$width('18'),
					$elm$svg$Svg$Attributes$height('18'),
					$elm$svg$Svg$Attributes$rx('2'),
					$elm$svg$Svg$Attributes$ry('2')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('3'),
					$elm$svg$Svg$Attributes$y1('9'),
					$elm$svg$Svg$Attributes$x2('21'),
					$elm$svg$Svg$Attributes$y2('9')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('9'),
					$elm$svg$Svg$Attributes$y1('21'),
					$elm$svg$Svg$Attributes$x2('9'),
					$elm$svg$Svg$Attributes$y2('9')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$lifeBuoy = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'life-buoy',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('10')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('4')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('4.93'),
					$elm$svg$Svg$Attributes$y1('4.93'),
					$elm$svg$Svg$Attributes$x2('9.17'),
					$elm$svg$Svg$Attributes$y2('9.17')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('14.83'),
					$elm$svg$Svg$Attributes$y1('14.83'),
					$elm$svg$Svg$Attributes$x2('19.07'),
					$elm$svg$Svg$Attributes$y2('19.07')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('14.83'),
					$elm$svg$Svg$Attributes$y1('9.17'),
					$elm$svg$Svg$Attributes$x2('19.07'),
					$elm$svg$Svg$Attributes$y2('4.93')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('14.83'),
					$elm$svg$Svg$Attributes$y1('9.17'),
					$elm$svg$Svg$Attributes$x2('18.36'),
					$elm$svg$Svg$Attributes$y2('5.64')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('4.93'),
					$elm$svg$Svg$Attributes$y1('19.07'),
					$elm$svg$Svg$Attributes$x2('9.17'),
					$elm$svg$Svg$Attributes$y2('14.83')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$link = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'link',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$link2 = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'link-2',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M15 7h3a5 5 0 0 1 5 5 5 5 0 0 1-5 5h-3m-6 0H6a5 5 0 0 1-5-5 5 5 0 0 1 5-5h3')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('8'),
					$elm$svg$Svg$Attributes$y1('12'),
					$elm$svg$Svg$Attributes$x2('16'),
					$elm$svg$Svg$Attributes$y2('12')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$linkedin = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'linkedin',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M16 8a6 6 0 0 1 6 6v7h-4v-7a2 2 0 0 0-2-2 2 2 0 0 0-2 2v7h-4v-7a6 6 0 0 1 6-6z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('2'),
					$elm$svg$Svg$Attributes$y('9'),
					$elm$svg$Svg$Attributes$width('4'),
					$elm$svg$Svg$Attributes$height('12')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('4'),
					$elm$svg$Svg$Attributes$cy('4'),
					$elm$svg$Svg$Attributes$r('2')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$list = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'list',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('8'),
					$elm$svg$Svg$Attributes$y1('6'),
					$elm$svg$Svg$Attributes$x2('21'),
					$elm$svg$Svg$Attributes$y2('6')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('8'),
					$elm$svg$Svg$Attributes$y1('12'),
					$elm$svg$Svg$Attributes$x2('21'),
					$elm$svg$Svg$Attributes$y2('12')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('8'),
					$elm$svg$Svg$Attributes$y1('18'),
					$elm$svg$Svg$Attributes$x2('21'),
					$elm$svg$Svg$Attributes$y2('18')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('3'),
					$elm$svg$Svg$Attributes$y1('6'),
					$elm$svg$Svg$Attributes$x2('3.01'),
					$elm$svg$Svg$Attributes$y2('6')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('3'),
					$elm$svg$Svg$Attributes$y1('12'),
					$elm$svg$Svg$Attributes$x2('3.01'),
					$elm$svg$Svg$Attributes$y2('12')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('3'),
					$elm$svg$Svg$Attributes$y1('18'),
					$elm$svg$Svg$Attributes$x2('3.01'),
					$elm$svg$Svg$Attributes$y2('18')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$loader = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'loader',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('2'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('6')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('18'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('22')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('4.93'),
					$elm$svg$Svg$Attributes$y1('4.93'),
					$elm$svg$Svg$Attributes$x2('7.76'),
					$elm$svg$Svg$Attributes$y2('7.76')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('16.24'),
					$elm$svg$Svg$Attributes$y1('16.24'),
					$elm$svg$Svg$Attributes$x2('19.07'),
					$elm$svg$Svg$Attributes$y2('19.07')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('2'),
					$elm$svg$Svg$Attributes$y1('12'),
					$elm$svg$Svg$Attributes$x2('6'),
					$elm$svg$Svg$Attributes$y2('12')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('18'),
					$elm$svg$Svg$Attributes$y1('12'),
					$elm$svg$Svg$Attributes$x2('22'),
					$elm$svg$Svg$Attributes$y2('12')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('4.93'),
					$elm$svg$Svg$Attributes$y1('19.07'),
					$elm$svg$Svg$Attributes$x2('7.76'),
					$elm$svg$Svg$Attributes$y2('16.24')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('16.24'),
					$elm$svg$Svg$Attributes$y1('7.76'),
					$elm$svg$Svg$Attributes$x2('19.07'),
					$elm$svg$Svg$Attributes$y2('4.93')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$lock = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'lock',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('3'),
					$elm$svg$Svg$Attributes$y('11'),
					$elm$svg$Svg$Attributes$width('18'),
					$elm$svg$Svg$Attributes$height('11'),
					$elm$svg$Svg$Attributes$rx('2'),
					$elm$svg$Svg$Attributes$ry('2')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M7 11V7a5 5 0 0 1 10 0v4')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$logIn = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'log-in',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('10 17 15 12 10 7')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('15'),
					$elm$svg$Svg$Attributes$y1('12'),
					$elm$svg$Svg$Attributes$x2('3'),
					$elm$svg$Svg$Attributes$y2('12')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$logOut = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'log-out',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('16 17 21 12 16 7')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('21'),
					$elm$svg$Svg$Attributes$y1('12'),
					$elm$svg$Svg$Attributes$x2('9'),
					$elm$svg$Svg$Attributes$y2('12')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$mail = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'mail',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('22,6 12,13 2,6')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$map = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'map',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polygon,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('1 6 1 22 8 18 16 22 23 18 23 2 16 6 8 2 1 6')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('8'),
					$elm$svg$Svg$Attributes$y1('2'),
					$elm$svg$Svg$Attributes$x2('8'),
					$elm$svg$Svg$Attributes$y2('18')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('16'),
					$elm$svg$Svg$Attributes$y1('6'),
					$elm$svg$Svg$Attributes$x2('16'),
					$elm$svg$Svg$Attributes$y2('22')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$mapPin = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'map-pin',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('10'),
					$elm$svg$Svg$Attributes$r('3')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$maximize = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'maximize',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M8 3H5a2 2 0 0 0-2 2v3m18 0V5a2 2 0 0 0-2-2h-3m0 18h3a2 2 0 0 0 2-2v-3M3 16v3a2 2 0 0 0 2 2h3')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$maximize2 = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'maximize-2',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('15 3 21 3 21 9')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('9 21 3 21 3 15')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('21'),
					$elm$svg$Svg$Attributes$y1('3'),
					$elm$svg$Svg$Attributes$x2('14'),
					$elm$svg$Svg$Attributes$y2('10')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('3'),
					$elm$svg$Svg$Attributes$y1('21'),
					$elm$svg$Svg$Attributes$x2('10'),
					$elm$svg$Svg$Attributes$y2('14')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$meh = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'meh',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('10')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('8'),
					$elm$svg$Svg$Attributes$y1('15'),
					$elm$svg$Svg$Attributes$x2('16'),
					$elm$svg$Svg$Attributes$y2('15')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('9'),
					$elm$svg$Svg$Attributes$y1('9'),
					$elm$svg$Svg$Attributes$x2('9.01'),
					$elm$svg$Svg$Attributes$y2('9')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('15'),
					$elm$svg$Svg$Attributes$y1('9'),
					$elm$svg$Svg$Attributes$x2('15.01'),
					$elm$svg$Svg$Attributes$y2('9')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$menu = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'menu',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('3'),
					$elm$svg$Svg$Attributes$y1('12'),
					$elm$svg$Svg$Attributes$x2('21'),
					$elm$svg$Svg$Attributes$y2('12')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('3'),
					$elm$svg$Svg$Attributes$y1('6'),
					$elm$svg$Svg$Attributes$x2('21'),
					$elm$svg$Svg$Attributes$y2('6')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('3'),
					$elm$svg$Svg$Attributes$y1('18'),
					$elm$svg$Svg$Attributes$x2('21'),
					$elm$svg$Svg$Attributes$y2('18')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$messageCircle = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'message-circle',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M21 11.5a8.38 8.38 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.38 8.38 0 0 1-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 0 1-.9-3.8 8.5 8.5 0 0 1 4.7-7.6 8.38 8.38 0 0 1 3.8-.9h.5a8.48 8.48 0 0 1 8 8v.5z')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$messageSquare = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'message-square',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$mic = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'mic',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M12 1a3 3 0 0 0-3 3v8a3 3 0 0 0 6 0V4a3 3 0 0 0-3-3z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M19 10v2a7 7 0 0 1-14 0v-2')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('19'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('23')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('8'),
					$elm$svg$Svg$Attributes$y1('23'),
					$elm$svg$Svg$Attributes$x2('16'),
					$elm$svg$Svg$Attributes$y2('23')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$micOff = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'mic-off',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('1'),
					$elm$svg$Svg$Attributes$y1('1'),
					$elm$svg$Svg$Attributes$x2('23'),
					$elm$svg$Svg$Attributes$y2('23')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M9 9v3a3 3 0 0 0 5.12 2.12M15 9.34V4a3 3 0 0 0-5.94-.6')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M17 16.95A7 7 0 0 1 5 12v-2m14 0v2a7 7 0 0 1-.11 1.23')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('19'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('23')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('8'),
					$elm$svg$Svg$Attributes$y1('23'),
					$elm$svg$Svg$Attributes$x2('16'),
					$elm$svg$Svg$Attributes$y2('23')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$minimize = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'minimize',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M8 3v3a2 2 0 0 1-2 2H3m18 0h-3a2 2 0 0 1-2-2V3m0 18v-3a2 2 0 0 1 2-2h3M3 16h3a2 2 0 0 1 2 2v3')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$minimize2 = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'minimize-2',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('4 14 10 14 10 20')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('20 10 14 10 14 4')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('14'),
					$elm$svg$Svg$Attributes$y1('10'),
					$elm$svg$Svg$Attributes$x2('21'),
					$elm$svg$Svg$Attributes$y2('3')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('3'),
					$elm$svg$Svg$Attributes$y1('21'),
					$elm$svg$Svg$Attributes$x2('10'),
					$elm$svg$Svg$Attributes$y2('14')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$minus = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'minus',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('5'),
					$elm$svg$Svg$Attributes$y1('12'),
					$elm$svg$Svg$Attributes$x2('19'),
					$elm$svg$Svg$Attributes$y2('12')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$minusCircle = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'minus-circle',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('10')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('8'),
					$elm$svg$Svg$Attributes$y1('12'),
					$elm$svg$Svg$Attributes$x2('16'),
					$elm$svg$Svg$Attributes$y2('12')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$minusSquare = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'minus-square',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('3'),
					$elm$svg$Svg$Attributes$y('3'),
					$elm$svg$Svg$Attributes$width('18'),
					$elm$svg$Svg$Attributes$height('18'),
					$elm$svg$Svg$Attributes$rx('2'),
					$elm$svg$Svg$Attributes$ry('2')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('8'),
					$elm$svg$Svg$Attributes$y1('12'),
					$elm$svg$Svg$Attributes$x2('16'),
					$elm$svg$Svg$Attributes$y2('12')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$monitor = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'monitor',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('2'),
					$elm$svg$Svg$Attributes$y('3'),
					$elm$svg$Svg$Attributes$width('20'),
					$elm$svg$Svg$Attributes$height('14'),
					$elm$svg$Svg$Attributes$rx('2'),
					$elm$svg$Svg$Attributes$ry('2')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('8'),
					$elm$svg$Svg$Attributes$y1('21'),
					$elm$svg$Svg$Attributes$x2('16'),
					$elm$svg$Svg$Attributes$y2('21')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('17'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('21')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$moon = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'moon',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$moreHorizontal = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'more-horizontal',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('1')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('19'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('1')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('5'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('1')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$moreVertical = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'more-vertical',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('1')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('5'),
					$elm$svg$Svg$Attributes$r('1')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('19'),
					$elm$svg$Svg$Attributes$r('1')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$mousePointer = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'mouse-pointer',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M3 3l7.07 16.97 2.51-7.39 7.39-2.51L3 3z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M13 13l6 6')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$move = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'move',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('5 9 2 12 5 15')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('9 5 12 2 15 5')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('15 19 12 22 9 19')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('19 9 22 12 19 15')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('2'),
					$elm$svg$Svg$Attributes$y1('12'),
					$elm$svg$Svg$Attributes$x2('22'),
					$elm$svg$Svg$Attributes$y2('12')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('2'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('22')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$music = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'music',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M9 18V5l12-2v13')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('6'),
					$elm$svg$Svg$Attributes$cy('18'),
					$elm$svg$Svg$Attributes$r('3')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('18'),
					$elm$svg$Svg$Attributes$cy('16'),
					$elm$svg$Svg$Attributes$r('3')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$navigation = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'navigation',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polygon,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('3 11 22 2 13 21 11 13 3 11')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$navigation2 = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'navigation-2',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polygon,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('12 2 19 21 12 17 5 21 12 2')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$octagon = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'octagon',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polygon,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('7.86 2 16.14 2 22 7.86 22 16.14 16.14 22 7.86 22 2 16.14 2 7.86 7.86 2')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$package = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'package',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('16.5'),
					$elm$svg$Svg$Attributes$y1('9.4'),
					$elm$svg$Svg$Attributes$x2('7.5'),
					$elm$svg$Svg$Attributes$y2('4.21')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('3.27 6.96 12 12.01 20.73 6.96')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('22.08'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('12')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$paperclip = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'paperclip',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M21.44 11.05l-9.19 9.19a6 6 0 0 1-8.49-8.49l9.19-9.19a4 4 0 0 1 5.66 5.66l-9.2 9.19a2 2 0 0 1-2.83-2.83l8.49-8.48')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$pause = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'pause',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('6'),
					$elm$svg$Svg$Attributes$y('4'),
					$elm$svg$Svg$Attributes$width('4'),
					$elm$svg$Svg$Attributes$height('16')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('14'),
					$elm$svg$Svg$Attributes$y('4'),
					$elm$svg$Svg$Attributes$width('4'),
					$elm$svg$Svg$Attributes$height('16')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$pauseCircle = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'pause-circle',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('10')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('10'),
					$elm$svg$Svg$Attributes$y1('15'),
					$elm$svg$Svg$Attributes$x2('10'),
					$elm$svg$Svg$Attributes$y2('9')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('14'),
					$elm$svg$Svg$Attributes$y1('15'),
					$elm$svg$Svg$Attributes$x2('14'),
					$elm$svg$Svg$Attributes$y2('9')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$penTool = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'pen-tool',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M12 19l7-7 3 3-7 7-3-3z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M18 13l-1.5-7.5L2 2l3.5 14.5L13 18l5-5z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M2 2l7.586 7.586')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('11'),
					$elm$svg$Svg$Attributes$cy('11'),
					$elm$svg$Svg$Attributes$r('2')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$percent = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'percent',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('19'),
					$elm$svg$Svg$Attributes$y1('5'),
					$elm$svg$Svg$Attributes$x2('5'),
					$elm$svg$Svg$Attributes$y2('19')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('6.5'),
					$elm$svg$Svg$Attributes$cy('6.5'),
					$elm$svg$Svg$Attributes$r('2.5')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('17.5'),
					$elm$svg$Svg$Attributes$cy('17.5'),
					$elm$svg$Svg$Attributes$r('2.5')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$phone = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'phone',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$phoneCall = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'phone-call',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M15.05 5A5 5 0 0 1 19 8.95M15.05 1A9 9 0 0 1 23 8.94m-1 7.98v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$phoneForwarded = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'phone-forwarded',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('19 1 23 5 19 9')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('15'),
					$elm$svg$Svg$Attributes$y1('5'),
					$elm$svg$Svg$Attributes$x2('23'),
					$elm$svg$Svg$Attributes$y2('5')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$phoneIncoming = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'phone-incoming',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('16 2 16 8 22 8')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('23'),
					$elm$svg$Svg$Attributes$y1('1'),
					$elm$svg$Svg$Attributes$x2('16'),
					$elm$svg$Svg$Attributes$y2('8')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$phoneMissed = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'phone-missed',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('23'),
					$elm$svg$Svg$Attributes$y1('1'),
					$elm$svg$Svg$Attributes$x2('17'),
					$elm$svg$Svg$Attributes$y2('7')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('17'),
					$elm$svg$Svg$Attributes$y1('1'),
					$elm$svg$Svg$Attributes$x2('23'),
					$elm$svg$Svg$Attributes$y2('7')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$phoneOff = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'phone-off',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M10.68 13.31a16 16 0 0 0 3.41 2.6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7 2 2 0 0 1 1.72 2v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.42 19.42 0 0 1-3.33-2.67m-2.67-3.34a19.79 19.79 0 0 1-3.07-8.63A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('23'),
					$elm$svg$Svg$Attributes$y1('1'),
					$elm$svg$Svg$Attributes$x2('1'),
					$elm$svg$Svg$Attributes$y2('23')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$phoneOutgoing = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'phone-outgoing',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('23 7 23 1 17 1')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('16'),
					$elm$svg$Svg$Attributes$y1('8'),
					$elm$svg$Svg$Attributes$x2('23'),
					$elm$svg$Svg$Attributes$y2('1')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$pieChart = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'pie-chart',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M21.21 15.89A10 10 0 1 1 8 2.83')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M22 12A10 10 0 0 0 12 2v10z')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$play = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'play',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polygon,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('5 3 19 12 5 21 5 3')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$playCircle = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'play-circle',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('10')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polygon,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('10 8 16 12 10 16 10 8')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$plus = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'plus',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('5'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('19')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('5'),
					$elm$svg$Svg$Attributes$y1('12'),
					$elm$svg$Svg$Attributes$x2('19'),
					$elm$svg$Svg$Attributes$y2('12')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$plusCircle = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'plus-circle',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('10')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('8'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('16')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('8'),
					$elm$svg$Svg$Attributes$y1('12'),
					$elm$svg$Svg$Attributes$x2('16'),
					$elm$svg$Svg$Attributes$y2('12')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$plusSquare = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'plus-square',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('3'),
					$elm$svg$Svg$Attributes$y('3'),
					$elm$svg$Svg$Attributes$width('18'),
					$elm$svg$Svg$Attributes$height('18'),
					$elm$svg$Svg$Attributes$rx('2'),
					$elm$svg$Svg$Attributes$ry('2')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('8'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('16')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('8'),
					$elm$svg$Svg$Attributes$y1('12'),
					$elm$svg$Svg$Attributes$x2('16'),
					$elm$svg$Svg$Attributes$y2('12')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$pocket = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'pocket',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M4 3h16a2 2 0 0 1 2 2v6a10 10 0 0 1-10 10A10 10 0 0 1 2 11V5a2 2 0 0 1 2-2z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('8 10 12 14 16 10')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$power = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'power',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M18.36 6.64a9 9 0 1 1-12.73 0')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('2'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('12')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$printer = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'printer',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('6 9 6 2 18 2 18 9')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('6'),
					$elm$svg$Svg$Attributes$y('14'),
					$elm$svg$Svg$Attributes$width('12'),
					$elm$svg$Svg$Attributes$height('8')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$radio = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'radio',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('2')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M16.24 7.76a6 6 0 0 1 0 8.49m-8.48-.01a6 6 0 0 1 0-8.49m11.31-2.82a10 10 0 0 1 0 14.14m-14.14 0a10 10 0 0 1 0-14.14')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$refreshCcw = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'refresh-ccw',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('1 4 1 10 7 10')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('23 20 23 14 17 14')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M20.49 9A9 9 0 0 0 5.64 5.64L1 10m22 4l-4.64 4.36A9 9 0 0 1 3.51 15')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$refreshCw = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'refresh-cw',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('23 4 23 10 17 10')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('1 20 1 14 7 14')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$repeat = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'repeat',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('17 1 21 5 17 9')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M3 11V9a4 4 0 0 1 4-4h14')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('7 23 3 19 7 15')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M21 13v2a4 4 0 0 1-4 4H3')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$rewind = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'rewind',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polygon,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('11 19 2 12 11 5 11 19')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polygon,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('22 19 13 12 22 5 22 19')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$rotateCcw = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'rotate-ccw',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('1 4 1 10 7 10')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M3.51 15a9 9 0 1 0 2.13-9.36L1 10')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$rotateCw = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'rotate-cw',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('23 4 23 10 17 10')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M20.49 15a9 9 0 1 1-2.12-9.36L23 10')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$rss = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'rss',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M4 11a9 9 0 0 1 9 9')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M4 4a16 16 0 0 1 16 16')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('5'),
					$elm$svg$Svg$Attributes$cy('19'),
					$elm$svg$Svg$Attributes$r('1')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$save = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'save',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('17 21 17 13 7 13 7 21')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('7 3 7 8 15 8')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$scissors = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'scissors',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('6'),
					$elm$svg$Svg$Attributes$cy('6'),
					$elm$svg$Svg$Attributes$r('3')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('6'),
					$elm$svg$Svg$Attributes$cy('18'),
					$elm$svg$Svg$Attributes$r('3')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('20'),
					$elm$svg$Svg$Attributes$y1('4'),
					$elm$svg$Svg$Attributes$x2('8.12'),
					$elm$svg$Svg$Attributes$y2('15.88')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('14.47'),
					$elm$svg$Svg$Attributes$y1('14.48'),
					$elm$svg$Svg$Attributes$x2('20'),
					$elm$svg$Svg$Attributes$y2('20')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('8.12'),
					$elm$svg$Svg$Attributes$y1('8.12'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('12')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$search = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'search',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('11'),
					$elm$svg$Svg$Attributes$cy('11'),
					$elm$svg$Svg$Attributes$r('8')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('21'),
					$elm$svg$Svg$Attributes$y1('21'),
					$elm$svg$Svg$Attributes$x2('16.65'),
					$elm$svg$Svg$Attributes$y2('16.65')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$send = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'send',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('22'),
					$elm$svg$Svg$Attributes$y1('2'),
					$elm$svg$Svg$Attributes$x2('11'),
					$elm$svg$Svg$Attributes$y2('13')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polygon,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('22 2 15 22 11 13 2 9 22 2')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$server = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'server',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('2'),
					$elm$svg$Svg$Attributes$y('2'),
					$elm$svg$Svg$Attributes$width('20'),
					$elm$svg$Svg$Attributes$height('8'),
					$elm$svg$Svg$Attributes$rx('2'),
					$elm$svg$Svg$Attributes$ry('2')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('2'),
					$elm$svg$Svg$Attributes$y('14'),
					$elm$svg$Svg$Attributes$width('20'),
					$elm$svg$Svg$Attributes$height('8'),
					$elm$svg$Svg$Attributes$rx('2'),
					$elm$svg$Svg$Attributes$ry('2')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('6'),
					$elm$svg$Svg$Attributes$y1('6'),
					$elm$svg$Svg$Attributes$x2('6.01'),
					$elm$svg$Svg$Attributes$y2('6')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('6'),
					$elm$svg$Svg$Attributes$y1('18'),
					$elm$svg$Svg$Attributes$x2('6.01'),
					$elm$svg$Svg$Attributes$y2('18')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$settings = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'settings',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('3')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$share = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'share',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M4 12v8a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-8')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('16 6 12 2 8 6')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('2'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('15')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$share2 = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'share-2',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('18'),
					$elm$svg$Svg$Attributes$cy('5'),
					$elm$svg$Svg$Attributes$r('3')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('6'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('3')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('18'),
					$elm$svg$Svg$Attributes$cy('19'),
					$elm$svg$Svg$Attributes$r('3')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('8.59'),
					$elm$svg$Svg$Attributes$y1('13.51'),
					$elm$svg$Svg$Attributes$x2('15.42'),
					$elm$svg$Svg$Attributes$y2('17.49')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('15.41'),
					$elm$svg$Svg$Attributes$y1('6.51'),
					$elm$svg$Svg$Attributes$x2('8.59'),
					$elm$svg$Svg$Attributes$y2('10.49')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$shield = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'shield',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$shieldOff = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'shield-off',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M19.69 14a6.9 6.9 0 0 0 .31-2V5l-8-3-3.16 1.18')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M4.73 4.73L4 5v7c0 6 8 10 8 10a20.29 20.29 0 0 0 5.62-4.38')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('1'),
					$elm$svg$Svg$Attributes$y1('1'),
					$elm$svg$Svg$Attributes$x2('23'),
					$elm$svg$Svg$Attributes$y2('23')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$shoppingBag = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'shopping-bag',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('3'),
					$elm$svg$Svg$Attributes$y1('6'),
					$elm$svg$Svg$Attributes$x2('21'),
					$elm$svg$Svg$Attributes$y2('6')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M16 10a4 4 0 0 1-8 0')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$shoppingCart = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'shopping-cart',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('9'),
					$elm$svg$Svg$Attributes$cy('21'),
					$elm$svg$Svg$Attributes$r('1')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('20'),
					$elm$svg$Svg$Attributes$cy('21'),
					$elm$svg$Svg$Attributes$r('1')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$shuffle = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'shuffle',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('16 3 21 3 21 8')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('4'),
					$elm$svg$Svg$Attributes$y1('20'),
					$elm$svg$Svg$Attributes$x2('21'),
					$elm$svg$Svg$Attributes$y2('3')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('21 16 21 21 16 21')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('15'),
					$elm$svg$Svg$Attributes$y1('15'),
					$elm$svg$Svg$Attributes$x2('21'),
					$elm$svg$Svg$Attributes$y2('21')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('4'),
					$elm$svg$Svg$Attributes$y1('4'),
					$elm$svg$Svg$Attributes$x2('9'),
					$elm$svg$Svg$Attributes$y2('9')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$sidebar = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'sidebar',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('3'),
					$elm$svg$Svg$Attributes$y('3'),
					$elm$svg$Svg$Attributes$width('18'),
					$elm$svg$Svg$Attributes$height('18'),
					$elm$svg$Svg$Attributes$rx('2'),
					$elm$svg$Svg$Attributes$ry('2')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('9'),
					$elm$svg$Svg$Attributes$y1('3'),
					$elm$svg$Svg$Attributes$x2('9'),
					$elm$svg$Svg$Attributes$y2('21')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$skipBack = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'skip-back',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polygon,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('19 20 9 12 19 4 19 20')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('5'),
					$elm$svg$Svg$Attributes$y1('19'),
					$elm$svg$Svg$Attributes$x2('5'),
					$elm$svg$Svg$Attributes$y2('5')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$skipForward = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'skip-forward',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polygon,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('5 4 15 12 5 20 5 4')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('19'),
					$elm$svg$Svg$Attributes$y1('5'),
					$elm$svg$Svg$Attributes$x2('19'),
					$elm$svg$Svg$Attributes$y2('19')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$slack = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'slack',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M14.5 10c-.83 0-1.5-.67-1.5-1.5v-5c0-.83.67-1.5 1.5-1.5s1.5.67 1.5 1.5v5c0 .83-.67 1.5-1.5 1.5z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M20.5 10H19V8.5c0-.83.67-1.5 1.5-1.5s1.5.67 1.5 1.5-.67 1.5-1.5 1.5z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M9.5 14c.83 0 1.5.67 1.5 1.5v5c0 .83-.67 1.5-1.5 1.5S8 21.33 8 20.5v-5c0-.83.67-1.5 1.5-1.5z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M3.5 14H5v1.5c0 .83-.67 1.5-1.5 1.5S2 16.33 2 15.5 2.67 14 3.5 14z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M14 14.5c0-.83.67-1.5 1.5-1.5h5c.83 0 1.5.67 1.5 1.5s-.67 1.5-1.5 1.5h-5c-.83 0-1.5-.67-1.5-1.5z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M15.5 19H14v1.5c0 .83.67 1.5 1.5 1.5s1.5-.67 1.5-1.5-.67-1.5-1.5-1.5z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M10 9.5C10 8.67 9.33 8 8.5 8h-5C2.67 8 2 8.67 2 9.5S2.67 11 3.5 11h5c.83 0 1.5-.67 1.5-1.5z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M8.5 5H10V3.5C10 2.67 9.33 2 8.5 2S7 2.67 7 3.5 7.67 5 8.5 5z')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$slash = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'slash',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('10')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('4.93'),
					$elm$svg$Svg$Attributes$y1('4.93'),
					$elm$svg$Svg$Attributes$x2('19.07'),
					$elm$svg$Svg$Attributes$y2('19.07')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$sliders = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'sliders',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('4'),
					$elm$svg$Svg$Attributes$y1('21'),
					$elm$svg$Svg$Attributes$x2('4'),
					$elm$svg$Svg$Attributes$y2('14')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('4'),
					$elm$svg$Svg$Attributes$y1('10'),
					$elm$svg$Svg$Attributes$x2('4'),
					$elm$svg$Svg$Attributes$y2('3')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('21'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('12')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('8'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('3')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('20'),
					$elm$svg$Svg$Attributes$y1('21'),
					$elm$svg$Svg$Attributes$x2('20'),
					$elm$svg$Svg$Attributes$y2('16')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('20'),
					$elm$svg$Svg$Attributes$y1('12'),
					$elm$svg$Svg$Attributes$x2('20'),
					$elm$svg$Svg$Attributes$y2('3')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('1'),
					$elm$svg$Svg$Attributes$y1('14'),
					$elm$svg$Svg$Attributes$x2('7'),
					$elm$svg$Svg$Attributes$y2('14')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('9'),
					$elm$svg$Svg$Attributes$y1('8'),
					$elm$svg$Svg$Attributes$x2('15'),
					$elm$svg$Svg$Attributes$y2('8')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('17'),
					$elm$svg$Svg$Attributes$y1('16'),
					$elm$svg$Svg$Attributes$x2('23'),
					$elm$svg$Svg$Attributes$y2('16')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$smartphone = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'smartphone',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('5'),
					$elm$svg$Svg$Attributes$y('2'),
					$elm$svg$Svg$Attributes$width('14'),
					$elm$svg$Svg$Attributes$height('20'),
					$elm$svg$Svg$Attributes$rx('2'),
					$elm$svg$Svg$Attributes$ry('2')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('18'),
					$elm$svg$Svg$Attributes$x2('12.01'),
					$elm$svg$Svg$Attributes$y2('18')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$smile = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'smile',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('10')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M8 14s1.5 2 4 2 4-2 4-2')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('9'),
					$elm$svg$Svg$Attributes$y1('9'),
					$elm$svg$Svg$Attributes$x2('9.01'),
					$elm$svg$Svg$Attributes$y2('9')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('15'),
					$elm$svg$Svg$Attributes$y1('9'),
					$elm$svg$Svg$Attributes$x2('15.01'),
					$elm$svg$Svg$Attributes$y2('9')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$speaker = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'speaker',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('4'),
					$elm$svg$Svg$Attributes$y('2'),
					$elm$svg$Svg$Attributes$width('16'),
					$elm$svg$Svg$Attributes$height('20'),
					$elm$svg$Svg$Attributes$rx('2'),
					$elm$svg$Svg$Attributes$ry('2')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('14'),
					$elm$svg$Svg$Attributes$r('4')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('6'),
					$elm$svg$Svg$Attributes$x2('12.01'),
					$elm$svg$Svg$Attributes$y2('6')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$square = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'square',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('3'),
					$elm$svg$Svg$Attributes$y('3'),
					$elm$svg$Svg$Attributes$width('18'),
					$elm$svg$Svg$Attributes$height('18'),
					$elm$svg$Svg$Attributes$rx('2'),
					$elm$svg$Svg$Attributes$ry('2')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$star = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'star',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polygon,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$stopCircle = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'stop-circle',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('10')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('9'),
					$elm$svg$Svg$Attributes$y('9'),
					$elm$svg$Svg$Attributes$width('6'),
					$elm$svg$Svg$Attributes$height('6')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$sun = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'sun',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('5')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('1'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('3')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('21'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('23')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('4.22'),
					$elm$svg$Svg$Attributes$y1('4.22'),
					$elm$svg$Svg$Attributes$x2('5.64'),
					$elm$svg$Svg$Attributes$y2('5.64')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('18.36'),
					$elm$svg$Svg$Attributes$y1('18.36'),
					$elm$svg$Svg$Attributes$x2('19.78'),
					$elm$svg$Svg$Attributes$y2('19.78')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('1'),
					$elm$svg$Svg$Attributes$y1('12'),
					$elm$svg$Svg$Attributes$x2('3'),
					$elm$svg$Svg$Attributes$y2('12')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('21'),
					$elm$svg$Svg$Attributes$y1('12'),
					$elm$svg$Svg$Attributes$x2('23'),
					$elm$svg$Svg$Attributes$y2('12')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('4.22'),
					$elm$svg$Svg$Attributes$y1('19.78'),
					$elm$svg$Svg$Attributes$x2('5.64'),
					$elm$svg$Svg$Attributes$y2('18.36')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('18.36'),
					$elm$svg$Svg$Attributes$y1('5.64'),
					$elm$svg$Svg$Attributes$x2('19.78'),
					$elm$svg$Svg$Attributes$y2('4.22')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$sunrise = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'sunrise',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M17 18a5 5 0 0 0-10 0')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('2'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('9')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('4.22'),
					$elm$svg$Svg$Attributes$y1('10.22'),
					$elm$svg$Svg$Attributes$x2('5.64'),
					$elm$svg$Svg$Attributes$y2('11.64')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('1'),
					$elm$svg$Svg$Attributes$y1('18'),
					$elm$svg$Svg$Attributes$x2('3'),
					$elm$svg$Svg$Attributes$y2('18')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('21'),
					$elm$svg$Svg$Attributes$y1('18'),
					$elm$svg$Svg$Attributes$x2('23'),
					$elm$svg$Svg$Attributes$y2('18')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('18.36'),
					$elm$svg$Svg$Attributes$y1('11.64'),
					$elm$svg$Svg$Attributes$x2('19.78'),
					$elm$svg$Svg$Attributes$y2('10.22')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('23'),
					$elm$svg$Svg$Attributes$y1('22'),
					$elm$svg$Svg$Attributes$x2('1'),
					$elm$svg$Svg$Attributes$y2('22')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('8 6 12 2 16 6')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$sunset = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'sunset',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M17 18a5 5 0 0 0-10 0')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('9'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('2')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('4.22'),
					$elm$svg$Svg$Attributes$y1('10.22'),
					$elm$svg$Svg$Attributes$x2('5.64'),
					$elm$svg$Svg$Attributes$y2('11.64')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('1'),
					$elm$svg$Svg$Attributes$y1('18'),
					$elm$svg$Svg$Attributes$x2('3'),
					$elm$svg$Svg$Attributes$y2('18')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('21'),
					$elm$svg$Svg$Attributes$y1('18'),
					$elm$svg$Svg$Attributes$x2('23'),
					$elm$svg$Svg$Attributes$y2('18')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('18.36'),
					$elm$svg$Svg$Attributes$y1('11.64'),
					$elm$svg$Svg$Attributes$x2('19.78'),
					$elm$svg$Svg$Attributes$y2('10.22')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('23'),
					$elm$svg$Svg$Attributes$y1('22'),
					$elm$svg$Svg$Attributes$x2('1'),
					$elm$svg$Svg$Attributes$y2('22')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('16 5 12 9 8 5')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$tablet = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'tablet',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('4'),
					$elm$svg$Svg$Attributes$y('2'),
					$elm$svg$Svg$Attributes$width('16'),
					$elm$svg$Svg$Attributes$height('20'),
					$elm$svg$Svg$Attributes$rx('2'),
					$elm$svg$Svg$Attributes$ry('2')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('18'),
					$elm$svg$Svg$Attributes$x2('12.01'),
					$elm$svg$Svg$Attributes$y2('18')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$tag = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'tag',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('7'),
					$elm$svg$Svg$Attributes$y1('7'),
					$elm$svg$Svg$Attributes$x2('7.01'),
					$elm$svg$Svg$Attributes$y2('7')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$target = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'target',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('10')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('6')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('2')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$terminal = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'terminal',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('4 17 10 11 4 5')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('19'),
					$elm$svg$Svg$Attributes$x2('20'),
					$elm$svg$Svg$Attributes$y2('19')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$thermometer = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'thermometer',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M14 14.76V3.5a2.5 2.5 0 0 0-5 0v11.26a4.5 4.5 0 1 0 5 0z')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$thumbsDown = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'thumbs-down',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M10 15v4a3 3 0 0 0 3 3l4-9V2H5.72a2 2 0 0 0-2 1.7l-1.38 9a2 2 0 0 0 2 2.3zm7-13h2.67A2.31 2.31 0 0 1 22 4v7a2.31 2.31 0 0 1-2.33 2H17')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$thumbsUp = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'thumbs-up',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M14 9V5a3 3 0 0 0-3-3l-4 9v11h11.28a2 2 0 0 0 2-1.7l1.38-9a2 2 0 0 0-2-2.3zM7 22H4a2 2 0 0 1-2-2v-7a2 2 0 0 1 2-2h3')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$toggleLeft = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'toggle-left',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('1'),
					$elm$svg$Svg$Attributes$y('5'),
					$elm$svg$Svg$Attributes$width('22'),
					$elm$svg$Svg$Attributes$height('14'),
					$elm$svg$Svg$Attributes$rx('7'),
					$elm$svg$Svg$Attributes$ry('7')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('8'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('3')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$toggleRight = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'toggle-right',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('1'),
					$elm$svg$Svg$Attributes$y('5'),
					$elm$svg$Svg$Attributes$width('22'),
					$elm$svg$Svg$Attributes$height('14'),
					$elm$svg$Svg$Attributes$rx('7'),
					$elm$svg$Svg$Attributes$ry('7')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('16'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('3')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$tool = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'tool',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$trash = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'trash',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('3 6 5 6 21 6')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$trash2 = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'trash-2',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('3 6 5 6 21 6')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('10'),
					$elm$svg$Svg$Attributes$y1('11'),
					$elm$svg$Svg$Attributes$x2('10'),
					$elm$svg$Svg$Attributes$y2('17')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('14'),
					$elm$svg$Svg$Attributes$y1('11'),
					$elm$svg$Svg$Attributes$x2('14'),
					$elm$svg$Svg$Attributes$y2('17')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$trello = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'trello',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('3'),
					$elm$svg$Svg$Attributes$y('3'),
					$elm$svg$Svg$Attributes$width('18'),
					$elm$svg$Svg$Attributes$height('18'),
					$elm$svg$Svg$Attributes$rx('2'),
					$elm$svg$Svg$Attributes$ry('2')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('7'),
					$elm$svg$Svg$Attributes$y('7'),
					$elm$svg$Svg$Attributes$width('3'),
					$elm$svg$Svg$Attributes$height('9')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('14'),
					$elm$svg$Svg$Attributes$y('7'),
					$elm$svg$Svg$Attributes$width('3'),
					$elm$svg$Svg$Attributes$height('5')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$trendingDown = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'trending-down',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('23 18 13.5 8.5 8.5 13.5 1 6')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('17 18 23 18 23 12')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$trendingUp = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'trending-up',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('23 6 13.5 15.5 8.5 10.5 1 18')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('17 6 23 6 23 12')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$triangle = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'triangle',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$truck = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'truck',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('1'),
					$elm$svg$Svg$Attributes$y('3'),
					$elm$svg$Svg$Attributes$width('15'),
					$elm$svg$Svg$Attributes$height('13')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polygon,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('16 8 20 8 23 11 23 16 16 16 16 8')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('5.5'),
					$elm$svg$Svg$Attributes$cy('18.5'),
					$elm$svg$Svg$Attributes$r('2.5')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('18.5'),
					$elm$svg$Svg$Attributes$cy('18.5'),
					$elm$svg$Svg$Attributes$r('2.5')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$tv = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'tv',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('2'),
					$elm$svg$Svg$Attributes$y('7'),
					$elm$svg$Svg$Attributes$width('20'),
					$elm$svg$Svg$Attributes$height('15'),
					$elm$svg$Svg$Attributes$rx('2'),
					$elm$svg$Svg$Attributes$ry('2')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('17 2 12 7 7 2')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$twitch = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'twitch',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M21 2H3v16h5v4l4-4h5l4-4V2zm-10 9V7m5 4V7')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$twitter = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'twitter',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M23 3a10.9 10.9 0 0 1-3.14 1.53 4.48 4.48 0 0 0-7.86 3v1A10.66 10.66 0 0 1 3 4s-4 9 5 13a11.64 11.64 0 0 1-7 2c9 5 20 0 20-11.5a4.5 4.5 0 0 0-.08-.83A7.72 7.72 0 0 0 23 3z')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$type_ = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'type',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('4 7 4 4 20 4 20 7')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('9'),
					$elm$svg$Svg$Attributes$y1('20'),
					$elm$svg$Svg$Attributes$x2('15'),
					$elm$svg$Svg$Attributes$y2('20')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('4'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('20')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$umbrella = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'umbrella',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M23 12a11.05 11.05 0 0 0-22 0zm-5 7a3 3 0 0 1-6 0v-7')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$underline = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'underline',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M6 3v7a6 6 0 0 0 6 6 6 6 0 0 0 6-6V3')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('4'),
					$elm$svg$Svg$Attributes$y1('21'),
					$elm$svg$Svg$Attributes$x2('20'),
					$elm$svg$Svg$Attributes$y2('21')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$unlock = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'unlock',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('3'),
					$elm$svg$Svg$Attributes$y('11'),
					$elm$svg$Svg$Attributes$width('18'),
					$elm$svg$Svg$Attributes$height('11'),
					$elm$svg$Svg$Attributes$rx('2'),
					$elm$svg$Svg$Attributes$ry('2')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M7 11V7a5 5 0 0 1 9.9-1')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$upload = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'upload',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('17 8 12 3 7 8')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('3'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('15')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$uploadCloud = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'upload-cloud',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('16 16 12 12 8 16')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('12'),
					$elm$svg$Svg$Attributes$x2('12'),
					$elm$svg$Svg$Attributes$y2('21')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M20.39 18.39A5 5 0 0 0 18 9h-1.26A8 8 0 1 0 3 16.3')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('16 16 12 12 8 16')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$user = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'user',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('7'),
					$elm$svg$Svg$Attributes$r('4')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$userCheck = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'user-check',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('8.5'),
					$elm$svg$Svg$Attributes$cy('7'),
					$elm$svg$Svg$Attributes$r('4')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('17 11 19 13 23 9')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$userMinus = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'user-minus',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('8.5'),
					$elm$svg$Svg$Attributes$cy('7'),
					$elm$svg$Svg$Attributes$r('4')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('23'),
					$elm$svg$Svg$Attributes$y1('11'),
					$elm$svg$Svg$Attributes$x2('17'),
					$elm$svg$Svg$Attributes$y2('11')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$userPlus = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'user-plus',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('8.5'),
					$elm$svg$Svg$Attributes$cy('7'),
					$elm$svg$Svg$Attributes$r('4')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('20'),
					$elm$svg$Svg$Attributes$y1('8'),
					$elm$svg$Svg$Attributes$x2('20'),
					$elm$svg$Svg$Attributes$y2('14')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('23'),
					$elm$svg$Svg$Attributes$y1('11'),
					$elm$svg$Svg$Attributes$x2('17'),
					$elm$svg$Svg$Attributes$y2('11')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$userX = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'user-x',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('8.5'),
					$elm$svg$Svg$Attributes$cy('7'),
					$elm$svg$Svg$Attributes$r('4')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('18'),
					$elm$svg$Svg$Attributes$y1('8'),
					$elm$svg$Svg$Attributes$x2('23'),
					$elm$svg$Svg$Attributes$y2('13')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('23'),
					$elm$svg$Svg$Attributes$y1('8'),
					$elm$svg$Svg$Attributes$x2('18'),
					$elm$svg$Svg$Attributes$y2('13')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$users = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'users',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('9'),
					$elm$svg$Svg$Attributes$cy('7'),
					$elm$svg$Svg$Attributes$r('4')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M23 21v-2a4 4 0 0 0-3-3.87')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M16 3.13a4 4 0 0 1 0 7.75')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$video = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'video',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polygon,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('23 7 16 12 23 17 23 7')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('1'),
					$elm$svg$Svg$Attributes$y('5'),
					$elm$svg$Svg$Attributes$width('15'),
					$elm$svg$Svg$Attributes$height('14'),
					$elm$svg$Svg$Attributes$rx('2'),
					$elm$svg$Svg$Attributes$ry('2')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$videoOff = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'video-off',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M16 16v1a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V7a2 2 0 0 1 2-2h2m5.66 0H14a2 2 0 0 1 2 2v3.34l1 1L23 7v10')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('1'),
					$elm$svg$Svg$Attributes$y1('1'),
					$elm$svg$Svg$Attributes$x2('23'),
					$elm$svg$Svg$Attributes$y2('23')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$voicemail = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'voicemail',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('5.5'),
					$elm$svg$Svg$Attributes$cy('11.5'),
					$elm$svg$Svg$Attributes$r('4.5')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('18.5'),
					$elm$svg$Svg$Attributes$cy('11.5'),
					$elm$svg$Svg$Attributes$r('4.5')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('5.5'),
					$elm$svg$Svg$Attributes$y1('16'),
					$elm$svg$Svg$Attributes$x2('18.5'),
					$elm$svg$Svg$Attributes$y2('16')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$volume = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'volume',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polygon,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('11 5 6 9 2 9 2 15 6 15 11 19 11 5')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$volume1 = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'volume-1',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polygon,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('11 5 6 9 2 9 2 15 6 15 11 19 11 5')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M15.54 8.46a5 5 0 0 1 0 7.07')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$volume2 = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'volume-2',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polygon,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('11 5 6 9 2 9 2 15 6 15 11 19 11 5')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M19.07 4.93a10 10 0 0 1 0 14.14M15.54 8.46a5 5 0 0 1 0 7.07')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$volumeX = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'volume-x',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polygon,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('11 5 6 9 2 9 2 15 6 15 11 19 11 5')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('23'),
					$elm$svg$Svg$Attributes$y1('9'),
					$elm$svg$Svg$Attributes$x2('17'),
					$elm$svg$Svg$Attributes$y2('15')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('17'),
					$elm$svg$Svg$Attributes$y1('9'),
					$elm$svg$Svg$Attributes$x2('23'),
					$elm$svg$Svg$Attributes$y2('15')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$watch = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'watch',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('7')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('12 9 12 12 13.5 13.5')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M16.51 17.35l-.35 3.83a2 2 0 0 1-2 1.82H9.83a2 2 0 0 1-2-1.82l-.35-3.83m.01-10.7l.35-3.83A2 2 0 0 1 9.83 1h4.35a2 2 0 0 1 2 1.82l.35 3.83')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$wifi = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'wifi',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M5 12.55a11 11 0 0 1 14.08 0')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M1.42 9a16 16 0 0 1 21.16 0')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M8.53 16.11a6 6 0 0 1 6.95 0')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('20'),
					$elm$svg$Svg$Attributes$x2('12.01'),
					$elm$svg$Svg$Attributes$y2('20')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$wifiOff = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'wifi-off',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('1'),
					$elm$svg$Svg$Attributes$y1('1'),
					$elm$svg$Svg$Attributes$x2('23'),
					$elm$svg$Svg$Attributes$y2('23')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M16.72 11.06A10.94 10.94 0 0 1 19 12.55')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M5 12.55a10.94 10.94 0 0 1 5.17-2.39')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M10.71 5.05A16 16 0 0 1 22.58 9')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M1.42 9a15.91 15.91 0 0 1 4.7-2.88')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M8.53 16.11a6 6 0 0 1 6.95 0')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('12'),
					$elm$svg$Svg$Attributes$y1('20'),
					$elm$svg$Svg$Attributes$x2('12.01'),
					$elm$svg$Svg$Attributes$y2('20')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$wind = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'wind',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M9.59 4.59A2 2 0 1 1 11 8H2m10.59 11.41A2 2 0 1 0 14 16H2m15.73-8.27A2.5 2.5 0 1 1 19.5 12H2')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$x = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'x',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('18'),
					$elm$svg$Svg$Attributes$y1('6'),
					$elm$svg$Svg$Attributes$x2('6'),
					$elm$svg$Svg$Attributes$y2('18')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('6'),
					$elm$svg$Svg$Attributes$y1('6'),
					$elm$svg$Svg$Attributes$x2('18'),
					$elm$svg$Svg$Attributes$y2('18')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$xCircle = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'x-circle',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('12'),
					$elm$svg$Svg$Attributes$cy('12'),
					$elm$svg$Svg$Attributes$r('10')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('15'),
					$elm$svg$Svg$Attributes$y1('9'),
					$elm$svg$Svg$Attributes$x2('9'),
					$elm$svg$Svg$Attributes$y2('15')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('9'),
					$elm$svg$Svg$Attributes$y1('9'),
					$elm$svg$Svg$Attributes$x2('15'),
					$elm$svg$Svg$Attributes$y2('15')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$xOctagon = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'x-octagon',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polygon,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('7.86 2 16.14 2 22 7.86 22 16.14 16.14 22 7.86 22 2 16.14 2 7.86 7.86 2')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('15'),
					$elm$svg$Svg$Attributes$y1('9'),
					$elm$svg$Svg$Attributes$x2('9'),
					$elm$svg$Svg$Attributes$y2('15')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('9'),
					$elm$svg$Svg$Attributes$y1('9'),
					$elm$svg$Svg$Attributes$x2('15'),
					$elm$svg$Svg$Attributes$y2('15')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$xSquare = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'x-square',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$rect,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x('3'),
					$elm$svg$Svg$Attributes$y('3'),
					$elm$svg$Svg$Attributes$width('18'),
					$elm$svg$Svg$Attributes$height('18'),
					$elm$svg$Svg$Attributes$rx('2'),
					$elm$svg$Svg$Attributes$ry('2')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('9'),
					$elm$svg$Svg$Attributes$y1('9'),
					$elm$svg$Svg$Attributes$x2('15'),
					$elm$svg$Svg$Attributes$y2('15')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('15'),
					$elm$svg$Svg$Attributes$y1('9'),
					$elm$svg$Svg$Attributes$x2('9'),
					$elm$svg$Svg$Attributes$y2('15')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$youtube = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'youtube',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$path,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$d('M22.54 6.42a2.78 2.78 0 0 0-1.94-2C18.88 4 12 4 12 4s-6.88 0-8.6.46a2.78 2.78 0 0 0-1.94 2A29 29 0 0 0 1 11.75a29 29 0 0 0 .46 5.33A2.78 2.78 0 0 0 3.4 19c1.72.46 8.6.46 8.6.46s6.88 0 8.6-.46a2.78 2.78 0 0 0 1.94-2 29 29 0 0 0 .46-5.25 29 29 0 0 0-.46-5.33z')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polygon,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('9.75 15.02 15.5 11.75 9.75 8.48 9.75 15.02')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$zap = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'zap',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polygon,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('13 2 3 14 12 14 11 22 21 10 12 10 13 2')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$zapOff = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'zap-off',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('12.41 6.75 13 2 10.57 4.92')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('18.57 12.91 21 10 15.66 10')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$polyline,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$points('8 8 3 14 12 14 11 22 16 16')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('1'),
					$elm$svg$Svg$Attributes$y1('1'),
					$elm$svg$Svg$Attributes$x2('23'),
					$elm$svg$Svg$Attributes$y2('23')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$zoomIn = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'zoom-in',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('11'),
					$elm$svg$Svg$Attributes$cy('11'),
					$elm$svg$Svg$Attributes$r('8')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('21'),
					$elm$svg$Svg$Attributes$y1('21'),
					$elm$svg$Svg$Attributes$x2('16.65'),
					$elm$svg$Svg$Attributes$y2('16.65')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('11'),
					$elm$svg$Svg$Attributes$y1('8'),
					$elm$svg$Svg$Attributes$x2('11'),
					$elm$svg$Svg$Attributes$y2('14')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('8'),
					$elm$svg$Svg$Attributes$y1('11'),
					$elm$svg$Svg$Attributes$x2('14'),
					$elm$svg$Svg$Attributes$y2('11')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$zoomOut = A2(
	$feathericons$elm_feather$FeatherIcons$makeBuilder,
	'zoom-out',
	_List_fromArray(
		[
			A2(
			$elm$svg$Svg$circle,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$cx('11'),
					$elm$svg$Svg$Attributes$cy('11'),
					$elm$svg$Svg$Attributes$r('8')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('21'),
					$elm$svg$Svg$Attributes$y1('21'),
					$elm$svg$Svg$Attributes$x2('16.65'),
					$elm$svg$Svg$Attributes$y2('16.65')
				]),
			_List_Nil),
			A2(
			$elm$svg$Svg$line,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$x1('8'),
					$elm$svg$Svg$Attributes$y1('11'),
					$elm$svg$Svg$Attributes$x2('14'),
					$elm$svg$Svg$Attributes$y2('11')
				]),
			_List_Nil)
		]));
var $feathericons$elm_feather$FeatherIcons$icons = $elm$core$Dict$fromList(
	_List_fromArray(
		[
			_Utils_Tuple2('activity', $feathericons$elm_feather$FeatherIcons$activity),
			_Utils_Tuple2('airplay', $feathericons$elm_feather$FeatherIcons$airplay),
			_Utils_Tuple2('alert-circle', $feathericons$elm_feather$FeatherIcons$alertCircle),
			_Utils_Tuple2('alert-octagon', $feathericons$elm_feather$FeatherIcons$alertOctagon),
			_Utils_Tuple2('alert-triangle', $feathericons$elm_feather$FeatherIcons$alertTriangle),
			_Utils_Tuple2('align-center', $feathericons$elm_feather$FeatherIcons$alignCenter),
			_Utils_Tuple2('align-justify', $feathericons$elm_feather$FeatherIcons$alignJustify),
			_Utils_Tuple2('align-left', $feathericons$elm_feather$FeatherIcons$alignLeft),
			_Utils_Tuple2('align-right', $feathericons$elm_feather$FeatherIcons$alignRight),
			_Utils_Tuple2('anchor', $feathericons$elm_feather$FeatherIcons$anchor),
			_Utils_Tuple2('aperture', $feathericons$elm_feather$FeatherIcons$aperture),
			_Utils_Tuple2('archive', $feathericons$elm_feather$FeatherIcons$archive),
			_Utils_Tuple2('arrow-down-circle', $feathericons$elm_feather$FeatherIcons$arrowDownCircle),
			_Utils_Tuple2('arrow-down-left', $feathericons$elm_feather$FeatherIcons$arrowDownLeft),
			_Utils_Tuple2('arrow-down-right', $feathericons$elm_feather$FeatherIcons$arrowDownRight),
			_Utils_Tuple2('arrow-down', $feathericons$elm_feather$FeatherIcons$arrowDown),
			_Utils_Tuple2('arrow-left-circle', $feathericons$elm_feather$FeatherIcons$arrowLeftCircle),
			_Utils_Tuple2('arrow-left', $feathericons$elm_feather$FeatherIcons$arrowLeft),
			_Utils_Tuple2('arrow-right-circle', $feathericons$elm_feather$FeatherIcons$arrowRightCircle),
			_Utils_Tuple2('arrow-right', $feathericons$elm_feather$FeatherIcons$arrowRight),
			_Utils_Tuple2('arrow-up-circle', $feathericons$elm_feather$FeatherIcons$arrowUpCircle),
			_Utils_Tuple2('arrow-up-left', $feathericons$elm_feather$FeatherIcons$arrowUpLeft),
			_Utils_Tuple2('arrow-up-right', $feathericons$elm_feather$FeatherIcons$arrowUpRight),
			_Utils_Tuple2('arrow-up', $feathericons$elm_feather$FeatherIcons$arrowUp),
			_Utils_Tuple2('at-sign', $feathericons$elm_feather$FeatherIcons$atSign),
			_Utils_Tuple2('award', $feathericons$elm_feather$FeatherIcons$award),
			_Utils_Tuple2('bar-chart-2', $feathericons$elm_feather$FeatherIcons$barChart2),
			_Utils_Tuple2('bar-chart', $feathericons$elm_feather$FeatherIcons$barChart),
			_Utils_Tuple2('battery-charging', $feathericons$elm_feather$FeatherIcons$batteryCharging),
			_Utils_Tuple2('battery', $feathericons$elm_feather$FeatherIcons$battery),
			_Utils_Tuple2('bell-off', $feathericons$elm_feather$FeatherIcons$bellOff),
			_Utils_Tuple2('bell', $feathericons$elm_feather$FeatherIcons$bell),
			_Utils_Tuple2('bluetooth', $feathericons$elm_feather$FeatherIcons$bluetooth),
			_Utils_Tuple2('bold', $feathericons$elm_feather$FeatherIcons$bold),
			_Utils_Tuple2('book-open', $feathericons$elm_feather$FeatherIcons$bookOpen),
			_Utils_Tuple2('book', $feathericons$elm_feather$FeatherIcons$book),
			_Utils_Tuple2('bookmark', $feathericons$elm_feather$FeatherIcons$bookmark),
			_Utils_Tuple2('box', $feathericons$elm_feather$FeatherIcons$box),
			_Utils_Tuple2('briefcase', $feathericons$elm_feather$FeatherIcons$briefcase),
			_Utils_Tuple2('calendar', $feathericons$elm_feather$FeatherIcons$calendar),
			_Utils_Tuple2('camera-off', $feathericons$elm_feather$FeatherIcons$cameraOff),
			_Utils_Tuple2('camera', $feathericons$elm_feather$FeatherIcons$camera),
			_Utils_Tuple2('cast', $feathericons$elm_feather$FeatherIcons$cast),
			_Utils_Tuple2('check-circle', $feathericons$elm_feather$FeatherIcons$checkCircle),
			_Utils_Tuple2('check-square', $feathericons$elm_feather$FeatherIcons$checkSquare),
			_Utils_Tuple2('check', $feathericons$elm_feather$FeatherIcons$check),
			_Utils_Tuple2('chevron-down', $feathericons$elm_feather$FeatherIcons$chevronDown),
			_Utils_Tuple2('chevron-left', $feathericons$elm_feather$FeatherIcons$chevronLeft),
			_Utils_Tuple2('chevron-right', $feathericons$elm_feather$FeatherIcons$chevronRight),
			_Utils_Tuple2('chevron-up', $feathericons$elm_feather$FeatherIcons$chevronUp),
			_Utils_Tuple2('chevrons-down', $feathericons$elm_feather$FeatherIcons$chevronsDown),
			_Utils_Tuple2('chevrons-left', $feathericons$elm_feather$FeatherIcons$chevronsLeft),
			_Utils_Tuple2('chevrons-right', $feathericons$elm_feather$FeatherIcons$chevronsRight),
			_Utils_Tuple2('chevrons-up', $feathericons$elm_feather$FeatherIcons$chevronsUp),
			_Utils_Tuple2('chrome', $feathericons$elm_feather$FeatherIcons$chrome),
			_Utils_Tuple2('circle', $feathericons$elm_feather$FeatherIcons$circle),
			_Utils_Tuple2('clipboard', $feathericons$elm_feather$FeatherIcons$clipboard),
			_Utils_Tuple2('clock', $feathericons$elm_feather$FeatherIcons$clock),
			_Utils_Tuple2('cloud-drizzle', $feathericons$elm_feather$FeatherIcons$cloudDrizzle),
			_Utils_Tuple2('cloud-lightning', $feathericons$elm_feather$FeatherIcons$cloudLightning),
			_Utils_Tuple2('cloud-off', $feathericons$elm_feather$FeatherIcons$cloudOff),
			_Utils_Tuple2('cloud-rain', $feathericons$elm_feather$FeatherIcons$cloudRain),
			_Utils_Tuple2('cloud-snow', $feathericons$elm_feather$FeatherIcons$cloudSnow),
			_Utils_Tuple2('cloud', $feathericons$elm_feather$FeatherIcons$cloud),
			_Utils_Tuple2('code', $feathericons$elm_feather$FeatherIcons$code),
			_Utils_Tuple2('codepen', $feathericons$elm_feather$FeatherIcons$codepen),
			_Utils_Tuple2('codesandbox', $feathericons$elm_feather$FeatherIcons$codesandbox),
			_Utils_Tuple2('coffee', $feathericons$elm_feather$FeatherIcons$coffee),
			_Utils_Tuple2('columns', $feathericons$elm_feather$FeatherIcons$columns),
			_Utils_Tuple2('command', $feathericons$elm_feather$FeatherIcons$command),
			_Utils_Tuple2('compass', $feathericons$elm_feather$FeatherIcons$compass),
			_Utils_Tuple2('copy', $feathericons$elm_feather$FeatherIcons$copy),
			_Utils_Tuple2('corner-down-left', $feathericons$elm_feather$FeatherIcons$cornerDownLeft),
			_Utils_Tuple2('corner-down-right', $feathericons$elm_feather$FeatherIcons$cornerDownRight),
			_Utils_Tuple2('corner-left-down', $feathericons$elm_feather$FeatherIcons$cornerLeftDown),
			_Utils_Tuple2('corner-left-up', $feathericons$elm_feather$FeatherIcons$cornerLeftUp),
			_Utils_Tuple2('corner-right-down', $feathericons$elm_feather$FeatherIcons$cornerRightDown),
			_Utils_Tuple2('corner-right-up', $feathericons$elm_feather$FeatherIcons$cornerRightUp),
			_Utils_Tuple2('corner-up-left', $feathericons$elm_feather$FeatherIcons$cornerUpLeft),
			_Utils_Tuple2('corner-up-right', $feathericons$elm_feather$FeatherIcons$cornerUpRight),
			_Utils_Tuple2('cpu', $feathericons$elm_feather$FeatherIcons$cpu),
			_Utils_Tuple2('credit-card', $feathericons$elm_feather$FeatherIcons$creditCard),
			_Utils_Tuple2('crop', $feathericons$elm_feather$FeatherIcons$crop),
			_Utils_Tuple2('crosshair', $feathericons$elm_feather$FeatherIcons$crosshair),
			_Utils_Tuple2('database', $feathericons$elm_feather$FeatherIcons$database),
			_Utils_Tuple2('delete', $feathericons$elm_feather$FeatherIcons$delete),
			_Utils_Tuple2('disc', $feathericons$elm_feather$FeatherIcons$disc),
			_Utils_Tuple2('divide-circle', $feathericons$elm_feather$FeatherIcons$divideCircle),
			_Utils_Tuple2('divide-square', $feathericons$elm_feather$FeatherIcons$divideSquare),
			_Utils_Tuple2('divide', $feathericons$elm_feather$FeatherIcons$divide),
			_Utils_Tuple2('dollar-sign', $feathericons$elm_feather$FeatherIcons$dollarSign),
			_Utils_Tuple2('download-cloud', $feathericons$elm_feather$FeatherIcons$downloadCloud),
			_Utils_Tuple2('download', $feathericons$elm_feather$FeatherIcons$download),
			_Utils_Tuple2('dribbble', $feathericons$elm_feather$FeatherIcons$dribbble),
			_Utils_Tuple2('droplet', $feathericons$elm_feather$FeatherIcons$droplet),
			_Utils_Tuple2('edit-2', $feathericons$elm_feather$FeatherIcons$edit2),
			_Utils_Tuple2('edit-3', $feathericons$elm_feather$FeatherIcons$edit3),
			_Utils_Tuple2('edit', $feathericons$elm_feather$FeatherIcons$edit),
			_Utils_Tuple2('external-link', $feathericons$elm_feather$FeatherIcons$externalLink),
			_Utils_Tuple2('eye-off', $feathericons$elm_feather$FeatherIcons$eyeOff),
			_Utils_Tuple2('eye', $feathericons$elm_feather$FeatherIcons$eye),
			_Utils_Tuple2('facebook', $feathericons$elm_feather$FeatherIcons$facebook),
			_Utils_Tuple2('fast-forward', $feathericons$elm_feather$FeatherIcons$fastForward),
			_Utils_Tuple2('feather', $feathericons$elm_feather$FeatherIcons$feather),
			_Utils_Tuple2('figma', $feathericons$elm_feather$FeatherIcons$figma),
			_Utils_Tuple2('file-minus', $feathericons$elm_feather$FeatherIcons$fileMinus),
			_Utils_Tuple2('file-plus', $feathericons$elm_feather$FeatherIcons$filePlus),
			_Utils_Tuple2('file-text', $feathericons$elm_feather$FeatherIcons$fileText),
			_Utils_Tuple2('file', $feathericons$elm_feather$FeatherIcons$file),
			_Utils_Tuple2('film', $feathericons$elm_feather$FeatherIcons$film),
			_Utils_Tuple2('filter', $feathericons$elm_feather$FeatherIcons$filter),
			_Utils_Tuple2('flag', $feathericons$elm_feather$FeatherIcons$flag),
			_Utils_Tuple2('folder-minus', $feathericons$elm_feather$FeatherIcons$folderMinus),
			_Utils_Tuple2('folder-plus', $feathericons$elm_feather$FeatherIcons$folderPlus),
			_Utils_Tuple2('folder', $feathericons$elm_feather$FeatherIcons$folder),
			_Utils_Tuple2('framer', $feathericons$elm_feather$FeatherIcons$framer),
			_Utils_Tuple2('frown', $feathericons$elm_feather$FeatherIcons$frown),
			_Utils_Tuple2('gift', $feathericons$elm_feather$FeatherIcons$gift),
			_Utils_Tuple2('git-branch', $feathericons$elm_feather$FeatherIcons$gitBranch),
			_Utils_Tuple2('git-commit', $feathericons$elm_feather$FeatherIcons$gitCommit),
			_Utils_Tuple2('git-merge', $feathericons$elm_feather$FeatherIcons$gitMerge),
			_Utils_Tuple2('git-pull-request', $feathericons$elm_feather$FeatherIcons$gitPullRequest),
			_Utils_Tuple2('github', $feathericons$elm_feather$FeatherIcons$github),
			_Utils_Tuple2('gitlab', $feathericons$elm_feather$FeatherIcons$gitlab),
			_Utils_Tuple2('globe', $feathericons$elm_feather$FeatherIcons$globe),
			_Utils_Tuple2('grid', $feathericons$elm_feather$FeatherIcons$grid),
			_Utils_Tuple2('hard-drive', $feathericons$elm_feather$FeatherIcons$hardDrive),
			_Utils_Tuple2('hash', $feathericons$elm_feather$FeatherIcons$hash),
			_Utils_Tuple2('headphones', $feathericons$elm_feather$FeatherIcons$headphones),
			_Utils_Tuple2('heart', $feathericons$elm_feather$FeatherIcons$heart),
			_Utils_Tuple2('help-circle', $feathericons$elm_feather$FeatherIcons$helpCircle),
			_Utils_Tuple2('hexagon', $feathericons$elm_feather$FeatherIcons$hexagon),
			_Utils_Tuple2('home', $feathericons$elm_feather$FeatherIcons$home),
			_Utils_Tuple2('image', $feathericons$elm_feather$FeatherIcons$image),
			_Utils_Tuple2('inbox', $feathericons$elm_feather$FeatherIcons$inbox),
			_Utils_Tuple2('info', $feathericons$elm_feather$FeatherIcons$info),
			_Utils_Tuple2('instagram', $feathericons$elm_feather$FeatherIcons$instagram),
			_Utils_Tuple2('italic', $feathericons$elm_feather$FeatherIcons$italic),
			_Utils_Tuple2('key', $feathericons$elm_feather$FeatherIcons$key),
			_Utils_Tuple2('layers', $feathericons$elm_feather$FeatherIcons$layers),
			_Utils_Tuple2('layout', $feathericons$elm_feather$FeatherIcons$layout),
			_Utils_Tuple2('life-buoy', $feathericons$elm_feather$FeatherIcons$lifeBuoy),
			_Utils_Tuple2('link-2', $feathericons$elm_feather$FeatherIcons$link2),
			_Utils_Tuple2('link', $feathericons$elm_feather$FeatherIcons$link),
			_Utils_Tuple2('linkedin', $feathericons$elm_feather$FeatherIcons$linkedin),
			_Utils_Tuple2('list', $feathericons$elm_feather$FeatherIcons$list),
			_Utils_Tuple2('loader', $feathericons$elm_feather$FeatherIcons$loader),
			_Utils_Tuple2('lock', $feathericons$elm_feather$FeatherIcons$lock),
			_Utils_Tuple2('log-in', $feathericons$elm_feather$FeatherIcons$logIn),
			_Utils_Tuple2('log-out', $feathericons$elm_feather$FeatherIcons$logOut),
			_Utils_Tuple2('mail', $feathericons$elm_feather$FeatherIcons$mail),
			_Utils_Tuple2('map-pin', $feathericons$elm_feather$FeatherIcons$mapPin),
			_Utils_Tuple2('map', $feathericons$elm_feather$FeatherIcons$map),
			_Utils_Tuple2('maximize-2', $feathericons$elm_feather$FeatherIcons$maximize2),
			_Utils_Tuple2('maximize', $feathericons$elm_feather$FeatherIcons$maximize),
			_Utils_Tuple2('meh', $feathericons$elm_feather$FeatherIcons$meh),
			_Utils_Tuple2('menu', $feathericons$elm_feather$FeatherIcons$menu),
			_Utils_Tuple2('message-circle', $feathericons$elm_feather$FeatherIcons$messageCircle),
			_Utils_Tuple2('message-square', $feathericons$elm_feather$FeatherIcons$messageSquare),
			_Utils_Tuple2('mic-off', $feathericons$elm_feather$FeatherIcons$micOff),
			_Utils_Tuple2('mic', $feathericons$elm_feather$FeatherIcons$mic),
			_Utils_Tuple2('minimize-2', $feathericons$elm_feather$FeatherIcons$minimize2),
			_Utils_Tuple2('minimize', $feathericons$elm_feather$FeatherIcons$minimize),
			_Utils_Tuple2('minus-circle', $feathericons$elm_feather$FeatherIcons$minusCircle),
			_Utils_Tuple2('minus-square', $feathericons$elm_feather$FeatherIcons$minusSquare),
			_Utils_Tuple2('minus', $feathericons$elm_feather$FeatherIcons$minus),
			_Utils_Tuple2('monitor', $feathericons$elm_feather$FeatherIcons$monitor),
			_Utils_Tuple2('moon', $feathericons$elm_feather$FeatherIcons$moon),
			_Utils_Tuple2('more-horizontal', $feathericons$elm_feather$FeatherIcons$moreHorizontal),
			_Utils_Tuple2('more-vertical', $feathericons$elm_feather$FeatherIcons$moreVertical),
			_Utils_Tuple2('mouse-pointer', $feathericons$elm_feather$FeatherIcons$mousePointer),
			_Utils_Tuple2('move', $feathericons$elm_feather$FeatherIcons$move),
			_Utils_Tuple2('music', $feathericons$elm_feather$FeatherIcons$music),
			_Utils_Tuple2('navigation-2', $feathericons$elm_feather$FeatherIcons$navigation2),
			_Utils_Tuple2('navigation', $feathericons$elm_feather$FeatherIcons$navigation),
			_Utils_Tuple2('octagon', $feathericons$elm_feather$FeatherIcons$octagon),
			_Utils_Tuple2('package', $feathericons$elm_feather$FeatherIcons$package),
			_Utils_Tuple2('paperclip', $feathericons$elm_feather$FeatherIcons$paperclip),
			_Utils_Tuple2('pause-circle', $feathericons$elm_feather$FeatherIcons$pauseCircle),
			_Utils_Tuple2('pause', $feathericons$elm_feather$FeatherIcons$pause),
			_Utils_Tuple2('pen-tool', $feathericons$elm_feather$FeatherIcons$penTool),
			_Utils_Tuple2('percent', $feathericons$elm_feather$FeatherIcons$percent),
			_Utils_Tuple2('phone-call', $feathericons$elm_feather$FeatherIcons$phoneCall),
			_Utils_Tuple2('phone-forwarded', $feathericons$elm_feather$FeatherIcons$phoneForwarded),
			_Utils_Tuple2('phone-incoming', $feathericons$elm_feather$FeatherIcons$phoneIncoming),
			_Utils_Tuple2('phone-missed', $feathericons$elm_feather$FeatherIcons$phoneMissed),
			_Utils_Tuple2('phone-off', $feathericons$elm_feather$FeatherIcons$phoneOff),
			_Utils_Tuple2('phone-outgoing', $feathericons$elm_feather$FeatherIcons$phoneOutgoing),
			_Utils_Tuple2('phone', $feathericons$elm_feather$FeatherIcons$phone),
			_Utils_Tuple2('pie-chart', $feathericons$elm_feather$FeatherIcons$pieChart),
			_Utils_Tuple2('play-circle', $feathericons$elm_feather$FeatherIcons$playCircle),
			_Utils_Tuple2('play', $feathericons$elm_feather$FeatherIcons$play),
			_Utils_Tuple2('plus-circle', $feathericons$elm_feather$FeatherIcons$plusCircle),
			_Utils_Tuple2('plus-square', $feathericons$elm_feather$FeatherIcons$plusSquare),
			_Utils_Tuple2('plus', $feathericons$elm_feather$FeatherIcons$plus),
			_Utils_Tuple2('pocket', $feathericons$elm_feather$FeatherIcons$pocket),
			_Utils_Tuple2('power', $feathericons$elm_feather$FeatherIcons$power),
			_Utils_Tuple2('printer', $feathericons$elm_feather$FeatherIcons$printer),
			_Utils_Tuple2('radio', $feathericons$elm_feather$FeatherIcons$radio),
			_Utils_Tuple2('refresh-ccw', $feathericons$elm_feather$FeatherIcons$refreshCcw),
			_Utils_Tuple2('refresh-cw', $feathericons$elm_feather$FeatherIcons$refreshCw),
			_Utils_Tuple2('repeat', $feathericons$elm_feather$FeatherIcons$repeat),
			_Utils_Tuple2('rewind', $feathericons$elm_feather$FeatherIcons$rewind),
			_Utils_Tuple2('rotate-ccw', $feathericons$elm_feather$FeatherIcons$rotateCcw),
			_Utils_Tuple2('rotate-cw', $feathericons$elm_feather$FeatherIcons$rotateCw),
			_Utils_Tuple2('rss', $feathericons$elm_feather$FeatherIcons$rss),
			_Utils_Tuple2('save', $feathericons$elm_feather$FeatherIcons$save),
			_Utils_Tuple2('scissors', $feathericons$elm_feather$FeatherIcons$scissors),
			_Utils_Tuple2('search', $feathericons$elm_feather$FeatherIcons$search),
			_Utils_Tuple2('send', $feathericons$elm_feather$FeatherIcons$send),
			_Utils_Tuple2('server', $feathericons$elm_feather$FeatherIcons$server),
			_Utils_Tuple2('settings', $feathericons$elm_feather$FeatherIcons$settings),
			_Utils_Tuple2('share-2', $feathericons$elm_feather$FeatherIcons$share2),
			_Utils_Tuple2('share', $feathericons$elm_feather$FeatherIcons$share),
			_Utils_Tuple2('shield-off', $feathericons$elm_feather$FeatherIcons$shieldOff),
			_Utils_Tuple2('shield', $feathericons$elm_feather$FeatherIcons$shield),
			_Utils_Tuple2('shopping-bag', $feathericons$elm_feather$FeatherIcons$shoppingBag),
			_Utils_Tuple2('shopping-cart', $feathericons$elm_feather$FeatherIcons$shoppingCart),
			_Utils_Tuple2('shuffle', $feathericons$elm_feather$FeatherIcons$shuffle),
			_Utils_Tuple2('sidebar', $feathericons$elm_feather$FeatherIcons$sidebar),
			_Utils_Tuple2('skip-back', $feathericons$elm_feather$FeatherIcons$skipBack),
			_Utils_Tuple2('skip-forward', $feathericons$elm_feather$FeatherIcons$skipForward),
			_Utils_Tuple2('slack', $feathericons$elm_feather$FeatherIcons$slack),
			_Utils_Tuple2('slash', $feathericons$elm_feather$FeatherIcons$slash),
			_Utils_Tuple2('sliders', $feathericons$elm_feather$FeatherIcons$sliders),
			_Utils_Tuple2('smartphone', $feathericons$elm_feather$FeatherIcons$smartphone),
			_Utils_Tuple2('smile', $feathericons$elm_feather$FeatherIcons$smile),
			_Utils_Tuple2('speaker', $feathericons$elm_feather$FeatherIcons$speaker),
			_Utils_Tuple2('square', $feathericons$elm_feather$FeatherIcons$square),
			_Utils_Tuple2('star', $feathericons$elm_feather$FeatherIcons$star),
			_Utils_Tuple2('stop-circle', $feathericons$elm_feather$FeatherIcons$stopCircle),
			_Utils_Tuple2('sun', $feathericons$elm_feather$FeatherIcons$sun),
			_Utils_Tuple2('sunrise', $feathericons$elm_feather$FeatherIcons$sunrise),
			_Utils_Tuple2('sunset', $feathericons$elm_feather$FeatherIcons$sunset),
			_Utils_Tuple2('tablet', $feathericons$elm_feather$FeatherIcons$tablet),
			_Utils_Tuple2('tag', $feathericons$elm_feather$FeatherIcons$tag),
			_Utils_Tuple2('target', $feathericons$elm_feather$FeatherIcons$target),
			_Utils_Tuple2('terminal', $feathericons$elm_feather$FeatherIcons$terminal),
			_Utils_Tuple2('thermometer', $feathericons$elm_feather$FeatherIcons$thermometer),
			_Utils_Tuple2('thumbs-down', $feathericons$elm_feather$FeatherIcons$thumbsDown),
			_Utils_Tuple2('thumbs-up', $feathericons$elm_feather$FeatherIcons$thumbsUp),
			_Utils_Tuple2('toggle-left', $feathericons$elm_feather$FeatherIcons$toggleLeft),
			_Utils_Tuple2('toggle-right', $feathericons$elm_feather$FeatherIcons$toggleRight),
			_Utils_Tuple2('tool', $feathericons$elm_feather$FeatherIcons$tool),
			_Utils_Tuple2('trash-2', $feathericons$elm_feather$FeatherIcons$trash2),
			_Utils_Tuple2('trash', $feathericons$elm_feather$FeatherIcons$trash),
			_Utils_Tuple2('trello', $feathericons$elm_feather$FeatherIcons$trello),
			_Utils_Tuple2('trending-down', $feathericons$elm_feather$FeatherIcons$trendingDown),
			_Utils_Tuple2('trending-up', $feathericons$elm_feather$FeatherIcons$trendingUp),
			_Utils_Tuple2('triangle', $feathericons$elm_feather$FeatherIcons$triangle),
			_Utils_Tuple2('truck', $feathericons$elm_feather$FeatherIcons$truck),
			_Utils_Tuple2('tv', $feathericons$elm_feather$FeatherIcons$tv),
			_Utils_Tuple2('twitch', $feathericons$elm_feather$FeatherIcons$twitch),
			_Utils_Tuple2('twitter', $feathericons$elm_feather$FeatherIcons$twitter),
			_Utils_Tuple2('type', $feathericons$elm_feather$FeatherIcons$type_),
			_Utils_Tuple2('umbrella', $feathericons$elm_feather$FeatherIcons$umbrella),
			_Utils_Tuple2('underline', $feathericons$elm_feather$FeatherIcons$underline),
			_Utils_Tuple2('unlock', $feathericons$elm_feather$FeatherIcons$unlock),
			_Utils_Tuple2('upload-cloud', $feathericons$elm_feather$FeatherIcons$uploadCloud),
			_Utils_Tuple2('upload', $feathericons$elm_feather$FeatherIcons$upload),
			_Utils_Tuple2('user-check', $feathericons$elm_feather$FeatherIcons$userCheck),
			_Utils_Tuple2('user-minus', $feathericons$elm_feather$FeatherIcons$userMinus),
			_Utils_Tuple2('user-plus', $feathericons$elm_feather$FeatherIcons$userPlus),
			_Utils_Tuple2('user-x', $feathericons$elm_feather$FeatherIcons$userX),
			_Utils_Tuple2('user', $feathericons$elm_feather$FeatherIcons$user),
			_Utils_Tuple2('users', $feathericons$elm_feather$FeatherIcons$users),
			_Utils_Tuple2('video-off', $feathericons$elm_feather$FeatherIcons$videoOff),
			_Utils_Tuple2('video', $feathericons$elm_feather$FeatherIcons$video),
			_Utils_Tuple2('voicemail', $feathericons$elm_feather$FeatherIcons$voicemail),
			_Utils_Tuple2('volume-1', $feathericons$elm_feather$FeatherIcons$volume1),
			_Utils_Tuple2('volume-2', $feathericons$elm_feather$FeatherIcons$volume2),
			_Utils_Tuple2('volume-x', $feathericons$elm_feather$FeatherIcons$volumeX),
			_Utils_Tuple2('volume', $feathericons$elm_feather$FeatherIcons$volume),
			_Utils_Tuple2('watch', $feathericons$elm_feather$FeatherIcons$watch),
			_Utils_Tuple2('wifi-off', $feathericons$elm_feather$FeatherIcons$wifiOff),
			_Utils_Tuple2('wifi', $feathericons$elm_feather$FeatherIcons$wifi),
			_Utils_Tuple2('wind', $feathericons$elm_feather$FeatherIcons$wind),
			_Utils_Tuple2('x-circle', $feathericons$elm_feather$FeatherIcons$xCircle),
			_Utils_Tuple2('x-octagon', $feathericons$elm_feather$FeatherIcons$xOctagon),
			_Utils_Tuple2('x-square', $feathericons$elm_feather$FeatherIcons$xSquare),
			_Utils_Tuple2('x', $feathericons$elm_feather$FeatherIcons$x),
			_Utils_Tuple2('youtube', $feathericons$elm_feather$FeatherIcons$youtube),
			_Utils_Tuple2('zap-off', $feathericons$elm_feather$FeatherIcons$zapOff),
			_Utils_Tuple2('zap', $feathericons$elm_feather$FeatherIcons$zap),
			_Utils_Tuple2('zoom-in', $feathericons$elm_feather$FeatherIcons$zoomIn),
			_Utils_Tuple2('zoom-out', $feathericons$elm_feather$FeatherIcons$zoomOut)
		]));
var $elm$svg$Svg$Attributes$class = _VirtualDom_attribute('class');
var $elm$svg$Svg$Attributes$fill = _VirtualDom_attribute('fill');
var $elm$virtual_dom$VirtualDom$map = _VirtualDom_map;
var $elm$svg$Svg$map = $elm$virtual_dom$VirtualDom$map;
var $elm$svg$Svg$Attributes$stroke = _VirtualDom_attribute('stroke');
var $elm$svg$Svg$Attributes$strokeLinecap = _VirtualDom_attribute('stroke-linecap');
var $elm$svg$Svg$Attributes$strokeLinejoin = _VirtualDom_attribute('stroke-linejoin');
var $elm$svg$Svg$Attributes$strokeWidth = _VirtualDom_attribute('stroke-width');
var $elm$svg$Svg$svg = $elm$svg$Svg$trustedNode('svg');
var $elm$svg$Svg$Attributes$viewBox = _VirtualDom_attribute('viewBox');
var $feathericons$elm_feather$FeatherIcons$toHtml = F2(
	function (attributes, _v0) {
		var src = _v0.a.src;
		var attrs = _v0.a.attrs;
		var strSize = $elm$core$String$fromFloat(attrs.size);
		var baseAttributes = _List_fromArray(
			[
				$elm$svg$Svg$Attributes$fill('none'),
				$elm$svg$Svg$Attributes$height(
				_Utils_ap(strSize, attrs.sizeUnit)),
				$elm$svg$Svg$Attributes$width(
				_Utils_ap(strSize, attrs.sizeUnit)),
				$elm$svg$Svg$Attributes$stroke('currentColor'),
				$elm$svg$Svg$Attributes$strokeLinecap('round'),
				$elm$svg$Svg$Attributes$strokeLinejoin('round'),
				$elm$svg$Svg$Attributes$strokeWidth(
				$elm$core$String$fromFloat(attrs.strokeWidth)),
				$elm$svg$Svg$Attributes$viewBox(attrs.viewBox)
			]);
		var combinedAttributes = _Utils_ap(
			function () {
				var _v1 = attrs._class;
				if (_v1.$ === 'Just') {
					var c = _v1.a;
					return A2(
						$elm$core$List$cons,
						$elm$svg$Svg$Attributes$class(c),
						baseAttributes);
				} else {
					return baseAttributes;
				}
			}(),
			attributes);
		return A2(
			$elm$svg$Svg$svg,
			combinedAttributes,
			A2(
				$elm$core$List$map,
				$elm$svg$Svg$map($elm$core$Basics$never),
				src));
	});
var $author$project$IconMenuAPI$viewIconList = A2(
	$elm$core$List$map,
	function (_v0) {
		var iconName = _v0.a;
		var icon = _v0.b;
		return A2(
			$elm$html$Html$button,
			_Utils_ap(
				_List_fromArray(
					[
						$elm$html$Html$Events$onClick(
						$author$project$AppModel$IconMenu(
							$author$project$IconMenu$SetIcon(
								$elm$core$Maybe$Just(iconName)))),
						$elm$html$Html$Attributes$title(iconName)
					]),
				$author$project$IconMenuAPI$iconButtonStyle),
			_List_fromArray(
				[
					A2($feathericons$elm_feather$FeatherIcons$toHtml, _List_Nil, icon)
				]));
	},
	$elm$core$Dict$toList($feathericons$elm_feather$FeatherIcons$icons));
var $author$project$IconMenuAPI$viewIconMenu = function (model) {
	return model.iconMenu.open ? _List_fromArray(
		[
			A2(
			$elm$html$Html$div,
			_Utils_ap(
				$author$project$IconMenuAPI$iconMenuStyle,
				_List_fromArray(
					[
						$author$project$IconMenuAPI$onContextMenuPrevent(
						$author$project$AppModel$IconMenu($author$project$IconMenu$Close))
					])),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$div,
					$author$project$IconMenuAPI$closeButtonStyle,
					_List_fromArray(
						[
							A2(
							$elm$html$Html$button,
							_List_fromArray(
								[
									$elm$html$Html$Events$onClick(
									$author$project$AppModel$IconMenu($author$project$IconMenu$Close))
								]),
							_List_fromArray(
								[
									$elm$html$Html$text('×')
								]))
						])),
					A2(
					$elm$html$Html$div,
					_Utils_ap(
						$author$project$IconMenuAPI$iconListStyle,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$title('Pick an icon')
							])),
					$author$project$IconMenuAPI$viewIconList)
				]))
		]) : _List_Nil;
};
var $author$project$MapRenderer$blackBoxStyle = _List_fromArray(
	[
		A2($elm$html$Html$Attributes$style, 'pointer-events', 'none')
	]);
var $author$project$Config$blackBoxOffset = 5;
var $author$project$ModelAPI$isSelected = F3(
	function (itemId, mapId, model) {
		return A2(
			$elm$core$List$any,
			function (_v0) {
				var id = _v0.a;
				var mapPath = _v0.b;
				if (mapPath.b) {
					var mapId_ = mapPath.a;
					return _Utils_eq(itemId, id) && _Utils_eq(mapId, mapId_);
				} else {
					return false;
				}
			},
			model.selection);
	});
var $author$project$MapRenderer$selectionStyle = F3(
	function (topicId, mapId, model) {
		return A3($author$project$ModelAPI$isSelected, topicId, mapId, model) ? _List_fromArray(
			[
				A2($elm$html$Html$Attributes$style, 'box-shadow', 'gray 5px 5px 5px')
			]) : _List_Nil;
	});
var $author$project$MapRenderer$isTarget = F3(
	function (topicId, mapId, target) {
		if (target.$ === 'Just') {
			var _v1 = target.a;
			var targetId = _v1.a;
			var targetMapPath = _v1.b;
			if (targetMapPath.b) {
				var targetMapId = targetMapPath.a;
				return _Utils_eq(topicId, targetId) && _Utils_eq(mapId, targetMapId);
			} else {
				return false;
			}
		} else {
			return false;
		}
	});
var $author$project$MapRenderer$topicBorderStyle = F3(
	function (id, mapId, model) {
		var targeted = function () {
			var _v0 = model.mouse.dragState;
			_v0$2:
			while (true) {
				if (_v0.$ === 'Drag') {
					if (_v0.a.$ === 'DragTopic') {
						if (_v0.c.b) {
							var _v1 = _v0.a;
							var _v2 = _v0.c;
							var mapId_ = _v2.a;
							var target = _v0.f;
							return A3($author$project$MapRenderer$isTarget, id, mapId, target) && (!_Utils_eq(mapId_, id));
						} else {
							break _v0$2;
						}
					} else {
						if (_v0.c.b) {
							var _v3 = _v0.a;
							var _v4 = _v0.c;
							var mapId_ = _v4.a;
							var target = _v0.f;
							return A3($author$project$MapRenderer$isTarget, id, mapId, target) && _Utils_eq(mapId_, mapId);
						} else {
							break _v0$2;
						}
					}
				} else {
					break _v0$2;
				}
			}
			return false;
		}();
		return _List_fromArray(
			[
				A2(
				$elm$html$Html$Attributes$style,
				'border-width',
				$elm$core$String$fromFloat($author$project$Config$topicBorderWidth) + 'px'),
				A2(
				$elm$html$Html$Attributes$style,
				'border-style',
				targeted ? 'dashed' : 'solid'),
				A2($elm$html$Html$Attributes$style, 'box-sizing', 'border-box'),
				A2($elm$html$Html$Attributes$style, 'background-color', 'white')
			]);
	});
var $author$project$Config$topicRadius = 7;
var $author$project$MapRenderer$ghostTopicStyle = F3(
	function (topic, mapId, model) {
		return _Utils_ap(
			_List_fromArray(
				[
					A2($elm$html$Html$Attributes$style, 'position', 'absolute'),
					A2(
					$elm$html$Html$Attributes$style,
					'left',
					$elm$core$String$fromInt($author$project$Config$blackBoxOffset) + 'px'),
					A2(
					$elm$html$Html$Attributes$style,
					'top',
					$elm$core$String$fromInt($author$project$Config$blackBoxOffset) + 'px'),
					A2(
					$elm$html$Html$Attributes$style,
					'width',
					$elm$core$String$fromFloat($author$project$Config$topicSize.w) + 'px'),
					A2(
					$elm$html$Html$Attributes$style,
					'height',
					$elm$core$String$fromFloat($author$project$Config$topicSize.h) + 'px'),
					A2(
					$elm$html$Html$Attributes$style,
					'border-radius',
					$elm$core$String$fromInt($author$project$Config$topicRadius) + 'px'),
					A2($elm$html$Html$Attributes$style, 'pointer-events', 'none'),
					A2($elm$html$Html$Attributes$style, 'z-index', '-1')
				]),
			_Utils_ap(
				A3($author$project$MapRenderer$topicBorderStyle, topic.id, mapId, model),
				A3($author$project$MapRenderer$selectionStyle, topic.id, mapId, model)));
	});
var $author$project$Model$EditEnd = {$: 'EditEnd'};
var $author$project$Model$OnTextInput = function (a) {
	return {$: 'OnTextInput', a: a};
};
var $elm$core$String$lines = _String_lines;
var $author$project$ModelAPI$getTopicLabel = function (topic) {
	var _v0 = $elm$core$List$head(
		$elm$core$String$lines(topic.text));
	if (_v0.$ === 'Just') {
		var line = _v0.a;
		return line;
	} else {
		return '';
	}
};
var $elm$html$Html$input = _VirtualDom_node('input');
var $elm$html$Html$Events$onBlur = function (msg) {
	return A2(
		$elm$html$Html$Events$on,
		'blur',
		$elm$json$Json$Decode$succeed(msg));
};
var $elm$html$Html$Events$keyCode = A2($elm$json$Json$Decode$field, 'keyCode', $elm$json$Json$Decode$int);
var $author$project$Utils$keyDecoder = F2(
	function (key, msg_) {
		var isKey = function (code) {
			return _Utils_eq(code, key) ? $elm$json$Json$Decode$succeed(msg_) : $elm$json$Json$Decode$fail('not that key');
		};
		return A2($elm$json$Json$Decode$andThen, isKey, $elm$html$Html$Events$keyCode);
	});
var $author$project$Utils$onEnterOrEsc = function (msg_) {
	return A2(
		$elm$html$Html$Events$on,
		'keydown',
		$elm$json$Json$Decode$oneOf(
			_List_fromArray(
				[
					A2($author$project$Utils$keyDecoder, 13, msg_),
					A2($author$project$Utils$keyDecoder, 27, msg_)
				])));
};
var $elm$html$Html$Events$alwaysStop = function (x) {
	return _Utils_Tuple2(x, true);
};
var $elm$virtual_dom$VirtualDom$MayStopPropagation = function (a) {
	return {$: 'MayStopPropagation', a: a};
};
var $elm$html$Html$Events$stopPropagationOn = F2(
	function (event, decoder) {
		return A2(
			$elm$virtual_dom$VirtualDom$on,
			event,
			$elm$virtual_dom$VirtualDom$MayStopPropagation(decoder));
	});
var $elm$html$Html$Events$targetValue = A2(
	$elm$json$Json$Decode$at,
	_List_fromArray(
		['target', 'value']),
	$elm$json$Json$Decode$string);
var $elm$html$Html$Events$onInput = function (tagger) {
	return A2(
		$elm$html$Html$Events$stopPropagationOn,
		'input',
		A2(
			$elm$json$Json$Decode$map,
			$elm$html$Html$Events$alwaysStop,
			A2($elm$json$Json$Decode$map, tagger, $elm$html$Html$Events$targetValue)));
};
var $author$project$Utils$stopPropagationOnMousedown = function (msg_) {
	return A2(
		$elm$html$Html$Events$stopPropagationOn,
		'mousedown',
		$elm$json$Json$Decode$succeed(
			_Utils_Tuple2(msg_, true)));
};
var $author$project$MapRenderer$topicIconBoxStyle = function (props) {
	var r1 = $elm$core$String$fromInt($author$project$Config$topicRadius) + 'px';
	var r4 = function () {
		var _v0 = props.displayMode;
		if ((_v0.$ === 'Container') && (_v0.a.$ === 'WhiteBox')) {
			var _v1 = _v0.a;
			return '0';
		} else {
			return r1;
		}
	}();
	return _List_fromArray(
		[
			A2($elm$html$Html$Attributes$style, 'flex', 'none'),
			A2(
			$elm$html$Html$Attributes$style,
			'width',
			$elm$core$String$fromFloat($author$project$Config$topicSize.h) + 'px'),
			A2(
			$elm$html$Html$Attributes$style,
			'height',
			$elm$core$String$fromFloat($author$project$Config$topicSize.h) + 'px'),
			A2($elm$html$Html$Attributes$style, 'border-radius', r1 + (' 0 0 ' + r4)),
			A2($elm$html$Html$Attributes$style, 'background-color', 'black'),
			A2($elm$html$Html$Attributes$style, 'pointer-events', 'none')
		]);
};
var $author$project$Config$topicLabelWeight = 'bold';
var $author$project$MapRenderer$topicInputStyle = _List_fromArray(
	[
		A2($elm$html$Html$Attributes$style, 'font-family', $author$project$Config$mainFont),
		A2(
		$elm$html$Html$Attributes$style,
		'font-size',
		$elm$core$String$fromInt($author$project$Config$contentFontSize) + 'px'),
		A2($elm$html$Html$Attributes$style, 'font-weight', $author$project$Config$topicLabelWeight),
		A2($elm$html$Html$Attributes$style, 'width', '100%'),
		A2($elm$html$Html$Attributes$style, 'position', 'relative'),
		A2($elm$html$Html$Attributes$style, 'left', '-4px'),
		A2($elm$html$Html$Attributes$style, 'pointer-events', 'initial')
	]);
var $author$project$MapRenderer$topicLabelStyle = _List_fromArray(
	[
		A2(
		$elm$html$Html$Attributes$style,
		'font-size',
		$elm$core$String$fromInt($author$project$Config$contentFontSize) + 'px'),
		A2($elm$html$Html$Attributes$style, 'font-weight', $author$project$Config$topicLabelWeight),
		A2($elm$html$Html$Attributes$style, 'overflow', 'hidden'),
		A2($elm$html$Html$Attributes$style, 'text-overflow', 'ellipsis'),
		A2($elm$html$Html$Attributes$style, 'white-space', 'nowrap'),
		A2($elm$html$Html$Attributes$style, 'pointer-events', 'none')
	]);
var $elm$html$Html$Attributes$value = $elm$html$Html$Attributes$stringProperty('value');
var $author$project$IconMenu$Open = {$: 'Open'};
var $author$project$IconMenuAPI$topicIconStyle = _List_fromArray(
	[
		A2($elm$html$Html$Attributes$style, 'position', 'relative'),
		A2($elm$html$Html$Attributes$style, 'top', '0px'),
		A2($elm$html$Html$Attributes$style, 'left', '0px'),
		A2($elm$html$Html$Attributes$style, 'color', 'white')
	]);
var $author$project$IconMenuAPI$viewTopicIcon = F2(
	function (topicId, model) {
		var titleText = 'Choose icon';
		return A2(
			$elm$html$Html$button,
			_Utils_ap(
				_List_fromArray(
					[
						$elm$html$Html$Events$onClick(
						$author$project$AppModel$IconMenu($author$project$IconMenu$Open)),
						$elm$html$Html$Attributes$title(titleText)
					]),
				$author$project$IconMenuAPI$topicIconStyle),
			_List_fromArray(
				[
					$elm$html$Html$text('…')
				]));
	});
var $author$project$MapRenderer$labelTopicHtml = F4(
	function (topic, props, mapId, model) {
		var isEdit = _Utils_eq(
			model.editState,
			A2($author$project$Model$ItemEdit, topic.id, mapId));
		var textElem = isEdit ? A2(
			$elm$html$Html$input,
			_Utils_ap(
				_List_fromArray(
					[
						$elm$html$Html$Attributes$id(
						'dmx-input-' + ($elm$core$String$fromInt(topic.id) + ('-' + $elm$core$String$fromInt(mapId)))),
						$elm$html$Html$Attributes$value(topic.text),
						$elm$html$Html$Events$onInput(
						A2($elm$core$Basics$composeL, $author$project$AppModel$Edit, $author$project$Model$OnTextInput)),
						$elm$html$Html$Events$onBlur(
						$author$project$AppModel$Edit($author$project$Model$EditEnd)),
						$author$project$Utils$onEnterOrEsc(
						$author$project$AppModel$Edit($author$project$Model$EditEnd)),
						$author$project$Utils$stopPropagationOnMousedown($author$project$AppModel$NoOp)
					]),
				$author$project$MapRenderer$topicInputStyle),
			_List_Nil) : A2(
			$elm$html$Html$div,
			$author$project$MapRenderer$topicLabelStyle,
			_List_fromArray(
				[
					$elm$html$Html$text(
					$author$project$ModelAPI$getTopicLabel(topic))
				]));
		return _List_fromArray(
			[
				A2(
				$elm$html$Html$div,
				$author$project$MapRenderer$topicIconBoxStyle(props),
				_List_fromArray(
					[
						A2($author$project$IconMenuAPI$viewTopicIcon, topic.id, model)
					])),
				textElem
			]);
	});
var $author$project$MapRenderer$itemCountStyle = _List_fromArray(
	[
		A2(
		$elm$html$Html$Attributes$style,
		'font-size',
		$elm$core$String$fromInt($author$project$Config$contentFontSize) + 'px'),
		A2($elm$html$Html$Attributes$style, 'position', 'absolute'),
		A2($elm$html$Html$Attributes$style, 'left', 'calc(100% + 12px)')
	]);
var $author$project$MapRenderer$mapItemCount = F3(
	function (topicId, props, model) {
		var itemCount = function () {
			var _v0 = props.displayMode;
			if (_v0.$ === 'Monad') {
				return 0;
			} else {
				var _v1 = A2($author$project$ModelAPI$getMap, topicId, model.maps);
				if (_v1.$ === 'Just') {
					var map = _v1.a;
					return $elm$core$List$length(
						A2(
							$elm$core$List$filter,
							$author$project$ModelAPI$isVisible,
							$elm$core$Dict$values(map.items)));
				} else {
					return 0;
				}
			}
		}();
		return _List_fromArray(
			[
				A2(
				$elm$html$Html$div,
				$author$project$MapRenderer$itemCountStyle,
				_List_fromArray(
					[
						$elm$html$Html$text(
						$elm$core$String$fromInt(itemCount))
					]))
			]);
	});
var $author$project$MapRenderer$topicFlexboxStyle = F4(
	function (topic, props, mapId, model) {
		var r12 = $elm$core$String$fromInt($author$project$Config$topicRadius) + 'px';
		var r34 = function () {
			var _v0 = props.displayMode;
			if ((_v0.$ === 'Container') && (_v0.a.$ === 'WhiteBox')) {
				var _v1 = _v0.a;
				return '0';
			} else {
				return r12;
			}
		}();
		return _Utils_ap(
			_List_fromArray(
				[
					A2($elm$html$Html$Attributes$style, 'display', 'flex'),
					A2($elm$html$Html$Attributes$style, 'align-items', 'center'),
					A2($elm$html$Html$Attributes$style, 'gap', '8px'),
					A2(
					$elm$html$Html$Attributes$style,
					'width',
					$elm$core$String$fromFloat($author$project$Config$topicSize.w) + 'px'),
					A2(
					$elm$html$Html$Attributes$style,
					'height',
					$elm$core$String$fromFloat($author$project$Config$topicSize.h) + 'px'),
					A2($elm$html$Html$Attributes$style, 'border-radius', r12 + (' ' + (r12 + (' ' + (r34 + (' ' + r34))))))
				]),
			A3($author$project$MapRenderer$topicBorderStyle, topic.id, mapId, model));
	});
var $author$project$MapRenderer$topicPosStyle = function (_v0) {
	var pos = _v0.pos;
	return _List_fromArray(
		[
			A2(
			$elm$html$Html$Attributes$style,
			'left',
			$elm$core$String$fromFloat(pos.x - $author$project$Config$topicW2) + 'px'),
			A2(
			$elm$html$Html$Attributes$style,
			'top',
			$elm$core$String$fromFloat(pos.y - $author$project$Config$topicH2) + 'px')
		]);
};
var $author$project$MapRenderer$blackBoxTopic = F4(
	function (topic, props, mapPath, model) {
		var mapId = $author$project$ModelAPI$getMapId(mapPath);
		return _Utils_Tuple2(
			$author$project$MapRenderer$topicPosStyle(props),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$div,
					_Utils_ap(
						A4($author$project$MapRenderer$topicFlexboxStyle, topic, props, mapId, model),
						$author$project$MapRenderer$blackBoxStyle),
					_Utils_ap(
						A4($author$project$MapRenderer$labelTopicHtml, topic, props, mapId, model),
						A3($author$project$MapRenderer$mapItemCount, topic.id, props, model))),
					A2(
					$elm$html$Html$div,
					A3($author$project$MapRenderer$ghostTopicStyle, topic, mapId, model),
					_List_Nil)
				]));
	});
var $author$project$Model$OnTextareaInput = function (a) {
	return {$: 'OnTextareaInput', a: a};
};
var $author$project$ModelAPI$getTopicSize = F3(
	function (topicId, mapId, maps) {
		var _v0 = A3($author$project$ModelAPI$getTopicProps, topicId, mapId, maps);
		if (_v0.$ === 'Just') {
			var size = _v0.a.size;
			return $elm$core$Maybe$Just(size);
		} else {
			return A3(
				$author$project$Utils$fail,
				'getTopicSize',
				{mapId: mapId, topicId: topicId},
				$elm$core$Maybe$Nothing);
		}
	});
var $author$project$MapRenderer$detailTextEditStyle = F3(
	function (topicId, mapId, model) {
		var height = function () {
			var _v0 = A3($author$project$ModelAPI$getTopicSize, topicId, mapId, model.maps);
			if (_v0.$ === 'Just') {
				var size = _v0.a;
				return size.h;
			} else {
				return 0;
			}
		}();
		return _List_fromArray(
			[
				A2($elm$html$Html$Attributes$style, 'position', 'relative'),
				A2(
				$elm$html$Html$Attributes$style,
				'top',
				$elm$core$String$fromFloat(-$author$project$Config$topicBorderWidth) + 'px'),
				A2(
				$elm$html$Html$Attributes$style,
				'height',
				$elm$core$String$fromFloat(height) + 'px'),
				A2($elm$html$Html$Attributes$style, 'font-family', $author$project$Config$mainFont),
				A2($elm$html$Html$Attributes$style, 'border-color', 'black'),
				A2($elm$html$Html$Attributes$style, 'resize', 'none')
			]);
	});
var $author$project$MapRenderer$detailTextStyle = F3(
	function (topicId, mapId, model) {
		var r = $elm$core$String$fromInt($author$project$Config$topicRadius) + 'px';
		return _Utils_ap(
			_List_fromArray(
				[
					A2(
					$elm$html$Html$Attributes$style,
					'font-size',
					$elm$core$String$fromInt($author$project$Config$contentFontSize) + 'px'),
					A2(
					$elm$html$Html$Attributes$style,
					'width',
					$elm$core$String$fromFloat($author$project$Config$topicDetailMaxWidth) + 'px'),
					A2(
					$elm$html$Html$Attributes$style,
					'line-height',
					$elm$core$String$fromFloat($author$project$Config$topicLineHeight)),
					A2(
					$elm$html$Html$Attributes$style,
					'padding',
					$elm$core$String$fromInt($author$project$Config$topicDetailPadding) + 'px'),
					A2($elm$html$Html$Attributes$style, 'border-radius', '0 ' + (r + (' ' + (r + (' ' + r)))))
				]),
			_Utils_ap(
				A3($author$project$MapRenderer$topicBorderStyle, topicId, mapId, model),
				A3($author$project$MapRenderer$selectionStyle, topicId, mapId, model)));
	});
var $author$project$MapRenderer$detailTextViewStyle = _List_fromArray(
	[
		A2(
		$elm$html$Html$Attributes$style,
		'min-width',
		$elm$core$String$fromFloat($author$project$Config$topicSize.w - $author$project$Config$topicSize.h) + 'px'),
		A2($elm$html$Html$Attributes$style, 'max-width', 'max-content'),
		A2($elm$html$Html$Attributes$style, 'white-space', 'pre-wrap'),
		A2($elm$html$Html$Attributes$style, 'pointer-events', 'none')
	]);
var $author$project$MapRenderer$detailTopicIconBoxStyle = _List_fromArray(
	[
		A2(
		$elm$html$Html$Attributes$style,
		'padding-left',
		$elm$core$String$fromFloat($author$project$Config$topicBorderWidth) + 'px'),
		A2(
		$elm$html$Html$Attributes$style,
		'width',
		$elm$core$String$fromFloat($author$project$Config$topicSize.h - $author$project$Config$topicBorderWidth) + 'px')
	]);
var $author$project$MapRenderer$detailTopicStyle = function (_v0) {
	var pos = _v0.pos;
	return _List_fromArray(
		[
			A2($elm$html$Html$Attributes$style, 'display', 'flex'),
			A2(
			$elm$html$Html$Attributes$style,
			'left',
			$elm$core$String$fromFloat(pos.x - $author$project$Config$topicW2) + 'px'),
			A2(
			$elm$html$Html$Attributes$style,
			'top',
			$elm$core$String$fromFloat(pos.y - $author$project$Config$topicH2) + 'px')
		]);
};
var $author$project$Utils$multilineHtml = function (str) {
	return A3(
		$elm$core$List$foldr,
		F2(
			function (line, linesAcc) {
				return _Utils_ap(
					_List_fromArray(
						[
							$elm$html$Html$text(line),
							A2($elm$html$Html$br, _List_Nil, _List_Nil)
						]),
					linesAcc);
			}),
		_List_Nil,
		$elm$core$String$lines(str));
};
var $author$project$Utils$onEsc = function (msg_) {
	return A2(
		$elm$html$Html$Events$on,
		'keydown',
		A2($author$project$Utils$keyDecoder, 27, msg_));
};
var $elm$html$Html$textarea = _VirtualDom_node('textarea');
var $author$project$MapRenderer$detailTopic = F4(
	function (topic, props, mapPath, model) {
		var mapId = $author$project$ModelAPI$getMapId(mapPath);
		var isEdit = _Utils_eq(
			model.editState,
			A2($author$project$Model$ItemEdit, topic.id, mapId));
		var textElem = isEdit ? A2(
			$elm$html$Html$textarea,
			_Utils_ap(
				_List_fromArray(
					[
						$elm$html$Html$Attributes$id(
						'dmx-input-' + ($elm$core$String$fromInt(topic.id) + ('-' + $elm$core$String$fromInt(mapId)))),
						$elm$html$Html$Events$onInput(
						A2($elm$core$Basics$composeL, $author$project$AppModel$Edit, $author$project$Model$OnTextareaInput)),
						$elm$html$Html$Events$onBlur(
						$author$project$AppModel$Edit($author$project$Model$EditEnd)),
						$author$project$Utils$onEsc(
						$author$project$AppModel$Edit($author$project$Model$EditEnd)),
						$author$project$Utils$stopPropagationOnMousedown($author$project$AppModel$NoOp)
					]),
				_Utils_ap(
					A3($author$project$MapRenderer$detailTextStyle, topic.id, mapId, model),
					A3($author$project$MapRenderer$detailTextEditStyle, topic.id, mapId, model))),
			_List_fromArray(
				[
					$elm$html$Html$text(topic.text)
				])) : A2(
			$elm$html$Html$div,
			_Utils_ap(
				A3($author$project$MapRenderer$detailTextStyle, topic.id, mapId, model),
				$author$project$MapRenderer$detailTextViewStyle),
			$author$project$Utils$multilineHtml(topic.text));
		return _Utils_Tuple2(
			$author$project$MapRenderer$detailTopicStyle(props),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$div,
					_Utils_ap(
						$author$project$MapRenderer$topicIconBoxStyle(props),
						_Utils_ap(
							$author$project$MapRenderer$detailTopicIconBoxStyle,
							A3($author$project$MapRenderer$selectionStyle, topic.id, mapId, model))),
					_List_fromArray(
						[
							A2($author$project$IconMenuAPI$viewTopicIcon, topic.id, model)
						])),
					textElem
				]));
	});
var $elm$virtual_dom$VirtualDom$attribute = F2(
	function (key, value) {
		return A2(
			_VirtualDom_attribute,
			_VirtualDom_noOnOrFormAction(key),
			_VirtualDom_noJavaScriptOrHtmlUri(value));
	});
var $elm$html$Html$Attributes$attribute = $elm$virtual_dom$VirtualDom$attribute;
var $author$project$MapRenderer$posDecoder = A3(
	$elm$json$Json$Decode$map2,
	$author$project$Model$Point,
	A2($elm$json$Json$Decode$field, 'clientX', $elm$json$Json$Decode$float),
	A2($elm$json$Json$Decode$field, 'clientY', $elm$json$Json$Decode$float));
var $author$project$MapRenderer$topicCls = 'dmx-topic';
var $author$project$MapRenderer$dragHandle = F2(
	function (id, mapPath) {
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					A2($elm$html$Html$Attributes$attribute, 'data-drag-handle', '1'),
					A2($elm$html$Html$Attributes$attribute, 'title', 'Drag handle'),
					A2($elm$html$Html$Attributes$style, 'position', 'absolute'),
					A2($elm$html$Html$Attributes$style, 'left', '-6px'),
					A2($elm$html$Html$Attributes$style, 'top', '-6px'),
					A2($elm$html$Html$Attributes$style, 'width', '12px'),
					A2($elm$html$Html$Attributes$style, 'height', '12px'),
					A2($elm$html$Html$Attributes$style, 'border', '2px solid #f40'),
					A2($elm$html$Html$Attributes$style, 'border-radius', '50%'),
					A2($elm$html$Html$Attributes$style, 'background', 'rgba(255,64,0,0.2)'),
					A2($elm$html$Html$Attributes$style, 'cursor', 'move'),
					A2($elm$html$Html$Attributes$style, 'z-index', '999'),
					A2(
					$elm$html$Html$Events$on,
					'mousedown',
					A2(
						$elm$json$Json$Decode$map,
						A2(
							$elm$core$Basics$composeL,
							$author$project$AppModel$Mouse,
							A3($author$project$Mouse$DownItem, $author$project$MapRenderer$topicCls, id, mapPath)),
						$author$project$MapRenderer$posDecoder)),
					A2(
					$elm$html$Html$Events$on,
					'mouseenter',
					$elm$json$Json$Decode$succeed(
						$author$project$AppModel$Mouse(
							A3($author$project$Mouse$Over, $author$project$MapRenderer$topicCls, id, mapPath)))),
					A2(
					$elm$html$Html$Events$on,
					'mousemove',
					$elm$json$Json$Decode$succeed(
						$author$project$AppModel$Mouse(
							A3($author$project$Mouse$Over, $author$project$MapRenderer$topicCls, id, mapPath)))),
					A2(
					$elm$html$Html$Events$on,
					'mouseup',
					$elm$json$Json$Decode$succeed(
						$author$project$AppModel$Mouse($author$project$Mouse$Up)))
				]),
			_List_Nil);
	});
var $author$project$MapRenderer$effectiveDisplayMode = F3(
	function (topicId, displayMode, model) {
		var isLimbo = _Utils_eq(
			model.search.menu,
			$author$project$Search$Open(
				$elm$core$Maybe$Just(topicId)));
		if (isLimbo) {
			if (displayMode.$ === 'Monad') {
				return $author$project$Model$Monad($author$project$Model$Detail);
			} else {
				return $author$project$Model$Container($author$project$Model$WhiteBox);
			}
		} else {
			return displayMode;
		}
	});
var $elm$svg$Svg$g = $elm$svg$Svg$trustedNode('g');
var $elm$svg$Svg$Attributes$transform = _VirtualDom_attribute('transform');
var $author$project$MapRenderer$gAttr = F3(
	function (_v0, mapRect, _v1) {
		return _List_fromArray(
			[
				$elm$svg$Svg$Attributes$transform(
				'translate(' + ($elm$core$String$fromFloat(-mapRect.x1) + (' ' + ($elm$core$String$fromFloat(-mapRect.y1) + ')'))))
			]);
	});
var $author$project$Compat$ModelAPI$getMapItemById = $author$project$ModelAPI$getMapItemById;
var $elm$html$Html$Attributes$class = $elm$html$Html$Attributes$stringProperty('className');
var $author$project$MapRenderer$htmlTopicAttr = F2(
	function (id, mapPath) {
		return _List_fromArray(
			[
				A2($elm$html$Html$Attributes$attribute, 'data-elm-probe', 'htmlTopicAttr:v2'),
				$elm$html$Html$Attributes$class('dmx-topic topic monad'),
				A2($elm$html$Html$Attributes$style, 'cursor', 'move'),
				A2(
				$elm$html$Html$Events$on,
				'mousedown',
				A2(
					$elm$json$Json$Decode$map,
					A2(
						$elm$core$Basics$composeL,
						$author$project$AppModel$Mouse,
						A3($author$project$Mouse$DownItem, $author$project$MapRenderer$topicCls, id, mapPath)),
					$author$project$MapRenderer$posDecoder)),
				A2(
				$elm$html$Html$Events$on,
				'mouseenter',
				$elm$json$Json$Decode$succeed(
					$author$project$AppModel$Mouse(
						A3($author$project$Mouse$Over, $author$project$MapRenderer$topicCls, id, mapPath)))),
				A2(
				$elm$html$Html$Events$on,
				'mousemove',
				$elm$json$Json$Decode$succeed(
					$author$project$AppModel$Mouse(
						A3($author$project$Mouse$Over, $author$project$MapRenderer$topicCls, id, mapPath)))),
				A2(
				$elm$html$Html$Events$on,
				'mouseup',
				$elm$json$Json$Decode$succeed(
					$author$project$AppModel$Mouse($author$project$Mouse$Up)))
			]);
	});
var $author$project$ModelAPI$isFullscreen = F2(
	function (mapId, model) {
		return _Utils_eq(
			$author$project$ModelAPI$activeMap(model),
			mapId);
	});
var $author$project$MapRenderer$labelTopic = F4(
	function (topic, props, mapPath, model) {
		var mapId = $author$project$ModelAPI$getMapId(mapPath);
		return _Utils_Tuple2(
			_Utils_ap(
				$author$project$MapRenderer$topicPosStyle(props),
				_Utils_ap(
					A4($author$project$MapRenderer$topicFlexboxStyle, topic, props, mapId, model),
					A3($author$project$MapRenderer$selectionStyle, topic.id, mapId, model))),
			A4($author$project$MapRenderer$labelTopicHtml, topic, props, mapId, model));
	});
var $elm$core$Basics$round = _Basics_round;
var $author$project$MapRenderer$svgStyle = _List_fromArray(
	[
		A2($elm$html$Html$Attributes$style, 'position', 'absolute'),
		A2($elm$html$Html$Attributes$style, 'top', '0'),
		A2($elm$html$Html$Attributes$style, 'left', '0')
	]);
var $author$project$MapRenderer$topicLayerStyle = function (mapRect) {
	return _List_fromArray(
		[
			A2($elm$html$Html$Attributes$style, 'position', 'absolute'),
			A2(
			$elm$html$Html$Attributes$style,
			'left',
			$elm$core$String$fromFloat(-mapRect.x1) + 'px'),
			A2(
			$elm$html$Html$Attributes$style,
			'top',
			$elm$core$String$fromFloat(-mapRect.y1) + 'px')
		]);
};
var $author$project$MapRenderer$topicStyle = F2(
	function (id, model) {
		var isLimbo = _Utils_eq(
			model.search.menu,
			$author$project$Search$Open(
				$elm$core$Maybe$Just(id)));
		var isDragging = function () {
			var _v0 = model.mouse.dragState;
			if ((_v0.$ === 'Drag') && (_v0.a.$ === 'DragTopic')) {
				var _v1 = _v0.a;
				var id_ = _v0.b;
				return _Utils_eq(id_, id);
			} else {
				return false;
			}
		}();
		return _List_fromArray(
			[
				A2($elm$html$Html$Attributes$style, 'position', 'absolute'),
				A2(
				$elm$html$Html$Attributes$style,
				'opacity',
				isLimbo ? '.5' : '1'),
				A2(
				$elm$html$Html$Attributes$style,
				'z-index',
				isDragging ? '1' : '2')
			]);
	});
var $author$project$MapRenderer$unboxedTopic = F4(
	function (topic, props, mapPath, model) {
		var _v0 = A4($author$project$MapRenderer$labelTopic, topic, props, mapPath, model);
		var style = _v0.a;
		var children = _v0.b;
		return _Utils_Tuple2(
			style,
			_Utils_ap(
				children,
				A3($author$project$MapRenderer$mapItemCount, topic.id, props, model)));
	});
var $author$project$Config$assocRadius = 14;
var $author$project$Config$assocColor = 'black';
var $author$project$Config$assocWidth = 1.5;
var $author$project$MapRenderer$lineDasharray = function (maybeAssoc) {
	if (maybeAssoc.$ === 'Just') {
		var itemType = maybeAssoc.a.itemType;
		switch (itemType) {
			case 'dmx.association':
				return '5 0';
			case 'dmx.composition':
				return '5';
			default:
				return '1';
		}
	} else {
		return '5 0';
	}
};
var $elm$svg$Svg$Attributes$strokeDasharray = _VirtualDom_attribute('stroke-dasharray');
var $author$project$MapRenderer$lineStyle = function (assoc) {
	return _List_fromArray(
		[
			$elm$svg$Svg$Attributes$stroke($author$project$Config$assocColor),
			$elm$svg$Svg$Attributes$strokeWidth(
			$elm$core$String$fromFloat($author$project$Config$assocWidth) + 'px'),
			$elm$svg$Svg$Attributes$strokeDasharray(
			$author$project$MapRenderer$lineDasharray(assoc)),
			$elm$svg$Svg$Attributes$fill('none')
		]);
};
var $author$project$MapRenderer$taxiLine = F3(
	function (assoc, pos1, pos2) {
		if (_Utils_cmp(
			$elm$core$Basics$abs(pos2.x - pos1.x),
			2 * $author$project$Config$assocRadius) < 0) {
			var xm = (pos1.x + pos2.x) / 2;
			return A2(
				$elm$svg$Svg$path,
				A2(
					$elm$core$List$cons,
					$elm$svg$Svg$Attributes$d(
						'M ' + ($elm$core$String$fromFloat(xm) + (' ' + ($elm$core$String$fromFloat(pos1.y) + (' V ' + $elm$core$String$fromFloat(pos2.y)))))),
					$author$project$MapRenderer$lineStyle(assoc)),
				_List_Nil);
		} else {
			if (_Utils_cmp(
				$elm$core$Basics$abs(pos2.y - pos1.y),
				2 * $author$project$Config$assocRadius) < 0) {
				var ym = (pos1.y + pos2.y) / 2;
				return A2(
					$elm$svg$Svg$path,
					A2(
						$elm$core$List$cons,
						$elm$svg$Svg$Attributes$d(
							'M ' + ($elm$core$String$fromFloat(pos1.x) + (' ' + ($elm$core$String$fromFloat(ym) + (' H ' + $elm$core$String$fromFloat(pos2.x)))))),
						$author$project$MapRenderer$lineStyle(assoc)),
					_List_Nil);
			} else {
				var ym = (pos1.y + pos2.y) / 2;
				var sy = (_Utils_cmp(pos2.y, pos1.y) > 0) ? (-1) : 1;
				var y1 = $elm$core$String$fromFloat(ym + (sy * $author$project$Config$assocRadius));
				var y2 = $elm$core$String$fromFloat(ym - (sy * $author$project$Config$assocRadius));
				var sx = (_Utils_cmp(pos2.x, pos1.x) > 0) ? 1 : (-1);
				var x1 = $elm$core$String$fromFloat(pos1.x + (sx * $author$project$Config$assocRadius));
				var x2 = $elm$core$String$fromFloat(pos2.x - (sx * $author$project$Config$assocRadius));
				var sweep1 = (sy === 1) ? ((sx === 1) ? 1 : 0) : ((sx === 1) ? 0 : 1);
				var sweep2 = 1 - sweep1;
				var sw2 = $elm$core$String$fromInt(sweep2);
				var sw1 = $elm$core$String$fromInt(sweep1);
				var r = $elm$core$String$fromFloat($author$project$Config$assocRadius);
				return A2(
					$elm$svg$Svg$path,
					A2(
						$elm$core$List$cons,
						$elm$svg$Svg$Attributes$d(
							'M ' + ($elm$core$String$fromFloat(pos1.x) + (' ' + ($elm$core$String$fromFloat(pos1.y) + (' V ' + (y1 + (' A ' + (r + (' ' + (r + (' 0 0 ' + (sw1 + (' ' + (x1 + (' ' + ($elm$core$String$fromFloat(ym) + (' H ' + (x2 + (' A ' + (r + (' ' + (r + (' 0 0 ' + (sw2 + (' ' + ($elm$core$String$fromFloat(pos2.x) + (' ' + (y2 + (' V ' + $elm$core$String$fromFloat(pos2.y)))))))))))))))))))))))))))))),
						$author$project$MapRenderer$lineStyle(assoc)),
					_List_Nil);
			}
		}
	});
var $author$project$MapRenderer$lineFunc = $author$project$MapRenderer$taxiLine;
var $author$project$MapRenderer$accumulateMapRect = F3(
	function (posAcc, mapId, model) {
		var _v0 = A2($author$project$ModelAPI$getMap, mapId, model.maps);
		if (_v0.$ === 'Just') {
			var map = _v0.a;
			return A2($author$project$Model$Point, posAcc.x - map.rect.x1, posAcc.y - map.rect.y1);
		} else {
			return A2($author$project$Model$Point, 0, 0);
		}
	});
var $author$project$MapRenderer$absMapPos = F3(
	function (mapPath, posAcc, model) {
		if (mapPath.b) {
			if (!mapPath.b.b) {
				var mapId = mapPath.a;
				return A3($author$project$MapRenderer$accumulateMapRect, posAcc, mapId, model);
			} else {
				var mapId = mapPath.a;
				var _v3 = mapPath.b;
				var parentMapId = _v3.a;
				var mapIds = _v3.b;
				return A5($author$project$MapRenderer$accumulateMapPos, posAcc, mapId, parentMapId, mapIds, model);
			}
		} else {
			return A3(
				$author$project$Utils$logError,
				'absMapPos',
				'mapPath is empty!',
				A2($author$project$Model$Point, 0, 0));
		}
	});
var $author$project$MapRenderer$accumulateMapPos = F5(
	function (posAcc, mapId, parentMapId, mapIds, model) {
		var _v0 = A3($author$project$MapRenderer$accumulateMapRect, posAcc, mapId, model);
		var x = _v0.x;
		var y = _v0.y;
		var _v1 = A3($author$project$ModelAPI$getTopicPos, mapId, parentMapId, model.maps);
		if (_v1.$ === 'Just') {
			var mapPos = _v1.a;
			return A3(
				$author$project$MapRenderer$absMapPos,
				A2($elm$core$List$cons, parentMapId, mapIds),
				A2($author$project$Model$Point, (x + mapPos.x) - $author$project$Config$topicW2, (y + mapPos.y) + $author$project$Config$topicH2),
				model);
		} else {
			return A2($author$project$Model$Point, 0, 0);
		}
	});
var $author$project$MapRenderer$relPos = F3(
	function (pos, mapPath, model) {
		var posAbs = A3(
			$author$project$MapRenderer$absMapPos,
			mapPath,
			A2($author$project$Model$Point, 0, 0),
			model);
		return A2($author$project$Model$Point, pos.x - posAbs.x, pos.y - posAbs.y);
	});
var $author$project$MapRenderer$viewLimboAssoc = F2(
	function (mapId, model) {
		var _v0 = model.mouse.dragState;
		if ((_v0.$ === 'Drag') && (_v0.a.$ === 'DrawAssoc')) {
			var _v1 = _v0.a;
			var mapPath = _v0.c;
			var origPos = _v0.d;
			var pos = _v0.e;
			return _Utils_eq(
				$author$project$ModelAPI$getMapId(mapPath),
				mapId) ? _List_fromArray(
				[
					A3(
					$author$project$MapRenderer$lineFunc,
					$elm$core$Maybe$Nothing,
					origPos,
					A3($author$project$MapRenderer$relPos, pos, mapPath, model))
				]) : _List_Nil;
		} else {
			return _List_Nil;
		}
	});
var $elm$svg$Svg$Attributes$dominantBaseline = _VirtualDom_attribute('dominant-baseline');
var $elm$svg$Svg$Attributes$fillOpacity = _VirtualDom_attribute('fill-opacity');
var $elm$svg$Svg$Attributes$fontFamily = _VirtualDom_attribute('font-family');
var $elm$svg$Svg$Attributes$fontSize = _VirtualDom_attribute('font-size');
var $elm$svg$Svg$Attributes$fontWeight = _VirtualDom_attribute('font-weight');
var $author$project$MapRenderer$isTargeted = F3(
	function (topicId, mapId, model) {
		var _v0 = model.mouse.dragState;
		_v0$2:
		while (true) {
			if (_v0.$ === 'Drag') {
				if (_v0.a.$ === 'DragTopic') {
					if (_v0.c.b) {
						var _v1 = _v0.a;
						var _v2 = _v0.c;
						var mapId_ = _v2.a;
						var target = _v0.f;
						return A3($author$project$MapRenderer$isTarget, topicId, mapId, target) && (!_Utils_eq(mapId_, topicId));
					} else {
						break _v0$2;
					}
				} else {
					if (_v0.c.b) {
						var _v3 = _v0.a;
						var _v4 = _v0.c;
						var mapId_ = _v4.a;
						var target = _v0.f;
						return A3($author$project$MapRenderer$isTarget, topicId, mapId, target) && _Utils_eq(mapId_, mapId);
					} else {
						break _v0$2;
					}
				}
			} else {
				break _v0$2;
			}
		}
		return false;
	});
var $elm$core$Basics$ge = _Utils_ge;
var $elm$core$String$trim = _String_trim;
var $elm$core$String$words = _String_words;
var $author$project$MapRenderer$monadMark = function (title) {
	var trimmed = $elm$core$String$trim(title);
	var word = A2(
		$elm$core$Maybe$withDefault,
		trimmed,
		$elm$core$List$head(
			$elm$core$String$words(trimmed)));
	var take = F2(
		function (n, s) {
			return A2($elm$core$String$left, n, s);
		});
	return $elm$core$String$isEmpty(trimmed) ? '•' : (($elm$core$String$length(word) >= 1) ? A2(
		take,
		A2(
			$elm$core$Basics$min,
			3,
			$elm$core$String$length(word)),
		word) : A2(
		take,
		A2(
			$elm$core$Basics$min,
			2,
			$elm$core$String$length(trimmed)),
		trimmed));
};
var $elm$svg$Svg$Events$on = $elm$html$Html$Events$on;
var $elm$svg$Svg$Attributes$style = _VirtualDom_attribute('style');
var $author$project$MapRenderer$svgTopicAttr = F2(
	function (id, mapPath) {
		return _List_fromArray(
			[
				$elm$svg$Svg$Attributes$class('dmx-topic topic monad'),
				$elm$svg$Svg$Attributes$style('cursor: move'),
				A2(
				$elm$svg$Svg$Events$on,
				'mousedown',
				A2(
					$elm$json$Json$Decode$map,
					A2(
						$elm$core$Basics$composeL,
						$author$project$AppModel$Mouse,
						A3($author$project$Mouse$DownItem, $author$project$MapRenderer$topicCls, id, mapPath)),
					$author$project$MapRenderer$posDecoder)),
				A2(
				$elm$svg$Svg$Events$on,
				'pointerdown',
				A2(
					$elm$json$Json$Decode$map,
					A2(
						$elm$core$Basics$composeL,
						$author$project$AppModel$Mouse,
						A3($author$project$Mouse$DownItem, $author$project$MapRenderer$topicCls, id, mapPath)),
					$author$project$MapRenderer$posDecoder)),
				A2(
				$elm$svg$Svg$Events$on,
				'mouseenter',
				$elm$json$Json$Decode$succeed(
					$author$project$AppModel$Mouse(
						A3($author$project$Mouse$Over, $author$project$MapRenderer$topicCls, id, mapPath)))),
				A2(
				$elm$svg$Svg$Events$on,
				'mousemove',
				$elm$json$Json$Decode$succeed(
					$author$project$AppModel$Mouse(
						A3($author$project$Mouse$Over, $author$project$MapRenderer$topicCls, id, mapPath)))),
				A2(
				$elm$svg$Svg$Events$on,
				'mouseup',
				$elm$json$Json$Decode$succeed(
					$author$project$AppModel$Mouse($author$project$Mouse$Up)))
			]);
	});
var $elm$svg$Svg$text = $elm$virtual_dom$VirtualDom$text;
var $elm$svg$Svg$Attributes$textAnchor = _VirtualDom_attribute('text-anchor');
var $elm$svg$Svg$text_ = $elm$svg$Svg$trustedNode('text');
var $elm$svg$Svg$title = $elm$svg$Svg$trustedNode('title');
var $author$project$MapRenderer$viewTopicSvg = F4(
	function (topic, props, mapPath, model) {
		var rVal = ($author$project$Config$topicSize.h / 2) - $author$project$Config$topicBorderWidth;
		var rStr = $elm$core$String$fromFloat(rVal);
		var mark = $author$project$MapRenderer$monadMark(topic.text);
		var mapId = $author$project$ModelAPI$getMapId(mapPath);
		var selected = A3($author$project$ModelAPI$isSelected, topic.id, mapId, model);
		var dash = A3($author$project$MapRenderer$isTargeted, topic.id, mapId, model) ? '4 2' : '0';
		var cyStr = $elm$core$String$fromFloat(props.pos.y);
		var cxStr = $elm$core$String$fromFloat(props.pos.x);
		var mainNodes = _List_fromArray(
			[
				A2(
				$elm$svg$Svg$rect,
				_List_fromArray(
					[
						$elm$svg$Svg$Attributes$x(
						$elm$core$String$fromFloat(props.pos.x - rVal)),
						$elm$svg$Svg$Attributes$y(
						$elm$core$String$fromFloat(props.pos.y - rVal)),
						$elm$svg$Svg$Attributes$width(
						$elm$core$String$fromFloat(rVal * 2)),
						$elm$svg$Svg$Attributes$height(
						$elm$core$String$fromFloat(rVal * 2)),
						$elm$svg$Svg$Attributes$fill('transparent'),
						A2($elm$html$Html$Attributes$attribute, 'pointer-events', 'all')
					]),
				_List_Nil),
				A2(
				$elm$svg$Svg$circle,
				_List_fromArray(
					[
						$elm$svg$Svg$Attributes$cx(cxStr),
						$elm$svg$Svg$Attributes$cy(cyStr),
						$elm$svg$Svg$Attributes$r(rStr),
						$elm$svg$Svg$Attributes$fill('white'),
						$elm$svg$Svg$Attributes$stroke('black'),
						$elm$svg$Svg$Attributes$strokeWidth(
						$elm$core$String$fromFloat($author$project$Config$topicBorderWidth) + 'px'),
						$elm$svg$Svg$Attributes$strokeDasharray(dash)
					]),
				_List_Nil),
				A2(
				$elm$svg$Svg$text_,
				_List_fromArray(
					[
						$elm$svg$Svg$Attributes$x(cxStr),
						$elm$svg$Svg$Attributes$y(cyStr),
						$elm$svg$Svg$Attributes$textAnchor('middle'),
						$elm$svg$Svg$Attributes$dominantBaseline('central'),
						$elm$svg$Svg$Attributes$fontFamily($author$project$Config$mainFont),
						$elm$svg$Svg$Attributes$fontSize(
						$elm$core$String$fromInt($author$project$Config$contentFontSize) + 'px'),
						$elm$svg$Svg$Attributes$fontWeight($author$project$Config$topicLabelWeight),
						$elm$svg$Svg$Attributes$fill('black')
					]),
				_List_fromArray(
					[
						$elm$svg$Svg$text(mark)
					])),
				A2(
				$elm$svg$Svg$title,
				_List_Nil,
				_List_fromArray(
					[
						$elm$svg$Svg$text(
						$author$project$ModelAPI$getTopicLabel(topic))
					]))
			]);
		var shadowNodes = selected ? _List_fromArray(
			[
				A2(
				$elm$svg$Svg$circle,
				_List_fromArray(
					[
						$elm$svg$Svg$Attributes$cx(cxStr),
						$elm$svg$Svg$Attributes$cy(cyStr),
						$elm$svg$Svg$Attributes$r(rStr),
						$elm$svg$Svg$Attributes$fill('black'),
						$elm$svg$Svg$Attributes$fillOpacity('0.20'),
						$elm$svg$Svg$Attributes$transform('translate(5,5)')
					]),
				_List_Nil)
			]) : _List_Nil;
		return A2(
			$elm$svg$Svg$g,
			_Utils_ap(
				A2($author$project$MapRenderer$svgTopicAttr, topic.id, mapPath),
				_List_fromArray(
					[
						$elm$svg$Svg$Attributes$transform('translate(0,0)')
					])),
			mainNodes);
	});
var $author$project$Config$whiteBoxRadius = 14;
var $author$project$MapRenderer$whiteBoxStyle = F4(
	function (topicId, rect, mapId, model) {
		var width = rect.x2 - rect.x1;
		var r = $elm$core$String$fromInt($author$project$Config$whiteBoxRadius) + 'px';
		var height = rect.y2 - rect.y1;
		return _Utils_ap(
			_List_fromArray(
				[
					A2($elm$html$Html$Attributes$style, 'position', 'absolute'),
					A2(
					$elm$html$Html$Attributes$style,
					'left',
					$elm$core$String$fromFloat(-$author$project$Config$topicBorderWidth) + 'px'),
					A2(
					$elm$html$Html$Attributes$style,
					'top',
					$elm$core$String$fromFloat($author$project$Config$topicSize.h - (2 * $author$project$Config$topicBorderWidth)) + 'px'),
					A2(
					$elm$html$Html$Attributes$style,
					'width',
					$elm$core$String$fromFloat(width) + 'px'),
					A2(
					$elm$html$Html$Attributes$style,
					'height',
					$elm$core$String$fromFloat(height) + 'px'),
					A2($elm$html$Html$Attributes$style, 'border-radius', '0 ' + (r + (' ' + (r + (' ' + r)))))
				]),
			_Utils_ap(
				A3($author$project$MapRenderer$topicBorderStyle, topicId, mapId, model),
				A3($author$project$MapRenderer$selectionStyle, topicId, mapId, model)));
	});
var $author$project$MapRenderer$limboTopic = F2(
	function (mapId, model) {
		var activeMapId = $author$project$ModelAPI$activeMap(model);
		if (_Utils_eq(mapId, activeMapId)) {
			var _v18 = model.search.menu;
			if ((_v18.$ === 'Open') && (_v18.a.$ === 'Just')) {
				var topicId = _v18.a.a;
				if (A3($author$project$ModelAPI$isItemInMap, topicId, activeMapId, model)) {
					var _v19 = A3($author$project$Compat$ModelAPI$getMapItemById, topicId, activeMapId, model.maps);
					if (_v19.$ === 'Just') {
						var mapItem = _v19.a;
						if (mapItem.hidden) {
							var _v20 = A2($elm$core$Dict$get, topicId, model.items);
							if (_v20.$ === 'Just') {
								var info = _v20.a.info;
								var _v21 = _Utils_Tuple2(info, mapItem.props);
								if ((_v21.a.$ === 'Topic') && (_v21.b.$ === 'MapTopic')) {
									var topic = _v21.a.a;
									var props = _v21.b.a;
									var _v22 = A3($author$project$MapRenderer$effectiveDisplayMode, topic.id, props.displayMode, model);
									if (_v22.$ === 'Monad') {
										if (_v22.a.$ === 'LabelOnly') {
											var _v23 = _v22.a;
											return _List_Nil;
										} else {
											var _v24 = _v22.a;
											return _List_fromArray(
												[
													A4($author$project$MapRenderer$viewTopic, topic, props, _List_Nil, model)
												]);
										}
									} else {
										return _List_fromArray(
											[
												A4($author$project$MapRenderer$viewTopic, topic, props, _List_Nil, model)
											]);
									}
								} else {
									return _List_Nil;
								}
							} else {
								return _List_Nil;
							}
						} else {
							return _List_Nil;
						}
					} else {
						return _List_Nil;
					}
				} else {
					var props = A3($author$project$ModelAPI$defaultProps, topicId, $author$project$Config$topicSize, model);
					var _v25 = A2($elm$core$Dict$get, topicId, model.items);
					if (_v25.$ === 'Just') {
						var info = _v25.a.info;
						if (info.$ === 'Topic') {
							var topic = info.a;
							var _v27 = A3($author$project$MapRenderer$effectiveDisplayMode, topic.id, props.displayMode, model);
							if (_v27.$ === 'Monad') {
								if (_v27.a.$ === 'LabelOnly') {
									var _v28 = _v27.a;
									return _List_Nil;
								} else {
									var _v29 = _v27.a;
									return _List_fromArray(
										[
											A4($author$project$MapRenderer$viewTopic, topic, props, _List_Nil, model)
										]);
								}
							} else {
								return _List_fromArray(
									[
										A4($author$project$MapRenderer$viewTopic, topic, props, _List_Nil, model)
									]);
							}
						} else {
							return _List_Nil;
						}
					} else {
						return _List_Nil;
					}
				}
			} else {
				return _List_Nil;
			}
		} else {
			return _List_Nil;
		}
	});
var $author$project$MapRenderer$mapInfo = F3(
	function (mapId, mapPath, model) {
		var parentMapId = $author$project$ModelAPI$getMapId(mapPath);
		var _v17 = A2($author$project$ModelAPI$getMap, mapId, model.maps);
		if (_v17.$ === 'Just') {
			var map = _v17.a;
			return _Utils_Tuple3(
				A3($author$project$MapRenderer$mapItems, map, mapPath, model),
				map.rect,
				A2($author$project$ModelAPI$isFullscreen, mapId, model) ? _Utils_Tuple2(
					{h: '100%', w: '100%'},
					_List_Nil) : _Utils_Tuple2(
					{
						h: $elm$core$String$fromInt(
							$elm$core$Basics$round(map.rect.y2 - map.rect.y1)),
						w: $elm$core$String$fromInt(
							$elm$core$Basics$round(map.rect.x2 - map.rect.x1))
					},
					A4($author$project$MapRenderer$whiteBoxStyle, mapId, map.rect, parentMapId, model)));
		} else {
			return _Utils_Tuple3(
				_Utils_Tuple3(_List_Nil, _List_Nil, _List_Nil),
				A4($author$project$Model$Rectangle, 0, 0, 0, 0),
				_Utils_Tuple2(
					{h: '0', w: '0'},
					_List_Nil));
		}
	});
var $author$project$MapRenderer$mapItems = F3(
	function (map, mapPath, model) {
		var newPath = A2($elm$core$List$cons, map.id, mapPath);
		return A3(
			$elm$core$List$foldr,
			F2(
				function (_v10, _v11) {
					var id = _v10.id;
					var props = _v10.props;
					var htmlTopics = _v11.a;
					var assocs = _v11.b;
					var topicsSvg = _v11.c;
					var _v12 = A2($elm$core$Dict$get, id, model.items);
					if (_v12.$ === 'Just') {
						var info = _v12.a.info;
						var _v13 = _Utils_Tuple2(info, props);
						if ((_v13.a.$ === 'Topic') && (_v13.b.$ === 'MapTopic')) {
							var topic = _v13.a.a;
							var tProps = _v13.b.a;
							var _v14 = A3($author$project$MapRenderer$effectiveDisplayMode, topic.id, tProps.displayMode, model);
							if (_v14.$ === 'Monad') {
								if (_v14.a.$ === 'LabelOnly') {
									var _v15 = _v14.a;
									return _Utils_Tuple3(
										htmlTopics,
										assocs,
										A2(
											$elm$core$List$cons,
											A4($author$project$MapRenderer$viewTopicSvg, topic, tProps, newPath, model),
											topicsSvg));
								} else {
									var _v16 = _v14.a;
									return _Utils_Tuple3(
										A2(
											$elm$core$List$cons,
											A4($author$project$MapRenderer$viewTopic, topic, tProps, newPath, model),
											htmlTopics),
										assocs,
										topicsSvg);
								}
							} else {
								return _Utils_Tuple3(
									A2(
										$elm$core$List$cons,
										A4($author$project$MapRenderer$viewTopic, topic, tProps, newPath, model),
										htmlTopics),
									assocs,
									topicsSvg);
							}
						} else {
							return A3(
								$author$project$Utils$logError,
								'mapItems',
								'problem with item ' + $elm$core$String$fromInt(id),
								_Utils_Tuple3(htmlTopics, assocs, topicsSvg));
						}
					} else {
						return A3(
							$author$project$Utils$logError,
							'mapItems',
							'problem with item ' + $elm$core$String$fromInt(id),
							_Utils_Tuple3(htmlTopics, assocs, topicsSvg));
					}
				}),
			_Utils_Tuple3(_List_Nil, _List_Nil, _List_Nil),
			A2(
				$elm$core$List$filter,
				$author$project$ModelAPI$isVisible,
				$elm$core$Dict$values(map.items)));
	});
var $author$project$MapRenderer$viewMap = F3(
	function (mapId, mapPath, model) {
		var _v7 = A3($author$project$MapRenderer$mapInfo, mapId, mapPath, model);
		var _v8 = _v7.a;
		var topicsHtml = _v8.a;
		var assocsSvg = _v8.b;
		var topicsSvg = _v8.c;
		var mapRect = _v7.b;
		var _v9 = _v7.c;
		var svgSize = _v9.a;
		var mapStyle = _v9.b;
		return A2(
			$elm$html$Html$div,
			mapStyle,
			_List_fromArray(
				[
					A2(
					$elm$html$Html$div,
					$author$project$MapRenderer$topicLayerStyle(mapRect),
					_Utils_ap(
						topicsHtml,
						A2($author$project$MapRenderer$limboTopic, mapId, model))),
					A2(
					$elm$svg$Svg$svg,
					_Utils_ap(
						_List_fromArray(
							[
								$elm$svg$Svg$Attributes$width(svgSize.w),
								$elm$svg$Svg$Attributes$height(svgSize.h)
							]),
						$author$project$MapRenderer$svgStyle),
					_List_fromArray(
						[
							A2(
							$elm$svg$Svg$g,
							A3($author$project$MapRenderer$gAttr, mapId, mapRect, model),
							_Utils_ap(
								assocsSvg,
								_Utils_ap(
									topicsSvg,
									A2($author$project$MapRenderer$viewLimboAssoc, mapId, model))))
						]))
				]));
	});
var $author$project$MapRenderer$viewTopic = F4(
	function (topic, props, mapPath, model) {
		var topicFunc = function () {
			var _v2 = A3($author$project$MapRenderer$effectiveDisplayMode, topic.id, props.displayMode, model);
			if (_v2.$ === 'Monad') {
				if (_v2.a.$ === 'Detail') {
					var _v3 = _v2.a;
					return $author$project$MapRenderer$detailTopic;
				} else {
					return $author$project$MapRenderer$labelTopic;
				}
			} else {
				switch (_v2.a.$) {
					case 'BlackBox':
						var _v4 = _v2.a;
						return $author$project$MapRenderer$blackBoxTopic;
					case 'WhiteBox':
						var _v5 = _v2.a;
						return $author$project$MapRenderer$whiteBoxTopic;
					default:
						var _v6 = _v2.a;
						return $author$project$MapRenderer$unboxedTopic;
				}
			}
		}();
		var _v1 = A4(topicFunc, topic, props, mapPath, model);
		var style = _v1.a;
		var children = _v1.b;
		return A2(
			$elm$html$Html$div,
			_Utils_ap(
				A2($author$project$MapRenderer$htmlTopicAttr, topic.id, mapPath),
				_Utils_ap(
					A2($author$project$MapRenderer$topicStyle, topic.id, model),
					style)),
			A2(
				$elm$core$List$cons,
				A2($author$project$MapRenderer$dragHandle, topic.id, mapPath),
				children));
	});
var $author$project$MapRenderer$whiteBoxTopic = F4(
	function (topic, props, mapPath, model) {
		var _v0 = A4($author$project$MapRenderer$labelTopic, topic, props, mapPath, model);
		var style = _v0.a;
		var children = _v0.b;
		return _Utils_Tuple2(
			style,
			_Utils_ap(
				children,
				_Utils_ap(
					A3($author$project$MapRenderer$mapItemCount, topic.id, props, model),
					_List_fromArray(
						[
							A3($author$project$MapRenderer$viewMap, topic.id, mapPath, model)
						]))));
	});
var $author$project$Search$ClickItem = function (a) {
	return {$: 'ClickItem', a: a};
};
var $author$project$Search$HoverItem = function (a) {
	return {$: 'HoverItem', a: a};
};
var $author$project$Search$UnhoverItem = function (a) {
	return {$: 'UnhoverItem', a: a};
};
var $author$project$ModelAPI$getTopicInfo = F2(
	function (topicId, model) {
		var _v0 = A2($elm$core$Dict$get, topicId, model.items);
		if (_v0.$ === 'Just') {
			var info = _v0.a.info;
			if (info.$ === 'Topic') {
				var topic = info.a;
				return $elm$core$Maybe$Just(topic);
			} else {
				return A3($author$project$ModelAPI$topicMismatch, 'getTopicInfo', topicId, $elm$core$Maybe$Nothing);
			}
		} else {
			return A3($author$project$ModelAPI$illegalItemId, 'getTopicInfo', topicId, $elm$core$Maybe$Nothing);
		}
	});
var $elm$core$List$isEmpty = function (xs) {
	if (!xs.b) {
		return true;
	} else {
		return false;
	}
};
var $author$project$AppModel$Search = function (a) {
	return {$: 'Search', a: a};
};
var $author$project$SearchAPI$itemDecoder = function (msg) {
	return A2(
		$elm$json$Json$Decode$map,
		$author$project$AppModel$Search,
		A2(
			$elm$json$Json$Decode$map,
			msg,
			A2(
				$elm$json$Json$Decode$andThen,
				$author$project$ModelAPI$idDecoder,
				A2(
					$elm$json$Json$Decode$at,
					_List_fromArray(
						['target', 'dataset', 'id']),
					$elm$json$Json$Decode$string))));
};
var $author$project$SearchAPI$resultItemStyle = F2(
	function (topicId, model) {
		var isHover = function () {
			var _v0 = model.search.menu;
			if (_v0.$ === 'Open') {
				var maybeId = _v0.a;
				return _Utils_eq(
					maybeId,
					$elm$core$Maybe$Just(topicId));
			} else {
				return false;
			}
		}();
		return _List_fromArray(
			[
				A2(
				$elm$html$Html$Attributes$style,
				'color',
				isHover ? 'white' : 'black'),
				A2(
				$elm$html$Html$Attributes$style,
				'background-color',
				isHover ? 'black' : 'white'),
				A2($elm$html$Html$Attributes$style, 'overflow', 'hidden'),
				A2($elm$html$Html$Attributes$style, 'text-overflow', 'ellipsis'),
				A2($elm$html$Html$Attributes$style, 'padding', '0 8px')
			]);
	});
var $author$project$SearchAPI$resultMenuStyle = _List_fromArray(
	[
		A2($elm$html$Html$Attributes$style, 'position', 'absolute'),
		A2($elm$html$Html$Attributes$style, 'top', '144px'),
		A2($elm$html$Html$Attributes$style, 'width', '240px'),
		A2($elm$html$Html$Attributes$style, 'padding', '3px 0'),
		A2(
		$elm$html$Html$Attributes$style,
		'font-size',
		$elm$core$String$fromInt($author$project$Config$contentFontSize) + 'px'),
		A2($elm$html$Html$Attributes$style, 'line-height', '2'),
		A2($elm$html$Html$Attributes$style, 'white-space', 'nowrap'),
		A2($elm$html$Html$Attributes$style, 'background-color', 'white'),
		A2($elm$html$Html$Attributes$style, 'border', '1px solid lightgray'),
		A2($elm$html$Html$Attributes$style, 'z-index', '2')
	]);
var $author$project$SearchAPI$viewResultMenu = function (model) {
	var _v0 = _Utils_Tuple2(
		model.search.menu,
		$elm$core$List$isEmpty(model.search.result));
	if ((_v0.a.$ === 'Open') && (!_v0.b)) {
		return _List_fromArray(
			[
				A2(
				$elm$html$Html$div,
				_Utils_ap(
					_List_fromArray(
						[
							A2(
							$elm$html$Html$Events$on,
							'click',
							$author$project$SearchAPI$itemDecoder($author$project$Search$ClickItem)),
							A2(
							$elm$html$Html$Events$on,
							'mouseover',
							$author$project$SearchAPI$itemDecoder($author$project$Search$HoverItem)),
							A2(
							$elm$html$Html$Events$on,
							'mouseout',
							$author$project$SearchAPI$itemDecoder($author$project$Search$UnhoverItem)),
							$author$project$Utils$stopPropagationOnMousedown($author$project$AppModel$NoOp)
						]),
					$author$project$SearchAPI$resultMenuStyle),
				A2(
					$elm$core$List$map,
					function (id) {
						var _v1 = A2($author$project$ModelAPI$getTopicInfo, id, model);
						if (_v1.$ === 'Just') {
							var topic = _v1.a;
							return A2(
								$elm$html$Html$div,
								A2(
									$elm$core$List$cons,
									A2(
										$elm$html$Html$Attributes$attribute,
										'data-id',
										$elm$core$String$fromInt(id)),
									A2($author$project$SearchAPI$resultItemStyle, id, model)),
								_List_fromArray(
									[
										$elm$html$Html$text(topic.text)
									]));
						} else {
							return $elm$html$Html$text('??');
						}
					},
					model.search.result))
			]);
	} else {
		return _List_Nil;
	}
};
var $author$project$Model$Back = {$: 'Back'};
var $author$project$Model$Fullscreen = {$: 'Fullscreen'};
var $author$project$AppModel$Nav = function (a) {
	return {$: 'Nav', a: a};
};
var $author$project$Feature$OpenDoor$Decide$isChildOf = F3(
	function (childId, parentId, model) {
		var _v0 = A2($elm$core$Dict$get, parentId, model.maps);
		if (_v0.$ === 'Just') {
			var parentMap = _v0.a;
			return A2($elm$core$Dict$member, childId, parentMap.items);
		} else {
			return false;
		}
	});
var $author$project$Feature$OpenDoor$Decide$findContainerForChild = F3(
	function (parentId, topicId, model) {
		return A2(
			$elm$core$Maybe$map,
			function ($) {
				return $.id;
			},
			$elm$core$List$head(
				A2(
					$elm$core$List$filter,
					function (m) {
						return A3($author$project$Feature$OpenDoor$Decide$isChildOf, m.id, parentId, model);
					},
					A2(
						$elm$core$List$filter,
						function (m) {
							return A2($elm$core$Dict$member, topicId, m.items);
						},
						$elm$core$Dict$values(model.maps)))));
	});
var $author$project$Feature$OpenDoor$Decide$mapIdOf = function (path) {
	if (path.b) {
		var id = path.a;
		return id;
	} else {
		return 0;
	}
};
var $author$project$Feature$OpenDoor$Decide$parentPathOf = function (path) {
	if (path.b) {
		var rest = path.b;
		return $elm$core$Maybe$Just(rest);
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $author$project$Feature$OpenDoor$Decide$decideOpenDoorMsg = function (model) {
	var _v0 = $author$project$ModelAPI$getSingleSelection(model);
	if (_v0.$ === 'Nothing') {
		var _v1 = A2(
			$author$project$Logger$log,
			'Cross',
			{reason: 'no selection'});
		return $elm$core$Maybe$Nothing;
	} else {
		var _v2 = _v0.a;
		var topicId = _v2.a;
		var selectionPath = _v2.b;
		var selectionMapId = $author$project$Feature$OpenDoor$Decide$mapIdOf(selectionPath);
		var origin = A2($author$project$Model$Point, 0, 0);
		var isContainer = A2($elm$core$Dict$member, topicId, model.maps);
		var here = $author$project$ModelAPI$activeMap(model);
		if (isContainer) {
			if (_Utils_eq(selectionMapId, here)) {
				var _v3 = A2(
					$author$project$Logger$log,
					'Cross (enter container)',
					{container: topicId});
				return $elm$core$Maybe$Just(
					$author$project$AppModel$Nav($author$project$Model$Fullscreen));
			} else {
				var _v4 = A2(
					$author$project$Logger$log,
					'Cross (exit container)',
					{container: selectionMapId});
				return $elm$core$Maybe$Just(
					$author$project$AppModel$Nav($author$project$Model$Back));
			}
		} else {
			if (_Utils_eq(selectionMapId, here)) {
				var _v5 = A3($author$project$Feature$OpenDoor$Decide$findContainerForChild, here, topicId, model);
				if (_v5.$ === 'Just') {
					var containerId = _v5.a;
					var _v6 = A2(
						$author$project$Logger$log,
						'Cross (parent→inner)',
						{dst: containerId, src: here, topicId: topicId});
					return $elm$core$Maybe$Just(
						A6(
							$author$project$AppModel$MoveTopicToMap,
							topicId,
							here,
							origin,
							topicId,
							A2($elm$core$List$cons, containerId, model.mapPath),
							origin));
				} else {
					var _v7 = A2(
						$author$project$Logger$log,
						'Cross (no-op)',
						{parent: here, reason: 'no owning container on parent', topicId: topicId});
					return $elm$core$Maybe$Just(
						A6($author$project$AppModel$MoveTopicToMap, topicId, here, origin, topicId, model.mapPath, origin));
				}
			} else {
				var _v8 = $author$project$Feature$OpenDoor$Decide$parentPathOf(selectionPath);
				if (_v8.$ === 'Just') {
					var parentPath = _v8.a;
					var parentId = $author$project$Feature$OpenDoor$Decide$mapIdOf(parentPath);
					var _v9 = A2(
						$author$project$Logger$log,
						'Cross (inner→parent)',
						{dst: parentId, src: selectionMapId, topicId: topicId});
					return $elm$core$Maybe$Just(
						A6($author$project$AppModel$MoveTopicToMap, topicId, selectionMapId, origin, topicId, parentPath, origin));
				} else {
					var _v10 = A2(
						$author$project$Logger$log,
						'Cross disabled',
						{inner: selectionMapId, reason: 'inner map has no parent'});
					return $elm$core$Maybe$Nothing;
				}
			}
		}
	}
};
var $elm$html$Html$Attributes$boolProperty = F2(
	function (key, bool) {
		return A2(
			_VirtualDom_property,
			key,
			$elm$json$Json$Encode$bool(bool));
	});
var $elm$html$Html$Attributes$disabled = $elm$html$Html$Attributes$boolProperty('disabled');
var $author$project$UI$Toolbar$crossButton = function (model) {
	var _v0 = function () {
		var _v1 = $author$project$Feature$OpenDoor$Decide$decideOpenDoorMsg(model);
		if (_v1.$ === 'Just') {
			var m = _v1.a;
			return _Utils_Tuple2(false, m);
		} else {
			return _Utils_Tuple2(true, $author$project$AppModel$NoOp);
		}
	}();
	var disabled_ = _v0.a;
	var msg = _v0.b;
	return A2(
		$elm$html$Html$button,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$id('btn-Cross'),
				$elm$html$Html$Attributes$disabled(disabled_),
				$author$project$Utils$stopPropagationOnMousedown($author$project$AppModel$NoOp),
				$elm$html$Html$Events$onClick(msg)
			]),
		_List_fromArray(
			[
				$elm$html$Html$text('Cross')
			]));
};
var $author$project$AppModel$AddTopic = {$: 'AddTopic'};
var $author$project$AppModel$Delete = {$: 'Delete'};
var $author$project$Model$EditStart = {$: 'EditStart'};
var $author$project$AppModel$Hide = {$: 'Hide'};
var $author$project$Config$toolbarFontSize = 14;
var $author$project$Toolbar$toolbarStyle = _List_fromArray(
	[
		A2(
		$elm$html$Html$Attributes$style,
		'font-size',
		$elm$core$String$fromInt($author$project$Config$toolbarFontSize) + 'px'),
		A2($elm$html$Html$Attributes$style, 'display', 'flex'),
		A2($elm$html$Html$Attributes$style, 'flex-direction', 'column'),
		A2($elm$html$Html$Attributes$style, 'align-items', 'flex-start'),
		A2($elm$html$Html$Attributes$style, 'gap', '28px'),
		A2($elm$html$Html$Attributes$style, 'position', 'fixed'),
		A2($elm$html$Html$Attributes$style, 'z-index', '1')
	]);
var $author$project$AppModel$SwitchDisplay = function (a) {
	return {$: 'SwitchDisplay', a: a};
};
var $author$project$Toolbar$displayModeStyle = function (disabled) {
	var _v0 = disabled ? _Utils_Tuple2('gray', 'none') : _Utils_Tuple2('unset', 'unset');
	var color = _v0.a;
	var pointerEvents = _v0.b;
	return _List_fromArray(
		[
			A2($elm$html$Html$Attributes$style, 'display', 'flex'),
			A2($elm$html$Html$Attributes$style, 'flex-direction', 'column'),
			A2($elm$html$Html$Attributes$style, 'gap', '6px'),
			A2($elm$html$Html$Attributes$style, 'color', color),
			A2($elm$html$Html$Attributes$style, 'pointer-events', pointerEvents)
		]);
};
var $elm$html$Html$Attributes$checked = $elm$html$Html$Attributes$boolProperty('checked');
var $elm$html$Html$label = _VirtualDom_node('label');
var $elm$html$Html$Attributes$name = $elm$html$Html$Attributes$stringProperty('name');
var $elm$html$Html$Attributes$type_ = $elm$html$Html$Attributes$stringProperty('type');
var $author$project$Toolbar$viewRadioButton = F4(
	function (label_, msg, isChecked, isDisabled) {
		return A2(
			$elm$html$Html$label,
			_List_fromArray(
				[
					$author$project$Utils$stopPropagationOnMousedown($author$project$AppModel$NoOp)
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$input,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$type_('radio'),
							$elm$html$Html$Attributes$name('display-mode'),
							$elm$html$Html$Attributes$checked(isChecked),
							$elm$html$Html$Attributes$disabled(isDisabled),
							$elm$html$Html$Events$onClick(msg)
						]),
					_List_Nil),
					$elm$html$Html$text(label_)
				]));
	});
var $author$project$Toolbar$viewContainerDisplay = function (model) {
	var displayMode = A2(
		$elm$core$Maybe$andThen,
		function (_v6) {
			var topicId = _v6.a;
			var mapPath = _v6.b;
			return A3(
				$author$project$ModelAPI$getDisplayMode,
				topicId,
				$author$project$ModelAPI$getMapId(mapPath),
				model.maps);
		},
		$author$project$ModelAPI$getSingleSelection(model));
	var disabled_ = function () {
		if ((displayMode.$ === 'Just') && (displayMode.a.$ === 'Container')) {
			return false;
		} else {
			return true;
		}
	}();
	var _v0 = function () {
		if ((displayMode.$ === 'Just') && (displayMode.a.$ === 'Container')) {
			switch (displayMode.a.a.$) {
				case 'BlackBox':
					var _v2 = displayMode.a.a;
					return _Utils_Tuple3(true, false, false);
				case 'WhiteBox':
					var _v3 = displayMode.a.a;
					return _Utils_Tuple3(false, true, false);
				default:
					var _v4 = displayMode.a.a;
					return _Utils_Tuple3(false, false, true);
			}
		} else {
			return _Utils_Tuple3(false, false, false);
		}
	}();
	var checked1 = _v0.a;
	var checked2 = _v0.b;
	var checked3 = _v0.c;
	return A2(
		$elm$html$Html$div,
		$author$project$Toolbar$displayModeStyle(disabled_),
		_List_fromArray(
			[
				A2(
				$elm$html$Html$div,
				_List_Nil,
				_List_fromArray(
					[
						$elm$html$Html$text('Container Display')
					])),
				A4(
				$author$project$Toolbar$viewRadioButton,
				'Black Box',
				$author$project$AppModel$SwitchDisplay(
					$author$project$Model$Container($author$project$Model$BlackBox)),
				checked1,
				disabled_),
				A4(
				$author$project$Toolbar$viewRadioButton,
				'White Box',
				$author$project$AppModel$SwitchDisplay(
					$author$project$Model$Container($author$project$Model$WhiteBox)),
				checked2,
				disabled_),
				A4(
				$author$project$Toolbar$viewRadioButton,
				'Unboxed',
				$author$project$AppModel$SwitchDisplay(
					$author$project$Model$Container($author$project$Model$Unboxed)),
				checked3,
				disabled_)
			]));
};
var $elm$html$Html$a = _VirtualDom_node('a');
var $author$project$Config$date = 'Sep 8, 2025';
var $author$project$Config$footerFontSize = 13;
var $author$project$Toolbar$footerStyle = _List_fromArray(
	[
		A2(
		$elm$html$Html$Attributes$style,
		'font-size',
		$elm$core$String$fromInt($author$project$Config$footerFontSize) + 'px'),
		A2($elm$html$Html$Attributes$style, 'color', 'lightgray')
	]);
var $elm$html$Html$Attributes$href = function (url) {
	return A2(
		$elm$html$Html$Attributes$stringProperty,
		'href',
		_VirtualDom_noJavaScriptUri(url));
};
var $author$project$Toolbar$linkStyle = _List_fromArray(
	[
		A2($elm$html$Html$Attributes$style, 'color', 'lightgray')
	]);
var $author$project$Config$version = '0.2.0-snapshot';
var $author$project$Toolbar$viewFooter = A2(
	$elm$html$Html$div,
	$author$project$Toolbar$footerStyle,
	_List_fromArray(
		[
			A2(
			$elm$html$Html$div,
			_List_Nil,
			_List_fromArray(
				[
					$elm$html$Html$text($author$project$Config$version)
				])),
			A2(
			$elm$html$Html$div,
			_List_Nil,
			_List_fromArray(
				[
					$elm$html$Html$text($author$project$Config$date)
				])),
			A2(
			$elm$html$Html$div,
			_List_Nil,
			_List_fromArray(
				[
					$elm$html$Html$text('Source: '),
					A2(
					$elm$html$Html$a,
					A2(
						$elm$core$List$cons,
						$elm$html$Html$Attributes$href('https://github.com/dmx-systems/dm6-elm'),
						$author$project$Toolbar$linkStyle),
					_List_fromArray(
						[
							$elm$html$Html$text('GitHub')
						]))
				])),
			A2(
			$elm$html$Html$a,
			A2(
				$elm$core$List$cons,
				$elm$html$Html$Attributes$href('https://dmx.berlin'),
				$author$project$Toolbar$linkStyle),
			_List_fromArray(
				[
					$elm$html$Html$text('DMX Systems')
				]))
		]));
var $author$project$Config$homeMapName = 'DM6 Elm';
var $author$project$ModelAPI$isHome = function (model) {
	return !$author$project$ModelAPI$activeMap(model);
};
var $author$project$Toolbar$getMapName = function (model) {
	if ($author$project$ModelAPI$isHome(model)) {
		return $author$project$Config$homeMapName;
	} else {
		var _v0 = A2(
			$author$project$ModelAPI$getTopicInfo,
			$author$project$ModelAPI$activeMap(model),
			model);
		if (_v0.$ === 'Just') {
			var topic = _v0.a;
			return $author$project$ModelAPI$getTopicLabel(topic);
		} else {
			return '??';
		}
	}
};
var $author$project$Toolbar$mapNavStyle = _List_fromArray(
	[
		A2($elm$html$Html$Attributes$style, 'margin-top', '20px'),
		A2($elm$html$Html$Attributes$style, 'margin-bottom', '12px')
	]);
var $author$project$Toolbar$mapTitleStyle = _List_fromArray(
	[
		A2($elm$html$Html$Attributes$style, 'font-size', '36px'),
		A2($elm$html$Html$Attributes$style, 'font-weight', 'bold'),
		A2($elm$html$Html$Attributes$style, 'vertical-align', 'top'),
		A2($elm$html$Html$Attributes$style, 'margin-left', '12px')
	]);
var $elm$html$Html$span = _VirtualDom_node('span');
var $feathericons$elm_feather$FeatherIcons$withSize = F2(
	function (size, _v0) {
		var attrs = _v0.a.attrs;
		var src = _v0.a.src;
		return $feathericons$elm_feather$FeatherIcons$Icon(
			{
				attrs: _Utils_update(
					attrs,
					{size: size}),
				src: src
			});
	});
var $author$project$IconMenuAPI$viewIcon = F2(
	function (iconName, sizePx) {
		var _v0 = A2($elm$core$Dict$get, iconName, $feathericons$elm_feather$FeatherIcons$icons);
		if (_v0.$ === 'Just') {
			var icon = _v0.a;
			return A2(
				$feathericons$elm_feather$FeatherIcons$toHtml,
				_List_Nil,
				A2($feathericons$elm_feather$FeatherIcons$withSize, sizePx, icon));
		} else {
			return $elm$html$Html$text('??');
		}
	});
var $author$project$Toolbar$viewMapNav = function (model) {
	var backDisabled = $author$project$ModelAPI$isHome(model);
	return A2(
		$elm$html$Html$div,
		$author$project$Toolbar$mapNavStyle,
		_List_fromArray(
			[
				A2(
				$elm$html$Html$button,
				_List_fromArray(
					[
						$elm$html$Html$Events$onClick(
						$author$project$AppModel$Nav($author$project$Model$Back)),
						$elm$html$Html$Attributes$disabled(backDisabled)
					]),
				_List_fromArray(
					[
						A2($author$project$IconMenuAPI$viewIcon, 'arrow-left', 20)
					])),
				A2(
				$elm$html$Html$span,
				$author$project$Toolbar$mapTitleStyle,
				_List_fromArray(
					[
						$elm$html$Html$text(
						$author$project$Toolbar$getMapName(model))
					]))
			]));
};
var $author$project$Toolbar$viewMonadDisplay = function (model) {
	var displayMode = A2(
		$elm$core$Maybe$andThen,
		function (_v4) {
			var topicId = _v4.a;
			var mapPath = _v4.b;
			return A3(
				$author$project$ModelAPI$getDisplayMode,
				topicId,
				$author$project$ModelAPI$getMapId(mapPath),
				model.maps);
		},
		$author$project$ModelAPI$getSingleSelection(model));
	var _v0 = function () {
		if ((displayMode.$ === 'Just') && (displayMode.a.$ === 'Monad')) {
			if (displayMode.a.a.$ === 'LabelOnly') {
				var _v2 = displayMode.a.a;
				return _Utils_Tuple3(true, false, false);
			} else {
				var _v3 = displayMode.a.a;
				return _Utils_Tuple3(false, true, false);
			}
		} else {
			return _Utils_Tuple3(false, false, true);
		}
	}();
	var checked1 = _v0.a;
	var checked2 = _v0.b;
	var disabled_ = _v0.c;
	return A2(
		$elm$html$Html$div,
		$author$project$Toolbar$displayModeStyle(disabled_),
		_List_fromArray(
			[
				A2(
				$elm$html$Html$div,
				_List_Nil,
				_List_fromArray(
					[
						$elm$html$Html$text('Monad Display')
					])),
				A4(
				$author$project$Toolbar$viewRadioButton,
				'Label Only',
				$author$project$AppModel$SwitchDisplay(
					$author$project$Model$Monad($author$project$Model$LabelOnly)),
				checked1,
				disabled_),
				A4(
				$author$project$Toolbar$viewRadioButton,
				'Detail',
				$author$project$AppModel$SwitchDisplay(
					$author$project$Model$Monad($author$project$Model$Detail)),
				checked2,
				disabled_)
			]));
};
var $author$project$Search$FocusInput = {$: 'FocusInput'};
var $author$project$Search$Input = function (a) {
	return {$: 'Input', a: a};
};
var $elm$html$Html$Events$onFocus = function (msg) {
	return A2(
		$elm$html$Html$Events$on,
		'focus',
		$elm$json$Json$Decode$succeed(msg));
};
var $author$project$SearchAPI$searchInputStyle = _List_fromArray(
	[
		A2($elm$html$Html$Attributes$style, 'width', '100px')
	]);
var $author$project$SearchAPI$viewSearchInput = function (model) {
	return A2(
		$elm$html$Html$div,
		_List_Nil,
		_List_fromArray(
			[
				A2(
				$elm$html$Html$div,
				_List_Nil,
				_List_fromArray(
					[
						$elm$html$Html$text('Search')
					])),
				A2(
				$elm$html$Html$input,
				_Utils_ap(
					_List_fromArray(
						[
							$elm$html$Html$Attributes$value(model.search.text),
							$elm$html$Html$Events$onInput(
							A2($elm$core$Basics$composeL, $author$project$AppModel$Search, $author$project$Search$Input)),
							$elm$html$Html$Events$onFocus(
							$author$project$AppModel$Search($author$project$Search$FocusInput))
						]),
					$author$project$SearchAPI$searchInputStyle),
				_List_Nil)
			]));
};
var $author$project$Toolbar$buttonStyle = _List_fromArray(
	[
		A2($elm$html$Html$Attributes$style, 'font-family', $author$project$Config$mainFont),
		A2(
		$elm$html$Html$Attributes$style,
		'font-size',
		$elm$core$String$fromInt($author$project$Config$toolbarFontSize) + 'px')
	]);
var $author$project$Toolbar$viewToolbarButton = F4(
	function (label, msg, requireSelection, model) {
		var hasNoSelection = $elm$core$List$isEmpty(model.selection);
		var buttonAttr = requireSelection ? _List_fromArray(
			[
				$author$project$Utils$stopPropagationOnMousedown($author$project$AppModel$NoOp),
				$elm$html$Html$Attributes$disabled(hasNoSelection)
			]) : _List_Nil;
		return A2(
			$elm$html$Html$button,
			A2(
				$elm$core$List$cons,
				$elm$html$Html$Events$onClick(msg),
				_Utils_ap(buttonAttr, $author$project$Toolbar$buttonStyle)),
			_List_fromArray(
				[
					$elm$html$Html$text(label)
				]));
	});
var $author$project$Toolbar$viewToolbar = function (model) {
	return A2(
		$elm$html$Html$div,
		$author$project$Toolbar$toolbarStyle,
		_List_fromArray(
			[
				$author$project$Toolbar$viewMapNav(model),
				$author$project$SearchAPI$viewSearchInput(model),
				A4($author$project$Toolbar$viewToolbarButton, 'Add Topic', $author$project$AppModel$AddTopic, false, model),
				A4(
				$author$project$Toolbar$viewToolbarButton,
				'Edit',
				$author$project$AppModel$Edit($author$project$Model$EditStart),
				true,
				model),
				A4(
				$author$project$Toolbar$viewToolbarButton,
				'Choose Icon',
				$author$project$AppModel$IconMenu($author$project$IconMenu$Open),
				true,
				model),
				$author$project$Toolbar$viewMonadDisplay(model),
				$author$project$Toolbar$viewContainerDisplay(model),
				A4($author$project$Toolbar$viewToolbarButton, 'Hide', $author$project$AppModel$Hide, true, model),
				A4(
				$author$project$Toolbar$viewToolbarButton,
				'Fullscreen',
				$author$project$AppModel$Nav($author$project$Model$Fullscreen),
				true,
				model),
				A4($author$project$Toolbar$viewToolbarButton, 'Delete', $author$project$AppModel$Delete, true, model),
				$author$project$Toolbar$viewFooter
			]));
};
var $author$project$UI$Toolbar$viewToolbar = function (model) {
	return A2(
		$elm$html$Html$div,
		_List_Nil,
		_List_fromArray(
			[
				$author$project$UI$Toolbar$crossButton(model),
				$author$project$Toolbar$viewToolbar(model)
			]));
};
var $author$project$Main$view = function (model) {
	return A2(
		$elm$browser$Browser$Document,
		'DM6 Elm',
		_List_fromArray(
			[
				A2(
				$elm$html$Html$div,
				_Utils_ap($author$project$MouseAPI$mouseHoverHandler, $author$project$Main$appStyle),
				_Utils_ap(
					_List_fromArray(
						[
							$author$project$UI$Toolbar$viewToolbar(model),
							A3(
							$author$project$MapRenderer$viewMap,
							$author$project$ModelAPI$activeMap(model),
							_List_Nil,
							model)
						]),
					_Utils_ap(
						$author$project$SearchAPI$viewResultMenu(model),
						$author$project$IconMenuAPI$viewIconMenu(model)))),
				A2(
				$elm$html$Html$div,
				_Utils_ap(
					_List_fromArray(
						[
							$elm$html$Html$Attributes$id('measure')
						]),
					$author$project$Main$measureStyle),
				_List_fromArray(
					[
						$elm$html$Html$text(model.measureText),
						A2($elm$html$Html$br, _List_Nil, _List_Nil)
					]))
			]));
};
var $author$project$Main$main = $elm$browser$Browser$document(
	{init: $author$project$Main$init, subscriptions: $author$project$MouseAPI$mouseSubs, update: $author$project$Main$update, view: $author$project$Main$view});
_Platform_export({'Main':{'init':$author$project$Main$main($elm$json$Json$Decode$value)(0)}});}(this));

  var app = Elm.Main.init({ node: document.getElementById("elm") });
}
catch (e)
{
  // display initialization errors (e.g. bad flags, infinite recursion)
  var header = document.createElement("h1");
  header.style.fontFamily = "monospace";
  header.innerText = "Initialization Error";
  var pre = document.getElementById("elm");
  document.body.insertBefore(header, pre);
  pre.innerText = e;
  throw e;
}
</script>

</body>
</html>
````

## File: src/Config.elm
````elm
module Config exposing (..)

import Model exposing (Point, Size)



-- CONFIG


homeMapName : String
homeMapName =
    "DM6 Elm"


version : String
version =
    "0.2.0-snapshot"


date : String
date =
    "Sep 12, 2025"


newTopicPos : Point
newTopicPos =
    Point 186 180


mainFont : String
mainFont =
    "sans-serif"


toolbarFontSize : number
toolbarFontSize =
    14


contentFontSize : number
contentFontSize =
    13


footerFontSize : number
footerFontSize =
    13


topicWidth : number
topicWidth =
    156


topicHeight : number
topicHeight =
    28



-- also width/height of square icon box


topicW2 : Float
topicW2 =
    topicWidth / 2


topicH2 : Float
topicH2 =
    topicHeight / 2


topicSize : Size
topicSize =
    Size topicWidth topicHeight


topicLabelWeight : String
topicLabelWeight =
    "bold"



-- "normal"


topicDetailSize : Size
topicDetailSize =
    Size
        (topicWidth - topicHeight)
        -- detail width does not include icon box
        (topicLineHeight * contentFontSize + 2 * (topicDetailPadding + topicBorderWidth))


topicDetailMaxWidth : number
topicDetailMaxWidth =
    300


topicDetailPadding : number
topicDetailPadding =
    8


topicLineHeight : Float
topicLineHeight =
    1.5


topicDefaultText : String
topicDefaultText =
    "New Topic"


topicIconSize : number
topicIconSize =
    16


topicBorderWidth : number
topicBorderWidth =
    1


topicRadius : number
topicRadius =
    7


assocWidth : Float
assocWidth =
    1.5


assocRadius : number
assocRadius =
    14



-- should not be bigger than half topicSize height


assocColor : String
assocColor =
    "black"


assocDelayMillis : number
assocDelayMillis =
    200


whiteBoxRange : Size
whiteBoxRange =
    Size 250 150


whiteBoxRadius : number
whiteBoxRadius =
    14


whiteBoxPadding : number
whiteBoxPadding =
    12


blackBoxOffset : number
blackBoxOffset =
    5
````

## File: src/ModelAPI.elm
````elm
module ModelAPI exposing (..)

import AppModel exposing (..)
import Config exposing (..)
import Dict exposing (Dict)
import Model exposing (..)
import String exposing (fromInt)
import UndoList
import Utils as U



-- MODEL API
-- Items


getTopicInfo : Id -> Model -> Maybe TopicInfo
getTopicInfo topicId model =
    case model.items |> Dict.get topicId of
        Just { info } ->
            case info of
                Topic topic ->
                    Just topic

                Assoc _ ->
                    topicMismatch "getTopicInfo" topicId Nothing

        Nothing ->
            illegalItemId "getTopicInfo" topicId Nothing


getAssocInfo : Id -> Model -> Maybe AssocInfo
getAssocInfo assocId model =
    case model.items |> Dict.get assocId of
        Just { info } ->
            case info of
                Topic _ ->
                    assocMismatch "getAssocInfo" assocId Nothing

                Assoc assoc ->
                    Just assoc

        Nothing ->
            illegalItemId "getAssocInfo" assocId Nothing


updateTopicInfo : Id -> (TopicInfo -> TopicInfo) -> Model -> Model
updateTopicInfo topicId topicFunc model =
    { model
        | items =
            model.items
                |> Dict.update topicId
                    (\maybeItem ->
                        case maybeItem of
                            Just item ->
                                case item.info of
                                    Topic topic ->
                                        Just { item | info = topicFunc topic |> Topic }

                                    Assoc _ ->
                                        topicMismatch "updateTopicInfo" topicId Nothing

                            Nothing ->
                                illegalItemId "updateTopicInfo" topicId Nothing
                    )
    }


getTopicLabel : TopicInfo -> String
getTopicLabel topic =
    case topic.text |> String.lines |> List.head of
        Just line ->
            line

        Nothing ->
            ""


createTopic : String -> Maybe IconName -> Model -> ( Model, Id )
createTopic text iconName model =
    let
        id =
            model.nextId

        topic =
            Item id <| Topic <| TopicInfo id text iconName
    in
    ( { model | items = model.items |> Dict.insert id topic }
        |> nextId
    , id
    )


createAssoc : ItemType -> RoleType -> Id -> RoleType -> Id -> Model -> ( Model, Id )
createAssoc itemType role1 player1 role2 player2 model =
    let
        id =
            model.nextId

        assoc =
            Item id <| Assoc <| AssocInfo id itemType role1 player1 role2 player2
    in
    ( { model | items = model.items |> Dict.insert id assoc }
        |> nextId
    , id
    )


nextId : Model -> Model
nextId model =
    { model | nextId = model.nextId + 1 }



-- Maps


isHome : Model -> Bool
isHome model =
    activeMap model == 0


isFullscreen : MapId -> Model -> Bool
isFullscreen mapId model =
    activeMap model == mapId


activeMap : Model -> MapId
activeMap model =
    case List.head model.mapPath of
        Just mapId ->
            mapId

        Nothing ->
            U.logError "activeMap" "mapPath is empty!" 0


{-| Returns -1 if mapPath is empty
-}
getMapId : MapPath -> MapId
getMapId mapPath =
    case mapPath of
        mapId :: _ ->
            mapId

        _ ->
            -1


fromPath : MapPath -> String
fromPath mapPath =
    mapPath |> List.map fromInt |> String.join ","


{-| Logs an error if map does not exist
-}
getMap : MapId -> Maps -> Maybe Map
getMap mapId maps =
    case getMapIfExists mapId maps of
        Just map ->
            Just map

        Nothing ->
            illegalMapId "getMap" mapId Nothing


getMapIfExists : MapId -> Maps -> Maybe Map
getMapIfExists mapId maps =
    maps |> Dict.get mapId


hasMap : MapId -> Maps -> Bool
hasMap mapId maps =
    maps |> Dict.member mapId


createMap : MapId -> Model -> Model
createMap mapId model =
    { model
        | maps =
            model.maps
                |> Dict.insert
                    mapId
                    (Map mapId (Rectangle 0 0 0 0) Dict.empty)
    }


updateMapRect : MapId -> (Rectangle -> Rectangle) -> Model -> Model
updateMapRect mapId rectFunc model =
    { model
        | maps =
            updateMaps
                mapId
                (\map ->
                    { map | rect = rectFunc map.rect }
                )
                model.maps
    }


{-| Logs an error if map does not exist or item is not in map or is not a topic
-}
getTopicPos : Id -> MapId -> Maps -> Maybe Point
getTopicPos topicId mapId maps =
    case getTopicProps topicId mapId maps of
        Just { pos } ->
            Just pos

        Nothing ->
            U.fail "getTopicPos" { topicId = topicId, mapId = mapId } Nothing


{-| Logs an error if map does not exist or if topic is not in map
-}
setTopicPos : Id -> MapId -> Point -> Model -> Model
setTopicPos topicId mapId pos model =
    model
        |> updateTopicProps topicId
            mapId
            (\props -> { props | pos = pos })


{-| Logs an error if map does not exist or if topic is not in map
-}
setTopicPosByDelta : Id -> MapId -> Delta -> Model -> Model
setTopicPosByDelta topicId mapId delta model =
    model
        |> updateTopicProps topicId
            mapId
            (\props ->
                { props
                    | pos =
                        Point
                            (props.pos.x + delta.x)
                            (props.pos.y + delta.y)
                }
            )


getTopicSize : Id -> MapId -> Maps -> Maybe Size
getTopicSize topicId mapId maps =
    case getTopicProps topicId mapId maps of
        Just { size } ->
            Just size

        Nothing ->
            U.fail "getTopicSize" { topicId = topicId, mapId = mapId } Nothing


{-| Logs an error if map does not exist or if topic is not in map
-}
setTopicSize : Id -> MapId -> Size -> Model -> Model
setTopicSize topicId mapId size model =
    model
        |> updateTopicProps topicId
            mapId
            (\props -> { props | size = size })


getDisplayMode : Id -> MapId -> Maps -> Maybe DisplayMode
getDisplayMode topicId mapId maps =
    case getTopicProps topicId mapId maps of
        Just { displayMode } ->
            Just displayMode

        Nothing ->
            U.fail "getDisplayMode" { topicId = topicId, mapId = mapId } Nothing


{-| Logs an error if map does not exist or if topic is not in map.
Now also logs a single line only when the display mode actually changes.
-}
setDisplayMode : Id -> MapId -> DisplayMode -> Model -> Model
setDisplayMode topicId mapId newMode model =
    model
        |> updateTopicProps topicId
            mapId
            (\props ->
                let
                    old =
                        props.displayMode
                in
                if old /= newMode then
                    let
                        _ =
                            U.info "displayMode.change"
                                { topic = topicId
                                , map = mapId
                                , old = U.toString old
                                , new = U.toString newMode
                                }
                    in
                    { props | displayMode = newMode }

                else
                    props
            )


getTopicProps : Id -> MapId -> Maps -> Maybe TopicProps
getTopicProps topicId mapId maps =
    case getMapItemById topicId mapId maps of
        Just mapItem ->
            case mapItem.props of
                MapTopic props ->
                    Just props

                MapAssoc _ ->
                    topicMismatch "getTopicProps" topicId Nothing

        Nothing ->
            U.fail "getTopicProps" { topicId = topicId, mapId = mapId } Nothing


{-| Logs an error if map does not exist or if topic is not in map
-}
updateTopicProps : Id -> MapId -> (TopicProps -> TopicProps) -> Model -> Model
updateTopicProps topicId mapId propsFunc model =
    { model
        | maps =
            model.maps
                |> updateMaps mapId
                    (\map ->
                        { map
                            | items =
                                map.items
                                    |> Dict.update topicId
                                        (\mapItem_ ->
                                            case mapItem_ of
                                                Just mapItem ->
                                                    case mapItem.props of
                                                        MapTopic props ->
                                                            Just
                                                                { mapItem | props = MapTopic (propsFunc props) }

                                                        MapAssoc _ ->
                                                            topicMismatch "updateTopicProps" topicId Nothing

                                                Nothing ->
                                                    illegalItemId "updateTopicProps" topicId Nothing
                                        )
                        }
                    )
    }


{-| Useful when revealing an existing topic
-}
defaultProps : Id -> Size -> Model -> TopicProps
defaultProps topicId size model =
    TopicProps
        (Point 0 0)
        -- TODO
        size
        (if hasMap topicId model.maps then
            Container BlackBox

         else
            Monad LabelOnly
        )


{-| Logs an error if map does not exist or item is not in map
-}
getMapItemById : Id -> MapId -> Maps -> Maybe MapItem
getMapItemById itemId mapId maps =
    getMap mapId maps |> Maybe.andThen (getMapItem itemId)


{-| Logs an error if item is not in map
-}
getMapItem : Id -> Map -> Maybe MapItem
getMapItem itemId map =
    case map.items |> Dict.get itemId of
        Just mapItem ->
            Just mapItem

        Nothing ->
            itemNotInMap "getMapItem" itemId map.id Nothing


{-| Logs an error if map does not exist
-}
isItemInMap : Id -> MapId -> Model -> Bool
isItemInMap itemId mapId model =
    case getMap mapId model.maps of
        Just map ->
            case map.items |> Dict.get itemId of
                Just _ ->
                    True

                Nothing ->
                    False

        Nothing ->
            False


createTopicIn : String -> Maybe IconName -> MapPath -> Model -> Model
createTopicIn text iconName mapPath model =
    let
        mapId =
            getMapId mapPath
    in
    case getMap mapId model.maps of
        Just map ->
            let
                ( newModel, topicId ) =
                    createTopic text iconName model

                props =
                    MapTopic <|
                        TopicProps
                            (Point
                                (newTopicPos.x + map.rect.x1)
                                (newTopicPos.y + map.rect.y1)
                            )
                            topicDetailSize
                            (Monad LabelOnly)
            in
            newModel
                |> addItemToMap topicId props mapId
                |> select topicId mapPath

        Nothing ->
            model



-- Presumption: both players exist in same map


createDefaultAssocIn : Id -> Id -> MapId -> Model -> Model
createDefaultAssocIn player1 player2 mapId model =
    createAssocIn
        "dmx.association"
        "dmx.default"
        player1
        "dmx.default"
        player2
        mapId
        model



-- Presumption: both players exist in same map


createAssocIn : ItemType -> RoleType -> Id -> RoleType -> Id -> MapId -> Model -> Model
createAssocIn itemType role1 player1 role2 player2 mapId model =
    let
        ( newModel, assocId ) =
            createAssoc itemType role1 player1 role2 player2 model

        props =
            MapAssoc AssocProps
    in
    addItemToMap assocId props mapId newModel


{-| Precondition: the item is not yet contained in the map
-}
addItemToMap : Id -> MapProps -> MapId -> Model -> Model
addItemToMap itemId props incomingMapId model0 =
    let
        model =
            ensureCurrentMap model0

        targetMapId =
            normalizeMapId model incomingMapId

        ( newModel, parentAssocId ) =
            createAssoc
                "dmx.composition"
                "dmx.child"
                itemId
                "dmx.parent"
                targetMapId
                model

        mapItem =
            MapItem itemId parentAssocId False False props

        -- Only log normalization when we actually changed it.
        _ =
            if incomingMapId /= targetMapId then
                U.info "ModelAPI.addItemToMap.normalized"
                    { attemptedMapId = incomingMapId
                    , normalizedTo = targetMapId
                    , existingMapIds = Dict.keys newModel.maps
                    , mapPath = newModel.mapPath
                    }
                    |> always ()
                -- <- make it unit

            else
                ()

        -- log the actual add
        _ =
            U.info "ModelAPI.addItemToMap"
                { itemId = itemId
                , mapId = targetMapId
                , parentAssocId = parentAssocId
                , props = props
                }
    in
    { newModel
        | maps =
            updateMaps
                targetMapId
                (\m -> { m | items = Dict.insert itemId mapItem m.items })
                newModel.maps
    }


showItem : Id -> MapId -> Model -> Model
showItem itemId mapId model =
    { model
        | maps =
            model.maps
                |> updateMaps
                    mapId
                    (\map ->
                        { map
                            | items =
                                Dict.update itemId
                                    (Maybe.map (\mapItem -> { mapItem | hidden = False }))
                                    map.items
                        }
                    )
    }


hideItem : Id -> MapId -> Model -> Model
hideItem itemId mapId model =
    { model
        | maps =
            model.maps
                |> updateMaps
                    mapId
                    (\map -> { map | items = hideItem_ itemId map.items model })
    }


hideItem_ : Id -> MapItems -> Model -> MapItems
hideItem_ itemId items model =
    mapAssocsOfPlayer_ itemId items model
        |> List.foldr
            (\assocId itemsAcc -> hideItem_ assocId itemsAcc model)
            (items
                |> Dict.update
                    itemId
                    (\item_ ->
                        case item_ of
                            Just item ->
                                Just { item | hidden = True }

                            Nothing ->
                                Nothing
                    )
            )


updateMaps : MapId -> (Map -> Map) -> Dict MapId Map -> Dict MapId Map
updateMaps mid f maps =
    case Dict.get mid maps of
        Just m ->
            Dict.insert mid (f m) maps

        Nothing ->
            let
                _ =
                    U.logError "updateMaps.illegal-map-id"
                        ("mapId="
                            ++ String.fromInt mid
                            ++ " existing="
                            ++ U.toString (Dict.keys maps)
                        )
                        maps
            in
            maps


deleteItem : Id -> Model -> Model
deleteItem itemId model =
    assocsOfPlayer itemId model
        |> List.foldr
            deleteItem
            -- recursion
            { model
                | items = model.items |> Dict.remove itemId -- delete item
                , maps =
                    model.maps
                        |> Dict.map
                            -- delete item from all maps
                            (\_ map -> { map | items = map.items |> Dict.remove itemId })
            }


assocsOfPlayer : Id -> Model -> List Id
assocsOfPlayer playerId model =
    model.items
        |> Dict.values
        |> List.filter isAssoc
        |> List.map .id
        |> List.filter (hasPlayer playerId model)


mapAssocsOfPlayer_ : Id -> MapItems -> Model -> List Id
mapAssocsOfPlayer_ playerId items model =
    items
        |> Dict.values
        |> List.filter isMapAssoc
        |> List.map .id
        |> List.filter (hasPlayer playerId model)


hasPlayer : Id -> Model -> Id -> Bool
hasPlayer playerId model assocId =
    case getAssocInfo assocId model of
        Just assoc ->
            assoc.player1 == playerId || assoc.player2 == playerId

        Nothing ->
            False


{-| useful as a filter predicate
-}
isTopic : Item -> Bool
isTopic item =
    case item.info of
        Topic _ ->
            True

        Assoc _ ->
            False


{-| useful as a filter predicate
-}
isAssoc : Item -> Bool
isAssoc item =
    not (isTopic item)


{-| useful as a filter predicate
-}
isMapTopic : MapItem -> Bool
isMapTopic item =
    case item.props of
        MapTopic _ ->
            True

        MapAssoc _ ->
            False


{-| useful as a filter predicate
-}
isMapAssoc : MapItem -> Bool
isMapAssoc item =
    not (isMapTopic item)


isVisible : MapItem -> Bool
isVisible item =
    not item.hidden



-- Selection


select : Id -> MapPath -> Model -> Model
select itemId mapPath model =
    { model | selection = [ ( itemId, mapPath ) ] }


resetSelection : Model -> Model
resetSelection model =
    { model | selection = [] }


isSelected : Id -> MapId -> Model -> Bool
isSelected itemId mapId model =
    model.selection
        |> List.any
            (\( id, mapPath ) ->
                case mapPath of
                    mapId_ :: _ ->
                        itemId == id && mapId == mapId_

                    [] ->
                        False
            )


getSingleSelection : Model -> Maybe ( Id, MapPath )
getSingleSelection model =
    case model.selection of
        [ selItem ] ->
            Just selItem

        _ ->
            Nothing



-- Undo / Redo


push : UndoModel -> ( Model, Cmd Msg ) -> ( UndoModel, Cmd Msg )
push undoModel ( model, cmd ) =
    ( UndoList.new model undoModel, cmd )


swap : UndoModel -> ( Model, Cmd Msg ) -> ( UndoModel, Cmd Msg )
swap undoModel ( model, cmd ) =
    ( UndoList.mapPresent (\_ -> model) undoModel, cmd )


reset : ( Model, Cmd Msg ) -> ( UndoModel, Cmd Msg )
reset ( model, cmd ) =
    ( UndoList.fresh model, cmd )



-- DEBUG


itemNotInMap : String -> Id -> Id -> a -> a
itemNotInMap funcName itemId mapId val =
    U.logError funcName ("item " ++ fromInt itemId ++ " not in map " ++ fromInt mapId) val


topicMismatch : String -> Id -> a -> a
topicMismatch funcName id val =
    U.logError funcName (fromInt id ++ " is not a Topic but an Assoc") val


assocMismatch : String -> Id -> a -> a
assocMismatch funcName id val =
    U.logError funcName (fromInt id ++ " is not an Assoc but a Topic") val


illegalMapId : String -> Id -> a -> a
illegalMapId funcName id val =
    illegalId funcName "Map" id val


illegalItemId : String -> Id -> a -> a
illegalItemId funcName id val =
    illegalId funcName "Item" id val


illegalId : String -> String -> Id -> a -> a
illegalId funcName item id val =
    U.logError funcName (fromInt id ++ " is an illegal " ++ item ++ " ID") val



-- === Root-map helpers (moved here to avoid importing Main) ==================


{-| Ensure that:
\* `mapPath` points to an existing map
-}
ensureCurrentMap : Model -> Model
ensureCurrentMap model0 =
    case model0.mapPath of
        id :: _ ->
            if Dict.member id model0.maps then
                model0

            else
                sanitize model0

        [] ->
            sanitize model0


sanitize : Model -> Model
sanitize model0 =
    case Dict.keys model0.maps |> List.head of
        Just firstId ->
            { model0 | mapPath = [ firstId ] }

        Nothing ->
            -- No maps here; creation happens in Main on init
            model0


currentMapId : Model -> MapId
currentMapId model =
    case model.mapPath of
        mid :: _ ->
            mid

        [] ->
            case Dict.keys model.maps |> List.head of
                Just firstId ->
                    firstId

                Nothing ->
                    -- Should not happen after init; treat as root.
                    0


normalizeMapId : Model -> MapId -> MapId
normalizeMapId model mid =
    if Dict.member mid model.maps then
        mid

    else
        currentMapId (ensureCurrentMap model)
````

## File: public/cold-boot.html
````html
<!doctype html>
<meta charset="utf-8">
<title>dm6 wiki console</title>
<link href="https://cdn.jsdelivr.net/npm/@observablehq/inspector@5.0.1/dist/inspector.min.css" rel="stylesheet">
<style>
  :root{ --pad:10px; --muted:#666; --line:#eee; --ring:#ccc; --mono:ui-monospace,SFMono-Regular,Menlo,Consolas,monospace; }
  html,body{ height:100% }
  body{ margin:0; font:14px/1.35 system-ui,-apple-system,Segoe UI,Roboto,sans-serif; }
  details{ border-bottom:1px solid var(--line) }
  summary{ display:flex; gap:8px; align-items:center; padding:8px var(--pad); }
  summary::-webkit-details-marker{ display:none }
  .spacer{ flex:1 }
  .muted{ color:var(--muted); font-size:12px }
  .btn{ padding:4px 8px; border:1px solid var(--ring); border-radius:6px; background:#fafafa; cursor:pointer }
  .btn:hover{ background:#f0f0f0 }

  /* Scroll container (already present) */
  #elmMount{
    overflow:auto;
    /* keep whatever min-height/height/resize you use */
  }

  /* Elm root inside #elmMount must be positioned to contain the overlay */
  #elmMount > div{
    position:relative;
  }

  /* ✅ The overlay: first child inside Elm root */
  #elmMount > div > div:first-child{
    position:absolute !important;
    left:0 !important;
    top:0 !important;
    width:1600px !important;   /* pick your stage size */
    height:1200px !important;
    pointer-events:auto !important;
    z-index:1;                  /* ensure it’s above the SVG */
  }

  /* The SVG visuals (below the overlay) */
  #elmMount svg{
    position:relative !important;
    left:0 !important;
    top:0 !important;
    width:1600px !important;    /* same stage size as overlay */
    height:1200px !important;
    display:block;
    z-index:0;
  }

  #jqbar{ display:flex; gap:8px; align-items:center; padding:8px var(--pad) }
  #jq{ flex:1; border:1px solid var(--ring); height:2.1rem; padding:.35rem .55rem; font:13px/1.35 var(--mono) }
  #result{ max-height:28vh; overflow:auto; padding:0 var(--pad) var(--pad) var(--pad) }
  #flags{ font-size:12px; color:var(--muted) }
  @media (max-width:420px){
    #elmMount{ height:34vh }
    #result{ max-height:24vh }
  }
</style>

<!-- Elm pane -->
<details id="elmPane" open>
  <summary>
    <strong>Elm</strong>
    <span class="toolbar">
      <button id="bootPage"  class="btn">Boot JSON</button>
      <button id="bootEmpty" class="btn">Cold {}</button>
      <span class="spacer"></span>
      <span id="status" class="muted">waiting…</span>
    </span>
  </summary>
  <div id="elmMount"></div>
</details>

<!-- jq pane -->
<details id="jqPane" open>
  <summary>
    <strong>jq</strong>
    <span class="muted" id="jqMeta"></span>
    <span class="spacer"></span>
    <button id="run" class="btn">Run</button>
  </summary>
  <div id="jqbar">
    <input id="jq" list="jq-presets" placeholder=".title · .story|length · .story[]|.type" />
  </div>
  <div id="result"></div>
</details>

<!-- IMPORTANT: this elm.js must be built from AppEmbed.elm (Browser.element) -->
<script src="elm.js"></script>

<!-- jq runtime (globals: window.jq) -->
<script src="https://dobbs.github.io/wiki-jq/jq.js"></script>

<script type="module">
  import * as frames from 'https://wiki.dbbs.co/assets/v1/frame.js'
  import {Inspector} from 'https://cdn.jsdelivr.net/npm/@observablehq/inspector@5.0.1/+esm'

  // ---------- Elements ----------
  const $mount  = document.getElementById('elmMount')
  const $status = document.getElementById('status')
  const $jq     = document.getElementById('jq')
  const $run    = document.getElementById('run')
  const $jqMeta  = document.getElementById('jqMeta')
  const inspector = new Inspector(document.getElementById('result'))

  // ---------- Helpers ----------
  const asSlug = t => String(t||'').replace(/\s/g,'-').replace(/[^A-Za-z0-9-]/g,'').toLowerCase()

  function pickElmModule() {
    if (!window.Elm) { console.error('elm.js not loaded'); return null }
    // Prefer embedded element entrypoint if present
    return window.Elm.AppEmbed || window.Elm.AppMain || window.Elm.Main || null
  }

  // ---------- Elm boot ----------
  function bootElm(flags){
    const App = pickElmModule()
    if (!App) { $status.textContent = 'No Elm module found. Check elm.js build/paths.'; return null }

    // Outer scrolling container
    const mount = document.createElement('div')
    mount.style.position = 'relative'
    mount.style.height   = '100%'      // fills #elmMount
    mount.style.width    = '100%'
    $mount.replaceChildren(mount)

    // Inner fixed-size stage that can be larger than the viewport
    const stage = document.createElement('div')
    stage.style.position = 'relative'
    stage.style.width  = '1600px'      // ← tweak as needed
    stage.style.height = '1200px'      // ← tweak as needed
    mount.appendChild(stage)

    const app  = App.init({ node: stage, flags })
    const name = (App === window.Elm.AppEmbed ? 'AppEmbed' : App === window.Elm.AppMain ? 'AppMain' : 'Main')
    $status.textContent = `Elm(${name}) flags { slug:"${flags.slug}", storedLen:${flags.stored.length} }`

    // (ports wiring unchanged)
    if (app.ports?.pageJson) {
      try { const raw = JSON.stringify(window.data ?? {}); app.ports.pageJson.send(raw) } catch {}
    }
    if (app.ports?.store)   app.ports.store.subscribe(v => console.log('store', String(v).length, 'bytes'))
    if (app.ports?.persist) app.ports.persist.subscribe(v => console.log('persist', String(v).length, 'bytes'))

    return app
  }


  // ---------- jq wiring ----------
  let lastRanAt = 0
  async function runJq(filter) {
    const started = performance.now()
    inspector.pending()
    try{
      if(!window.jq || typeof window.jq.json !== 'function')
        throw new Error('jq runtime not loaded (jq.json unavailable)')
      const data = window.data ?? {}
      const result = await window.jq.json(data, String(filter||'').trim() || '.')
      inspector.fulfilled(result)
      const ms = Math.max(1, Math.round(performance.now() - started))
      const bytes = typeof result === 'string' ? result.length : JSON.stringify(result).length
      lastRanAt = Date.now()
      $jqMeta.textContent = `ok • ${bytes}B • ${ms}ms`
    }catch(err){
      $jqMeta.textContent = 'error'
      inspector.rejected(err)
    }
  }

  // UI events
  $run.onclick = () => runJq($jq.value)
  $jq.addEventListener('keydown', (e) => {
    if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); $run.click() }
  })

  // FedWiki context handshake
  let ctx = {}
  try {
    inspector.pending()
    ctx = await frames.context()
    inspector.fulfilled({ site: ctx.site, title: ctx.title })
  } catch (e) {
    inspector.rejected(e)
    ctx = { site: location.host, title: 'dm6-elm-demo', page: {} }
  }

  // Expose page JSON for jq, like the jq wiki console
  window.data = ctx.page
  const slug = asSlug(ctx.title)

  // Buttons: boot Elm with page JSON or {}
  document.getElementById('bootPage').onclick = () =>
    bootElm({ slug, stored: JSON.stringify(window.data ?? {}) })

  document.getElementById('bootEmpty').onclick = () =>
    bootElm({ slug, stored: "{}" })

  // Auto-boot with page JSON and focus jq input
  document.getElementById('bootPage').click()
  $jq.value = '.title'
  $jq.focus()
  // First run shows something immediately
  runJq($jq.value)
</script>
````

## File: src/Compat/FedWiki.elm
````elm
module Compat.FedWiki exposing
    ( decodePage
    , pageToModel
    , renderAsMonad
    )

import AppModel as AM
import Compat.FedWikiImport as FWI
import Json.Decode as D



-- Old name, stable surface: decode raw JSON to a Value


decodePage : D.Decoder D.Value
decodePage =
    D.value



-- Old name, adapted: call the new importer


pageToModel : D.Value -> AM.Model -> ( AM.Model, Cmd AM.Msg )
pageToModel val model =
    FWI.importPage val model



-- Convenience: raw JSON -> Value -> import -> Model (pure)


renderAsMonad : String -> AM.Model -> AM.Model
renderAsMonad raw model =
    case D.decodeString decodePage raw of
        Ok val ->
            let
                ( m1, _ ) =
                    pageToModel val model
            in
            m1

        Err _ ->
            model
````

## File: src/Compat/ModelAPI.elm
````elm
module Compat.ModelAPI exposing
    ( -- overlayed (guarded) write-path
      addItemToMap
    , addItemToMapDefault
    , childItemIdsOf
    , createAssoc
    , createAssocAndAddToMap
    , createTopic
    , createTopicAndAddToMap
    , currentMapIdOf
    , defaultProps
    , ensureChildMap
    , getMap
    , getMapItem
    , getMapItemById
    , getTopicProps
    , hideItem
    , isItemInMap
    , isMapTopic
    , select
    , setTopicPos
    )

import AppModel as AM
import Config exposing (topicSize)
import Dict
import Model exposing (..)
import ModelAPI as MAPI
    exposing
        ( addItemToMap
        , createAssoc
        , createMap
        , createTopic
        , defaultProps
        , getMap
        , getMapItem
        , getMapItemById
        , getTopicProps
        , hasMap
        , hideItem
        , isMapTopic
        , select
        , setTopicPos
        )



{- ==============================-
      Thin forwards to upstream
   -==============================
-}
-- force monads for topics


defaultProps : Id -> Size -> AM.Model -> TopicProps
defaultProps id size model =
    let
        tp =
            MAPI.defaultProps id size model
    in
    { tp | displayMode = Monad LabelOnly }



-- Delegate core guarded add (single source of truth)


addItemToMap : Id -> MapProps -> MapId -> AM.Model -> AM.Model
addItemToMap =
    MAPI.addItemToMap



-- Forward when present on upstream


createAssoc : String -> String -> Id -> String -> Id -> AM.Model -> ( AM.Model, Id )
createAssoc =
    MAPI.createAssoc


createTopicAndAddToMap : String -> Maybe IconName -> MapId -> AM.Model -> ( AM.Model, Id )
createTopicAndAddToMap title icon mapId model0 =
    let
        -- 1) create the topic (ensures nested map)
        ( model1, topicId ) =
            createTopic title icon model0

        -- 2) props
        props : MapProps
        props =
            MapTopic (MAPI.defaultProps topicId topicSize model1)

        -- 3) add to requested map (guarded add normalizes/guards destination)
        model2 =
            MAPI.addItemToMap topicId props mapId model1

        -- 4) select it on that path
        model3 =
            MAPI.select topicId [ mapId ] model2
    in
    ( model3, topicId )



-- Polyfill: upstream removed this on nested-maps-fix.
-- We re-create it by (1) creating the assoc, then (2) adding its MapAssoc item to mapId.


createAssocAndAddToMap : String -> String -> Id -> String -> Id -> MapId -> AM.Model -> ( AM.Model, Id )
createAssocAndAddToMap itemType role1 player1 role2 player2 mapId model0 =
    let
        ( model1, assocId ) =
            MAPI.createAssoc itemType role1 player1 role2 player2 model0

        model2 =
            MAPI.addItemToMap assocId (MapAssoc AssocProps) mapId model1
    in
    ( model2, assocId )


createTopic : String -> Maybe IconName -> AM.Model -> ( AM.Model, Id )
createTopic =
    MAPI.createTopic


getMapItemById : Id -> MapId -> Maps -> Maybe MapItem
getMapItemById =
    MAPI.getMapItemById


isMapTopic : MapItem -> Bool
isMapTopic =
    MAPI.isMapTopic


getTopicProps : Id -> MapId -> Dict.Dict MapId Map -> Maybe TopicProps
getTopicProps =
    MAPI.getTopicProps


hideItem : Id -> MapId -> AM.Model -> AM.Model
hideItem =
    MAPI.hideItem


setTopicPos : Id -> MapId -> Point -> AM.Model -> AM.Model
setTopicPos =
    MAPI.setTopicPos


select : Id -> MapPath -> AM.Model -> AM.Model
select =
    MAPI.select


getMap : MapId -> Dict.Dict MapId Map -> Maybe Map
getMap =
    MAPI.getMap


getMapItem : Id -> Map -> Maybe MapItem
getMapItem =
    MAPI.getMapItem



{- ========================================-
      Test/useful helpers (local, no upstream)
   -========================================
-}
-- Visible membership helper used by tests:
-- return True only if a (non-hidden) map item exists in the given map.


isItemInMap : Id -> MapId -> AM.Model -> Bool
isItemInMap id mapId model =
    case getMapItemById id mapId model.maps of
        Just mi ->
            not mi.hidden

        Nothing ->
            False


{-| Default add used in tests and simple call-sites.
Creates default props and then calls the guarded `addItemToMap` below.
-}
addItemToMapDefault : Id -> MapId -> AM.Model -> AM.Model
addItemToMapDefault id mapId model =
    let
        tp : TopicProps
        tp =
            MAPI.defaultProps id topicSize model
    in
    MAPI.addItemToMap id (MapTopic tp) mapId model


{-| Return the child map id of a topic, if it exists.
In this model, a topic’s child map id == the topic id.
-}
currentMapIdOf : Id -> AM.Model -> Maybe MapId
currentMapIdOf topicId model =
    if hasMap topicId model.maps then
        Just topicId

    else
        Nothing


{-| Ensure a child map exists for `topicId`. Returns (updatedModel, childMapId).
No need to “attach” a map; creating it with id == topicId is sufficient.
-}
ensureChildMap : Id -> AM.Model -> ( AM.Model, MapId )
ensureChildMap topicId model =
    if hasMap topicId model.maps then
        ( model, topicId )

    else
        let
            model1 =
                createMap topicId model

            -- If you want default container styling like in Main.createMapIfNeeded,
            -- import and call setDisplayModeInAllMaps here.
            -- model2 = MAPI.setDisplayModeInAllMaps topicId (Container BlackBox) model1
        in
        ( model1, topicId )


childItemIdsOf : Id -> AM.Model -> List Id
childItemIdsOf topicId model =
    case currentMapIdOf topicId model of
        Just mapId ->
            case getMap mapId model.maps of
                Just map ->
                    Dict.keys map.items

                Nothing ->
                    []

        Nothing ->
            []
````

## File: src/FedWiki.elm
````elm
module FedWiki exposing
    ( decodePage
    , importString
    , importValue
    , renderAsMonad
    , summarizeLite
    , synopsisLite
    )

import AppModel as AM
import Compat.FedWiki as CFW
import Dict
import Json.Decode as D


decodePage : D.Decoder D.Value
decodePage =
    D.value


importValue : D.Value -> AM.Model -> ( AM.Model, Cmd AM.Msg )
importValue val model =
    CFW.pageToModel val model


importString : String -> AM.Model -> ( AM.Model, Cmd AM.Msg )
importString raw model =
    case D.decodeString decodePage raw of
        Ok val ->
            importValue val model

        Err _ ->
            ( model, Cmd.none )


summarizeLite :
    String
    -> Result String { title : String, total : Int, histogram : Dict.Dict String Int, sample : List { id : String, typ : String } }
summarizeLite raw =
    let
        storyItemLite =
            D.map2 (\id typ -> { id = id, typ = typ })
                (D.field "id" D.string)
                (D.field "type" D.string)

        liteDecoder =
            D.map2 (\title story -> { title = title, story = story })
                (D.field "title" D.string)
                (D.field "story" (D.list storyItemLite))
    in
    case D.decodeString liteDecoder raw of
        Err e ->
            Err (Debug.toString e)

        Ok { title, story } ->
            let
                total =
                    List.length story

                histogram =
                    List.foldl (\s acc -> Dict.update s.typ (\mi -> Just <| Maybe.withDefault 0 mi + 1) acc)
                        Dict.empty
                        story

                sample =
                    List.take 6 story
            in
            Ok { title = title, total = total, histogram = histogram, sample = sample }


renderAsMonad : String -> AM.Model -> AM.Model
renderAsMonad raw model =
    let
        ( m, _ ) =
            importString raw model
    in
    m


synopsisLite : String -> String
synopsisLite raw =
    case summarizeLite raw of
        Ok s ->
            let
                bucket ( k, v ) =
                    String.fromInt v
                        ++ " "
                        ++ k
                        ++ (if v == 1 then
                                ""

                            else
                                "s"
                           )

                parts =
                    s.histogram
                        |> Dict.toList
                        |> List.map bucket
                        |> String.join ", "
            in
            s.title
                ++ " — "
                ++ String.fromInt s.total
                ++ " blocks ("
                ++ parts
                ++ ")"

        Err _ ->
            "unknown — 0 blocks"
````

## File: src/IconMenuAPI.elm
````elm
module IconMenuAPI exposing (closeIconMenu, updateIconMenu, viewIcon, viewIconMenu, viewTopicIcon)

-- components

import AppModel exposing (..)
import Config exposing (..)
import Dict
import FeatherIcons as Icon
import Html exposing (Attribute, Html, button, div, text)
import Html.Attributes exposing (style, title)
import Html.Events exposing (onClick)
import IconMenu
import Model exposing (..)
import ModelAPI exposing (..)
import Storage exposing (store)
import String exposing (fromFloat)
import Utils exposing (..)



-- VIEW


viewIconMenu : Model -> List (Html Msg)
viewIconMenu model =
    if model.iconMenu.open then
        [ div
            iconMenuStyle
            [ div
                iconListStyle
                viewIconList
            , button
                (onClick (IconMenu IconMenu.Close) :: closeButtonStyle)
                [ Icon.x
                    |> Icon.withSize 12
                    |> Icon.toHtml []
                ]
            ]
        ]

    else
        []


iconMenuStyle : List (Attribute Msg)
iconMenuStyle =
    [ style "position" "absolute"
    , style "top" "291px"
    , style "width" "320px"
    , style "height" "320px"
    , style "background-color" "white"
    , style "border" "1px solid lightgray"
    , style "z-index" "1"
    ]


iconListStyle : List (Attribute Msg)
iconListStyle =
    [ style "height" "100%"
    , style "overflow" "auto"
    ]


closeButtonStyle : List (Attribute Msg)
closeButtonStyle =
    [ style "position" "absolute"
    , style "top" "0"
    , style "right" "0"
    ]


viewIconList : List (Html Msg)
viewIconList =
    Icon.icons
        |> Dict.toList
        |> List.map
            (\( iconName, icon ) ->
                button
                    ([ onClick (Just iconName |> IconMenu.SetIcon |> IconMenu)
                     , stopPropagationOnMousedown NoOp
                     , title iconName
                     ]
                        ++ iconButtonStyle
                    )
                    [ Icon.toHtml [] icon ]
            )


iconButtonStyle : List (Attribute Msg)
iconButtonStyle =
    [ style "border-width" "0"
    , style "margin" "8px"
    ]


viewTopicIcon : Id -> Model -> Html Msg
viewTopicIcon topicId model =
    case getTopicInfo topicId model of
        Just topic ->
            case topic.iconName of
                Just iconName ->
                    case Icon.icons |> Dict.get iconName of
                        Just icon ->
                            icon |> Icon.withSize topicIconSize |> Icon.toHtml topicIconStyle

                        Nothing ->
                            text "??"

                Nothing ->
                    text ""

        Nothing ->
            text "?"


viewIcon : String -> Float -> Html Msg
viewIcon iconName size =
    case Icon.icons |> Dict.get iconName of
        Just icon ->
            icon |> Icon.withSize size |> Icon.toHtml []

        Nothing ->
            text "??"


topicIconStyle : List (Attribute Msg)
topicIconStyle =
    [ style "position" "relative"
    , style "top" <| fromFloat ((topicSize.h - topicIconSize) / 2) ++ "px"
    , style "left" <| fromFloat ((topicSize.h - topicIconSize) / 2) ++ "px"
    , style "color" "white"
    ]



-- UPDATE


updateIconMenu : IconMenu.Msg -> UndoModel -> ( UndoModel, Cmd Msg )
updateIconMenu msg ({ present } as undoModel) =
    case msg of
        IconMenu.Open ->
            ( openIconMenu present, Cmd.none ) |> swap undoModel

        IconMenu.Close ->
            ( closeIconMenu present, Cmd.none ) |> swap undoModel

        IconMenu.SetIcon maybeIcon ->
            setIcon maybeIcon present
                |> closeIconMenu
                |> store
                |> push undoModel


openIconMenu : Model -> Model
openIconMenu ({ iconMenu } as model) =
    { model | iconMenu = { iconMenu | open = True } }


closeIconMenu : Model -> Model
closeIconMenu ({ iconMenu } as model) =
    { model | iconMenu = { iconMenu | open = False } }


setIcon : Maybe IconName -> Model -> Model
setIcon iconName model =
    case getSingleSelection model of
        Just ( id, _ ) ->
            updateTopicInfo id
                (\topic -> { topic | iconName = iconName })
                model

        Nothing ->
            model



-- FIXME: illegal state -> make Edit dialog modal
````

## File: src/AppModel.elm
````elm
module AppModel exposing (Model, Msg(..), UndoModel, default)

import Compat.Display as Display exposing (DisplayConfig)
import Dict
import IconMenu
import Model exposing (DisplayMode, EditMsg, EditState(..), Id, Items, Map, MapId, MapPath, Maps, NavMsg, Point, Rectangle, Selection)
import Mouse
import Search
import UndoList exposing (UndoList)



-- UNDO


type alias UndoModel =
    UndoList Model



-- MODEL (must match what Storage.elm builds)


type alias Model =
    { items : Items
    , maps : Maps
    , mapPath : MapPath
    , nextId : Id

    ----- transient -----
    , selection : Selection
    , editState : EditState
    , measureText : String

    -- components
    , mouse : Mouse.Model
    , search : Search.Model
    , iconMenu : IconMenu.Model

    -- Federated Wiki
    , display : DisplayConfig
    , fedWikiRaw : String -- keep for raw JSON
    , fedWiki : FedWikiData -- add structured data
    }


type alias FedWikiData =
    { storyItemIds : List Id
    , containerId : Maybe Id
    }



-- DEFAULT


default : Model
default =
    { items = Dict.empty
    , maps =
        Dict.singleton 0
            -- map 0 is the "home map", it has no corresponding topic
            (Map 0 (Rectangle 0 0 0 0) Dict.empty)
    , mapPath = [ 0 ]
    , nextId = 1

    ----- transient -----
    , selection = []
    , editState = NoEdit
    , measureText = ""

    -- components
    , mouse = Mouse.init
    , search = Search.init
    , iconMenu = IconMenu.init

    -- Federated Wiki
    , display = Display.default
    , fedWikiRaw = ""
    , fedWiki =
        { storyItemIds = []
        , containerId = Nothing
        }
    }



-- MESSAGES


type Msg
    = AddTopic
    | MoveTopicToMap Id MapId Point Id MapPath Point -- start point, random point (for target)
    | SwitchDisplay DisplayMode
    | Edit EditMsg
    | Nav NavMsg
    | Hide
    | Delete
    | Undo
    | Redo
    | Import
    | Export
    | NoOp
      -- components
    | Mouse Mouse.Msg
    | Search Search.Msg
    | IconMenu IconMenu.Msg
````

## File: src/MouseAPI.elm
````elm
module MouseAPI exposing (mouseHoverHandler, mouseSubs, svgMouseHoverHandler, updateMouse)

import AppModel exposing (Model, Msg(..), UndoModel)
import Browser.Events as Events
import Config exposing (assocDelayMillis, topicH2, topicW2, whiteBoxPadding, whiteBoxRange)
import Html exposing (Attribute)
import Html.Events exposing (on)
import IconMenuAPI exposing (closeIconMenu)
import Json.Decode as D
import MapAutoSize exposing (autoSize)
import Model exposing (Class, Id, MapPath, Point)
import ModelAPI
    exposing
        ( createDefaultAssocIn
        , fromPath
        , getMapId
        , getTopicPos
        , push
        , resetSelection
        , select
        , setTopicPosByDelta
        , swap
        )
import Mouse exposing (DragMode(..), DragState(..))
import Random
import SearchAPI exposing (closeResultMenu)
import Storage exposing (storeWith)
import String exposing (fromInt)
import Svg as S
import Svg.Events as SE
import Task
import Time exposing (Posix, posixToMillis)
import Utils
    exposing
        ( classDecoder
        , idDecoder
        , info
        , logError
        , pathDecoder
        , pointDecoder
        , toString
        )



-- VIEW


mouseHoverHandler : List (Attribute Msg)
mouseHoverHandler =
    [ on "mouseover" (mouseDecoder Mouse.Over)
    , on "mouseout" (mouseDecoder Mouse.Out)
    ]


svgMouseHoverHandler : List (S.Attribute Msg)
svgMouseHoverHandler =
    [ SE.on "mouseover" (mouseDecoder Mouse.Over)
    , SE.on "mouseout" (mouseDecoder Mouse.Out)
    ]



-- UPDATE


updateMouse : Mouse.Msg -> UndoModel -> ( UndoModel, Cmd Msg )
updateMouse msg ({ present } as undoModel) =
    case msg of
        Mouse.Down ->
            ( mouseDown present, Cmd.none ) |> swap undoModel

        Mouse.DownOnItem class id mapPath pos ->
            mouseDownOnItem present class id mapPath pos
                |> swap undoModel

        Mouse.Move pos ->
            case present.mouse.dragState of
                NoDrag ->
                    -- don't forward Move into mouseMove; avoids the spammy log
                    ( undoModel, Cmd.none )

                WaitForStartTime _ _ _ _ ->
                    -- still waiting for the debounce/start timer; ignore Move
                    ( undoModel, Cmd.none )

                -- For all other drag states, let mouseMove handle it.
                _ ->
                    mouseMove present pos |> swap undoModel

        Mouse.Up ->
            case present.mouse.dragState of
                NoDrag ->
                    -- Stray mouseup (e.g. click on non-draggable or release outside)
                    ( undoModel, Cmd.none )

                WaitForStartTime _ _ _ _ ->
                    -- Released before drag engaged → cancel tentative drag
                    ( updateDragState present NoDrag, Cmd.none )
                        |> swap undoModel

                _ ->
                    mouseUp undoModel

        Mouse.Over class id mapPath ->
            ( mouseOver present class id mapPath, Cmd.none )
                |> swap undoModel

        Mouse.Out class id mapPath ->
            ( mouseOut present class id mapPath, Cmd.none )
                |> swap undoModel

        Mouse.Time time ->
            timeArrived time undoModel


mouseDown : Model -> Model
mouseDown model =
    model
        |> resetSelection
        |> closeIconMenu
        |> closeResultMenu


mouseDownOnItem : Model -> Class -> Id -> MapPath -> Point -> ( Model, Cmd Msg )
mouseDownOnItem model class id mapPath pos =
    ( updateDragState model (WaitForStartTime class id mapPath pos)
        |> select id mapPath
    , Task.perform (Mouse << Mouse.Time) Time.now
    )


timeArrived : Posix -> UndoModel -> ( UndoModel, Cmd Msg )
timeArrived time ({ present } as undoModel) =
    case present.mouse.dragState of
        WaitForStartTime class id mapPath pos ->
            let
                dragState =
                    DragEngaged time class id mapPath pos
            in
            ( updateDragState present dragState, Cmd.none )
                |> swap undoModel

        WaitForEndTime startTime class id mapPath pos ->
            let
                delay =
                    posixToMillis time - posixToMillis startTime > assocDelayMillis

                ( dragMode, historyFunc ) =
                    if delay then
                        ( DrawAssoc, swap )

                    else
                        ( DragTopic, push )

                maybeOrigPos =
                    getTopicPos id (getMapId mapPath) present.maps

                dragState =
                    case class of
                        "dmx-topic" ->
                            case maybeOrigPos of
                                Just origPos ->
                                    Drag dragMode id mapPath origPos pos Nothing

                                Nothing ->
                                    NoDrag

                        -- error is already logged
                        _ ->
                            NoDrag

                -- the error will be logged in performDrag
            in
            ( updateDragState present dragState, Cmd.none )
                |> historyFunc undoModel

        _ ->
            logError "timeArrived"
                "Received \"Time\" message when dragState is not WaitForTime"
                ( undoModel, Cmd.none )


mouseMove : Model -> Point -> ( Model, Cmd Msg )
mouseMove model pos =
    case model.mouse.dragState of
        DragEngaged time class id mapPath pos_ ->
            ( updateDragState model <| WaitForEndTime time class id mapPath pos_
            , Task.perform (Mouse << Mouse.Time) Time.now
            )

        WaitForEndTime _ _ _ _ _ ->
            ( model, Cmd.none )

        -- ignore -- TODO: can this happen at all? Is there a move listener?
        Drag _ _ _ _ _ _ ->
            ( performDrag model pos, Cmd.none )

        _ ->
            logError "mouseMove"
                ("Received \"Move\" message when dragState is " ++ toString model.mouse.dragState)
                ( model, Cmd.none )


performDrag : Model -> Point -> Model
performDrag model pos =
    case model.mouse.dragState of
        Drag dragMode id mapPath origPos lastPos target ->
            let
                delta =
                    Point
                        (pos.x - lastPos.x)
                        (pos.y - lastPos.y)

                mapId =
                    getMapId mapPath

                newModel =
                    case dragMode of
                        DragTopic ->
                            setTopicPosByDelta id mapId delta model

                        DrawAssoc ->
                            model
            in
            -- update lastPos
            updateDragState newModel (Drag dragMode id mapPath origPos pos target)
                |> autoSize

        _ ->
            logError "performDrag"
                ("Received \"Move\" message when dragState is " ++ toString model.mouse.dragState)
                model


mouseUp : UndoModel -> ( UndoModel, Cmd Msg )
mouseUp ({ present } as undoModel) =
    let
        ( model, cmd, historyFunc ) =
            case present.mouse.dragState of
                Drag DragTopic id mapPath origPos _ (Just ( targetId, targetMapPath )) ->
                    let
                        _ =
                            info "mouseUp"
                                ("dropped "
                                    ++ fromInt id
                                    ++ " (map "
                                    ++ fromPath mapPath
                                    ++ ") on "
                                    ++ fromInt targetId
                                    ++ " (map "
                                    ++ fromPath targetMapPath
                                    ++ ") --> "
                                    ++ (if notDroppedOnOwnMap then
                                            "move topic"

                                        else
                                            "abort"
                                       )
                                )

                        mapId =
                            getMapId mapPath

                        notDroppedOnOwnMap =
                            mapId /= targetId

                        msg =
                            MoveTopicToMap id mapId origPos targetId targetMapPath
                    in
                    if notDroppedOnOwnMap then
                        ( present, Random.generate msg point, swap )

                    else
                        ( present, Cmd.none, swap )

                Drag DrawAssoc id mapPath _ _ (Just ( targetId, targetMapPath )) ->
                    let
                        _ =
                            info "mouseUp"
                                ("assoc drawn from "
                                    ++ fromInt id
                                    ++ " (map "
                                    ++ fromPath
                                        mapPath
                                    ++ ") to "
                                    ++ fromInt targetId
                                    ++ " (map "
                                    ++ fromPath targetMapPath
                                    ++ ") --> "
                                    ++ (if isSameMap then
                                            "create assoc"

                                        else
                                            "abort"
                                       )
                                )

                        mapId =
                            getMapId mapPath

                        isSameMap =
                            mapId == getMapId targetMapPath
                    in
                    if isSameMap then
                        ( createDefaultAssocIn id targetId mapId present, Cmd.none, push )

                    else
                        ( present, Cmd.none, swap )

                Drag _ _ _ _ _ _ ->
                    let
                        _ =
                            info "mouseUp" "drag ended w/o target"
                    in
                    ( present, Cmd.none, swap )

                DragEngaged _ _ _ _ _ ->
                    let
                        _ =
                            info "mouseUp" "drag aborted w/o moving"
                    in
                    ( present, Cmd.none, swap )

                _ ->
                    logError "mouseUp"
                        ("Received \"Up\" message when dragState is " ++ toString present.mouse.dragState)
                        ( present, Cmd.none, swap )
    in
    ( updateDragState model NoDrag, cmd )
        |> storeWith
        |> historyFunc undoModel


point : Random.Generator Point
point =
    let
        cx =
            topicW2 + whiteBoxPadding

        cy =
            topicH2 + whiteBoxPadding

        rw =
            whiteBoxRange.w

        rh =
            whiteBoxRange.h
    in
    Random.map2
        (\x y -> Point (cx + x) (cy + y))
        (Random.float 0 rw)
        (Random.float 0 rh)


mouseOver : Model -> Class -> Id -> MapPath -> Model
mouseOver model _ targetId targetMapPath =
    case model.mouse.dragState of
        Drag dragMode id mapPath origPos lastPos _ ->
            let
                mapId =
                    getMapId mapPath

                targetMapId =
                    getMapId targetMapPath

                target =
                    if ( id, mapId ) /= ( targetId, targetMapId ) then
                        -- TODO: mapId comparison needed?
                        Just ( targetId, targetMapPath )

                    else
                        Nothing
            in
            -- update target
            updateDragState model <| Drag dragMode id mapPath origPos lastPos target

        DragEngaged _ _ _ _ _ ->
            logError "mouseOver" "Received \"Over\" message when dragState is DragEngaged" model

        _ ->
            model


mouseOut : Model -> Class -> Id -> MapPath -> Model
mouseOut model _ _ _ =
    case model.mouse.dragState of
        Drag dragMode id mapPath origPos lastPos _ ->
            -- reset target
            updateDragState model <| Drag dragMode id mapPath origPos lastPos Nothing

        _ ->
            model


updateDragState : Model -> DragState -> Model
updateDragState ({ mouse } as model) dragState =
    { model | mouse = { mouse | dragState = dragState } }



-- SUBSCRIPTIONS


mouseSubs : UndoModel -> Sub Msg
mouseSubs { present } =
    case present.mouse.dragState of
        WaitForStartTime _ _ _ _ ->
            Sub.none

        WaitForEndTime _ _ _ _ _ ->
            Sub.none

        DragEngaged _ _ _ _ _ ->
            dragSub

        Drag _ _ _ _ _ _ ->
            dragSub

        NoDrag ->
            mouseDownSub


mouseDownSub : Sub Msg
mouseDownSub =
    Events.onMouseDown <|
        D.oneOf
            [ D.map Mouse <| D.map4 Mouse.DownOnItem classDecoder idDecoder pathDecoder pointDecoder
            , D.succeed (Mouse Mouse.Down)
            ]


dragSub : Sub Msg
dragSub =
    Sub.batch
        [ Events.onMouseMove <| D.map Mouse <| D.map Mouse.Move pointDecoder
        , Events.onMouseUp <| D.map Mouse <| D.succeed Mouse.Up
        ]


mouseDecoder : (Class -> Id -> MapPath -> Mouse.Msg) -> D.Decoder Msg
mouseDecoder msg =
    D.map Mouse <| D.map3 msg classDecoder idDecoder pathDecoder
````

## File: src/Storage.elm
````elm
port module Storage exposing
    ( exportJSON
    , importJSON
    , modelDecoder
    , store
      -- keep both APIs so all callers work
    , storeModel
    , storeModelWith
    , storeWith
    )

-- Model, Item, Map, etc.

import AppModel as AM
import Compat.Display as Display
import Defaults exposing (editState, iconMenu, mouse, search)
import Dict exposing (Dict)
import Json.Decode as D
import Json.Decode.Pipeline exposing (hardcoded, required)
import Json.Encode as E
import Model as M exposing (..)



-- keep using M.Item, M.Map, etc.
-- JS sink


port persist : E.Value -> Cmd msg



-- ========= SAVE (pipeline-friendly, as your callers expect) =========


storeModel : AM.Model -> ( AM.Model, Cmd AM.Msg )
storeModel model =
    ( model, encodeModel model |> persist )


storeModelWith : ( AM.Model, Cmd AM.Msg ) -> ( AM.Model, Cmd AM.Msg )
storeModelWith ( model, cmd ) =
    ( model
    , Cmd.batch
        [ cmd
        , encodeModel model |> persist
        ]
    )



-- Back-compat aliases some modules import


store : AM.Model -> ( AM.Model, Cmd AM.Msg )
store =
    storeModel


storeWith : ( AM.Model, Cmd AM.Msg ) -> ( AM.Model, Cmd AM.Msg )
storeWith =
    storeModelWith



-- ========= IMPORT/EXPORT (no-ops in embed) =========


importJSON : () -> Cmd AM.Msg
importJSON _ =
    Cmd.none


exportJSON : () -> Cmd AM.Msg
exportJSON _ =
    Cmd.none



-- ========= ENCODE (for persist port) =========


encodeModel : AM.Model -> E.Value
encodeModel model =
    E.object
        [ ( "items", model.items |> Dict.values |> E.list encodeItem )
        , ( "maps", model.maps |> Dict.values |> E.list encodeMap )
        , ( "mapPath", E.list E.int model.mapPath )
        , ( "nextId", E.int model.nextId )
        ]


encodeItem : Item -> E.Value
encodeItem item =
    E.object
        [ case item.info of
            Topic topic ->
                ( "topic"
                , E.object
                    [ ( "id", E.int topic.id )
                    , ( "text", E.string topic.text )
                    , ( "icon", E.string <| Maybe.withDefault "" topic.iconName )
                    ]
                )

            Assoc assoc ->
                ( "assoc"
                , E.object
                    [ ( "id", E.int assoc.id )
                    , ( "type", E.string assoc.itemType )
                    , ( "role1", E.string assoc.role1 )
                    , ( "player1", E.int assoc.player1 )
                    , ( "role2", E.string assoc.role2 )
                    , ( "player2", E.int assoc.player2 )
                    ]
                )
        ]


encodeMap : Map -> E.Value
encodeMap map =
    E.object
        [ ( "id", E.int map.id )
        , ( "rect"
          , E.object
                [ ( "x1", E.float map.rect.x1 )
                , ( "y1", E.float map.rect.y1 )
                , ( "x2", E.float map.rect.x2 )
                , ( "y2", E.float map.rect.y2 )
                ]
          )
        , ( "items", map.items |> Dict.values |> E.list encodeMapItem )
        ]


encodeMapItem : MapItem -> E.Value
encodeMapItem item =
    E.object
        [ ( "id", E.int item.id )
        , ( "parentAssocId", E.int item.parentAssocId )
        , ( "hidden", E.bool item.hidden )
        , ( "pinned", E.bool item.pinned )
        , case item.props of
            MapTopic topicProps ->
                ( "topicProps"
                , E.object
                    [ ( "pos"
                      , E.object [ ( "x", E.float topicProps.pos.x ), ( "y", E.float topicProps.pos.y ) ]
                      )
                    , ( "size"
                      , E.object [ ( "w", E.float topicProps.size.w ), ( "h", E.float topicProps.size.h ) ]
                      )
                    , ( "display", encodeDisplayName topicProps.displayMode )
                    ]
                )

            MapAssoc _ ->
                ( "assocProps", E.object [] )
        ]


encodeDisplayName : DisplayMode -> E.Value
encodeDisplayName displayMode =
    E.string <|
        case displayMode of
            Monad LabelOnly ->
                "LabelOnly"

            Monad Detail ->
                "Detail"

            Container BlackBox ->
                "BlackBox"

            Container WhiteBox ->
                "WhiteBox"

            Container Unboxed ->
                "Unboxed"



-- ========= DECODE (for localStorage) =========


fullModelDecoder : D.Decoder AM.Model
fullModelDecoder =
    D.succeed AM.Model
        |> required "items" (D.list itemDecoder |> D.andThen tupleToDictDecoder)
        |> required "maps" (D.list mapDecoder |> D.andThen toDictDecoder)
        |> required "mapPath" (D.list D.int)
        |> required "nextId" D.int
        -- transient / components come from Defaults (no import cycles)
        |> hardcoded []
        -- selection
        |> hardcoded editState
        |> hardcoded ""
        -- measureText
        |> hardcoded mouse
        |> hardcoded search
        |> hardcoded iconMenu
        -- add these two to close the constructor:
        |> hardcoded Display.default
        |> hardcoded ""
        -- ADD THIS LINE for the new fedWiki field
        |> hardcoded { storyItemIds = [], containerId = Nothing }


fallbackDecoder : D.Decoder AM.Model
fallbackDecoder =
    D.succeed AM.Model
        -- items
        |> hardcoded Dict.empty
        -- maps (will be filled by ensureRoot)
        |> hardcoded Dict.empty
        -- mapPath (will be filled by ensureRoot)
        |> hardcoded []
        -- nextId (may be bumped by ensureRoot)
        |> hardcoded 1
        -- selection
        |> hardcoded []
        |> hardcoded editState
        -- measureText
        |> hardcoded ""
        |> hardcoded mouse
        |> hardcoded search
        |> hardcoded iconMenu
        -- display
        |> hardcoded Display.default
        -- fedWikiRaw
        |> hardcoded ""
        -- ADD THIS LINE for the new fedWiki field
        |> hardcoded { storyItemIds = [], containerId = Nothing }


modelDecoder : D.Decoder AM.Model
modelDecoder =
    -- Try legacy stored blob; otherwise start from an empty in-repo model
    D.oneOf
        [ fullModelDecoder
        , fallbackDecoder
        ]
        |> D.map ensureRoot


rootRect : M.Rectangle
rootRect =
    -- match your stage size
    M.Rectangle 0 0 1600 1200


ensureRoot : AM.Model -> AM.Model
ensureRoot m0 =
    let
        maps1 =
            if Dict.isEmpty m0.maps then
                Dict.fromList [ ( 0, M.Map 0 rootRect Dict.empty ) ]

            else
                m0.maps

        path1 =
            if List.isEmpty m0.mapPath then
                [ 0 ]

            else
                m0.mapPath

        bumpNext n =
            let
                maxMapId =
                    Dict.keys maps1 |> List.maximum |> Maybe.withDefault 0
            in
            if n <= maxMapId then
                maxMapId + 1

            else
                n
    in
    { m0 | maps = maps1, mapPath = path1, nextId = bumpNext m0.nextId }



-- ===== helpers for decode =====


itemDecoder : D.Decoder ( Id, ItemInfo )
itemDecoder =
    D.oneOf
        [ D.field "topic"
            (D.map2 Tuple.pair
                (D.field "id" D.int)
                (D.map Topic <|
                    D.map3 TopicInfo
                        (D.field "id" D.int)
                        (D.field "text" D.string)
                        (D.field "icon" D.string |> D.andThen maybeString)
                )
            )
        , D.field "assoc"
            (D.map2 Tuple.pair
                (D.field "id" D.int)
                (D.map Assoc <|
                    D.map6 AssocInfo
                        (D.field "id" D.int)
                        (D.field "type" D.string)
                        (D.field "role1" D.string)
                        (D.field "player1" D.int)
                        (D.field "role2" D.string)
                        (D.field "player2" D.int)
                )
            )
        ]


mapDecoder : D.Decoder Map
mapDecoder =
    D.map3 Map
        (D.field "id" D.int)
        (D.field "rect"
            (D.map4 Rectangle
                (D.field "x1" D.float)
                (D.field "y1" D.float)
                (D.field "x2" D.float)
                (D.field "y2" D.float)
            )
        )
        (D.field "items" (D.list mapItemDecoder |> D.andThen toDictDecoder))


mapItemDecoder : D.Decoder MapItem
mapItemDecoder =
    D.map5 MapItem
        (D.field "id" D.int)
        (D.field "parentAssocId" D.int)
        (D.field "hidden" D.bool)
        (D.field "pinned" D.bool)
        (D.oneOf
            [ D.field "topicProps"
                (D.map MapTopic
                    (D.map3 TopicProps
                        (D.field "pos" (D.map2 Point (D.field "x" D.float) (D.field "y" D.float)))
                        (D.field "size" (D.map2 Size (D.field "w" D.float) (D.field "h" D.float)))
                        (D.field "display" D.string |> D.andThen displayModeDecoder)
                    )
                )
            , D.field "assocProps" (D.succeed (MapAssoc AssocProps))
            ]
        )


tupleToDictDecoder : List ( Id, ItemInfo ) -> D.Decoder Items
tupleToDictDecoder tuples =
    tuples
        |> List.map (\( id, info ) -> ( id, Item id info ))
        |> Dict.fromList
        |> D.succeed


toDictDecoder : List { item | id : Id } -> D.Decoder (Dict Int { item | id : Id })
toDictDecoder items =
    items
        |> List.map (\item -> ( item.id, item ))
        |> Dict.fromList
        |> D.succeed


displayModeDecoder : String -> D.Decoder DisplayMode
displayModeDecoder str =
    case str of
        "LabelOnly" ->
            D.succeed (Monad LabelOnly)

        "Detail" ->
            D.succeed (Monad Detail)

        "BlackBox" ->
            D.succeed (Container BlackBox)

        "WhiteBox" ->
            D.succeed (Container WhiteBox)

        "Unboxed" ->
            D.succeed (Container Unboxed)

        _ ->
            D.fail <| "\"" ++ str ++ "\" is an invalid display mode"


maybeString : String -> D.Decoder (Maybe String)
maybeString str =
    D.succeed
        (if str == "" then
            Nothing

         else
            Just str
        )
````

## File: src/Compat/FedWikiImport.elm
````elm
module Compat.FedWikiImport exposing
    ( Page
    , encodeFwMeta
    , importPage
    , pageDecoder
    , storyItemDecoder
    )

import AppModel as AM
import Compat.ModelAPI as CAPI
import Dict
import Json.Decode as D exposing (Decoder)
import Json.Encode as E
import Model exposing (DisplayMode(..), Id, MapItem, MapItems, MapProps(..), Rectangle, TopicProps)
import ModelAPI exposing (currentMapId, updateMaps)
import String
import Utils as U



-- TYPES


type alias Page =
    { title : String
    , story : List StoryItem
    }



-- Carry both type and text so we can create a label for any story block


type alias StoryItem =
    { typ : String
    , text : String
    }



-- DECODERS


titleDecoder : Decoder String
titleDecoder =
    D.maybe (D.field "title" D.string)
        |> D.map (Maybe.withDefault "empty")


paragraphTextDecoder : Decoder String
paragraphTextDecoder =
    D.maybe (D.field "text" D.string)
        |> D.map (Maybe.withDefault "")


storyItemDecoder : Decoder StoryItem
storyItemDecoder =
    D.map2 StoryItem
        (D.maybe (D.field "type" D.string) |> D.map (Maybe.withDefault "unknown"))
        (D.maybe (D.field "text" D.string) |> D.map (Maybe.withDefault ""))


storyDecoder : Decoder (List StoryItem)
storyDecoder =
    D.maybe (D.field "story" (D.list storyItemDecoder))
        |> D.map (Maybe.withDefault [])


pageDecoder : Decoder Page
pageDecoder =
    D.map2 Page
        titleDecoder
        storyDecoder



-- IMPORT


{-| Import a FedWiki page JSON Value into the model.

  - {} is valid -> title defaults to "empty"
  - Create one topic for the page title (container)
  - Ensure it has a child map
  - Create one topic per story item **in the child map**
  - Persist lightweight meta (container + story ids) into `fedWikiRaw`

-}
importPage : D.Value -> AM.Model -> ( AM.Model, Cmd msg )
importPage value model0 =
    case D.decodeValue pageDecoder value of
        Err _ ->
            let
                mid =
                    currentMapId model0

                ( model1, titleId ) =
                    CAPI.createTopicAndAddToMap "empty" Nothing mid model0

                -- Immediately show the title as a WhiteBox container on the current map
                model1a =
                    setWhiteBoxOnCurrentMap titleId model1

                ( model2, childMid ) =
                    CAPI.ensureChildMap titleId model1a

                model3 =
                    { model2
                        | fedWikiRaw = encodeFwMeta titleId []
                        , fedWiki =
                            { storyItemIds = []
                            , containerId = Just titleId
                            }
                    }
            in
            ( model3, Cmd.none )

        Ok page ->
            let
                mid =
                    currentMapId model0

                titleLabel : String
                titleLabel =
                    page.title
                        |> String.trim
                        |> (\t ->
                                if t == "" then
                                    "empty"

                                else
                                    t
                           )

                -- 1) Create title topic (container) in current map
                ( model1, titleId ) =
                    CAPI.createTopicAndAddToMap titleLabel Nothing mid model0

                -- 2) Flip it to WhiteBox on the current map *immediately*
                model1a =
                    setWhiteBoxOnCurrentMap titleId model1

                -- 3) Ensure the container has a child map
                ( model2, childMid ) =
                    CAPI.ensureChildMap titleId model1a

                -- 4) Create topics for each story item inside the CHILD map
                step :
                    StoryItem
                    -> ( List Id, AM.Model )
                    -> ( List Id, AM.Model )
                step si ( accIds, m ) =
                    let
                        raw =
                            String.trim si.text

                        label0 =
                            if raw == "" then
                                String.trim si.typ

                            else
                                raw
                                    |> String.lines
                                    |> List.head
                                    |> Maybe.withDefault raw
                                    |> String.left 120
                                    |> String.trim

                        label =
                            if label0 == "" then
                                "untitled"

                            else
                                label0

                        ( m2, id2 ) =
                            CAPI.createTopicAndAddToMap label Nothing childMid m
                    in
                    ( id2 :: accIds, m2 )

                ( revIds, model3 ) =
                    List.foldl step ( [], model2 ) page.story

                storyIds =
                    List.reverse revIds

                _ =
                    U.info "fedwiki.import.structured"
                        { containerId = titleId
                        , storyCount = List.length storyIds
                        }

                modelFinal =
                    { model3
                        | fedWikiRaw = encodeFwMeta titleId storyIds
                        , fedWiki =
                            { storyItemIds = storyIds
                            , containerId = Just titleId
                            }
                    }
            in
            ( modelFinal, Cmd.none )


encodeFwMeta : Int -> List Int -> String
encodeFwMeta containerId storyItemIds =
    E.encode 0 <|
        E.object
            [ ( "containerId", E.int containerId )
            , ( "storyItemIds", E.list E.int storyItemIds )
            ]


{-| Immediately flip the freshly created title item to Container WhiteBox
on the _current_ map (the same map we just added it to).
-}
setWhiteBoxOnCurrentMap : Id -> AM.Model -> AM.Model
setWhiteBoxOnCurrentMap tid model =
    let
        _ =
            U.info "setWhiteBoxOnCurrentMap" { topicId = tid, currentMapId = currentMapId model }

        mid =
            currentMapId model
    in
    ModelAPI.setDisplayMode tid mid (Container Model.WhiteBox) model
````

## File: src/AppMain.elm
````elm
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
````

## File: src/AppRunner.elm
````elm
module AppRunner exposing
    ( Msg(..)
    , UndoModel
    , fromInner
    , init
    , onFedWikiPage
    , subscriptions
    , update
    , view
    )

import AppModel as AM
import Browser
import Compat.FedWiki as CFW
import Dict
import FedWiki as FW
import Html as H
import IconMenu
import Json.Decode as D
import Json.Encode as E
import Main
import Model exposing (EditMsg, NavMsg)
import ModelAPI exposing (activeMap)
import Mouse
import MouseAPI exposing (mouseSubs)
import Platform.Sub as Sub
import Search
import Types exposing (DisplayMode, Id, MapId, MapPath, Point)
import Utils as U



-- --- FedWiki peek decoders & helpers (diagnostics only) ----------------------


type alias FWStoryLite =
    { id : String
    , typ : String
    }


type alias FWPageLite =
    { title : String
    , story : List FWStoryLite
    }


fwStoryLiteDecoder : D.Decoder FWStoryLite
fwStoryLiteDecoder =
    D.map2 FWStoryLite
        (D.field "id" D.string)
        (D.field "type" D.string)


fwPageLiteDecoder : D.Decoder FWPageLite
fwPageLiteDecoder =
    D.map2 FWPageLite
        (D.field "title" D.string)
        (D.field "story" (D.list fwStoryLiteDecoder))


typeHistogram : List FWStoryLite -> Dict.Dict String Int
typeHistogram items =
    let
        bump : String -> Dict.Dict String Int -> Dict.Dict String Int
        bump k =
            Dict.update k (\mi -> Just <| Maybe.withDefault 0 mi + 1)
    in
    List.foldl (\s acc -> bump s.typ acc) Dict.empty items


firstN : Int -> List FWStoryLite -> List FWStoryLite
firstN n xs =
    xs |> List.take n



-- local alias so we can expose UndoModel from this module


type alias UndoModel =
    AM.UndoModel



-- EXPLICIT WRAPPER MESSAGE (mirrors AM.Msg) + FedWiki


type Msg
    = AddTopic
    | MoveTopicToMap Id MapId Point Id MapPath Point
    | SwitchDisplay DisplayMode
    | Edit EditMsg
    | Nav NavMsg
    | Hide
    | Delete
    | Undo
    | Redo
    | Import
    | Export
    | NoOp
      -- components
    | Mouse Mouse.Msg
    | Search Search.Msg
    | IconMenu IconMenu.Msg
      -- external (kept in AppRunner)
    | FedWikiPage String



-- Map AppRunner.Msg -> AM.Msg (when delegating to Main)


toInner : Msg -> Maybe AM.Msg
toInner msg =
    case msg of
        AddTopic ->
            Just AM.AddTopic

        MoveTopicToMap a b c d e f ->
            Just (AM.MoveTopicToMap a b c d e f)

        SwitchDisplay d ->
            Just (AM.SwitchDisplay d)

        Edit m ->
            Just (AM.Edit m)

        Nav m ->
            Just (AM.Nav m)

        Hide ->
            Just AM.Hide

        Delete ->
            Just AM.Delete

        Undo ->
            Just AM.Undo

        Redo ->
            Just AM.Redo

        Import ->
            Just AM.Import

        Export ->
            Just AM.Export

        NoOp ->
            Just AM.NoOp

        Mouse m ->
            Just (AM.Mouse m)

        Search m ->
            Just (AM.Search m)

        IconMenu m ->
            Just (AM.IconMenu m)

        FedWikiPage _ ->
            Nothing



-- Map AM.Msg -> AppRunner.Msg (for Cmd/view/subs mapping)


fromInner : AM.Msg -> Msg
fromInner am =
    case am of
        AM.AddTopic ->
            AddTopic

        AM.MoveTopicToMap a b c d e f ->
            MoveTopicToMap a b c d e f

        AM.SwitchDisplay d ->
            SwitchDisplay d

        AM.Edit m ->
            Edit m

        AM.Nav m ->
            Nav m

        AM.Hide ->
            Hide

        AM.Delete ->
            Delete

        AM.Undo ->
            Undo

        AM.Redo ->
            Redo

        AM.Import ->
            Import

        AM.Export ->
            Export

        AM.NoOp ->
            NoOp

        AM.Mouse m ->
            Mouse m

        AM.Search m ->
            Search m

        AM.IconMenu m ->
            IconMenu m



-- Init: map Cmd AM.Msg -> Cmd AppRunner.Msg


init : E.Value -> ( UndoModel, Cmd Msg )
init =
    Main.init >> Tuple.mapSecond (Cmd.map fromInner)



-- WRAP update: handle FedWikiPage here, delegate everything else.


update : Msg -> AM.UndoModel -> ( AM.UndoModel, Cmd Msg )
update msg undo =
    case msg of
        FedWikiPage rawJson ->
            let
                -- Peek the payload BEFORE Compat import
                _ =
                    case D.decodeString fwPageLiteDecoder rawJson of
                        Ok lite ->
                            let
                                total =
                                    List.length lite.story

                                hist =
                                    typeHistogram lite.story

                                sample =
                                    firstN 6 lite.story

                                _ =
                                    U.info "fedwiki.story.stats"
                                        { title = lite.title
                                        , total = total
                                        , histogram = hist
                                        , sample = List.map (\s -> { id = s.id, typ = s.typ }) sample
                                        }
                            in
                            ()

                        Err err ->
                            let
                                _ =
                                    U.info "fedwiki.story.decode.err"
                                        { error = Debug.toString err
                                        , rawLen = String.length rawJson
                                        }
                            in
                            ()

                _ =
                    U.info "fedwiki.synopsis" (FW.synopsisLite rawJson)
            in
            -- Proceed with your existing Compat import
            case D.decodeString CFW.decodePage rawJson of
                Ok val ->
                    let
                        ( model1, _ ) =
                            CFW.pageToModel val undo.present

                        _ =
                            U.info "fedwiki.decode.ok"
                                { rawLen = String.length rawJson }

                        _ =
                            U.info "fedwiki.import"
                                { itemsBefore = Dict.size undo.present.items
                                , itemsAfter = Dict.size model1.items
                                , itemsCreated = Dict.size model1.items - Dict.size undo.present.items
                                , mapsBefore = Dict.size undo.present.maps
                                , mapsAfter = Dict.size model1.maps
                                , mapsDelta = Dict.size model1.maps - Dict.size undo.present.maps
                                }
                    in
                    ( { undo | present = { model1 | fedWikiRaw = rawJson } }
                    , Cmd.none
                    )

                Err err ->
                    let
                        _ =
                            U.info "fedwiki.decode.err"
                                { error = Debug.toString err
                                , rawLen = String.length rawJson
                                }
                    in
                    ( undo, Cmd.none )

        _ ->
            forward msg undo


forward : Msg -> UndoModel -> ( UndoModel, Cmd Msg )
forward msg undo =
    case toInner msg of
        Just inner ->
            let
                beforeItems =
                    Dict.size undo.present.items

                beforeMaps =
                    Dict.size undo.present.maps

                beforeActive =
                    activeMap undo.present

                ( undo1, cmd1 ) =
                    Main.update inner undo

                afterItems =
                    Dict.size undo1.present.items

                afterMaps =
                    Dict.size undo1.present.maps

                afterActive =
                    activeMap undo1.present

                _ =
                    U.info "app.update.forward"
                        { itemsBefore = beforeItems
                        , itemsAfter = afterItems
                        , itemsDelta = afterItems - beforeItems
                        , mapsBefore = beforeMaps
                        , mapsAfter = afterMaps
                        , mapsDelta = afterMaps - beforeMaps
                        , activeBefore = beforeActive
                        , activeAfter = afterActive
                        }
            in
            ( undo1, Cmd.map fromInner cmd1 )

        Nothing ->
            ( undo, Cmd.none )


subscriptions : AM.UndoModel -> Sub.Sub Msg
subscriptions undo =
    Sub.map fromInner (mouseSubs undo)



-- Map-only element view (moved here from Main)


view : AM.UndoModel -> Browser.Document Msg
view undo =
    let
        doc =
            Main.view undo

        -- Browser.Document Main.Msg
    in
    { title = doc.title
    , body = List.map (H.map fromInner) doc.body
    }



-- Called by AppEmbed when the frame sends the current page’s JSON


onFedWikiPage : String -> AM.UndoModel -> ( AM.UndoModel, Cmd msg )
onFedWikiPage raw undoModel =
    case D.decodeString CFW.decodePage raw of
        Ok val ->
            let
                before =
                    Dict.size undoModel.present.items

                -- Importer creates the page topic AND all story items
                ( model1, _ ) =
                    CFW.pageToModel val undoModel.present

                after =
                    Dict.size model1.items

                _ =
                    U.info "fedwiki.import"
                        { before = before
                        , after = after
                        , created = after - before
                        , activeMap = activeMap model1
                        }
            in
            ( { undoModel | present = { model1 | fedWikiRaw = raw } }
            , Cmd.none
            )

        Err _ ->
            ( undoModel, Cmd.none )
````

## File: src/AppEmbed.elm
````elm
port module AppEmbed exposing (main)

import AppModel as AM
import AppRunner as App exposing (Msg(..), fromInner)
import Browser
import Html as H
import Json.Encode as E
import MapRenderer exposing (viewMap)
import Model exposing (..)
import ModelAPI exposing (activeMap)
import Platform.Sub as Sub



-- Incoming page JSON from the FedWiki frame (stringified page object)


port pageJson : (String -> msg) -> Sub msg



-- White-box the current FedWiki page container by rendering ONLY the current map fullscreen.
-- That means we show its contained story items (MapTopic) as circles (Monad LabelOnly),
-- not the outer container topic.


view : App.UndoModel -> H.Html App.Msg
view undo =
    let
        model : AM.Model
        model =
            undo.present

        currentMapId : Int
        currentMapId =
            case model.mapPath of
                m :: _ ->
                    m

                [] ->
                    activeMap model
    in
    -- Empty mapPath => fullscreen; you see inner story items as LabelOnly circles
    H.map App.fromInner (viewMap currentMapId [] model)


main : Program E.Value App.UndoModel App.Msg
main =
    Browser.element
        { init = App.init
        , update = App.update
        , subscriptions =
            \undo ->
                Sub.batch
                    [ App.subscriptions undo
                    , pageJson App.FedWikiPage
                    ]
        , view = view
        }
````

## File: src/MapRenderer.elm
````elm
module MapRenderer exposing (viewMap)

import AppModel exposing (..)
import Compat.ModelAPI exposing (currentMapIdOf, getMapItemById)
import Config exposing (..)
import Dict
import Html exposing (Attribute, Html, div, input, textarea)
import Html.Attributes as Attr
import Html.Events as HE
import IconMenuAPI exposing (viewTopicIcon)
import Json.Decode as D
import Model exposing (..)
import ModelAPI
    exposing
        ( activeMap
        , defaultProps
        , fromPath
        , getMap
        , getMapId
        , getTopicLabel
        , getTopicPos
        , getTopicSize
        , isFullscreen
        , isItemInMap
        , isMapTopic
        , isSelected
        , isVisible
        )
import Mouse exposing (DragMode(..), DragState(..))
import Search exposing (ResultMenu(..))
import String exposing (fromFloat, fromInt, toLower, trim)
import Svg exposing (Svg, circle, g, path, rect, svg)
import Svg.Attributes as SA
import Svg.Events as SE
import SvgExtras exposing (cursorPointer, peAll, peNone, peStroke)
import Utils as U



-- Class tag used in Mouse messages for topics


topicCls : Class
topicCls =
    "dmx-topic"



-- if this errors because Class = List String, use: [ "topic", "monad" ]
-- CONFIG


lineFunc : Maybe AssocInfo -> Point -> Point -> Svg Msg
lineFunc =
    taxiLine



-- directLine
-- MODEL


type alias MapInfo =
    ( ( List (Html Msg), List (Svg Msg), List (Svg Msg) )
    , Rectangle
    , ( { w : String, h : String }
      , List (Attribute Msg)
      )
    )


type alias TopicRendering =
    ( List (Attribute Msg), List (Html Msg) )



-- VIEW
-- For a fullscreen map mapPath is empty


viewMap : MapId -> MapPath -> Model -> Html Msg
viewMap mapId mapPath model =
    let
        ( ( topicsHtml, assocsSvg, topicsSvg ), mapRect, ( svgSize, mapStyle ) ) =
            mapInfo mapId mapPath model
    in
    div
        mapStyle
        [ div
            (topicLayerStyle mapRect)
            (topicsHtml
                ++ limboTopic mapId model
            )
        , svg
            ([ SA.width svgSize.w, SA.height svgSize.h ] ++ svgStyle)
            [ g (gAttr mapId mapRect model)
                -- A) background rect: does NOT capture events (peNone)
                ([ rect
                    [ SA.x (String.fromFloat mapRect.x1)
                    , SA.y (String.fromFloat mapRect.y1)
                    , SA.width (String.fromFloat (mapRect.x2 - mapRect.x1))
                    , SA.height (String.fromFloat (mapRect.y2 - mapRect.y1))
                    , SA.fill "transparent"
                    , peNone
                    ]
                    []
                 ]
                    -- B) children group: DOES capture events (peAll)
                    ++ [ g [ peAll ] (assocsSvg ++ topicsSvg ++ viewLimboAssoc mapId model) ]
                    -- C) border: only the stroke is interactive (peStroke). Optional.
                    ++ [ rect
                            [ SA.x (String.fromFloat mapRect.x1)
                            , SA.y (String.fromFloat mapRect.y1)
                            , SA.width (String.fromFloat (mapRect.x2 - mapRect.x1))
                            , SA.height (String.fromFloat (mapRect.y2 - mapRect.y1))
                            , SA.fill "none"
                            , SA.stroke "#ddd"
                            , SA.strokeWidth "1"
                            , peStroke
                            ]
                            []
                       ]
                )
            ]
        ]


gAttr : MapId -> Rectangle -> Model -> List (Attribute Msg)
gAttr _ mapRect _ =
    [ SA.transform <|
        "translate("
            ++ fromFloat -mapRect.x1
            ++ " "
            ++ fromFloat -mapRect.y1
            ++ ")"
    ]


mapInfo : MapId -> MapPath -> Model -> MapInfo
mapInfo mapId mapPath model =
    let
        parentMapId =
            getMapId mapPath
    in
    case getMap mapId model.maps of
        Just map ->
            ( mapItems map mapPath model
            , map.rect
            , if isFullscreen mapId model then
                ( { w = "100%", h = "100%" }, [] )

              else
                ( { w = (map.rect.x2 - map.rect.x1) |> round |> fromInt
                  , h = (map.rect.y2 - map.rect.y1) |> round |> fromInt
                  }
                , whiteBoxStyle mapId map.rect parentMapId model
                )
            )

        Nothing ->
            ( ( [], [], [] ), Rectangle 0 0 0 0, ( { w = "0", h = "0" }, [] ) )


mapItems : Map -> MapPath -> Model -> ( List (Html Msg), List (Svg Msg), List (Svg Msg) )
mapItems map mapPath model =
    let
        newPath =
            map.id :: mapPath
    in
    map.items
        |> Dict.values
        |> List.filter isVisible
        |> List.foldr
            (\{ id, props } ( htmlTopics, assocs, topicsSvg ) ->
                case model.items |> Dict.get id of
                    Just { info } ->
                        case ( info, props ) of
                            ( Topic topic, MapTopic tProps ) ->
                                case effectiveDisplayMode topic.id tProps.displayMode model of
                                    Monad LabelOnly ->
                                        ( htmlTopics
                                        , assocs
                                        , viewTopicSvg topic tProps newPath model :: topicsSvg
                                        )

                                    Monad Detail ->
                                        ( viewTopic topic tProps newPath model :: htmlTopics
                                        , assocs
                                        , topicsSvg
                                        )

                                    _ ->
                                        ( viewTopic topic tProps newPath model :: htmlTopics
                                        , assocs
                                        , topicsSvg
                                        )

                            _ ->
                                U.logError "mapItems" ("problem with item " ++ fromInt id) ( htmlTopics, assocs, topicsSvg )

                    _ ->
                        U.logError "mapItems" ("problem with item " ++ fromInt id) ( htmlTopics, assocs, topicsSvg )
            )
            ( [], [], [] )


limboTopic : MapId -> Model -> List (Html Msg)
limboTopic mapId model =
    let
        activeMapId =
            activeMap model
    in
    if mapId == activeMapId then
        case model.search.menu of
            Open (Just topicId) ->
                if isItemInMap topicId activeMapId model then
                    case getMapItemById topicId activeMapId model.maps of
                        Just mapItem ->
                            if mapItem.hidden then
                                case model.items |> Dict.get topicId of
                                    Just { info } ->
                                        case ( info, mapItem.props ) of
                                            ( Topic topic, MapTopic props ) ->
                                                case effectiveDisplayMode topic.id props.displayMode model of
                                                    Monad LabelOnly ->
                                                        []

                                                    -- circle handled in SVG layer
                                                    Monad Detail ->
                                                        [ viewTopic topic props [] model ]

                                                    -- keep rich HTML detail
                                                    _ ->
                                                        [ viewTopic topic props [] model ]

                                            _ ->
                                                []

                                    _ ->
                                        []

                            else
                                -- already visible → nothing in limbo
                                []

                        Nothing ->
                            []

                else
                    -- not yet in map: render a preview for containers only
                    let
                        props =
                            defaultProps topicId topicSize model
                    in
                    case model.items |> Dict.get topicId of
                        Just { info } ->
                            case info of
                                Topic topic ->
                                    case effectiveDisplayMode topic.id props.displayMode model of
                                        Monad LabelOnly ->
                                            []

                                        -- circle handled in SVG layer
                                        Monad Detail ->
                                            [ viewTopic topic props [] model ]

                                        -- keep rich HTML detail
                                        _ ->
                                            [ viewTopic topic props [] model ]

                                _ ->
                                    []

                        _ ->
                            []

            _ ->
                []

    else
        []


viewTopicSvg : TopicInfo -> TopicProps -> MapPath -> Model -> Svg Msg
viewTopicSvg topic props mapPath model =
    let
        mapId =
            getMapId mapPath

        mark =
            monadMark topic.text

        rVal : Float
        rVal =
            (topicSize.h / 2) - topicBorderWidth

        rStr =
            fromFloat rVal

        cxStr =
            fromFloat props.pos.x

        cyStr =
            fromFloat props.pos.y

        dash =
            if isTargeted topic.id mapId model then
                "4 2"

            else
                "0"

        selected =
            isSelected topic.id mapId model

        shadowNodes : List (Svg Msg)
        shadowNodes =
            if selected then
                [ circle
                    [ SA.cx cxStr
                    , SA.cy cyStr
                    , SA.r rStr
                    , SA.fill "black"
                    , SA.fillOpacity "0.20"
                    , SA.transform "translate(5,5)"
                    ]
                    []
                ]

            else
                []

        mainNodes : List (Svg Msg)
        mainNodes =
            [ -- transparent hitbox: the event target
              rect
                ([ SA.x (fromFloat (props.pos.x - rVal))
                 , SA.y (fromFloat (props.pos.y - rVal))
                 , SA.width (fromFloat (rVal * 2))
                 , SA.height (fromFloat (rVal * 2))
                 , SA.fill "transparent"
                 , SA.pointerEvents "all"
                 , cursorPointer
                 ]
                    ++ svgTopicHandlers topic.id mapPath
                )
                []
            , circle
                [ SA.cx cxStr
                , SA.cy cyStr
                , SA.r rStr
                , SA.fill "white"
                , SA.stroke "black"
                , SA.strokeWidth (fromFloat topicBorderWidth ++ "px")
                , SA.strokeDasharray dash
                , SA.pointerEvents "none" -- <- let the hitbox handle it
                ]
                []
            , Svg.text_
                [ SA.x cxStr
                , SA.y cyStr
                , SA.textAnchor "middle"
                , SA.dominantBaseline "central"
                , SA.fontFamily mainFont
                , SA.fontSize (fromInt contentFontSize ++ "px")
                , SA.fontWeight topicLabelWeight
                , SA.fill "black"
                , SA.pointerEvents "none" -- <- text should not steal events
                ]
                [ Svg.text mark ]
            , Svg.title [] [ Svg.text (getTopicLabel topic) ]
            ]
    in
    g
        (svgTopicAttr topic.id mapPath
            ++ [ SA.transform "translate(0,0)" ]
        )
        mainNodes


isTargeted : Id -> MapId -> Model -> Bool
isTargeted topicId mapId model =
    case model.mouse.dragState of
        Drag DragTopic _ (mapId_ :: _) _ _ target ->
            isTarget topicId mapId target && mapId_ /= topicId

        Drag DrawAssoc _ (mapId_ :: _) _ _ target ->
            isTarget topicId mapId target && mapId_ == mapId

        _ ->
            False



-- VIEW TOPIC


viewTopic : TopicInfo -> TopicProps -> MapPath -> Model -> Html Msg
viewTopic topic props mapPath model =
    let
        -- decide final mode (single source of truth)
        mode1 : DisplayMode
        mode1 =
            effectiveDisplayMode topic.id props.displayMode model

        -- choose renderer + a name we surface for quick DOM inspection
        ( topicFunc, rendererName ) =
            case mode1 of
                Container WhiteBox ->
                    ( whiteBoxTopic, "whiteBoxTopic" )

                Container BlackBox ->
                    ( blackBoxTopic, "blackBoxTopic" )

                Container Unboxed ->
                    ( unboxedTopic, "unboxedTopic" )

                Monad Detail ->
                    ( detailTopic, "detailTopic" )

                _ ->
                    ( labelTopic, "labelTopic" )

        -- renderer-provided attrs/children
        ( attrsFromRenderer, childrenFromRenderer ) =
            topicFunc topic props mapPath model

        -- IMPORTANT attribute order:
        --   1) htmlTopicAttr (ids, event handlers, drag)
        --   2) base pos/size + mode visuals
        --   3) renderer extras (e.g. scream/outline)
        --   4) diagnostics
        finalAttrs =
            htmlTopicAttr topic.id mapPath
                ++ topicStyleWithMode topic.id mode1 model
                ++ attrsFromRenderer
                ++ [ Attr.attribute "data-mode0" (displayModeToString props.displayMode)
                   , Attr.attribute "data-mode1" (displayModeToString mode1)
                   , Attr.attribute "data-renderer" rendererName
                   , boolAttr "data-isFedWikiPage" (isFedWikiPage topic.id model)
                   ]
    in
    Html.div finalAttrs childrenFromRenderer


{-| Extract the page title from Model.fedWikiRaw.
-}
fedWikiTitle : Model -> Maybe String
fedWikiTitle model =
    if String.isEmpty model.fedWikiRaw then
        Nothing

    else
        case D.decodeString (D.field "title" D.string) model.fedWikiRaw of
            Ok t ->
                let
                    s =
                        trim t
                in
                if String.isEmpty s then
                    Nothing

                else
                    Just s

            Err _ ->
                Nothing


{-| Get TopicInfo (if this Id refers to a Topic).
-}
topicInfoOf : Id -> Model -> Maybe TopicInfo
topicInfoOf topicId model =
    case Dict.get topicId model.items of
        Just { info } ->
            case info of
                Topic ti ->
                    Just ti

                _ ->
                    Nothing

        _ ->
            Nothing



-- Safe child-map existence check (no error logs)


hasChildMap : Id -> Model -> Bool
hasChildMap topicId model =
    Dict.member topicId model.maps


{-| A topic is considered the FedWiki page container iff:

it has a containerId

-}
isFedWikiPage : Id -> Model -> Bool
isFedWikiPage topicId model =
    case model.fedWiki.containerId of
        Just containerId ->
            containerId == topicId

        Nothing ->
            False



-- Effective mode decision (force FedWiki to WhiteBox; limbo tweaks)


effectiveDisplayMode : Id -> DisplayMode -> Model -> DisplayMode
effectiveDisplayMode topicId incoming model =
    let
        isLimbo =
            model.search.menu == Open (Just topicId)

        isFedWiki =
            isFedWikiPage topicId model

        decided : DisplayMode
        decided =
            if isFedWiki then
                Container WhiteBox

            else if isLimbo then
                case incoming of
                    Monad _ ->
                        Monad Detail

                    Container _ ->
                        Container WhiteBox

            else
                incoming
    in
    decided



-- Tiny helpers for diagnostics + style composition


displayModeToString : DisplayMode -> String
displayModeToString mode =
    case mode of
        Monad Detail ->
            "Monad(Detail)"

        Monad LabelOnly ->
            "Monad(LabelOnly)"

        Container BlackBox ->
            "Container(BlackBox)"

        Container WhiteBox ->
            "Container(WhiteBox)"

        Container Unboxed ->
            "Container(Unboxed)"



-- Helper: turn a Bool into a data-* attribute value


boolAttr : String -> Bool -> Html.Attribute msg
boolAttr name value =
    Attr.attribute name
        (if value then
            "true"

         else
            "false"
        )



-- base (pos/size/etc.) + visuals that depend on mode


baseTopicStyles : Id -> Model -> List (Html.Attribute Msg)
baseTopicStyles tid model =
    topicStyle tid model


displayModeStyles : DisplayMode -> List (Html.Attribute Msg)
displayModeStyles mode =
    case mode of
        Container WhiteBox ->
            [ Attr.style "background" "white !important"
            , Attr.style "border" "1px solid #ddd !important"
            , Attr.style "border-radius" "6px"
            ]

        Container BlackBox ->
            [ Attr.style "background" "#222 !important"
            , Attr.style "color" "#fff !important"
            ]

        _ ->
            []


topicStyleWithMode : Id -> DisplayMode -> Model -> List (Html.Attribute Msg)
topicStyleWithMode tid mode model =
    baseTopicStyles tid model ++ displayModeStyles mode


whiteBoxStyle : Id -> Rectangle -> MapId -> Model -> List (Attribute Msg)
whiteBoxStyle topicId rect mapId model =
    let
        minW =
            182

        minH =
            54

        width =
            max minW (rect.x2 - rect.x1)

        height =
            max minH (rect.y2 - rect.y1)

        r =
            fromInt whiteBoxRadius ++ "px"
    in
    [ Attr.style "position" "absolute"
    , Attr.style "left" <| fromFloat -topicBorderWidth ++ "px"
    , Attr.style "top" <| fromFloat (topicSize.h - 2 * topicBorderWidth) ++ "px"
    , Attr.style "width" <| fromFloat width ++ "px"
    , Attr.style "height" <| fromFloat height ++ "px"
    , Attr.style "border-radius" <| "0 " ++ r ++ " " ++ r ++ " " ++ r
    , Attr.style "overflow" "hidden"
    , Attr.style "pointer-events" "none" -- pass clicks through to SVG
    ]
        ++ topicBorderStyle topicId mapId model
        ++ selectionStyle topicId mapId model


labelTopic : TopicInfo -> TopicProps -> MapPath -> Model -> TopicRendering
labelTopic topic props mapPath model =
    let
        mapId =
            getMapId mapPath
    in
    ( topicPosStyle props
        ++ topicFlexboxStyle topic props mapId model
        ++ selectionStyle topic.id mapId model
    , labelTopicHtml topic props mapId model
    )


labelTopicHtml : TopicInfo -> TopicProps -> MapId -> Model -> List (Html Msg)
labelTopicHtml topic props mapId model =
    let
        isEdit =
            model.editState == ItemEdit topic.id mapId

        textElem =
            if isEdit then
                input
                    ([ Attr.id <| "dmx-input-" ++ fromInt topic.id ++ "-" ++ fromInt mapId
                     , Attr.value topic.text
                     , Attr.style "pointer-events" "auto"
                     , HE.onInput (Edit << OnTextInput)
                     , HE.onBlur (Edit EditEnd)
                     , U.onEnterOrEsc (Edit EditEnd)
                     , U.stopPropagationOnMousedown NoOp
                     ]
                        ++ topicInputStyle
                    )
                    []

            else
                div
                    topicLabelStyle
                    [ Html.text <| getTopicLabel topic ]
    in
    [ div
        (topicIconBoxStyle props)
        [ viewTopicIcon topic.id model ]
    , textElem
    ]


detailTopic : TopicInfo -> TopicProps -> MapPath -> Model -> TopicRendering
detailTopic topic props mapPath model =
    let
        mapId =
            getMapId mapPath

        isEdit =
            model.editState == ItemEdit topic.id mapId

        textElem =
            if isEdit then
                textarea
                    ([ Attr.id <| "dmx-input-" ++ fromInt topic.id ++ "-" ++ fromInt mapId
                     , Attr.style "pointer-events" "auto"
                     , HE.onInput (Edit << OnTextareaInput)
                     , HE.onBlur (Edit EditEnd)
                     , U.onEsc (Edit EditEnd)
                     , U.stopPropagationOnMousedown NoOp
                     ]
                        ++ detailTextStyle topic.id mapId model
                        ++ detailTextEditStyle topic.id mapId model
                    )
                    [ Html.text topic.text ]

            else
                div
                    (detailTextStyle topic.id mapId model
                        ++ detailTextViewStyle
                    )
                    (U.multilineHtml topic.text)
    in
    ( detailTopicStyle props
    , [ div
            (topicIconBoxStyle props
                ++ detailTopicIconBoxStyle
                ++ selectionStyle topic.id mapId model
            )
            [ viewTopicIcon topic.id model ]
      , textElem
      ]
    )


detailTopicStyle : TopicProps -> List (Attribute Msg)
detailTopicStyle { pos } =
    [ Attr.style "display" "flex"
    , Attr.style "left" <| fromFloat (pos.x - topicW2) ++ "px"
    , Attr.style "top" <| fromFloat (pos.y - topicH2) ++ "px"
    ]


detailTextStyle : Id -> MapId -> Model -> List (Attribute Msg)
detailTextStyle topicId mapId model =
    let
        r =
            fromInt topicRadius ++ "px"
    in
    [ Attr.style "font-size" <| fromInt contentFontSize ++ "px"
    , Attr.style "width" <| fromFloat topicDetailMaxWidth ++ "px"
    , Attr.style "line-height" <| fromFloat topicLineHeight
    , Attr.style "padding" <| fromInt topicDetailPadding ++ "px"
    , Attr.style "border-radius" <| "0 " ++ r ++ " " ++ r ++ " " ++ r
    ]
        ++ topicBorderStyle topicId mapId model
        ++ selectionStyle topicId mapId model


detailTextViewStyle : List (Attribute Msg)
detailTextViewStyle =
    [ Attr.style "min-width" <| fromFloat (topicSize.w - topicSize.h) ++ "px"
    , Attr.style "max-width" "max-content"
    , Attr.style "white-space" "pre-wrap"
    , Attr.style "pointer-events" "none"
    ]


detailTextEditStyle : Id -> MapId -> Model -> List (Attribute Msg)
detailTextEditStyle topicId mapId model =
    let
        height =
            case getTopicSize topicId mapId model.maps of
                Just size ->
                    size.h

                Nothing ->
                    0
    in
    [ Attr.style "position" "relative"
    , Attr.style "top" <| fromFloat -topicBorderWidth ++ "px"
    , Attr.style "height" <| fromFloat height ++ "px"
    , Attr.style "font-family" mainFont -- <textarea> default is "monospace"
    , Attr.style "border-color" "black" -- <textarea> default is some lightgray
    , Attr.style "resize" "none"
    ]


blackBoxTopic : TopicInfo -> TopicProps -> MapPath -> Model -> TopicRendering
blackBoxTopic topic props mapPath model =
    let
        mapId =
            getMapId mapPath
    in
    ( topicPosStyle props
    , [ div
            (topicFlexboxStyle topic props mapId model
                ++ blackBoxStyle
            )
            (labelTopicHtml topic props mapId model
                ++ mapItemCount topic.id props model
            )
      , div
            (ghostTopicStyle topic mapId model)
            []
      ]
    )



-- RENDERERS (only WhiteBox shown; keep your other renderers unchanged)


whiteBoxTopic : TopicInfo -> TopicProps -> MapPath -> Model -> TopicRendering
whiteBoxTopic topic props mapPath model =
    let
        _ =
            U.info "whiteBoxTopic.called" { topicId = topic.id }

        ( styleLabel, childrenLabel ) =
            labelTopic topic props mapPath model

        whiteChrome =
            [ Attr.style "background" "white !important"
            , Attr.style "border" "1px solid #ddd !important"
            , Attr.style "border-radius" "6px"
            ]

        scream =
            [ Attr.style "outline" "4px solid magenta !important"
            , Attr.style "box-shadow" "0 0 0 3px rgba(255,0,255,0.35) inset !important"
            , Attr.attribute "data-renderer" "whiteBoxTopic"
            ]
    in
    ( styleLabel ++ whiteChrome ++ scream
    , childrenLabel
        ++ mapItemCount topic.id props model
        ++ [ viewMap topic.id mapPath model ]
    )


unboxedTopic : TopicInfo -> TopicProps -> MapPath -> Model -> TopicRendering
unboxedTopic topic props mapPath model =
    let
        ( style, children ) =
            labelTopic topic props mapPath model
    in
    ( style
    , children
        ++ mapItemCount topic.id props model
    )


mapItemCount : Id -> TopicProps -> Model -> List (Html Msg)
mapItemCount topicId props model =
    let
        itemCount =
            case effectiveDisplayMode topicId props.displayMode model of
                Monad _ ->
                    0

                Container _ ->
                    childCount topicId model
    in
    [ div
        itemCountStyle
        [ Html.text <| fromInt itemCount ]
    ]



-- Count only topics in the child map (map id == topic id)


childMapTopicCount : Id -> Model -> Int
childMapTopicCount topicId model =
    case Dict.get topicId model.maps of
        Just m ->
            m.items
                |> Dict.values
                |> List.filter isMapTopic
                |> List.filter isVisible
                |> List.length

        Nothing ->
            0



-- Unified child count (FedWiki-aware)


childCount : Id -> Model -> Int
childCount topicId model =
    if isFedWikiPage topicId model then
        List.length model.fedWiki.storyItemIds

    else
        childMapTopicCount topicId model



-- HTML topics


htmlTopicAttr : Id -> MapPath -> List (Attribute Msg)
htmlTopicAttr id mapPath =
    [ Attr.class "dmx-topic topic monad"
    , Attr.attribute "data-id" (fromInt id)
    , Attr.attribute "data-path" (fromPath mapPath)
    , Attr.style "cursor" "move"
    , HE.on "mousedown" (D.map (Mouse << Mouse.DownOnItem topicCls id mapPath) posDecoder)
    , HE.on "pointerdown" (D.map (Mouse << Mouse.DownOnItem topicCls id mapPath) posDecoder)
    ]



-- SVG monads


svgTopicAttr : Id -> MapPath -> List (Svg.Attribute Msg)
svgTopicAttr id mapPath =
    [ SA.class "dmx-topic topic monad"
    , SA.style "cursor: move"

    -- start drag from SVG (bypass global decoder)
    , SE.on "mousedown" (D.map (Mouse << Mouse.DownOnItem topicCls id mapPath) posDecoder)
    , SE.on "pointerdown" (D.map (Mouse << Mouse.DownOnItem topicCls id mapPath) posDecoder)

    -- keep model updated while dragging, independent from subs timing
    , SE.on "mousemove" (D.map (Mouse << Mouse.Move) posDecoder)
    , SE.on "pointermove" (D.map (Mouse << Mouse.Move) posDecoder)

    -- finish locally (global onMouseUp also handles it; having both is harmless)
    , SE.on "mouseup" (D.succeed (Mouse Mouse.Up))
    , SE.on "pointerup" (D.succeed (Mouse Mouse.Up))

    -- helpful for target highlighting during drag
    , SE.on "mouseenter" (D.succeed (Mouse (Mouse.Over topicCls id mapPath)))
    , SE.on "mouseleave" (D.succeed (Mouse (Mouse.Out topicCls id mapPath)))
    ]



-- TODO


assocGeometry : AssocInfo -> MapId -> Model -> Maybe ( Point, Point )
assocGeometry assoc mapId model =
    let
        pos1 =
            getTopicPos assoc.player1 mapId model.maps

        pos2 =
            getTopicPos assoc.player2 mapId model.maps
    in
    case Maybe.map2 (\p1 p2 -> ( p1, p2 )) pos1 pos2 of
        Just geometry ->
            Just geometry

        Nothing ->
            U.fail "assocGeometry" { assoc = assoc, mapId = mapId } Nothing


viewLimboAssoc : MapId -> Model -> List (Svg Msg)
viewLimboAssoc mapId model =
    case model.mouse.dragState of
        Drag DrawAssoc _ mapPath origPos pos _ ->
            if getMapId mapPath == mapId then
                [ lineFunc Nothing origPos (relPos pos mapPath model) ]

            else
                []

        _ ->
            []


{-| Transforms an absolute screen position to a map-relative position.
-}
relPos : Point -> MapPath -> Model -> Point
relPos pos mapPath model =
    let
        posAbs =
            absMapPos mapPath (Point 0 0) model
    in
    Point
        (pos.x - posAbs.x)
        (pos.y - posAbs.y)


{-| Recursively calculates the absolute position of a map.
"posAcc" is the position accumulated so far.
-}
absMapPos : MapPath -> Point -> Model -> Point
absMapPos mapPath posAcc model =
    case mapPath of
        [ mapId ] ->
            accumulateMapRect posAcc mapId model

        mapId :: parentMapId :: mapIds ->
            accumulateMapPos posAcc mapId parentMapId mapIds model

        [] ->
            U.logError "absMapPos" "mapPath is empty!" (Point 0 0)


accumulateMapPos : Point -> MapId -> MapId -> MapPath -> Model -> Point
accumulateMapPos posAcc mapId parentMapId mapIds model =
    let
        { x, y } =
            accumulateMapRect posAcc mapId model
    in
    case getTopicPos mapId parentMapId model.maps of
        Just mapPos ->
            absMapPos
                -- recursion
                (parentMapId :: mapIds)
                (Point
                    (x + mapPos.x - topicW2)
                    (y + mapPos.y + topicH2)
                )
                model

        Nothing ->
            Point 0 0



-- error is already logged


accumulateMapRect : Point -> MapId -> Model -> Point
accumulateMapRect posAcc mapId model =
    case getMap mapId model.maps of
        Just map ->
            Point
                (posAcc.x - map.rect.x1)
                (posAcc.y - map.rect.y1)

        Nothing ->
            Point 0 0



-- error is already logged
-- STYLE


topicStyle : Id -> Model -> List (Attribute Msg)
topicStyle id model =
    let
        isLimbo =
            model.search.menu == Open (Just id)

        isDragging =
            case model.mouse.dragState of
                Drag DragTopic id_ _ _ _ _ ->
                    id_ == id

                _ ->
                    False
    in
    [ Attr.style "position" "absolute"
    , Attr.style "opacity" <|
        if isLimbo then
            ".5"

        else
            "1"
    , Attr.style "z-index" <|
        if isDragging then
            "1"

        else
            "2"
    ]


selectionStyle : Id -> MapId -> Model -> List (Attribute Msg)
selectionStyle topicId mapId model =
    if isSelected topicId mapId model then
        [ Attr.style "box-shadow" "gray 5px 5px 5px" ]

    else
        []


topicFlexboxStyle : TopicInfo -> TopicProps -> MapId -> Model -> List (Attribute Msg)
topicFlexboxStyle topic props mapId model =
    let
        r12 =
            fromInt topicRadius ++ "px"

        r34 =
            case props.displayMode of
                Container WhiteBox ->
                    "0"

                _ ->
                    r12
    in
    [ Attr.style "display" "flex"
    , Attr.style "align-items" "center"
    , Attr.style "gap" "8px"
    , Attr.style "width" <| fromFloat topicSize.w ++ "px"
    , Attr.style "height" <| fromFloat topicSize.h ++ "px"
    , Attr.style "border-radius" <| r12 ++ " " ++ r12 ++ " " ++ r34 ++ " " ++ r34
    ]
        ++ topicBorderStyle topic.id mapId model


topicPosStyle : TopicProps -> List (Attribute Msg)
topicPosStyle { pos } =
    [ Attr.style "left" <| fromFloat (pos.x - topicW2) ++ "px"
    , Attr.style "top" <| fromFloat (pos.y - topicH2) ++ "px"
    ]


topicIconBoxStyle : TopicProps -> List (Attribute Msg)
topicIconBoxStyle props =
    let
        r1 =
            fromInt topicRadius ++ "px"

        r4 =
            case props.displayMode of
                Container WhiteBox ->
                    "0"

                _ ->
                    r1
    in
    [ Attr.style "flex" "none"
    , Attr.style "width" <| fromFloat topicSize.h ++ "px"
    , Attr.style "height" <| fromFloat topicSize.h ++ "px"
    , Attr.style "border-radius" <| r1 ++ " 0 0 " ++ r4
    , Attr.style "background-color" "black"
    , Attr.style "pointer-events" "none"
    ]


detailTopicIconBoxStyle : List (Attribute Msg)
detailTopicIconBoxStyle =
    -- icon box correction as detail topic has no border, in contrast to label topic
    [ Attr.style "padding-left" <| fromFloat topicBorderWidth ++ "px"
    , Attr.style "width" <| fromFloat (topicSize.h - topicBorderWidth) ++ "px"
    ]


topicLabelStyle : List (Attribute Msg)
topicLabelStyle =
    [ Attr.style "font-size" <| fromInt contentFontSize ++ "px"
    , Attr.style "font-weight" topicLabelWeight
    , Attr.style "overflow" "hidden"
    , Attr.style "text-overflow" "ellipsis"
    , Attr.style "white-space" "nowrap"
    , Attr.style "pointer-events" "none"
    ]


topicInputStyle : List (Attribute Msg)
topicInputStyle =
    [ Attr.style "font-family" mainFont -- Default for <input> is "-apple-system" (on Mac)
    , Attr.style "font-size" <| fromInt contentFontSize ++ "px"
    , Attr.style "font-weight" topicLabelWeight
    , Attr.style "width" "100%"
    , Attr.style "position" "relative"
    , Attr.style "left" "-4px"
    , Attr.style "pointer-events" "initial"
    ]


blackBoxStyle : List (Attribute Msg)
blackBoxStyle =
    [ Attr.style "pointer-events" "none" ]


ghostTopicStyle : TopicInfo -> MapId -> Model -> List (Attribute Msg)
ghostTopicStyle topic mapId model =
    [ Attr.style "position" "absolute"
    , Attr.style "left" <| fromInt blackBoxOffset ++ "px"
    , Attr.style "top" <| fromInt blackBoxOffset ++ "px"
    , Attr.style "width" <| fromFloat topicSize.w ++ "px"
    , Attr.style "height" <| fromFloat topicSize.h ++ "px"
    , Attr.style "border-radius" <| fromInt topicRadius ++ "px"
    , Attr.style "pointer-events" "none"
    , Attr.style "z-index" "-1" -- behind topic
    ]
        ++ topicBorderStyle topic.id mapId model
        ++ selectionStyle topic.id mapId model


itemCountStyle : List (Attribute Msg)
itemCountStyle =
    [ Attr.style "font-size" <| fromInt contentFontSize ++ "px"
    , Attr.style "position" "absolute"
    , Attr.style "left" "calc(100% + 12px)"
    ]


topicBorderStyle : Id -> MapId -> Model -> List (Attribute Msg)
topicBorderStyle id mapId model =
    let
        targeted =
            case model.mouse.dragState of
                -- can't move a topic to a map where it is already
                -- can't create assoc when both topics are in different map
                Drag DragTopic _ (mapId_ :: _) _ _ target ->
                    isTarget id mapId target && mapId_ /= id

                Drag DrawAssoc _ (mapId_ :: _) _ _ target ->
                    isTarget id mapId target && mapId_ == mapId

                _ ->
                    False
    in
    [ Attr.style "border-width" <| fromFloat topicBorderWidth ++ "px"
    , Attr.style "border-style" <|
        if targeted then
            "dashed"

        else
            "solid"
    , Attr.style "box-sizing" "border-box"
    , Attr.style "background-color" "white"
    ]


isTarget : Id -> MapId -> Maybe ( Id, MapPath ) -> Bool
isTarget topicId mapId target =
    case target of
        Just ( targetId, targetMapPath ) ->
            case targetMapPath of
                targetMapId :: _ ->
                    topicId == targetId && mapId == targetMapId

                [] ->
                    False

        Nothing ->
            False


topicLayerStyle : Rectangle -> List (Attribute Msg)
topicLayerStyle mapRect =
    [ Attr.style "position" "absolute"
    , Attr.style "left" <| fromFloat -mapRect.x1 ++ "px"
    , Attr.style "top" <| fromFloat -mapRect.y1 ++ "px"
    ]


svgStyle : List (Attribute Msg)
svgStyle =
    [ Attr.style "position" "absolute" -- occupy entire window height (instead 150px default height)
    , Attr.style "top" "0"
    , Attr.style "left" "0"
    ]



-- One possible line func


taxiLine : Maybe AssocInfo -> Point -> Point -> Svg Msg
taxiLine assoc pos1 pos2 =
    if abs (pos2.x - pos1.x) < 2 * assocRadius then
        -- straight vertical
        let
            xm =
                (pos1.x + pos2.x) / 2
        in
        Svg.path
            (SA.d ("M " ++ fromFloat xm ++ " " ++ fromFloat pos1.y ++ " V " ++ fromFloat pos2.y)
                :: lineStyle assoc
            )
            []

    else if abs (pos2.y - pos1.y) < 2 * assocRadius then
        -- straight horizontal
        let
            ym =
                (pos1.y + pos2.y) / 2
        in
        Svg.path
            (SA.d ("M " ++ fromFloat pos1.x ++ " " ++ fromFloat ym ++ " H " ++ fromFloat pos2.x)
                :: lineStyle assoc
            )
            []

    else
        -- 5 segment taxi line
        let
            sx =
                if pos2.x > pos1.x then
                    1

                else
                    -1

            -- sign x
            sy =
                if pos2.y > pos1.y then
                    -1

                else
                    1

            -- sign y
            ym =
                (pos1.y + pos2.y) / 2

            -- y mean
            x1 =
                fromFloat (pos1.x + sx * assocRadius)

            x2 =
                fromFloat (pos2.x - sx * assocRadius)

            y1 =
                fromFloat (ym + sy * assocRadius)

            y2 =
                fromFloat (ym - sy * assocRadius)

            sweep1 =
                if sy == 1 then
                    if sx == 1 then
                        1

                    else
                        0

                else if sx == 1 then
                    0

                else
                    1

            sweep2 =
                1 - sweep1

            sw1 =
                fromInt sweep1

            sw2 =
                fromInt sweep2

            r =
                fromFloat assocRadius
        in
        Svg.path
            (SA.d
                ("M "
                    ++ fromFloat pos1.x
                    ++ " "
                    ++ fromFloat pos1.y
                    ++ " V "
                    ++ y1
                    ++ " A "
                    ++ r
                    ++ " "
                    ++ r
                    ++ " 0 0 "
                    ++ sw1
                    ++ " "
                    ++ x1
                    ++ " "
                    ++ fromFloat ym
                    ++ " H "
                    ++ x2
                    ++ " A "
                    ++ r
                    ++ " "
                    ++ r
                    ++ " 0 0 "
                    ++ sw2
                    ++ " "
                    ++ fromFloat pos2.x
                    ++ " "
                    ++ y2
                    ++ " V "
                    ++ fromFloat pos2.y
                )
                :: lineStyle assoc
            )
            []


lineStyle : Maybe AssocInfo -> List (Attribute Msg)
lineStyle assoc =
    [ SA.stroke assocColor
    , SA.strokeWidth <| fromFloat assocWidth ++ "px"
    , SA.strokeDasharray <| lineDasharray assoc
    , SA.fill "none"
    ]


lineDasharray : Maybe AssocInfo -> String
lineDasharray maybeAssoc =
    case maybeAssoc of
        Just { itemType } ->
            case itemType of
                "dmx.association" ->
                    "5 0"

                -- solid
                "dmx.composition" ->
                    "5"

                -- dotted
                _ ->
                    "1"

        -- error
        Nothing ->
            "5 0"


{-| Pick a short “mark” for the monad interior.
Strategy:

  - prefer the first non-space “word” up to 3 chars
  - else first 2 visible chars
  - else "•"

-}
monadMark : String -> String
monadMark title =
    let
        trimmed =
            String.trim title

        word =
            trimmed
                |> String.words
                |> List.head
                |> Maybe.withDefault trimmed

        take n s =
            String.left n s
    in
    if String.isEmpty trimmed then
        "•"

    else if String.length word >= 1 then
        word |> take (Basics.min 3 (String.length word))

    else
        take (Basics.min 2 (String.length trimmed)) trimmed


posDecoder : D.Decoder Point
posDecoder =
    D.map2 Point
        (D.field "clientX" D.float)
        (D.field "clientY" D.float)


svgTopicHandlers : Id -> MapPath -> List (Svg.Attribute Msg)
svgTopicHandlers id mapPath =
    [ SE.on "pointerdown" (D.map (Mouse << Mouse.DownOnItem topicCls id mapPath) posDecoder)
    , SE.on "mousedown" (D.map (Mouse << Mouse.DownOnItem topicCls id mapPath) posDecoder)
    , SE.on "pointermove" (D.map (Mouse << Mouse.Move) posDecoder)
    , SE.on "mousemove" (D.map (Mouse << Mouse.Move) posDecoder)
    , SE.on "pointerup" (D.succeed (Mouse Mouse.Up))
    , SE.on "mouseup" (D.succeed (Mouse Mouse.Up))
    ]
````

## File: src/Main.elm
````elm
module Main exposing (..)

import AppModel exposing (..)
import Boxing exposing (boxContainer, unboxContainer)
import Browser
import Browser.Dom as Dom
import Compat.Model as CModel
import Config exposing (..)
import Dict exposing (Dict)
import Feature.Move
import Html exposing (Attribute, br, div, text)
import Html.Attributes exposing (id, style)
import IconMenuAPI exposing (updateIconMenu, viewIconMenu)
import Json.Decode as D
import Json.Encode as E
import MapAutoSize exposing (autoSize)
import MapRenderer exposing (viewMap)
import Model as M exposing (..)
import ModelAPI exposing (..)
import Mouse.Pretty as MousePretty
import MouseAPI exposing (mouseHoverHandler, mouseSubs, updateMouse)
import SearchAPI exposing (updateSearch, viewResultMenu)
import Storage exposing (exportJSON, importJSON, modelDecoder, store, storeWith)
import String exposing (fromFloat, fromInt)
import Task
import Toolbar exposing (viewToolbar)
import Types exposing (Id, MapId, MapItem, Maps, Point)
import UI.Icon
import UndoList
import Utils as U



-- MAIN


main : Program E.Value UndoModel Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = mouseSubs
        }



-- INIT


init : E.Value -> ( UndoModel, Cmd Msg )
init flags =
    ( initModel flags, Cmd.none ) |> reset


initModel : E.Value -> Model
initModel flags =
    case flags |> D.decodeValue (D.null True) of
        Ok True ->
            let
                _ =
                    U.info "init" "localStorage: empty"
            in
            AppModel.default |> ensureCurrentMap

        _ ->
            case flags |> D.decodeValue modelDecoder of
                Ok model ->
                    let
                        _ =
                            U.info "init"
                                ("localStorage: " ++ (model |> U.toString |> String.length |> fromInt) ++ " bytes")
                    in
                    ensureCurrentMap model

                Err e ->
                    let
                        _ =
                            U.logError "init" "localStorage" e
                    in
                    AppModel.default |> ensureCurrentMap


type alias Id =
    Int


blankRect : M.Rectangle
blankRect =
    { x1 = 0, y1 = 0, x2 = 0, y2 = 0 }



-- adjust field names if your alias differs


emptyItems : M.MapItems
emptyItems =
    Dict.empty


mkRoot : M.MapId -> M.Map
mkRoot rid =
    CModel.makeMapR { id = rid, rect = blankRect, items = emptyItems }


ensureRootOnInit : Model -> Model
ensureRootOnInit model0 =
    if Dict.isEmpty model0.maps then
        let
            rid =
                model0.nextId

            root =
                mkRoot rid
        in
        { model0
            | maps = Dict.insert rid root model0.maps
            , mapPath = [ rid ]
            , nextId = rid + 1
        }

    else
        -- also make sure mapPath head points to an existing map
        ensureCurrentMap model0



-- VIEW


view : UndoModel -> Browser.Document Msg
view ({ present } as undoModel) =
    Browser.Document
        "DM6 Elm"
        [ div
            (mouseHoverHandler
                ++ appStyle
            )
            ([ UI.Icon.sprite "" -- ← Add sprite here (empty prefix for now)
             , viewToolbar undoModel
             , viewMap (activeMap present) [] present
             ]
                ++ viewResultMenu present
                ++ viewIconMenu present
            )
        , div
            (id "measure" :: measureStyle)
            [ text present.measureText
            , br [] []
            ]
        ]


appStyle : List (Attribute Msg)
appStyle =
    [ style "font-family" mainFont
    , style "user-select" "none"
    , style "-webkit-user-select" "none" -- Safari still needs vendor prefix
    ]


measureStyle : List (Attribute Msg)
measureStyle =
    [ style "position" "fixed"
    , style "visibility" "hidden"
    , style "white-space" "pre-wrap"
    , style "font-family" mainFont
    , style "font-size" <| fromInt contentFontSize ++ "px"
    , style "line-height" <| fromFloat topicLineHeight
    , style "padding" <| fromInt topicDetailPadding ++ "px"
    , style "width" <| fromFloat topicDetailMaxWidth ++ "px"
    , style "min-width" <| fromFloat (topicSize.w - topicSize.h) ++ "px"
    , style "max-width" "max-content"
    , style "border-width" <| fromFloat topicBorderWidth ++ "px"
    , style "border-style" "solid"
    , style "box-sizing" "border-box"
    ]



-- UPDATE


update : Msg -> UndoModel -> ( UndoModel, Cmd Msg )
update msg ({ present } as undoModel) =
    let
        _ =
            case msg of
                Mouse _ ->
                    msg

                _ ->
                    U.info "update" msg
    in
    case msg of
        AddTopic ->
            createTopicIn topicDefaultText Nothing [ activeMap present ] present
                |> store
                |> push undoModel

        MoveTopicToMap topicId mapId origPos targetId targetMapPath pos ->
            moveTopicToMap topicId mapId origPos targetId targetMapPath pos present
                |> store
                |> push undoModel

        SwitchDisplay displayMode ->
            switchDisplay displayMode present
                |> store
                |> swap undoModel

        Search searchMsg ->
            updateSearch searchMsg undoModel

        Edit editMsg ->
            updateEdit editMsg undoModel

        IconMenu iconMenuMsg ->
            updateIconMenu iconMenuMsg undoModel

        Mouse mouseMsg ->
            updateMouse mouseMsg undoModel

        Nav navMsg ->
            updateNav navMsg present |> store |> reset

        Hide ->
            hide present |> store |> push undoModel

        Delete ->
            delete present |> store |> push undoModel

        Undo ->
            undo undoModel

        Redo ->
            redo undoModel

        Import ->
            ( present, importJSON () ) |> swap undoModel

        Export ->
            ( present, exportJSON () ) |> swap undoModel

        NoOp ->
            ( present, Cmd.none ) |> swap undoModel


moveTopicToMap : Id -> MapId -> Point -> Id -> MapPath -> Point -> Model -> Model
moveTopicToMap topicId mapId origPos targetId targetPath dropWorld model =
    let
        cfg =
            { whiteBoxPadding = 8
            , respectBlackBox = True
            , selectAfterMove = True
            , autosizeAfterMove = True
            }
    in
    Feature.Move.moveTopicToMap_ moveDeps
        cfg
        topicId
        mapId
        origPos
        targetId
        targetPath
        dropWorld
        model


moveDeps : Feature.Move.Deps
moveDeps =
    { createMapIfNeeded = createMapIfNeeded
    , getTopicProps = \tid mid m -> getTopicProps tid mid m.maps
    , addItemToMap = addItemToMap
    , hideItem = hideItem
    , setTopicPos = setTopicPos
    , select = select
    , autoSize = autoSize
    , getItem = \tid m -> getItemAny tid m -- <— cross-map
    , updateItem = updateItemById -- <— cross-map
    , worldToLocal = worldToLocalPos -- <— cross-map
    , ownerToMapId = \ownerId _ -> ownerId -- keep if “mapId == ownerId”
    }


getItemFromModel : Id -> Model -> Maybe MapItem
getItemFromModel tid m =
    getMapItemById tid (activeMap m) m.maps



-- update the correct map when promoting target


updateItemById : Id -> (MapItem -> MapItem) -> Model -> Model
updateItemById targetId f model =
    case findItemInAnyMap targetId model.maps of
        Nothing ->
            model

        Just ( mid, _ ) ->
            let
                amendItems : Dict Id MapItem -> Dict Id MapItem
                amendItems =
                    Dict.update targetId (Maybe.map f)

                amendMap : Map -> Map
                amendMap m =
                    { m | items = amendItems m.items }

                maps2 : Maps
                maps2 =
                    Dict.update mid (Maybe.map amendMap) model.maps
            in
            { model | maps = maps2 }


worldToLocalPos : Id -> Point -> Model -> Maybe Point
worldToLocalPos targetId world model =
    getItemAny targetId model
        |> Maybe.andThen
            (\it ->
                case it.props of
                    MapTopic tp ->
                        Just
                            { x = world.x - tp.pos.x
                            , y = world.y - tp.pos.y
                            }

                    _ ->
                        Nothing
            )



-- Model-aware getter used by Feature.Move deps


getItemAny : Id -> Model -> Maybe MapItem
getItemAny tid model =
    findItemInAnyMap tid model.maps
        |> Maybe.map Tuple.second



-- Find (mapId, item) for a topic anywhere in the model


findItemInAnyMap : Id -> Maps -> Maybe ( MapId, MapItem )
findItemInAnyMap tid maps =
    Dict.foldl
        (\mid m acc ->
            case acc of
                Just _ ->
                    acc

                Nothing ->
                    Dict.get tid m.items
                        |> Maybe.map (\it -> ( mid, it ))
        )
        Nothing
        maps


createMapIfNeeded : Id -> Model -> ( Model, Bool )
createMapIfNeeded topicId model =
    if hasMap topicId model.maps then
        ( model, False )

    else
        ( model
            |> createMap topicId
            |> setDisplayModeInAllMaps topicId (Container BlackBox)
          -- A nested topic which becomes a container might exist in other maps as well, still as
          -- a monad. We must set the topic's display mode to "container" in *all* maps. Otherwise
          -- in the other maps it might be revealed still as a monad.
        , True
        )


setDisplayModeInAllMaps : Id -> DisplayMode -> Model -> Model
setDisplayModeInAllMaps topicId displayMode model =
    model.maps
        |> Dict.foldr
            (\mapId _ modelAcc ->
                if isItemInMap topicId mapId model then
                    setDisplayMode topicId mapId displayMode modelAcc

                else
                    modelAcc
            )
            model


switchDisplay : DisplayMode -> Model -> Model
switchDisplay displayMode model =
    (case getSingleSelection model of
        Just ( containerId, mapPath ) ->
            let
                mapId =
                    getMapId mapPath
            in
            { model
                | maps =
                    case displayMode of
                        Monad _ ->
                            model.maps

                        Container BlackBox ->
                            boxContainer containerId mapId model

                        Container WhiteBox ->
                            boxContainer containerId mapId model

                        Container Unboxed ->
                            unboxContainer containerId mapId model
            }
                |> setDisplayMode containerId mapId displayMode

        Nothing ->
            model
    )
        |> autoSize



-- Text Edit


updateEdit : EditMsg -> UndoModel -> ( UndoModel, Cmd Msg )
updateEdit msg ({ present } as undoModel) =
    case msg of
        EditStart ->
            startEdit present |> push undoModel

        OnTextInput text ->
            onTextInput text present |> store |> swap undoModel

        OnTextareaInput text ->
            onTextareaInput text present |> storeWith |> swap undoModel

        SetTopicSize topicId mapId size ->
            ( present
                |> setTopicSize topicId mapId size
                |> autoSize
            , Cmd.none
            )
                |> swap undoModel

        EditEnd ->
            ( endEdit present, Cmd.none )
                |> swap undoModel


startEdit : Model -> ( Model, Cmd Msg )
startEdit model =
    let
        newModel =
            case getSingleSelection model of
                Just ( topicId, mapPath ) ->
                    { model | editState = ItemEdit topicId (getMapId mapPath) }
                        |> setDetailDisplayIfMonade topicId (getMapId mapPath)
                        |> autoSize

                Nothing ->
                    model
    in
    ( newModel, focus newModel )


setDetailDisplayIfMonade : Id -> MapId -> Model -> Model
setDetailDisplayIfMonade topicId mapId model =
    model
        |> updateTopicProps topicId
            mapId
            (\props ->
                case props.displayMode of
                    Monad _ ->
                        { props | displayMode = Monad Detail }

                    _ ->
                        props
            )


onTextInput : String -> Model -> Model
onTextInput text model =
    case model.editState of
        ItemEdit topicId _ ->
            updateTopicInfo topicId
                (\topic -> { topic | text = text })
                model

        NoEdit ->
            U.logError "onTextInput" "called when editState is NoEdit" model


onTextareaInput : String -> Model -> ( Model, Cmd Msg )
onTextareaInput text model =
    case model.editState of
        ItemEdit topicId mapId ->
            updateTopicInfo topicId
                (\topic -> { topic | text = text })
                model
                |> measureText text topicId mapId

        NoEdit ->
            U.logError "onTextareaInput" "called when editState is NoEdit" ( model, Cmd.none )


measureText : String -> Id -> MapId -> Model -> ( Model, Cmd Msg )
measureText text topicId mapId model =
    ( { model | measureText = text }
    , Dom.getElement "measure"
        |> Task.attempt
            (\result ->
                case result of
                    Ok elem ->
                        Edit
                            (SetTopicSize topicId
                                mapId
                                (Size elem.element.width elem.element.height)
                            )

                    Err err ->
                        U.logError "measureText" (U.toString err) NoOp
            )
    )


endEdit : Model -> Model
endEdit model =
    { model | editState = NoEdit }
        |> autoSize


focus : Model -> Cmd Msg
focus model =
    let
        nodeId =
            case model.editState of
                ItemEdit id mapId ->
                    "dmx-input-" ++ fromInt id ++ "-" ++ fromInt mapId

                NoEdit ->
                    U.logError "focus" "called when editState is NoEdit" ""
    in
    Dom.focus nodeId
        |> Task.attempt
            (\result ->
                case result of
                    Ok () ->
                        NoOp

                    Err e ->
                        U.logError "focus" (U.toString e) NoOp
            )



--


updateNav : NavMsg -> Model -> Model
updateNav navMsg model =
    case navMsg of
        Fullscreen ->
            fullscreen model

        Back ->
            back model


fullscreen : Model -> Model
fullscreen model =
    case getSingleSelection model of
        Just ( topicId, _ ) ->
            { model | mapPath = topicId :: model.mapPath }
                |> resetSelection
                |> createMapIfNeeded topicId
                |> Tuple.first
                |> adjustMapRect topicId -1

        Nothing ->
            model


back : Model -> Model
back model =
    let
        ( mapId, mapPath, _ ) =
            case model.mapPath of
                prevMapId :: nextMapId :: mapIds ->
                    ( prevMapId
                    , nextMapId :: mapIds
                    , [ ( prevMapId, nextMapId ) ]
                    )

                _ ->
                    U.logError "back" "model.mapPath has a problem" ( 0, [ 0 ], [] )
    in
    { model
        | mapPath = mapPath

        -- , selection = selection -- TODO
    }
        |> adjustMapRect mapId 1
        |> autoSize


adjustMapRect : MapId -> Float -> Model -> Model
adjustMapRect mapId factor model =
    model
        |> updateMapRect mapId
            (\rect ->
                Rectangle
                    (rect.x1 + factor * 400)
                    -- TODO
                    (rect.y1 + factor * 300)
                    -- TODO
                    rect.x2
                    rect.y2
            )


hide : Model -> Model
hide model =
    let
        newModel =
            model.selection
                |> List.foldr
                    (\( itemId, mapPath ) modelAcc -> hideItem itemId (getMapId mapPath) modelAcc)
                    model
    in
    newModel
        |> resetSelection
        |> autoSize


delete : Model -> Model
delete model =
    let
        newModel =
            model.selection
                |> List.map Tuple.first
                |> List.foldr
                    (\itemId modelAcc -> deleteItem itemId modelAcc)
                    model
    in
    newModel
        |> resetSelection
        |> autoSize



-- Undo / Redo


undo : UndoModel -> ( UndoModel, Cmd Msg )
undo undoModel =
    let
        newUndoModel =
            UndoList.undo undoModel

        newModel =
            resetTransientState newUndoModel.present
    in
    newModel
        |> store
        |> swap newUndoModel


redo : UndoModel -> ( UndoModel, Cmd Msg )
redo undoModel =
    let
        newUndoModel =
            UndoList.redo undoModel

        newModel =
            resetTransientState newUndoModel.present
    in
    newModel
        |> store
        |> swap newUndoModel


prettyMsg : Msg -> String
prettyMsg msg =
    case msg of
        Mouse m ->
            "Mouse." ++ MousePretty.pretty m

        Search m ->
            "Search." ++ U.toString m

        IconMenu m ->
            "IconMenu." ++ U.toString m

        Edit m ->
            "Edit." ++ U.toString m

        Nav m ->
            "Nav." ++ U.toString m

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
                ++ U.toString origPos
                ++ " → T"
                ++ fromInt targetId
                ++ " path="
                ++ pathStr
                ++ " drop="
                ++ U.toString dropWorld

        AddTopic ->
            "AddTopic"

        SwitchDisplay mode ->
            "SwitchDisplay." ++ U.toString mode

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
````

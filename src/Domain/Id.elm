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

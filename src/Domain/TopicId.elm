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

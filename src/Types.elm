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

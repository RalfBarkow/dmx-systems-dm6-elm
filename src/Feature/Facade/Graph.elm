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

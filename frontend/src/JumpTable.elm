module JumpTable exposing (..)

import Dict exposing (Dict)
import Location
import Models exposing (CodeViewer, JumpTable, JumpTo(..))


initJumpTable : List ( ( Int, Int ), JumpTo ) -> JumpTable
initJumpTable initList =
    Dict.fromList initList


get : Location.Pos -> JumpTable -> Location.Pos
get pos table =
    let
        ( cx, cy ) =
            ( pos.x, pos.y )
    in
    case Dict.get ( cx, cy ) table of
        Just (GoTo ( absx, absy )) ->
            { x = absx, y = absy }

        Nothing ->
            pos


insert : Location.Pos -> Location.Pos -> JumpTable -> JumpTable
insert pos jumpToPos table =
    let
        posTuple =
            ( pos.x, pos.y )

        jumpToPosTuple =
            ( jumpToPos.x, jumpToPos.y )
    in
    Dict.insert posTuple (GoTo jumpToPosTuple) table

module JumpTable exposing (..)

import Array
import Dict exposing (Dict)
import Location
import Models exposing (JumpTable, JumpTo(..), Model)


initJumpTable : List ( ( Int, Int ), JumpTo ) -> JumpTable
initJumpTable initList =
    Dict.fromList initList



-- Moves the cursor to the absolute position
-- Indicated as absPos. If outside, does not
-- move anything.


moveToAbsPos : Location.Pos -> Model -> Model
moveToAbsPos absPos model =
    let
        maxOffset =
            Array.length model.sourceCode - model.viewportSize.height

        newOffset =
            min absPos.x maxOffset

        newCursor =
            { x = absPos.x - newOffset, y = 0 }
    in
    { model | cursor = newCursor, rowOffset = newOffset }


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

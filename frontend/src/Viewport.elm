module Viewport exposing (..)

import Location
import Models exposing (Movement(..), Viewport)


empty =
    { size = { width = 1, height = 1 }
    , cursor = { x = 0, y = 0 }
    , rowOffset = 0
    , totalHeight = 0
    }


type alias CreationError =
    String


createAtOrigin : Location.Size -> Int -> Result CreationError Viewport
createAtOrigin size totalHeight =
    case ( size.width, size.height ) of
        ( 0, 0 ) ->
            Err "width and height must be at least 1"

        ( _, _ ) ->
            Ok (new size { x = 0, y = 0 } 0 totalHeight)


new : Location.Size -> Location.Pos -> Int -> Int -> Viewport
new size cursor rowOffset totalHeight =
    { size = size
    , cursor = cursor
    , rowOffset = rowOffset
    , totalHeight = totalHeight
    }


getAbsoluteNewCursor : Movement -> Viewport -> Location.Pos
getAbsoluteNewCursor mov model =
    let
        pos =
            model.cursor
    in
    case mov of
        RightOneChar ->
            { pos | y = pos.y + 1 }

        LeftOneChar ->
            { pos | y = pos.y - 1 }

        UpOneChar ->
            { pos | x = model.rowOffset + pos.x - 1 }

        DownOneChar ->
            { pos | x = model.rowOffset + pos.x + 1 }

        PageUp ->
            { pos | x = model.rowOffset + pos.x - 10 }

        PageDown ->
            { pos | x = model.rowOffset + pos.x + 10 }

        EndFile ->
            { pos | x = model.totalHeight - 1 }

        BegFile ->
            { pos | x = 0 }


move : Movement -> Viewport -> Viewport
move mov viewer =
    let
        newCursorAbsPos =
            getAbsoluteNewCursor mov viewer
    in
    moveCursor newCursorAbsPos viewer


moveCursor : Location.Pos -> Viewport -> Viewport
moveCursor cursorAbsPos viewport =
    let
        lastRow =
            viewport.totalHeight - 1

        cursorInFile =
            clampCursor
                ( lastRow, viewport.size.width - 1 )
                cursorAbsPos

        curAbsBegin =
            viewport.rowOffset

        curAbsEnd =
            curAbsBegin + viewport.size.height

        offsetDiff =
            if
                cursorInFile.x
                    < curAbsBegin
                    || cursorInFile.x
                    >= curAbsEnd
            then
                (Debug.log "" <| cursorInFile).x - (viewport.rowOffset + viewport.cursor.x)

            else
                0

        maxRowOffset =
            (viewport.totalHeight - viewport.size.height)
                |> max 0

        newOffset =
            clamp 0 maxRowOffset (viewport.rowOffset + offsetDiff)

        cursorInView =
            { cursorInFile
                | x = modBy viewport.size.height (cursorInFile.x - newOffset)
            }
    in
    { viewport
        | cursor = cursorInView
        , rowOffset = newOffset
    }


clampCursor : ( Int, Int ) -> Location.Pos -> Location.Pos
clampCursor ( lastRow, lastCol ) newPos =
    { x = clamp 0 lastRow newPos.x
    , y = clamp 0 lastCol newPos.y
    }

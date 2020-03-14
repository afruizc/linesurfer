-- This is a thing that you can use to have a cursor
-- Navigating some text.

module Viewport exposing (..)

import Array exposing (Array)
import Html exposing (Html, div, pre, text)
import Html.Attributes exposing (style)
import JumpTable exposing (JumpTable, getJump)
import Models exposing (Movement(..), Msg, Pos, Size)
import Styles exposing (gridCss)


-- Manages information about what to display and
-- where to show the cursor
type alias CodeViewer =
    { content: List String
    , size: Size
    , cursorPos: Pos
    }


createViewer : List String -> CodeViewer
createViewer s =
    let
        maxWidth = List.map String.length s |> List.foldr max -1
    in
        { content = s
        , size = { width=maxWidth, height=List.length s }
        , cursorPos= ( 0 , 0 )
        }


moveCursor : Movement -> CodeViewer -> CodeViewer
moveCursor mov model =
    let
        getNewPos (x, y) =
            case mov of
                RightOneChar -> (x, (y+1))
                LeftOneChar -> (x, y-1)
                UpOneChar -> ( (x-1), y )
                DownOneChar -> ( (x+1), y )
        newPos = getNewPos model.cursorPos
        canMove (x, y) =
            x >= 0 && x < model.size.height
                && y >= 0 && y < model.size.width
    in
        case canMove newPos of
            True -> { model | cursorPos=newPos }
            False -> model


jumpCursor : JumpTable -> CodeViewer -> CodeViewer
jumpCursor table viewer =
    { viewer | cursorPos = ( getJump viewer.cursorPos table ) }


render : CodeViewer -> Html Msg
render viewer =
    div []
        [ textPanel viewer
        , gridPanel viewer
        ]


textPanel : CodeViewer -> Html Msg
textPanel viewer =
    div ( style "font-size" "1.2rem" ::
            [ style "position" "absolute"
            ]
        )
        [ pre [ style "font-family" "courier" ]
              [ text ( String.join "\n" viewer.content ) ] ]


from2Dto1D : Int -> Pos -> Int
from2Dto1D width (x, y) =
    width * x + y


gridDivs : CodeViewer -> List ( Html Msg )
gridDivs viewer =
    let
        size = viewer.size.width * viewer.size.height
    in
    Array.repeat size cell
        |> Array.set (from2Dto1D viewer.size.width viewer.cursorPos) filledCell
        |> Array.toList


cell
    = div []
          []


filledCell
    = div [ style "background-color" "rgba(1, 1, 1, 0.5)"]
          []


gridPanel : CodeViewer -> Html Msg
gridPanel viewer =
    div ( gridCss viewer.size 11.5 20 )
        ( gridDivs viewer )

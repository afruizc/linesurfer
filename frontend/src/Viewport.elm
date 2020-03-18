-- This is a thing that you can use to have a cursor
-- Navigating some text.

module Viewport exposing (..)

import Array exposing (Array)
import Html exposing (Html, div, pre, text)
import Html.Attributes exposing (style)
import JumpTable exposing (JumpTable, addJump, createDefaultJumpTable, getJump)
import Models exposing (Pos, Size)
import Styles exposing (gridCss)


type Movement = RightOneChar
              | LeftOneChar
              | UpOneChar
              | DownOneChar


type Msg = MoveCursor Movement
         | JumpCursor
         | NoOp


-- Manages information about what to display and
-- where to show the cursor
type alias CodeViewer =
    { content: List String
    , size: Size
    , cursorPos: Pos
    , jumpTable: JumpTable
    }


createViewer : List String -> CodeViewer
createViewer s =
    let
        maxWidth = List.map String.length s |> List.foldr max -1
        height =  List.length s
        initialJumpTable = createDefaultJumpTable {width=maxWidth, height=height}
    in
        { content = s
        , size = { width=maxWidth, height=List.length s }
        , cursorPos= ( 0 , 0 )
        , jumpTable = initialJumpTable |> addJump (0, 0) (0, 1)
        }


updateViewer : Msg -> CodeViewer -> CodeViewer
updateViewer msg viewer =
    case msg of
        (MoveCursor dir) -> ( moveCursor dir viewer )
        JumpCursor ->( jumpCursor viewer.jumpTable viewer )
        NoOp -> viewer


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


render : CodeViewer -> Html msg
render viewer =
    div []
        [ textPanel viewer
        , gridPanel viewer
        ]


textPanel : CodeViewer -> Html msg
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


gridDivs : CodeViewer -> List ( Html msg )
gridDivs viewer =
    let
        cellCount = viewer.size.width * viewer.size.height
    in
    Array.repeat cellCount emptyCell
        |> Array.set (from2Dto1D viewer.size.width viewer.cursorPos) focusedCell
        |> Array.toList


emptyCell
    = div []
          []


focusedCell
    = div [ style "background-color" "rgba(1, 1, 1, 0.5)"]
          []


gridPanel : CodeViewer -> Html msg
gridPanel viewer =
    div ( gridCss viewer.size 11.5 20 )
        ( gridDivs viewer )



keyToAction : String -> Msg
keyToAction string =
    case String.uncons string of
        Just ( 'j', "" ) ->
            MoveCursor DownOneChar
        Just ( 'k', "" ) ->
            MoveCursor UpOneChar
        Just ( 'h', "" ) ->
            MoveCursor LeftOneChar
        Just ( 'l', "" ) ->
            MoveCursor RightOneChar
        Just ( 'B', "" ) ->
            JumpCursor
        _ ->
            NoOp


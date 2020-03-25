-- This is a thing that you can use to have a cursor
-- Navigating some text.

module CodeViewer exposing (..)

import Array
import Html exposing (Html, div, pre, text)
import Html.Attributes exposing (style)
import Models exposing (Pos, Range, Size, SourceCode)
import Styles exposing (gridCss)


type Movement = RightOneChar
              | LeftOneChar
              | UpOneChar
              | DownOneChar


type Msg = MoveCursor Movement
         --| JumpCursor
         | NoOp


type alias CodeViewer =
    { viewportText: SourceCode
    , cursor: Pos
    , displayRange: Range
    , content: SourceCode
    , viewportSize: Size
    }


create : Int -> SourceCode -> CodeViewer
create height s =
    let
        maxWidth = List.map String.length s |> List.foldr max -1
        viewerContent = List.take height s
    in
        { viewportText = viewerContent
        , viewportSize = { width=maxWidth, height=height }
        , cursor = { x=0, y=0 }
        , content = s
        , displayRange = { begin = 0, end = height }
        }


update : Msg -> CodeViewer -> CodeViewer
update msg viewer =
    case msg of
        (MoveCursor dir) -> ( moveCursor dir viewer )
        --JumpCursor ->( jumpCursor viewer.jumpTable viewer )
        NoOp -> viewer


clampPos : Size -> Pos -> Pos
clampPos size pos =
    { x = clamp 0 ( size.height - 1 ) pos.x
    , y = clamp 0 ( size.width - 1 ) pos.y
    }


moveCursor : Movement -> CodeViewer -> CodeViewer
moveCursor mov viewer =
    let
        (dx, dy) =
            case mov of
                RightOneChar -> (0, 1)
                LeftOneChar -> (0, -1)
                UpOneChar -> (-1, 0)
                DownOneChar -> (1, 0)
        newCursor = Debug.log "newCur" ({ x = viewer.cursor.x + dx
                    , y = viewer.cursor.y + dy
                    })
        shouldUpdateRange = Debug.log "shoudUp" ( newCursor.x < 0
                                || newCursor.x >= viewer.viewportSize.height)
        newRange = if shouldUpdateRange then
                        getNewRange dx viewer.displayRange
                   else
                        viewer.displayRange
        clampedNewCursor = clampPos viewer.viewportSize newCursor
    in
        calculateNewViewer clampedNewCursor newRange viewer


getNewRange delta oldRange =
    { begin=oldRange.begin + delta
    , end=oldRange.end + delta
    }


calculateNewViewer : Pos -> Range -> CodeViewer -> CodeViewer
calculateNewViewer newCursor newRange viewer =
    let
        newViewportText = List.drop newRange.begin viewer.content
                        |> List.take viewer.viewportSize.height
    in
        { viewer
        | cursor = newCursor
        , displayRange = newRange
        , viewportText = newViewportText
        }


--jumpCursor : JumpTable -> Viewport -> Viewport
--jumpCursor table viewer =
--    { viewer | cursorPos = ( getJump viewer.cursorPos table ) }


render : CodeViewer -> Html msg
render viewer =
    div []
        [ textPanel viewer.viewportText
        , gridPanel viewer
        ]


textPanel : SourceCode -> Html msg
textPanel srcCode =
    div ( style "font-size" "1.2rem" ::
            [ style "position" "absolute"
            ]
        )
        [ pre [ style "font-family" "courier" ]
              [ text ( String.join "\n" srcCode ) ] ]


gridPanel : CodeViewer -> Html msg
gridPanel viewer =
    div ( gridCss viewer.viewportSize 11.5 20 )
        ( gridDivs viewer )


from2Dto1D : Int -> Pos -> Int
from2Dto1D width { x, y } =
    width * x + y


gridDivs : CodeViewer -> List ( Html msg )
gridDivs viewer =
    let
        cellCount = viewer.viewportSize.width * viewer.viewportSize.height
    in
    Array.repeat cellCount emptyCell
        |> Array.set ( from2Dto1D viewer.viewportSize.width
                       ( clampCursor viewer.viewportSize.height viewer.cursor )
                     ) focusedCell
        |> Array.toList


emptyCell
    = div []
          []


focusedCell
    = div [ style "background-color" "rgba(1, 1, 1, 0.5)"]
          []


clampCursor : Int -> Pos -> Pos
clampCursor h pos =
    { pos | x = modBy h pos.x }


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
        --Just ( 'B', "" ) ->
        --    JumpCursor
        _ ->
            NoOp


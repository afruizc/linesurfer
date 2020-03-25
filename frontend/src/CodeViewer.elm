-- This is a thing that you can use to have a cursor
-- Navigating some text.

module CodeViewer exposing (..)

import Models exposing (Pos, Range, Size, SourceCode)


type Movement = RightOneChar
              | LeftOneChar
              | UpOneChar
              | DownOneChar


type Msg = MoveCursor Movement
         | JumpCursor
         | NoOp


type alias CodeViewer =
    { viewportText: SourceCode
    , cursor: Pos
    , displayRange: Range
    , content: SourceCode
    , viewportSize: Size
    }


createCodeViewer : Int -> SourceCode -> CodeViewer
createCodeViewer height s =
    let
        maxWidth = List.map String.length s |> List.foldr max -1
        viewerContent = List.take height s
    in
        { viewportText = viewerContent
        , viewportSize = { width=maxWidth, height=height }
        , cursor = { x=0, y=0 }
        , content = s
        , displayRange = { begin = 0, end = 1 }
        }


--updateViewer : Msg -> Viewport -> Viewport
--updateViewer msg viewer =
--    case msg of
--        (MoveCursor dir) -> ( moveCursor dir viewer )
--        JumpCursor ->( jumpCursor viewer.jumpTable viewer )
--        NoOp -> viewer
--

--moveOrReplaceViewer : Movement -> CodeViewer -> CodeViewer
--moveOrReplaceViewer mov viewer =
--    let
--        isLastRow = viewer.viewport.cursorPos == viewer.viewport.size
--        isFirstRow = x == 0
--        getNewPos (x, y) =
--            case mov of
--                RightOneChar -> (x, (y+1))
--                LeftOneChar -> (x, y-1)
--                UpOneChar -> ( (x-1), y )
--                DownOneChar -> ( (x+1), y )
--    in


moveCursor : Movement -> CodeViewer -> CodeViewer
moveCursor mov viewer =
    let
        getNewPos curPos =
            case mov of
                RightOneChar -> { curPos | y = curPos.y + 1}
                LeftOneChar -> { curPos | y = curPos.y - 1}
                UpOneChar -> { curPos | x = curPos.x - 1}
                DownOneChar -> { curPos | x = curPos.x + 1}
        newPos = getNewPos viewer.cursor
        canMove { x, y } =
            x >= 0 && x < viewer.viewportSize.height
                && y >= 0 && y < viewer.viewportSize.width
    in
        case canMove newPos of
            True -> updateViewer viewer newPos
            False -> viewer


inRange : Range -> Pos -> Bool
inRange range pos =
    pos.x >= range.begin && pos.x < range.end


updateViewer : CodeViewer -> Pos -> CodeViewer
updateViewer viewer newCursor =
    let
        newPosInViewport = inRange viewer.displayRange newCursor
        newRange = { begin = newCursor.x, end = newCursor.x + viewer.viewportSize.height}
        newViewport = List.drop ( max 0 ( newCursor.x - 1 ) ) viewer.content
                        |> List.take viewer.viewportSize.height
    in
    case newPosInViewport of
        True -> viewer
        False -> { viewer | }


--jumpCursor : JumpTable -> Viewport -> Viewport
--jumpCursor table viewer =
--    { viewer | cursorPos = ( getJump viewer.cursorPos table ) }
--
--
--render : Viewport -> Html msg
--render viewer =
--    div []
--        [ textPanel viewer
--        , gridPanel viewer
--        ]
--
--
--textPanel : Viewport -> Html msg
--textPanel viewer =
--    div ( style "font-size" "1.2rem" ::
--            [ style "position" "absolute"
--            ]
--        )
--        [ pre [ style "font-family" "courier" ]
--              [ text ( String.join "\n" viewer.content ) ] ]


--from2Dto1D : Int -> Pos -> Int
--from2Dto1D width (x, y) =
--    width * x + y


--gridDivs : Viewport -> List ( Html msg )
--gridDivs viewer =
--    let
--        cellCount = viewer.size.width * viewer.size.height
--    in
--    Array.repeat cellCount emptyCell
--        |> Array.set (from2Dto1D viewer.size.width viewer.cursorPos) focusedCell
--        |> Array.toList
--

--emptyCell
--    = div []
--          []
--
--
--focusedCell
--    = div [ style "background-color" "rgba(1, 1, 1, 0.5)"]
--          []
--
--
--gridPanel : Viewport -> Html msg
--gridPanel viewer =
--    div ( gridCss viewer.size 11.5 20 )
--        ( gridDivs viewer )
--
--
--
--keyToAction : String -> Msg
--keyToAction string =
--    case String.uncons string of
--        Just ( 'j', "" ) ->
--            MoveCursor DownOneChar
--        Just ( 'k', "" ) ->
--            MoveCursor UpOneChar
--        Just ( 'h', "" ) ->
--            MoveCursor LeftOneChar
--        Just ( 'l', "" ) ->
--            MoveCursor RightOneChar
--        Just ( 'B', "" ) ->
--            JumpCursor
--        _ ->
--            NoOp
--

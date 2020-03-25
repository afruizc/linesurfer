module TestCodeViewer exposing (..)

import Expect
import Models exposing (Pos, Range, Size, SourceCode)
import Test exposing (Test, describe, test)
import CodeViewer exposing (CodeViewer, Movement(..), create, moveCursor)


newViewer : SourceCode -> Size -> SourceCode -> Range -> Pos -> CodeViewer
newViewer viewportText viewportSize viewerContent displayRange cursor =
    { viewportText = viewportText
    , viewportSize = viewportSize
    , content = viewerContent
    , displayRange = displayRange
    , cursor = cursor
    }


testCreateEmptyViewer : Test
testCreateEmptyViewer =
    let
        inputViewportHeight = 1
        inputText = [""]

        outputViewer =
            newViewer [""]
                      { width = 0, height = inputViewportHeight }
                      [""]
                      { begin = 0, end = 1 }
                      { x = 0, y = 0 }
    in
    describe "empty viewer is created"
        [ test "size and viewer have right thangs" <|
            \_ ->
                create inputViewportHeight inputText
                    |> Expect.equal outputViewer
        ]

testCreateViewerOneLine : Test
testCreateViewerOneLine =
    let
        inputViewportHeight = 1
        inputText = ["a"]

        outputViewer =
            newViewer ["a"]
                      { width = 1, height = inputViewportHeight }
                      ["a"]
                      { begin = 0, end = 1 }
                      { x = 0, y = 0 }
    in
    describe "one line viewer is created"
        [ test "all the attributes are set" <|
            \_ ->
                create inputViewportHeight inputText
                    |> Expect.equal outputViewer
        ]


testCreateViewerTwoLines : Test
testCreateViewerTwoLines =
    let
        inputViewportHeight = 1
        inputText = ["a", "b"]

        outputViewer =
            newViewer ["a"]
                      { width = 1, height = inputViewportHeight }
                      ["a", "b"]
                      { begin = 0, end = 1 }
                      { x = 0, y = 0 }
    in
    describe "two line viewer is created"
        [ test "all the attributes are set" <|
            \_ ->
                create inputViewportHeight inputText
                    |> Expect.equal outputViewer
        ]


testCreateViewerThreeLines : Test
testCreateViewerThreeLines =
    let
        inputViewportHeight = 2
        inputText = ["a", "b", "c"]

        outputViewer =
            newViewer ["a", "b"]
                      { width = 1, height = inputViewportHeight }
                      ["a", "b", "c"]
                      { begin = 0, end = inputViewportHeight }
                      { x = 0, y = 0 }
    in
    describe "three line viewer is created"
        [ test "all the attributes are set" <|
            \_ ->
                create inputViewportHeight inputText
                    |> Expect.equal outputViewer
        ]


testMoveCursorEmptyViewer : Test
testMoveCursorEmptyViewer =
    let
        inputViewer =
            newViewer [""]
                      { width = 0, height = 1 }
                      [""]
                      { begin = 0, end = 1 }
                      { x = 0, y = 0 }

        outputViewer =
            newViewer [""]
                      { width = 0, height = 1 }
                      [""]
                      { begin = 0, end = 1 }
                      { x = 0, y = 0 }
    in
    describe "move left on empty viewer"
        [ test "all the attributes are set" <|
            \_ ->
                moveCursor LeftOneChar inputViewer
                    |> Expect.equal outputViewer
        ]


testMoveCursorOneLineViewer : Test
testMoveCursorOneLineViewer =
    let
        inputViewer =
            newViewer ["a"]
                      { width = 0, height = 1 }
                      ["a"]
                      { begin = 0, end = 1 }
                      { x = 0, y = 0 }

        outputViewer =
            newViewer ["a"]
                      { width = 0, height = 1 }
                      ["a"]
                      { begin = 0, end = 1 }
                      { x = 0, y = 0 }
    in
    describe "move left on one line viewer"
        [ test "all the attributes are set" <|
            \_ ->
                moveCursor LeftOneChar inputViewer
                    |> Expect.equal outputViewer
        ]


testMoveCursorOneLineTwoLetterViewer : Test
testMoveCursorOneLineTwoLetterViewer =
    let
        inputViewer =
            newViewer ["ab"]
                      { width = 2, height = 1 }
                      ["ab"]
                      { begin = 0, end = 1 }
                      { x = 0, y = 0 }

        outputViewer =
            newViewer ["ab"]
                      { width = 2, height = 1 }
                      ["ab"]
                      { begin = 0, end = 1 }
                      { x = 0, y = 1 }
    in
    describe "move right on one line two chars viewer"
        [ test "all the attributes are set" <|
            \_ ->
                moveCursor RightOneChar inputViewer
                    |> Expect.equal outputViewer
        ]


testMoveCursorTwoLinesTwoLetters : Test
testMoveCursorTwoLinesTwoLetters =
    let
        inputViewer =
            newViewer ["ab"]
                      { width = 2, height = 1 }
                      ["ab", "cd"]
                      { begin = 0, end = 1 }
                      { x = 0, y = 0 }

        outputViewer =
            newViewer ["cd"]
                      { width = 2, height = 1 }
                      ["ab", "cd"]
                      { begin = 1, end = 2 }
                      { x = 0, y = 0 }
    in
    describe "move down on one line show next line"
        [ test "all the attributes are set" <|
            \_ ->
                moveCursor DownOneChar inputViewer
                    |> Expect.equal outputViewer
        ]

--
--testMoveCursorUpTwoLinesTwoLetters : Test
--testMoveCursorUpTwoLinesTwoLetters =
--    let
--        inputViewer =
--            newViewer ["cd"]
--                      { width = 2, height = 1 }
--                      ["ab", "cd"]
--                      { begin = 1, end = 2 }
--                      { x = 1, y = 0 }
--
--        outputViewer =
--            newViewer ["ab"]
--                      { width = 2, height = 1 }
--                      ["ab", "cd"]
--                      { begin = 0, end = 1 }
--                      { x = 0, y = 0 }
--    in
--    describe "move up on one line show next line"
--        [ test "all the attributes are set" <|
--            \_ ->
--                moveCursor UpOneChar inputViewer
--                    |> Expect.equal outputViewer
--        ]
--
--
--testMoveCursorUpFourLinesShowTwo : Test
--testMoveCursorUpFourLinesShowTwo =
--    let
--        inputViewer =
--            newViewer [ "a", "b" ]
--                      { width = 1, height = 2 }
--                      [ "a", "b", "c" ]
--                      { begin = 0, end = 2 }
--                      { x = 1, y = 0 }
--
--        outputViewer =
--            newViewer [ "b", "c" ]
--                      { width = 1, height = 2 }
--                      [ "a", "b", "c" ]
--                      { begin = 1, end = 3 }
--                      { x = 2, y = 0 }
--    in
--    describe "move down on four line show three lines"
--        [ test "all the attributes are set" <|
--            \_ ->
--                moveCursor DownOneChar inputViewer
--                    |> Expect.equal outputViewer
--        ]

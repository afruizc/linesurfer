module TestCodeViewer exposing (..)

import Array exposing (Array)
import CodeViewer exposing (CodeViewer, Movement(..), create, moveCursor)
import Expect
import JumpTable exposing (createDefaultJumpTable)
import Location exposing (Pos, Range, Size, SourceCode)
import Test exposing (Test, describe, test)


newViewer : SourceCode -> Size -> SourceCode -> Range -> Pos -> CodeViewer
newViewer viewportText viewportSize viewerContent displayRange cursor =
    { viewportText = viewportText
    , viewportSize = viewportSize
    , content = viewerContent
    , displayRange = displayRange
    , cursor = cursor
    , jumpTable =
        createDefaultJumpTable
            { width = viewportSize.width
            , height = List.length viewerContent
            }
    }


testCreateEmptyViewer : Test
testCreateEmptyViewer =
    let
        inputViewportHeight =
            1

        inputText =
            [ "" ]

        outputViewer =
            newViewer [ "" ]
                { width = 0, height = inputViewportHeight }
                [ "" ]
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
        inputViewportHeight =
            1

        inputText =
            [ "a" ]

        outputViewer =
            newViewer [ "a" ]
                { width = 1, height = inputViewportHeight }
                [ "a" ]
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
        inputViewportHeight =
            1

        inputText =
            [ "a", "b" ]

        outputViewer =
            newViewer [ "a" ]
                { width = 1, height = inputViewportHeight }
                [ "a", "b" ]
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
        inputViewportHeight =
            2

        inputText =
            [ "a", "b", "c" ]

        outputViewer =
            newViewer [ "a", "b" ]
                { width = 1, height = inputViewportHeight }
                [ "a", "b", "c" ]
                { begin = 0, end = inputViewportHeight }
                { x = 0, y = 0 }
    in
    describe "three line viewer is created"
        [ test "all the attributes are set" <|
            \_ ->
                create inputViewportHeight inputText
                    |> Expect.equal outputViewer
        ]


type alias MoveTestCase =
    { msg : String
    , input : CodeViewer
    , move : Movement
    , expected : CodeViewer
    }


testCases : List MoveTestCase
testCases =
    [ { msg = "move left on empty viewer"
      , input =
            newViewer [ "" ]
                { width = 0, height = 1 }
                [ "" ]
                { begin = 0, end = 1 }
                { x = 0, y = 0 }
      , move = LeftOneChar
      , expected =
            newViewer [ "" ]
                { width = 0, height = 1 }
                [ "" ]
                { begin = 0, end = 1 }
                { x = 0, y = 0 }
      }
    , { msg = "move left on one line viewer"
      , input =
            newViewer [ "a" ]
                { width = 0, height = 1 }
                [ "a" ]
                { begin = 0, end = 1 }
                { x = 0, y = 0 }
      , move = LeftOneChar
      , expected =
            newViewer [ "a" ]
                { width = 0, height = 1 }
                [ "a" ]
                { begin = 0, end = 1 }
                { x = 0, y = 0 }
      }
    , { msg = "move right on one line two chars viewer"
      , input =
            newViewer [ "ab" ]
                { width = 2, height = 1 }
                [ "ab" ]
                { begin = 0, end = 1 }
                { x = 0, y = 0 }
      , move = RightOneChar
      , expected =
            newViewer [ "ab" ]
                { width = 2, height = 1 }
                [ "ab" ]
                { begin = 0, end = 1 }
                { x = 0, y = 1 }
      }
    , { msg = "move down on one line show next line"
      , input =
            newViewer [ "ab" ]
                { width = 2, height = 1 }
                [ "ab", "cd" ]
                { begin = 0, end = 1 }
                { x = 0, y = 0 }
      , move = DownOneChar
      , expected =
            newViewer [ "cd" ]
                { width = 2, height = 1 }
                [ "ab", "cd" ]
                { begin = 1, end = 2 }
                { x = 0, y = 0 }
      }
    , { msg = "move up on one line show next line"
      , input =
            newViewer [ "cd" ]
                { width = 2, height = 1 }
                [ "ab", "cd" ]
                { begin = 1, end = 2 }
                { x = 0, y = 0 }
      , move = UpOneChar
      , expected =
            newViewer [ "ab" ]
                { width = 2, height = 1 }
                [ "ab", "cd" ]
                { begin = 0, end = 1 }
                { x = 0, y = 0 }
      }
    , { msg = "move down on three lines change two"
      , input =
            newViewer [ "a", "b" ]
                { width = 1, height = 2 }
                [ "a", "b", "c" ]
                { begin = 0, end = 2 }
                { x = 1, y = 0 }
      , move = DownOneChar
      , expected =
            newViewer [ "b", "c" ]
                { width = 1, height = 2 }
                [ "a", "b", "c" ]
                { begin = 1, end = 3 }
                { x = 1, y = 0 }
      }
    , { msg = "move down on three lines no change"
      , input =
            newViewer [ "b", "c" ]
                { width = 1, height = 2 }
                [ "a", "b", "c" ]
                { begin = 1, end = 3 }
                { x = 1, y = 0 }
      , move = DownOneChar
      , expected =
            newViewer [ "b", "c" ]
                { width = 1, height = 2 }
                [ "a", "b", "c" ]
                { begin = 1, end = 3 }
                { x = 1, y = 0 }
      }
    , { msg = "move up on three lines no change"
      , input =
            newViewer [ "a", "b" ]
                { width = 1, height = 2 }
                [ "a", "b", "c" ]
                { begin = 0, end = 2 }
                { x = 0, y = 0 }
      , move = UpOneChar
      , expected =
            newViewer [ "a", "b" ]
                { width = 1, height = 2 }
                [ "a", "b", "c" ]
                { begin = 0, end = 2 }
                { x = 0, y = 0 }
      }
    ]


runTests =
    Array.repeat 9 True


zip : Array a -> List b -> List ( a, b )
zip xs ys =
    List.map2 Tuple.pair (Array.toList xs) ys


testAllMoves : Test
testAllMoves =
    let
        shouldRunTest : ( Bool, MoveTestCase ) -> Bool
        shouldRunTest ( r, _ ) =
            r

        runTest testData =
            test testData.msg <|
                \_ ->
                    moveCursor testData.move testData.input
                        |> Expect.equal testData.expected
    in
    describe "move tests" <|
        (testCases
            |> zip runTests
            |> List.filter shouldRunTest
            |> List.map Tuple.second
            |> List.map runTest
        )

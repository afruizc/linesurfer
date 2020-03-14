module TestViewport exposing (..)

import Expect
import Models exposing (Movement(..))
import Test exposing (Test, describe, test)
import Viewport exposing (CodeViewer, createViewer, moveCursor)

zeroOnePos = ( 0, 1 )
emptyViewer = createViewer [""]
oneLetterViewer = createViewer ["a"]
fiveLetterViewer = createViewer ["aeiou"]

testCases testFn cases =
    let
        testCase c =
            test ( Debug.toString c ) <|
                \() ->
                    Expect.equal c.expected (testFn c.direction c.initial)
    in
        List.map testCase cases


all : Test
all =
    describe "The viewport module"
        [ describe "Create Viewport"
            [ test "Empty viewport"  <|
                \_ ->
                    [""]
                        |> createViewer
                        |> .size
                        |> Expect.equal { width=0, height=1 }
            , test "one line some chars" <|
                \_ ->
                    ["test"]
                        |> createViewer
                        |> .size
                        |> Expect.equal { width=4, height=1 }
            , test "multiple lines" <|
                \_ ->
                    ["test", "testoooo", "tes", "", "blah", "hola", "12345678901234"]
                        |> createViewer
                        |> .size
                        |> Expect.equal { width=14, height=7 }
            ]

        , describe "Move cursor" <|
            testCases moveCursor
                [ { direction=RightOneChar, initial=emptyViewer , expected=emptyViewer }
                , { direction=RightOneChar, initial=oneLetterViewer , expected= oneLetterViewer }
                , { direction=RightOneChar, initial=fiveLetterViewer , expected={ fiveLetterViewer | cursorPos = zeroOnePos } }
                ]
        ]

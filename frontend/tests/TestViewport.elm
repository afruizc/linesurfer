module TestViewport exposing (..)

import Array exposing (Array)
import Expect
import Location exposing (Pos, Range, Size)
import Models exposing (CodeViewer, ColorTable, Movement(..), SourceCode, Token, Viewport)
import Test exposing (Test, describe, test)
import Viewport


changeViewport : Int -> Pos -> Viewport -> Viewport
changeViewport offset cursor viewer =
    { viewer
        | cursor = cursor
        , rowOffset = offset
    }


type alias MoveTestCase =
    { msg : String
    , input : Viewport
    , move : Movement
    , expected : Viewport
    }


newAtOrigin : ( Int, Int ) -> Int -> Viewport
newAtOrigin ( w, h ) totalH =
    Viewport.createAtOrigin { width = w, height = h } totalH
        |> Result.withDefault Viewport.empty


testCases : List MoveTestCase
testCases =
    [ { msg = "move right on one line two chars viewer"
      , input = newAtOrigin ( 2, 1 ) 2
      , move = RightOneChar
      , expected =
            newAtOrigin ( 2, 1 ) 2
                |> changeViewport 0 { x = 0, y = 1 }
      }
    , { msg = "move down on one line show next line"
      , input = newAtOrigin ( 1, 1 ) 2
      , move = DownOneChar
      , expected =
            newAtOrigin ( 1, 1 ) 2
                |> changeViewport 1 { x = 0, y = 0 }
      }
    , { msg = "move up one line on two line"
      , input = newAtOrigin ( 1, 1 ) 2 |> changeViewport 1 { x = 0, y = 0 }
      , move = UpOneChar
      , expected =
            newAtOrigin ( 1, 1 ) 2
      }
    , { msg = "move down one line on three line"
      , input = newAtOrigin ( 1, 2 ) 2
      , move = DownOneChar
      , expected =
            newAtOrigin ( 1, 2 ) 2
                |> changeViewport 0 { x = 1, y = 0 }
      }
    , { msg = "move on three lines down dont change offset"
      , input = newAtOrigin ( 1, 2 ) 3
      , move = DownOneChar
      , expected =
            newAtOrigin ( 1, 2 ) 3
                |> changeViewport 0 { x = 1, y = 0 }
      }
    , { msg = "move on three lines down change offset"
      , input = newAtOrigin ( 1, 2 ) 3 |> changeViewport 0 { x = 1, y = 0 }
      , move = DownOneChar
      , expected =
            newAtOrigin ( 1, 2 ) 3
                |> changeViewport 1 { x = 1, y = 0 }
      }
    , { msg = "move down on three lines down "
      , input = newAtOrigin ( 1, 2 ) 3 |> changeViewport 1 { x = 1, y = 0 }
      , move = DownOneChar
      , expected =
            newAtOrigin ( 1, 2 ) 3
                |> changeViewport 1 { x = 1, y = 0 }
      }
    ]



--, { msg = "move down on one line show next line"
--  , input = heightTwo [ [ "a" ], [ "b" ] ]
--  , move = DownOneChar
--  , expected =
--        heightTwo [ [ "a" ], [ "b" ] ]
--            |> changeViewer 1 { x = 0, y = 0 }
--, { msg = "move up on one line show next line"
--  , input =
--        newViewer [ "cd" ]
--            { width = 2, height = 1 }
--            [ "ab", "cd" ]
--            { begin = 1, end = 2 }
--            { x = 0, y = 0 }
--  , move = UpOneChar
--  , expected =
--        newViewer [ "ab" ]
--            { width = 2, height = 1 }
--            [ "ab", "cd" ]
--            { begin = 0, end = 1 }
--            { x = 0, y = 0 }
--  }
--, { msg = "move down on three lines change two"
--  , input =
--        newViewer [ "a", "b" ]
--            { width = 1, height = 2 }
--            [ "a", "b", "c" ]
--            { begin = 0, end = 2 }
--            { x = 1, y = 0 }
--  , move = DownOneChar
--  , expected =
--        newViewer [ "b", "c" ]
--            { width = 1, height = 2 }
--            [ "a", "b", "c" ]
--            { begin = 1, end = 3 }
--            { x = 1, y = 0 }
--  }
--, { msg = "move down on three lines no change"
--  , input =
--        newViewer [ "b", "c" ]
--            { width = 1, height = 2 }
--            [ "a", "b", "c" ]
--            { begin = 1, end = 3 }
--            { x = 1, y = 0 }
--  , move = DownOneChar
--  , expected =
--        newViewer [ "b", "c" ]
--            { width = 1, height = 2 }
--            [ "a", "b", "c" ]
--            { begin = 1, end = 3 }
--            { x = 1, y = 0 }
--  }
--, { msg = "move up on three lines no change"
--  , input =
--        newViewer [ "a", "b" ]
--            { width = 1, height = 2 }
--            [ "a", "b", "c" ]
--            { begin = 0, end = 2 }
--            { x = 0, y = 0 }
--  , move = UpOneChar
--  , expected =
--        newViewer [ "a", "b" ]
--            { width = 1, height = 2 }
--            [ "a", "b", "c" ]
--            { begin = 0, end = 2 }
--            { x = 0, y = 0 }
--  }


runTests =
    Array.repeat 9 True
        |> Array.set 2 True


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
                    Viewport.move testData.move testData.input
                        |> Expect.equal testData.expected
    in
    describe "move tests" <|
        (testCases
            |> zip runTests
            |> List.filter shouldRunTest
            |> List.map Tuple.second
            |> List.map runTest
        )

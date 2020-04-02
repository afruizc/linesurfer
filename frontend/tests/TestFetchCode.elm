module TestFetchCode exposing (..)

import Array exposing (Array)
import Expect
import FetchCode
import Models exposing (Token)
import Test exposing (Test, describe, test)


type alias SplitStringTestCase =
    { msg : String
    , input : List Token
    , expected : Array (Array Token)
    }


runTests =
    Array.repeat 9 True
        |> Array.set 2 True


zip : Array a -> List b -> List ( a, b )
zip xs ys =
    List.map2 Tuple.pair (Array.toList xs) ys


t : String -> Token
t s =
    { token_type = "", value = s }


teol : Token
teol =
    { token_type = "Text", value = "\n" }


toArrays : List (List a) -> Array (Array a)
toArrays lists =
    lists
        |> List.map Array.fromList
        |> Array.fromList


testCases : List SplitStringTestCase
testCases =
    [ { msg = "empty string"
      , input = []
      , expected = Array.fromList []
      }
    , { msg = "one line append new line"
      , input = [ t "a" ]
      , expected = toArrays [ [ t "a", teol ] ]
      }
    , { msg = "one line unchanged"
      , input = [ t "a", teol, teol ]
      , expected =
            toArrays
                [ [ t "a", teol ]
                , [ teol ]
                ]
      }
    ]


testAllMoves : Test
testAllMoves =
    let
        shouldRunTest : ( Bool, SplitStringTestCase ) -> Bool
        shouldRunTest ( r, _ ) =
            r

        runTest testData =
            test testData.msg <|
                \_ ->
                    FetchCode.splitByNewline testData.input
                        |> Expect.equal testData.expected
    in
    describe "move tests" <|
        (testCases
            |> zip runTests
            |> List.filter shouldRunTest
            |> List.map Tuple.second
            |> List.map runTest
        )

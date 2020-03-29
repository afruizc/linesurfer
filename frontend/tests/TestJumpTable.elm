module TestJumpTable exposing (..)

import Expect
import JumpTable exposing (initJumpTable)
import Models exposing (JumpTo(..))
import Test exposing (Test, describe, test)


emptyJumpTable =
    initJumpTable []


someJumpsJumpTable =
    initJumpTable
        [ ( ( 0, 0 ), GoTo ( 1, 2 ) )
        , ( ( 2, 3 ), GoTo ( 5, 5 ) )
        ]


zeroZero =
    { x = 0, y = 0 }


tenTen =
    { x = 10, y = 10 }


jumpTableTest : Test
jumpTableTest =
    describe "Create jump table"
        [ test "create default" <|
            \_ ->
                emptyJumpTable
                    |> JumpTable.get zeroZero
                    |> Expect.equal zeroZero
        , test "Get jump to same pos" <|
            \_ ->
                emptyJumpTable
                    |> JumpTable.get tenTen
                    |> Expect.equal tenTen
        , test "Get add jumps other pos" <|
            \_ ->
                emptyJumpTable
                    |> JumpTable.insert zeroZero tenTen
                    |> JumpTable.get zeroZero
                    |> Expect.equal tenTen
        ]

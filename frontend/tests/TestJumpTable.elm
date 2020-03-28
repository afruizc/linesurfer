module TestJumpTable exposing (..)

import CodeViewer
import Dict
import Expect
import JumpTable exposing (JumpTo(..), addJump, createDefaultJumpTable, getJump)
import Test exposing (Test, describe, test)


emptyJumpTable =
    createDefaultJumpTable { width = 5, height = 5 }


jumpTableTest : Test
jumpTableTest =
    describe "Create jump table"
        [ test "create default" <|
            \_ ->
                { width = 3, height = 3 }
                    |> createDefaultJumpTable
                    |> Dict.values
                    |> Expect.equal (List.repeat 9 Stay)
        , test "Get jump to same pos" <|
            \_ ->
                emptyJumpTable
                    |> getJump ( 1, 1 )
                    |> Expect.equal { x = 1, y = 1 }
        , test "Get add jumps other pos" <|
            \_ ->
                emptyJumpTable
                    |> addJump ( 1, 1 ) { x = 3, y = 3 }
                    |> getJump ( 1, 1 )
                    |> Expect.equal { x = 3, y = 3 }
        ]


newViewer =
    CodeViewer.create 1 [ "a", "b" ]


expectedViewer =
    { newViewer | displayRange = { begin = 1, end = 2 } }



--testJumpTable : Test
--testJumpTable =
--    describe "Jump updates code viewer"
--        [ test "jump outside range" <|
--            \_ ->
--                newViewer
--                    |> CodeViewer.update CodeViewer.JumpCursor
--                    |> Expect.equal expectedViewer
--        ]

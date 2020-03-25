module TestJumpTable exposing (..)

import Dict
import Expect
import JumpTable exposing (JumpTo(..), addJump, createDefaultJumpTable, getJump)
import Test exposing (Test, describe, test)


emptyJumpTable = createDefaultJumpTable { width=5, height=5 }

--
--all : Test
--all =
--    describe "Jump table"
--        [ describe "Create jump table"
--            [ test "create default"  <|
--                \_ ->
--                    { width=3, height=3 }
--                        |> createDefaultJumpTable
--                        |> Dict.values
--                        |> Expect.equal ( List.repeat 9 Stay )
--
--            , test "Get jump to same pos" <|
--                \_ ->
--                    emptyJumpTable
--                        |> getJump ( 1, 1 )
--                        |> Expect.equal ( 1, 1 )
--
--            , test "Get add jumps other pos" <|
--                \_ ->
--                    emptyJumpTable
--                        |> addJump ( 1, 1 ) ( 3, 3 )
--                        |> getJump ( 1, 1 )
--                        |> Expect.equal ( 3, 3 )
--
--            ]
--        ]

module JumpTable exposing (..)

import Dict exposing (Dict)
import Models exposing (Pos, Size)


type JumpTo = Stay
            | GoTo Pos


type alias JumpTable = Dict Pos JumpTo


cartesian : List a -> List b -> List (a,b)
cartesian xs ys =
  List.concatMap
    ( \x -> List.map ( \y -> (x, y) ) ys )
    xs


createDefaultJumpTable : Size -> JumpTable
createDefaultJumpTable size =
    let
        xs = List.range 0 ( size.height - 1 )
        ys = List.range 0 ( size.width - 1 )
        allPairs = cartesian xs ys
        getEntry pos = ( pos, Stay )
    in
        Dict.fromList <|  List.map getEntry allPairs


getJump : Pos -> JumpTable -> Pos
getJump pos table =
    case Dict.get pos table of
        ( Just Stay ) -> pos
        ( Just ( GoTo newPos ) ) -> newPos
        _ -> ( -1, -1 )


addJump : Pos -> Pos -> JumpTable -> JumpTable
addJump pos jumpToPos table =
    Dict.insert pos ( GoTo jumpToPos ) table


module Models exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Location


type alias Token =
    { token_type : String
    , value : String
    }


type alias SourceTable =
    Array (Array Token)


type alias Color =
    { r : Int
    , g : Int
    , b : Int
    }


type alias ColorTable =
    Dict String Color


type alias Model =
    { sourceCode : SourceTable
    , absCursor : Location.Pos -- This is a computed property
    , cursor : Location.Pos
    , rowOffset : Int
    , viewportSize : Location.Size
    , colorTable : ColorTable
    , jumpTable : JumpTable
    }


type JumpTo
    = GoTo ( Int, Int )


type alias JumpTable =
    Dict ( Int, Int ) JumpTo

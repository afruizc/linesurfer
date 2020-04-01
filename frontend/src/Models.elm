module Models exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Location


type alias Token =
    { token_type : String
    , value : String
    }


type alias SourceCode =
    Array (Array Token)


type alias Color =
    { r : Int
    , g : Int
    , b : Int
    }


type alias ColorTable =
    Dict String Color


type alias CodeViewer =
    { sourceCode : SourceCode
    , viewport : Viewport
    , colorTable : ColorTable
    , jumpTable : JumpTable
    }


type alias Viewport =
    { size : Location.Size
    , cursor : Location.Pos
    , rowOffset : Int
    , totalHeight : Int
    }


type JumpTo
    = GoTo ( Int, Int )


type alias JumpTable =
    Dict ( Int, Int ) JumpTo


type Movement
    = RightOneChar
    | LeftOneChar
    | UpOneChar
    | DownOneChar
    | PageDown
    | PageUp
    | EndFile
    | BegFile



--| JumpTo

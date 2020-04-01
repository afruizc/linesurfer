module Models exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Http
import Location


type alias Token =
    { token_type : String
    , value : String
    }


type alias SourceCode =
    { path : String
    , content : Array (Array Token)
    }


type alias Color =
    { r : Int
    , g : Int
    , b : Int
    }


type alias ColorTable =
    Dict String Color


type alias ViewersTable =
    Dict String CodeViewer


type alias Model =
    { currentViewer : CodeViewer
    , allViewers : ViewersTable
    , colorTable : ColorTable
    }


type alias CodeViewer =
    { sourceCode : SourceCode
    , viewport : Viewport
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


type alias Path =
    String


type Movement
    = RightOneChar
    | LeftOneChar
    | UpOneChar
    | DownOneChar
    | PageDown
    | PageUp
    | EndFile
    | BegFile


type Msg
    = GetTokens (Result Http.Error (List SourceCode))
    | MoveCursor Movement
    | ChangeTo Path
    | NoOp



--| JumpTo

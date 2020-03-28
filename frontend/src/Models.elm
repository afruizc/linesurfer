module Models exposing (..)


type alias Pos =
    { x : Int
    , y : Int
    }


type alias Size =
    { width : Int
    , height : Int
    }


type alias Range =
    { begin : Int
    , end : Int
    }


type alias KeywordType =
    Int


type SourceWord
    = SourceWord String KeywordType


type alias SourceLine =
    List SourceWord


type alias SourceCode =
    List String


type alias HighlightIdx =
    Int


type alias Token =
    { token_type : String
    , value : String
    , highlight : HighlightIdx
    }


type alias Url =
    String


type alias SourceProgram =
    List Token

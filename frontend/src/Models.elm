module Models exposing (..)


type alias Pos =
    { x: Int
    , y: Int
    }


type alias Size =
    { width: Int
    , height: Int
    }


type alias Range =
    { begin: Int
    , end: Int
    }


type alias SourceCode = List String

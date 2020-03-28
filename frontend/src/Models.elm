module Models exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)


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

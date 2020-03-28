module Main exposing (..)

import Browser
import SourceProgram


type alias Url =
    String



---- PROGRAM ----


main : Program () SourceProgram.Model SourceProgram.Msg
main =
    Browser.element
        { view = SourceProgram.view
        , init = \_ -> SourceProgram.init
        , update = SourceProgram.update
        , subscriptions = SourceProgram.subscriptions
        }

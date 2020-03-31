module Main exposing (..)

import Browser
import CodeViewer
import Models exposing (CodeViewer)


type alias Url =
    String



---- PROGRAM ----


main : Program () CodeViewer CodeViewer.Msg
main =
    Browser.element
        { view = CodeViewer.view
        , init = \_ -> CodeViewer.init
        , update = CodeViewer.update
        , subscriptions = CodeViewer.subscriptions
        }

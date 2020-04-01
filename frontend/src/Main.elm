module Main exposing (..)

import Browser
import CodeViewer
import Models exposing (CodeViewer, Model, Msg)


type alias Url =
    String



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = CodeViewer.view
        , init = \_ -> CodeViewer.init
        , update = CodeViewer.update
        , subscriptions = CodeViewer.subscriptions
        }

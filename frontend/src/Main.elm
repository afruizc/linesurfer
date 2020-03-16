module Main exposing (..)

import Browser
import Browser.Events
import Html exposing (Html)

import Http
import Json.Decode as Decode exposing (Decoder, field, list, string)
import Viewport exposing (CodeViewer, Movement(..), createViewer, keyToAction, render, updateViewer)


type alias SourceProgram = List String
type alias Url = String


---- MODEL ----
type alias Model =
    { viewer : CodeViewer
    }


---- MSG ----
type Msg
    = ViewerMsg Viewport.Msg
    | GotSourceCode (Result Http.Error SourceProgram)


initialViewer = createViewer []


initialModel =
    { viewer = initialViewer
    }


fetchFile : Url -> Cmd Msg
fetchFile url =
    Http.get
        { url = url
        , expect = Http.expectJson GotSourceCode fileDecoder
        }


fileDecoder : Decoder SourceProgram
fileDecoder =
    field  "data" (list string)


init : ( Model, Cmd Msg )
init =
    ( initialModel , fetchFile "http://localhost:8080" )


---- UPDATE ----
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ViewerMsg vmsg -> ({ model | viewer = ( updateViewer vmsg model.viewer )}, Cmd.none)
        GotSourceCode result -> (updateModelIfSuccess result model, Cmd.none)


updateModelIfSuccess : (Result Http.Error SourceProgram) -> Model -> Model
updateModelIfSuccess result model =
    case result of
        Ok data -> { model | viewer = createViewer data }
        Err err -> { model | viewer = createViewer ["error loading data: " ++ Debug.toString err] }


---- VIEW ----
view : Model -> Html Msg
view model =
    render model.viewer


---- PROGRAM ----
main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Browser.Events.onKeyDown keyDecoder


keyDecoder : Decode.Decoder Msg
keyDecoder =
    let
        wrapVMsg str =
            ViewerMsg (keyToAction str)
    in
    Decode.map wrapVMsg (Decode.field "key" Decode.string)


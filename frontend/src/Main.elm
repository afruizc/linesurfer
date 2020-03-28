module Main exposing (..)

import Browser
import Browser.Events
import CodeViewer exposing (CodeViewer)
import Html exposing (Html)
import Http
import Json.Decode as Decode
import Models exposing (SourceCode)
import SourceProgram


type alias Url =
    String



---- MODEL ----


type alias Model =
    { viewer : CodeViewer
    }



---- MSG ----


type Msg
    = ViewerMsg CodeViewer.Msg
    | GotSourceCode (Result Http.Error SourceCode)


defaultHeight =
    20


initialViewer =
    CodeViewer.create defaultHeight []


initialModel =
    { viewer = initialViewer
    }



--fetchFile : Url -> Cmd Msg
--fetchFile url =
--    Http.get
--        { url = url
--        , expect = Http.expectJson GotSourceCode SourceProgram.tokenDecoder
--        }
--
--
--fileDecoder : Decode.Decoder SourceCode
--fileDecoder =
--    Decode.field "data" (Decode.list Decode.string)
--


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )



---- UPDATE ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ViewerMsg vmsg ->
            ( { model
                | viewer = CodeViewer.update vmsg model.viewer
              }
            , Cmd.none
            )

        GotSourceCode result ->
            --( updateModelIfSuccess result model, Cmd.none )
            ( updateRender result model, Cmd.none )


updateRender : Result Http.Error SourceCode -> Model -> Model
updateRender result model =
    case result of
        Ok data ->
            { model | viewer = CodeViewer.create defaultHeight data }

        Err err ->
            { model
                | viewer =
                    CodeViewer.create defaultHeight
                        [ "error loading data: " ++ Debug.toString err ]
            }


updateModelIfSuccess : Result Http.Error SourceCode -> Model -> Model
updateModelIfSuccess result model =
    case result of
        Ok data ->
            { model | viewer = CodeViewer.create defaultHeight data }

        Err err ->
            { model
                | viewer =
                    CodeViewer.create defaultHeight
                        [ "error loading data: " ++ Debug.toString err ]
            }



---- VIEW ----


view : Model -> Html Msg
view model =
    CodeViewer.render model.viewer



---- PROGRAM ----


main : Program () SourceProgram.Model SourceProgram.Msg
main =
    Browser.element
        { view = SourceProgram.view
        , init = \_ -> SourceProgram.init
        , update = SourceProgram.update
        , subscriptions = subscriptions
        }


subscriptions : SourceProgram.Model -> Sub SourceProgram.Msg
subscriptions _ =
    Sub.none



--Browser.Events.onKeyDown keyDecoder


keyDecoder : Decode.Decoder Msg
keyDecoder =
    let
        wrapVMsg str =
            ViewerMsg (CodeViewer.keyToAction str)
    in
    Decode.map wrapVMsg (Decode.field "key" Decode.string)

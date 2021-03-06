module CodeViewer exposing (..)

import Browser.Events
import Dict
import FetchCode
import Html
import HtmlRendering
import Http
import Json.Decode as JsonDecode
import JumpTable
import Models exposing (CodeViewer, ColorTable, Model, Movement(..), Msg(..), SourceCode, Token)
import SourceCode exposing (emptySourceCode)
import Viewport


view : Model -> Html.Html Msg
view model =
    HtmlRendering.render model


emptyViewer : CodeViewer
emptyViewer =
    { sourceCode = emptySourceCode
    , viewport = Viewport.empty
    , jumpTable = JumpTable.initJumpTable []
    }


emptyModel : Model
emptyModel =
    { allViewers = Dict.fromList []
    , currentViewer = emptyViewer
    , colorTable = Dict.fromList []
    }


fetchSourceCode : String -> Cmd Msg
fetchSourceCode url =
    Http.get
        { url = url
        , expect = Http.expectJson GetTokens FetchCode.tokenListDecoder
        }


init : ( Model, Cmd Msg )
init =
    ( emptyModel, fetchSourceCode "http://localhost:8080" )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        newModel dir =
            { model | currentViewer = move dir model.currentViewer }
    in
    case msg of
        GetTokens result ->
            ( FetchCode.getSourceCode result, Cmd.none )

        MoveCursor dir ->
            ( newModel dir, Cmd.none )

        ChangeTo path ->
            ( changeToViewer path model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


changeToViewer : String -> Model -> Model
changeToViewer path model =
    let
        newViewer =
            Dict.get path model.allViewers
                |> Maybe.withDefault emptyViewer
    in
    { model | currentViewer = newViewer }


move : Movement -> CodeViewer -> CodeViewer
move dir viewer =
    let
        newViewport =
            Viewport.move dir viewer.viewport
    in
    { viewer | viewport = newViewport }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Browser.Events.onKeyDown keyDecoder


keyDecoder : JsonDecode.Decoder Msg
keyDecoder =
    let
        wrapVMsg str =
            keyToAction str
    in
    JsonDecode.map wrapVMsg (JsonDecode.field "key" JsonDecode.string)


keyToAction : String -> Msg
keyToAction string =
    case String.uncons string of
        Just ( 'j', "" ) ->
            MoveCursor DownOneChar

        Just ( 'k', "" ) ->
            MoveCursor UpOneChar

        Just ( 'h', "" ) ->
            MoveCursor LeftOneChar

        Just ( 'l', "" ) ->
            MoveCursor RightOneChar

        Just ( 'g', "" ) ->
            MoveCursor BegFile

        Just ( 'G', "" ) ->
            MoveCursor EndFile

        Just ( 'd', "" ) ->
            MoveCursor PageDown

        Just ( 'u', "" ) ->
            MoveCursor PageUp

        --Just ( 'B', "" ) ->
        --    MoveCursor JumpTo
        _ ->
            NoOp

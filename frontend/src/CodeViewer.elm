module CodeViewer exposing (..)

import Array exposing (Array)
import Browser.Events
import CodeHighlighting
import Dict
import FetchCode
import Html
import Http
import Json.Decode as JsonDecode
import JumpTable
import Models exposing (CodeViewer, ColorTable, Model, Movement(..), SourceCode, Token)
import Viewport


type Msg
    = GetTokens (Result Http.Error (List SourceCode))
    | MoveCursor Movement
    | NoOp


view : Model -> Html.Html Msg
view model =
    CodeHighlighting.render model.currentViewer


emptySourceCode : SourceCode
emptySourceCode =
    { path = "", content = Array.fromList [] }


emptyViewer : CodeViewer
emptyViewer =
    { sourceCode = emptySourceCode
    , viewport = Viewport.empty
    , colorTable = Dict.fromList []
    , jumpTable = JumpTable.initJumpTable []
    }


emptyModel : Model
emptyModel =
    { allViewers = Dict.fromList []
    , currentViewer = emptyViewer
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

        NoOp ->
            ( model, Cmd.none )


move : Movement -> CodeViewer -> CodeViewer
move dir viewer =
    let
        newViewport =
            Viewport.move dir viewer.viewport
    in
    { viewer | viewport = newViewport }



--JumpTo ->
--    JumpTable.get model.jumpTable model.cursor
--
----
----EndFile ->
----    JumpTable.moveToAbsPos lastRowFile model
--BegFile ->
--    { x = 0, y = 0 }
--
--PageDown ->
--    { pos | x = pos.x + 10 }
--
--PageUp ->
--    { pos | x = pos.x - 10 }
--_ ->
--    pos


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

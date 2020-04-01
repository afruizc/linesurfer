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
import Models exposing (CodeViewer, ColorTable, Movement(..), SourceCode, Token)
import Viewport


type Msg
    = GetTokens (Result Http.Error (List Token))
    | MoveCursor Movement
    | NoOp


view : CodeViewer -> Html.Html Msg
view model =
    CodeHighlighting.render model


initialModel : CodeViewer
initialModel =
    { sourceCode = Array.fromList []
    , viewport = Viewport.empty
    , colorTable = Dict.fromList []
    , jumpTable = JumpTable.initJumpTable []
    }


fetchSourceCode : String -> Cmd Msg
fetchSourceCode url =
    Http.get
        { url = url
        , expect = Http.expectJson GetTokens FetchCode.tokenListDecoder
        }


init : ( CodeViewer, Cmd Msg )
init =
    ( initialModel, fetchSourceCode "http://localhost:8080" )


update : Msg -> CodeViewer -> ( CodeViewer, Cmd Msg )
update msg model =
    case msg of
        GetTokens result ->
            ( FetchCode.getSourceCode result, Cmd.none )

        MoveCursor dir ->
            ( move dir model, Cmd.none )

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


subscriptions : CodeViewer -> Sub Msg
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

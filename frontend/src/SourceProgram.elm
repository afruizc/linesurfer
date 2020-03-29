module SourceProgram exposing (..)

import Array exposing (Array)
import ArrayExtra
import Browser.Events
import CodeHighlighting
import Dict
import Html
import Http
import Json.Decode as JsonDecode
import JumpTable
import Location
import Models exposing (ColorTable, Model, SourceTable, Token)


type Movement
    = RightOneChar
    | LeftOneChar
    | UpOneChar
    | DownOneChar



--| EndFile
--| BegFile
--| PageDown
--| PageUp
--| JumpTo


type Msg
    = GetTokens (Result Http.Error (List Token))
    | MoveCursor Movement
    | NoOp


getAbsCursor : Model -> Location.Pos
getAbsCursor model =
    { x = model.cursor.x + model.rowOffset
    , y = model.cursor.y
    }


view : Model -> Html.Html Msg
view model =
    CodeHighlighting.render model


initialModel : Model
initialModel =
    { sourceCode = Array.fromList []
    , cursor = { x = 0, y = 0 }
    , rowOffset = 0
    , viewportSize = { width = 0, height = 1 }
    , colorTable = Dict.fromList []
    , jumpTable = JumpTable.initJumpTable
    , absCursor = { x = 0, y = 0 }
    }


createModel : Int -> SourceTable -> Model
createModel height source =
    let
        maxWidth =
            100
    in
    { viewportSize = { width = maxWidth, height = height }
    , cursor = { x = 0, y = 0 }
    , sourceCode = source
    , rowOffset = 0
    , colorTable = CodeHighlighting.init source
    , jumpTable = JumpTable.initJumpTable
    , absCursor = { x = 0, y = 0 }
    }


fetchSourceCode : String -> Cmd Msg
fetchSourceCode url =
    Http.get
        { url = url
        , expect = Http.expectJson GetTokens tokenListDecoder
        }


init : ( Model, Cmd Msg )
init =
    ( initialModel, fetchSourceCode "http://localhost:8080" )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetTokens result ->
            ( getSourceCode result model, Cmd.none )

        MoveCursor dir ->
            ( moveCursor dir model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


getNewPos : Movement -> Model -> Location.Pos
getNewPos mov model =
    let
        pos =
            model.cursor
    in
    case mov of
        RightOneChar ->
            { pos | y = pos.y + 1 }

        LeftOneChar ->
            { pos | y = pos.y - 1 }

        UpOneChar ->
            { pos | x = pos.x - 1 }

        DownOneChar ->
            { pos | x = pos.x + 1 }

        JumpTo ->
            JumpTable.get model.jumpTable model.cursor

        --
        --EndFile ->
        --    JumpTable.moveToAbsPos lastRowFile model
        BegFile ->
            { x = 0, y = 0 }

        PageDown ->
            { pos | x = pos.x + 10 }

        PageUp ->
            { pos | x = pos.x - 10 }

        _ ->
            pos


moveCursor : Movement -> Model -> Model
moveCursor mov model =
    let
        newPos =
            getNewPos mov model
    in
    moveOffset newPos model


clampCursor : Model -> Location.Pos -> Location.Pos
clampCursor model newPos =
    let
        lastRow =
            Array.length model.sourceCode - 1
    in
    { x = clamp 0 lastRow newPos.x
    , y = clamp 0 model.viewportSize.width newPos.y
    }


moveOffset : Location.Pos -> Model -> Model
moveOffset newCursor model =
    let
        diff =
            newCursor.x - model.cursor.x

        displayRangeBeg =
            model.rowOffset

        displayRangeEnd =
            displayRangeBeg + model.viewportSize.height - 1

        newCursorOutside =
            newCursor.x < displayRangeBeg || newCursor.x > displayRangeEnd

        newOffset =
            if newCursorOutside then
                clamp
                    0
                    (Array.length model.sourceCode - model.viewportSize.height)
                    (model.rowOffset + diff)

            else
                0
    in
    { model
        | rowOffset = newOffset
        , cursor = clampCursor model newCursor
    }


defaultHeight =
    10


getSourceCode : Result Http.Error (List Token) -> Model -> Model
getSourceCode result _ =
    case result of
        Ok data ->
            createModel defaultHeight <| splitByNewline data

        Err _ ->
            createModel defaultHeight <| Array.fromList []


trimNewLines : ( Token, List Token ) -> Array Token
trimNewLines ( token, list ) =
    if token.value == "\n" then
        Array.fromList (List.concat [ list, [ token ] ])

    else
        token
            :: List.append list [ { token_type = "Text", value = "\n" } ]
            |> Array.fromList


splitByNewline : List Token -> Array (Array Token)
splitByNewline tokens =
    let
        test _ b =
            b.value /= "\n"

        listGroups =
            ArrayExtra.groupWhile test tokens
    in
    Array.fromList
        (List.map trimNewLines listGroups)


tokenListDecoder : JsonDecode.Decoder (List Token)
tokenListDecoder =
    JsonDecode.field "data" <| JsonDecode.list tokenDecoder


tokenDecoder : JsonDecode.Decoder Token
tokenDecoder =
    JsonDecode.map2 Token
        (JsonDecode.field "type" JsonDecode.string)
        (JsonDecode.field "value" JsonDecode.string)


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

        Just ( 'B', "" ) ->
            MoveCursor JumpTo

        _ ->
            NoOp

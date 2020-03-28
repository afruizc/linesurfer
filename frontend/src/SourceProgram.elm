module SourceProgram exposing (..)

import Array exposing (Array)
import ArrayExtra
import Browser.Events
import CodeHighlighting
import Dict
import Html
import Http
import Json.Decode as JsonDecode
import Location
import Models exposing (ColorTable, SourceTable, Token)


type Movement
    = RightOneChar
    | LeftOneChar
    | UpOneChar
    | DownOneChar


type Msg
    = GetTokens (Result Http.Error (List Token))
    | MoveCursor Movement
    | NoOp


type alias Model =
    { table : SourceTable
    , cursor : Location.Pos
    , rowOffset : Int
    , viewportSize : Location.Size
    , colorTable : ColorTable
    }


view : Model -> Html.Html Msg
view model =
    CodeHighlighting.renderCode
        model.viewportSize
        model.cursor
        (getCodeToDisplay model)
        model.colorTable


initialModel =
    { table = Array.fromList []
    , cursor = { x = 0, y = 0 }
    , rowOffset = 0
    , viewportSize = { width = 0, height = 1 }
    , colorTable = Dict.fromList []
    }


createModel : Int -> SourceTable -> Model
createModel height source =
    let
        maxWidth =
            80
    in
    { viewportSize = { width = maxWidth, height = height }
    , cursor = { x = 0, y = 0 }
    , table = source
    , rowOffset = 0
    , colorTable = CodeHighlighting.init source
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


moveCursor : Movement -> Model -> Model
moveCursor mov model =
    let
        ( dx, dy ) =
            case mov of
                RightOneChar ->
                    ( 0, 1 )

                LeftOneChar ->
                    ( 0, -1 )

                UpOneChar ->
                    ( -1, 0 )

                DownOneChar ->
                    ( 1, 0 )

        ( x, y ) =
            ( model.cursor.x, model.cursor.y )

        newCursor =
            { x = x + dx
            , y = y + dy
            }

        height =
            model.viewportSize.height

        numberOfLines =
            Array.length model.table

        isFirstRow =
            x == 0 && model.rowOffset == 0

        isLastRow =
            x == (height - 1) && (model.rowOffset + height) == numberOfLines

        canMoveRangeUp =
            newCursor.x < 0 && not isFirstRow

        canMoveRangeDown =
            newCursor.x >= height && not isLastRow

        newOffset =
            if canMoveRangeUp || canMoveRangeDown then
                model.rowOffset + dx

            else
                model.rowOffset

        clampedNewCursor =
            clampPos model.viewportSize newCursor
    in
    { model
        | cursor = clampedNewCursor
        , rowOffset = newOffset
    }


clampPos : Location.Size -> Location.Pos -> Location.Pos
clampPos size pos =
    { x = clamp 0 (size.height - 1) pos.x
    , y = clamp 0 (size.width - 1) pos.y
    }


getCodeToDisplay : Model -> SourceTable
getCodeToDisplay model =
    let
        newTable =
            model.table
                |> Array.toList
                |> List.drop model.rowOffset
                |> List.take model.viewportSize.height
    in
    Array.fromList newTable


defaultHeight =
    30


getSourceCode : Result Http.Error (List Token) -> Model -> Model
getSourceCode result _ =
    case result of
        Ok data ->
            createModel defaultHeight <| splitByNewline data

        Err _ ->
            createModel defaultHeight <| Array.fromList []


splitByNewline : List Token -> Array (Array Token)
splitByNewline tokens =
    let
        test _ b =
            b.value /= "\n"

        listGroups =
            ArrayExtra.groupWhile test tokens
    in
    Array.fromList
        (List.map (\( t, list ) -> Array.fromList (t :: list)) listGroups)


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

        --Just ( 'B', "" ) ->
        --    JumpCursor
        _ ->
            NoOp

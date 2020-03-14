module Main exposing (..)

import Browser
import Browser.Events
import Html exposing (Html, div)
import Json.Decode as Decode
import JumpTable exposing (JumpTable, addJump, createDefaultJumpTable, getJump)
import Models exposing (Movement(..), Msg(..))
import Viewport exposing (CodeViewer, createViewer, jumpCursor, moveCursor, render)


---- MODEL ----

type alias Model =
    { viewer : CodeViewer
    , jumpTable: JumpTable
    }

initialViewer = createViewer
    [ ""
    , "package main"
    , ""
    , "func blah() { println(\"hola\") }"
    , ""
    , "func main() {"
    , "    blah()"
    , "}"
    ]


initialJumpTable =
    createDefaultJumpTable initialViewer.size
        |> addJump (6,4) (3, 5)

initialModel =
    { viewer = initialViewer
    , jumpTable = initialJumpTable
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel , Cmd.none )


---- UPDATE ----

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        (MoveCursor dir) -> ( { model | viewer = ( moveCursor dir model.viewer ) }, Cmd.none )
        JumpCursor -> ( { model | viewer = ( jumpCursor model.jumpTable model.viewer ) }, Cmd.none )
        NoOp -> ( model, Cmd.none )

---- VIEW ----

--showLines : Model -> Html Msg
--showLines model =
--    let
--        createLine idx line =
--            li [ id <| "l" ++ String.fromInt (idx + 1) ]
--               [ pre [ ] [ text <|  String.fromInt (idx + 1) ++ ". " ]
--               , pre [ ] [ text line ]
--               ]
--    in
--        ul []
           --(List.indexedMap createLine model.program)


view : Model -> Html Msg
view model =
    render model.viewer
    --div [] []


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
subscriptions model =
    Browser.Events.onKeyDown keyDecoder

keyDecoder : Decode.Decoder Msg
keyDecoder =
    Decode.map toKey (Decode.field "key" Decode.string)


toKey : String -> Msg
toKey string =
    case String.uncons string of
        Just ( 'j', "" ) ->
            MoveCursor DownOneChar
        Just ( 'k', "" ) ->
            MoveCursor UpOneChar
        Just ( 'h', "" ) ->
            MoveCursor LeftOneChar
        Just ( 'l', "" ) ->
            MoveCursor RightOneChar
        Just ( 'b', "" ) ->
            JumpCursor

        _ ->
            NoOp

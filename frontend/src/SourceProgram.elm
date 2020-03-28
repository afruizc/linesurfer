module SourceProgram exposing (..)

import ColorTable
import Html
import Html.Attributes exposing (style)
import Http
import Json.Decode as JsonDecode
import Models exposing (SourceProgram, Token, Url)


type Msg
    = GotSourceCode (Result Http.Error SourceProgram)


type alias Model =
    { source : SourceProgram
    }


view : Model -> Html.Html Msg
view model =
    ColorTable.renderCode model.source


initialModel =
    { source = [] }


fetchSourceCode : Url -> Cmd Msg
fetchSourceCode url =
    Http.get
        { url = url
        , expect = Http.expectJson GotSourceCode sourceProgramDecoder
        }


init : ( Model, Cmd Msg )
init =
    ( initialModel, fetchSourceCode "http://localhost:8080" )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSourceCode result ->
            --( updateModelIfSuccess result model, Cmd.none )
            ( updateModel result model, Cmd.none )


updateModel : Result Http.Error SourceProgram -> Model -> Model
updateModel result _ =
    case result of
        Ok data ->
            { source = data }

        Err _ ->
            { source = [] }


sourceProgramDecoder : JsonDecode.Decoder SourceProgram
sourceProgramDecoder =
    JsonDecode.field "data" <| JsonDecode.list tokenDecoder


tokenDecoder : JsonDecode.Decoder Token
tokenDecoder =
    JsonDecode.map3 Token
        (JsonDecode.field "type" JsonDecode.string)
        (JsonDecode.field "value" JsonDecode.string)
        (JsonDecode.succeed -1)

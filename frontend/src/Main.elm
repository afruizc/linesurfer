module Main exposing (..)

import Browser
import Browser.Events
import Html exposing (Html)

import Json.Decode as Decode
import Viewport exposing (CodeViewer, Movement(..), VMsg, createViewer, keyToAction, render, updateViewer)


---- MODEL ----
type alias Model =
    { viewer : CodeViewer
    }


---- MSG ----
type Msg
    = ViewerMsg VMsg


initialViewer = createViewer
    [ "package main"
    , ""
    , "import ("
    , "\t\"encoding/json\""
    , "\t\"fmt\""
    , "\t\"io/ioutil\""
    , "\t\"net/http\""
    , "\t\"strings\"",
    ")",
    "",
    "func main() {",
    "\tfmt.Println(\"Connect here\")",
    "\thttp.HandleFunc(\"/\", HelloServer)",
    "\t_ = http.ListenAndServe(\":8080\", nil)",
    "}",
    "",
    "func checkErr(err error) {",
    "\tif err != nil {",
    "\t\tpanic(err)",
    "\t}",
    "}",
    "",
    "func splitLines(data []byte) []string {",
    "\tdataStr := string(data)",
    "",
    "\treturn strings.Split(dataStr, \"\\n\")",
    "}",
    "",
    "func HelloServer(w http.ResponseWriter, r *http.Request) {",
    "\tdata, err := ioutil.ReadFile(\"main.go\")",
    "\tcheckErr(err)",
    "",
    "\tlinesList := splitLines(data)",
    "",
    "\tjsonData, err := json.Marshal(linesList)",
    "\tcheckErr(err)",
    "",
    "\t_, _ = w.Write(jsonData)",
    "}",
    ""
    ]

initialModel =
    { viewer = initialViewer
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel , Cmd.none )


---- UPDATE ----
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        (ViewerMsg vmsg) -> ({ model | viewer = ( updateViewer vmsg model.viewer )}, Cmd.none)


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


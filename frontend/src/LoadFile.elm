module LoadFile exposing (..)

import Http
import Json.Decode exposing (Decoder, field, list, string)


type alias Program = List String

type alias Url = String


type Model = Loading
           | Failure
           | Success Program


type Msg =
    GotJson (Result Http.Error Program)


fetchFile : Url -> Cmd Msg
fetchFile url =
    Http.get
        { url = url
        , expect = Http.expectJson GotJson fileDecoder
        }


fileDecoder : Decoder Program
fileDecoder =
    field  "data" (list string)

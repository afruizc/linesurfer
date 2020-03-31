module FetchCode exposing (..)

import Array exposing (Array)
import ArrayExtra
import CodeHighlighting
import Config
import Http
import Json.Decode as JsonDecode
import JumpTable
import Models exposing (CodeViewer, SourceCode, Token)
import Viewport


getSourceCode : Result Http.Error (List Token) -> CodeViewer
getSourceCode result =
    case result of
        Ok data ->
            splitByNewline data
                |> createModel

        Err _ ->
            Array.fromList []
                |> createModel


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


trimNewLines : ( Token, List Token ) -> Array Token
trimNewLines ( token, list ) =
    if token.value == "\n" then
        Array.fromList (List.concat [ list, [ token ] ])

    else
        token
            :: List.append list [ { token_type = "Text", value = "\n" } ]
            |> Array.fromList


createModel : SourceCode -> CodeViewer
createModel source =
    let
        size =
            { width = Config.defaultWidth, height = Config.defaultHeight }

        totalHeight =
            Array.length source

        viewport =
            Viewport.createAtOrigin size totalHeight
    in
    { sourceCode = source
    , viewport = Result.withDefault Viewport.empty viewport
    , colorTable = CodeHighlighting.init source
    , jumpTable = JumpTable.initJumpTable []
    }


tokenListDecoder : JsonDecode.Decoder (List Token)
tokenListDecoder =
    JsonDecode.field "data" <| JsonDecode.list tokenDecoder


tokenDecoder : JsonDecode.Decoder Token
tokenDecoder =
    JsonDecode.map2 Token
        (JsonDecode.field "type" JsonDecode.string)
        (JsonDecode.field "value" JsonDecode.string)

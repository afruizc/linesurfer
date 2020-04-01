module FetchCode exposing (..)

import Array exposing (Array)
import ArrayExtra
import Config
import Dict exposing (Dict)
import HtmlRendering
import Http
import Json.Decode as JsonDecode
import JumpTable
import Models exposing (CodeViewer, Model, SourceCode, Token, ViewersTable)
import Viewport


getSourceCode : Result Http.Error (List SourceCode) -> Model
getSourceCode result =
    case result of
        Ok data ->
            createModel data

        Err _ ->
            createModel []


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


createViewer : SourceCode -> CodeViewer
createViewer source =
    let
        size =
            { width = Config.defaultWidth, height = Config.defaultHeight }

        totalHeight =
            Array.length source.content

        viewport =
            Viewport.createAtOrigin size totalHeight
    in
    { sourceCode = source
    , viewport = Result.withDefault Viewport.empty viewport
    , jumpTable = JumpTable.initJumpTable []
    }


createModel : List SourceCode -> Model
createModel sources =
    let
        insert : SourceCode -> ViewersTable -> ViewersTable
        insert source dict =
            Dict.insert source.path (createViewer source) dict

        allViewports =
            List.foldr insert Dict.empty sources
    in
    { currentViewer =
        List.head sources
            |> Maybe.withDefault { path = "", content = Array.fromList [] }
            |> createViewer
    , allViewers = allViewports
    , colorTable = HtmlRendering.init sources
    }


tokenListDecoder : JsonDecode.Decoder (List SourceCode)
tokenListDecoder =
    JsonDecode.field "data" <| JsonDecode.list sourceCodeDecoder


sourceCodeDecoder : JsonDecode.Decoder SourceCode
sourceCodeDecoder =
    JsonDecode.map2 SourceCode
        (JsonDecode.field "path" JsonDecode.string)
        (JsonDecode.map splitByNewline (JsonDecode.field "content" <| JsonDecode.list tokenDecoder))


tokenDecoder : JsonDecode.Decoder Token
tokenDecoder =
    JsonDecode.map2 Token
        (JsonDecode.field "type" JsonDecode.string)
        (JsonDecode.field "value" JsonDecode.string)

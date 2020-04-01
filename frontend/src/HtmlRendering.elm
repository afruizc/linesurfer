module HtmlRendering exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Hex
import Html
import Html.Attributes exposing (style)
import HtmlElements
import Location
import Models exposing (CodeViewer, Color, ColorTable, Model, Msg(..), SourceCode, Token)
import Random
import SourceCode
import Styles exposing (gridCss)


empty : ColorTable
empty =
    Dict.fromList []


init : List SourceCode -> ColorTable
init source =
    let
        initialElement =
            ( empty, Random.initialSeed 0 )
    in
    Tuple.first <| List.foldr set initialElement (flattenSourceCodes source)


renderViewer : ColorTable -> CodeViewer -> Html.Html msg
renderViewer table viewer =
    Html.div
        [ style "display" "flex"
        , style "font" "1.2rem monospace"
        ]
        [ renderLineNumbers viewer
        , renderCode table viewer
        ]


getAllFiles : Model -> List String
getAllFiles model =
    Dict.toList model.allViewers
        |> List.map Tuple.first


render : Model -> Html.Html Msg
render model =
    Html.div []
        [ HtmlElements.renderSelect ChangeTo (getAllFiles model)
        , renderViewer model.colorTable model.currentViewer
        ]


renderLineNumbers : CodeViewer -> Html.Html msg
renderLineNumbers viewer =
    let
        rowStart =
            viewer.viewport.rowOffset + 1

        rowEnd =
            min viewer.viewport.totalHeight
                (rowStart + viewer.viewport.size.height - 1)
    in
    Html.div
        [ style "flex-basis" "4ch"
        ]
        [ Html.div
            [ style "display" "flex"
            , style "align-items" "flex-end"
            , style "flex-direction" "column"
            , style "margin-left" "-4ch"
            , style "color" "white"
            ]
            (List.range rowStart rowEnd
                |> List.map String.fromInt
                |> List.map (\s -> Html.div [] [ Html.text (s ++ "\u{00A0}") ])
            )
        ]


renderCode : ColorTable -> CodeViewer -> Html.Html msg
renderCode color viewer =
    let
        codeToDisplay =
            SourceCode.getCodeToDisplay viewer

        len =
            Array.length codeToDisplay.content
                |> Debug.log "length"
    in
    Html.div []
        (Html.pre
            [ style "position" "absolute"
            ]
            (List.map (renderToken color) <|
                flattenSourceCode codeToDisplay.content
            )
            :: [ gridPanel viewer.viewport.size viewer.viewport.cursor ]
        )


get : ColorTable -> String -> Color
get table key =
    case Dict.get key table of
        Just x ->
            x

        Nothing ->
            { r = 0, g = 0, b = 0 }


set : Token -> ( ColorTable, Random.Seed ) -> ( ColorTable, Random.Seed )
set token ( table, seed ) =
    case Dict.get token.token_type table of
        Just _ ->
            ( table, seed )

        Nothing ->
            let
                ( newColor, newSeed ) =
                    Random.step randomDarkColorGenerator seed

                newDict =
                    Dict.insert token.token_type newColor table
            in
            ( newDict, newSeed )


flattenSourceCode : Array (Array Token) -> List Token
flattenSourceCode =
    Array.foldr Array.append Array.empty
        >> Array.toList


flattenSourceCodes : List SourceCode -> List Token
flattenSourceCodes sources =
    List.map .content sources
        |> List.map flattenSourceCode
        |> List.concat


gridPanel : Location.Size -> Location.Pos -> Html.Html msg
gridPanel size cursor =
    Html.div (gridCss size)
        (gridDivs size cursor)


from2Dto1D : Int -> Location.Pos -> Int
from2Dto1D width { x, y } =
    width * x + y


gridDivs : Location.Size -> Location.Pos -> List (Html.Html msg)
gridDivs size cursor =
    let
        cellCount =
            size.width * size.height
    in
    Array.repeat cellCount emptyCell
        |> Array.set
            (from2Dto1D size.width
                (clampCursor size.height cursor)
            )
            focusedCell
        |> Array.toList


clampCursor : Int -> Location.Pos -> Location.Pos
clampCursor h pos =
    { pos | x = modBy h pos.x }


cell =
    [ style "width" "1ch"
    , style "height" "20px"
    ]


emptyCell =
    Html.div
        cell
        []


focusedCell =
    Html.div
        (style "background-color" "rgba(255, 255, 255, 0.3)"
            :: cell
        )
        []


renderToken : ColorTable -> Token -> Html.Html msg
renderToken table token =
    renderTokenWithColor (toHexColor <| get table token.token_type) token


renderTokenWithColor : String -> Token -> Html.Html msg
renderTokenWithColor hexColor token =
    Html.span
        [ style "color" hexColor
        , style "height" "25px"
        ]
        [ Html.text token.value ]


toHexColor : Color -> String
toHexColor { r, g, b } =
    String.concat [ "#", Hex.toString r, Hex.toString g, Hex.toString b ]


randomDarkColorGenerator =
    randomColorGenerator 80 256


randomColorGenerator : Int -> Int -> Random.Generator Color
randomColorGenerator low high =
    let
        genInt =
            Random.int low high

        newColor r g b =
            { r = r, g = g, b = b }
    in
    Random.map3 newColor genInt genInt genInt

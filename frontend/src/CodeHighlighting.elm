module CodeHighlighting exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Hex
import Html
import Html.Attributes exposing (style)
import Location
import Models exposing (CodeViewer, Color, ColorTable, SourceCode, Token)
import Random
import Styles exposing (gridCss)


empty : ColorTable
empty =
    Dict.fromList []


init : SourceCode -> ColorTable
init source =
    let
        initialElement =
            ( empty, Random.initialSeed 0 )
    in
    Tuple.first <| List.foldr set initialElement (flattenToList source.content)


render : CodeViewer -> Html.Html msg
render model =
    Html.div
        [ style "display" "flex"
        , style "font" "1.2rem monospace"
        ]
        [ renderLineNumbers model
        , renderCode model
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


getCodeToDisplay : CodeViewer -> SourceCode
getCodeToDisplay viewer =
    let
        newTable =
            viewer.sourceCode.content
                |> Array.slice viewer.viewport.rowOffset viewer.viewport.size.height
    in
    { path = "", content = newTable }


renderCode : CodeViewer -> Html.Html msg
renderCode model =
    let
        codeToDisplay =
            getCodeToDisplay model
    in
    Html.div []
        (Html.pre
            [ style "position" "absolute"
            ]
            (List.map (renderToken model.colorTable) <|
                flattenToList codeToDisplay.content
            )
            :: [ gridPanel model.viewport.size (calculateViewportCoordinate model) ]
        )


calculateViewportCoordinate : CodeViewer -> Location.Pos
calculateViewportCoordinate model =
    let
        pos =
            model.viewport.cursor
    in
    { pos | x = modBy model.viewport.size.height pos.x }


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


flattenToList : Array (Array a) -> List a
flattenToList xs =
    Array.foldr Array.append Array.empty xs
        |> Array.toList


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

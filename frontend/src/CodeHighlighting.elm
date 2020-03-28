module CodeHighlighting exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Hex
import Html
import Html.Attributes exposing (style)
import Location
import Models exposing (Color, ColorTable, SourceTable, Token)
import Random
import Styles exposing (gridCss)


empty : ColorTable
empty =
    Dict.fromList []


init : SourceTable -> ColorTable
init source =
    let
        initialElement =
            ( empty, Random.initialSeed 111 )
    in
    Tuple.first <| List.foldr set initialElement (flattenToList source)


renderCode : Location.Size -> Location.Pos -> SourceTable -> ColorTable -> Html.Html msg
renderCode size cursor source table =
    Html.div
        [ style "font" "1.2rem monospace"
        ]
        (Html.pre
            [ style "position" "absolute"
            ]
            (List.map (renderToken table) <| flattenToList source)
            :: [ gridPanel size cursor source ]
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


flattenToList : Array (Array a) -> List a
flattenToList xs =
    Array.foldr Array.append Array.empty xs
        |> Array.toList


gridPanel : Location.Size -> Location.Pos -> SourceTable -> Html.Html msg
gridPanel size cursor viewer =
    Html.div (gridCss size)
        (gridDivs size cursor viewer)


from2Dto1D : Int -> Location.Pos -> Int
from2Dto1D width { x, y } =
    width * x + y


gridDivs : Location.Size -> Location.Pos -> SourceTable -> List (Html.Html msg)
gridDivs size cursor source =
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
        (style "background-color" "rgba(1, 1, 1, 0.2)"
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
    randomColorGenerator 3 200


randomColorGenerator : Int -> Int -> Random.Generator Color
randomColorGenerator low high =
    let
        genInt =
            Random.int low high

        newColor r g b =
            { r = r, g = g, b = b }
    in
    Random.map3 newColor genInt genInt genInt

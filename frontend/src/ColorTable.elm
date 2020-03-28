module ColorTable exposing (..)

import Dict exposing (Dict)
import Hex
import Html
import Html.Attributes exposing (style)
import Models exposing (SourceProgram, Token)
import Random


type alias Color =
    { r : Int
    , g : Int
    , b : Int
    }


type alias Table =
    Dict String Color


empty : Table
empty =
    Dict.fromList []


init : SourceProgram -> Table
init source =
    let
        initialElement =
            ( empty, Random.initialSeed 111 )
    in
    Tuple.first <| List.foldr set initialElement source


get : Table -> String -> Color
get table key =
    case Dict.get key table of
        Just x ->
            x

        Nothing ->
            { r = 0, g = 0, b = 0 }


set : Token -> ( Table, Random.Seed ) -> ( Table, Random.Seed )
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


renderCode : SourceProgram -> Html.Html msg
renderCode source =
    let
        table =
            init source
    in
    Html.div []
        [ Html.pre []
            (List.map (renderToken table) source)
        ]


renderToken : Table -> Token -> Html.Html msg
renderToken table token =
    renderTokenWithColor (toHexColor <| get table token.token_type) token


renderTokenWithColor : String -> Token -> Html.Html msg
renderTokenWithColor hexColor token =
    Html.span [ style "color" hexColor ]
        [ Html.text token.value ]


toHexColor : Color -> String
toHexColor { r, g, b } =
    String.concat [ "#", Hex.toString r, Hex.toString g, Hex.toString b ]


randomDarkColorGenerator =
    randomColorGenerator 0 256


randomColorGenerator : Int -> Int -> Random.Generator Color
randomColorGenerator low high =
    let
        genInt =
            Random.int low high

        newColor r g b =
            { r = r, g = g, b = b }
    in
    Random.map3 newColor genInt genInt genInt

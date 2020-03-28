module TestColorTable exposing (..)

import ColorTable
import Expect
import Html
import Html.Attributes exposing (style)
import Test exposing (Test, describe, test)


oneTokenNoHighlight =
    { token_type = "one"
    , value = "hello"
    , highlight = -1
    }


noHighlightResult =
    Html.span [ style "color" "#010101" ]
        [ Html.text "hello" ]


oneTokenHighlight =
    { token_type = "one"
    , value = "hello"
    , highlight = 1
    }


highlightResult =
    Html.span [ style "color" "#010101" ]
        [ Html.text "h"
        , Html.span [ style "background-color" "rgba(0, 0, 0, 0.3)" ]
            [ Html.text "e"
            ]
        , Html.text "llo"
        ]


all : Test
all =
    describe "Render token"
        [ test "no highlight" <|
            \_ ->
                oneTokenNoHighlight
                    |> ColorTable.renderTokenWithColor "#010101"
                    |> Expect.equal noHighlightResult
        , test "basic highlight " <|
            \_ ->
                oneTokenHighlight
                    |> ColorTable.renderTokenWithColor "#010101"
                    |> Expect.equal highlightResult
        ]

module TestColorTable exposing (..)

import Expect
import Html
import Html.Attributes exposing (style)
import HtmlRendering
import Test exposing (Test, describe, test)


oneTokenNoHighlight =
    { token_type = "one"
    , value = "hello"
    }


noHighlightResult =
    Html.span
        [ style "color" "#010101"
        , style "height" "25px"
        ]
        [ Html.text "hello" ]


all : Test
all =
    describe "Render token"
        [ test "basic render" <|
            \_ ->
                oneTokenNoHighlight
                    |> HtmlRendering.renderTokenWithColor "#010101"
                    |> Expect.equal noHighlightResult
        ]

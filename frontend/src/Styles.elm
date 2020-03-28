module Styles exposing (..)

import Html exposing (Html)
import Html.Attributes exposing (style)
import Models exposing (Size)


repeat n u ms =
    "repeat(" ++ String.fromInt n ++ ", " ++ String.fromFloat u ++ ms ++ ")"


gridCss : Size -> Float -> Float -> List (Html.Attribute msg)
gridCss size w h =
    [ style "display" "grid"
    , style "grid-template-columns" (repeat size.width w "px")
    , style "grid-template-rows" (repeat size.height h "px")
    ]


oneLineGrid : Int -> Float -> List (Html.Attribute msg)
oneLineGrid numberOfRows rowHeight =
    [ style "display" "grid"
    , style "grid-template-columns" "1"
    , style "grid-template-rows" (repeat numberOfRows rowHeight "px")
    ]

module Styles exposing (..)

import Html exposing (Html)
import Html.Attributes exposing (style)
import Location exposing (Size)


repeat times value unit =
    "repeat(" ++ String.fromInt times ++ ", " ++ String.fromFloat value ++ unit ++ ")"


gridCss : Size -> List (Html.Attribute msg)
gridCss size =
    [ style "display" "grid"
    , style "grid-template-columns" (repeat size.width 1 "ch")
    , style "justify-items" "center"
    , style "align-items" "center"
    , style "font" "1.2rem monospace"
    , style "grid-template-rows" (repeat size.height 20 "px")
    ]


oneLineGrid : Int -> Float -> List (Html.Attribute msg)
oneLineGrid numberOfRows rowHeight =
    [ style "display" "grid"
    , style "grid-template-columns" "1"
    , style "grid-template-rows" (repeat numberOfRows rowHeight "px")
    ]

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


select : List (Html.Attribute msg)
select =
    [ style "background-color" "rgba(49, 81, 104)"
    , style "color" "lightgray"
    , style "padding" ".5rem"
    , style "margin" ".5rem 0"
    , style "font" "1.1rem monospace"
    , style "min-width" "90%"
    , style "border" "1px solid gray"
    ]

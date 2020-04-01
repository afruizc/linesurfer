module HtmlElements exposing (..)

import Html
import Html.Attributes
import Html.Events
import Styles


renderSelect : (String -> msg) -> List String -> Html.Html msg
renderSelect msg data =
    let
        optionize txt =
            Html.option [ Html.Attributes.value txt ] [ Html.text txt ]
    in
    Html.select (Html.Events.onInput msg :: Styles.select)
        (List.map optionize data)

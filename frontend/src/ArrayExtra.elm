module ArrayExtra exposing (..)


groupWhile : (a -> a -> Bool) -> List a -> List ( a, List a )
groupWhile isSameGroup items =
    List.foldr
        (\x acc ->
            case acc of
                [] ->
                    [ ( x, [] ) ]

                ( y, restOfGroup ) :: groups ->
                    if isSameGroup x y then
                        ( x, y :: restOfGroup ) :: groups

                    else
                        ( x, [] ) :: acc
        )
        []
        items


{-| Drop elements in order as long as the predicate evaluates to `True`
-}
dropWhile : (a -> Bool) -> List a -> List a
dropWhile predicate list =
    case list of
        [] ->
            []

        x :: xs ->
            if predicate x then
                dropWhile predicate xs

            else
                list


{-| Take elements in order as long as the predicate evaluates to `True`
-}
takeWhile : (a -> Bool) -> List a -> List a
takeWhile predicate =
    let
        takeWhileMemo memo list =
            case list of
                [] ->
                    List.reverse memo

                x :: xs ->
                    if predicate x then
                        takeWhileMemo (x :: memo) xs

                    else
                        List.reverse memo
    in
    takeWhileMemo []


span : (a -> Bool) -> List a -> ( List a, List a )
span p xs =
    ( takeWhile p xs, dropWhile p xs )

module List.Unique
    exposing
        ( UniqueList
        , addAfter
        , addBefore
        , cons
        , empty
        , filterDuplicates
        , fromList
        , isAfter
        , isBefore
        , isEmpty
        , isFirst
        , length
        , member
        , remove
        , reverse
        , toList
        )

{-| A list that can only contain unique elements


# UniqueList

@docs UniqueList


# Basics

@docs empty, isEmpty, fromList, toList, length, reverse, member


# Modifying UniqueLists

@docs remove, cons, addBefore, addAfter, isBefore, isAfter, isFirst


# Util

@docs filterDuplicates

-}


{-| An arrangement of things in an order. An `UniqueList` is kind of like a `List`, except there cant be duplicate elements. And, its kind of like a `Set`, except an `UniqueList`s elements go from first to last.
-}
type UniqueList a
    = UniqueList (List a)


{-| Create an empty `UniqueList

    List.Unique.empty == List.Unique.fromList []

-}
empty : UniqueList a
empty =
    UniqueList []


{-| Check if an Order is empty

    Order.isEmpty Order.empty == True

-}
isEmpty : UniqueList a -> Bool
isEmpty (UniqueList list) =
    List.isEmpty list


{-| Get the length of a `UniqueList`

    nobleGases = List.Unique.fromList
        [ helium
        , neon
        , argon
        , krypton
        , xenon
        , radon
        ]

    List.Unique.length nobleGases == 6

-}
length : UniqueList a -> Int
length (UniqueList list) =
    List.length list


{-| Reverse a `UniqueList`

    bestCoffeeDrinks ==
        List.Unique.fromList
            [ cortado
            , latte
            , coldbrew
            , coffee
            , mocha
            ]

    worstCoffeeDrinks : UniqueList Coffee
    worstCoffeeDrinks =
        List.Unique.reverse bestCoffeeDrinks

-}
reverse : UniqueList a -> UniqueList a
reverse (UniqueList list) =
    UniqueList (List.reverse list)


{-| Check if something is in a `UniqueList`

    List.Unique.member "Grover Cleveland" usPresidents == True

-}
member : a -> UniqueList a -> Bool
member el (UniqueList list) =
    List.member el list


{-| Create a `UniqueList` from a `List`
-}
fromList : List a -> UniqueList a
fromList list =
    UniqueList (List.foldr consIfNotMember [] list)


{-| Turn a `UniqueList` into a `List`

    let
        u = [ 'u' ]

        doubleU = [ 'u', 'u' ]
    in
        u == (List.Unique.toList <| List.Unique.fromList doubleU)

-}
toList : UniqueList a -> List a
toList (UniqueList list) =
    list


{-| Remove an element from a `UniqueList
-}
remove : a -> UniqueList a -> UniqueList a
remove element (UniqueList list) =
    UniqueList (filterFor element list)


{-| Add an element to the beginning of a `UniqueList`
-}
cons : a -> UniqueList a -> UniqueList a
cons element (UniqueList list) =
    UniqueList (element :: filterFor element list)


{-| Add an element to a `UniqueList` before another element

    addBefore `c` `b` (List.Unique.fromList [ `a`, `c`, `d` ])
        == List.Unique.fromList [ `a`, `b`, `c`, `d` ]

-}
addBefore : a -> a -> UniqueList a -> UniqueList a
addBefore el newEl (UniqueList list) =
    if newEl /= el then
        let
            check : a -> List a -> List a
            check thisEl newList =
                if thisEl == el then
                    newEl :: thisEl :: newList
                else
                    thisEl :: newList
        in
        list
            |> List.foldr check []
            |> fromList
    else
        UniqueList list


{-| Add an element to a `UniqueList` before another element

    addAfter `b` `c` (List.Unique.fromList [ `a`, `b`, `d` ])
        == List.Unique.fromList [ `a`, `b`, `c`, `d` ]

-}
addAfter : a -> a -> UniqueList a -> UniqueList a
addAfter el newEl (UniqueList list) =
    if newEl /= el then
        let
            check : a -> List a -> List a
            check thisEl newList =
                if thisEl == el then
                    el :: newEl :: newList
                else
                    thisEl :: newList
        in
        list
            |> List.foldr check []
            |> fromList
    else
        UniqueList list


{-| Check if an element is before another, if it is in the `UniqueList` at all.

    germanStates = List.Unique.fromList [ "Bavaria", "Brandenberg" ]

    ("Bavaria" |> List.Unique.isBefore "Brandenberg") germanStates == Just True

    ("Bavaria" |> List.Unique.isBefore "New York City") germanStates == Nothing

-}
isBefore : a -> a -> UniqueList a -> Maybe Bool
isBefore after first (UniqueList list) =
    case ( getOrderHelper after list, getOrderHelper first list ) of
        ( Just afterIndex, Just firstIndex ) ->
            if firstIndex < afterIndex then
                Just True
            else
                Just False

        _ ->
            Nothing


{-| Check if an element is after another, if it is in the `UniqueList` at all.
-}
isAfter : a -> a -> UniqueList a -> Maybe Bool
isAfter first after order =
    isBefore after first order


{-| Check is an element is the first in a `UniqueList`
-}
isFirst : a -> UniqueList a -> Maybe Bool
isFirst el (UniqueList list) =
    case list of
        [] ->
            Nothing

        x :: xs ->
            if x == el then
                Just True
            else
                Just False


{-| If you just need to filter out duplicates, but dont want to use th `UniqueList` type, use this function. Its just like the `unique` function in `elm-community/list-extra`, except for the fact that `List.Extra.unique` only works on `List comparable`.

    filterDuplicates [ True, True ] == [ True ]
    filterDuplicates [ 1, 1, 2, 3, 5 ] == [ 1, 2, 3, 5 ]

-}
filterDuplicates : List a -> List a
filterDuplicates =
    fromList >> toList



-- HELPERS --


consIfNotMember : a -> List a -> List a
consIfNotMember el list =
    if List.member el list then
        list
    else
        el :: list


getOrderHelper : a -> List a -> Maybe Int
getOrderHelper el list =
    getOrderRecursive el ( List.indexedMap (flip (,)) list, Nothing )
        |> Tuple.second


getOrderRecursive : a -> ( List ( a, Int ), Maybe Int ) -> ( List ( a, Int ), Maybe Int )
getOrderRecursive el ( list, maybeIndex ) =
    case list of
        x :: xs ->
            let
                ( xEl, index ) =
                    x
            in
            if xEl == el then
                ( [], Just index )
            else
                getOrderRecursive el ( xs, maybeIndex )

        [] ->
            ( [], Nothing )


filterFor : a -> List a -> List a
filterFor element list =
    List.filter ((/=) element) list

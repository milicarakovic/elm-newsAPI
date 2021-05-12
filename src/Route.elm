module Route exposing (..)

import Url exposing (Url)
import Url.Parser exposing (..)

type Route
    = NotFound
    | HomePage
    | NewsPage
    | MyNewsPage

parseUrl : Url -> Route
parseUrl url =
    case parse matchRoute url of
        Just route ->
            route
        
        Nothing ->
            NotFound

matchRoute : Parser (Route -> a) a
matchRoute =
    oneOf
        [ map HomePage top
        , map NewsPage (s "newsPage")
        , map MyNewsPage (s "myNewsPage")
        ]


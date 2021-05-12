module Pages.HomePage exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)

startUpPageView : Html msg
startUpPageView =
    div []
        [ h2 [] [ text "Welcome to our News app!" ]
        , h4 [] [ text "Here you can find top news from all over the world!" ]
        , br [] []
        , br [] []
        , table tableStyle
            [ tr []
                [ td [] [pre [] [text "Go to news page --->"]]
                , td [] [a [ href "/newsPage" ] [ text "News" ] ]
                ]
            , tr []
                [ td [] [pre [] [text "Go to page with your news --->"]]
                , td [] [a [ href "/myNewsPage" ] [ text "My News" ] ]
                ]
            ]
        ]

tableStyle : List (Attribute msg)
tableStyle =
    [ style "margin" "auto"
    ]
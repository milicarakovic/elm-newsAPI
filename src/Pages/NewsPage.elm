module Pages.NewsPage exposing (..)

import RemoteData exposing (WebData)
import Model.News exposing (News, initialNews)
import Model.News exposing (newsDecoder)
import Http
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Pages.Error exposing (buildErrorMessage)
import Json.Decode exposing (string)
import Bootstrap.Modal as Modal
import Bootstrap.Button as Button
import List exposing (length)
import Tuple exposing (first)
import List exposing (all)
import List exposing (filter)

type alias Model =
    { news : WebData (List News)
    , searchTitleString : String
    , searchAuthorString : String
    , modalVisible : Bool
    , contentOfTheModal : News
    }

type Msg
    = FetchNews
    | NewsReceived (WebData (List News))
    | SetSearchInput String
    | SetSearchAuthorInput String
    | ShowModal News
    | CloseModal 

init : WebData (List News) -> (Model, Cmd Msg)
init news =
    (initialModel news, fetchNews)

initialModel : WebData (List News) -> Model
initialModel news =
    { news = news
    , searchTitleString = ""
    , searchAuthorString = ""
    , modalVisible = False
    , contentOfTheModal = initialNews
    }

fetchNews : Cmd Msg
fetchNews =
    Http.get
        { url = "http://localhost:3000/topHeadlines/"
        , expect =
            newsDecoder
                |> Http.expectJson (RemoteData.fromResult >> NewsReceived)
        }

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        FetchNews ->
            ({ model | news = RemoteData.Loading }, fetchNews)
        
        NewsReceived response ->
            ({model | news = response}, Cmd.none)
        
        SetSearchInput searchStr ->
            ({model | searchTitleString = searchStr}, Cmd.none)

        SetSearchAuthorInput searchStr ->
            ({model | searchAuthorString = searchStr}, Cmd.none)
        
        CloseModal ->
            ({model | modalVisible = False}, Cmd.none)

        ShowModal toPreview->
            ({model | modalVisible = True, contentOfTheModal = toPreview}, Cmd.none)
        
view : Model -> Html Msg
view model =
    div ([] ++ pageStyle)
        [ div ([] ++ searchBarStyle) [
            div [style "float" "left"] 
                [ input ([onInput SetSearchInput, placeholder "Title..." ] ++ inputStyle) []
                , text "Type title you are searching for"
                -- , button ([ onClick FetchNews ] ++ buttonStyle)
                --     [ text "Search news" ]
                -- 
                ]
            , div [style "width" "2%"] []
            ,div [style "overflow" "hidden"]
                [ input ([onInput SetSearchAuthorInput, placeholder "Author..." ] ++ inputStyle) []
                , text "Type author you are searching for"
                -- , button ([ onClick FetchNews ] ++ buttonStyle)
                --     [ text "Search authors" ]
                ]
        ]
        , br [] []
        , br [] []        
        , if model.modalVisible then
            div
                (onClick CloseModal
                    :: dialogContainerStyle
                )
                [ div []                    
                    [ span [] [ text model.contentOfTheModal.content]
                    , text model.contentOfTheModal.url                  
                    ]
                ]
          else
            div [] []
        , viewNews model
        ]

filterByTitle title list   =
    List.filter (\x -> String.contains title (String.toLower(x.title))) list

filterByAuthor author list   =
    List.filter (\x -> String.contains author (String.toLower(x.author))) list

viewNews : Model -> Html Msg
viewNews model =
    case model.news of        
        RemoteData.NotAsked ->
            text "Not asked"
        
        RemoteData.Loading ->
            h3 [] [ text "Loading..." ]
        
        RemoteData.Success actualNews ->
            let
                filtered = actualNews
                    |> filterByTitle model.searchTitleString
                    |> filterByAuthor model.searchAuthorString
                                    

                oddElements = filterOddList filtered 0
                evenElements = filterEvenList filtered 0
            in
            div ([] ++ combinedStyle)
            [
                div [] (List.map viewOne oddElements)
                ,div [] (List.map viewTwo evenElements)
            ]                
                

        RemoteData.Failure httpError ->
            viewFetchError (buildErrorMessage httpError)


isOdd : Int -> Bool
isOdd number = if (remainderBy 2 number) == 0 then False else True

filterOddList : List News -> Int -> List News
filterOddList allNews index =
    case allNews of
        [] ->
            []

        first :: rest ->
            if (List.length allNews > 0 && isOdd (List.length allNews)) then first :: (filterOddList rest (index + 1)) else filterOddList rest (index + 1)

filterEvenList : List News -> Int -> List News
filterEvenList allNews index =
    case allNews of
        [] ->
            []

        first :: rest ->
            if (List.length allNews > 0 && isOdd (List.length allNews) == False) then first :: (filterEvenList rest (index + 1)) else filterEvenList rest (index + 1)


viewOne : News -> Html Msg
viewOne news =
    div ([] ++ leftContentStyle)
        [ div ([] ++ leftStyle)
           [ img ([src news.urlToImage] ++ imageStyle) []
            , if (news.author == "") then text "No author info" else text news.author
            , br [] []
            , button ([ onClick (ShowModal news)] ++ modalButtonStyle)
                [ text "Read more" ]
            ]
        , div ([] ++ rightStyle)
            [ h4 [] [text news.title]
            , br [] [] 
            , text news.description 
            , br [] [] 
            , br [] []         
            ]
        ]

viewTwo : News -> Html Msg
viewTwo news =
     div ([] ++ rightContentStyle)
        [ div ([] ++ leftStyle)
           [ img ([src news.urlToImage] ++ imageStyle) []
            , if (news.author == "") then text "No author info" else text news.author
            , br [] []
            , button ([ onClick (ShowModal news)] ++ modalButtonStyle)
                [ text "Read more" ]
            ]
        , div ([] ++ rightStyle)
            [ h4 [] [text news.title]
            , br [] [] 
            , text news.description 
            , br [] [] 
            , br [] []         
            ]
        ]

viewFetchError : String -> Html Msg
viewFetchError errorMessage =
    let
        errorHeading =
            "Couldn't fetch news at this time."
    in
    div []
        [ h3 [] [ text errorHeading ]
        , text ("Error: " ++ errorMessage)
        ]

-- STYLE

pageStyle : List (Attribute msg)
pageStyle =
    [ style "margin" "2% 2% 2% 2%"
    ]


searchBarStyle : List (Attribute msg)
searchBarStyle =
    [ style "display" "flex"
    , style "justifyContent" "center"
    ]
inputStyle : List (Attribute msg)
inputStyle =
    [ style "display" "block"
    , style "width" "260px"
    , style "padding" "12px 20px"
    , style "margin" "auto"
    , style "border" "solid 2px #6b9292"
    , style "border-radius" "4px"
    ]

buttonStyle : List (Attribute msg)
buttonStyle =
    [ style "width" "300px"
    , style "background-color" "#6b9292"
    , style "color" "white"
    , style "padding" "14px 20px"
    , style "margin-top" "10px"
    , style "border" "none"
    , style "border-radius" "4px"
    , style "font-size" "16px"
    ]



combinedStyle : List (Attribute msg)
combinedStyle =
    [ style "padding" "10px"
    , style "display" "flex"
    ]

leftContentStyle : List (Attribute msg)
leftContentStyle =
    [ style "marginBottom" "10px"
    , style "padding" "10px"
    , style "border" "solid 1px"
    , style "backgroundColor" "#EAFEFE"
    , style "width" "44vw"
    , style "height" "250px"
    , style "display" "flex"
    , style "flexDirection" "row"
    , style "float" "left"
    ]

rightContentStyle : List (Attribute msg)
rightContentStyle =
    [style "marginBottom" "10px"
    , style "padding" "10px"
    , style "border" "solid 1px"
    , style "backgroundColor" "#EAFEFE"
    , style "width" "44vw"
    , style "height" "250px"
    , style "display" "flex"
    , style "flexDirection" "row"
    , style "overflow" "hidden"
    ]

leftStyle : List (Attribute msg)
leftStyle =
    [ style "float" "left"
    , style "margin" "auto"
    , style "display" "flex"
    , style "flexDirection" "column"
    , style "width" "40%"
    ]

imageStyle : List (Attribute msg)
imageStyle =
    [ style "maxHeight" "100px"
    , style "width" "160px"
    ]

rightStyle : List (Attribute msg)
rightStyle =
    [ style "overflow" "hidden"
    , style "padding" "5px"
    , style "margin" "auto"
    ]

modalButtonStyle : List (Attribute msg)
modalButtonStyle =
    [ style "background-color" "#6b9292"
    , style "color" "white"
    , style "padding" "14px 20px"
    , style "margin-top" "10px"
    , style "border" "none"
    , style "border-radius" "4px"
    , style "font-size" "16px"
    ]

modalStyle : List (Attribute msg)
modalStyle =
    [style "display" "none"
    , style "position" "fixed"
    , style "z-index" "1"
    , style "left" "0"
    , style "top" "0"
    , style "overflow" "auto"
    ]

dialogContainerStyle : List (Attribute msg)
dialogContainerStyle =
    [ style "position" "absolute"
    , style "top" "20%"
    , style "bottom" "20%"
    , style "right" "20%"
    , style "left" "20%"
    , style "display" "flex"
    , style "align-items" "center"
    , style "justify-content" "center"
    -- , style "background-color" "rgba(33, 43, 54, 0.4)"
    , style "background-color" "black"
    ]

dialogContentStyle : List (Attribute msg)
dialogContentStyle =
    [ style "border-style" "solid"
    , style "border-radius" "3px"
    , style "border-color" "white"
    , style "background-color" "white"
    , style "height" "120px"
    , style "width" "440px"
    , style "display" "flex"
    , style "flex-direction" "column"
    , style "align-items" "center"
    , style "justify-content" "center"
    ]
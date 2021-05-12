module Pages.NewsPage exposing (..)

import Http
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import RemoteData exposing (WebData)
import Pages.Error exposing (buildErrorMessage)
import Model.News exposing (News, initialNews, newsDecoder)
import CSS.All exposing (imageStyle, leftStyle, rightStyle, rightContentStyle, leftContentStyle, searchInputStyle, modalStyle, searchBarStyle, dialogContainerStyle, pageStyle, combinedStyle, modalButtonStyle)

type alias Model =
    { news : WebData (List News)
    , searchTitleString : String
    , searchAuthorString : String
    , modalVisible : Bool
    , contentOfTheModal : News
    }

type Msg
    = NewsReceived (WebData (List News))
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
    div pageStyle
        [ div searchBarStyle 
            [ div [style "float" "left"] 
                [ input ([onInput SetSearchInput, placeholder "Title..." ] ++ searchInputStyle) []
                , text "Type title you are searching for"
                ]
            , div [style "width" "2%"] []
            , div [style "overflow" "hidden"]
                [ input ([onInput SetSearchAuthorInput, placeholder "Author..." ] ++ searchInputStyle) []
                , text "Type author you are searching for"
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
                    [ h3 [] [text model.contentOfTheModal.title]
                    , h4 [] [text model.contentOfTheModal.author]
                    , span [] [ text model.contentOfTheModal.content]
                    , br [] []
                    , br [] []
                    , br [] []
                    , text "Source: "
                    , span [] [ text model.contentOfTheModal.source.name]
                    , br [] []
                    , a [href model.contentOfTheModal.url] [text "Go to page"]              
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
           [ img (imageStyle ++ [src news.urlToImage] ) []
            , if (news.author == "") then text "No author info" else text news.author
            , br [] []
            , button ( modalButtonStyle ++ [ onClick (ShowModal news) ])
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
           [ img (imageStyle ++ [src news.urlToImage]) []
            , if (news.author == "") then text "No author info" else text news.author
            , br [] []
            , button ( modalButtonStyle ++ [ onClick (ShowModal news)])
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
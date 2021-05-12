module Pages.MyNewsPage exposing (..)
import Http
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onMouseEnter, onMouseLeave, onClick, onInput)
import RemoteData exposing (WebData)
import CSS.All exposing (buttonStyle, buttonStyleHovered, imageStyle, leftStyle, rightStyle, rightContentStyle, inputStyle, doubleInputStyle)
import Model.News exposing (initialNews, News, myNewsDecoder, oneNewsEncoder, oneNewsDecoder)
import Pages.Error exposing (buildErrorMessage)


type alias Model =
    { news : News
    , allNews : WebData (List News)
    , hovered : Bool
    , error : Maybe String
    }

type Msg
    = StoreTitle String
    | StoreAuthorName String
    | StoreDescription String
    | StoreUrl String
    | StoreUrlToImage String
    | StoreContent String
    | CreateNews
    | NewsCreated (Result Http.Error News)
    | Hover
    | MyNewsReceived (WebData (List News))

init :  WebData (List News) -> (Model, Cmd Msg)
init myNews =
    (initialModel myNews, fetchMyNews)


initialModel : WebData (List News) -> Model
initialModel myNews = 
    { news = initialNews
    , allNews = myNews
    , hovered = False
    , error = Nothing
    }

fetchMyNews : Cmd Msg
fetchMyNews =
    Http.get
        { url = "http://localhost:3000/news"
        , expect =
            myNewsDecoder
                |> Http.expectJson (RemoteData.fromResult >> MyNewsReceived)
        }

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        StoreTitle title ->
            let
                oldNews =
                    model.news
                updatedNews =
                    {oldNews | title = title}
            in
            ({model | news = updatedNews}, Cmd.none)

        StoreAuthorName name ->
            let
                oldNews =
                    model.news
                updatedNews =
                    {oldNews | author = name}
            in
            ({model | news = updatedNews}, Cmd.none)

        StoreDescription description ->
            let
                oldNews =
                    model.news
                updatedNews =
                    {oldNews | description = description}
            in
            ({model | news = updatedNews}, Cmd.none)

        StoreContent content ->
            let
                oldNews =
                    model.news
                updatedNews =
                    {oldNews | content = content}
            in
            ({model | news = updatedNews}, Cmd.none)
        
        StoreUrlToImage urlToImage ->
            let
                oldNews =
                    model.news
                updatedNews =
                    {oldNews | urlToImage = urlToImage}
            in
            ({model | news = updatedNews}, Cmd.none)
        
        StoreUrl url ->
            let
                oldNews =
                    model.news
                updatedNews =
                    {oldNews | url = url}
            in
            ({model | news = updatedNews}, Cmd.none)

        Hover ->
            let
                isHovered =
                    if model.hovered == True then False else True
            in
            ({model | hovered = isHovered}, Cmd.none)            

        CreateNews ->
            (model, createNew model.news)
        
        NewsCreated (Err error) ->
            ({model | error = Just (buildErrorMessage error)}, Cmd.none)

        NewsCreated (Ok news) ->
            ({model | news = news, error = Nothing}, Cmd.none)
        
        MyNewsReceived response ->
            ({model | allNews = response}, Cmd.none)


        
createNew : News -> Cmd Msg
createNew news =
    Http.post
        { url = "http://localhost:3000"
        , body = Http.jsonBody (oneNewsEncoder news)
        , expect = Http.expectJson NewsCreated oneNewsDecoder
        }        


view : Model -> Html Msg
view model =
    div []
        [div leftStyle
            [ h3 [] [text "Create new..."]
            , newNewsForm model
            ]
        , div rightStyle
            [ viewPostsOrError model
            ]
        ]
    

viewPostsOrError : Model -> Html Msg
viewPostsOrError model =
    case model.allNews of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            h3 [] [ text "Loading..." ]

        RemoteData.Success allNews ->
             div [] (List.map viewOne allNews)


        RemoteData.Failure httpError ->
            viewError (buildErrorMessage httpError)
        
viewOne : News -> Html Msg
viewOne news =
    div ([] ++ rightContentStyle)
        [ div ([] ++ leftStyle)
           [ img (imageStyle ++ [src news.urlToImage]) []
            , if (news.author == "") then text "No author info" else text news.author
            , br [] []
            , a [href news.url]
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
    

viewError : String -> Html Msg
viewError errorMessage =
    let
        errorHeading =
            "Couldn't fetch data at this time."
    in
    div []
        [ h3 [] [ text errorHeading ]
        , text ("Error: " ++ errorMessage)
        ]



newNewsForm : Model -> Html Msg
newNewsForm model =
    Html.form []
        [ div []
            [ label [for "authName"] [text "Author Name"]
            , br [] []
            , input (inputStyle ++ [ type_ "text", id "authName", onInput StoreAuthorName ]) []
            ]
        , div []
            [ label [for "title"] [text "Title"]
            , br [] []
            , input (doubleInputStyle ++ [ type_ "text", id "title", onInput StoreTitle ]) []
            ]
        , div []
            [ label [for "description"] [text "Description"]
            , br [] []
            , input (doubleInputStyle ++ [ type_ "text", id "description", onInput StoreDescription ]) []
            ]
        , div []
            [ label [for "url"] [text "Link to site"]
            , br [] []
            , input (inputStyle ++ [ type_ "text", id "url", onInput StoreUrl ]) []
            ]
        , div []
            [ label [for "urlToImage"] [text "Link to the image"]
            , br [] []
            , input (inputStyle ++ [ type_ "text", id "urlToImage", onInput StoreUrlToImage ]) []
            ]
        , div []
            [ label [for "content"] [text "Content"]
            , br [] []
            , input (doubleInputStyle ++ [ type_ "text", id "content", onInput StoreContent ]) []
            ]
        , div []
            [ button ([ type_ "submit", onClick CreateNews, onMouseEnter Hover, onMouseLeave Hover ] ++ if model.hovered == False then buttonStyle else buttonStyleHovered) 
                [ text "Create" ]
            ]
        ]



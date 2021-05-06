module Main exposing (..)

import Browser
import Html exposing (Html, text)
import Route exposing (Route)
import Url exposing (Url)
import Browser.Navigation as Nav
import Browser exposing (Document)
import Html exposing (h3)

import Pages.HomePage as HomePage
import Pages.NewsPage as NewsPage
import Model.News exposing (..)
import Browser exposing (UrlRequest)
import Json.Decode as Decode exposing (decodeValue, decodeString, Value)
import Model.News exposing (News)
import Http
import RemoteData exposing (WebData)

---- MODEL ----


type alias Model =
    { route: Route
    , page : Page
    , navKey : Nav.Key
    }

type Page
    = NotFoundPage
    | HomePage
    | NewsPage NewsPage.Model


init : Value -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    let
        model =
            { route = Route.parseUrl url
            , page = NotFoundPage
            , navKey = navKey
            }     
        
        news =
            case decodeValue Decode.string flags of
                Ok newsJson ->
                    decodeStoredNews newsJson
                Err _ ->
                    Http.BadBody "Flags must be either string or null"
                        |> RemoteData.Failure
    in    
    initCurrentPage news ( model, Cmd.none )  

decodeStoredNews : String -> WebData (List News)
decodeStoredNews newsJson =
    case decodeString newsDecoder newsJson of
        Ok news ->
            RemoteData.succeed news

        Err _ ->
            RemoteData.Loading


initCurrentPage : WebData (List News) -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
initCurrentPage  news ( model, existingCmds ) =
        let
            ( currentPage, mappedPageCmds ) =
                case model.route of
                    Route.NotFound ->
                        ( NotFoundPage, Cmd.none )
                    
                    Route.HomePage ->
                        (HomePage, Cmd.none)
                    
                    Route.NewsPage ->
                        let
                            (pageModel, pageCmds) =
                                NewsPage.init news
                        in
                        ( NewsPage pageModel, Cmd.map NewsPageMsg pageCmds )
        in

    ( { model | page = currentPage }
    , Cmd.batch [ existingCmds, mappedPageCmds ]
    )


---- UPDATE ----


type Msg
    = LinkClicked UrlRequest
    | UrlChanged Url
    | NewsPageMsg NewsPage.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case (msg,  model.page ) of
        ( NewsPageMsg subMsg, NewsPage pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    NewsPage.update subMsg pageModel
            in
            ( { model | page = NewsPage updatedPageModel }
            , Cmd.map NewsPageMsg updatedCmd
            )

        ( LinkClicked urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl model.navKey (Url.toString url)
                    )

                Browser.External url ->
                    ( model
                    , Nav.load url
                    )

        ( UrlChanged url, _ ) ->
            let
                newRoute =
                    Route.parseUrl url
            in
            ( { model | route = newRoute }, Cmd.none )
                |> initCurrentPage RemoteData.Loading

        ( _, _ ) ->
            ( model, Cmd.none )



---- VIEW ----


view : Model -> Document Msg
view model =
    {title = "News App"
    , body = [currentView model]
    }

currentView : Model -> Html Msg
currentView model =
    case model.page of
        NotFoundPage ->
            notFoundView

        HomePage ->
            HomePage.startUpPageView

        NewsPage pageModel ->
            NewsPage.view pageModel
                |> Html.map NewsPageMsg

notFoundView : Html msg
notFoundView =
    h3 [] [ text "Oops! The page you requested does not exist!" ]


---- PROGRAM ----


main : Program Value Model Msg
main =
    Browser.application
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }

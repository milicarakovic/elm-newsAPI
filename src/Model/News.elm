module Model.News exposing (..)

import Json.Decode as Decode exposing (Decoder, list, string)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode

type alias Source =
    { id: String
    , name : String
    }

type alias News =
    { source: Source
    , author : String
    , title : String
    , description : String
    , url : String
    , urlToImage : String
    , content : String
    }

initialSource : Source
initialSource =
    { id = ""
    , name = ""
    }


initialNews : News 
initialNews = 
    { source = initialSource
    , author  = ""
    , title  = ""
    , description  = ""
    , url  = ""
    , urlToImage = ""
    , content  = ""
    }

newsDecoder : Decoder (List News)
newsDecoder =
    Decode.succeed identity
        |> required "articles" (list oneNewsDecoder)

myNewsDecoder : Decoder (List News)
myNewsDecoder =
    list oneNewsDecoder

oneNewsDecoder : Decoder News
oneNewsDecoder =
    Decode.succeed News
        |> required "source" sourceDecoder
        |> optional "author" string ""
        |> optional "title" string ""
        |> optional "description" string ""
        |> optional "url" string ""
        |> optional "urlToImage" string "http://cdn.onlinewebfonts.com/svg/img_148071.png"
        |> optional "content" string ""

sourceDecoder : Decoder Source
sourceDecoder =
    Decode.succeed Source
        |> optional "id" string ""
        |> required "name" string

oneNewsEncoder : News -> Encode.Value
oneNewsEncoder news =
    Encode.object
        [ ( "source", sourceEncoder news.source)
        , ( "author", Encode.string news.author)
        , ( "title", Encode.string news.title)
        , ( "description", Encode.string news.description)
        , ( "url", Encode.string news.url)
        , ( "urlToImage", Encode.string news.urlToImage)
        , ( "content", Encode.string news.content)
        ]

sourceEncoder : Source -> Encode.Value
sourceEncoder source =
    Encode.object
        [ ( "id", Encode.string source.id)
        , ( "name", Encode.string source.name)
        ]
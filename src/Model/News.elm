module Model.News exposing (..)

import Json.Decode as Decode exposing (Decoder, int, list, string)
import Json.Decode.Pipeline exposing (optionalAt, required, requiredAt)
import Json.Encode as Encode
import Json.Decode.Pipeline exposing (optional)
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
    -- Decode.map2 Source
    --     (Decode.field "id" Decode.string (null ""))
    --     (Decode.field "name" Decode.string)
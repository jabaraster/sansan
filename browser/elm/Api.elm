module Api exposing (getCardCount)

import Http
import Json.Decode as JD

type alias SansanApiKey = String

type alias Condition =
  { updatedFrom : String
  , updatedTo : String
  }

getCardCount: SansanApiKey -> Condition -> (Result Http.Error Int -> msg) -> Cmd msg
getCardCount key cond operation =
    get
      { url = "https://api.sansan.jabara.info/card/count?updatedFrom=" ++ cond.updatedFrom ++ "&updatedTo=" ++ cond.updatedTo
      , headers = [ Http.header "X-Sansan-Api-Key" key ]
      , expect = Http.expectJson operation <| JD.field "count" JD.int
      }

get : { url: String, headers: List Http.Header, expect: Http.Expect msg} -> Cmd msg
get {url, headers, expect } =
    Http.riskyRequest
      { url = url
      , method = "GET"
      , body = Http.emptyBody
      , headers = headers
      , timeout = Nothing
      , tracker = Nothing
      , expect = expect
      }
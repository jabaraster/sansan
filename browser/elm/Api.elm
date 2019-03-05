module Api exposing (getCards)

import Http

type alias SansanApiKey = String

getCards : SansanApiKey -> (Result Http.Error String -> msg) -> Cmd msg
getCards key operation =
    get
      { url = "https://api.sansan.jabara.infom/card/index"
      , headers = [ Http.header "X-Sansan-Api-Key" key ]
      , expect = Http.expectString operation 
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
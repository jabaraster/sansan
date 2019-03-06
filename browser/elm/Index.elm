module Index exposing (Model, Msg(..), errorText, init, main, subscriptions, update, view)

import Api
import Browser exposing (Document)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http


main : Platform.Program () Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { sansanApiKey : String
    , from : String
    , to : String
    , cardCount : Maybe Int
    , errorText : Maybe String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { sansanApiKey = ""
      , from = "2019-04-01"
      , to = "2020-04-01"
      , cardCount = Nothing
      , errorText = Nothing
      }
    , Cmd.none
    )


type Msg
    = SansanApiKeyChange String
    | GetCardCount
    | CardCountChange Int
    | FromChange String
    | ToChange String
    | ErrorOccurred Http.Error


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SansanApiKeyChange v ->
            ( { model | sansanApiKey = v }, Cmd.none )

        FromChange s ->
            ( { model | from = s }, Cmd.none )

        ToChange s ->
            ( { model | to = s }, Cmd.none )

        GetCardCount ->
            ( model
            , Api.getCardCount model.sansanApiKey { updatedFrom = model.from, updatedTo = model.to }
                (\res ->
                    case res of
                        Ok c ->
                            CardCountChange c

                        Err err ->
                            ErrorOccurred err
                )
            )

        CardCountChange c ->
            ( { model | cardCount = Just c }, Cmd.none )

        ErrorOccurred err ->
            ( { model | errorText = Just <| errorText err }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Document Msg
view model =
    { title = "Sansan名刺カウンタ"
    , body =
        [ h1 [] [ span [] [ text "Sansan名刺カウンタ" ] ]
        , div [ class "container" ]
            [ p [] [ text "SansanからAPIキーを発行して貼り付けて下さい。" ]
            , input
                [ class "form-control"
                , placeholder "SansanのAPIキー"
                , onInput SansanApiKeyChange
                ]
                []
            , input [ type_ "date", class "form-control updated-from", value model.from, onInput FromChange ] []
            , span [] [ text "〜" ]
            , input [ type_ "date", class "form-control updated-to", value model.to, onInput ToChange ] []
            , hr_
            , button [ class "btn btn-primary", onClick GetCardCount ] [ text "名刺の枚数を取得" ]
            , hr_
            , label [] [ text "名刺の数" ]
            , case model.cardCount of
                Nothing ->
                    p [] [ text "まだ情報を取得していません" ]

                Just c ->
                    input [ value <| String.fromInt c ] []
            , hr_
            , label [] [ text "エラー状況" ]
            , p [] [ text <| Maybe.withDefault "エラーはありません" model.errorText ]
            ]
        ]
    }


hr_ : Html msg
hr_ =
    hr [] []



-- UTILITY


errorText : Http.Error -> String
errorText err =
    case err of
        Http.BadUrl url ->
            "Fail -> Bad URL ->" ++ url

        Http.Timeout ->
            "Fail -> Timeout."

        Http.NetworkError ->
            "Fail -> Network error."

        Http.BadStatus s ->
            "Fail -> Bad status -> " ++ String.fromInt s

        Http.BadBody b ->
            "Fail -> BadBody -> " ++ b

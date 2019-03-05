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
    , cardsJson : String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { sansanApiKey = "", cardsJson = "" }, Cmd.none )


type Msg
    = SansanApiKeyChange String
    | GetCards
    | CardsJsonChange String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SansanApiKeyChange v ->
            ( { model | sansanApiKey = v }, Cmd.none )

        GetCards ->
            ( model
            , Api.getCards model.sansanApiKey
                (\res ->
                    case res of
                        Ok s ->
                            CardsJsonChange s

                        Err err ->
                            CardsJsonChange <| errorText err
                )
            )

        CardsJsonChange j ->
            ( { model | cardsJson = j }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Document Msg
view model =
    { title = "Sansan名刺カウンタ"
    , body =
        [ h1 [] [ span [] [ text "Sansan名刺カウンタ" ] ]
        , p [] [ text "SansanからAPIキーを発行して貼り付けて下さい。" ]
        , div []
            [ input [ class "form-control", onInput SansanApiKeyChange ] []
            , button [ onClick GetCards ] [ text "名刺情報取得" ]
            ]
        ]
    }



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

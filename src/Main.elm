module Main exposing (..)

import Auth
import Html exposing (..)
import Html.Attributes exposing (class, defaultValue, src)
import Html.Events exposing (..)
import Http
import Json.Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (..)


---- MODEL ----


type alias Model =
    { query : String
    , results : List SearchResult
    , selection : String
    , photo : String
    , errorMessage : Maybe String
    }


type alias SearchResult =
    { name : String
    }



---- UPDATE ----


type Msg
    = Search
    | SetQuery String
    | MakeSelection String
    | HandleSearchResponse (Result Http.Error (List SearchResult))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Search ->
            ( model, getSearchResult model.query )

        SetQuery query ->
            ( { model | query = query }, Cmd.none )

        MakeSelection selection ->
            let
                newResults =
                    model.results
                        |> List.filter (\{ name } -> name == selection)

                newModel =
                    { model
                        | selection = selection
                        , results = newResults
                        , photo =
                            "https://source.unsplash.com/1200x800/?"
                                ++ selection
                    }
            in
            ( newModel, Cmd.none )

        HandleSearchResponse result ->
            case result of
                Ok results ->
                    ( { model | results = results }, Cmd.none )

                Err error ->
                    let
                        errorMessage =
                            case error of
                                Http.BadUrl _ ->
                                    "There is something wrong with the url"

                                Http.Timeout ->
                                    "Timeout error. Please try again"

                                Http.NetworkError ->
                                    "Network Error has occured"

                                Http.BadStatus _ ->
                                    "I got a Bad Status error"

                                Http.BadPayload _ _ ->
                                    "I got a Bad Payload error"
                    in
                    ( { model | errorMessage = Just errorMessage }, Cmd.none )



---- VIEW ----


initialModel : Model
initialModel =
    { query = ""
    , results = []
    , selection = ""
    , photo = ""
    , errorMessage = Nothing
    }


view : Model -> Html Msg
view model =
    div [ class "content" ]
        [ header []
            [ h1 [] [ text "Let's travel virtually!" ]
            ]
        , p []
            [ text "Where do you wanna go?" ]
        , input [ onInput SetQuery, defaultValue model.query ] []
        , button [ onClick Search ] [ text "Go" ]
        , ul [] (List.map viewSearchResult model.results)
        , viewErrorMessage model.errorMessage
        , viewImage model.photo
        ]


viewErrorMessage : Maybe String -> Html Msg
viewErrorMessage errorMessage =
    case errorMessage of
        Just message ->
            div [ class "error" ] [ text message ]

        Nothing ->
            text ""


viewSearchResult : SearchResult -> Html Msg
viewSearchResult result =
    li []
        [ text result.name
        , button [ onClick (MakeSelection result.name) ]
            [ text "Select" ]
        ]


viewImage : String -> Html Msg
viewImage destination =
    case destination of
        selection ->
            div [] [ img [ src destination ] [] ]



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = ( initialModel, Cmd.none )
        , update = update
        , subscriptions = always Sub.none
        }


getSearchResult : String -> Cmd Msg
getSearchResult query =
    let
        url =
            "https://maps.googleapis.com/maps/api/place/autocomplete/json?input="
                ++ query
                ++ "&types=geocode&key="
                ++ Auth.token

        request =
            Http.get url decodeSearchResult
    in
    Http.send HandleSearchResponse <|
        request


decodeSearchResult : Decoder (List SearchResult)
decodeSearchResult =
    Json.Decode.at [ "predictions" ] (Json.Decode.list searchResultDecoder)


searchResultDecoder : Decoder SearchResult
searchResultDecoder =
    decode SearchResult
        |> required "description" Json.Decode.string

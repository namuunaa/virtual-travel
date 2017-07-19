module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, defaultValue, src)
import Html.Events exposing (..)


---- MODEL ----


type alias Model =
    { query : String
    , result : List SearchResult
    }


type alias SearchResult =
    { city : String
    , country : String
    }



---- UPDATE ----


type Msg
    = Search
    | SetQuery String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Search ->
            ( model, Cmd.none )

        SetQuery query ->
            ( { model | query = query }, Cmd.none )



---- VIEW ----


initialModel : Model
initialModel =
    { query = ""
    , result = []
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
        , button [] [ text "Go" ]
        ]



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = ( initialModel, Cmd.none )
        , update = update
        , subscriptions = always Sub.none
        }

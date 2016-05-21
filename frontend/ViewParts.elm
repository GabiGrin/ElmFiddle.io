module ViewParts where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Signal exposing (..)
import Model exposing (..)


type Action
  = UpdateName String

appFooter : Address Action -> Model -> Html
appFooter address model =
  footer
    []
    [ div
        []
        [ span
            []
            [ text "Made by Gabriel Grinberg, " ]
        , em
            []
            [ text "(almost) " ]
        , span
            []
            [ text "entirely in Elm!" ]
        ]
    , img
        [ src "/assets/github.png" ]
        []
    ]


appHeader : Address Action -> Model -> Html
appHeader address model =
  header
    []
    [ span
        [ id "logo" ]
        [ span
            [ class "elm" ]
            [ text "Elm" ]
        , span
            [ class "fiddle" ]
            [ text "Fiddle." ]
        , span
            [ class "i" ]
            [ text "i" ]
        , span
            [ class "o" ]
            [ text "o" ]
        ]
    , div
        [ id "snippet-container" ]
        [ input
            [ id
                "snippet-name"
            , class (if model.focusName then "blink" else "")
            , value
                model.name
            , on "input" targetValue (Signal.message address << UpdateName)
            , placeholder
                "New Snippet"
            , maxlength 20
            ]
            []
        ]
    , div
        [ id "dummy" ]
        []
    ]

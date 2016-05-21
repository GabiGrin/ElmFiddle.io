module ResultView where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Examples.HelloWorld
import Examples.Snake
import Examples.TodoList
import WebAPI.Date
import String

type Model
  = FirstUse
  | CompilationResult (Result String String)
  | Loading

type Action
  = LoadExample String


init: Model
init = FirstUse


firstUse: Signal.Address Action -> Html
firstUse address =
  div
    [ id "first-use" ]
    [ p
        [ class "title" ]
        [ text "Enter some awesome Elm code" ]
    , p
        [ class "sub-title" ]
        [ text "Or.." ]
    , p
        [ class "sub-title" ]
        [ text "Load one of these cool examples:" ]
    , ul
        [ class "examples" ]
        [ li
            []
            [ a
                [ onClick address (LoadExample Examples.HelloWorld.code)]
                [ text "Hello world" ]
            ]
        , li
            []
            [ a
                [ onClick address (LoadExample Examples.TodoList.code)]
                [ text "To-do list" ]
            ]
        -- , li
        --     []
        --     [ a
        --         [ onClick address (LoadExample Examples.Snake.code)]
        --         [ text "Snake game" ]
        --     ]
        ]
    ]


resultFrame : String -> Html
resultFrame code =
  iframe [ id "compiled-code", srcdoc code ] []


errorView : String -> Html
errorView err =
  div
    [ id "error-container" ]
    [ p
        [ class "error-title" ]
        [ text "Oopsie, there's something wront with your code.\nPlease fix the issues below and try again." ]
    , p
        [ class "error-content" ]
        [ text err ]
    ]


view : Signal.Address Action -> Model -> Html
view address model =
  case model of
    FirstUse ->
      div [] [ firstUse address ]

    Loading ->
      let
        -- loadingTicket = 3
        dots = String.repeat 2 "."
      in
        div
          [ class "loading-container" ]
          [ div [ class "loading" ] [ text ("Compiling" ++ dots) ]
          ]

    CompilationResult res ->
      case res of
        Ok code -> resultFrame code
        Err err -> errorView err

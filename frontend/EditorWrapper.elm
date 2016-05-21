module EditorWrapper (..) where

import Editor
import Router
import Signal
import Effects exposing (Effects)
import Html exposing (..)
import Html.Attributes exposing (..)
import Task exposing (..)
import WebAPI.Location exposing (location)
import Maybe exposing (..)
import String
import Api
import Time


type State
  = Loading
  | Ready
  | NotFound


type alias Model =
  { state : State
  , editor : Editor.Model
  }


type Action
  = EditorAction Editor.Action
  | LoadCode String


initModel : Model
initModel =
  { state = Loading
  , editor = Editor.initModel
  }


getPath : Task x String
getPath =
  Task.map (\l -> l.pathname) location


getIdFromUrl : Task x (Maybe String)
getIdFromUrl =
  let
    getId =
      (\p ->
        if (String.length p == 1) then
          Nothing
        else
          (Just (String.dropLeft 6 p))
      )
  in
    getPath
      |> Task.map getId
      |> (flip Task.onError) (\v -> Task.succeed Nothing)


getCodeFromIdInUrl : Effects Action
getCodeFromIdInUrl =
  getIdFromUrl
    |> (flip Task.andThen)
        (\maybeId ->
          case maybeId of
            Just id ->
              Api.getCode id
                `Task.onError` (\str -> Task.succeed str)
                |> Task.map (\code -> LoadCode code)

            Nothing ->
              let
                im =
                  Editor.initModel
              in
                Task.succeed im.code
                  |> Task.map LoadCode
        )
    |> Effects.task


init : ( Model, Effects Action )
init =
  ( initModel
    -- , Effects.map EditorAction fx
    --, getCode "cim7osup20000xa083lxem4pu"
  , getCodeFromIdInUrl
  )


update : Action -> Model -> ( Model, Effects Action )
update action model =
  case action of
    EditorAction act ->
      let
        ( editor, fx ) =
          Editor.update act model.editor
      in
        ( { model | editor = editor }
        , Effects.map EditorAction fx
        )

    LoadCode code ->
      let
        ( editor, fx ) =
          Editor.update (Editor.UpdateCode code) model.editor
      in
        ( { model | editor = editor, state = Ready }
        , Effects.map EditorAction fx
        )


appFooter : Html
appFooter =
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
        [ src "assets/github.png" ]
        []
    ]


appHeader : Html
appHeader =
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
            , value
                ""
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


view : Signal.Address Action -> Model -> Html
view address model =
  case model.state of
    Ready ->
      div [ id "main" ] [ appHeader, Editor.view (Signal.forwardTo address EditorAction) model.editor, appFooter ]

    _ ->
      div [] [ text "Loading" ]


everyHalfSecond = Time.every (Time.millisecond * 500)

loadingTicker = Signal.map (\a -> EditorAction Editor.Tick) everyHalfSecond

inputs = [loadingTicker]

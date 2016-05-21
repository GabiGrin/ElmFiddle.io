module App (..) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Effects exposing (..)
import Api
import Task exposing (..)
import ViewParts exposing (..)
import Model exposing (..)
import WebAPI.Location exposing (location)
import ResultView
import CodeView
import Debug
import SaveStatusView
import String
import Snippet exposing (Snippet, errorSnippet)

type Action
  = LoadCode String
  | LoadSnippet Snippet
  | Compile
  | Save
  | UpdateName String
  | UpdateResult ResultView.Model
  | UpdateSaveStatus SaveStatus
  | ResultViewAction ResultView.Action
  | CodeViewAction CodeView.Action
  | ViewPartsAction ViewParts.Action
  | SaveStatusViewAction SaveStatusView.Action
  | NoOp

init : ( Model, Effects Action )
init =
  ( initModel, loadCodeIfViewMode )


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

loadCodeIfViewMode : Effects Action
loadCodeIfViewMode =
  getIdFromUrl
    |> (flip Task.andThen)
        (\maybeId ->
          case maybeId of
            Just id ->
              Api.getCode id
                |> (flip Task.onError) (\str -> Task.succeed (errorSnippet str))
                |> Task.map (\code -> LoadSnippet code)

            Nothing ->
                Task.succeed NoOp
        )
    |> Effects.task


compileCode : String -> Effects Action
compileCode code =
  Api.compileCode code
    |> Task.toResult
    |> Task.map (\r -> UpdateResult (ResultView.CompilationResult r))
    |> Effects.task


saveCode : ( String, String ) -> Effects Action
saveCode ( name, code ) =
  Api.saveCode name code
    |> Task.toResult
    |> Task.map (\r -> UpdateSaveStatus (SavedResult r))
    |> Effects.task


update : Action -> Model -> ( Model, Effects Action )
update action model =
  case action of
    LoadCode code ->
      ( { model | code = code, codeState = Dirty }, Effects.none )
    LoadSnippet snippet ->
      ({ model | code = snippet.code, name = snippet.name}, compileCode snippet.code)
    Compile ->
      ( { model | result = ResultView.Loading }, compileCode model.code )

    Save ->
      let
        n =
          Debug.log "name" model
      in
        if model.name == "" then
          ( { model | focusName = True }, Effects.none )
        else
          ( model, saveCode ( model.name, model.code ) )

    UpdateName str ->
      ( { model | name = str, focusName = False }, Effects.none )

    UpdateResult res ->
      let
        newState =
          case res of
            ResultView.CompilationResult (Ok cr) ->
              Pristine

            _ ->
              model.codeState
      in
        ( { model | result = res, codeState = newState }, Effects.none )

    UpdateSaveStatus status ->
      ( { model | saveStatus = status }, Effects.none )

    ResultViewAction act ->
      case act of
        ResultView.LoadExample str ->
          ( { model | code = str }, Effects.none )

    CodeViewAction act ->
      case act of
        CodeView.CodeChange str ->
          let
            newState =
              if model.code == str then
                model.codeState
              else
                Dirty
          in
            ( { model | code = str, codeState = newState }, Effects.none )

    ViewPartsAction act ->
      case act of
        ViewParts.UpdateName str ->
          ( { model | name = str }, Effects.none )
    SaveStatusViewAction act ->
      case act of
        SaveStatusView.NewFromCurrentCode ->
          ({ model | saveStatus = Unsaved, name = "", codeState = Dirty}, Effects.none)
    NoOp ->
      (model, Effects.none)


buttonsView : Signal.Address Action -> Model -> Html
buttonsView address model =
  div
    [ id "buttons" ]
    []


saveButton : Signal.Address Action -> Model -> Html
saveButton address model =
  let
    hidden =
      model.codeState == Dirty || model.saveStatus /= Unsaved

    disabled =
      False
  in
    button
      [ onClick address Save
      , class
          ("btn save"
            ++ if hidden then
                " hidden"
               else
                ""
          )
      ]
      [ text "Save" ]


runButton : Signal.Address Action -> Model -> Html
runButton address model =
  let
    hidden =
      case model.result of
        ResultView.Loading ->
          True

        _ ->
          model.codeState == Pristine

    disabled =
      False
  in
    button
      [ onClick address Compile
      , class
          ("btn run"
            ++ if hidden then
                " hidden"
               else
                ""
          )
      ]
      [ text "Run" ]


view : Signal.Address Action -> Model -> Html
view address model =
  div
    [ id "main" ]
    [ appHeader (Signal.forwardTo address ViewPartsAction) model
    , SaveStatusView.view (Signal.forwardTo address SaveStatusViewAction) model.saveStatus
    , buttonsView address model
    , div
        [ class "main-container" ]
        [ div
            [ class "cm-container" ]
            [ runButton address model
            , CodeView.view (Signal.forwardTo address CodeViewAction) model.code
            ]
        , div
            [ class "result-container" ]
            [ saveButton address model
            , ResultView.view (Signal.forwardTo address ResultViewAction) model.result
            ]
        ]
    , appFooter (Signal.forwardTo address ViewPartsAction) model
    ]

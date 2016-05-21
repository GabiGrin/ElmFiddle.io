module Editor (..) where

import Effects exposing (Effects, Never)
import Html exposing (..)
import Html.Attributes exposing (style, property, srcdoc, class, id, disabled)
import Json.Encode exposing (string)
import Json.Decode as Decode
import Html.Events exposing (onClick)
import Http
import Json.Decode as Json
import Task
import WebAPI.Location as Location
import CodeMirror
import Api
import String
import History

import Examples.Snake
import Examples.HelloWorld
import Examples.TodoList

type SnippetId
  = Id String
  | None


type Action
  = Compile
  | Result CompileResult
  | UpdateCode String
  | UpdateSaveStatus SaveStatus
  | SaveCode
  | Tick
  | NoOp
  | LoadExample String

type SaveStatus
  = Unsaved
  | Saved CodeId
  | Saving
  | ErrorSaving String


type alias CodeId =
  String


type AppState
  = Pristine
  | Dirty
  | CodeSaved


type CompileResult
  = Success String
  | Error String
  | Loading
  | FirstUse


type alias Model =
  { state : AppState
  , compilationResult : CompileResult
  , code : String
  , name : String
  , id : SnippetId
  , saveStatus : SaveStatus
  , loadingTicker: Int
  }


initModel : Model
initModel =
  { state = Dirty
  , compilationResult = FirstUse
  , code = """
import Html exposing (text)

main =
  text "Hello, World!"
  """
  , name = "New Snippet"
  , id = None
  , saveStatus = Unsaved
  , loadingTicker = 0
  }


codeMirrorConfig : CodeMirror.CmConfig
codeMirrorConfig =
  { mode = "elm"
  , theme = "elegant"
  , lineNumbers = True
  , lineWrapping = False
  , height = "1000px"
  }


init : ( Model, Effects Action )
init =
  ( initModel, Effects.none )


update : Action -> Model -> ( Model, Effects Action )
update action model =
  case action of
    Compile ->
      ( { model | compilationResult = Loading }, compileCode model.code )

    UpdateCode code ->
      let
        newState = if code == model.code then model.state else Dirty
      in
        ( { model | code = code, state = newState }
        , Effects.none
        )

    Result compileResult ->
      let
        newState = case compileResult of
          Success _ -> Pristine
          _ -> Dirty
      in
        ( { model | compilationResult = compileResult, state = newState }
        , Effects.none
        )

    UpdateSaveStatus status ->
      let
        restartStatus = Task.sleep 5000
        |> Task.map (\_ ->  (UpdateSaveStatus Unsaved))
        |> Effects.task
        (effects, state) = case status of
          Saved id -> (changePath id, CodeSaved)
          _ -> (Effects.none, model.state)
      in
        ( { model | saveStatus = status, state = state }
        , Effects.batch [effects, restartStatus]
        )

    SaveCode ->
      ( { model | saveStatus = Saving }
      , saveCode model.code
      )

    LoadExample code ->
      ( {model | state = Dirty, code = Debug.log "code" code}
      , Effects.none --compileCode code
      )

    NoOp ->
      ( model, Effects.none )

    Tick ->
      let
        ticker = if (model.compilationResult == Loading) then  model.loadingTicker + 1 else 0
      in
       ( {model | loadingTicker = ticker}, Effects.none)


changePath : String -> Effects Action
changePath id =
  History.setPath ("/view/" ++ id)
  |> Task.map (\_ -> NoOp)
  |> (flip Task.onError) (\e -> Task.succeed NoOp)
  |> Effects.task

saveCode : String -> Effects Action
saveCode code =
  Api.saveCode code
    |> Task.map (\key -> UpdateSaveStatus (Saved key))
    |> (flip Task.onError) (\v -> UpdateSaveStatus (ErrorSaving v) |> Task.succeed)
    |> Effects.task


compileCode : String -> Effects Action
compileCode code =
  Api.compileCode code
    |> Task.map (\v -> Result (Success v))
    |> (flip Task.onError) (\err -> Result (Error err) |> Task.succeed)
    |> Effects.task


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
        , li
            []
            [ a
                [ onClick address (LoadExample Examples.Snake.code)]
                [ text "Snake game" ]
            ]
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


resultView : Signal.Address Action -> Model -> Html
resultView address model =
  case model.compilationResult of
    FirstUse ->
      div [] [ firstUse address ]

    Loading ->
      let
        dots = String.repeat ( 2 + model.loadingTicker % 4) "."
      in
        div
          [ class "loading-container" ]
          [ div [ class "loading" ] [ text ("Compiling" ++ dots) ]
          ]

    Success code ->
      resultFrame code

    Error err ->
      errorView err


codeSaveStatusView : SaveStatus -> Html
codeSaveStatusView status =
  let
    errStr =
      case status of
        Unsaved ->
          text "Unsaved"

        Saved id ->
          a [ Html.Attributes.href ("/view" ++ id) ] [ text ("Saved! " ++ id) ]

        Saving ->
          text "Saving.."

        ErrorSaving err ->
          div [ style [ ( "color", "red" ) ] ] [ text ("Error saving! " ++ err) ]
  in
    errStr


codeMirror msgCreator code =
  CodeMirror.codeMirror codeMirrorConfig msgCreator code


view : Signal.Address Action -> Model -> Html
view address model =
  let
    baseClass = "btn"
    saveClass = baseClass ++ (if model.state == Dirty then " hidden" else "")
    runClass = baseClass ++ (if model.state == Pristine then " hidden" else "")
    (saveText, saveDisabled) = case model.saveStatus of
        Saved id -> ("Saved!", True)
        Saving -> ("Saving..", True)
        ErrorSaving err -> (fst (Debug.log "error" ("Error saving :(", err)), True)
        _ -> ("Save", False)
  in
    div
      [ class "main-container" ]
      [ div
          [ class "cm-container" ]
          [ codeMirror (Signal.message address << (\c -> UpdateCode c)) model.code
          , button [ onClick address Compile, class ("run " ++ runClass) ] [ text "Run" ]
          ]
      , div
          [ class "result-container" ]
          [ resultView address model
          , button [ onClick address SaveCode, class saveClass, disabled saveDisabled] [ text saveText ]
          ]
        -- , codeSaveStatusView model.saveStatus
      ]

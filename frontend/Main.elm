
import Effects exposing (Never)
import StartApp
import Task

import Html exposing (..)
import Html.Attributes exposing (..)
-- import Graphics.Element exposing (..)
-- import Graphics.Collage exposing (..)
import Json.Encode exposing (string)
-- import EditorWrapper exposing (view, update, init, inputs)
-- showCode: Signal String
-- showCode = Signal.foldp (\n o -> n) state codeSignal

import App exposing (view, update, init)

import CodeMirror

app =
  StartApp.start
    { init = init
    , update = update
    , view = view
    , inputs = [] --inputs
    }

main =
  app.html


port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks

module CodeView where

import CodeMirror
import Html exposing (..)
import Html.Attributes exposing (..)
import Signal exposing (..)

type Action = CodeChange String

codeMirror msgCreator code =
  CodeMirror.codeMirror codeMirrorConfig msgCreator code

codeMirrorConfig : CodeMirror.CmConfig
codeMirrorConfig =
  { mode = "elm"
  , theme = "elegant"
  , lineNumbers = True
  , lineWrapping = True
  , height = "1000px"
  }

view: Address Action -> String -> Html
view address code =
  codeMirror (Signal.message address << (\c -> CodeChange c)) code

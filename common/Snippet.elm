module Snippet where

import Json.Decode as JD exposing ((:=))
import Json.Encode as JE

type alias Snippet =
  { name: String
  , code: String
  , timestamp: Int
  }

type alias SnippetWithId =
  { snippet: Snippet
  , id: String
  }

-- temp!
errorSnippet: String -> Snippet
errorSnippet err =
  Snippet "Error" err 0

snippetDecoder: JD.Decoder Snippet
snippetDecoder =
     JD.object3 Snippet
      ("name" := JD.string)
      ("code" := JD.string)
      ("timestamp" := JD.int)

snippetEncoder: Snippet -> JE.Value
snippetEncoder snippet =
  JE.object [
    ("name", JE.string snippet.name)
    , ("code", JE.string snippet.code)
    , ("timestamp", JE.int snippet.timestamp)
  ]

snippetWithIdEncoder: SnippetWithId -> JE.Value
snippetWithIdEncoder snippetWithId =
  JE.object [
    ("key", JE.string snippetWithId.id)
    , ("value", snippetEncoder snippetWithId.snippet)
  ]

snippetWithIdDecoder: JD.Decoder SnippetWithId
snippetWithIdDecoder =
  JD.object2 SnippetWithId
    ("value" := snippetDecoder)
    ("key" := JD.string)

snippetWithIdListDecoder: JD.Decoder (List SnippetWithId)
snippetWithIdListDecoder =
  JD.list snippetWithIdDecoder

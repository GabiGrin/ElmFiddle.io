module Api (getCode, saveCode, compileCode) where

import Http exposing (..)
import Json.Decode exposing (..)
import Json.Encode as JE
import Task exposing (mapError, Task)
-- import Json.Decode as Decode
import Http.Extra as HE
import Snippet exposing (Snippet, snippetDecoder)

errorStr: Http.Error -> String
errorStr err =
    case err of
      Http.UnexpectedPayload str -> str
      Http.BadResponse num str -> str
      _ -> "Unexpected error"

codeDecoder: Decoder Snippet
codeDecoder =
     snippetDecoder

getCode: String -> Task String Snippet
getCode id =
    get codeDecoder ("/api/code/" ++ id)
    |> mapError errorStr


saveCode:  String -> String -> Task String String
saveCode name code =
          let
            data = JE.encode 0 (JE.object
                [ ("name", JE.string name)
                , ("code", JE.string code)
                ])
          in
            Http.post (Json.Decode.string) "/api/code" (Http.string data)
            |> Task.mapError errorStr


heErrStr: HE.Error String -> String
heErrStr err =
  case err of
    HE.UnexpectedPayload str -> str
    HE.NetworkError -> "Network error"
    HE.Timeout -> "Timeout"
    HE.BadResponse res ->
      res.data

compileCode: String -> Task String String
compileCode code =
  HE.post "/api/compile"
    |> HE.withBody (Http.string code)
    |> HE.send HE.stringReader HE.stringReader
    |> Task.mapError heErrStr
    |> Task.map (\r -> r.data)

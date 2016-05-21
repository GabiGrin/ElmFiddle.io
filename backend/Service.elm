module Service (saveCode, compileCode, getCode, getAllSnippets) where

import LevelUp exposing (Db, openOrCreate, put, log, get, getAll, now)
import Uuid as Uuid
import Cuid
import Task exposing (..)
import Json.Decode as JD exposing (..)
import Json.Encode as JE exposing (..)
import ElmCompiler exposing (compile)
import Timestamp exposing (getTimestamp)

import Snippet exposing (..)

db: Db
db = openOrCreate "./ldb-storage"

putAndReturnKey: String -> String -> Task x String
putAndReturnKey key val =
  Task.map (\_ -> key) (put db key val)


type alias SnippetPayload = {name: String, code: String}

saveCode: String -> Task String String
saveCode code =
  Uuid.v1
   `Task.andThen` (\guid ->
     let
      payloadDecoder = JD.object2 SnippetPayload ("name" := JD.string)  ("code" := JD.string)
      payload = JD.decodeString payloadDecoder code
      ts = 112312321
     in
      case payload of
        Ok data ->
          let
            snippet = Snippet data.name data.code ts
            encoded = JE.encode 2 (snippetEncoder snippet)
          in
            putAndReturnKey guid encoded
        Err err ->
          Task.fail err)

compileCode: String -> Task String String
compileCode code =
  -- compile code `onError` (\err -> Task.succeed err)
  compile code


getCode: String -> Task String (Result String Snippet)
getCode id =
  get db id
  |> Task.map (\code -> JD.decodeString snippetDecoder code)

getAllSnippets: Task x (Result String (List SnippetWithId))
getAllSnippets =
  getAll db
  |> Task.map(\list ->
    let
      a = Debug.log "list" list
    in
      Debug.log "ddfg" (JD.decodeString snippetWithIdListDecoder list))

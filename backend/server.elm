module Main (..) where

import Http.Server exposing (..)
import Http.Request exposing (emptyReq, Request, Method(..), parseQuery, getQueryField, Form)
import Http.Response exposing (emptyRes, Response)
import Http.Response.Write exposing (writeHtml, writeJson, writeElm, writeFile, writeNode, writeError)
import Task exposing (..)
import Signal exposing (..)
import Json.Encode as Json
import Json.Decode as Decode exposing ((:=))
import Json.Encode as Encode
import String as String
import Regex as Regex
import Service
import Router exposing (..)
import Dict
import Snippet

getCodeRouteHandler ( req, res ) params =
  let
    id =
      Maybe.withDefault "" (Dict.get "id" params)
  in
    writeHtml ("id" ++ id) res


getIndexHandler ( req, res ) params =
  defaultGetHandler ( req, res )


defaultGetHandler ( req, res ) =
  let
    url =
      req.url

    file =
      if (url == "/") then
        "/index.html"
      else
        url
  in
    writeFile ("../frontend" ++ file) res



getRouter : Router ( Request, Response ) (Task x ())
getRouter =
  makeRouter
    [ "/api/code/:id"
        :-> (\( req, res ) params ->
              let
                id = Maybe.withDefault "" (Dict.get "id" params)

              in
                Service.getCode id
                  `onError` (\err -> succeed (Result.Err err))
                  `andThen` (\sr -> case sr of
                    Ok snippet -> writeJson (Snippet.snippetEncoder snippet) res
                    Err err -> writeError err res)
                  -- `onError` (\e -> writeHead)
            )
    , "/view/:id"
        :-> (\( req, res ) params ->
              writeFile "../frontend/index.html" res
            )
    , "/api/code"
        :-> (\( req, res ) params ->
                Service.getAllSnippets
                  `andThen` (\sr -> case sr of
                    Ok snippets -> writeJson (List.map Snippet.snippetWithIdEncoder snippets |> Encode.list) res
                    Err err -> writeError err res)
            )
    ]
    defaultGetHandler


server : Mailbox ( Request, Response )
server =
  mailbox ( emptyReq, emptyRes )


route : ( Request, Response ) -> Task x ()
route ( req, res ) =
  case req.method of
    GET ->
      Router.route getRouter ( req, res ) req.url

    POST ->
      case req.url of
        "/api/code" ->
          Http.Request.setBody req
            `andThen` (\req -> Service.saveCode req.body)
            `andThen` (\key -> writeJson (Encode.string key) res)
            `onError` (\err -> writeError err res)

        "/api/compile" ->
          let
            log1 = Debug.log "Started compiling" 1
          in
            Http.Request.setBody req
              `andThen` (\req -> Service.compileCode req.body)
              `andThen` (\compiled ->
                let
                  log2 = Debug.log "finished compiling" 2
                in
                  writeHtml compiled res)
              `onError` (\err -> writeError err res)
        _ ->
          res
            |> writeHtml ("Posted!" ++ req.body)

    NOOP ->
      succeed ()

    _ ->
      res
        |> writeJson (Json.string "unknown method!")


port reply : Signal (Task x ())
port reply =
  Signal.map route (dropRepeats server.signal)


port bob : Task x Server
port bob =
  createServerAndListen
    server.address
    8080
    "Listening on 8080"

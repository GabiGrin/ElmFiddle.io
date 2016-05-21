module Router where

import Regex exposing (..)

import Dict exposing (..)
import String
import Debug

type Route
      = Pattern Regex
      | Path String

type alias RouteParams = Dict String String

dynamicUrlToRegex: String -> Regex
dynamicUrlToRegex url =
    let
      partsPattern = regex "/:[^/]+"
      raw = Regex.replace Regex.All partsPattern (\_ -> "/([^/]+)") url
    in
      regex ("^" ++ raw ++ "$")
      -- regex raw


(:->) : String -> RouteHandler a b -> RouterPart a b
(:->) url handler =
    { route = Path url
     , handler = handler
    }

routeParams: Route -> String -> RouteParams
routeParams route url =
    case route of
      Pattern regex ->
        Dict.empty
      Path routeUrl ->
        let
          pattern = dynamicUrlToRegex routeUrl
          matches = Regex.find Regex.All pattern url
          keyMatches = Regex.find Regex.All pattern routeUrl

          paramNames: List Regex.Match -> List String
          paramNames matches =
             let
              firstMatch = List.head matches
             in
              case firstMatch of
                Nothing ->
                  []
                Just match ->
                  List.map (Maybe.withDefault "") match.submatches

          keyVals: List (String, String)
          keyVals =
            let
              keys = paramNames keyMatches
              vals = paramNames matches
            in
              List.map2 (\k v -> (String.dropLeft 1 k, v))  keys vals
        in
          List.foldr (\(key,val) dict -> Dict.insert key val (Debug.log "dict" dict)) Dict.empty keyVals


matches: Route -> String -> Bool
matches route url =
    case route of
      Pattern regex ->
        contains regex url
      Path str ->
        let
          pattern = dynamicUrlToRegex str
        in
          contains pattern url


makeRouter: (List (RouterPart a b)) -> DefaultRouteHandle a b -> Router a b

makeRouter routeParts defaultHandler =
  { parts = routeParts
  , default = defaultHandler
  }

type alias RouterPart a b =
    { route: Route,
      handler: RouteHandler a b
    }

type alias RouteHandler a b = a -> RouteParams ->  b

type alias DefaultRouteHandle a b = a -> b

type alias Router a b =
  { parts: List (RouterPart a b)
  , default: DefaultRouteHandle a b
  }

route: Router a b -> a -> String -> b
route router extra url =
  let
    maybeMatchingPart part url =
      if (matches part.route url) then Just part else Nothing

    matchingRoutePart =
      List.foldr (\part maybeFound ->
        case maybeFound of
          Just part -> Just part
          Nothing -> maybeMatchingPart part url
       ) Nothing router.parts

  in
      case matchingRoutePart of
        Just routerPart -> routerPart.handler extra (routeParams routerPart.route url)
        Nothing -> router.default extra

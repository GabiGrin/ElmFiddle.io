-- Example.elm


module Main (..) where

import String
import Task
import Console
import ElmTest exposing (..)
import Router exposing (..)
import Regex
import Dict exposing (..)


route1 : Route
route1 =
  Pattern (Regex.regex "/test")


routeWithParam : Route
routeWithParam =
  Path "/user/:id"


routeWithNestedParams : Route
routeWithNestedParams =
  Path "/:ticketId/reply/:replyId"


staticRoute : Route
staticRoute =
  Path "/profile-of/user"


assertTrue val =
  assertEqual True val


assertFalse val =
  assertEqual False val


expectedRoute2Dict : String -> Dict String String
expectedRoute2Dict id =
  let
    dict =
      Dict.empty
  in
    Dict.insert "id" id dict


assertKeyValPresentInDict : RouteParams -> String -> String -> Assertion
assertKeyValPresentInDict routeParams key val =
  assertEqual val (routeParamOrEmpty routeParams key)


routeParamOrEmpty : RouteParams -> String -> String
routeParamOrEmpty params key =
  Maybe.withDefault "" (Dict.get key params)


testRouterParamHandler : a -> RouteParams -> String
testRouterParamHandler a params =
  let
    get =
      routeParamOrEmpty params
  in
    (get "id") ++ (get "commentId")


testRouterInstance : Router a String
testRouterInstance =
  { parts =
      [ { route = Path "/people/:name"
        , handler = (\a b -> "Name!")
        }
      , { route = Path "/someroute"
        , handler = (\a b -> "Someroute")
        }
      , { route = Path "/someroute2"
        , handler = (\a b -> "Someroute2")
        }
      , { route = Path "/post/:id/comments/:commentId"
        , handler = testRouterParamHandler
        }
      ]
  , default = (\a -> "Nothing")
  }





testRouterInstance2: Router a String
testRouterInstance2  = makeRouter
  [ "/people/:name" :-> (\a b -> "Name!")
    , "/someroute" :-> (\a b -> "Someroute")
    , "/someroute2" :-> (\a b -> "Someroute2")
    , "/post/:id/comments/:commentId" :-> testRouterParamHandler
  ]  (\a -> "Nothing")


testRoute : String -> String
testRoute url =
  route testRouterInstance2 "" url


fullTest : Test
fullTest =
  suite
    "Full router suite"
    [ test "people route" (assertEqual (testRoute "/people/bob") "Name!")
    , test "people route" (assertEqual (testRoute "/people/dsfsdfsdf") "Name!")
    , test "some route" (assertEqual (testRoute "/someroute") "Someroute")
    , test "some route2" (assertEqual (testRoute "/someroute2") "Someroute2")
    , test "default" (assertEqual (testRoute "/foo/bar") "Nothing")
    , test "default" (assertEqual (testRoute "/someroute3") "Nothing")
    , test "params" (assertEqual (testRoute "/post/id1/comments/id2") "id1id2")
    , test "params" (assertEqual (testRoute "/post/hello/comments/from") "hellofrom")
    ]


tests : Test
tests =
  suite
    "A Test Suite"
    [ test "Simple route" (assertEqual (matches route1 "/test") True)
    , test "Do not match" (matches route1 "/bob" |> assertNotEqual True)
    , test "static paths" (matches staticRoute "/profile-of/user" |> assertTrue)
    , test "static paths" (matches staticRoute "/bob" |> assertFalse)
    , test "dynamic paths" (matches routeWithParam "/user/some-id" |> assertTrue)
    , test "dynamic paths" (matches routeWithParam "/user/34324-dsfsf" |> assertTrue)
    , test "dynamic paths" (matches routeWithParam "/user/" |> assertFalse)
    , test "dynamic paths" (matches routeWithParam "/usersdfds/" |> assertFalse)
    , test "nested dynmaic paths" (matches routeWithNestedParams "/some-id/reply/some-other-id" |> assertTrue)
    , test "nested dynmaic paths" (matches routeWithNestedParams "/some-ohter-id/reply/some-id" |> assertTrue)
    , test "nested dynmaic paths" (matches routeWithNestedParams "/some-id/replyz/some-other-id" |> assertFalse)
    , test "get params" (matches routeWithParam "/user/" |> assertFalse)
    , test "params 2" (assertKeyValPresentInDict (routeParams routeWithParam "/user/bob") "id" "bob")
    , test "params 2" (assertKeyValPresentInDict (routeParams routeWithNestedParams "/ticket-id/reply/test") "ticketId" "ticket-id")
    , fullTest
    ]


port runner : Signal (Task.Task x ())
port runner =
  Console.run (consoleRunner tests)

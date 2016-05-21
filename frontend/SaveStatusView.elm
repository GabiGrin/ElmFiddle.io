module SaveStatusView (..) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Model exposing (..)


type Action
  = NewFromCurrentCode

view : Signal.Address Action -> SaveStatus -> Html
view address status =
  let
    className =
      if status == Unsaved then
        "hidden"
      else
        ""
    codeId = case status of
      SavedResult (Ok id) -> id
      _ -> ""
    tweetLink = "https://twitter.com/intent/tweet?text=Checkout%20this%20Elm%20snippet%20I've%20made%20using%20%23elmfiddle.io%0Ahttp%3A%2F%2Fwww.elmfiddle.io%2Fview%2F" ++ codeId
  in
    div
  [ id "save-status", class className]
  [ h2
    []
    [ text "Your Awesome Snippet is" , a
      [ href ("/view/" ++ codeId)
      , target "_blank"
      ]
      [ text "Saved!" ]
    ]
  , div
    [ class "bottom-row" ]
    [ span
      [ class "twitter" ]
      [ text "Share on",  a
        [ href tweetLink
        , target "_blank"
        ]
        [ text "Twitter" ]
      ]
    , span
      [ class "divider"]
      [ text "|" ]
    , span
      [ class "new-one" ]
      [ text "Create a new one from",  a
        [ href "/" ]
        [ text "scratch" ] , text "or"
      , a
        [ onClick address NewFromCurrentCode ]
        [ text "using current code" ]
      ]
    ]
  ]

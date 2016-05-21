import Html exposing (..)
import Html.Attributes exposing (..)
import Signal exposing (..)
import Html.Events exposing (..)
 
import Json.Decode as Json

{-| This snippet uses the <ul> and <li> tags to create an unorderd
list of French grocery items. Notice that all occurrences of 'ul'
and 'li' are followed by two lists. The first list is for any HTML
attributes, and the second list is all the HTML nodes inside the
tag.

Et maintenant le voyage au supermarché!
-}

type alias Model = {items: List String, newItem: String}

type Action = AddItem | UpdateCurrent String | NoOp | Remove String

init: Model
init = {items = ["milk", "bread"], newItem =""}

onEnter : Address a -> a -> Attribute
onEnter address value =
    on "keydown"
      (Json.customDecoder keyCode is13)
      (\_ -> Signal.message address value)

actions : Signal.Mailbox Action
actions =
  Signal.mailbox NoOp
  
  
is13 : Int -> Result String ()
is13 code =
  if code == 13 then Ok () else Err "not the right key code"



update: Model -> Action -> Model
update model action =
  case action of
    AddItem -> {model | items = model.newItem :: model.items, newItem = ""}
    UpdateCurrent str -> {model | newItem = str}
    Remove str -> {model | items = List.filter (\i -> i /= str) model.items}
    NoOp -> model


itemsList: List String -> Address Action -> Html
itemsList items address =
  ul []
    (List.map (\i -> li [onClick address (Remove i)] [text i]) items)
    
view: Address Action -> Model -> Html
view address model =
  div []
    [itemsList model.items address
     ,  input
          [ 
          placeholder "What needs to be done?"
          , autofocus True
          , value model.newItem
          , on "input" targetValue (Signal.message address << UpdateCurrent)
          , onEnter address AddItem
          ]
          []]
  
test: Signal Model
test = 
  foldp (\action model -> update model action) init actions.signal

      

main =
   Signal.map (\model -> view actions.address model) test


-- Thanks to "Flight of the Conchords" for creating "Foux Du Fafa"

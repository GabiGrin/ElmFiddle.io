module Model where
import Examples.HelloWorld
import ResultView

type CodeState
  = Pristine
  | Dirty

type SaveStatus
  = Unsaved
  | SavedResult (Result String String)

type alias Model =
  { code: String
  , name: String
  , result: ResultView.Model
  , codeState: CodeState
  , loading: Bool
  , saveStatus: SaveStatus
  , unsavedChanges: Bool
  , focusName: Bool
  }

initModel: Model
initModel =
  { code = Examples.HelloWorld.code
  , name = ""
  , result = ResultView.init
  , codeState = Dirty
  , loading = False
  , saveStatus = Unsaved
  , unsavedChanges = False
  , focusName = False
 }

module Cuid (cuid) where

import Task exposing (Task)
import Native.Cuid


-- type alias Cuid = String


cuid: Task x String
cuid =
  Native.Cuid.cuid

module Timestamp (getTimestamp) where

import Task exposing (Task)
import Native.Timestamp

getTimestamp : Task x Int
getTimestamp = Native.Timestamp.getTimestamp

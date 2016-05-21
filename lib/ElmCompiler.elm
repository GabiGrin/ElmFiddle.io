module ElmCompiler (compile) where

import Task exposing (Task)
import Native.ElmCompiler

compile : String -> Task String String
compile = Native.ElmCompiler.compile

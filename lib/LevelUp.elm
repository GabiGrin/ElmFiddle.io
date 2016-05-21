module LevelUp (Db, openOrCreate, put, log, get, getAll, now) where


import Task exposing (Task)
-- imports are weird for Native modules
-- You import them as you would normal modules
-- but you can't alias them nor expose stuff from them
import Native.LevelUp

type Db = Db

type alias DbItem = {key: String, value: String}

-- this will be our function which returns a number plus one
openOrCreate : String -> Db
openOrCreate = Native.LevelUp.openOrCreate

put : Db -> String -> String -> Task x ()
put db key value =
    Native.LevelUp.put db key value

get : Db -> String -> Task x String
get db key =
    Native.LevelUp.get db key

getAll: Db -> Task x String
getAll db =
    Native.LevelUp.getAll db

log : a -> Task x ()
log str =
    Native.LevelUp.log (toString str)

now: Task x Int
now =
   Native.LevelUp.now

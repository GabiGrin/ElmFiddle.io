module Http.Response.Write (write, writeHead, writeHtml, writeJson, writeCss, writeFile, writeElm, writeError, writeNode, writeRedirect, end) where

import Http.Response exposing (textHtml, applicationJson, textCss, okCode, redirectCode, redirectHeader, Header, Response, StatusCode)
import Native.Http.Response.Write
import Task exposing (Task, andThen)
import VirtualDom exposing (Node)
import Json.Encode as Json


{-| Write Headers to a Response
[Node Docs](https://nodejs.org/api/http.html#http_response_writehead_statuscode_statusmessage_headers)
-}
writeHead : StatusCode -> Header -> Response -> Task x Response
writeHead =
    Native.Http.Response.Write.writeHead


{-| Write body to a Response
[Node Docs](https://nodejs.org/api/http.html#http_response_write_chunk_encoding_callback)
-}
write : String -> Response -> Task x Response
write =
    Native.Http.Response.Write.write


{-| End a Response
[Node Docs](https://nodejs.org/api/http.html#http_response_end_data_encoding_callback)
-}
end : Response -> Task x ()
end =
    Native.Http.Response.Write.end


writeAs : StatusCode -> Header -> String -> Response -> Task x ()
writeAs code header html res =
    writeHead code header res
        `andThen` write html
        `andThen` end


{-| Write out HTML to a Response. For example

    res `writeHtml` "<h1>Howdy</h1>"

-}
writeHtml : String -> Response -> Task x ()
writeHtml =
    writeAs okCode textHtml


writeError: String -> Response -> Task x ()
writeError =
    writeAs 500 textHtml

{-| Write out HTML to a Response. For example

    res `writeCss` "h1 { color : red; }"

-}
writeCss : String -> Response -> Task x ()
writeCss =
    writeAs okCode textCss


{-| Write out JSON to a Response. For example
    res `writeJson` Json.object
      [ ("foo", Json.string "bar")
      , ("baz", Json.int 0) ]
-}
writeJson : Json.Value -> Response -> Task x ()
writeJson val res =
    writeAs okCode applicationJson (Json.encode 0 val) res


{-| write a file
-}
writeFile : String -> Response -> Task a ()
writeFile file res =
    writeHead 200 textHtml res
        `andThen` Native.Http.Response.Write.writeFile file
        `andThen` end


{-| write elm!
-}
writeElm : String -> Maybe b -> Response -> Task a ()
writeElm file appendable res =
    writeHead 200 textHtml res
        `andThen` Native.Http.Response.Write.writeElm file appendable
        `andThen` end


writeNode : Node -> Response -> Task a ()
writeNode node res =
    writeHead 200 textHtml res
        `andThen` Native.Http.Response.Write.writeNode node
        `andThen` end


writeRedirect : String -> Response -> Task a ()
writeRedirect url res =
    writeHead redirectCode (redirectHeader url) res
        `andThen` end

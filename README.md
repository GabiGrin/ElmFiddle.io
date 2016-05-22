![ElmFiddle.io](logo.png)

Elm snippet sharing site made almost entirely using Elm.

It's far from being production ready, so it might crash and your snippets may be deleted. Adding to that, the code is smelly and was my first attempt in building something real with Elm, and playing around with it in the server.

## Running locally
1. Clone this repo
2. `npm install && npm run dev`

Now hack away and the server/client will restart on any change you made.

Note: If you get an error on the opened page, please retry and it should work. Couldn't find the source of this bug yet.

## How it works?

The browser part is easy, basic Elm StartApp app. I had to write [an Elm wrapper for CodeMirror](https://github.com/gabigrin/elm-codemirror), which has a nice example of how to interact with complex existing libraries that are not worth rewriting in Elm.

The server part is pretty experimental and based on works from [NoRedink](https://github.com/NoRedInk/take-home) and [deadfoxygrandpa](https://github.com/deadfoxygrandpa/elm-node), with a few improvements and missed features.
Snippets persistence is done with a simple LevelDb instance, with an [Elm wrapper](lib/LevelUp.elm). It'll probably need many changes to support more features, and might even be replaces by another persistence layer.

Compiling of Elm code is done using [node-elm-compile-string](https://github.com/GabiGrin/node-elm-compile-string), a small library I wrote that compiles an Elm source code string and outputs a string, hiding the actual file creation, and uses the native Elm Compiler behind the scenes. It loads some of the more popular packages (like Html and Http) automatically. Compiling is still much slower than on [Elm's "try" section](http://elm-lang.org/try), and optimizing that will probably involve a haskell microservice to compile the code using the native compiler code. I tried that and failed :). I even played around with the thought of compiling Elm's Compiler to JS and do it from the browser. Also failed, but I'm not experienced with Haskell enough to say it it's impossible.

Routing was also not trivial, and I had to write a small router to be able to strip url parameters efficiently. It even has some [tests](tests/Main.elm)!
I plan using it on the front-end as soon as I have some time to refactor.

There are still many things to be done and the code is far from perfect and needs heavy refactoring, but hopefully it will be helpful and serve as another example of a full-stack Elm app.

## 0.17
Unfortunately most work on this was made before 0.17 was released, and it was written for 0.16, so it has concepts that are now gone from the language, like `Signals`.

### Todo:
- Show a list of recent snippets
- Support authentication / user snippets
- Support 0.17
- Improve reliability on the server


MIT © Gabriel Grinberg

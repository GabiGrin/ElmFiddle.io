Making of elmfiddle.io

After playing around with Elm, I became astonished by the language and was eager to create something real with it.
Lacking the ability to share Elm snippets on the online elm editor, I thought making snippet sharing website can be a cool project to make.
Adding to that, I really wanted to improve my DevOps skills, and dive deeper into Docker, VPS and try making something end-to-end, without using a PaaS such as Heroku.

My goals were:
- Have the whole site run under a docker container from a VPS, via DigitalOcean.
- Create a full-stack Elm application, with both the server (via node.js bindings) and the client run isomorphically using Elm.
- Have some kind of continuous integration
- Deploy static files to a CDN to reduce server load
- Have some kind of monitoring service
- Have nice access to logBase

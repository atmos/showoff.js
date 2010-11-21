Showoff = require("./init")

Express = require("express")
Path    = require("path")
Io      = require("socket.io")

app    = Express.createServer()
preso  = new Showoff.Presentation(Path.join(__dirname, ".."))
socket = Io.listen(app)

app.configure ->
  app.set "views", "#{__dirname}/views"
  app.set "view engine", "ejs"
  app.use Express.staticProvider({ path: Path.join(__dirname, "..", "public") })
  app.use Express.logger()
  app.use Express.errorHandler({ showStack: true, dumpExceptions: true })

app.get "/(?:image|file)/*", (req, res) ->
  res.sendfile Path.join(preso.slidesDir, req.params[0])

app.get "/", (req, res) ->
  console.log(preso)
  preso.generate (content) ->
    locals =
      port     : req.headers.host.split(':')[1] || 80
      title    : preso.name
      slides   : content
      hostname : req.headers.host.split(':')[0] || 'localhost'

    console.log locals
    res.render "index", { locals: locals }

socket.on "connection", (client) ->
  client.on "message", (json) ->
    self = this
    console.error(json)
    try
      if(json.action == 'authentication')
        if(client.request.socket.remoteAddress == '127.0.0.1')
          client.send({presenter: true})
        else
          client.send({presenter: false})

      if(json.action == 'next')
        socket.clients.forEach (watcher) ->
          if(watcher? && watcher.sessionId != self.sessionId)
            watcher.send({action: 'next', index: json.index})

      if(json.action == 'prev')
        socket.clients.forEach (watcher) ->
          if(watcher? && watcher.sessionId != self.sessionId)
            watcher.send({action: 'prev', index: json.index})

    catch err
      console.error err.stack
      return

  client.on 'disconnect', (json) ->
    console.log("Disconnected")

exports.run = (options) ->
  app.listen(parseInt(process.env.PORT) || 9393)

# vim: ft=coffee

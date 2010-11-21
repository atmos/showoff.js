Fs     = require("fs")
Path   = require("path")
LibDir = Path.join(Fs.realpathSync(__dirname), "..", "vendor")

libs = [ "ejs", "connect", "express", "showdown", "optparse-js", "Socket.IO-node" ]

libs.forEach (dep) ->
  require.paths.unshift(Path.join(LibDir, dep, "lib"))

exports.Presentation = require("./showoff").Presentation

# vim: ft=coffee

var fs     = require("fs")
  , path   = require("path")
  , libDir = path.join(fs.realpathSync(__dirname), "..", "vendor")

var libs = [ "ejs", "connect", "express", "showdown", "optparse-js", "Socket.IO-node" ]

libs.forEach(function(dep) {
  require.paths.unshift(path.join(libDir, dep, "lib"))
})

var presentation = require("./showoff/presentation")
  , slide        = require("./showoff/slide")

exports.Presentation = presentation.Presentation

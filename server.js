// add the vendored express to the require path
require("./lib/showoff")

var app = require("./lib/app")

app.run({presenting: false})

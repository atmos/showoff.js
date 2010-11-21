Fs       = require("fs")
Path     = require("path")
Showdown = require("showdown").Showdown

class Builder
  constructor: (section) ->
    data = section.split(/\n/)

    @styles  = data.shift().trim()
    @content = data.join("\n")

  toHTML: (name, index) ->
    @outterDiv(name + "/" + index)

  outterDiv: (refName) ->
    slideHTML   = generatedContent()
    outterHTML  = "<div class=\"slide\" data-transition=\"#{transition()}\">"
    wrapperHTML = "<div class=\"#{this.classes()}\" ref=\"" + refName + "\">"

    outterHTML + wrapperHTML + slideHTML + "</div>\n</div>"

  generatedContent: ->
    converter = new Showdown.converter()

    converter.makeHtml(@content)

  classes: ->
    [ "content" ].join(" ") + " " + @styles

  transition: ->
    if @styles.match(/transition=(\S+)/)
      @styles.match(/transition=(\S+)/)[0]
    else
      "none"

class Section
  constructor: (@baseDir) ->

  sortedSlideFiles: ->
    results = [ ]
    files   = Fs.readdirSync(@baseDir)

    files.forEach (file) ->
      if file.match(/\.md$/)
        results.push file

    results.sort()

  slideFor: (suffix) ->
    slide = new Slide(Path.join(@baseDir, suffix))
    slide.render()

  parseSync: ->
    slides = [ ]
    slides.push slideFor(suffix) for suffix in @sortedSlideFiles()
    slides.join("\n")

class Slide
  constructor: (markdownFile) ->
    @file = markdownFile

  parse: ->
    results  = [ ]
    contents = Fs.readFileSync(@file).toString()

    results.push(new Builder(slides)) for slides in contents.split(/^!SLIDE/mg)

    results

  slug: ->
    console.log @file
    matches = @file.match(/^.*?\/([^\/]+)\/([^\/]+).md$/)
    console.log matches
    if matches?
      [ matches[1], matches[2] ].join("/")
    else
      "foo/bar"

  render: ->
    slug    = slug()
    results = [ ]

    parse().forEach (builder, index) ->
      results.push(builder.toHTML(slug, index + 1))
    results.join("\n")

class Presentation
  constructor: (@rootDir) ->
    @slidesDir = Path.join(@rootDir, "example")
    @jsonFile  = Path.join(@slidesDir, 'showoff.json')
    @config    = @parseConfig()

  name: ->
    @config.name || @rootDir.split("/").last

  description: ->
    @config.description || ""

  sections: ->
    @config.sections() || [ ]

  parseConfig: ->
    console.log(@jsonFile)
    JSON.parse(Fs.readFileSync(@jsonFile).toString())

  sectionFor: (value) ->
    section = new Section(Path.join(self.slidesDir, val.section))
    section.parseSync()

  generate: (callback) ->
    html = [ ]
    self = this

    html.push(sectionFor(val.section)) for val in @sections

    console.log(html.join("\n"))
    callback(html.join("\n"))

  js_files: ->
    [ ]

  css_files: ->
    [ ]

exports.Slide        = Slide
exports.Builder      = Builder
exports.Section      = Section
exports.Presentation = Presentation

# vim: ft=coffee

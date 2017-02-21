fs       = require 'fs'
path     = require 'path'
debounce = require 'debounce'

writeFile = (dst, content) ->
  fs.writeFile dst, content, 'utf8', (err) ->
    console.error err if err?

compilePug = (src, dst) ->
  filename = path.basename src
  return if filename.charAt(0) == '_'

  pug = require 'pug'

  opts =
    basedir:      __dirname + '/src'
    pretty:       true
    production:   if process.env.PRODUCTION then true else false

  for k,v of require './settings'
    opts[k] = v

  src = path.join 'src',    filename
  dst = path.join 'public', filename.replace '.pug', '.html'

  html = pug.renderFile src, opts
  writeFile dst, html

  true

compileCoffee = ->
  requisite  = require 'requisite'

  src = 'src/js/app.coffee'
  dst = 'public/js/app.js'

  opts =
    entry:             src
    externalSourceMap: true
    sourceMapURL:      (path.basename dst) + '.map'

  if process.env.PRODUCTION
    opts.minify   = true
    opts.minifier = 'esmangle'

  requisite.bundle opts, (err, bundle) ->
    return console.error err if err?
    {code, map} = bundle.toString opts
    writeFile dst, code
    writeFile dst + '.map', map

  true

compileStylus = ->
  stylus       = require 'stylus'
  postcss      = require 'poststylus'
  autoprefixer = require 'autoprefixer'
  comments     = require 'postcss-discard-comments'
  lost         = require 'lost-stylus'
  rupture      = require 'rupture'
  CleanCSS     = require 'clean-css'

  src = 'src/css/app.styl'
  dst = 'public/css/app.css'

  style = stylus fs.readFileSync src, 'utf8'
    .set 'filename', src
    .set 'paths', [
      __dirname + '/src/css'
      __dirname + '/node_modules'
    ]
    .set 'include css', true
    .set 'sourcemap',
      basePath:   ''
      sourceRoot: '../'
    .use lost()
    .use rupture()
    .use postcss [
      autoprefixer browsers: '> 1%'
      'lost'
      'rucksack-css'
      'css-mqpacker'
      comments removeAll: true
    ]

  style.render (err, css) ->
    return console.error err if err
    if process.env.PRODUCTION
      minifier = new CleanCSS
        aggressiveMerging: false
        semanticMerging:   false
      minified = minifier.minify css
      writeFile dst, minified.styles
    else
      sourceMapURL = (path.basename dst) + '.map'
      css = css + "/*# sourceMappingURL=#{sourceMapURL} */"
      writeFile dst, css
      writeFile dst + '.map', JSON.stringify style.sourcemap
  true

module.exports =
  assetDir: __dirname + '/src'
  buildDir: __dirname + '/public'

  compilers:
    pug:    compilePug
    coffee: debounce compileCoffee, 10
    styl:   debounce compileStylus, 10

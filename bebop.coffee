fs       = require 'fs'
path     = require 'path'
debounce = require 'debounce'

builtins      = require 'rollup-plugin-node-builtins'
coffee        = require 'rollup-plugin-coffee-script'
commonjs      = require 'rollup-plugin-commonjs'
filesize      = require 'rollup-plugin-filesize'
globals       = require 'rollup-plugin-node-globals'
json          = require 'rollup-plugin-json'
nodeResolve   = require 'rollup-plugin-node-resolve'
pug           = require 'rollup-plugin-pug'
rollup        = require 'rollup'
stylus        = require 'rollup-plugin-stylus'

postcss      = require 'poststylus'
autoprefixer = require 'autoprefixer'
comments     = require 'postcss-discard-comments'
lost         = require 'lost-stylus'

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

plugins = [
  builtins()
  globals()
  coffee()
  pug
    pretty:                 true
    compileDebug:           true
    sourceMap:              false
    inlineRuntimeFunctions: false
    staticPattern:          /\S/
  stylus
    sourceMap: false
    fn: (style) ->
      style.use lost()
      style.use postcss [
        autoprefixer browsers: '> 1%'
        'lost'
        'css-mqpacker'
        comments removeAll: true
      ]
  json()
  nodeResolve
    browser:    true
    module:     true
    jsnext:     true
    extensions: ['.js', '.coffee', '.pug', '.styl']
  commonjs
    extensions: ['.js', '.coffee']
    sourceMap:  false
]

cache = null

compileCoffee = (src, dst, cb) ->
  rollup.rollup
    cache:   cache
    entry:   'src/js/app.coffee'
    plugins:  plugins
  .then (bundle) ->
    cache = bundle
    bundle.write
      dest:       'public/js/app.js'
      format:     'iife'
      moduleName: 'app'
    .then cb
  true

compileStylus = ->
  src = 'src/css/app.styl'
  dst = 'public/css/app.css'

  stylus       = require 'stylus'
  postcss      = require 'poststylus'
  autoprefixer = require 'autoprefixer'
  comments     = require 'postcss-discard-comments'
  lost         = require 'lost-stylus'
  rupture      = require 'rupture'
  CleanCSS     = require 'clean-css'

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
    # if process.env.PRODUCTION
    #   minifier = new CleanCSS
    #     aggressiveMerging: false
    #     semanticMerging:   false
    #   minified = minifier.minify css
    #   writeFile dst, minified.styles
    # else
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

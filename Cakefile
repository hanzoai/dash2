require 'shortcake'

use 'cake-test'
use 'cake-version'
use 'cake-publish',
  deploy:
    remote:  'origin'
    refspec: 'master:master'
  npm: false
use 'cake-yarn'

task 'build', 'build project', ['build:static', 'build:js']

task 'build:js', 'build js', ['install'], do ->
  handroll = require 'handroll'

  bundle = null

  compile = (b) ->
    bundle = b
    bundle.write()

  ->
    return compile bundle if bundle?

    handroll.bundle
      entry:    'src/js/app.coffee'
      dest:     'public/js/app.js'
      format:   'web'
      commonjs: true
    .then compile
    .catch (err) ->
      console.error err

task 'build:static', 'build static assets', ->
  exec '''
    mkdir -p public/css
    mkdir -p public/js
    bebop compile'
  '''

task 'watch', 'watch for changes and rebuild project', ['watch:js', 'watch:static']

task 'watch:js', 'watch js for changes and rebuild', ['install'], ->
 build = (filename) ->
    return if (running 'build')
    console.log filename, 'modified'
    invoke 'build'

  watch 'src/*',          build
  watch 'node_modules/*', build

task 'watch:static', 'watch static files and rebuild', ['build:static'], ->
  exec 'bebop'

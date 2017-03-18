require 'shortcake'

use 'cake-bundle'
use 'cake-linked'
use 'cake-outdated'
use 'cake-publish',
  deploy:
    remote:  'origin'
    refspec: 'master:master'
  npm: false
use 'cake-test'
use 'cake-version'
use 'cake-yarn'

task 'build', 'build project', ['build:static', 'build:js']

task 'build:js', 'build js',   ['yarn:install'], ->
  return if (running 'build')

  bundle.write
    dest:     'public/js/app.js'
    entry:    'src/js/app.coffee'
    format:   'web'
    commonjs: true
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

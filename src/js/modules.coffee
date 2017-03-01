moment = require 'moment-timezone'
Daisho = require 'daisho'

module.exports =
  Home: require 'hanzo-home'
  Note: class Note #require 'hanzo-note'
    constructor: (daisho, ps, ms, cs)->
      cs.register 'note.add', '<message> <timestamp>',  (message, time)->
        opts =
          message:  message
          time:     moment(time).format Daisho.util.time.rfc3339
          source:   'dashboard'

        daisho.client.note.create(opts).then ->
          console.log '---NOTE SUCCESS---'
        .catch (e)->
          console.log '---NOTE FAIL---', e

      cs.register 'note.remove', '<note id>',  (id)->
        opts =
          id: id
          enabled: false

        daisho.client.note.update(opts).then ->
          console.log '---NOTE REMOVE SUCCESS---'
        .catch (e)->
          console.log '---NOTE REMOVE FAIL---', e

import moment from 'moment'
import Daisho from 'daisho'
import Home   from 'hanzo-home'
import Orders from 'hanzo-orders'
import akasha  from 'akasha'

export default modules =
  Home: Home
  Orders: Orders

  VideoChat: class VideoChat
    constructor: (daisho, ps, ms, cs)->
      el = null

      ps.register 'video-chat',
        ->
          activeOrg = akasha.get 'activeOrg'

          el = document.createElement 'iframe'
          el.setAttribute 'src', 'https://talky.io/' + activeOrg
          return el
        ->
          return el
        ->

      ms.register 'Chat', ->
        ps.show 'video-chat'


  Note: class Note
    constructor: (daisho, ps, ms, cs)->
      cs.register 'note.add', '<message> <optional timestamp>',  (message, time)->
        opts =
          message:  message
          time:     moment(time).format Daisho.util.time.rfc3339
          source:   'dashboard'
          enabled:  true

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

  Fake: class Fake
    constructor: (daisho, ps, ms, cs)->
      # ms.register 'Analytics', ->
      #   window.location.href = 'https://dash.hanzo.io/#analytics'
      # ms.register 'Campaign', ->
      #   window.location.href = 'https://dash.hanzo.io/#campaign'
      # ms.register 'Log', ->
      #   window.location.href = 'https://dash.hanzo.io/#log'

      # ms.register 'Content', ->
      #   window.location.href = 'https://dash.hanzo.io/#log'
      # ms.register 'Messaging', ->
      #   window.location.href = 'https://dash.hanzo.io/#messaging'
      # ms.register 'Social', ->
      #   window.location.href = 'https://dash.hanzo.io/#log'

      # ms.register 'Email', ->
      #   window.location.href = 'https://dash.hanzo.io/#email'
      ms.register 'Forms', ->
        window.location.href = 'https://dash.hanzo.io/#forms'

      ms.register 'Sites', ->
        window.location.href = 'https://dash.hanzo.io/#sites'
      ms.register 'Shops', ->
        window.location.href = 'https://dash.hanzo.io/#shops'

      # ms.register 'Bundles', ->
      #   window.location.href = 'https://dash.hanzo.io/#bundles'
      ms.register 'Products', ->
        window.location.href = 'https://dash.hanzo.io/#products'
      ms.register 'Variants', ->
        window.location.href = 'https://dash.hanzo.io/#variant'

      # ms.register 'Payments', ->
      #   window.location.href = 'https://dash.hanzo.io/#payments'
      # ms.register 'Returns', ->
      #   window.location.href = 'https://dash.hanzo.io/#returns'
      # ms.register 'Disputes', ->
      #   window.location.href = 'https://dash.hanzo.io/#disputes'

      ms.register 'Users', ->
        window.location.href = 'https://dash.hanzo.io/#users'
      # ms.register 'Subscribers', ->
      #   window.location.href = 'https://dash.hanzo.io/#subscribers'
      # ms.register 'Ambassadors', ->
      #   window.location.href = 'https://dash.hanzo.io/#ambassadors'
      # ms.register 'Referrals', ->
      #   window.location.href = 'https://dash.hanzo.io/#referrals'

      ms.register 'Organization', ->
        window.location.href = 'https://dash.hanzo.io/#organization'
      ms.register 'Team', ->
        window.location.href = 'https://dash.hanzo.io/#team'
      ms.register 'Integrations', ->
        window.location.href = 'https://dash.hanzo.io/#integrations'
      ms.register 'Settings', ->
        window.location.href = 'https://dash.hanzo.io/#settings'

      ms.register 'Profile', ->
        window.location.href = 'https://dash.hanzo.io/#profile'

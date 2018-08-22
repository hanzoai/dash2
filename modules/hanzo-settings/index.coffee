import Daisho  from 'daisho/src'
import { isRequired } from 'daisho/src/views/middleware'

import settingsHtml from './templates/settings.pug'
import css  from './css/app.styl'

class HanzoSettings extends Daisho.Views.Dynamic
  tag: 'hanzo-settings'
  html: settingsHtml
  css:  css
  _dataStaleField:  'id'

  showResetModal: false
  showSaveModal: false
  showMessageModal: false

  loading: false

  # message modal's message
  message: ''

  configs:
    'fullName': [isRequired]

  _refresh: ->
    org = @daisho.akasha.get('orgs')[@daisho.akasha.get('activeOrg')]

    @loading = true
    return @client.organization.get(org.id).then (res) =>
      @cancelModals()
      @loading = false
      @data.set res
      @scheduleUpdate()
    .catch (err)=>
      @loading = false

  reset: ->
    @_refresh().then =>
      @showMessage 'Reset!'

  save: ->
    test = @submit()
    test.then (val) =>
      if !val?
        if $('.input .error')[0]?
          @cancelModals()
          @showMessage 'Some things were missing or incorrect.  Try again.'
          @scheduleUpdate()
    .catch (err)=>
      @showMessage err

  _submit: ->
    data = @data.get()

    @loading = true
    @client.organization.update(data).then (res) =>
      @cancelModals()
      @loading = false
      @data.set res
      @showMessage 'Success!'
      @scheduleUpdate()
    .catch (err) =>
      @loading = false
      @showMessage err

  # show the message modal
  showMessage: (msg)->
    if !msg?
      msg = 'There was an error.'
    else
      msg = msg.message ? msg

    @cancelModals()
    @message = msg
    @showMessageModal = true
    @scheduleUpdate()

    @messageTimeoutId = setTimeout =>
      @cancelModals()
      @scheduleUpdate()
    , 5000

  # show the save modal
  showSave: ->
    @cancelModals()
    @showSaveModal = true
    @scheduleUpdate()

  # show the reset modal
  showReset: ->
    @cancelModals()
    @showResetModal = true
    @scheduleUpdate()

  # close all modals
  cancelModals: ->
    clearTimeout @messageTimeoutId
    @showSaveModal = false
    @showMessageModal = false
    @scheduleUpdate()

HanzoSettings.register()

export default class Settings
  constructor: (daisho, ps, ms, cs)->
    ps.register 'settings',
      ->
        @el = el = document.createElement 'hanzo-settings'

        @tag = (daisho.mount el)[0]
        return el
      ->
        @tag.refresh()
        return @el
      ->
        return @el

    ms.register 'Settings', ->
      ps.show 'settings'


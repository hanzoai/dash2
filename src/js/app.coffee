import Daisho  from 'daisho/src/index'
import akasha  from 'akasha'
import refer   from 'referential'

import modules from './modules'

m = Daisho.mediator

data = refer(akasha.get('data') || {})
data.set 'orgs', (akasha.get('orgs') || [])
data.set 'activeOrg', (akasha.get('activeOrg') || 0)
data.set 'account', (akasha.get('account') || {})

settings = refer(akasha.get('settings') || {})

dash = new Daisho 'https://api.hanzo.ai', modules, data, settings, true
# dash = new Daisho 'https://api-staging.hanzo.io', modules, data, settings, true

dash.Daisho = Daisho
dash.akasha = akasha
dash.m      = m

# login
m.on Daisho.Events.LoginSuccess, ->
  # load important values
  akasha.set 'orgs', data.get 'orgs'
  akasha.set 'activeOrg', data.get 'activeOrg'
  akasha.set 'account', data.get 'account'
  akasha.set 'data', data.get()
  akasha.set 'settings', settings.get()

  dash.mount Daisho.Views.Main::tag, data: data

  # hide login and try and start
  requestAnimationFrame ->
    try
      $('#screen-login').hide()
      dash.start()
      dash.scheduleUpdate()
    catch err
      console.log err.stack

# logout
m.on Daisho.Events.Logout, ->
  akasha.remove 'orgs'
  akasha.remove 'account'

updateTimeoutID = null

# whenever a field updates
m.on Daisho.Events.Change, (name, val)->
  if name == 'activeOrg'
    akasha.set name, val

  if updateTimeoutID
    return
  else
    updateTimeoutID = requestAnimationFrame ->
      akasha.set 'data', data.get()
      akasha.set 'settings', settings.get()

      # force webkit reflow
      document.body.offsetHeight

      updateTimeoutID = null
    return

# bootstrap
if data.get('orgs').length > 0
  m.trigger Daisho.Events.LoginSuccess
else
  dash.mount Daisho.Views.Login::tag, data: data

  requestAnimationFrame ->
    $('#screen-login .content').css 'display', 'table'

# TODO: Figure out what's randomly putting focus on the body
$(document).on 'focus', '*', (e) ->
  if e.target._focused
    return true
  e.target._focused = true
  setTimeout ()->
    $(e.target).focus()
    setTimeout ()->
      e.target._focused = false
    , 100
  , 100

export default dash

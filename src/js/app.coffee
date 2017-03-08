import Daisho from 'daisho'
import Home   from 'hanzo-home'
import akasha from 'akasha'
import refer  from 'referential'

modules = [
  Home
]

m = Daisho.mediator

data = refer(akasha.get('data') || {})
data.set 'orgs', (akasha.get('orgs') || [])
data.set 'activeOrg', (akasha.get('activeOrg') || 0)
data.set 'account', (akasha.get('account') || {})

settings = refer(akasha.get('settings') || {})

daisho = new Daisho 'https://api.hanzo.io', modules, data, settings, true
# daisho = new Daisho 'https://api-staging.hanzo.io', modules, data, settings, true

# login
m.on Daisho.Events.LoginSuccess, ->
  # load important values
  akasha.set 'orgs', data.get 'orgs'
  akasha.set 'activeOrg', data.get 'activeOrg'
  akasha.set 'account', data.get 'account'
  akasha.set 'data', data.get()
  akasha.set 'settings', settings.get()

  daisho.mount Daisho.Views.Main.tag,
    data: data

  # hide login and try and start
  requestAnimationFrame ->
    try
      $('#page-login').hide()
      daisho.start()
      daisho.update()
    catch err
      console.log err.stack

# logout
m.on Daisho.Events.Logout, ->
  akasha.remove 'orgs'
  akasha.remove 'account'

# whenever a field updates
m.on Daisho.Events.Change, (name, val)->
  if name == 'activeOrg'
    akasha.set name, val

  akasha.set 'data', data.get()
  akasha.set 'settings', settings.get()

# bootstrap
if data.get('orgs').length > 0
  m.trigger Daisho.Events.LoginSuccess
else
  daisho.mount Daisho.Views.Login.tag,
    data: data

export default daisho

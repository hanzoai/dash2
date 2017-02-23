Daisho  = require 'daisho'
refer   = require 'referential'
$       = require 'jquery'
akasha  = require 'akasha'

m = Daisho.Mediator

data = refer
  orgs:         akasha.get 'orgs'
  activeOrg:    akasha.get 'activeOrg'
  account:      akasha.get 'account'

modules = require './modules'
  # lol: class Lol
  #   constructor: (daisho, ps, ms)->
  #     ps.register 'lol',
  #       ->
  #         console.log 'enter lol'
  #       ->
  #         console.log 'start lol'
  #       ->
  #         console.log 'end lol'

  #     ms.register 'Home', ->
  #       ps.show 'lol'

  #     console.log 'registered lol'

daisho = new Daisho 'https://api.hanzo.io', modules, data, true

m.on Daisho.Events.LoginSuccess, ->
  akasha.set 'orgs', data.get 'orgs'
  akasha.set 'activeOrg', data.get 'activeOrg'
  akasha.set 'account', data.get 'account'

  daisho.mount Daisho.Views.Main.tag
  requestAnimationFrame ->
    try
      $('#page-login').hide()
      daisho.start()
      daisho.update()
    catch err
      console.log err.stack

m.on Daisho.Events.Logout, ->
  akasha.remove 'orgs'
  akasha.remove 'account'

m.on Daisho.Events.Change, (name, val)->
  if name == 'activeOrg'
    akasha.set name, val

if data.get('orgs')?
  m.trigger Daisho.Events.LoginSuccess
else
  daisho.mount Daisho.Views.Login.tag

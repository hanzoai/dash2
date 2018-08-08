import Daisho  from 'daisho/src'
import Promise from 'broken'
import numeral from 'numeral'
import { isRequired } from 'daisho/src/views/middleware'

import subscribersHtml from './templates/subscribers.pug'
import subscriberHtml from './templates/subscriber.pug'
import css  from './css/app.styl'
# import TractorBeam from 'tractor-beam'

SubscriberUpdateBalanceEvent = 'subscriber-update-balance'

class HanzoSubscribers extends Daisho.Views.HanzoDynamicTable
  tag: 'hanzo-subscribers'
  html: subscribersHtml
  css:  css

  name: 'Subscribers'

  configs:
    'filter': []

  initialized: false
  loading: false

  # a map of all the range facets that should use currency instead of numeric
  facetCurrency:
    price: true
    listPrice: true
    inventoryCost: true

  # table header configuration
  headers: [
    # {
    #   name: 'Image'
    #   field: 'Slug'
    # },
    {
      name: 'Email'
      field: 'Email'
    },
    {
      name: 'Signed Up On'
      field: 'CreatedAt'
    },
    {
      name: 'Last Updated'
      field: 'UpdatedAt'
    }
  ]

  openFilter: false

  init: ->
    super

  create: ()->
    @services.page.show 'subscriber', ''

  list: (opts) ->
    return @client.subscriber.list opts

HanzoSubscribers.register()

class HanzoSubscriber extends Daisho.Views.Dynamic
  tag: 'hanzo-subscriber'
  html: subscriberHtml
  css:  css
  _dataStaleField:  'id'
  showResetModal: false
  showResetPasswordModal: false
  showSaveModal: false
  showMessageModal: false
  password: 'New Password Appears Here'

  loading: false

  # message modal's message
  message: ''

  # spatial units
  dimensionsUnits:
    cm: 'cm'
    m:  'm'
    in: 'in'
    ft: 'ft'

  # mass units
  weightUnits:
    g:  'g'
    kg: 'kg'
    oz: 'oz'
    lb: 'lb'

  configs:
    firstName:   [isRequired]
    email:       [isRequired]
    enabled:     [isRequired]

  init: ->
    super

    # @one 'updated', ()=>
    #   beam = new TractorBeam '.tractor-beam'
    #   beam.on 'dropped', (files) ->
    #     for filepath in files
    #       console.log 'Uploading...', filepath

  default: ()->
    # pull the org information from localstorage
    org = @daisho.akasha.get('orgs')[@daisho.akasha.get('activeOrg')]
    model =
      currency: org.currency

    return model

  # load things
  _refresh: ()->
    id = @data.get('id')
    if !id
      @data.clear()
      @data.set @default()
      @scheduleUpdate()
      return true

    @loading = true
    return @client.subscriber.get(id).then (res) =>
      @cancelModals()
      @loading = false
      @data.set res
      @scheduleUpdate()
    .catch (err)=>
      @loading = false

  # load things but slightly differently
  reset: ()->
    @_refresh(true).then ()=>
      @showMessage 'Reset!'

  resetPassword: ->
    @loading = true
    @scheduleUpdate()

    @client.subscriber.resetPassword(@data.get('id')).then (res) =>
      @cancelModals()
      @password = res.password
      @loading = false
      @scheduleUpdate()
    .catch (err)=>
      @loading = false
      @showMessage err

  getResetPassword: ->
    return @password ? ''

  # save by using submit to validate inputs
  save: ()->
    test = @submit()
    test.then (val)=>
      if !val?
        if $('.input .error')[0]?
          @cancelModals()
          @showMessage 'Some things were missing or incorrect.  Try again.'
          @scheduleUpdate()
    .catch (err)=>
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

    @messageTimeoutId = setTimeout ()=>
      @cancelModals()
      @scheduleUpdate()
    , 5000

  # show the reset modal
  showReset: ()->
    @cancelModals()
    @showResetModal = true
    @scheduleUpdate()

  # show the reset password
  showResetPassword: ()->
    @cancelModals()
    @showResetPasswordModal = true
    @scheduleUpdate()

  # show the save modal
  showSave: ()->
    @cancelModals()
    @showSaveModal = true
    @scheduleUpdate()

  # close all modals
  cancelModals: ()->
    clearTimeout @messageTimeoutId
    @showResetModal = false
    @showResetPasswordModal = false
    @showSaveModal = false
    @showMessageModal = false
    @scheduleUpdate()

  # submit the form
  _submit: ()->
    data = Object.assign {},  @data.get()
    delete data.balances
    delete data.referrers
    delete data.referrals

    # presence of id determines method used
    api = 'create'
    if data.id?
      api = 'update'

    @loading = true
    @client.subscriber[api](data).then (res)=>
      @cancelModals()
      @loading = false
      @data.set res
      @showMessage 'Success!'
      @scheduleUpdate()
    .catch (err)=>
      @loading = false
      @showMessage err

HanzoSubscriber.register()

class HanzoSubscribers extends Daisho.Views.HanzoDynamicTable
  tag: 'hanzo-subscribers'
  html: subscribersHtml
  css:  css

  name: 'Subscribers'

  configs:
    'filter': []

  initialized: false
  loading: false

  # a map of all the range facets that should use currency instead of numeric
  facetCurrency:
    price: true
    listPrice: true
    inventoryCost: true

  # table header configuration
  headers: [
    # {
    #   name: 'Image'
    #   field: 'Slug'
    # },
    {
      name: 'Email'
      field: 'Email'
    },
    {
      name: 'Registered On'
      field: 'CreatedAt'
    },
    {
      name: 'Last Updated'
      field: 'UpdatedAt'
    }
  ]

  openFilter: false

  init: ->
    super

  create: ()->
    @services.page.show 'subscriber', ''

  list: (opts) ->
    return @client.subscriber.list opts

HanzoSubscribers.register()

export default class Subscribers
  constructor: (daisho, ps, ms, cs)->
    tag = null
    opts = {}

    ps.register 'subscribers',
      ->
        @el = el = document.createElement 'hanzo-subscribers'

        tag = (daisho.mount el)[0]
        return el
      ->
        tag.refresh()
        return @el
      ->

    ps.register 'subscriber',
      (ps, id)->
        opts.id = id if id?
        @el = el = document.createElement 'hanzo-subscriber'

        tag = (daisho.mount el)[0]
        tag.data.set 'id', opts.id
        return el
      (ps, id)->
        opts.id = id if id?
        tag.data.set 'id', opts.id
        tag.refresh()
        return @el
      ->

    ms.register 'Subscribers', ->
      ps.show 'subscribers'

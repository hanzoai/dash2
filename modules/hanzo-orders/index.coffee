import Daisho  from 'daisho/src'
import Promise from 'broken'
import numeral from 'numeral'
import { isRequired } from 'daisho/src/views/middleware'

import html1 from './templates/orders.pug'
import html2 from './templates/order.pug'
import css  from './css/app.styl'
# import TractorBeam from 'tractor-beam'

# import to register
import ShippingAddressState from 'shop.js/src/controls/checkout/shippingaddress-state'
import ShippingAddressCountry from 'shop.js/src/controls/checkout/shippingaddress-country'

class HanzoOrders extends Daisho.Views.HanzoDynamicTable
  tag: 'hanzo-orders'
  html: html1
  css:  css

  name: 'Orders'

  configs:
    'filter': []

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
      name: 'Number'
      field: 'Number'
    },
    {
      name: 'Total'
      field: 'Total'
    },
    {
      name: 'Status'
      field: 'PaymentStatus'
    },
    {
      name: 'Created On'
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
    @services.page.show 'order', ''

  list: (opts) ->
    return @client.order.list opts

HanzoOrders.register()

class HanzoOrder extends Daisho.Views.Dynamic
  tag: 'hanzo-order'
  html: html2
  css:  css
  _dataStaleField:  'id'
  showResetModal: false
  showSaveModal: false
  showMessageModal: false

  loading: false

  # message modal's message
  message: ''

  configs:
    'status':               [isRequired]
    'paymentStatus':        [isRequired]
    'fullfillmentStatus':   [isRequired]

  init: ->
    super

    # @one 'updated', ()=>
    #   beam = new TractorBeam '.tractor-beam'
    #   beam.on 'dropped', (files) ->
    #     for filepath in files
    #       console.log 'Uploading...', filepath

    # pull countries data
    @data.set 'countries', @data.parent.get 'countries'

    @data.parent.on 'set', (k, v) =>
      if k == 'countries'
        @data.set 'countries', @data.parent.get 'countries'

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
    return @client.order.get(id).then (res)=>
      if res.shippingAddress?.state
        res.shippingAddress.state = res.shippingAddress.state.toUpperCase()
      if res.shippingAddress?.country
        res.shippingAddress.country = res.shippingAddress.country.toUpperCase()

      if res.billingAddress?.state
        res.billingAddress.state = res.billingAddress.state.toUpperCase()
      if res.billingAddress?.country
        res.billingAddress.country = res.billingAddress.country.toUpperCase()

      @cancelModals()
      @loading = false
      @data.set res
      @scheduleUpdate()
    .catch (err)->
      @loading = false

  # load things but slightly differently
  reset: ()->
    @_refresh().then ()=>
      @showMessage 'Reset!'

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

  # show the save modal
  showSave: ()->
    @cancelModals()
    @showSaveModal = true
    @scheduleUpdate()

  # close all modals
  cancelModals: ()->
    clearTimeout @messageTimeoutId
    @showResetModal = false
    @showSaveModal = false
    @showMessageModal = false
    @scheduleUpdate()

  # submit the form
  _submit: ()->
    data = @data.get()

    # presence of id determines method used
    api = 'create'
    if data.id?
      api = 'update'

    @loading = true
    @client.order[api](data).then (res)=>
      @cancelModals()
      @loading = false
      @data.set res
      @showMessage 'Success!'
      @scheduleUpdate()
    .catch (err)->
      @loading = false
      @showMessage err

HanzoOrder.register()

export default class Orders
  constructor: (daisho, ps, ms, cs)->
    tag = null
    opts = {}

    ps.register 'orders',
      ->
        @el = el = document.createElement 'hanzo-orders'

        tag = (daisho.mount el)[0]
        return el
      ->
        tag.refresh()
        return @el
      ->

    ps.register 'order',
      (ps, id)->
        opts.id = id if id?
        @el = el = document.createElement 'hanzo-order'

        tag = (daisho.mount el)[0]
        tag.data.set 'id', opts.id
        return el
      (ps, id)->
        opts.id = id if id?
        tag.data.set 'id', opts.id
        tag.refresh()
        return @el
      ->

    ms.register 'Orders', ->
      ps.show 'orders'

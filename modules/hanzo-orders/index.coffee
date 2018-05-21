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
      name: 'Name'
      field: 'ShippingAddressName'
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
  showResendConfirmation: false
  showSaveModal: false
  showMessageModal: false

  loading: false

  statusOptions:
    cancelled: 'Cancelled'
    completed: 'Completed'
    locked: 'Locked'
    open: 'Open'
    'on-hold': 'On Hold'

  paymentStatusOptions:
    credit: 'Credit'
    disputed: 'Disputed'
    failed: 'Failed'
    fraudulent: 'Fraud'
    paid: 'Paid'
    refunded: 'Refunded'
    unpaid: 'Unpaid'

  fulfillmentStatusOptions:
    cancelled: 'Cancelled'
    processing: 'Processing'
    shipped: 'Shipped'
    unfulfilled: 'Unfulfilled'

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

    @on 'updated', ->
      els = @root.getElementsByClassName 'metadata-pre'
      el = els[0]
      el.innerHTML = JSON.stringify(@data.get('metadata'), null, 2) if el

  default: ->
    # pull the org information from localstorage
    org = @daisho.akasha.get('orgs')[@daisho.akasha.get('activeOrg')]
    model =
      currency: org.currency

    return model

  isShipping: ->
    return @data.get('fulfillment.status') != 'pending'

  isRefunded: ->
    return @data.get('refunded') > 0

  # load things
  _refresh: ->
    id = @data.get('id')
    if !id
      @data.clear()
      @data.set @default()
      @scheduleUpdate()
      return true

    @loading = true
    return @client.order.get(id).then (res) =>
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
  reset: ->
    @_refresh().then =>
      @showMessage 'Reset!'

  # save by using submit to validate inputs
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

  resendConfirmation: ->
    @loading = true
    @client.order.sendOrderConfirmation(@data.get('id')).then =>
      @cancelModals()
      @loading = false
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

  # show the reset modal
  showReset: ->
    @cancelModals()
    @showResetModal = true
    @scheduleUpdate()

  # show the save modal
  showSave: ->
    @cancelModals()
    @showSaveModal = true
    @scheduleUpdate()

  # show the save modal
  showResendConfirmation: ->
    @cancelModals()
    @showResendConfirmation = true
    @scheduleUpdate()

  # close all modals
  cancelModals: ->
    clearTimeout @messageTimeoutId
    @showResetModal = false
    @showResendConfirmation = false
    @showSaveModal = false
    @showMessageModal = false
    @scheduleUpdate()

  # submit the form
  _submit: ->
    data = @data.get()

    # presence of id determines method used
    api = 'create'
    if data.id?
      api = 'update'

    @loading = true
    @client.order[api](data).then (res) =>
      @cancelModals()
      @loading = false
      @data.set res
      @showMessage 'Success!'
      @scheduleUpdate()
    .catch (err) =>
      @loading = false
      @showMessage err

  getShippingAddress: ->
    return [
      @data.get('shippingAddress.line1')
      @data.get('shippingAddress.line2')
      @data.get('shippingAddress.city')
      @data.get('shippingAddress.state')
      @data.get('shippingAddress.postalCode')
      @data.get('shippingAddress.country')
    ].join ' '

  getBillingAddress: ->
    return [
      @data.get('billingAddress.line1')
      @data.get('billingAddress.line2')
      @data.get('billingAddress.city')
      @data.get('billingAddress.state')
      @data.get('billingAddress.postalCode')
      @data.get('billingAddress.country')
    ].join ' '

HanzoOrder.register()

class HanzoOrderItems extends Daisho.Views.HanzoStaticTable
  tag: 'hanzo-order-items'

  display: 100

  name: 'Orders'

  # table header configuration
  headers: [
    # {
    #   name: 'Image'
    #   field: 'Slug'
    # },
    {
      name: 'Product Name'
    },
    {
      name: 'Quantity'
    },
    {
      name: 'Price'
    },
  ]

  init: ->
    super

  doLoad: ->
    return !!@data.get('id')

  list: ->
    return @data.get 'items'

HanzoOrderItems.register()

class HanzoOrderPayments extends Daisho.Views.HanzoStaticTable
  tag: 'hanzo-order-payments'

  display: 100

  name: 'Payments'

  # table header configuration
  headers: [
    # {
    #   name: 'Image'
    #   field: 'Slug'
    # },
    {
      name: 'External Id'
    },
    {
      name: 'Type'
    },
    {
      name: 'Description'
    },
    {
      name: 'Amount'
    },
    {
      name: 'Status'
    },
    {
      name: 'Meta'
    },
  ]

  init: ->
    super

  doLoad: ->
    return !!@data.get('id')

  list: ->
    return @client.order.payments @data.get('id')

  getExternalId: (payment) ->
    switch payment.type
      when 'stripe'
        return payment.account.chargeId

  getExternalLink: (payment) ->
    switch payment.type
      when 'stripe'
        return ->
          url = '//dashboard.stripe.com/payments/' + payment.account.chargeId
          win = window.open url, '_blank'
          win.focus()

  getMeta: (payment) ->
    switch payment.type
      when 'stripe'
        return 'Last 4: ' + payment.account.lastFour

HanzoOrderPayments.register()

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

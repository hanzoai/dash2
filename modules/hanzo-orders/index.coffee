import Daisho  from 'daisho/src'
import Promise from 'broken'
import numeral from 'numeral'
import { isRequired } from 'daisho/src/views/middleware'

import ordersHtml from './templates/orders.pug'
import orderHtml from './templates/order.pug'
import css  from './css/app.styl'
# import TractorBeam from 'tractor-beam'

# import to register
import ShippingAddressState from 'shop.js/src/controls/checkout/shippingaddress-state'
import ShippingAddressCountry from 'shop.js/src/controls/checkout/shippingaddress-country'

class HanzoOrders extends Daisho.Views.HanzoDynamicTable
  tag: 'hanzo-orders'
  html: ordersHtml
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
  html: orderHtml
  css:  css
  _dataStaleField:  'id'
  showResetModal: false
  showResendConfirmationModal: false
  showResendRefundConfirmationModal: false
  showResendFulfillmentConfirmationModal: false
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
      # clear out metadata due to it being null sometimes
      @data.set 'subscriptions', []
      @data.set 'mode', ''
      @data.set 'metadata', {}
      @data.set res
      @scheduleUpdate()
    .catch (err)->
      @loading = false

  # load things but slightly differently
  reset: ->
    @_refresh().then =>
      @showMessage 'Reset!'

  isCrypto: ->
    return ['ethereum', 'bitcoin'].indexOf(@data.get('type')) > -1

  isFiat: ->
    return @data.get('type') == 'stripe'

  isEcommerce: ->
    return @data.get('mode') == ''

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

  resendRefundConfirmation: ->
    @loading = true
    @client.order.sendRefundConfirmation(@data.get('id')).then =>
      @cancelModals()
      @loading = false
      @showMessage 'Success!'
      @scheduleUpdate()
    .catch (err) =>
      @loading = false
      @showMessage err

  resendFulfillmentConfirmation: ->
    @loading = true
    @client.order.sendFulfillmentConfirmation(@data.get('id')).then =>
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
    @showResendConfirmationModal = true
    @scheduleUpdate()

  # show the save modal
  showRefundConfirmation: ->
    @cancelModals()
    @showResendRefundConfirmationModal = true
    @scheduleUpdate()

  # show the save modal
  showRefundConfirmation: ->
    @cancelModals()
    @showResendFulfillmentConfirmationModal = true
    @scheduleUpdate()

  # close all modals
  cancelModals: ->
    clearTimeout @messageTimeoutId
    @showResetModal = false
    @showResendConfirmationModal = false
    @showResendRefundConfirmationModal = false
    @showResendFulfillmentConfirmationModal = false
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
      # clear out metadata due to it being null sometimes
      @data.set 'mode', ''
      @data.set 'metadata', {}
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

  showInvoice: ->
    items = @data.get 'items'
    return @data.get('total') != 0 || items && items.length == 0

  showRecurring: ->
    subscriptions = @data.get 'subscriptions'
    return subscriptions && subscriptions.length > 0

  recurringSubtotal: ->
    subscriptions = @data.get 'subscriptions'
    subtotal = 0
    for s in subscriptions
      subtotal += s.subtotal
    return subtotal

  recurringShipping: ->
    subscriptions = @data.get 'subscriptions'
    shipping = 0
    for s in subscriptions
      shipping += s.shipping
    return shipping

  recurringTax: ->
    subscriptions = @data.get 'subscriptions'
    tax = 0
    for s in subscriptions
      tax += s.tax
    return tax

  recurringTotal: ->
    subscriptions = @data.get 'subscriptions'
    total = 0
    for s in subscriptions
      total += s.total
    return total

HanzoOrder.register()

class HanzoOrderItems extends Daisho.Views.HanzoStaticTable
  tag: 'hanzo-order-items'

  display: 100

  name: 'Order Items'

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

    @data.on 'set', (k)=>
      if k == 'items'
        @_refresh true

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

    @data.on 'set', (k)=>
      if k == 'items'
        @_refresh true

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

class HanzoOrderWallet extends Daisho.Views.HanzoStaticTable
  tag: 'hanzo-order-wallet'

  display: 100

  name: 'Wallet Addresses'

  # table header configuration
  headers: [
    {
      name: 'Name'
    },
    {
      name: 'Address'
    },
    {
      name: 'Type'
    },
    {
      name: 'Created At'
    }
  ]

  init: ->
    super

  doLoad: ->
    return !!@data.get('id') && !!@data.get('walletId')

  list: ->
    return @client.wallet.get(@data.get('walletId')).then (res)->
      return res.accounts

  getExternalLink: (address) ->
    switch address.type
      when 'ethereum'
        return ->
          url = '//etherscan.io/address/' + address.address
          win = window.open url, '_blank'
          win.focus()
      when 'ethereum-ropsten'
        return ->
          url = '//ropsten.etherscan.io/address/' + address.address
          win = window.open url, '_blank'
          win.focus()
      when 'bitcoin'
        return ->
          url = '//blockchain.info/address/' + address.address
          win = window.open url, '_blank'
          win.focus()
      when 'bitcoin-testnet'
        return ->
          url = '//testnet.blockchain.info/address/' + address.address
          win = window.open url, '_blank'
          win.focus()

HanzoOrderWallet.register()

export default class Orders
  constructor: (daisho, ps, ms, cs)->
    ps.register 'orders',
      ->
        @el = el = document.createElement 'hanzo-orders'

        @tag = (daisho.mount el)[0]
        return el
      ->
        @tag.refresh()
        return @el
      ->
        return @el

    ps.register 'order',
      (ps, id)->
        @id = id if id?
        @el = el = document.createElement 'hanzo-order'

        @tag = (daisho.mount el)[0]
        @tag.data.set 'id', @id
        return el
      (ps, id)->
        @id = id if id?
        @tag.data.set 'id', @id
        @tag.refresh()
        return @el
      ->
        return @el

    ms.register 'Orders', ->
      ps.show 'orders'

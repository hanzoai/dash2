import Daisho  from 'daisho/src'
import Promise from 'broken'
import numeral from 'numeral'
import { isRequired } from 'daisho/src/views/middleware'

import usersHtml from './templates/users.pug'
import userHtml from './templates/user.pug'
import userAddTransactionHtml from './templates/user-add-transaction.pug'
import userTransactionsHtml from './templates/user-transactions.pug'
import userWalletHtml from './templates/user-wallet.pug'
import css  from './css/app.styl'
# import TractorBeam from 'tractor-beam'

UserUpdateBalanceEvent = 'user-update-balance'

class HanzoUsers extends Daisho.Views.HanzoDynamicTable
  tag: 'hanzo-users'
  html: usersHtml
  css:  css

  name: 'Users'

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
      name: 'Name'
      field: 'FirstName'
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
    @services.page.show 'user', ''

  list: (opts) ->
    return @client.user.list opts

HanzoUsers.register()

class HanzoUser extends Daisho.Views.Dynamic
  tag: 'hanzo-user'
  html: userHtml
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
    return @client.user.get(id).then (res) =>
      @cancelModals()
      @loading = false
      @data.set res
      @scheduleUpdate()
    .catch (err)->
      @loading = false

  # load things but slightly differently
  reset: ()->
    @_refresh(true).then ()=>
      @showMessage 'Reset!'

  resetPassword: ->
    @loading = true
    @scheduleUpdate()

    @client.user.resetPassword(@data.get('id')).then (res) =>
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
    data = @data.get()

    # presence of id determines method used
    api = 'create'
    if data.id?
      api = 'update'

    @loading = true
    @client.user[api](data).then (res)=>
      @cancelModals()
      @loading = false
      @data.set res
      @showMessage 'Success!'
      @scheduleUpdate()
    .catch (err)->
      @loading = false
      @showMessage err

HanzoUser.register()

class HanzoUsers extends Daisho.Views.HanzoDynamicTable
  tag: 'hanzo-users'
  html: userHtml
  css:  css

  name: 'Users'

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
      name: 'Name'
      field: 'FirstName'
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
    @services.page.show 'user', ''

  list: (opts) ->
    return @client.user.list opts

HanzoUsers.register()

class HanzoUserOrders extends Daisho.Views.HanzoStaticTable
  tag: 'hanzo-user-orders'

  display: 100

  name: 'Orders'

  # table header configuration
  headers: [
    # {
    #   name: 'Image'
    #   field: 'Slug'
    # },
    {
      name: 'Type'
    },
    {
      name: 'Amount'
    },
    {
      name: 'Status'
    },
    {
      name: 'Created On'
    },
    {
      name: 'Last Updated'
    }
  ]

  init: ->
    super

  doLoad: ->
    return !!@data.get('id')

  list: ->
    return @client.user.orders @data.get('id')

HanzoUserOrders.register()

class HanzoUserTransactions extends Daisho.Views.HanzoStaticTable
  tag: 'hanzo-user-transactions'
  html: userTransactionsHtml

  display: 100

  name: 'Transactions'

  # table header configuration
  headers: [
    {
      name: 'Type'
    },
    {
      name: 'Amount'
    },
    {
      name: 'Notes'
    },
    {
      name: 'Source'
    },
    {
      name: 'Destination'
    },
    {
      name: 'Created On'
    }
  ]

  init: ->
    super

  doLoad: ->
    return !!@data.get('id')

  list: ->
    return @client.user.transactions(@data.get('id')).then (res) =>
      data = res.data[@data.get('currency')]?.transactions
      return data ? []

  renderKindId: (kind, id) ->
    if kind
      return kind + '/' + id
    return 'None'

  showTxKindId: (kind, id) ->
    switch kind
      when 'order'
        return @show 'order', id
      when 'user'
        return @show 'user', id
      else
        return ->

HanzoUserTransactions.register()

# disabled for now
class HanzoUserWallet extends Daisho.Views.HanzoDynamicTable
  tag: 'hanzo-user-wallet'
  html: userWalletHtml

  display: 100

  name: 'Wallet'

  # count field name
  countField: 'wallet.count'

  # results field name
  resultsField: 'wallet.results'

  # table header configuration
  headers: [
    {
      name: 'QR Code'
      field: 'Address'
    },
    {
      name: 'Address'
      field: 'Address'
    }
  ]

  init: ->
    super

  _onheader: ->
    return (e) -> return true

  getFacetQuery: ->
    return ''

  doLoad: ->
    return !!@data.get('id')

  getFacetQuery: ->
    return ''

  list: ->
    return @client.user.wallet(@data.get('id')).then (res) =>
      data = res.data[@data.get('currency')]?.transactions
      return data ? []

HanzoUserWallet.register()

class HanzoUserReferrers extends Daisho.Views.HanzoStaticTable
  tag: 'hanzo-user-referrers'

  display: 100

  name: 'Referrers'

  # count field name
  countField: 'referrers.count'

  # results field name
  resultsField: 'referrers.results'

  # table header configuration
  headers: [
    # {
    #   name: 'Image'
    #   field: 'Slug'
    # },
    {
      name: 'Referral Token'
    },
    {
      name: 'Created On'
    },
  ]

  init: ->
    super

  doLoad: ->
    return !!@data.get('id')

  list: ->
    return @client.user.referrers @data.get('id')

HanzoUserReferrers.register()

class HanzoUserReferrals extends Daisho.Views.HanzoStaticTable
  tag: 'hanzo-user-referrals'

  display: 100

  name: 'Referrals'

  # count field name
  countField: 'referrals.count'

  # results field name
  resultsField: 'referrals.results'

  # table header configuration
  headers: [
    # {
    #   name: 'Image'
    #   field: 'Slug'
    # },
    {
      name: 'User Id'
      field: 'UserId'
    },
    {
      name: 'Referral Token'
      field: 'Referrer.Id'
    },
    {
      name: 'Referred On'
      field: 'CreatedAt'
    },
  ]

  init: ->
    super

  doLoad: ->
    return !!@data.get('id')

  list: ->
    return @client.user.referrals @data.get('id')

  show: ->

HanzoUserReferrals.register()

class HanzoUserBalances extends Daisho.Views.HanzoStaticTable
  tag: 'hanzo-user-balances'

  display: 100

  name: 'Balances'

  # count field name
  countField: 'balances.count'

  # results field name
  resultsField: 'balances.results'

  # table header configuration
  headers: [
    # {
    #   name: 'Image'
    #   field: 'Slug'
    # },
    {
      name: 'Currency'
    },
    {
      name: 'Balance'
    },
  ]

  init: ->
    super

    @on 'mount', =>
      @mediator.on UserUpdateBalanceEvent, =>
        @_refresh true
    @on 'unmount', =>
      @mediator.off UserUpdateBalanceEvent

  doLoad: ->
    return !!@data.get('id')

  list: ->
    return @client.user.transactions(@data.get('id')).then (res) =>
      vs = []
      for k, v of res.data
        v.currency = k
        vs.push v
      return vs

  showTransaction: (currency) ->
    return () =>
      @show('user-transactions',
        id: @parent.data.get 'id'
        currency: currency
      )()

HanzoUserBalances.register()

class HanzoUserAddTransaction extends Daisho.El.Form
  tag: 'hanzo-user-add-transaction'
  html: userAddTransactionHtml

  configs:
    type:     [ isRequired ]
    amount:   [ isRequired ]
    currency: [ isRequired ]

  typeOptions:
    deposit: 'Deposit'
    withdraw: 'Withdraw'

  currencyOptions: {}

  loading: false
  errorMessage: ''

  init: ->
    @data = @data.ref 'addTransaction'
    @data.set 'type', 'deposit'
    @data.set 'currency', 'usd'
    @data.set 'amount', 0

    currenciesToSort = Object.keys @currencies.data
    currenciesToSort.sort()

    @currencyOptions = {}

    for currency in currenciesToSort
      @currencyOptions[currency] = currency.toUpperCase()

    super

  _submit: ->
    return if @loading

    if @data.get('amount') <= 0
      @errorMessage = 'Amount must greater than 0.'
      @scheduleUpdate()
      return

    @loading = true
    @errorMessage = ''
    @scheduleUpdate()

    type = @data.get 'type'
    opts =
      type:     type
      amount:   @data.get 'amount'
      currency: @data.get 'currency'

    switch type
      when 'deposit'
        opts.destinationId =    @parent.data.get 'id'
        opts.destinationKind =  'user'
      when 'withdraw'
        opts.sourceId =     @parent.data.get 'id'
        opts.sourceKind =   'user'

    @client.transaction.create(opts).then (res) =>
      @loading = false
      @mediator.trigger UserUpdateBalanceEvent

      @parent.showMessage("A #{ type } of #{ @utils.currency.renderCurrency(@data.get('currency'), @data.get('amount')) } has been issued.") if @parent.showMessage
      @data.set 'amount', 0
      @scheduleUpdate()
    .catch (err) =>
      @loading = false
      @errorMessage = err.message
      @scheduleUpdate()

HanzoUserAddTransaction.register()

export default class Users
  constructor: (daisho, ps, ms, cs)->
    tag = null
    opts = {}

    ps.register 'users',
      ->
        @el = el = document.createElement 'hanzo-users'

        tag = (daisho.mount el)[0]
        return el
      ->
        tag.refresh()
        return @el
      ->

    ps.register 'user',
      (ps, id)->
        opts.id = id if id?
        @el = el = document.createElement 'hanzo-user'

        tag = (daisho.mount el)[0]
        tag.data.set 'id', opts.id
        return el
      (ps, id)->
        opts.id = id if id?
        tag.data.set 'id', opts.id
        tag.refresh()
        return @el
      ->

    ps.register 'user-transactions',
      (ps, options)->
        opts = options if options?
        @el = el = document.createElement 'hanzo-user-transactions'

        tag = (daisho.mount el)[0]
        tag.data.set 'id', opts.id
        tag.data.set 'currency', opts.currency
        return el
      (ps, options)->
        opts = options if options?
        tag.data.set 'id', opts.id
        tag.data.set 'currency', opts.currency
        tag.refresh()
        return @el
      ->

    ms.register 'Users', ->
      ps.show 'users'

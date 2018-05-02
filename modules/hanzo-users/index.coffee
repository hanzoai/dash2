import Daisho  from 'daisho/src'
import Promise from 'broken'
import numeral from 'numeral'
import { isRequired } from 'daisho/src/views/middleware'

import html1 from './templates/users.pug'
import html2 from './templates/user.pug'
import html3 from './templates/user-orders.pug'
import html4 from './templates/user-referrers.pug'
import html5 from './templates/user-referrals.pug'
import css  from './css/app.styl'
# import TractorBeam from 'tractor-beam'

class HanzoUsers extends Daisho.Views.HanzoDynamicTable
  tag: 'hanzo-users'
  html: html1
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
  html: html2
  css:  css
  _dataStaleField:  'id'
  showResetModal: false
  showResetPasswordModal: false
  showSaveModal: false
  showMessageModal: false
  password: null

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
    @_refresh().then ()=>
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

class HanzoUserOrders extends Daisho.Views.HanzoDynamicTable
  tag: 'hanzo-user-orders'
  html: html3
  css:  css

  display: 100

  name: 'Orders'

  # count field name
  countField: 'orders.count'

  # results field name
  resultsField: 'orders.results'

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

  init: ->
    super

  _onheader: ->
    return (e) -> return true

  doLoad: ->
    return !!@data.get('id')

  getFacetQuery: ->
    return ''

  list: ->
    return @client.user.orders @data.get('id')

HanzoUserOrders.register()

class HanzoUserReferrers extends Daisho.Views.HanzoDynamicTable
  tag: 'hanzo-user-referrers'
  html: html4
  css:  css

  display: 100

  name: 'Referrers'

  configs:
    'filter': []

  # count field name
  countField: 'referrals.count'

  # results field name
  resultsField: 'referrals.results'

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
      name: 'Referral Token'
      field: 'Id'
    },
    {
      name: 'Created On'
      field: 'CreatedAt'
    },
  ]

  init: ->
    super

  _onheader: ->
    return (e) -> return true

  doLoad: ->
    return !!@data.get('id')

  getFacetQuery: ->
    return ''

  list: ->
    return @client.user.referrers @data.get('id')

HanzoUserReferrers.register()

class HanzoUserReferrals extends Daisho.Views.HanzoDynamicTable
  tag: 'hanzo-user-referrals'
  html: html5
  css:  css

  display: 100

  name: 'Referrals'

  configs:
    'filter': []

  # count field name
  countField: 'referrals.count'

  # results field name
  resultsField: 'referrals.results'

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

  _onheader: ->
    return (e) -> return true

  doLoad: ->
    return !!@data.get('id')

  getFacetQuery: ->
    return ''

  list: ->
    return @client.user.referrals @data.get('id')

  show: ->

HanzoUserReferrals.register()

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

    ms.register 'Users', ->
      ps.show 'users'

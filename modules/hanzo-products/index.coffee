import Daisho  from 'daisho/src'
import Promise from 'broken'
import numeral from 'numeral'
import { isRequired } from 'daisho/src/views/middleware'

import html1 from './templates/products.pug'
import html2 from './templates/product.pug'
import css  from './css/app.styl'
# import TractorBeam from 'tractor-beam'

class HanzoProducts extends Daisho.Views.Dynamic
  tag: 'hanzo-products'
  html: html1
  css:  css

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
    {
      name: 'Image'
      field: 'Slug'
      onclick: 'onheader'
    },
    {
      name: 'Name'
      field: 'Name'
      onclick: 'onheader'
    },
    {
      name: 'Slug'
      field: 'Slug'
      onclick: 'onheader'
    },
    {
      name: 'SKU'
      field: 'SKU'
      onclick: 'onheader'
    },
    {
      name: 'Price'
      field: 'Price'
      onclick: 'onheader'
    },
    {
      name: 'Created On'
      field: 'CreatedAt'
      onclick: 'onheader'
    },
    {
      name: 'Last Updated'
      field: 'UpdatedAt'
      onclick: 'onheader'
    }
  ]

  openFilter: false

  init: ->
    super

  # generate header onclick events
  onheader: (header)->
    (e)=>
      if @data.get('sort') == header.field
        @data.set 'asc', !@data.get('asc')
      else
        @data.set 'asc', true
      @data.set 'sort', header.field
      @_refresh(e)

  create: ()->
    @services.page.show 'product', ''

  _refresh: (e)->
    if @initialized && !e?
      return
    org = @daisho.akasha.get('orgs')[@daisho.akasha.get('activeOrg')]
    @data.set 'facets.currency', org.currency

    @initialized = true

    #default sorting
    if !@data.get('sort')?
      @data.set 'sort', 'UpdatedAt'
      @data.set 'asc', false

    @loading = true
    @scheduleUpdate()

    # filter = @data.get 'filter'
    opts =
      sort: if @data.get('asc') then '-' + @data.get('sort') else @data.get('sort')
      display: 20
      page: 1

    q = @data.get 'facets.query'
    opts.q = q if q

    options = @data.get 'facets.options'
    facets =
      string: []
      range: []

    hasFacets = false
    if options && options.string
      for k, v of options.string
        hasFacets = true

        vals = []

        for k2, v2 of v
          if v2
            facets.string.push
              name: k
              value: k2

    if options && options.range
      for k, v of options.range
        hasFacets = true
        facets.range.push
          name: k
          value:
            start: v.from
            end: v.to

    if hasFacets
      opts.facets = JSON.stringify facets

    return @client.product.list(opts).then (res)=>
      @loading = false
      @data.set 'count', res.count
      @data.set 'products', res.models
      @data.set 'facets.results', undefined
      @data.set 'facets.results', res.facets
      @scheduleUpdate()

  show: (id, opts) ->
    return ()=>
      @services.page.show id, opts

  toggleFilterMenu: ()->
    @openFilter = !@openFilter

HanzoProducts.register()

class HanzoProduct extends Daisho.Views.Dynamic
  tag: 'hanzo-product'
  html: html2
  css:  css
  _dataStaleField:  'id'
  showResetModal: false
  showSaveModal: false
  showMessageModal: false

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
    slug:        [isRequired]
    name:        [isRequired]
    price:       [isRequired]
    listPrice:   [isRequired]

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
    return @client.product.get(id).then (res)=>
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
    @client.product[api](data).then (res)=>
      @cancelModals()
      @loading = false
      @data.set res
      @showMessage 'Success!'
      @scheduleUpdate()
    .catch (err)->
      @loading = false
      @showMessage err

HanzoProduct.register()

export default class Products
  constructor: (daisho, ps, ms, cs)->
    tag = null
    opts = {}

    ps.register 'products',
      ->
        @el = el = document.createElement 'hanzo-products'

        tag = (daisho.mount el)[0]
        return el
      ->
        tag.refresh()
        return @el
      ->

    ps.register 'product',
      (ps, id)->
        opts.id = id if id?
        @el = el = document.createElement 'hanzo-product'

        tag = (daisho.mount el)[0]
        tag.data.set 'id', opts.id
        return el
      (ps, id)->
        opts.id = id if id?
        tag.data.set 'id', opts.id
        tag.refresh()
        return @el
      ->

    ms.register 'Products', ->
      ps.show 'products'

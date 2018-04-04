import Daisho  from 'daisho'
import Promise from 'broken'
import moment  from 'moment-timezone'
import numeral from 'numeral'

import html from './templates/home.pug'
import css  from './css/app.styl'

rfc3339  =  Daisho.util.time.rfc3339
yyyymmdd =  Daisho.util.time.yyyymmdd

class HanzoHome extends Daisho.Views.Dynamic
  tag: 'hanzo-home'
  html: html
  css:  css
  days: 90

  configs:
    'filter': []

  counters:[
    ['order.count','Orders']
    ['order.revenue','Sales']
    ['order.shipped.cost','Shipping Costs']
    ['order.shipped.count','Orders Shipped']
    ['order.refunded.amount','Refunds']
    ['order.refunded.count','Full Refunds Issued']
    ['order.returned.count','Returns Issued']
    ['user.count','Users']
    ['subscriber.count','Subscribers']
    ['product.wycZ3j0kFP0JBv.sold','Earbuds Sold']
    ['product.wycZ3j0kFP0JBv.shipped.count','Earbuds Shipped']
    ['product.wycZ3j0kFP0JBv.returned.count','Earbuds Returned']
  ]

  _dataStaleField: 'filter'

  init: ->
    # filter = @data.get 'filter'
    # if !filter
    @data.set 'filter', [moment('2015-01-01').format(yyyymmdd), moment().format(yyyymmdd)]

    for counter in @counters
      models = Daisho.Graphics.Model.new()
      for model in models
        model.fmt.y = (n)->
          return parseInt n, 10
      @data.set 'counters.' + counter[0], models

      currency = (n)->
        n = n / 100
        # if n < 1000
        #   return numeral(n).format '$0a'
        return numeral(n).format '$0,0'

      @data.set 'counters.order.revenue.0.fmt.y', currency
      @data.set 'counters.order.shipped.cost.0.fmt.y', currency
      @data.set 'counters.order.refunded.amount.0.fmt.y', currency

    @data.set 'summaryChart', Daisho.Graphics.Model.new()
    @data.set 'summaryChart.0.axis.x.name', 'Date'
    @data.set 'summaryChart.0.axis.y.name', 'Amount'
    @data.set 'summaryChart.0.type', 'line'
    @data.set 'summaryChart.0.series', 'Sales'
    @data.set 'summaryChart.0.fmt.x', (n)->
      return moment(n).format rfc3339
    @data.set 'summaryChart.0.fmt.y', (n)->
      return n / 100
    @data.set 'summaryChart.0.axis.x.ticks', (n)->
      return moment(n).format 'MM/DD'
    @data.set 'summaryChart.0.axis.y.ticks', (n)->
      return numeral(n).format '$0,0'

    @data.set 'summaryChart.0.tip.x', (n)->
      return moment(n).format 'MM/DD/YYYY'
    @data.set 'summaryChart.0.tip.y', (n)->
      return numeral(n).format '$0,0.00'

    @data.set 'summaryChart.1', Daisho.Graphics.Model.newSeries()
    @data.set 'summaryChart.1.axis.x.name', 'Date'
    @data.set 'summaryChart.1.axis.y.name', 'Amount'
    @data.set 'summaryChart.1.type', 'line'
    @data.set 'summaryChart.1.series', 'Refunds'
    @data.set 'summaryChart.1.fmt.x', (n)->
      return moment(n).format rfc3339
    @data.set 'summaryChart.1.fmt.y', (n)->
      return n / 100
    @data.set 'summaryChart.1.axis.x.ticks', (n)->
      return moment(n).format 'MM/DD'
    @data.set 'summaryChart.1.axis.y.ticks', (n)->
      return numeral(n).format '$0,0'

    @data.set 'summaryChart.1.tip.x', (n)->
      return moment(n).format 'MM/DD/YYYY'
    @data.set 'summaryChart.1.tip.y', (n)->
      return numeral(n).format '$0,0.00'

    @data.set 'summaryChart.2', Daisho.Graphics.Model.newSeries()
    @data.set 'summaryChart.2.axis.x.name', 'Date'
    @data.set 'summaryChart.2.axis.y.name', 'Amount'
    @data.set 'summaryChart.2.type', 'line'
    @data.set 'summaryChart.2.series', 'Shipping'
    @data.set 'summaryChart.2.fmt.x', (n)->
      return moment(n).format rfc3339
    @data.set 'summaryChart.2.fmt.y', (n)->
      return n / 100
    @data.set 'summaryChart.2.axis.x.ticks', (n)->
      return moment(n).format 'MM/DD'
    @data.set 'summaryChart.2.axis.y.ticks', (n)->
      return numeral(n).format '$0,0'

    @data.set 'summaryChart.2.tip.x', (n)->
      return moment(n).format 'MM/DD/YYYY'
    @data.set 'summaryChart.2.tip.y', (n)->
      return numeral(n).format '$0,0.00'

    @data.set 'summaryChart.3', Daisho.Graphics.Model.newSeries()
    @data.set 'summaryChart.3.type', 'notes'

    super

  generateTimestamps: (startTime, endTime)->
    st = moment startTime
    earliest = moment @parentData.get('orgs')[@parentData.get('activeOrg')].createdAt
    if st.diff(earliest) < 0
      st = earliest

    st.seconds 0
    st.minutes 0
    st.hour 0
    et = moment endTime
    et.seconds 0
    et.minutes 0
    et.hour 0
    et.add 1, 'day'

    @days = Math.min Math.ceil(et.diff(st, 'day')), 90

    timestamps = []
    if et.diff(st, 'day') <= 1
      time = moment st
      for i in [0..23]
        after = time.format rfc3339
        time.add 1, 'hour'
        before = time.format rfc3339
        timestamps[i] = [after, before]
    else
      time = moment et
      for i in [@days-1..0]
        before = time.format rfc3339
        time.subtract 1, 'day'
        after = time.format rfc3339
        timestamps[i] = [after, before]

    return timestamps

  _refresh: ->
    filter = @data.get 'filter'
    for counter in @counters
      # Counters
      @refreshCounter counter[0], counter[1], filter[0], filter[1]

    # Chart
    ps1 = @refreshChartSeries 'order.revenue', 0, filter[0], filter[1]
    ps2 = @refreshChartSeries 'order.refunded.amount', 1, filter[0], filter[1]
    ps3 = @refreshChartSeries 'order.shipped.cost', 2, filter[0], filter[1]
    p1 = @refreshNotes 3, filter[0], filter[1]

    ps = ps1.concat(ps2).concat(ps3)
    ps.push p1

    Promise.settle ps
      .then (data)=>
        @scheduleUpdate()

    return true

  refreshNotes: (seriesIndex, startTime, endTime)->
    models = @data.get 'summaryChart'
    model = models[seriesIndex]
    model.xs = xs = []
    model.ys = ys = []

    timestamps = @generateTimestamps startTime, endTime
    opts =
      after:    timestamps[0][0]
      before:   timestamps[timestamps.length-1][1]

    @scheduleUpdate()
    return @client.note.search(opts).then (res)=>
      for i, timestamp of timestamps
        # this is horrible
        for note in res
          # using [) is weird because we use the opposite system on the server
          if moment(note.time).isBetween timestamp[0], timestamp[1], null, '[)'
            xs.push timestamp[0]
            ys.push 'note id: ' +  note.id + '\nfrom: ' + note.source + '@' + note.time + '\n' + note.message

      @data.set 'summaryChart', models

  refreshChartSeries: (tag, seriesIndex, startTime, endTime)->
    models = @data.get 'summaryChart'
    model = models[seriesIndex]
    xs = []
    ys = []

    timestamps = @generateTimestamps startTime, endTime

    ps = for i, timestamp of timestamps
      opts =
        tag: tag
        period: 'hourly'
        after: timestamp[0]
        before: timestamp[1]

      model.xs[i] = xs[i] = timestamp[0]
      model.ys[i] = ys[i] = 0
      do(i, opts)=>
        @client.counter.search(opts).then (res)->
          ys[i] = res.count

    @scheduleUpdate()

    Promise.settle ps
      .then (data)=>
        model.xs = xs
        model.ys = ys
        @data.set 'summaryChart', models

    return ps

  refreshCounter: (tag, name, startTime, endTime)->
    opts =
      tag: tag

    st = moment startTime
    et = moment endTime

    if moment(startTime).format(yyyymmdd)== '2015-01-01' && endTime == moment().format(yyyymmdd)
      opts.period = 'total'
    else if et.diff(st, 'days') >= 31
      opts.period = 'monthy' #ummmm
      opts.after = st.format rfc3339
      opts.before = et.format rfc3339
    else
      opts.period = 'hourly'
      opts.after = st.format rfc3339
      opts.before = et.format rfc3339

    @client.counter.search(opts).then((res)=>
      console.log tag, res
      path = 'counters.' + tag
      v = @data.get path
      v[0].ys[0] = res.count
      v[0].xs[0] = name
      v[0].series = 'All Time'
      if opts.period != 'total'
        v[0].series = 'From ' + st.format(yyyymmdd) + ' to ' + et.format(yyyymmdd)
      @data.set path, v
      @scheduleUpdate()
    ).catch (err)->
      console.log err.stack

HanzoHome.register()

export default class Home
  constructor: (daisho, ps, ms, cs)->
    tag = null
    el = null

    ps.register 'home',
      ->
        el = document.createElement 'hanzo-home'

        tag = (daisho.mount el)[0]
        return el
      ->
        tag.refresh()
        return el
      ->

    ms.register 'Home', ->
      ps.show 'home'

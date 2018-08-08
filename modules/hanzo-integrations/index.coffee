import Daisho  from 'daisho/src'
import Promise from 'broken'
import numeral from 'numeral'
import { isRequired } from 'daisho/src/views/middleware'

import integrationsHtml from './templates/integrations.pug'
import integrationHtml from './templates/integration.pug'
import css  from './css/app.styl'

class HanzoIntegrations extends Daisho.El.Form
  tag: 'hanzo-integrations'
  html: integrationsHtml
  css:  css

  init: ->
    super

HanzoIntegrations.register()

class HanzoSingleIntegration extends Daisho.El.Form
  tag: 'hanzo-single-integration'
  html: integrationHtml
  css:  css

  init: ->
    super

HanzoSingleIntegration.register()

class HanzoMultiIntegration extends Daisho.El.Form
  tag: 'hanzo-multi-integration'
  html: integrationHtml
  css:  css

  init: ->
    super

HanzoMultiIntegration.register()

export default class Integrations
  constructor: (daisho, ps, ms, cs)->
    tag = null
    opts = {}

    ps.register 'integrations',
      ->
        @el = el = document.createElement 'hanzo-integrations'

        tag = (daisho.mount el)[0]
        return el
      ->
        tag.refresh()
        return @el
      ->

    ms.register 'Integrations', ->
      ps.show 'integrations'

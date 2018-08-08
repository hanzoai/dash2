import Daisho  from 'daisho/src'
import { isRequired } from 'daisho/src/views/middleware'

yieldHtml = '</yield>'

class Drag extends Daisho.El.View
  tag: 'drag'
  html: yieldHtml
  ondragstart: ()->
  ondragend: ()->

Drag.register()

class DragDrop extends Daisho.El.Input
  tag: 'drop'
  html: yieldHtml

  ondragenter: ()->
  ondragover: ()->
  ondragleave: ()->

Drop.register()



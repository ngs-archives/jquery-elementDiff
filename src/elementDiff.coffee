#
# jQuery Element Diff
# https://github.com/ngs/jquery-elementDiff
#
# Copyright (c) 2013 Atsushi Nagase
# Licensed under the MIT license.
#
(($) ->

  console = window.console
  map     = $.map
  extend  = $.extend
  inArray = $.inArray

  #----------------------------------------------
  # jquery-allAttributes plugin 0.1.0
  #----------------------------------------------

  getAttributes = (element)->
    attrs = element.attributes
    hash = {}
    for attr in attrs
      names = attr.name.split '-'
      value = attr.value
      ref = hash
      if /^(\d[\d\.]*)$/.test value
        value = parseFloat(value)
      else if /^(true|false)$/.test value
        value = value is 'true'
      while names.length > 1
        name = names.shift()
        ref[name] = '_': ref[name] if /^(number|string|boolean)$/.test typeof ref[name]
        ref[name] = {} unless ref[name]
        ref = ref[name]
      name = names[0]
      if typeof ref[name] is 'object'
        ref[name]['_'] = value
      else
        ref[name] = value
    hash

  #----------------------------------------------

  duplicate = (object)->
    extend {}, object

  isEmptyObject = (obj)->
    return no unless obj && typeof obj is 'object'
    for key of obj
      return no if Object.prototype.hasOwnProperty.call(obj, key)
    yes

  diffObjects = (obj1, obj2)->
    obj1 = duplicate obj1
    obj2 = duplicate obj2
    diff = {}
    for key, value of obj1
      value2 = obj2[key]
      delete obj2[key]
      if /^(string|number|boolean)$/.test(typeof value2) or value2 instanceof Array
        diff[key] = value2 if value2 != value
      else if typeof value2 is 'object'
        obj = diffObjects value, value2
        diff[key] = obj unless isEmptyObject obj
      else
        diff[key] = null
    extend diff, obj2

  class ElementDiff
    constructor: (element)->
      @element = element

    toString: -> "[ElementDiff: #{@element[0]}]"

    getDiff: (element2)->
      return unless element2 && element2.size()

    diffAttributes: (element2)->
      element2 = $ element2
      attrs1 = @element.attr()
      attrs2 = element2.attr()
      diffObjects attrs1, attrs2



  #----------------------------------------------

  $.elementDiff =
    diffObjects: diffObjects
    isEmptyObject: isEmptyObject

  $.fn.elementDiff = -> new ElementDiff @

  $.fn.getElementDiff = (element2)->
    @elementDiff().getDiff(element2)

  _attr = $.fn.attr
  $.fn.attr =->
    if arguments.length
      _attr.apply @, arguments
    else if @[0]
      getAttributes @[0]

  @
) jQuery

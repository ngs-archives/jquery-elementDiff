#
# jQuery Element Diff
# https://github.com/ngs/jquery-elementDiff
#
# Copyright (c) 2013 Atsushi Nagase
# Licensed under the MIT license.
#
(($) ->
  "use strict"

  # console = window.console
  map     = $.map
  extend  = $.extend
  inArray = $.inArray

  duplicate = (object)->
    extend {}, object

  isEmptyObject = (obj)->
    return no unless obj && typeof obj is 'object'
    for key of obj
      return no if Object.prototype.hasOwnProperty.call(obj, key)
    yes

  VALUE_REGEX = /^(string|number|boolean)$/
  isValue = (obj)->
    !obj or VALUE_REGEX.test(typeof obj) or obj instanceof Array

  diffObjects = (obj1, obj2)->
    obj1 = duplicate obj1
    obj2 = duplicate obj2
    diff = {}
    for key, value of obj1
      value2 = obj2[key]
      delete obj2[key]
      if isValue value2
        diff[key] = value2 if value2 != value
      else if typeof value2 is 'object'
        obj = diffObjects value, value2
        diff[key] = obj unless isEmptyObject obj
      else
        diff[key] = null
    extend diff, obj2

  flattenAttributes = (attrs, attrs2 = {}, prefix = null)->
    for key, value of attrs
      if key is '_'
        key = prefix
      else if prefix
        key = "#{prefix}-#{key}"
      if isValue value
        attrs2[key] = value
      else
        flattenAttributes value, attrs2, key
    attrs2

  class ElementDiff
    constructor: (element, selector)->
      if typeof selector is 'undefined'
        selector = element.selector
      @element  = element
      @selector = selector

    toString:           -> "[ElementDiff: #{@selector || @element[0]}]"
    @diffObjects:       diffObjects
    @isEmptyObject:     isEmptyObject
    @flattenAttributes: flattenAttributes

    generateCode: (method, args = [])->
      strArguments = map(args, (a)-> JSON.stringify a).join(',')
      code = "#{method}(#{strArguments})"
      if @selector then """$("#{@selector}").#{code}"""
      else code

    diffAttributes: (element2)->
      element2 = $ element2
      attrs1 = @element.attr()
      attrs2 = element2.attr()
      diff = flattenAttributes diffObjects(attrs1, attrs2)
      for key, value of diff
        diff[key] = null if value == undefined
      unless isEmptyObject diff
        @generateCode 'attr', [diff]
      else
        null

    isSameTag: (element2)->
      @element.prop('nodeName') is $(element2).prop('nodeName')

    getDiff: (element2)->
      element2 = $ element2
      return unless element2 && element2.size()
      # if @sameTag element2

  $.elementDiff = ElementDiff

  $.fn.elementDiff = (selector)->
    new ElementDiff @, selector

  $.fn.getElementDiff = (element2, selector)->
    @elementDiff(selector).getDiff(element2)

  @
) jQuery

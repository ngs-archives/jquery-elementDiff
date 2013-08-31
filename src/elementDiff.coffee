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
  merge   = $.merge

  duplicate = (object)->
    extend {}, object

  isEmptyObject = (obj)->
    return no unless obj && typeof obj is 'object'
    for key of obj
      return no if Object.prototype.hasOwnProperty.call(obj, key)
    yes

  VALUE_REGEX = /^(string|number|boolean|undefined)$/
  isValue = (obj)->
    !obj or VALUE_REGEX.test(typeof obj) or obj instanceof Array

  nullDeeply = (obj)->
    return null if isValue obj
    for key, value of obj
      obj[key] = nullDeeply value
    obj

  diffObjects = (obj1, obj2)->
    obj1 = duplicate obj1
    obj2 = duplicate obj2
    diff = {}
    for key, value1 of obj1
      value2 = obj2[key]
      delete obj2[key]
      if isValue(value2) && isValue(value1)
        diff[key] = value2 if value2 != value1
      else if typeof value2 is 'object'
        obj = diffObjects value1, value2
        diff[key] = obj unless isEmptyObject obj
      else
        diff[key] = nullDeeply value1
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

  outerHTML = (element)->
    div = $('<div />').append(element.clone())
    $.trim(div.html()).replace(/\s*\n\s*/g, '')

  class ElementDiff
    constructor: (element, selector)->
      if typeof selector is 'undefined'
        selector = element.selector
      @element  = element
      @selector = selector

    toString:           -> "[ElementDiff: #{@selector || @element[0]}]"

    @diffObjects:       diffObjects
    @flattenAttributes: flattenAttributes
    @isEmptyObject:     isEmptyObject
    @nullDeeply:        nullDeeply
    @outerHTML:         outerHTML

    generateCode: (method)->
      args = merge([], arguments)[1..]
      strArguments = map(args, (a)-> JSON.stringify a).join(',')
      "#{method}(#{strArguments})"

    diffAttributes: (element2)->
      element2 = $ element2
      attrs1 = @element.attr()
      attrs2 = element2.attr()
      diff = flattenAttributes diffObjects(attrs1, attrs2)
      for key, value of diff
        diff[key] = null if value == undefined
      unless isEmptyObject diff
        [@generateCode 'attr', diff]
      else
        []

    diffText: (element2)->
      element1 = @element
      element2 = $ element2
      children1 = element1.children()
      children2 = element2.children()
      size1 = children1.size()
      size2 = children2.size()
      text1 = element1.text()
      text2 = element2.text()
      codes = []
      if size2 == 0 && text1 isnt text2
        codes.push @generateCode 'empty' if size1 > 0
        codes.push @generateCode 'text', text2
        return codes
      codes

    isSameTag: (element2)->
      @element.prop('nodeName') is $(element2).prop('nodeName')

    diff: (element2)->
      element1 = @element
      element2 = $ element2
      return [] unless element2 && element2.size()
      codes = []
      if @isSameTag element2
        merge codes, @diffAttributes(element2)
        merge codes, @diffText(element2)
      else
        codes.push @generateCode 'replaceWith', outerHTML(element2)
      if codes.length
        code = codes.join('.')
        if @selector then ["""$("#{@selector}").#{code}"""]
        else [code]
      else
        []

    diffRecursive: (element2)->
      self      = @
      element1  = self.element
      element2  = $ element2
      myDiff    = self.diff element2
      return myDiff if /\.(empty|replaceWith)\(/.test myDiff[0]
      codes     = []
      selector  = self.selector
      children1 = element1.children()
      children2 = element2.children()
      size1     = children1.size()
      size2     = children2.size()
      children2.each (index)->
        child1 = $ children1[index]
        child2 = $ children2[index]
        childSelector = "#{selector} > :eq(#{index})"
        if child1.size()
          merge codes, new ElementDiff(child1, childSelector).diffRecursive(child2)
        else
          codes.push """$("#{selector}").#{self.generateCode('append', outerHTML(child2))}"""
      index = size1
      while index > size2
        codes.push """$("#{selector} > :eq(#{--index})").#{self.generateCode('remove')}"""
      merge codes, myDiff
      codes


  $.elementDiff = ElementDiff

  $.fn.elementDiff = (selector)->
    new ElementDiff(@, selector)

  $.fn.getElementDiff = (element2, selector)->
    @elementDiff(selector).diffRecursive(element2)

  @
) jQuery

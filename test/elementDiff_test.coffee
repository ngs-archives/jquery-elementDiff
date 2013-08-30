(($) ->
  console = window.console

  fdiv =-> $("#qunit-fixture")
  fixtureHTML = null

  module "jquery-elementDiff",

    setup: ->
      @fdiv = fdiv()
      if fixtureHTML
        @fdiv.html fixtureHTML
      else
        fixtureHTML = @fdiv.html()

  test '@options', ->
    $.elementDiff.options = { foo: 'bar' }
    deepEqual $('a').elementDiff().options, { foo: 'bar' }, 'extends default options'
    deepEqual $('a').elementDiff({ bar: 2 }).options, { foo: 'bar', bar: 2 }, 'merges options and default options'
    deepEqual $('a').elementDiff({ foo: 3 }).options, { foo: 3 }, 'argument wins'

  test '@diffAttributes', ->
    ed = $('#test1 > a').elementDiff()
    diff = ed.diffAttributes("""<a href="#foo2" data-foo="1" data-foo-bar="2" data-foo-bar-baz2="3" foo="false">Yay</a>""")
    console.log JSON.stringify diff
    ok 1


) jQuery

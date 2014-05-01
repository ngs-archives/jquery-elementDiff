(($) ->
  console = window.console

  fdiv =-> $("#qunit-fixture")
  fixtureHTML = null
  outerHTML = $.elementDiff.outerHTML

  rollbackFixture =->
    fdiv().html(fixtureHTML)

  evalScript = (script)->
    script = script.join(';\n')
    try
      ### jshint -W054 ###
      f = new Function("$", script)
      f.call(this, $)
    catch e
      console.error e, script

  module "jquery-elementDiff",

    setup: ->
      @fdiv = fdiv()
      if fixtureHTML
        @fdiv.html fixtureHTML
      else
        fixtureHTML = @fdiv.html()

  test ':nullDeeply', ->
    deepEqual $.elementDiff.nullDeeply({ a: 1, b: { c: 1 } }), { a: null, b: { c: null } }

  test ':getTextContents', ->
    deepEqual $.elementDiff.getTextContents($("<a>A\n  <span>B</span>\n  C</a>")), ['A', 'C']
    deepEqual $.elementDiff.getTextContents($("<a>\n  <span>B</span>\n  </a>")), []
    deepEqual $.elementDiff.getTextContents($("<iframe></iframe>")), []

  test ':hasTextNode', ->
    ok !$.elementDiff.hasTextNode $("<div>\n  <a>OK</a>\n  </div>")
    ok  $.elementDiff.hasTextNode $("<div>\n  OK\n  </div>")

  test ':isEmptyObject', ->
    ok  $.elementDiff.isEmptyObject {},    'returns true for empty object'
    ok !$.elementDiff.isEmptyObject a: 1,  'returns false for object with property'
    ok !$.elementDiff.isEmptyObject null,  'returns false if it is null'
    ok !$.elementDiff.isEmptyObject 'foo', 'returns false if it is a string'
    ok !$.elementDiff.isEmptyObject 1,     'returns false if it is a number'
    ok !$.elementDiff.isEmptyObject true,  'returns false if it is a boolean'
    ok !$.elementDiff.isEmptyObject false, 'returns false if it is a boolean'

  test ':diffObjects', ->
    deepEqual $.elementDiff.diffObjects({ a: 1 }, { a: 1 }),
      {}, 'returns empty object for non-diff objects'
    deepEqual $.elementDiff.diffObjects({ a: 1 }, { a: 2 }),
      { a: 2 }, 'returns diff'
    deepEqual $.elementDiff.diffObjects({ a: 1 }, { a: '1' }),
      { a: '1' }, 'returns diff with different types'
    deepEqual $.elementDiff.diffObjects({ a: 1 }, { a: true }),
      { a: true }, 'returns diff with different types'
    deepEqual $.elementDiff.diffObjects({ a: 1 }, { a: null }),
      { a: null }, 'returns diff when property changed to be null'
    deepEqual $.elementDiff.diffObjects({ a: 1 }, {}),
      { a: undefined }, 'returns diff when property set property null'
    deepEqual $.elementDiff.diffObjects({ a: 1 }, { a: 1, b: 2 }),
      { b: 2 }, 'returns diff with new property'
    deepEqual $.elementDiff.diffObjects({ a: 1, b: { c: 1 } }, { a: 1, b: { c: 2 } }),
      { b: { c: 2 } }, ''

  test ':flattenAttributes', ->
    deepEqual $.elementDiff.flattenAttributes(
        a: 1
        b:
          _: 2
          c: 3
          d:
            _: 4
            e: 5
            f: null
            g: false
            h: '6'),
      {
        'a':     1
        'b':     2
        'b-c':   3
        'b-d':   4
        'b-d-e': 5
        'b-d-f': null
        'b-d-g': false
        'b-d-h': '6'
      }, 'generates object with attribute naming rule'

  test '#generateCode', ->
    ed = $('#test1 > a').elementDiff()
    equal ed.generateCode('foo'),
      'foo()', 'generates code with no arguments'
    equal ed.generateCode('foo', 1, '2', null, false, true),
      'foo(1,"2",null,false,true)', 'generates code with arguments'
    equal ed.generateCode('foo', NaN, {a: -> 1 }, -> 2),
      'foo(null,{})', 'should ignore functions'

  test '#diffAttributes', ->
    ed = $('#test1 > a').elementDiff()
    diff = ed.diffAttributes '<a href="#foo2" data-foo="1" data-foo-bar="2" data-foo-bar-baz2="3" foo="false">Yay</a>'
    deepEqual diff,
      ['attr({"href":"#foo2","data-foo-bar-baz":null,"data-foo-bar-baz2":3,"foo":false})'],
      "returns attr method with diff"
    diff = ed.diffAttributes '<a>Yay</a>'
    deepEqual diff, ['attr({"href":null,"data-foo":null,"data-foo-bar":null,"data-foo-bar-baz":null,"foo":null})']

  test '#hasTextDiff', ->
    ed = $('#test1 > a').elementDiff()
    ok !ed.hasTextDiff '<a>Yay</a>'
    ok  ed.hasTextDiff '<a>Hoo</a>'
    ok  ed.hasTextDiff '<div>Hoo</div>'
    ok !ed.hasTextDiff '<a>Yay\n<span>Yo</span>\n</a>'
    ok  ed.hasTextDiff '<a>Hoo\n<span>Yo</span>\n</a>'
    ok  ed.hasTextDiff '<div>Hoo\n<span>Yo</span>\n</div>'

  test '#diffText', ->
    ed = $('#test1 > a').elementDiff()
    diff = ed.diffText '<a>Hoo</a>'
    deepEqual diff, ['html("Hoo")']
    ed = $('#test1').elementDiff()
    diff = ed.diffText '<div>Hoo</div>'
    deepEqual diff, ['html("Hoo")']

  test '#isSameTag', ->
    ed = $('#test1 > a').elementDiff()
    ok  ed.isSameTag('<a href="#foo">Yay</a>'), 'returns true for same tag'
    ok !ed.isSameTag('<b>Yay</b>'), 'returns true for different tag'
    ok !ed.isSameTag('<a>Yay</a><a>Yay</a><a>Yay</a>'), 'returns false for plural elements'

  test '#diff', ->
    ed = $('#test1 > a').elementDiff()
    deepEqual ed.diff('<a href="#foo">Yay</a>'), ['$("#test1 > a").attr({"data-foo":null,"data-foo-bar":null,"data-foo-bar-baz":null,"foo":null})']
    deepEqual ed.diff('<b>Hoo</b>'), ['$("#test1 > a").replaceWith("<b>Hoo</b>")']
    ed = $('#test1').elementDiff()
    deepEqual ed.diff('<div>Hoo</div>'), ['$("#test1").attr({"id":null}).html("Hoo")']
    ed = $('<iframe src="http://example.com/"></iframe>').elementDiff()
    deepEqual ed.diff('<iframe src="http://example.com/foo"></iframe>'), ['attr({"src":"http://example.com/foo"})']
    ed = $('body').elementDiff()
    deepEqual ed.diff('<body class="foo">bar</body>'), ['$("body").attr({"style":null,"class":"foo"}).html("bar")']
    ed = $('body').elementDiff()
    deepEqual ed.diff('<p class="foo">bar</p>'), ['$("body").html("<p class=\\"foo\\">bar</p>")']

  test '#getDiffRecursive', ->
    ed = $('#test1 > a').elementDiff()
    diff = ed.diffRecursive '<b>Yay</b>'
    deepEqual diff, ['$("#test1 > a").replaceWith("<b>Yay</b>")']
    evalScript diff
    equal $.trim($("#test1").html()), '<b>Yay</b>', 'replaces with bold tag'
    rollbackFixture()
    #
    ed = $('#test1 > a').elementDiff()
    diff = ed.diffRecursive '<a>Yay</a><a>Yay</a><a>Yay</a>'
    deepEqual diff, ['$("#test1 > a").replaceWith("<a>Yay</a><a>Yay</a><a>Yay</a>")']
    evalScript diff
    equal $.trim($("#test1").html()), '<a>Yay</a><a>Yay</a><a>Yay</a>', 'replaces with plural anchors'
    rollbackFixture()
    #
    diff = ed.diffRecursive '<a>Foo</a>'
    deepEqual diff, ['$("#test1 > a").attr({"href":null,"data-foo":null,"data-foo-bar":null,"data-foo-bar-baz":null,"foo":null}).html("Foo")']
    evalScript diff
    equal $.trim($("#test1").html()), '<a>Foo</a>', 'updates text and attributes'
    rollbackFixture()
    #
    ed = $('#test1').elementDiff()
    diff = ed.diffRecursive '<div id="test1-1"><a href="http://www.google.com/" data-bar="foo" foo="1">Hoo</a><b>Baa</b></div>'
    deepEqual diff, [
      '$("#test1 > :eq(0)").attr({"href":"http://www.google.com/","data-foo":null,"data-foo-bar":null,"data-foo-bar-baz":null,"data-bar":"foo","foo":1}).html("Hoo")'
      '$("#test1").append("<b>Baa</b>")'
      '$("#test1").attr({"id":"test1-1"})'
    ]
    evalScript diff
    equal outerHTML($("#test1-1")), '<div id="test1-1"><a href="http://www.google.com/" foo="1" data-bar="foo">Hoo</a><b>Baa</b></div>'
    rollbackFixture()
    #
    diff = ed.diffRecursive '<div id="test1-2">aa</div>'
    deepEqual diff, ['$("#test1").attr({"id":"test1-2"}).html("aa")']
    evalScript diff
    equal outerHTML($("#test1-2")), '<div id="test1-2">aa</div>'
    rollbackFixture()
    #
    ed = $('#test-list1').elementDiff()
    clone = $("#test-list2").clone()
    clone.attr("id", "test-list2-2")
    diff = ed.diffRecursive clone
    deepEqual diff, [
      '$("#test-list1 > :eq(0) > :eq(0)").attr({"class":"item1"})'
      '$("#test-list1 > :eq(0) > :eq(2) > :eq(0)").attr({"href":"http://www.yahoo.com/?foo"}).html("Yahoo!!")'
      '$("#test-list1 > :eq(0)").attr({"class":"list2"})'
      '$("#test-list1").attr({"id":"test-list2-2"})'
    ], 'diff with test-list2'
    evalScript diff
    equal outerHTML($("#test-list2-2")), outerHTML(clone)
    rollbackFixture()
    #
    ed = $('#test-list1').elementDiff()
    clone = $("#test-list3").clone()
    clone.attr("id", "test-list3-2")
    diff = ed.diffRecursive outerHTML(clone)
    deepEqual diff, [
      '$("#test-list1 > :eq(0) > :eq(0)").attr({"class":"item1"})'
      '$("#test-list1 > :eq(0) > :eq(3)").remove()'
      '$("#test-list1 > :eq(0) > :eq(2)").remove()'
      '$("#test-list1").attr({"id":"test-list3-2"})'
    ], 'diff with test-list3'
    evalScript diff
    equal outerHTML($("#test-list3-2")), outerHTML(clone)
    rollbackFixture()

    ed = $('#test-list1').elementDiff()
    clone = $("#test-list4").clone()
    clone.attr("id", "test-list4-2")
    diff = ed.diffRecursive outerHTML(clone)
    deepEqual diff, [
      '$("#test-list1 > :eq(0)").replaceWith("<ol class=\\"list1\\"><li class=\\"item1\\"><a href=\\"http://www.apple.com/\\">Apple</a></li><li class=\\"item\\"><a href=\\"http://www.microsoft.com/\\" id=\\"link-microsoft\\">Microsoft</a></li></ol>")'
      '$("#test-list1").attr({"id":"test-list4-2"})'
    ], 'diff with test-list4'
    evalScript diff
    equal outerHTML($("#test-list4-2")), outerHTML(clone)
    rollbackFixture()

    ed = $('#test-text1').elementDiff()
    clone = $("#test-text2").clone()
    clone.attr("id", "test-text2-2")
    diff = ed.diffRecursive outerHTML(clone)
    deepEqual diff, [
      """$("#test-text1").attr({"id":"test-text2-2"}).html(#{JSON.stringify(clone.html())})"""
    ], 'diff with test-text2'
    evalScript diff
    equal outerHTML($("#test-text2-2")), outerHTML(clone)
    rollbackFixture()

    ed = $('#test-text1').elementDiff()
    clone = $("#test-text3").clone()
    clone.attr("id", "test-text3-2")
    diff = ed.diffRecursive outerHTML(clone)
    deepEqual diff, [
      """$("#test-text1").attr({"id":"test-text3-2"}).html(#{JSON.stringify(clone.html())})"""
    ], 'diff with test-text3'
    evalScript diff
    equal outerHTML($("#test-text3-2")), outerHTML(clone)
    rollbackFixture()

    ed = $('#test-text3').elementDiff()
    clone = $("#test-text4").clone()
    clone.attr("id", "test-text4-2")
    diff = ed.diffRecursive outerHTML(clone)
    deepEqual diff, [
      '$("#test-text3 > :eq(0)").html("__REPLACED__")'
      '$("#test-text3").attr({"id":"test-text4-2"})'
    ], 'diff with test-text4'
    evalScript diff
    equal outerHTML($("#test-text4-2")), outerHTML(clone)
    rollbackFixture()

    clone = $("#test-text5").clone()
    clone.attr("id", "test-text5-2")
    diff = ed.diffRecursive outerHTML(clone)
    deepEqual diff, [
      '$("#test-text3 > :eq(0)").replaceWith("<b>__REPLACED__</b>")'
      '$("#test-text3").attr({"id":"test-text5-2"})'
    ], 'diff with test-text5'
    evalScript diff
    equal outerHTML($("#test-text5-2")), outerHTML(clone)
    rollbackFixture()

  test '$.fn.getElementDiff', ->
    diff = $('#test1 > a').getElementDiff('<b>Yay</b>')
    deepEqual diff, ['$("#test1 > a").replaceWith("<b>Yay</b>")']
    evalScript diff
    equal $.trim($("#test1").html()), '<b>Yay</b>', 'replaces with bold tag'
    rollbackFixture()
    #
    diff = $('#test1 > a').getElementDiff('<a>Foo</a>')
    deepEqual diff, ['$("#test1 > a").attr({"href":null,"data-foo":null,"data-foo-bar":null,"data-foo-bar-baz":null,"foo":null}).html("Foo")']
    evalScript diff
    equal $.trim($("#test1").html()), '<a>Foo</a>', 'updates text and attributes'
    rollbackFixture()
    #
    diff = $('#test1').getElementDiff '<div id="test1-1"><a href="http://www.google.com/" data-bar="foo" foo="1">Hoo</a><b>Baa</b></div>'
    deepEqual diff, [
      '$("#test1 > :eq(0)").attr({"href":"http://www.google.com/","data-foo":null,"data-foo-bar":null,"data-foo-bar-baz":null,"data-bar":"foo","foo":1}).html("Hoo")'
      '$("#test1").append("<b>Baa</b>")'
      '$("#test1").attr({"id":"test1-1"})'
    ]
    evalScript diff
    equal outerHTML($("#test1-1")), '<div id="test1-1"><a href="http://www.google.com/" foo="1" data-bar="foo">Hoo</a><b>Baa</b></div>'
    rollbackFixture()
    #
    diff = $('#test1').getElementDiff '<div id="test1-2">aa</div>'
    deepEqual diff, ['$("#test1").attr({"id":"test1-2"}).html("aa")']
    evalScript diff
    equal outerHTML($("#test1-2")), '<div id="test1-2">aa</div>'
    rollbackFixture()
    #
    clone = $("#test-list2").clone()
    clone.attr("id", "test-list2-2")
    diff = $('#test-list1').getElementDiff clone
    deepEqual diff, [
      '$("#test-list1 > :eq(0) > :eq(0)").attr({"class":"item1"})'
      '$("#test-list1 > :eq(0) > :eq(2) > :eq(0)").attr({"href":"http://www.yahoo.com/?foo"}).html("Yahoo!!")'
      '$("#test-list1 > :eq(0)").attr({"class":"list2"})'
      '$("#test-list1").attr({"id":"test-list2-2"})'
    ], 'diff with test-list2'
    evalScript diff
    equal outerHTML($("#test-list2-2")), outerHTML(clone)
    rollbackFixture()
    #
    clone = $("#test-list3").clone()
    clone.attr("id", "test-list3-2")
    diff = $('#test-list1').getElementDiff outerHTML(clone)
    deepEqual diff, [
      '$("#test-list1 > :eq(0) > :eq(0)").attr({"class":"item1"})'
      '$("#test-list1 > :eq(0) > :eq(3)").remove()'
      '$("#test-list1 > :eq(0) > :eq(2)").remove()'
      '$("#test-list1").attr({"id":"test-list3-2"})'
    ], 'diff with test-list3'
    evalScript diff
    equal outerHTML($("#test-list3-2")), outerHTML(clone)
    rollbackFixture()

    clone = $("#test-list4").clone()
    clone.attr("id", "test-list4-2")
    diff = $('#test-list1').getElementDiff outerHTML(clone)
    deepEqual diff, [
      '$("#test-list1 > :eq(0)").replaceWith("<ol class=\\"list1\\"><li class=\\"item1\\"><a href=\\"http://www.apple.com/\\">Apple</a></li><li class=\\"item\\"><a href=\\"http://www.microsoft.com/\\" id=\\"link-microsoft\\">Microsoft</a></li></ol>")'
      '$("#test-list1").attr({"id":"test-list4-2"})'
    ], 'diff with test-list4'
    evalScript diff
    equal outerHTML($("#test-list4-2")), outerHTML(clone)
    rollbackFixture()

    clone = $("#test-text2").clone()
    clone.attr("id", "test-text2-2")
    diff = $('#test-text1').getElementDiff outerHTML(clone)
    deepEqual diff, [
      """$("#test-text1").attr({"id":"test-text2-2"}).html(#{JSON.stringify(clone.html())})"""
    ], 'diff with test-text2'
    evalScript diff
    equal outerHTML($("#test-text2-2")), outerHTML(clone)
    rollbackFixture()

    clone = $("#test-text3").clone()
    clone.attr("id", "test-text3-2")
    diff = $('#test-text1').getElementDiff outerHTML(clone)
    deepEqual diff, [
      """$("#test-text1").attr({"id":"test-text3-2"}).html(#{JSON.stringify(clone.html())})"""
    ], 'diff with test-text3'
    evalScript diff
    equal outerHTML($("#test-text3-2")), outerHTML(clone)
    rollbackFixture()

    clone = $("#test-text4").clone()
    clone.attr("id", "test-text4-2")
    diff = $('#test-text3').getElementDiff outerHTML(clone)
    deepEqual diff, [
      '$("#test-text3 > :eq(0)").html("__REPLACED__")'
      '$("#test-text3").attr({"id":"test-text4-2"})'
    ], 'diff with test-text4'
    evalScript diff
    equal outerHTML($("#test-text4-2")), outerHTML(clone)
    rollbackFixture()

    clone = $("#test-text5").clone()
    clone.attr("id", "test-text5-2")
    diff = $('#test-text3').getElementDiff outerHTML(clone)
    deepEqual diff, [
      '$("#test-text3 > :eq(0)").replaceWith("<b>__REPLACED__</b>")'
      '$("#test-text3").attr({"id":"test-text5-2"})'
    ], 'diff with test-text5'
    evalScript diff
    equal outerHTML($("#test-text5-2")), outerHTML(clone)
    rollbackFixture()

  test '#getDiffRecursive with selector', ->
    ed = $('#test1 > a').elementDiff('#foo')
    diff = ed.diffRecursive '<b>Yay</b>'
    deepEqual diff, ['$("#foo").replaceWith("<b>Yay</b>")']
    #
    diff = ed.diffRecursive '<a>Foo</a>'
    deepEqual diff, ['$("#foo").attr({"href":null,"data-foo":null,"data-foo-bar":null,"data-foo-bar-baz":null,"foo":null}).html("Foo")']
    #
    ed = $('#test1').elementDiff('#foo')
    diff = ed.diffRecursive '<div id="test1-1"><a href="http://www.google.com/" data-bar="foo" foo="1">Hoo</a><b>Baa</b></div>'
    deepEqual diff, [
      '$("#foo > :eq(0)").attr({"href":"http://www.google.com/","data-foo":null,"data-foo-bar":null,"data-foo-bar-baz":null,"data-bar":"foo","foo":1}).html("Hoo")'
      '$("#foo").append("<b>Baa</b>")'
      '$("#foo").attr({"id":"test1-1"})'
    ]
    #
    diff = ed.diffRecursive '<div id="test1-2">aa</div>'
    deepEqual diff, ['$("#foo").attr({"id":"test1-2"}).html("aa")']
    #
    ed = $('#test-list1').elementDiff('#foo')
    clone = $("#test-list2").clone()
    clone.attr("id", "test-list2-2")
    diff = ed.diffRecursive clone
    deepEqual diff, [
      '$("#foo > :eq(0) > :eq(0)").attr({"class":"item1"})'
      '$("#foo > :eq(0) > :eq(2) > :eq(0)").attr({"href":"http://www.yahoo.com/?foo"}).html("Yahoo!!")'
      '$("#foo > :eq(0)").attr({"class":"list2"})'
      '$("#foo").attr({"id":"test-list2-2"})'
    ], 'diff with test-list2'
    #
    ed = $('#test-list1').elementDiff('#foo')
    clone = $("#test-list3").clone()
    clone.attr("id", "test-list3-2")
    diff = ed.diffRecursive outerHTML(clone)
    deepEqual diff, [
      '$("#foo > :eq(0) > :eq(0)").attr({"class":"item1"})'
      '$("#foo > :eq(0) > :eq(3)").remove()'
      '$("#foo > :eq(0) > :eq(2)").remove()'
      '$("#foo").attr({"id":"test-list3-2"})'
    ], 'diff with test-list3'

    ed = $('#test-list1').elementDiff('#foo')
    clone = $("#test-list4").clone()
    clone.attr("id", "test-list4-2")
    diff = ed.diffRecursive outerHTML(clone)
    deepEqual diff, [
      '$("#foo > :eq(0)").replaceWith("<ol class=\\"list1\\"><li class=\\"item1\\"><a href=\\"http://www.apple.com/\\">Apple</a></li><li class=\\"item\\"><a href=\\"http://www.microsoft.com/\\" id=\\"link-microsoft\\">Microsoft</a></li></ol>")'
      '$("#foo").attr({"id":"test-list4-2"})'
    ], 'diff with test-list4'

    ed = $('#test-text1').elementDiff('#foo')
    clone = $("#test-text2").clone()
    clone.attr("id", "test-text2-2")
    diff = ed.diffRecursive outerHTML(clone)
    deepEqual diff, [
      """$("#foo").attr({"id":"test-text2-2"}).html(#{JSON.stringify(clone.html())})"""
    ], 'diff with test-text2'

    ed = $('#test-text1').elementDiff('#foo')
    clone = $("#test-text3").clone()
    clone.attr("id", "test-text3-2")
    diff = ed.diffRecursive outerHTML(clone)
    deepEqual diff, [
      """$("#foo").attr({"id":"test-text3-2"}).html(#{JSON.stringify(clone.html())})"""
    ], 'diff with test-text3'

    ed = $('#test-text3').elementDiff('#foo')
    clone = $("#test-text4").clone()
    clone.attr("id", "test-text4-2")
    diff = ed.diffRecursive outerHTML(clone)
    deepEqual diff, [
      '$("#foo > :eq(0)").html("__REPLACED__")'
      '$("#foo").attr({"id":"test-text4-2"})'
    ], 'diff with test-text4'

    clone = $("#test-text5").clone()
    clone.attr("id", "test-text5-2")
    diff = ed.diffRecursive outerHTML(clone)
    deepEqual diff, [
      '$("#foo > :eq(0)").replaceWith("<b>__REPLACED__</b>")'
      '$("#foo").attr({"id":"test-text5-2"})'
    ], 'diff with test-text5'

  test '$.fn.getElementDiff with selector', ->
    diff = $('#test1 > a').getElementDiff('<b>Yay</b>', '#foo')
    deepEqual diff, ['$("#foo").replaceWith("<b>Yay</b>")']
    #
    diff = $('#test1 > a').getElementDiff('<a>Foo</a>', '#foo')
    deepEqual diff, ['$("#foo").attr({"href":null,"data-foo":null,"data-foo-bar":null,"data-foo-bar-baz":null,"foo":null}).html("Foo")']
    #
    diff = $('#test1').getElementDiff '<div id="test1-1"><a href="http://www.google.com/" data-bar="foo" foo="1">Hoo</a><b>Baa</b></div>', '#foo'
    deepEqual diff, [
      '$("#foo > :eq(0)").attr({"href":"http://www.google.com/","data-foo":null,"data-foo-bar":null,"data-foo-bar-baz":null,"data-bar":"foo","foo":1}).html("Hoo")'
      '$("#foo").append("<b>Baa</b>")'
      '$("#foo").attr({"id":"test1-1"})'
    ]
    #
    diff = $('#test1').getElementDiff '<div id="test1-2">aa</div>', '#foo'
    deepEqual diff, ['$("#foo").attr({"id":"test1-2"}).html("aa")']
    #
    clone = $("#test-list2").clone()
    clone.attr("id", "test-list2-2")
    diff = $('#test-list1').getElementDiff clone, '#foo'
    deepEqual diff, [
      '$("#foo > :eq(0) > :eq(0)").attr({"class":"item1"})'
      '$("#foo > :eq(0) > :eq(2) > :eq(0)").attr({"href":"http://www.yahoo.com/?foo"}).html("Yahoo!!")'
      '$("#foo > :eq(0)").attr({"class":"list2"})'
      '$("#foo").attr({"id":"test-list2-2"})'
    ], 'diff with test-list2'
    #
    clone = $("#test-list3").clone()
    clone.attr("id", "test-list3-2")
    diff = $('#test-list1').getElementDiff outerHTML(clone), '#foo'
    deepEqual diff, [
      '$("#foo > :eq(0) > :eq(0)").attr({"class":"item1"})'
      '$("#foo > :eq(0) > :eq(3)").remove()'
      '$("#foo > :eq(0) > :eq(2)").remove()'
      '$("#foo").attr({"id":"test-list3-2"})'
    ], 'diff with test-list3'

    clone = $("#test-list4").clone()
    clone.attr("id", "test-list4-2")
    diff = $('#test-list1').getElementDiff outerHTML(clone), '#foo'
    deepEqual diff, [
      '$("#foo > :eq(0)").replaceWith("<ol class=\\"list1\\"><li class=\\"item1\\"><a href=\\"http://www.apple.com/\\">Apple</a></li><li class=\\"item\\"><a href=\\"http://www.microsoft.com/\\" id=\\"link-microsoft\\">Microsoft</a></li></ol>")'
      '$("#foo").attr({"id":"test-list4-2"})'
    ], 'diff with test-list4'

    clone = $("#test-text2").clone()
    clone.attr("id", "test-text2-2")
    diff = $('#test-text1').getElementDiff outerHTML(clone), '#foo'
    deepEqual diff, [
      """$("#foo").attr({"id":"test-text2-2"}).html(#{JSON.stringify(clone.html())})"""
    ], 'diff with test-text2'

    clone = $("#test-text3").clone()
    clone.attr("id", "test-text3-2")
    diff = $('#test-text1').getElementDiff outerHTML(clone), '#foo'
    deepEqual diff, [
      """$("#foo").attr({"id":"test-text3-2"}).html(#{JSON.stringify(clone.html())})"""
    ], 'diff with test-text3'

    clone = $("#test-text4").clone()
    clone.attr("id", "test-text4-2")
    diff = $('#test-text3').getElementDiff outerHTML(clone), '#foo'
    deepEqual diff, [
      '$("#foo > :eq(0)").html("__REPLACED__")'
      '$("#foo").attr({"id":"test-text4-2"})'
    ], 'diff with test-text4'

    clone = $("#test-text5").clone()
    clone.attr("id", "test-text5-2")
    diff = $('#test-text3').getElementDiff outerHTML(clone), '#foo'
    deepEqual diff, [
      '$("#foo > :eq(0)").replaceWith("<b>__REPLACED__</b>")'
      '$("#foo").attr({"id":"test-text5-2"})'
    ], 'diff with test-text5'

  test '#getDiffRecursive with replaceWith, html or empty', ->
    ed = $('div[id="test-list5"]').elementDiff()
    clone = $("#test-list6").clone()
    clone.attr("id", "test-list6-2")
    diff = ed.diffRecursive outerHTML(clone)
    deepEqual diff, [
      '$("div[id=\\"test-list5\\"] > :eq(0) > :eq(1) > :eq(0)").html("Microsoft!")'
      """$("div[id=\\"test-list5\\"]").attr({"id":"test-list6-2","onclick":"$(this).find('ol').replaceWith('<b>Yay!</b>');"})"""
    ], 'diff with test-list6'
    evalScript diff
    equal outerHTML($("#test-list6-2")), outerHTML(clone)
    rollbackFixture()

    ed = $('div[id="test-list5"]').elementDiff()
    clone = $("#test-list7").clone()
    clone.attr("id", "test-list7-2")
    diff = ed.diffRecursive outerHTML(clone)
    deepEqual diff, [
      '$("div[id=\\"test-list5\\"] > :eq(0) > :eq(1) > :eq(0)").html("Microsoft!")'
      """$("div[id=\\"test-list5\\"]").attr({"id":"test-list7-2","onclick":"$(this).find('ol').html('<li>Yay!</li>');"})"""
    ], 'diff with test-list7'
    evalScript diff
    equal outerHTML($("#test-list7-2")), outerHTML(clone)
    rollbackFixture()

    ed = $('div[id="test-list5"]').elementDiff()
    clone = $("#test-list8").clone()
    clone.attr("id", "test-list8-2")
    diff = ed.diffRecursive outerHTML(clone)
    deepEqual diff, [
      '$("div[id=\\"test-list5\\"] > :eq(0) > :eq(1) > :eq(0)").html("Microsoft!")'
      """$("div[id=\\"test-list5\\"]").attr({"id":"test-list8-2","onclick":"$(this).find('ol').empty();"})"""
    ], 'diff with test-list8'
    evalScript diff
    equal outerHTML($("#test-list8-2")), outerHTML(clone)
    rollbackFixture()

  # test '#getDiffRecursive for README.md', ->
  #   console.log JSON.stringify $("#sample-text1").getElementDiff($("#sample-text2"))
  #   ok 1

) jQuery

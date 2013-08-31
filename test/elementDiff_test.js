(function() {

  (function($) {
    var console, fdiv, fixtureHTML;
    console = window.console;
    fdiv = function() {
      return $("#qunit-fixture");
    };
    fixtureHTML = null;
    module("jquery-elementDiff", {
      setup: function() {
        this.fdiv = fdiv();
        if (fixtureHTML) {
          return this.fdiv.html(fixtureHTML);
        } else {
          return fixtureHTML = this.fdiv.html();
        }
      }
    });
    test(':isEmptyObject', function() {
      ok($.elementDiff.isEmptyObject({}, 'returns true for empty object'));
      ok(!$.elementDiff.isEmptyObject({
        a: 1
      }, 'returns false for object with property'));
      ok(!$.elementDiff.isEmptyObject(null, 'returns false if it is null'));
      ok(!$.elementDiff.isEmptyObject('foo', 'returns false if it is a string'));
      ok(!$.elementDiff.isEmptyObject(1, 'returns false if it is a number'));
      ok(!$.elementDiff.isEmptyObject(true, 'returns false if it is a boolean'));
      return ok(!$.elementDiff.isEmptyObject(false, 'returns false if it is a boolean'));
    });
    test(':diffObjects', function() {
      deepEqual($.elementDiff.diffObjects({
        a: 1
      }, {
        a: 1
      }), {}, 'returns empty object for non-diff objects');
      deepEqual($.elementDiff.diffObjects({
        a: 1
      }, {
        a: 2
      }), {
        a: 2
      }, 'returns diff');
      deepEqual($.elementDiff.diffObjects({
        a: 1
      }, {
        a: '1'
      }), {
        a: '1'
      }, 'returns diff with different types');
      deepEqual($.elementDiff.diffObjects({
        a: 1
      }, {
        a: true
      }), {
        a: true
      }, 'returns diff with different types');
      deepEqual($.elementDiff.diffObjects({
        a: 1
      }, {
        a: null
      }), {
        a: null
      }, 'returns diff when property changed to be null');
      deepEqual($.elementDiff.diffObjects({
        a: 1
      }, {}), {
        a: void 0
      }, 'returns diff when property set property null');
      deepEqual($.elementDiff.diffObjects({
        a: 1
      }, {
        a: 1,
        b: 2
      }), {
        b: 2
      }, 'returns diff with new property');
      return deepEqual($.elementDiff.diffObjects({
        a: 1,
        b: {
          c: 1
        }
      }, {
        a: 1,
        b: {
          c: 2
        }
      }), {
        b: {
          c: 2
        }
      }, '');
    });
    test(':flattenAttributes', function() {
      return deepEqual($.elementDiff.flattenAttributes({
        a: 1,
        b: {
          _: 2,
          c: 3,
          d: {
            _: 4,
            e: 5,
            f: null,
            g: false,
            h: '6'
          }
        }
      }), {
        'a': 1,
        'b': 2,
        'b-c': 3,
        'b-d': 4,
        'b-d-e': 5,
        'b-d-f': null,
        'b-d-g': false,
        'b-d-h': '6'
      }, 'generates object with attribute naming rule');
    });
    test('#generateCode', function() {
      var ed;
      ed = $('#test1 > a').elementDiff();
      equal(ed.generateCode('foo'), '$("#test1 > a").foo()', 'generates code with no arguments');
      equal(ed.generateCode('foo', [1, '2', false, true]), '$("#test1 > a").foo(1,"2",false,true)', 'generates code with arguments');
      ed = $('#test1 > a').elementDiff('#bar');
      equal(ed.generateCode('foo', []), '$("#bar").foo()', 'generates code with selector');
      equal(ed.generateCode('foo', [1, '2', false, true]), '$("#bar").foo(1,"2",false,true)', 'generates code with selector');
      ed = $('#test1 > a').elementDiff(null);
      equal(ed.generateCode('foo', []), 'foo()', 'generates code without selector');
      return equal(ed.generateCode('foo', [1, '2', false, true]), 'foo(1,"2",false,true)', 'generates code without selector');
    });
    test('#diffAttributes', function() {
      var diff, ed;
      ed = $('#test1 > a').elementDiff();
      diff = ed.diffAttributes("<a href=\"#foo2\" data-foo=\"1\" data-foo-bar=\"2\" data-foo-bar-baz2=\"3\" foo=\"false\">Yay</a>");
      return equal(diff, "$(\"#test1 > a\").attr({\"href\":\"#foo2\",\"data-foo-bar-baz\":null,\"data-foo-bar-baz2\":3,\"foo\":false})", "returns attr method with diff");
    });
    test('#isSameTag', function() {
      var ed;
      ed = $('#test1 > a').elementDiff();
      ok(ed.isSameTag('<a href="#foo">Yay</a>'), 'returns true for same tag');
      return ok(!ed.isSameTag('<b>Yay</b>'), 'returns true for different tag');
    });
    return test('#getDiff', function() {
      var ed;
      ed = $('#test1 > a').elementDiff();
      deepEqual(ed.getDiff('<a href="#foo">Yay</a>'), ['$("#test1 > a").attr({"data":null,"foo":null})']);
      return deepEqual(ed.getDiff('<b>Hoo</b>'), ['$("#test1 > a").replaceWith("<b>Hoo</b>")']);
    });
  })(jQuery);

}).call(this);

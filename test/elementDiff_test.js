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
    return test('@diffAttributes', function() {
      var diff, ed;
      ed = $('#test1 > a').elementDiff();
      diff = ed.diffAttributes("<a href=\"#foo2\" data-foo=\"1\" data-foo-bar=\"2\" data-foo-bar-baz2=\"3\" foo=\"false\">Yay</a>");
      console.log(JSON.stringify(diff));
      return ok(1);
    });
  })(jQuery);

}).call(this);

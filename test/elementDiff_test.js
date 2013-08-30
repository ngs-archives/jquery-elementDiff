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
    test('@options', function() {
      $.elementDiff.options = {
        foo: 'bar'
      };
      deepEqual($('a').elementDiff().options, {
        foo: 'bar'
      }, 'extends default options');
      deepEqual($('a').elementDiff({
        bar: 2
      }).options, {
        foo: 'bar',
        bar: 2
      }, 'merges options and default options');
      return deepEqual($('a').elementDiff({
        foo: 3
      }).options, {
        foo: 3
      }, 'argument wins');
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

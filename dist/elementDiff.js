/*! jQuery Element Diff - v0.1.0 - 2013-08-30
* https://github.com/ngs/jquery-elementDiff
* Copyright (c) 2013 Atsushi Nagase; Licensed MIT */
(function() {

  (function($) {
    var ElementDiff, clean, contains, escapeSelector, extend, inArray, map, unique;
    map = $.map;
    extend = $.extend;
    inArray = $.inArray;
    contains = function(item, array) {
      return inArray(item, array) !== -1;
    };
    escapeSelector = function(selector) {
      return selector.replace(/([\!\"\#\$\%\&'\(\)\*\+\,\.\/\:\;<\=>\?\@\[\\\]\^\`\{\|\}\~])/g, "\\$1");
    };
    clean = function(arr, reject) {
      return map(arr, function(item) {
        if (item === reject) {
          return null;
        } else {
          return item;
        }
      });
    };
    unique = function(arr) {
      return map(arr, function(item, index) {
        if (index === arr.indexOf(item)) {
          return item;
        } else {
          return null;
        }
      });
    };
    ElementDiff = (function() {

      function ElementDiff(element, options) {
        this.element = element;
        this.options = extend(extend({}, $.elementDiff.options), options);
      }

      ElementDiff.prototype.getDiff = function(element2) {
        if (!(element2 && element2.size())) {

        }
      };

      return ElementDiff;

    })();
    $.elementDiff = {
      options: {},
      unique: unique,
      clean: clean,
      escapeSelector: escapeSelector
    };
    $.fn.elementDiff = function(options) {
      return new ElementDiff($(this), options);
    };
    $.fn.getElementDiff = function(element2, options) {
      return this.elementDiff(options).getDiff(element2);
    };
    return this;
  })(jQuery);

}).call(this);

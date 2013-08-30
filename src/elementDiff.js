(function() {

  (function($) {
    var ElementDiff, clean, console, contains, diffObjects, duplicate, escapeSelector, extend, getAttributes, inArray, map, unique, _attr;
    console = window.console;
    map = $.map;
    extend = $.extend;
    inArray = $.inArray;
    getAttributes = function(element) {
      var attr, attrs, hash, name, names, ref, value, _i, _len;
      attrs = element.attributes;
      hash = {};
      for (_i = 0, _len = attrs.length; _i < _len; _i++) {
        attr = attrs[_i];
        names = attr.name.split('-');
        value = attr.value;
        ref = hash;
        if (/^(\d[\d\.]*)$/.test(value)) {
          value = parseFloat(value);
        } else if (/^(true|false)$/.test(value)) {
          value = value === 'true';
        }
        while (names.length > 1) {
          name = names.shift();
          if (/^(number|string|boolean)$/.test(typeof ref[name])) {
            ref[name] = {
              '_': ref[name]
            };
          }
          if (!ref[name]) {
            ref[name] = {};
          }
          ref = ref[name];
        }
        name = names[0];
        if (typeof ref[name] === 'object') {
          ref[name]['_'] = value;
        } else {
          ref[name] = value;
        }
      }
      return hash;
    };
    duplicate = function(object) {
      return extend({}, object);
    };
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
    diffObjects = function(obj1, obj2) {
      var diff, key, value, value2;
      obj1 = duplicate(obj1);
      obj2 = duplicate(obj2);
      diff = {};
      for (key in obj1) {
        value = obj1[key];
        value2 = obj2[key];
        delete obj2[key];
        if (/^(string|number|boolean)$/.test(typeof value2) || value2 instanceof Array) {
          diff[key] = value2;
        } else if (typeof value2 === 'object') {
          diff[key] = diffObjects(value, value2);
        } else {
          diff[key] = null;
        }
      }
      return extend(diff, obj2);
    };
    ElementDiff = (function() {

      function ElementDiff(element, options) {
        this.element = element;
        this.options = extend(extend({}, $.elementDiff.options), options);
      }

      ElementDiff.prototype.toString = function() {
        return "[ElementDiff: " + this.element[0] + "]";
      };

      ElementDiff.prototype.getDiff = function(element2) {
        if (!(element2 && element2.size())) {

        }
      };

      ElementDiff.prototype.diffAttributes = function(element2) {
        var attrs1, attrs2;
        element2 = $(element2);
        attrs1 = this.element.attr();
        attrs2 = element2.attr();
        return diffObjects(attrs1, attrs2);
      };

      return ElementDiff;

    })();
    $.elementDiff = {
      options: {},
      unique: unique,
      clean: clean,
      escapeSelector: escapeSelector,
      diffObjects: diffObjects
    };
    $.fn.elementDiff = function(options) {
      return new ElementDiff($(this), options);
    };
    $.fn.getElementDiff = function(element2, options) {
      return this.elementDiff(options).getDiff(element2);
    };
    _attr = $.fn.attr;
    $.fn.attr = function() {
      if (arguments.length) {
        return _attr.apply(this, arguments);
      } else if (this[0]) {
        return getAttributes(this[0]);
      }
    };
    return this;
  })(jQuery);

}).call(this);

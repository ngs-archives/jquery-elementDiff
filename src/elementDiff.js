(function() {

  (function($) {
    "use strict";

    var ElementDiff, VALUE_REGEX, diffObjects, duplicate, extend, flattenAttributes, inArray, isEmptyObject, isValue, map;
    map = $.map;
    extend = $.extend;
    inArray = $.inArray;
    duplicate = function(object) {
      return extend({}, object);
    };
    isEmptyObject = function(obj) {
      var key;
      if (!(obj && typeof obj === 'object')) {
        return false;
      }
      for (key in obj) {
        if (Object.prototype.hasOwnProperty.call(obj, key)) {
          return false;
        }
      }
      return true;
    };
    VALUE_REGEX = /^(string|number|boolean)$/;
    isValue = function(obj) {
      return !obj || VALUE_REGEX.test(typeof obj) || obj instanceof Array;
    };
    diffObjects = function(obj1, obj2) {
      var diff, key, obj, value, value2;
      obj1 = duplicate(obj1);
      obj2 = duplicate(obj2);
      diff = {};
      for (key in obj1) {
        value = obj1[key];
        value2 = obj2[key];
        delete obj2[key];
        if (isValue(value2)) {
          if (value2 !== value) {
            diff[key] = value2;
          }
        } else if (typeof value2 === 'object') {
          obj = diffObjects(value, value2);
          if (!isEmptyObject(obj)) {
            diff[key] = obj;
          }
        } else {
          diff[key] = null;
        }
      }
      return extend(diff, obj2);
    };
    flattenAttributes = function(attrs, attrs2, prefix) {
      var key, value;
      if (attrs2 == null) {
        attrs2 = {};
      }
      if (prefix == null) {
        prefix = null;
      }
      for (key in attrs) {
        value = attrs[key];
        if (key === '_') {
          key = prefix;
        } else if (prefix) {
          key = "" + prefix + "-" + key;
        }
        if (isValue(value)) {
          attrs2[key] = value;
        } else {
          flattenAttributes(value, attrs2, key);
        }
      }
      return attrs2;
    };
    ElementDiff = (function() {

      function ElementDiff(element) {
        this.element = element;
      }

      ElementDiff.prototype.toString = function() {
        return "[ElementDiff: " + this.element[0] + "]";
      };

      ElementDiff.diffObjects = diffObjects;

      ElementDiff.isEmptyObject = isEmptyObject;

      ElementDiff.flattenAttributes = flattenAttributes;

      ElementDiff.prototype.getDiff = function(element2) {
        if (!(element2 && element2.size())) {

        }
      };

      ElementDiff.prototype.generateCode = function(method, args, selector) {
        var code, strArguments;
        if (args == null) {
          args = [];
        }
        if (typeof selector === 'undefined') {
          selector = this.element.selector;
        }
        strArguments = map(args, function(a) {
          return JSON.stringify(a);
        }).join(',');
        code = "" + method + "(" + strArguments + ")";
        if (selector) {
          return "$(\"" + selector + "\")." + code;
        } else {
          return code;
        }
      };

      ElementDiff.prototype.diffAttributes = function(element2, selector) {
        var attrs1, attrs2, diff, key, value;
        element2 = $(element2);
        attrs1 = this.element.attr();
        attrs2 = element2.attr();
        diff = flattenAttributes(diffObjects(attrs1, attrs2));
        for (key in diff) {
          value = diff[key];
          if (value === void 0) {
            diff[key] = null;
          }
        }
        if (!isEmptyObject(diff)) {
          return this.generateCode('attr', [diff], selector);
        } else {
          return null;
        }
      };

      return ElementDiff;

    })();
    $.elementDiff = ElementDiff;
    $.fn.elementDiff = function() {
      return new ElementDiff(this);
    };
    $.fn.getElementDiff = function(element2) {
      return this.elementDiff().getDiff(element2);
    };
    return this;
  })(jQuery);

}).call(this);

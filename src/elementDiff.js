(function() {

  (function($) {
    var ElementDiff, console, diffObjects, duplicate, extend, getAttributes, inArray, isEmptyObject, map, _attr;
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
    diffObjects = function(obj1, obj2) {
      var diff, key, obj, value, value2;
      obj1 = duplicate(obj1);
      obj2 = duplicate(obj2);
      diff = {};
      for (key in obj1) {
        value = obj1[key];
        value2 = obj2[key];
        delete obj2[key];
        if (/^(string|number|boolean)$/.test(typeof value2) || value2 instanceof Array) {
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
    ElementDiff = (function() {

      function ElementDiff(element) {
        this.element = element;
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
      diffObjects: diffObjects,
      isEmptyObject: isEmptyObject
    };
    $.fn.elementDiff = function() {
      return new ElementDiff(this);
    };
    $.fn.getElementDiff = function(element2) {
      return this.elementDiff().getDiff(element2);
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

/*! jQuery All Attributes - v0.1.0 - 2013-08-30
* https://github.com/ngs/jquery-allAttributes
* Copyright (c) 2013 Atsushi Nagase; Licensed MIT */
(function() {

  (function($) {
    "use strict";

    var getAttributes, _attr;
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

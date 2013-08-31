(function() {

  (function($) {
    "use strict";

    var ElementDiff, VALUE_REGEX, diffObjects, duplicate, extend, flattenAttributes, inArray, isEmptyObject, isValue, map, merge, nullDeeply, outerHTML;
    map = $.map;
    extend = $.extend;
    inArray = $.inArray;
    merge = $.merge;
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
    VALUE_REGEX = /^(string|number|boolean|undefined)$/;
    isValue = function(obj) {
      return !obj || VALUE_REGEX.test(typeof obj) || obj instanceof Array;
    };
    nullDeeply = function(obj) {
      var key, value;
      if (isValue(obj)) {
        return null;
      }
      for (key in obj) {
        value = obj[key];
        obj[key] = nullDeeply(value);
      }
      return obj;
    };
    diffObjects = function(obj1, obj2) {
      var diff, key, obj, value1, value2;
      obj1 = duplicate(obj1);
      obj2 = duplicate(obj2);
      diff = {};
      for (key in obj1) {
        value1 = obj1[key];
        value2 = obj2[key];
        delete obj2[key];
        if (isValue(value2) && isValue(value1)) {
          if (value2 !== value1) {
            diff[key] = value2;
          }
        } else if (typeof value2 === 'object') {
          obj = diffObjects(value1, value2);
          if (!isEmptyObject(obj)) {
            diff[key] = obj;
          }
        } else {
          diff[key] = nullDeeply(value1);
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
    outerHTML = function(element) {
      var div;
      div = $('<div />').append(element.clone());
      return $.trim(div.html()).replace(/\s*\n\s*/g, '');
    };
    ElementDiff = (function() {

      function ElementDiff(element, selector) {
        if (typeof selector === 'undefined') {
          selector = element.selector;
        }
        this.element = element;
        this.selector = selector;
      }

      ElementDiff.prototype.toString = function() {
        return "[ElementDiff: " + (this.selector || this.element[0]) + "]";
      };

      ElementDiff.diffObjects = diffObjects;

      ElementDiff.flattenAttributes = flattenAttributes;

      ElementDiff.isEmptyObject = isEmptyObject;

      ElementDiff.nullDeeply = nullDeeply;

      ElementDiff.outerHTML = outerHTML;

      ElementDiff.prototype.generateCode = function(method) {
        var args, strArguments;
        args = merge([], arguments).slice(1);
        strArguments = map(args, function(a) {
          return JSON.stringify(a);
        }).join(',');
        return "" + method + "(" + strArguments + ")";
      };

      ElementDiff.prototype.diffAttributes = function(element2) {
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
          return [this.generateCode('attr', diff)];
        } else {
          return [];
        }
      };

      ElementDiff.prototype.diffText = function(element2) {
        var children1, children2, codes, element1, size1, size2, text1, text2;
        element1 = this.element;
        element2 = $(element2);
        children1 = element1.children();
        children2 = element2.children();
        size1 = children1.size();
        size2 = children2.size();
        text1 = element1.text();
        text2 = element2.text();
        codes = [];
        if (size2 === 0 && text1 !== text2) {
          if (size1 > 0) {
            codes.push(this.generateCode('empty'));
          }
          codes.push(this.generateCode('text', text2));
          return codes;
        }
        return codes;
      };

      ElementDiff.prototype.isSameTag = function(element2) {
        return this.element.prop('nodeName') === $(element2).prop('nodeName');
      };

      ElementDiff.prototype.diff = function(element2) {
        var code, codes, element1;
        element1 = this.element;
        element2 = $(element2);
        if (!(element2 && element2.size())) {
          return [];
        }
        codes = [];
        if (this.isSameTag(element2)) {
          merge(codes, this.diffAttributes(element2));
          merge(codes, this.diffText(element2));
        } else {
          codes.push(this.generateCode('replaceWith', outerHTML(element2)));
        }
        if (codes.length) {
          code = codes.join('.');
          if (this.selector) {
            return ["$(\"" + this.selector + "\")." + code];
          } else {
            return [code];
          }
        } else {
          return [];
        }
      };

      ElementDiff.prototype.diffRecursive = function(element2) {
        var children1, children2, codes, element1, index, myDiff, selector, self, size1, size2;
        self = this;
        element1 = self.element;
        element2 = $(element2);
        myDiff = self.diff(element2);
        if (/\.(empty|replaceWith)\(/.test(myDiff[0])) {
          return myDiff;
        }
        codes = [];
        selector = self.selector;
        children1 = element1.children();
        children2 = element2.children();
        size1 = children1.size();
        size2 = children2.size();
        children2.each(function(index) {
          var child1, child2, childSelector;
          child1 = $(children1[index]);
          child2 = $(children2[index]);
          childSelector = "" + selector + " > :eq(" + index + ")";
          if (child1.size()) {
            return merge(codes, new ElementDiff(child1, childSelector).diffRecursive(child2));
          } else {
            return codes.push("$(\"" + selector + "\")." + (self.generateCode('append', outerHTML(child2))));
          }
        });
        index = size1;
        while (index > size2) {
          codes.push("$(\"" + selector + " > :eq(" + (--index) + ")\")." + (self.generateCode('remove')));
        }
        merge(codes, myDiff);
        return codes;
      };

      return ElementDiff;

    })();
    $.elementDiff = ElementDiff;
    $.fn.elementDiff = function(selector) {
      return new ElementDiff(this, selector);
    };
    $.fn.getElementDiff = function(element2, selector) {
      return this.elementDiff(selector).diffRecursive(element2);
    };
    return this;
  })(jQuery);

}).call(this);

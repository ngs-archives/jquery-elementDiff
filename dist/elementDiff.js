/*! jQuery Element Diff - v0.1.4 - 2013-10-02
 * https://github.com/ngs/jquery-elementDiff
 * Copyright (c) 2013 Atsushi Nagase; Licensed MIT */
(function() {

  (function($) {
    "use strict";

    var ElementDiff, LF, VALUE_REGEX, diffObjects, duplicate, escapeSelector, extend, flattenAttributes, fnSelector, getTextContents, hasTextNode, inArray, isEmptyObject, isValue, map, merge, nullDeeply, outerHTML, selectorChild, trim;
    LF = "\n";
    map = $.map;
    extend = $.extend;
    inArray = $.inArray;
    merge = $.merge;
    trim = $.trim;
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
    getTextContents = function(obj) {
      var nodes;
      nodes = obj.contents().filter(function() {
        return this.nodeType === 3 && trim(this.data);
      }).get();
      return map(nodes, function(node) {
        return trim(node.data);
      });
    };
    hasTextNode = function(obj) {
      return getTextContents(obj).length > 0;
    };
    escapeSelector = function(selector) {
      return selector.replace(/(")/g, "\\$1");
    };
    fnSelector = function(selector) {
      return "$(\"" + (escapeSelector(selector)) + "\")";
    };
    selectorChild = function(selector, index) {
      return "" + selector + " > :eq(" + index + ")";
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
      return trim(div.html()).replace(/>\s*\n\s*</g, '><');
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

      ElementDiff.getTextContents = getTextContents;

      ElementDiff.hasTextNode = hasTextNode;

      ElementDiff.isEmptyObject = isEmptyObject;

      ElementDiff.nullDeeply = nullDeeply;

      ElementDiff.outerHTML = outerHTML;

      ElementDiff.prototype.hasTextDiff = function(element2) {
        var text1, text2;
        text1 = getTextContents($(this.element));
        text2 = getTextContents($(element2));
        return text1.join(LF) !== text2.join(LF);
      };

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
        var children1, children2, codes, element1, html1, html2, size1, size2;
        element1 = this.element;
        element2 = $(element2);
        children1 = element1.children();
        children2 = element2.children();
        size1 = children1.size();
        size2 = children2.size();
        html1 = element1.html();
        html2 = element2.html();
        codes = [];
        if (this.hasTextDiff(element2)) {
          codes.push(this.generateCode('html', html2));
          return codes;
        }
        return codes;
      };

      ElementDiff.prototype.isSameTag = function(element2) {
        var NODE_NAME;
        NODE_NAME = 'nodeName';
        element2 = $(element2);
        return element2.size() === 1 && this.element.prop(NODE_NAME) === element2.prop(NODE_NAME);
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
            return ["" + (fnSelector(this.selector)) + "." + code];
          } else {
            return [code];
          }
        } else {
          return [];
        }
      };

      ElementDiff.prototype.diffRecursive = function(element2) {
        var children1, children2, codes, element1, fn, index, myDiff, selector, self, size1, size2, testElement;
        self = this;
        element1 = self.element;
        element2 = $(element2);
        myDiff = self.diff(element2);
        if (!this.isSameTag(element2)) {
          return myDiff;
        }
        if (myDiff[0]) {
          testElement = element1.clone();
          fn = myDiff[0].replace(/^\$\("(.*?)"\)\./, 'ele.');
          /* jshint -W054
          */

          new Function('ele', fn).call(this, testElement);
          if (testElement.html() !== element1.html()) {
            return myDiff;
          }
        }
        codes = [];
        selector = self.selector;
        children1 = element1.children();
        children2 = element2.children();
        size1 = children1.size();
        size2 = children2.size();
        children2.each(function(index) {
          var child1, child2;
          child1 = $(children1[index]);
          child2 = $(children2[index]);
          if (child1.size()) {
            return merge(codes, new ElementDiff(child1, selectorChild(selector, index)).diffRecursive(child2));
          } else {
            return codes.push("" + (fnSelector(selector)) + "." + (self.generateCode('append', outerHTML(child2))));
          }
        });
        index = size1;
        while (index > size2) {
          codes.push("" + (fnSelector(selectorChild(selector, --index))) + "." + (self.generateCode('remove')));
        }
        merge(codes, myDiff);
        return codes;
      };

      return ElementDiff;

    })();
    $.elementDiff = ElementDiff;
    extend($.fn, {
      elementDiff: function(selector) {
        return new ElementDiff(this, selector);
      },
      getElementDiff: function(element2, selector) {
        return this.elementDiff(selector).diffRecursive(element2);
      }
    });
    return this;
  })(jQuery);

}).call(this);

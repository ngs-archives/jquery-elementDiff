# jQuery Element Diff

jQuery plugin that generates JavaScript code to arrange element to be same.

[![Build Status](https://travis-ci.org/ngs/jquery-elementDiff.png?branch=master)](https://travis-ci.org/ngs/jquery-elementDiff)

## Getting Started
```html
<script src="jquery.js"></script>
<script src="dist/elementDiff.min.js"></script>
```

## Documentation
### `jQuery.fn.getElementDiff(element2, selector = null)`

Generates JavaScript code to

### `jQuery.fn.elementDiff()`

Returns `ElementDiff` instance.

## Examples
```html
<div id="sample-text1">
  Lorem ipsum
  <span class="span1">dolor</span>
  <span class="span2">sit</span>
  <span class="span3">amet</span>,
  <span class="span4">consectetur</span>
  <span class="span5">adipiscing</span>
  <span class="span6">elit</span>.
</div>
<div id="sample-text2">
  Lorem ipsum
  <span class="span1" id="dolor">dolor</span>
  <span class="span2">sit!</span>
  <b class="span3">amet</b>,
  <span class="span5">adipiscing</span>
  <span class="span6">elit</span>.
</div>
```

```javascript
$("#sample-text1").getElementDiff($("#sample-text2"));
```

Returns:

```javascript
[
  "$(\"#sample-text1 > :eq(0)\").attr({\"id\":\"dolor\"})",
  "$(\"#sample-text1 > :eq(1)\").html(\"sit!\")",
  "$(\"#sample-text1 > :eq(2)\").replaceWith(\"<b class=\\\"span3\\\">amet</b>\")",
  "$(\"#sample-text1 > :eq(3)\").attr({\"class\":\"span5\"}).html(\"adipiscing\")",
  "$(\"#sample-text1 > :eq(4)\").attr({\"class\":\"span6\"}).html(\"elit\")",
  "$(\"#sample-text1 > :eq(5)\").remove()",
  "$(\"#sample-text1\").attr({\"id\":\"sample-text2\"})"
]
```

## Testing
```bash
$ npm install
$ npm test
```

## Author

* Atsushi Nagase (http://ngs.io/)

## License
[MIT License](http://en.wikipedia.org/wiki/MIT_License)

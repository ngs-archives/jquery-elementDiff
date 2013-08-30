# jQuery Element Diff

jQuery plugin that generates JavaScript code to arrange element to be same.

[![Build Status](https://travis-ci.org/ngs/jquery-elementDiff.png?branch=master)](https://travis-ci.org/ngs/jquery-elementDiff)

## Getting Started
```html
<script src="jquery.js"></script>
<script src="dist/elementDiff.min.js"></script>
```

## Documentation
### `jQuery.fn.getElementDiff(element2, options = {})`

Generates JavaScript code to 

### `jQuery.fn.elementDiff(options = {})`

Returns ElementDiff instance.

### `jQuery.elementDiff.options = []`
Default options.


## Examples
```html
<div id="foo">Test</div>
```

```javascript
$("#foo").getElementDiff($(""))
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

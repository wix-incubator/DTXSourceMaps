# DTXSourceMaps
An iOS parser and translator for JavaScript source maps.

Based on [Mozilla's JavaScript implementation](https://github.com/mozilla/source-map/).

### Using

Add `DTXSourceMaps.xcodeproj` to your project. In your target's settings, add `DTXSourceMaps` to embedded binaries.

Import the framework's umbrella header:

```objc
#import <DTXSourceMaps/DTXSourceMaps.h>

…

DTXSourceMapsParser* parser = [DTXSourceMapsParser sourceMapsParserForSourceMaps:sourceMaps];

DTXSourcePosition* position = [DTXSourcePosition new];
position.line = @12;
position.column = @48;
	
DTXSourcePosition* symbolicatedPosition = [parser originalPositionForPosition:position];
```


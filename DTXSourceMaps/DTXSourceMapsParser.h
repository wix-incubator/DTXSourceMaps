//
//  DTXSourceMapsParser.h
//  DTXSourceMaps
//
//  Created by Leo Natan (Wix) on 02/07/2017.
//  Copyright © 2017 Wix. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString* DTXSourceMapsKey __attribute__((swift_wrapper(enum)));

extern DTXSourceMapsKey const DTXSourceMapsVersionKey;
extern DTXSourceMapsKey const DTXSourceMapsSectionsKey;
extern DTXSourceMapsKey const DTXSourceMapsSourcesKey;
extern DTXSourceMapsKey const DTXSourceMapsNamesKey;
extern DTXSourceMapsKey const DTXSourceMapsSourceRootKey;
extern DTXSourceMapsKey const DTXSourceMapsSourcesContentKey;
extern DTXSourceMapsKey const DTXSourceMapsMappingsKey;
extern DTXSourceMapsKey const DTXSourceMapsFileKey;

/**
 * Represents a generated or original source position.
 */
@interface DTXSourcePosition : NSObject

/**
 * The source line number (starting at 1).
 */
@property (nonatomic, copy, nullable) NSNumber* line;
/**
 * The source column number (starting at 1).
 */
@property (nonatomic, copy, nullable) NSNumber* column;

/**
 * The source file name;
 */
@property (nonatomic, copy, nullable) NSString* sourceFileName;
/**
 * The symbol name;
 */
@property (nonatomic, copy, nullable) NSString* symbolName;

@end

/**
 * A source maps parser and translator.
 */
@interface DTXSourceMapsParser : NSObject

/**
 * Returns a parser for the provided source maps.
 *
 * @param sourceMaps The source maps to parse.
 */
+ (instancetype)sourceMapsParserForSourceMaps:(NSDictionary<DTXSourceMapsKey, id>*)sourceMaps;

/**
 * The current source maps.
 */
@property (nonatomic, copy, readonly) NSDictionary<DTXSourceMapsKey, id>* sourceMaps;

/**
 * Translates a generated position into the original position.
 *
 * @param position The generated position.
 */
- (nullable DTXSourcePosition*)originalPositionForPosition:(DTXSourcePosition*)position;

@end

NS_ASSUME_NONNULL_END

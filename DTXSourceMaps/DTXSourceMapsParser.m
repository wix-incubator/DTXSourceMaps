//
//  DTXSourceMapsParser.m
//  DTXSourceMaps
//
//  Created by Leo Natan (Wix) on 02/07/2017.
//  Copyright © 2017 Wix. All rights reserved.
//

#import "DTXSourceMapsParser-Private.h"
#import "_DTXBasicSourceMapsConsumer.h"
#import "_DTXIndexedSourceMapsConsumer.h"

static const NSInteger __suportedVersion = 3;

DTXSourceMapsKey const DTXSourceMapsVersionKey = @"version";
DTXSourceMapsKey const DTXSourceMapsSectionsKey = @"sections";
DTXSourceMapsKey const DTXSourceMapsSourcesKey = @"sources";
DTXSourceMapsKey const DTXSourceMapsNamesKey = @"names";
DTXSourceMapsKey const DTXSourceMapsSourceRootKey = @"sourceRoot";
DTXSourceMapsKey const DTXSourceMapsSourcesContentKey = @"sourcesContent";
DTXSourceMapsKey const DTXSourceMapsMappingsKey = @"mappings";
DTXSourceMapsKey const DTXSourceMapsFileKey = @"file";

@implementation DTXSourcePosition

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p; sourceFileName = %@; line = %@; column = %@; symbolName = %@>", self.class, self, self.sourceFileName, self.line, self.column, self.symbolName];
}

@end

@implementation DTXSourceMapsParser

+ (instancetype)sourceMapsParserForSourceMaps:(NSDictionary<NSString*, id>*)sourceMaps
{
	DTXSourceMapsParser* rv = nil;
	
	if(sourceMaps[DTXSourceMapsSectionsKey] != nil)
	{
		rv= [[_DTXIndexedSourceMapsConsumer alloc] _initWithSouceMaps:sourceMaps];
	}
	else
	{
		rv = [[_DTXBasicSourceMapsConsumer alloc] _initWithSouceMaps:sourceMaps];
	}
	
	return rv;
}

- (instancetype)_initWithSouceMaps:(NSDictionary<NSString*, id>*)sourceMaps
{
	self = [super init];
	
	if(self)
	{
		_sourceMaps = sourceMaps;
		_sections = sourceMaps[DTXSourceMapsSectionsKey];
		_version = [sourceMaps[DTXSourceMapsVersionKey] integerValue];
		_sources = sourceMaps[DTXSourceMapsSourcesKey];
		_names = sourceMaps[DTXSourceMapsNamesKey];
		_sourceRoot = sourceMaps[DTXSourceMapsSourceRootKey];
		_sourcesContent = sourceMaps[DTXSourceMapsSourcesContentKey];
		_mappings = sourceMaps[DTXSourceMapsMappingsKey];
		_file = sourceMaps[DTXSourceMapsFileKey];
		
		if(_version != __suportedVersion)
		{
			NSLog(@"Unsupported source maps version %ld", (long int)_version);
			return nil;
		}
	}
	
	return self;
}

- (DTXSourcePosition *)originalPositionForPosition:(DTXSourcePosition *)position
{
	return nil;
}
@end

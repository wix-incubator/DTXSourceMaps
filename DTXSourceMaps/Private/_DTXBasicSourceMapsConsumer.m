//
//  _DTXBasicSourceMapsConsumer.m
//  DTXSourceMaps
//
//  Created by Leo Natan (Wix) on 02/07/2017.
//  Copyright © 2017 Wix. All rights reserved.
//

#import "_DTXBasicSourceMapsConsumer.h"
#import "_DTXBase64VLQ.h"

@class _DTXBasicSourceMapsConsumer;

@interface _DTXSourceMapping : NSObject

@property (nonatomic, copy) NSNumber* originalLine;
@property (nonatomic, copy) NSNumber* generatedLine;

@property (nonatomic, copy) NSNumber* originalColumn;
@property (nonatomic, copy) NSNumber* generatedColumn;

@property (nonatomic, copy) NSNumber* lastGeneratedColumn;

@property (nonatomic, copy) NSNumber* sourceIndex;
@property (nonatomic, copy) NSNumber* nameIndex;

@property (nonatomic, weak) _DTXBasicSourceMapsConsumer* owner;

@end

@interface _DTXBasicSourceMapsConsumer ()

@property (nonatomic, copy, getter=_generatedMappings, setter=_setGeneratedMappings:) NSArray<_DTXSourceMapping*>* generatedMappings;

@end

@implementation _DTXSourceMapping

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p; source = \"%@\"; generatedLine = %@; generatedColumn = %@; originalLine = %@; originalColumn = %@; name = \"%@\">", self.class, self, self.sourceIndex == nil || self.owner == nil ? self.sourceIndex : [self.owner.sources[self.sourceIndex.integerValue] lastPathComponent], self.generatedLine, self.generatedColumn, self.originalLine, self.originalColumn, self.nameIndex == nil || self.owner == nil ? self.nameIndex : self.owner.names[self.nameIndex.integerValue]];
}

@end

@implementation _DTXBasicSourceMapsConsumer

- (instancetype)_initWithSouceMaps:(NSDictionary<NSString*, id>*)sourceMaps
{
	self = [super _initWithSouceMaps:sourceMaps];
	
	if(self)
	{
		
	}
	
	return self;
}

static BOOL _DTXSourceMapsConsumerIsMappingSeparator(unichar ch)
{
	return ch == ';' || ch == ',';
}

- (id)_generatedPositionsDeflatedComparator
{
	return ^ (_DTXSourceMapping* a, _DTXSourceMapping* b) {
		NSComparisonResult rv = [a.generatedLine compare:b.generatedLine];
		if(rv != NSOrderedSame)
		{
			return rv;
		}
		
		rv = [a.generatedColumn compare:b.generatedColumn];
		if(rv != NSOrderedSame)
		{
			return rv;
		}
		
		rv = [a.sourceIndex compare:b.sourceIndex];
		if(rv != NSOrderedSame)
		{
			return rv;
		}
		
		rv = [a.originalLine compare:b.originalLine];
		if(rv != NSOrderedSame)
		{
			return rv;
		}
		
		rv = [a.originalColumn compare:b.originalColumn];
		if(rv != NSOrderedSame)
		{
			return rv;
		}
		
		return [a.nameIndex compare:b.nameIndex];
	};
}

- (void)_parse
{
	NSInteger generatedLine = 1;
	NSInteger previousGeneratedColumn = 0;
	NSInteger previousOriginalLine = 0;
	NSInteger previousOriginalColumn = 0;
	NSInteger previousSource = 0;
	NSInteger previousName = 0;
	NSInteger index = 0;
	
	NSMutableDictionary* cachedSegments = [NSMutableDictionary new];
	
	NSMutableArray* generatedMappings = [NSMutableArray new];
	
	NSString* str;
	NSMutableArray* segment;
	
	NSInteger value;
	
	while(index < self.mappings.length)
	{
		if([self.mappings characterAtIndex:index] == ';')
		{
			generatedLine++;
			index++;
			previousGeneratedColumn = 0;
		}
		else if ([self.mappings characterAtIndex:index] == ',')
		{
			index++;
		}
		else
		{
			_DTXSourceMapping* mapping = [_DTXSourceMapping new];
			mapping.owner = self;
			mapping.generatedLine = @(generatedLine);
			
			NSInteger end;
			for(end = index; end < self.mappings.length; end++)
			{
				if(_DTXSourceMapsConsumerIsMappingSeparator([self.mappings characterAtIndex:end]))
				{
					break;
				}
			}
			
			str = [self.mappings substringWithRange:NSMakeRange(index, end - index)];
			
			segment = cachedSegments[str];
			if(segment)
			{
				index += str.length;
			}
			else
			{
				segment = [NSMutableArray new];
				while(index < end)
				{
					_DTXBase64VLQDecode(self.mappings, index, &value, &index);
					[segment addObject:@(value)];
				}
				
				if(segment.count == 2)
				{
					[NSException raise:NSInternalInconsistencyException format:@"Found a source, but no line and column"];
				}
				
				if(segment.count == 3)
				{
					[NSException raise:NSInternalInconsistencyException format:@"Found a source and line, but no column"];
				}
				
				cachedSegments[str] = segment;
			}
			
			mapping.generatedColumn = @(previousGeneratedColumn + [segment[0] integerValue]);
			previousGeneratedColumn = mapping.generatedColumn.integerValue;
			
			if(segment.count > 1)
			{
				mapping.sourceIndex = @(previousSource + [segment[1] integerValue]);
				previousSource += [segment[1] integerValue];
				
				mapping.originalLine = @(previousOriginalLine + [segment[2] integerValue]);
				previousOriginalLine = mapping.originalLine.integerValue;
				mapping.originalLine = @(mapping.originalLine.integerValue + 1);
				
				mapping.originalColumn = @(previousOriginalColumn + [segment[3] integerValue]);
				previousOriginalColumn = mapping.originalColumn.integerValue;
				
				if(segment.count > 4)
				{
					mapping.nameIndex = @(previousName + [segment[4] integerValue]);
					previousName += [segment[4] integerValue];
				}
			}
			
			[generatedMappings addObject:mapping];
		}
	}
	
	[generatedMappings sortUsingComparator:self._generatedPositionsDeflatedComparator];
	[self _setGeneratedMappings:generatedMappings];
}

- (NSArray *)_generatedMappings
{
	if(_generatedMappings == nil)
	{
		[self _parse];
	}
	
	return _generatedMappings;
}


- (DTXSourcePosition *)originalPositionForPosition:(DTXSourcePosition *)position
{
	_DTXSourceMapping* needle = [_DTXSourceMapping new];
	needle.generatedLine = position.line;
	needle.generatedColumn = position.column;
	//Fill some empty data to prevent `compare:` crashes due to nil.
	needle.originalLine = @0;
	needle.originalColumn = @0;
	needle.sourceIndex = @0;
	needle.nameIndex = @0;
	
	NSInteger index = [self._generatedMappings indexOfObject:needle inSortedRange:NSMakeRange(0, self._generatedMappings.count) options:NSBinarySearchingLastEqual | NSBinarySearchingInsertionIndex usingComparator:self._generatedPositionsDeflatedComparator];
	
	if(index > 0)
	{
		_DTXSourceMapping* mapping = self._generatedMappings[index];
		
		if([mapping.generatedLine isEqualToNumber:needle.generatedLine])
		{
			NSString* source = nil;
			
			NSNumber* sourceN = mapping.sourceIndex;
			if(sourceN != nil)
			{
				source = self.sources[sourceN.integerValue];
			}
			
			NSString* name = nil;
			
			NSNumber* nameN = mapping.nameIndex;
			if(nameN != nil)
			{
				name = self.names[nameN.integerValue];
			}
			
			DTXSourcePosition* rv = [DTXSourcePosition new];
			rv.sourceFileName = source;
			rv.symbolName = name;
			rv.line = mapping.originalLine;
			rv.column = mapping.originalColumn;
			
			return rv;
		}
	}
	
	return nil;
}



@end

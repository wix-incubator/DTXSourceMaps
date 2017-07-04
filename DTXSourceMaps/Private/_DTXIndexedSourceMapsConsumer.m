//
//  DTXIndexedSourceMapConsumer.m
//  DTXSourceMaps
//
//  Created by Leo Natan (Wix) on 03/07/2017.
//  Copyright © 2017 Leo Natan (Wix). All rights reserved.
//

#import "_DTXIndexedSourceMapsConsumer.h"

@interface _DTXSectionInternal : NSObject

@property (nonatomic, copy) NSNumber* generatedLine;
@property (nonatomic, copy) NSNumber* generatedColumn;

@property (nonatomic, strong) DTXSourceMapsParser* consumer;

@end

@implementation _DTXSectionInternal

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p; generatedLine = %@; generatedColumn = %@; consumer = <%@: %p>>", self.class, self, self.generatedLine, self.generatedColumn, self.consumer.class, self.consumer];
}

@end

@implementation _DTXIndexedSourceMapsConsumer
{
	NSMutableArray<_DTXSectionInternal*>* _internalSections;
}

- (instancetype)_initWithSouceMaps:(NSDictionary<NSString*, id>*)sourceMaps
{
	self = [super _initWithSouceMaps:sourceMaps];
	
	__block NSDictionary* lastOffset = @{@"line": @-1, @"column": @0};
	
	if(self)
	{
		_internalSections = [NSMutableArray new];
		
		[self.sections enumerateObjectsUsingBlock:^(NSDictionary<DTXSourceMapsKey,id> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			if(obj[@"url"] != nil)
			{
				[NSException raise:NSInvalidArgumentException format:@"Support for url field in sections not implemented."];
			}
			
			NSDictionary* offset = obj[@"offset"];
			NSNumber* offsetLine = offset[@"line"];
			NSNumber* offsetColumn = offset[@"column"];
			
			if(offsetLine.integerValue < [lastOffset[@"line"] integerValue] || (offsetLine.integerValue == [lastOffset[@"line"] integerValue] && offsetColumn.integerValue < [lastOffset[@"column"] integerValue]))
			{
				[NSException raise:NSInvalidArgumentException format:@"Section offsets must be ordered and non-overlapping."];
			}
			
			lastOffset = offset;
			
			_DTXSectionInternal* internalSection = [_DTXSectionInternal new];
			
			internalSection.generatedLine = @(offsetLine.integerValue + 1);
			internalSection.generatedColumn = @(offsetColumn.integerValue + 1);
			
			internalSection.consumer = [DTXSourceMapsParser sourceMapsParserForSourceMaps:obj[@"map"]];
			
			[_internalSections addObject:internalSection];
		}];
	}
	
	return self;
}

- (DTXSourcePosition *)originalPositionForPosition:(DTXSourcePosition *)position
{
	_DTXSectionInternal* sectionNeedle = [_DTXSectionInternal new];
	sectionNeedle.generatedLine = position.line;
	sectionNeedle.generatedColumn = position.column;
	
	NSInteger sectionIndex = [_internalSections indexOfObject:sectionNeedle inSortedRange:NSMakeRange(0, _internalSections.count) options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(_DTXSectionInternal*  _Nonnull section, _DTXSectionInternal*  _Nonnull needle) {
		NSComparisonResult cmp = [section.generatedLine compare:needle.generatedLine];
		if(cmp != 0)
		{
			return cmp;
		}
		
		return [section.generatedColumn compare:needle.generatedColumn];
	}];
	
	if(sectionIndex == 0)
	{
		return nil;
	}
	
	_DTXSectionInternal* section = _internalSections[sectionIndex - 1];
	
	DTXSourcePosition* innerPosition = [DTXSourcePosition new];
	innerPosition.line = @(sectionNeedle.generatedLine.integerValue - (section.generatedLine.integerValue - 1));
	innerPosition.column = @(sectionNeedle.generatedColumn.integerValue - (sectionNeedle.generatedLine.integerValue == section.generatedLine.integerValue ? section.generatedColumn.integerValue - 1 : 0));
	
	return [section.consumer originalPositionForPosition:innerPosition];
}

@end

//
//  DTXSourceMapsParser-Private.h
//  DTXSourceMaps
//
//  Created by Leo Natan (Wix) on 02/07/2017.
//  Copyright © 2017 Wix. All rights reserved.
//

#import "DTXSourceMapsParser.h"

@interface DTXSourceMapsParser ()

@property (nonatomic, readonly) NSInteger version;
@property (nonatomic, copy, readonly) NSArray<NSString*>* sources;
@property (nonatomic, copy, readonly) NSString* sourceRoot;
@property (nonatomic, copy, readonly) NSArray<NSString*>* sourcesContent;
@property (nonatomic, copy, readonly) NSArray<NSString*>* names;
@property (nonatomic, copy, readonly) NSArray<NSDictionary<DTXSourceMapsKey, id>*>* sections;
@property (nonatomic, copy, readonly) NSString* mappings;
@property (nonatomic, copy, readonly) NSString* file;

- (instancetype)_initWithSouceMaps:(NSDictionary<NSString*, id>*)sourceMaps;

@end

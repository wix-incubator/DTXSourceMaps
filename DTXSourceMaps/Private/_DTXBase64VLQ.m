//
//  _DTXBase64VLQ.m
//  DTXSourceMaps
//
//  Created by Leo Natan (Wix) on 02/07/2017.
//  Copyright © 2017 Wix. All rights reserved.
//

#import "_DTXBase64VLQ.h"

static const NSInteger VLQ_BASE_SHIFT = 5;
static const NSInteger VLQ_BASE = 1 << VLQ_BASE_SHIFT;
static const NSInteger VLQ_BASE_MASK = VLQ_BASE - 1;
static const NSInteger VLQ_CONTINUATION_BIT = VLQ_BASE;

static NSInteger __b64decode(unichar ch)
{
	if('A' <= ch && ch <= 'Z')
	{
		return (ch - 'A');
	}
	
	if('a' <= ch && ch <= 'z')
	{
		return (ch - 'a' + 26);
	}
	
	if('0' <= ch && ch <= '9')
	{
		return (ch - '0' + 52);
	}
	
	if(ch == '+')
	{
		return 62;
	}
	
	if(ch == '/')
	{
		return 63;
	}
	
	return -1;
}

static NSInteger __fromVLQSigned(NSInteger value)
{
	BOOL isNegative = (value & 1) == 1;
	NSInteger shifted = value >> 1;
	return isNegative ? -shifted : shifted;
}

extern void _DTXBase64VLQDecode(NSString* mappings, NSInteger idx, NSInteger* value, NSInteger* rest)
{
	NSInteger result = 0;
	NSInteger shift = 0;
	BOOL shouldContinue = NO;
	
	do
	{
		if(idx >= mappings.length)
		{
			[NSException raise:NSInvalidArgumentException format:@"Expected more digits in base 64 VLQ value."];
		}
		
		NSInteger digit = __b64decode([mappings characterAtIndex:idx++]);
		if(digit == -1)
		{
			[NSException raise:NSInvalidArgumentException format:@"Invalid base64 digit: %C", [mappings characterAtIndex:idx - 1]];
		}
		
		shouldContinue = (digit & VLQ_CONTINUATION_BIT) == VLQ_CONTINUATION_BIT;
		
		digit &= VLQ_BASE_MASK;
		result += (digit << shift);
		shift += VLQ_BASE_SHIFT;
	} while(shouldContinue);
	
	*value = __fromVLQSigned(result);
	*rest = idx;
}

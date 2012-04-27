/*
 * CPMutableDictionary+SlideshowData.j
 * 
 * Copyright (c) 2012 Hendrik Holtmann
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 
 * Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 * 
 * Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 * 
 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */


@import <Foundation/CPDictionary.j>
@import <Foundation/CPArray.j>
@import "CKJSONKeyedArchiver.j"
@import "CKJSONKeyedUnarchiver.j"

@implementation CPMutableDictionary (SlideshowData)

- (CPMutableDictionary)metadata
{
	return [self objectForKey:@"meta"];
}

- (CPMutableArray)slides
{
	if ([self objectForKey:@"slides"] == nil)
	{
		[self setObject:[CPMutableArray array] forKey:@"slides"];
	}
	return [self objectForKey:@"slides"];
}

- (CPMutableDictionary)slideAtPosition:(long)miliseconds
{
	slides = [self slides];
	if (miliseconds == 0) return [slides objectAtIndex:0];
	var length = 0;
	for (var i = 0; i < [slides count]; i++)
	{
		length += [[[slides objectAtIndex:i] objectForKey:@"length"] longValue];
		if (length > miliseconds)
		{
			return [slides objectAtIndex:i-1];
		}
	}
	return nil;
}

- (void)insertSlideWithImage:(CPString)image caption:(CPString)caption andLength :(long)miliseconds
{
	[self insertSlide:[CPMutableDictionary dictionaryWithObjectsAndKeys:image, @"file", caption, @"caption", [CPNumber numberWithLong:miliseconds], @"length"]];
}

- (void)insertSlide:(CPMutableDictionary)slide atPosition:(int)aIndex
{
	slides = [self slides];
	[slides insertObject:slide atIndex:aIndex];
}

- (void)insertSlide:(CPMutableDictionary)slide
{
	slides = [self slides];
	[slides addObject:slide];
}

- (JSON)toJSON
{
	var jsonobject = {};
	for (var i = 0; i < [[self allKeys] count]; i++)
	{
		var key = [[self allKeys] objectAtIndex:i];
		jsonobject[key] = [self _toJSON:[self objectForKey:key]];
	}
	return jsonobject;
}

- (JSON)_toJSON:(id)element
{
	if ([element class] == CPMutableDictionary || [element class] == CPDictionary)
	{
		var dataDict = element;
		var jsonDictObject = {};
		for (var j = 0; j < [[dataDict allKeys] count]; j++)
		{
			var key = [[dataDict allKeys] objectAtIndex:j];
			jsonDictObject[key] = [self _toJSON:[dataDict objectForKey:key]];
		}
		return jsonDictObject;
	}
	else if ([element class] == CPMutableArray || [element class] == CPArray)
	{
		var dataArray = element;
		var jsonArrayObject = [];
		for (var k = 0; k < [dataArray count]; k++)
		{
			jsonArrayObject[k] = [self _toJSON:[dataArray objectAtIndex:k]];
		}
		return jsonArrayObject;
	}
	else
	{
		return element;
	}
}

@end
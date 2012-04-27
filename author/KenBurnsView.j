/*
 * KenBurnsView.j
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



@import <AppKit/CPView.j>
@import "KenBurnsLayer.j"

@implementation KenBurnsView : CPView
{
	KenBurnsLayer _kenBurnsLayer;
	BOOL _freeze;
}

- (id)initWithFrame:(CGRect)aRect
{
	if (self = [super initWithFrame:aRect])
	{
		[self setBackgroundColor:[CPColor clearColor]];
		_freeze = NO;
		_kenBurnsLayer = [[KenBurnsLayer alloc] initWithView:self];
		[_kenBurnsLayer setBounds:[self bounds]];
		[_kenBurnsLayer setAnchorPoint:CGPointMakeZero()];
		[self setWantsLayer:YES];
		[self setLayer:_kenBurnsLayer];
		[_kenBurnsLayer setNeedsDisplay];
	}  
	return self;
}

-(void)freezePercentage:(BOOL)aFreeze
{
	_freeze = aFreeze;
}

- (CPImage)image
{
	return [_kenBurnsLayer image];
}

- (void) setImage:(CPImage)aImage
{
	[_kenBurnsLayer setImage:aImage];
	[_kenBurnsLayer setPercentage:0.0];
	[_kenBurnsLayer setNeedsDisplay];
}

- (void)setPercentage:(double)aPercentage
{
	if (!_freeze)
	{
		[_kenBurnsLayer setPercentage:aPercentage];
	 	[_kenBurnsLayer setNeedsDisplay];
	}
}

- (double)percentage
{
	return [_kenBurnsLayer percentage];
}

@end
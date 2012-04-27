/*
 * SlideWidthIndicator.j
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

@implementation SlideWidthIndicator : CPView
{
	id _delegate @accessors(property=delegate);
}

- (id)initWithFrame:(CGRect)aRect
{
	if (self = [super initWithFrame:aRect])
	{
		[self setBackgroundColor:[CPColor colorWithCSSString:@"transparent"]];
	}
	return self;
}

- (void)drawRect:(CGRect)aRect
{
	if (_delegate && [_delegate respondsToSelector:@selector(lengthUnit)])
	{
		for (var i = [[self subviews] count]-1; i >= 0; i--)
		{
			[[[self subviews] objectAtIndex:i] removeFromSuperview];
		}

		var context = [[CPGraphicsContext currentContext] graphicsPort];
		var length = (aRect.size.width / [_delegate lengthUnit]) / 1000.0;

		var label = [CPTextField labelWithTitle:[CPString stringWithFormat:@"%d:%02d.%d", length / 60, length % 60, (length * 10)%10]];
		[label setFont:[CPFont systemFontOfSize:12.0]];
		[label setBackgroundColor:[CPColor colorWithCSSString:@"transparent"]];
		[label sizeToFit];
		if ([label frame].size.width + 4 < aRect.size.width)
		{
			[label setFrameOrigin:CPPointMake((aRect.size.width / 2)-([label frame].size.width / 2), (aRect.size.height / 2) - ([label frame].size.height / 2))];
			[self addSubview:label];
		}
	}
}

@end

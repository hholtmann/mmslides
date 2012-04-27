/*
 * CaptionView.j
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

@implementation CaptionView : CPView
{
	CPTextField _caption;
	CPColor _captionBackgroundColor @accessors(property=captionBackgroundColor);
	CPColor _captionColor @accessors(property=captionColor);
}

- (id)initWithFrame:(CGRect)aRect
{
	if (self = [super initWithFrame:aRect])
	{
		[self setBackgroundColor:[CPColor clearColor]];
		_captionBackgroundColor = [CPColor colorWithCalibratedRed:0.25 green:0.25 blue:0.25 alpha:0.75];
		_captionColor = [CPColor whiteColor];
		
		_caption = [CPFocusTextField labelWithTitle:@"Transition"];
		[_caption setFrameOrigin:CGPointMake(10,230)];
		[_caption setTextColor:_captionColor];
		[_caption setLineBreakMode:CPLineBreakByWordWrapping]; 
		[_caption setFont:[CPFont boldSystemFontOfSize:15.0]];
		[_caption setAlignment:CPCenterTextAlignment];
		[_caption setVerticalAlignment:CPCenterVerticalTextAlignment];
		[self addSubview:_caption];
	}
	return self;
}

- (void)drawRect:(CGRect)aRect
{
	var context = [[CPGraphicsContext currentContext] graphicsPort];
	CGContextSetFillColor(context, _captionBackgroundColor);
	CGContextFillRect(context, aRect);
}

- (void)setCaptionColor:(CPColor)aColor
{
	_captionColor = aColor;
	[_caption setTextColor:aColor];
}

- (void)setFrame:(CPRect)aRect
{
	[super setFrame:aRect];
	[_caption setFrame:CGRectMake(0,([self frame].size.height/2)-([_caption frame].size.height/2),[self frame].size.width,[_caption frame].size.height)];
}

- (void)setCaption:(CPString)aCaption
{
	[_caption setFrame:[self frame]];
	var s = [aCaption sizeWithFont:[_caption font] inWidth:[self frame].size.width];
	[_caption setStringValue:aCaption];
	[_caption sizeToFit];
	[_caption setFrame:CGRectMake(0,([self frame].size.height/2)-([_caption frame].size.height/2),[self frame].size.width,s.height + 5.0)];
}

- (CPSize)captionSize
{
	return [_caption frame].size;
}

@end
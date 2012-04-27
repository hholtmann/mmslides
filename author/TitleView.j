/*
 * TitleView.j
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

@implementation TitleView : CPView
{
	CPString _title @accessors(property=title);
	CPImageView _itemImageView;
}

- (id)initWithFrame:(CGRect)aRect
{
	if (self = [super initWithFrame:aRect])
	{
		[self setAutoresizesSubviews:YES];
		[self setAutoresizingMask:CPViewWidthSizable];

		_title = [CPTextField labelWithTitle:CPLocalizedString(@"Untitled")];
		[_title setFrame:CGRectMake(35,6, aRect.size.width-35,24)];
		[_title setFont:[CPFont boldSystemFontOfSize:14.0]];
		[_title setTextColor:[CPColor colorWithHexString:@"333333"]];
		[self addSubview:_title];
		
		_itemImageView = [[CPImageView alloc] initWithFrame:CGRectMake(0,0,32,32)];
		var bundle = [CPBundle mainBundle];
		img = [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"80_slideshow_title.png"]];
		[_itemImageView setImage:img];
		[self addSubview:_itemImageView];
		
		[self setTitle:CPLocalizedString(@"Untitled")];
	}
	return self;
}

- (void)setTitle:(CPString)aValue
{
	if ([aValue length] > 60) aValue = [[aValue substringToIndex:60] stringByAppendingString:@"..."];
	[_title setStringValue:aValue];
}

@end
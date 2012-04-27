/*
 * PropertiesView.j
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

@import <AppKit/CPBox.j>
@import "Session.j"
@import "SlideView.j"
@import "CPBundle+Localization.j"

@implementation PropertiesView : CPBox
{
	id _delegate @accessors(property=delegate);
	SlideView _slideView @accessors(readonly,property=slideView);
}

- (id)initWithFrame:(CGRect)aRect
{
	if (self = [super initWithFrame:aRect])
	{
		[self setBorderType:CPLineBorder];
		[self setFillColor:[CPColor colorWithHexString:@"ebebeb"]];
		[self setBorderColor:[CPColor colorWithHexString:@"9e9e9e"]];
		[self setAutoresizesSubviews:YES];
		[self setAutoresizingMask:CPViewWidthSizable];

		_slideView = [[SlideView alloc] initWithFrame:CGRectMake(1,1,aRect.size.width-2,aRect.size.height-2)];
		[_slideView setAutoresizesSubviews:YES];
		[_slideView setAutoresizingMask:CPViewMinYMargin+CPViewWidthSizable];
		[self addSubview:_slideView];      
		[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(slideSelected:) name:CPNotificationSlideSelected object:nil];
	}
	return self;
}

-(void)setDelegate:(id)aDelegate
{
	_delegate = aDelegate;
	[_slideView setDelegate:self];
}

- (void)reset
{
	if (_slideView)
	{
		[_slideView reset];
	}
}

- (void)redraw
{
	[_slideView redraw];
}

- (void)layoutSubviews
{
}

- (void)slideSelected:(CPNotification)aNotification
{
	if (_delegate && [_delegate respondsToSelector:@selector(showImage:)])
	{
		var index = [[Session sharedSession] imageIndex];
		if (index >= 0)
		{
			[_delegate showImage:[[Session sharedSession] imageForSlideAtIndex:index]];
		}
		else
		{
			[_delegate showImage:nil];
		}
	}	
}


@end

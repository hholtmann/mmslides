/*
 * ToolbarProjectTitleView.j
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

@implementation ToolbarProjectTitleView : CPView
{
	CPString _projectTitle;
	CPImageView _itemImageView;
}

- (id)initWithFrame:(CGRect)aRect
{
	if (self = [super initWithFrame:aRect])
	{
		_projectTitle = [CPTextField labelWithTitle:CPLocalizedString(@"Untitled")];
		[_projectTitle setFrameOrigin:CGPointMake(25,0)];
		[_projectTitle setFont:[CPFont boldSystemFontOfSize:12.0]];
		[self addSubview:_projectTitle];
		
		_itemImageView = [[CPImageView alloc] initWithFrame:CGRectMake(0,0,16,16)];
		var bundle = [CPBundle mainBundle];
		img = [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"project.png"]];
		[_itemImageView setImage:img];
		[self addSubview:_itemImageView];
	}
	return self;
}

- (void)setStringValue:(CPString)aValue
{
	[_projectTitle setStringValue:aValue];
	[_projectTitle sizeToFit];
	[self setFrame:CGRectMake(0,0,25+[_projectTitle frame].size.width,16)];
}

@end
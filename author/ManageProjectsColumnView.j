/*
 * ManageProjectsColumnView.j
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

@implementation ManageProjectsColumnView : CPView
{
	BOOL _shared;
	CPImageView _imageView;
}

- (id)initWithFrame:(CGRect)aRect
{
	CPLog(@"Rect: %@",CPStringFromRect(aRect));
	if (self = [super initWithFrame:aRect])
	{	
		_imageView = [[CPImageView alloc] initWithFrame:CGRectMake(aRect.size.width/2-8,aRect.size.height/2-8,16,16)];
		_shared = NO;
		[_imageView setTag:100];
		[self addSubview:_imageView];
	}
	return self;
}

-(void)layoutSubviews
{
	//Bug calling subviews directly does not work
	if (_shared) {
		[[self viewWithTag:100] setImage:[[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"checked.png"]]];
	} else {
		[[self viewWithTag:100] setImage:nil];
	}
}

-(BOOL)shared
{
	return _shared;
}

-(void)setShared:(BOOL)shared
{
	_shared = shared;
	[self layoutSubviews];
}

- (void)setObjectValue:(CPNumber)aValue
{
	[self setShared:[aValue boolValue]];
	[self setNeedsDisplay:YES];
}

@end
/*
 * SlideTimelineView.j
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
@import <Foundation/CPArray.j>
@import "Session.j"
@import "SlideshowSequenceView.j"
@import "ConnectionController.j"

@implementation SlideTimelineView : CPView
{
	CPMutableArray _slides;
	id _delegate @accessors(property=delegate);
	double _lengthUnit @accessors(property=lengthUnit);	
	double _length @accessors(readonly,property=length);
	SlideshowSequenceView _dragView;
}

- (id)initWithFrame:(CGRect)aRect
{
	if (self = [super initWithFrame:aRect])
	{
		_slides = [CPMutableArray array];
		_length = 0.0;
		[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(slideSelected:) name:CPNotificationSlideSelected object:nil];
	}
	return self;
}

- (id)initWithFrame:(CGRect)aRect andLength:(double)length
{
	if (self = [super initWithFrame:aRect])
	{
		_slides = [CPMutableArray array];
		[self setLength:length];
		[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(slideSelected:) name:CPNotificationSlideSelected object:nil];
	}
	return self;
}

- (void)setContextMenusEnabled:(BOOL)aEnabled
{
	if (_slides)
	{
		for (var i = 0; i < [_slides count]; i++)
		{
			[[[_slides objectAtIndex:i] contextMenu] setEnabled:aEnabled];
		}
	}
}

- (void)setNeedsDisplay:(BOOL)aFlag
{
	for (var slidecount = 0; slidecount < [_slides count]; slidecount++)
	{
		[[_slides objectAtIndex:slidecount] setSelectionStatus];
	}
	[super setNeedsDisplay:aFlag];
}

- (void)setLength:(double)aLength
{
	_length = aLength;
	_lengthUnit = [self frame].size.width / (aLength * 1000.0);
	[self updateImages];
}

- (void)slideSelected:(CPNotification)aNotification
{
	[self setNeedsDisplay:YES];
}

- (void)showDragView:(int)aIndex
{
	[_dragView setFrame:[[_slides objectAtIndex:aIndex] frame]];
	[_dragView setSlideIndex:aIndex];
	[_dragView setSelectionStatus];
	[_dragView setHidden:NO];
}

- (void)updateDragView:(CPRect)newFrame
{
	[_dragView setFrame:newFrame];
}

- (void)hideDragView
{
	[_dragView setHidden:YES];
	[self setNewLengthForSlide:[_dragView slideIndex] fromSlideRect:[_dragView frame]];
}

- (void)setNewLengthForSlide:(int)aIndex fromSlideRect:(CPRect)aRect
{
	var slide = [_slides objectAtIndex:aIndex];
	if (slide)
	{
		var milliseconds = aRect.size.width / _lengthUnit;
		[[Session sharedSession] setLength:milliseconds forSlideAtIndex:aIndex];
		[[ConnectionController sharedConnectionController] updateSlideLengths];
	}
}

- (void)updateImages
{
	var slides = [[Session sharedSession] slides];
	if (slides && [slides count])
	{
		if ([slides count] != [_slides count])
		{
			[self _removeAllViews];
			var totalTime = 0.0;
			for (var slidecount = 0; slidecount < [slides count]; slidecount++)
			{
				var slide = [slides objectAtIndex:slidecount];
				var startX = Math.floor(totalTime * _lengthUnit);
				var endX = Math.floor((totalTime + [[slide objectForKey:@"length"] doubleValue]) * _lengthUnit);
				var imgview = [[SlideshowSequenceView alloc] initWithFrame:CPRectMake(startX, 0, endX - startX, 70) andIndex:slidecount];
				[imgview setDelegate:self];
				[self addSubview:imgview];
				[_slides addObject:imgview];
				totalTime += [[slide objectForKey:@"length"] doubleValue];
			}
			_dragView = [[SlideshowSequenceView alloc] initWithFrame:CPRectMakeZero() andIndex:0];
			[_dragView setTag:SSVDragView];
			[_dragView setHidden:YES];
			[_dragView setDelegate:self];
			[self addSubview:_dragView];
		}
		else
		{
			var totalTime = 0.0;
			for (var slidecount = 0; slidecount < [slides count]; slidecount++)
			{
				var slide = [slides objectAtIndex:slidecount];
				var startX = Math.floor(totalTime * _lengthUnit);
				var endX = Math.floor((totalTime + [[slide objectForKey:@"length"] doubleValue]) * _lengthUnit);
				var imgview = [_slides objectAtIndex:slidecount];
				[imgview setFrame:CPRectMake(startX, 0, endX - startX, 70)];
				[imgview setSlideIndex:slidecount];
				totalTime += [[slide objectForKey:@"length"] doubleValue];
			}
		}
	}
	else
	{
		[self _removeAllViews];
	}
}

- (void)_removeAllViews
{
	if (_slides && [_slides count])
	{
		for (var i = 0; i < [_slides count]; i++)
		{
			[[_slides objectAtIndex:i] removeFromSuperview];
		}
		[_slides removeAllObjects];
	}
	if (_dragView)
	{
		[_dragView removeFromSuperview];
		_dragView = nil;
	}
}

@end

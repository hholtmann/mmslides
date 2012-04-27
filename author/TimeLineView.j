/*
 * TimeLineView.j
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
@import <AppKit/CPButton.j>
@import <AppKit/CPViewAnimation.j>
@import "ConnectionController.j"
@import "RulerView.j"
@import "SlideTimelineView.j"
@import "Session.j"
@import "ZoomDialogController.j"

@implementation TimeLineView : CPBox
{
	CPScrollView _scrollview @accessors(readonly,property=scrollview);
	CPView _timeline @accessors(property=timeline);
	SlideTimelineView _slides @accessors(property=slides);
	RulerView _ruler @accessors(property=ruler);
	CPImageView _waveformview @accessors(property=waveformview);
	CPButton _magnify;
	id _delegate @accessors(property=delegate);
	double _magnification @accessors(property=magnification);
	int _playIndex;
	ZoomDialogController _zoomController;
	int _timelinePadding @accessors(readonly,property=timelinePadding);
}

- (id)initWithFrame:(CGRect)aRect
{
	if (self = [super initWithFrame:CGRectMake(aRect.origin.x, aRect.origin.y, aRect.size.width+20, aRect.size.height)])
	{
		_timelinePadding = 30.0;
		[self setBorderType:CPLineBorder];
		[self setFillColor:[CPColor colorWithHexString:@"e4e4e4"]];
		[self setBorderColor:[CPColor colorWithHexString:@"9e9e9e"]];
		[self setAutoresizesSubviews:YES];
		[self setAutoresizingMask:CPViewWidthSizable];

		_magnification = 1.0;
		[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(slidesChanged:) name:CPNotificationSlidesChanged object:nil];

		_scrollview = [[CPScrollView alloc] initWithFrame:CGRectMake(0,0, aRect.size.width+20, aRect.size.height)];
		[_scrollview setHasVerticalScroller:false];
		[_scrollview setAutoresizesSubviews:YES];
		[_scrollview setAutoresizingMask:CPViewWidthSizable];
		if (_magnification <= 1.0) [_scrollview setHasHorizontalScroller:false];

		_timeline = [[CPBox alloc] initWithFrame:CGRectMake(0,0,aRect.size.width*_magnification+20,146)];
		[_timeline setAutoresizesSubviews:YES];
		[_timeline setAutoresizingMask:CPViewWidthSizable];

		_slides = [[SlideTimelineView alloc] initWithFrame:CGRectMake(10,30,aRect.size.width*_magnification, 70)];
		[_slides setAutoresizesSubviews:YES];
		[_slides setAutoresizingMask:CPViewWidthSizable];
		[_slides setLength:[[Session sharedSession] slideShowLength]/1000.0];
		[_slides setDelegate:self];
		[_timeline addSubview:_slides];
		_playIndex = -1;

		_ruler = [[RulerView alloc] initWithFrame:CGRectMake(10,0,aRect.size.width*_magnification, 30)];
		[_ruler setAutoresizesSubviews:YES];
		[_ruler setAutoresizingMask:CPViewWidthSizable];
		[_ruler setDelegate:self];
		[_ruler setLength:[[Session sharedSession] slideShowLength]/1000.0];
		[_timeline addSubview:_ruler];
		
		_waveformview = [[CPImageView alloc] initWithFrame:CGRectMake(10, 100, aRect.size.width*_magnification, 45)];
		[_waveformview setAutoresizesSubviews:YES];
		[_waveformview setAutoresizingMask:CPViewWidthSizable];
		[_timeline addSubview:_waveformview];

		[self addSubview:_timeline];

		[_scrollview setDocumentView:_timeline];

		[self addSubview:_scrollview];

		_magnify = [[CPButton alloc] initWithFrame:CGRectMake(aRect.size.width-4,2,22,22)];
		[_magnify setImage:[[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"magnify.png"]]];
		[_magnify setBordered:YES];
		[_magnify setAlphaValue:0.75];
		[_magnify setAutoresizingMask:CPViewMinXMargin];
		[_magnify setAlternateImage:[[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"magnify.png"]]];
		[_magnify setAction:@selector(showZoomDialog:)];
		[_magnify setTarget:self];
		[_magnify setEnabled:YES];
		[self addSubview:_magnify];

		[self updateTimeline:_magnification];
		[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(projectDidLoad:) name:CPNotificationProjectDidLoad object:nil];
		[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(timelineHasChanged:) name:CCNotificationSlideLengthUpdated object:nil];
	}
	return self;
}

- (void)adjustScrollPositionFromSlider
{
	if (_delegate && [_delegate respondsToSelector:@selector(adjustScrollPositionFromSlider)])
	{
		[_delegate adjustScrollPositionFromSlider];
	}
}

- (void)showZoomDialog:(id)sender
{
	if (!_zoomController)
	{
		var origin = [self convertPoint:[sender frame].origin fromView:nil]
		var theWindow = [[CPPanel alloc]
			initWithContentRect:CGRectMake(origin.x-158, Math.abs(origin.y)-40, 200, 35) 
			styleMask:CPClosableWindowMask];//CPHUDBackgroundWindowMask

		_zoomController = [[ZoomDialogController alloc] initWithWindow:theWindow];
		[_zoomController setDelegate:self];
	}
	[[_zoomController window] orderFront:self];
}

- (void)hideZoomDialog:(id)sender
{
	[[_zoomController window] close]; 
}

- (void)projectDidLoad:(CPNotification)aNotification
{
	[_slides updateImages];
}

- (void)timelineHasChanged:(CPNotification)aNotification
{
	[self updateTimeline:_magnification];
}

- (void)updatePosition
{
	[_ruler updateMarkerPosition];
}

- (void)markerWasMovedToPosition:(double)aPosition
{
	if (_delegate && [_delegate respondsToSelector:@selector(markerWasMovedToPosition:)])
	{
		[_delegate markerWasMovedToPosition:aPosition];
	}
}

- (BOOL)isValidMarkerPosition:(CPPoint)aPosition
{
	if (aPosition.x <= [_timeline frame].size.width - _timelinePadding && aPosition.x >= _timelinePadding)
	{
		return YES;
	}
	else
	{
		return NO;
	}
}

- (void)showImageAtMarkerPosition:(double)aPosition
{
	if (_delegate && [_delegate respondsToSelector:@selector(showImageAtIndex:)])
	{
		var index = [[Session sharedSession] indexForSlideAtTimeCode:aPosition];
		if (index != _playIndex)
		{
			_playIndex = index;
			[_delegate showImageAtIndex:index];
		}
	}
}

- (void)slidesChanged:(CPNotification)aNotification
{
	[self updateTimeline:_magnification];
}

- (void)updateTimeline:(double)magnification
{
	[self setMagnification:magnification];
	if (_magnification <= 1.0)
	{
		[_scrollview setHasHorizontalScroller:false];
	}
	else
	{
		[_scrollview setHasHorizontalScroller:true];
	}
	[_timeline setFrame:CGRectMake(0,0,([self frame].size.width-20)*_magnification+20,146)];
	[_ruler setFrame:CGRectMake(_timelinePadding,0,([self frame].size.width-(2*_timelinePadding))*_magnification, 30)];
	[_slides setFrame:CGRectMake(_timelinePadding,30,([self frame].size.width-(2*_timelinePadding))*_magnification, 70)];
	[_ruler setLength:[[Session sharedSession] slideShowLength]/1000.0];
	[_slides setLength:[[Session sharedSession] slideShowLength]/1000.0];
	if ([[Session sharedSession] waveform])
	{
		[_waveformview setImage:[[CPImage alloc] initWithContentsOfFile:[[Session sharedSession] waveform]]];
		var total = [[Session sharedSession] slideShowLength];
		var audio = [[Session sharedSession] audioLength]*1000.0;
		var factor = audio/total;
		var width = ([self frame].size.width-(2*_timelinePadding))*factor*_magnification;
		if (width > ([self frame].size.width-(2*_timelinePadding))*_magnification) width = ([self frame].size.width-(2*_timelinePadding))*_magnification;
		[_waveformview setFrame:CGRectMake(_timelinePadding, 100, width, 45)];
	}
	else
	{
		[_waveformview setImage:nil];
	}
	[self setNeedsDisplay:YES];
}

- (void)setLength
{
	[_ruler setLength:[[Session sharedSession] slideShowLength]/1000.0];
	[self updateTimeline:_magnification];
	[_ruler setNeedsDisplay:YES];
}

- (void)reset
{
	[_ruler setLength:0];
	[_ruler updateMarkerPosition];
	[_ruler setNeedsDisplay:YES];
}

- (void)markerDragged
{
	[_ruler updateMarkerPosition];
	[self showImageAtMarkerPosition:[_ruler markerPosition]];
}

- (void)layoutSubviews
{
	[self updateTimeline:_magnification];
}

@end

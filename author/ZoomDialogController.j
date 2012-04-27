/*
 * ZoomDialogController.j
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

@import <AppKit/CPWindowController.j>
@import "ConnectionController.j";

@implementation ZoomDialogController : CPWindowController
{
	CPSlider _magnification;
	CPButton _magnificationSmaller;
	CPButton _magnificationLarger;
	id _delegate @accessors(property=delegate);
}

- (id)initWithWindow:(CPWindow)theWindow
{
	self = [super initWithWindow:theWindow];
    
	if (self)
	{
		[theWindow setTitle:CPLocalizedString(@"Timeline magnification")];
		[theWindow setDelegate:self];
		[theWindow setFloatingPanel:YES];
        
		var contentView = [theWindow contentView]

		_magnificationSmaller = [[CPButton alloc] initWithFrame:CPRectMake(10,10,16,13)];
		[_magnificationSmaller setImage:[[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"smaller.png"]]];
		[_magnificationSmaller setBordered:NO];
		[_magnificationSmaller setAlternateImage:[[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"smaller_P.png"]]];
		[_magnificationSmaller setAction:@selector(zoomSmaller:)];
		[_magnificationSmaller setTarget:self];
		[_magnificationSmaller setEnabled:YES];
		[_magnificationSmaller setAutoresizesSubviews:YES];
		[_magnificationSmaller setAutoresizingMask:CPViewMinXMargin];
		[contentView addSubview:_magnificationSmaller];

		_magnification = [[CPSlider alloc] initWithFrame:CPRectMake(35,10,123,13)];
		[_magnification setAutoresizesSubviews:YES];
		[_magnification setAutoresizingMask:CPViewMinXMargin];
		[_magnification setMinValue:1];
		[_magnification setMaxValue:8];
		[_magnification setSliderType:CPLinearSlider];
		[_magnification setObjectValue:[CPNumber numberWithDouble:1.0]];
		[_magnification setContinuous:NO];
		[_magnification setEnabled:YES];
		[_magnification setTarget:self];
		[_magnification setAction:@selector(changedMagnification:)];
		var knobColor = [CPColor colorWithPatternImage:[[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"knob_slider_N.png"]]]
		[_magnification setValue:knobColor forThemeAttribute:@"knob-color"];
		[_magnification setValue:CGSizeMake(12,12) forThemeAttribute:@"knob-size"];
		var sliderTrackColor = [CPColor colorWithPatternImage:[[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"slider_track.png"]]]
		[_magnification setValue:sliderTrackColor forThemeAttribute:@"track-color"];
		[_magnification setValue:123 forThemeAttribute:@"track-width"];
		[contentView addSubview:_magnification];

		_magnificationLarger = [[CPButton alloc] initWithFrame:CPRectMake(163,10,16,13)];
		[_magnificationLarger setImage:[[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"larger.png"]]];
		[_magnificationLarger setAutoresizesSubviews:YES];
		[_magnificationLarger setAutoresizingMask:CPViewMinXMargin];
		[_magnificationLarger setBordered:NO];
		[_magnificationLarger setAlternateImage:[[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"larger_P.png"]]];
		[_magnificationLarger setAction:@selector(zoomLarger:)];
		[_magnificationLarger setTarget:self];
		[_magnificationLarger setEnabled:YES];
		[contentView addSubview:_magnificationLarger];
	}
    
	return self;
}

- (void)zoomLarger:(id)sender
{	
	[_magnification setValue:[_magnification maxValue]];
	if (_delegate && [_delegate respondsToSelector:@selector(updateTimeline:)])
	{
		[_delegate updateTimeline:[_magnification maxValue]];
	}
	if (_delegate && [_delegate respondsToSelector:@selector(slidesChanged:)])
	{
		[_delegate slidesChanged:nil];
	}
	if (_delegate && [_delegate respondsToSelector:@selector(adjustScrollPositionFromSlider)])
	{
		[_delegate adjustScrollPositionFromSlider];
	}
}

- (void)zoomSmaller:(id)sender
{	
	[_magnification setValue:[_magnification minValue]];
	if (_delegate && [_delegate respondsToSelector:@selector(updateTimeline:)])
	{
		[_delegate updateTimeline:[_magnification minValue]];
	}
	if (_delegate && [_delegate respondsToSelector:@selector(slidesChanged:)])
	{
		[_delegate slidesChanged:nil];
	}
	if (_delegate && [_delegate respondsToSelector:@selector(adjustScrollPositionFromSlider)])
	{
		[_delegate adjustScrollPositionFromSlider];
	}
}

- (void)changedMagnification:(id)sender
{	
	if (_delegate && [_delegate respondsToSelector:@selector(updateTimeline:)])
	{
		[_delegate updateTimeline:[sender doubleValue]];
	}
	if (_delegate && [_delegate respondsToSelector:@selector(slidesChanged:)])
	{
		[_delegate slidesChanged:nil];
	}
	if (_delegate && [_delegate respondsToSelector:@selector(adjustScrollPositionFromSlider)])
	{
		[_delegate adjustScrollPositionFromSlider];
	}
}

-(BOOL)windowShouldClose:(id)window
{
	[[CPApplication sharedApplication] abortModal];
	[[self window] close]; 
	return true;
}

@end
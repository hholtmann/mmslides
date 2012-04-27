/*
 * PreviewContainer.j
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
@import "LPViewAnimation.j"
@import "ConnectionController.j"
@import "Session.j"
@import "PreviewView.j"
@import "TitleView.j"

@implementation PreviewContainer : CPBox
{	
	id _delegate @accessors(property=delegate);
	PreviewView _preview @accessors(property=preview);
	TitleView _titleView @accessors(property=titleView);
	CPTextField _timeLabel @accessors(property=timeLabel);
	CPButton _playButton;
	CPButton _rewindButton;
	CPImage _pauseImage;
	CPImage _pauseImageAlt;
	CPImage _playImage;
	CPImage _playImageAlt;
}

- (id)initWithFrame:(CGRect)aRect
{
	if (self = [super initWithFrame:aRect])
	{
		[self setBorderType:CPLineBorder];
		[self setFillColor:[CPColor colorWithHexString:@"e4e4e4"]];
		[self setBorderColor:[CPColor colorWithHexString:@"9e9e9e"]];

		_titleView = [[TitleView alloc] initWithFrame:CGRectMake(28, 10, aRect.size.width - 64, 32)];
		[self addSubview:_titleView];
		
		_preview = [[PreviewView alloc] initWithFrame:CGRectMake(32, 50, 460, 345)];
		[_preview setBackgroundColor:[CPColor blackColor]];
		[_preview setDelegate:self];
		[self addSubview:_preview]; 

		_timeLabel = [CPTextField labelWithTitle:@"00:00.0"];
		[_timeLabel setFont:[CPFont boldSystemFontOfSize:18.0]];
		[_timeLabel setFrame:CGRectMake(aRect.size.width-200-32,aRect.size.height-32,200,24)];
		[_timeLabel setValue:CPRightTextAlignment forThemeAttribute:@"alignment"];
		[_timeLabel setTextColor:[CPColor colorWithHexString:@"333333"]];
		[self addSubview:_timeLabel];

		_rewindButton = [[CPButton alloc] initWithFrame:CGRectMake(32,aRect.size.height-32,40,22)];
		[_rewindButton setImage:[[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"rewind_N.png"]]];
		[_rewindButton setBordered:NO];
		[_rewindButton setAlternateImage:[[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"rewind_P.png"]]];
		[_rewindButton setAction:@selector(rewind:)];
		[_rewindButton setTarget:self];
		[_rewindButton setEnabled:YES];
		[self addSubview:_rewindButton];

		_pauseImage = [[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"pause_N.png"]];
		_pauseImageAlt = [[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"pause_P.png"]];
		_playImage = [[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"play_N.png"]];
		_playImageAlt = [[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"play_P.png"]];

		_playButton = [[CPButton alloc] initWithFrame:CGRectMake(72,aRect.size.height-32,40,22)];
		[self setPauseButton];
		[self setPlayButton];
		[_playButton setBordered:NO];
		[_playButton setTarget:self];
		[_playButton setAction:@selector(playPause:)];
		[_playButton setEnabled:YES];
		[self addSubview:_playButton];
	}
	return self;
}

-(void)setPauseButton
{
	[_playButton setImage:_pauseImage];
	[_playButton setAlternateImage:_pauseImageAlt];
}

-(void)setPlayButton
{
	[_playButton setImage:_playImage];
	[_playButton setAlternateImage:_playImageAlt];
}

-(void)rewind:(id)sender
{
	if (_delegate && [_delegate respondsToSelector:@selector(rewind:)])
	{
		[_delegate rewind:sender];
	}
}

-(void)playPause:(id)sender
{
	if (_delegate && [_delegate respondsToSelector:@selector(playPause:)])
	{
		[_delegate playPause:sender];
	}
}

- (void) setImage:(CPImage)aImage
{	
	[_imageView setImage:aImage];
}

-(void)animationDidEnd:(CPAnimation)animation
{
	[_imageView setImage:[_secondView image]];
	if (_isFading)
	{
		[self transitionFadeIn:[_secondView image] withLength:[animation duration]];
	}
	else
	{
		[_imageView setFrameOrigin:CGPointMake(0,0)];
		[_imageView setAlphaValue:1.0];
		[_secondView setAlphaValue:0.0];
		[_secondView setFrameOrigin:CGPointMake(0,0)];
		if (LPCSSAnimationsAreAvailable)
		{
			[animation _clearCSS];
			_imageView._DOMElement.style["-webkit-transform"] = "translate(0px, 0px)";
			_secondView._DOMElement.style["-webkit-transform"] = "translate(0px, 0px)";
		}
		_transitionIsRunning = NO;
		if (_captionIndexOfRunningTransition >= 0)
		{
			[self showCaption:_captionIndexOfRunningTransition];
			_captionIndexOfRunningTransition = -1;
		}
	}
}

- (void)transitionFadeOut:(CPImage)newImage withLength:(double)aLength
{
	_isFading = YES;
	[_imageView setAlphaValue:1.0];
	[_secondView setAlphaValue:0.0];
	[_secondView setImage:newImage];
	animation = [[LPViewAnimation alloc] initWithViewAnimations:[
	{
		@"target": _imageView,
		@"animations": [
			[LPFadeAnimationKey, 1.0, 0.0] // Can also have multiple animations on a single view
		]
	}
	]];
	[animation setDelegate:self];
	[animation setAnimationCurve:CPAnimationEaseInOut];
	[animation setDuration:aLength];
	if (LPCSSAnimationsAreAvailable)
	{
		[animation setShouldUseCSSAnimations:YES];
	}
	else
	{
		[animation setShouldUseCSSAnimations:NO];
	}
	[animation startAnimation];
}

- (void)transitionFadeIn:(CPImage)newImage withLength:(double)aLength
{
	_isFading = NO;
	[_imageView setAlphaValue:0.0];
	[_secondView setAlphaValue:0.0];
	[_secondView setImage:newImage];
	animation = [[LPViewAnimation alloc] initWithViewAnimations:[
	{
		@"target": _imageView,
		@"animations": [
			[LPFadeAnimationKey, 0.0, 1.0] // Can also have multiple animations on a single view
		]
	}
	]];
	[animation setDelegate:self];
	[animation setAnimationCurve:CPAnimationEaseInOut];
	[animation setDuration:aLength];
	if (LPCSSAnimationsAreAvailable)
	{
		[animation setShouldUseCSSAnimations:YES];
	}
	else
	{
		[animation setShouldUseCSSAnimations:NO];
	}
	[animation startAnimation];
}

- (void)transitionCrossfade:(CPImage)newImage withLength:(double)aLength
{
	[_imageView setAlphaValue:1.0];
	[_secondView setAlphaValue:0.0];
	[_secondView setImage:newImage];
	animation = [[LPViewAnimation alloc] initWithViewAnimations:[
	        {
	            @"target": _imageView,
	            @"animations": [
	                [LPFadeAnimationKey, 1.0, 0.0] // Can also have multiple animations on a single view
	            ]
	        },
	        {
	            @"target": _secondView,
	            @"animations": [
	                [LPFadeAnimationKey, 0.0, 1.0] // Can also have multiple animations on a single view
	            ]
	        }
	    ]];
	[animation setDelegate:self];
	[animation setAnimationCurve:CPAnimationEaseInOut];
	[animation setDuration:aLength];
	if (LPCSSAnimationsAreAvailable)
	{
		[animation setShouldUseCSSAnimations:YES];
	}
	else
	{
		[animation setShouldUseCSSAnimations:NO];
	}
	[animation startAnimation];
}

- (void)transitionStraightCut:(CPImage)newImage withLength:(double)aLength
{
	[_imageView setAlphaValue:1.0];
	[_secondView setAlphaValue:1.0];
	[_secondView setImage:newImage];
	animation = [[LPViewAnimation alloc] initWithViewAnimations:[
	        {
		        @"target": _imageView,
		        @"animations": [
		            [LPOriginAnimationKey, CGPointMake(0,0), CGPointMake(-510,0)]
		        ]
	        },
	        {
		        @"target": _secondView,
		        @"animations": [
		            [LPOriginAnimationKey, CGPointMake(510,0), CGPointMake(0,0)]
		        ]
	        }
	    ]];

	[animation setDelegate:self];
	[animation setAnimationCurve:CPAnimationEaseInOut];
	[animation setDuration:aLength];
	if (LPCSSAnimationsAreAvailable)
	{
		[animation setShouldUseCSSAnimations:NO]; // disable because css animations do not work with autosizing
	}
	else
	{
		[animation setShouldUseCSSAnimations:NO];
	}
	[animation startAnimation];
}

- (void)setImageFromIndex:(int)aFrom toIndex:aTo
{
	var transition = [[Session sharedSession] transitionForSlideAtIndex:aFrom];
	if (!transition)
	{
		[self setImage:[[Session sharedSession] imageForSlideAtIndex:aTo]];
	}
	else
	{
		_transitionIsRunning = YES;
		if ([[transition objectForKey:@"type"] isEqualToString:@"straightcut"])
		{
			[self transitionStraightCut:[[Session sharedSession] imageForSlideAtIndex:aTo] withLength:[[transition objectForKey:@"length"] doubleValue]/1000];
		}
		else if ([[transition objectForKey:@"type"] isEqualToString:@"crossfade"])
		{
			[self transitionCrossfade:[[Session sharedSession] imageForSlideAtIndex:aTo] withLength:[[transition objectForKey:@"length"] doubleValue]/1000];
		}
		else if ([[transition objectForKey:@"type"] isEqualToString:@"fade"])
		{
			[self transitionFadeOut:[[Session sharedSession] imageForSlideAtIndex:aTo] withLength:[[transition objectForKey:@"length"] doubleValue]/2000];
		}
	}
}

- (void)showCaption:(int)aIndex
{
	if (aIndex >= 0)
	{
		if ([_delegate isPlaying] && !_transitionIsRunning)
		{
			var slide = [[[Session sharedSession] slides] objectAtIndex:aIndex];
			if ([slide objectForKey:@"caption"] && [[slide objectForKey:@"caption"] length] > 0)
			{
				[_captionView setCaption:[slide objectForKey:@"caption"]];
				var s = [_captionView captionSize];
				[_captionView setFrame:CGRectMake(0, [self frame].size.height - (s.height+20) - 10, [self frame].size.width, s.height+20)];
				[_captionView setAlphaValue:1.0];
				return;
			}
		}
		if (_transitionIsRunning)
		{
			_captionIndexOfRunningTransition = aIndex;
		}
	}
	[_captionView setAlphaValue:0.0];
}

- (void)projectDidLoad:(CPNotification)aNotification
{
	if (![_imageView image])
	{
		var image = [[Session sharedSession] imageForSlideAtIndex:0];
		if (image)
		{
			[self setImage:image];
		}
	}
}

@end

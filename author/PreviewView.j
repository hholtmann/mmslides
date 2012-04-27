/*
 * PreviewView.j
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
@import "LPViewAnimation.j"
@import "ConnectionController.j"
@import "Session.j"
@import "CaptionView.j"
@import "KenBurnsEditor.j"
@import "KenBurnsView.j"

@implementation PreviewView : CPView
{	
	CPImage _image;
	KenBurnsView _imageView;
	KenBurnsView _secondView;
	KenBurnsEditor _kenBurns;
	CaptionView _captionView;
	id _delegate @accessors(property=delegate);
	BOOL _transitionIsRunning;
	int _captionIndexOfRunningTransition;
	BOOL _isFading;
	double _position @accessors(property=position);
}

- (id)initWithFrame:(CGRect)aRect
{
	if (self = [super initWithFrame:aRect])
	{
		_isFading = NO;
		_transitionIsRunning = NO;
		_captionIndexOfRunningTransition = -1;
		_secondView = [[KenBurnsView alloc] initWithFrame:CGRectMake(0, 0, aRect.size.width, aRect.size.height)];
		[_secondView setAlphaValue:0.0];
		[self addSubview:_secondView]; 
		_imageView = [[KenBurnsView alloc] initWithFrame:CGRectMake(0, 0, aRect.size.width, aRect.size.height)];
		[self addSubview:_imageView]; 
		[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(projectDidLoad:) name:CPNotificationProjectDidLoad object:nil];
		[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(slidesChanged:) name:CPNotificationSlidesChanged object:nil];
		[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(slideSelected:) name:CPNotificationSlideSelected object:nil];
		[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(removeImage:) name:CPNotificationNoSlideSelected object:nil];
		[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(redrawImage:) name:CPNotificationForceSlideSelection object:nil];
		_captionView = [[CaptionView alloc] initWithFrame:CGRectMake(0,0,aRect.size.width,0)];
		[self addSubview:_captionView];
		_kenBurns = [[KenBurnsEditor alloc] initWithFrame:CGRectMake(0, 0, aRect.size.width, aRect.size.height)];
		[self addSubview:_kenBurns];
	}
	return self;
}

- (void)setImageAtIndex:(int)aIndex
{
	var image = [[Session sharedSession] imageForSlideAtIndex:aIndex];
	[self setImage:image];
	[self showCaption:aIndex];
}

- (void) setImage:(CPImage)aImage
{
	[_imageView setImage:aImage];
	[_kenBurns quitKenBurns];
	[[Session sharedSession] setKenBurns:NO];
	if (aImage != nil)
	{
		if ([[Session sharedSession] isKenBurns]) [_kenBurns loadKenBurns:aImage];
	}
}

- (void)setPercentage:(double)aPercentage
{
	[_imageView setPercentage:aPercentage];
	if ([_secondView alphaValue] > 0.0)
	{
		[_secondView setPercentage:aPercentage];
	}
}

-(void)animationDidEnd:(CPAnimation)animation
{
	[self setImage:[_secondView image]];
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
		[_imageView freezePercentage:NO];
		[_imageView setPercentage:[_secondView percentage]];
		[_secondView setPercentage:0.0];
	}
}

- (void)transitionFadeOut:(CPImage)newImage withLength:(double)aLength
{
	_isFading = YES;
	[_imageView setAlphaValue:1.0];
	[_imageView freezePercentage:YES];
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
	[_imageView freezePercentage:YES];
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
		[animation setShouldUseCSSAnimations:NO];
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
	[_imageView freezePercentage:YES];
	[_secondView setAlphaValue:1.0];
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
		[animation setShouldUseCSSAnimations:NO];
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
	[_imageView freezePercentage:YES];
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
	if (!transition || ([[transition objectForKey:@"type"] isEqualToString:@"notransition"]))
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
		if (!_transitionIsRunning)
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
		[self setImageAtIndex:0];
	}
}

- (void)slideSelected:(CPNotification)aNotification
{
	if ([[Session sharedSession] numberOfSlides] > 0)
	{
		[self showCaption:[[Session sharedSession] imageIndex]];
	}	
}


- (void)slidesChanged:(CPNotification)aNotification
{
	if ([[Session sharedSession] numberOfSlides] == 0)
	{
		[self setImage:nil];
	}
}

- (void)removeImage:(CPNotification)aNotification
{
	[self setImage:nil];
}

- (void)redrawImage:(CPNotification)aNotification
{
	if ([[Session sharedSession] numberOfSlides] == 0)
	{
		[self setImage:nil];
	}
	else
	{
		[self setImage:[[Session sharedSession] imageForSlideAtIndex:[[Session sharedSession] imageIndex]]];
	}
}

- (void)redraw
{
	if ([[Session sharedSession] isKenBurns])
	{
		[_kenBurns setAlphaValue:1.0];
		[_kenBurns loadKenBurns:[_imageView image]];
	}
	else
	{
		[_kenBurns setAlphaValue:0.0];
	}
}

@end

/*
 * SlidePropertiesView.j
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
@import <AppKit/CPImageView.j>
@import "CPFocusTextField.j"
@import "ConnectionController.j"
@import "CPMutableDictionary+SlideshowData.j"

@implementation SlidePropertiesView : CPView
{
	CPImageView _preview;
	CPTextField _caption;
	CPFocusTextField _captionLabel;
	CPTextField _length;
	CPTextField _lengthPostfix;
	CPFocusTextField _lengthLabel;
	CPButton _prevButton;
	CPButton _nextButton;
	CPFocusTextField _transitionsLabel;
	CPPopUpButton _transitions;
	CPPopUpButton _pictureMotion;
	CPTextField _pictureMotionLabel;
	CPSlider _scaleSlider;
	CPTextField _scaleValue;
	CPTextField _scaleStartLabel;
	CPTextField _scaleEndLabel;
	CPButton _kenBurns;
	id _delegate @accessors(property=delegate);
}

- (id)initWithFrame:(CGRect)aRect
{
	if (self = [super initWithFrame:aRect])
	{
		[self setFrame:CGRectMake(aRect.origin.x, aRect.origin.y, 400, 400)];
		[self setAutoresizesSubviews:YES];
		[self setAutoresizingMask:CPViewMinXMargin];

		_preview = [[CPImageView alloc] initWithFrame:CGRectMake(10, 5, 100, 100)];
		[_preview setHasShadow:YES];
		[_preview setImageScaling:CPScaleProportionally];
		[self addSubview:_preview]; 

		_caption = [CPTextField textFieldWithStringValue:@"" placeholder:@"" width:372]
		[_caption setFrameOrigin:CGPointMake(10,130)];
		[_caption setEditable:YES]; 
		[_caption setBordered:YES]; 
		[_caption setBezeled: YES];
		[_caption setSendsActionOnEndEditing:YES];
		[_caption setBezelStyle:CPTextFieldSquareBezel] 
		[_caption setAutoresizingMask:CPViewWidthSizable];
		[_caption setLineBreakMode:CPLineBreakByWordWrapping];
		[_lengthLabel setValue:CPLeftTextAlignment forThemeAttribute:@"alignment"];
		[_caption setTarget:self]; 
		[_caption setAction:@selector(slidePropertiesTextFieldDidEndEditing:)];
		[_caption setDelegate:self]; 
		[self addSubview:_caption];

		_captionLabel = [[CPFocusTextField alloc] initWithFrame:CGRectMake(10,110,80,25)];
		[_captionLabel setTextColor:[CPColor blackColor]];
		[_captionLabel setFocusField:_caption];
		[_captionLabel setStringValue:CPLocalizedString(@"Caption")];
		[self addSubview:_captionLabel];

		_length = [CPTextField textFieldWithStringValue:@"" placeholder:@"" width:120]
		[_length setFrameOrigin:CGPointMake(10,190)];
		[_length setEditable:YES]; 
		[_length setBordered:YES]; 
		[_length setBezeled: YES]; 
		[_length setValue:CPRightTextAlignment forThemeAttribute:@"alignment"];
		[_length setBezelStyle:CPTextFieldSquareBezel];
		[_length setSendsActionOnEndEditing:YES];
		[_length setTarget:self]; 
		[_length setAction:@selector(slidePropertiesTextFieldDidEndEditing:)];
		[_length setDelegate:self]; 
		[self addSubview:_length];

		_lengthLabel = [[CPFocusTextField alloc] initWithFrame:CGRectMake(10,170,80,25)];
		[_lengthLabel setTextColor:[CPColor blackColor]];
		[_lengthLabel setFocusField:_length];
		[_lengthLabel setStringValue:CPLocalizedString(@"Slide length")];
		[self addSubview:_lengthLabel];

		_lenghPostfix = [[CPTextField alloc] initWithFrame:CGRectMake(135,195,80,25)];
		[_lenghPostfix setTextColor:[CPColor blackColor]];
		[_lenghPostfix setStringValue:CPLocalizedString(@"seconds")];
		[self addSubview:_lenghPostfix];

		_pictureMotion = [[CPPopUpButton alloc] initWithFrame:CGRectMake(170, 40, 160, 24) pullsDown:NO];
		var menuitemStatic = [[CPMenuItem alloc] initWithTitle:CPLocalizedString(@"None") action:@selector(staticSelected:) keyEquivalent:nil];
		[menuitemStatic setTag:251];
		[menuitemStatic setTarget:self];
		[_pictureMotion addItem:menuitemStatic];
		var menuitemKenBurns = [[CPMenuItem alloc] initWithTitle:CPLocalizedString(@"Ken Burns") action:@selector(kenBurnsSelected:) keyEquivalent:nil];
		[menuitemKenBurns setTag:252];
		[menuitemKenBurns setTarget:self];
		[_pictureMotion addItem:menuitemKenBurns];
		[_pictureMotion setTarget:self];
		[self addSubview:_pictureMotion];

		_kenBurns = [[CPButton alloc] initWithFrame:CGRectMake(170,80,140,25)];
		[_kenBurns setTitle:CPLocalizedString(@"Edit Ken Burns")];
		[_kenBurns setTarget:self];
		[_kenBurns setAction:@selector(editKenBurns:)];
		[self addSubview:_kenBurns];

		_pictureMotionLabel = [CPFocusTextField labelWithTitle:@"Picture Motion"];
		[_pictureMotionLabel setFocusField:_pictureMotion];
		[_pictureMotionLabel setFrameOrigin:CGPointMake(170,20)];
		[self addSubview:_pictureMotionLabel];

		_transitions = [[CPPopUpButton alloc] initWithFrame:CGRectMake(10, 250, 160, 24) pullsDown:NO];
		for (var i = 0; i < [[[Session sharedSession] transitions] count]; i++)
		{
			var menuitem = [[CPMenuItem alloc] initWithTitle:CPLocalizedString([[[Session sharedSession] transitions] objectAtIndex:i]) action:@selector(transitionSelected:) keyEquivalent:nil];
			[menuitem setTag:i];
			[menuitem setTarget:self];
			[_transitions addItem:menuitem];
		}
		[_transitions setTarget:self];
		[self addSubview:_transitions];

		_transitionsLabel = [CPFocusTextField labelWithTitle:@"Transition"];
		[_transitionsLabel setFocusField:_transitions];
		[_transitionsLabel setFrameOrigin:CGPointMake(10,230)];
		[self addSubview:_transitionsLabel];

		var imageIndex = [[Session sharedSession] imageIndex];CPLog(@"imageindex = %d", imageIndex);
		var nextLength = [[Session sharedSession] lengthForSlideAtIndex:(imageIndex+1)];

		_scaleSlider = [[CPSlider alloc] initWithFrame:CGRectMake(200, 250.0, 150.0, 24.0)];

		[_scaleSlider setMinValue:0];
		[_scaleSlider setMaxValue:nextLength/1000.0];
		[_scaleSlider setTarget:self];
		[_scaleSlider setAction:@selector(sliderValueDidChange:)];
		[self addSubview:_scaleSlider];

		_scaleStartLabel = [CPTextField labelWithTitle:"0"];
		_scaleEndLabel = [CPTextField labelWithTitle:[CPString stringWithFormat:@"%.0f", [_scaleSlider maxValue]] + @" " + CPLocalizedString(@"sec")];
		[_scaleEndLabel setAlignment:CPRightTextAlignment];

		[_scaleStartLabel setFrameOrigin:CGPointMake(200, 230)];
		[_scaleEndLabel setFrame:CGRectMake(350-[_scaleEndLabel frame].size.width, 230, 150, [_scaleEndLabel frame].size.height)];

		[self addSubview:_scaleStartLabel];
		[self addSubview:_scaleEndLabel];

		_scaleValue = [CPTextField textFieldWithStringValue:nil placeholder:nil width:50.0]
		[_scaleValue setAlignment:CPRightTextAlignment];
		[_scaleValue setFrameOrigin:CPPointMake(250, 270)];
		[_scaleValue setSendsActionOnEndEditing:YES];
		[_scaleValue setDelegate:self]; 
		[_scaleValue setTarget:self];
		[_scaleValue setAction:@selector(slidePropertiesTextFieldDidEndEditing:)];
		[self addSubview:_scaleValue];

		_prevButton = [[CPButton alloc] initWithFrame:CGRectMake(aRect.size.width-60,335,24,24)];
		[_prevButton setImage:[[CPImage alloc] initWithContentsOfFile:"Resources/previous.png"]];
		[_prevButton setTarget:self];
		[_prevButton setImagePosition:CPImageOnly];
		[_prevButton setAction:@selector(prevImage:)];
		[_prevButton setEnabled:NO];
		[_prevButton setAutoresizingMask:CPViewMinXMargin];
		[self addSubview:_prevButton];

		_nextButton = [[CPButton alloc] initWithFrame:CGRectMake(aRect.size.width-30,335,24,24)];
		[_nextButton setImage:[[CPImage alloc] initWithContentsOfFile:"Resources/next.png"]];
		[_nextButton setImagePosition:CPImageOnly];
		[_nextButton setTarget:self];
		[_nextButton setAction:@selector(nextImage:)];
		[_nextButton setEnabled:NO];
		[_nextButton setAutoresizingMask:CPViewMinXMargin];
		[self addSubview:_nextButton];

		[[self window] setAutorecalculatesKeyViewLoop:NO];
		[_caption setNextKeyView:_length];
		[_length setNextKeyView:_scaleValue];
		[_scaleValue setNextKeyView:_caption];
		
		[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(slideSelected:) name:CPNotificationSlideSelected object:nil];
	}
	return self;
}

- (void)setEnabled:(BOOL)aEnabled
{
	[_caption setEnabled:aEnabled];
	[_length setEnabled:aEnabled];
	[_transitions setEnabled:aEnabled];
	if (aEnabled == YES)
	{
		[_lengthLabel setTextColor:[CPColor colorWithHexString:@"000000"]];
		[_preview setImage:[[Session sharedSession] imageForSlideAtIndex:index]];
		[_scaleSlider setHidden:NO];
		[_scaleStartLabel setHidden:NO];
		[_scaleEndLabel setHidden:NO];
		[_scaleValue setHidden:NO];
		[_pictureMotionLabel setHidden:NO];
		[_pictureMotion setHidden:NO];
	}
	else
	{
		[_preview setImage:nil];
		[_scaleSlider setHidden:YES];
		[_scaleStartLabel setHidden:YES];
		[_scaleEndLabel setHidden:YES];
		[_scaleValue setHidden:YES];
		[_pictureMotionLabel setHidden:YES];
		[_pictureMotion setHidden:YES];
		[_kenBurns setHidden:YES];
	}
}

- (void)writeTransitionValuesToSession
{
	if ([[_transitions selectedItem] tag] == 999)
	{
		[[Session sharedSession] removeTransitionForSlideAtIndex:[[Session sharedSession] imageIndex]];
	}
	else
	{
		timeInMillis = [[_scaleSlider objectValue] doubleValue]*1000.0;
		[[Session sharedSession] setTransition:[[[Session sharedSession] transitions] objectAtIndex:[[_transitions selectedItem] tag]] withLength:timeInMillis forSlideAtIndex:[[Session sharedSession] imageIndex]];
	}
}

-(void)editKenBurns:(id)sender
{
	[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationActivateKenBurns object:nil]];
	[[self window] close]; 
}

- (void)setData
{
	var index = [[Session sharedSession] imageIndex];
	if (index >= 0)
	{
		var transition = [[Session sharedSession] transitionForSlideAtIndex:index];
		var nextLength = [[Session sharedSession] lengthForSlideAtIndex:index+1];
		var isKenBurns = [[Session sharedSession] isKenBurnsForSlideAtIndex:index];
		var slide = [[[Session sharedSession] slides] objectAtIndex:index];
		[_prevButton setEnabled:(index > 0) ? YES : NO];
		[_nextButton setEnabled:(nextLength < 0) ? NO : YES];
		[_caption setStringValue:[slide objectForKey:@"caption"]];
		[_preview setImage:[[Session sharedSession] imageForSlideAtIndex:index]];
		if ([slide objectForKey:@"length"] != null && [[slide objectForKey:@"length"] class] == [CPNumber class])
		{
			[_length setStringValue:[CPString stringWithFormat:@"%.1f", [[slide objectForKey:@"length"] doubleValue]/1000.0]];
		}
		else
		{
			[_length setStringValue:[CPString stringWithFormat:@"%.1f", 0.0]];
		}
		if (nextLength >= 0)
		{
			[_scaleSlider setHidden:NO];
			[_scaleStartLabel setHidden:NO];
			[_scaleEndLabel setHidden:NO];
			[_scaleValue setHidden:NO];
			[_transitions setEnabled:YES];

			[_scaleSlider setMaxValue:nextLength/1000.0];
			[_scaleEndLabel setStringValue:[CPString stringWithFormat:@"%.0f", [_scaleSlider maxValue]] + @" " + CPLocalizedString(@"sec")];
			[_scaleEndLabel setFrameOrigin:CGPointMake(350-[_scaleEndLabel frame].size.width, 230)];
			if (transition)
			{
				[_transitions selectItemWithTitle:CPLocalizedString([transition objectForKey:@"type"])];
				[_scaleSlider setObjectValue:[CPNumber numberWithDouble:[[transition objectForKey:@"length"] doubleValue]/1000.0]];
				[_scaleValue setStringValue:[CPString stringWithFormat:@"%.1f", [[transition objectForKey:@"length"] doubleValue]/1000.0]];
			}
			else
			{
				[_transitions selectItemWithTag:999];
				[_scaleSlider setObjectValue:[CPNumber numberWithDouble:(nextLength < 4000) ? (nextLength/2000) : 2.0]];
				[_scaleValue setStringValue:[CPString stringWithFormat:@"%.1f", (nextLength < 4000) ? (nextLength/2000) : 2.0]];
			}
		}
		else
		{
			[_scaleSlider setHidden:YES];
			[_scaleStartLabel setHidden:YES];
			[_scaleEndLabel setHidden:YES];
			[_scaleValue setHidden:YES];
			[_transitions setEnabled:NO];
		}
		if (isKenBurns)
		{
			[_pictureMotion selectItemWithTitle:CPLocalizedString(@"Ken Burns")];
			[_kenBurns setHidden:NO];
		}
		else
		{
			[_pictureMotion selectItemWithTitle:CPLocalizedString(@"None")];
			[_kenBurns setHidden:YES];
		}
	}
	else
	{
		[_caption setStringValue:@""];
		[_length setStringValue:@""];
		[_prevButton setEnabled:NO];
		[_nextButton setEnabled:NO];
		[_preview setImage:nil];
		[_kenBurns setHidden:YES];
	}
}

- (void)slideSelected:(CPNotification)aNotification
{
	[self setData];
	[[self window] makeFirstResponder:_caption];
}

#pragma mark Actions

- (void)nextImage:(id)sender
{
	var idx = [[Session sharedSession] imageIndex];
	if ([[Session sharedSession] slideAtIndex:idx+1])
	{
		[[Session sharedSession] setImageIndex:idx+1];
	}
}

- (void)prevImage:(id)sender
{
	var idx = [[Session sharedSession] imageIndex];
	if (idx > 0)
	{
		[[Session sharedSession] setImageIndex:idx-1];
	}
}

- (void)sliderDidFinish:(id)sender
{
	[_scaleValue setStringValue:[CPString stringWithFormat:@"%.1f", [[_scaleSlider objectValue] doubleValue]]];
	[self writeTransitionValuesToSession];
	[self updateSlide:self];
}

- (void)sliderValueDidChange:(id)sender
{
	[_scaleValue setStringValue:[CPString stringWithFormat:@"%.1f", [[_scaleSlider objectValue] doubleValue]]];
}

- (void)controlTextDidChange:(CPNotification)aNotification
{
	var index = [[Session sharedSession] imageIndex];
	slide = [[[Session sharedSession] slides] objectAtIndex:index];
	if ([aNotification object] == _scaleValue)
	{
		var seconds = [[_scaleValue objectValue] doubleValue]*1000.0;
		if (isNaN(seconds) || [[_scaleValue objectValue] doubleValue] <= 0 || [[_scaleValue objectValue] doubleValue] > [_scaleSlider maxValue])
		{
		}
		else
		{
			[_scaleSlider setObjectValue:[_scaleValue objectValue]];
		}
		[self writeTransitionValuesToSession];
	}
	else if ([aNotification object] == _length)
	{
		var milliseconds = [[_length objectValue] doubleValue]*1000.0;
		if (isNaN(milliseconds) || [[_length objectValue] doubleValue] <= 0)
		{
			[_lengthLabel setTextColor:[CPColor colorWithHexString:@"FF6347"]];
		}
		else
		{
			[_lengthLabel setTextColor:[CPColor colorWithHexString:@"000000"]];
			[slide setObject:[CPNumber numberWithDouble:milliseconds] forKey:@"length"];
		}
	}
	else if ([aNotification object] == _caption)
	{
		[slide setObject:[_caption stringValue] forKey:@"caption"];
	}
}

- (void)staticSelected:(id)sender
{
	[_kenBurns setHidden:YES];
	[[Session sharedSession] activateKenBurns:NO forSlideAtIndex:[[Session sharedSession] imageIndex]];
	[self updateSlide:self];
}

- (void)kenBurnsSelected:(id)sender
{
	[_kenBurns setHidden:NO];
	[[Session sharedSession] activateKenBurns:YES forSlideAtIndex:[[Session sharedSession] imageIndex]];
	[self updateSlide:self];
}

- (void)transitionSelected:(id)sender
{
	[_transitions selectItem:sender];
	if ([sender tag] == 999)
	{
		[[Session sharedSession] removeTransitionForSlideAtIndex:[[Session sharedSession] imageIndex]];
	}
	else
	{
		timeInMillis = [[_scaleSlider objectValue] doubleValue]*1000.0;
		[[Session sharedSession] setTransition:[[[Session sharedSession] transitions] objectAtIndex:[sender tag]] withLength:timeInMillis forSlideAtIndex:[[Session sharedSession] imageIndex]];
	}
	[self updateSlide:self];
}

- (void)slidePropertiesTextFieldDidEndEditing:(id)sender
{
	[self updateSlide:self];
}

- (void)updateSlide:(id)sender
{
	var index = [[Session sharedSession] imageIndex];
	if (index >= 0)
	{
		[[ConnectionController sharedConnectionController] saveProject];
		[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationSlideUpdated object:nil]];
	}
}

@end

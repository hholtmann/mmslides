/*
 * GlobalPreferencesSlideshow.j
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
@import "Session.j"
@import "ConnectionController.j"

@implementation GlobalPreferencesSlideshow : CPView
{
	CPButton _okButton;
	CPButton _cancelButton;
	CPTextField _defaultLength;
	CPFocusTextField _defaultLengthLabel;
	CPTextField _defaultLengthSuffix;
	CPTextField _defaultSlideLength;
	CPFocusTextField _defaultSlideLengthLabel;
	CPTextField _defaultSlideLengthSuffix;
	CPPopUpButton _defaultTransition;
	CPFocusTextField _defaultTransitionLabel;
	CPTextField _defaultTransitionLength;
	CPFocusTextField _defaultTransitionLengthLabel;
	CPTextField _defaultTransitionLengthSuffix;
	CPTextField _defaultCaption;
	BOOL _error;
}

- (id)initWithFrame:(CGRect)aRect
{
	self = [super initWithFrame:aRect];
	if (self)
	{
		_error = NO;

		var startY = 10;
		_defaultLength = [CPTextField textFieldWithStringValue:@"" placeholder:@"" width:120]
		[_defaultLength setFrameOrigin:CGPointMake(310,startY+20)];
		[_defaultLength setEditable:YES]; 
		[_defaultLength setTarget:self]; 
		[_defaultLength setAction:@selector(textFieldDidEndEditing:)];
		[_defaultLength setValue:CPRightTextAlignment forThemeAttribute:@"alignment"];
		[_defaultLength setDelegate:self]; 
		[self addSubview:_defaultLength];
		[[self window] makeFirstResponder:_defaultLength];

		_defaultLengthLabel = [CPFocusTextField labelWithTitle:CPLocalizedString(@"Default slideshow length")];
		[_defaultLengthLabel setFrame:CGRectMake(10, startY+20+5, 290, 24)];
		[_defaultLengthLabel setFocusField:_defaultLength];
		[_defaultLengthLabel setValue:CPRightTextAlignment forThemeAttribute:@"alignment"];
		[self addSubview:_defaultLengthLabel];

		_defaultLengthSuffix = [CPTextField labelWithTitle:CPLocalizedString(@"seconds")];
		[_defaultLengthSuffix setFrame:CGRectMake(440, startY+20+5, 150, 24)];
		[_defaultLengthSuffix setValue:CPLeftTextAlignment forThemeAttribute:@"alignment"];
		[self addSubview:_defaultLengthSuffix];

		_defaultSlideLength = [CPTextField textFieldWithStringValue:@"" placeholder:@"" width:120]
		[_defaultSlideLength setFrameOrigin:CGPointMake(310,startY+50)];
		[_defaultSlideLength setEditable:YES]; 
		[_defaultSlideLength setTarget:self]; 
		[_defaultSlideLength setAction:@selector(textFieldDidEndEditing:)];
		[_defaultSlideLength setValue:CPRightTextAlignment forThemeAttribute:@"alignment"];
		[_defaultSlideLength setDelegate:self]; 
		[self addSubview:_defaultSlideLength];

		_defaultSlideLengthLabel = [CPFocusTextField labelWithTitle:CPLocalizedString(@"Default slide length")];
		[_defaultSlideLengthLabel setFrame:CGRectMake(10, startY+50+5, 290, 24)];
		[_defaultSlideLengthLabel setFocusField:_defaultSlideLength];
		[_defaultSlideLengthLabel setValue:CPRightTextAlignment forThemeAttribute:@"alignment"];
		[self addSubview:_defaultSlideLengthLabel];

		_defaultSlideLengthSuffix = [CPTextField labelWithTitle:CPLocalizedString(@"seconds")];
		[_defaultSlideLengthSuffix setFrame:CGRectMake(440, startY+50+5, 150, 24)];
		[_defaultSlideLengthSuffix setValue:CPLeftTextAlignment forThemeAttribute:@"alignment"];
		[self addSubview:_defaultSlideLengthSuffix];

		_defaultTransition = [[CPPopUpButton alloc] initWithFrame:CGRectMake(314, startY+85, 160, 24) pullsDown:NO];
		for (var i = 0; i < [[[Session sharedSession] transitions] count]; i++)
		{
			var menuitem = [[CPMenuItem alloc] initWithTitle:CPLocalizedString([[[Session sharedSession] transitions] objectAtIndex:i]) action:@selector(transitionSelected:) keyEquivalent:nil];
			[menuitem setTag:i];
			[menuitem setTarget:self];
			[_defaultTransition addItem:menuitem];
		}
		[_defaultTransition setTarget:self];
		[self addSubview:_defaultTransition];

		_defaultTransitionLabel = [CPFocusTextField labelWithTitle:CPLocalizedString(@"Default transition")];
		[_defaultTransitionLabel setFrame:CGRectMake(10, startY+85+5, 290, 24)];
		[_defaultTransitionLabel setFocusField:_defaultTransition];
		[_defaultTransitionLabel setValue:CPRightTextAlignment forThemeAttribute:@"alignment"];
		[self addSubview:_defaultTransitionLabel];

		_defaultTransitionLength = [CPTextField textFieldWithStringValue:@"" placeholder:@"" width:120]
		[_defaultTransitionLength setFrameOrigin:CGPointMake(310,startY+120)];
		[_defaultTransitionLength setEditable:YES]; 
		[_defaultTransitionLength setTarget:self]; 
		[_defaultTransitionLength setAction:@selector(textFieldDidEndEditing:)];
		[_defaultTransitionLength setValue:CPRightTextAlignment forThemeAttribute:@"alignment"];
		[_defaultTransitionLength setDelegate:self]; 
		[self addSubview:_defaultTransitionLength];

		_defaultTransitionLengthLabel = [CPFocusTextField labelWithTitle:CPLocalizedString(@"Default transition length")];
		[_defaultTransitionLengthLabel setFocusField:_defaultTransitionLength];
		[_defaultTransitionLengthLabel setFrame:CGRectMake(10, startY+120+5, 290, 24)];
		[_defaultTransitionLengthLabel setValue:CPRightTextAlignment forThemeAttribute:@"alignment"];
		[self addSubview:_defaultTransitionLengthLabel];

		_defaultTransitionLengthSuffix = [CPTextField labelWithTitle:CPLocalizedString(@"seconds")];
		[_defaultTransitionLengthSuffix setFrame:CGRectMake(440, startY+120+5, 150, 24)];
		[_defaultTransitionLengthSuffix setValue:CPLeftTextAlignment forThemeAttribute:@"alignment"];
		[self addSubview:_defaultTransitionLengthSuffix];

		_cancelButton = [[CPButton alloc] initWithFrame:CGRectMake(340,270,98,24)];
		[_cancelButton setTitle:CPLocalizedString(@"Cancel")];
		[_cancelButton setTarget:self];
		[_cancelButton setAction:@selector(cancelPreferences:)];
		[self addSubview:_cancelButton];

		_okButton = [[CPButton alloc] initWithFrame:CGRectMake(446,270,98,24)];
		[_okButton setTitle:CPLocalizedString(@"Save")];
		[_okButton setTarget:self];
		[_okButton setDefaultButton:YES];
		[_okButton setAction:@selector(savePreferences:)];
		[self addSubview:_okButton];
		[self setData];
		[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(preferencesSaved:) name:CCNotificationPreferencesSaved object:nil];
	}
	return self;
}

- (void)controlTextDidChange:(CPNotification)aNotification
{
	var isError = NO;
	if ([aNotification object] == _defaultTransitionLength)
	{
		var milliseconds = [[_defaultTransitionLength objectValue] doubleValue]*1000.0;
		if (isNaN(milliseconds) || [[_defaultTransitionLength objectValue] doubleValue] <= 0)
		{
			[_defaultTransitionLengthLabel setTextColor:[CPColor colorWithHexString:@"FF6347"]];
			isError = YES;
		}
		else
		{
			[_defaultTransitionLengthLabel setTextColor:[CPColor colorWithHexString:@"000000"]];
		}
	}
	else if ([aNotification object] == _defaultSlideLength)
	{
		var milliseconds = [[_defaultSlideLength objectValue] doubleValue]*1000.0;
		if (isNaN(milliseconds) || [[_defaultSlideLength objectValue] doubleValue] <= 0)
		{
			isError = YES;
			[_defaultSlideLengthLabel setTextColor:[CPColor colorWithHexString:@"FF6347"]];
		}
		else
		{
			[_defaultSlideLengthLabel setTextColor:[CPColor colorWithHexString:@"000000"]];
		}
	}
	else if ([aNotification object] == _defaultLength)
	{
		var milliseconds = [[_defaultLength objectValue] doubleValue]*1000.0;
		if (isNaN(milliseconds) || [[_defaultLength objectValue] doubleValue] <= 0)
		{
			isError = YES;
			[_defaultLengthLabel setTextColor:[CPColor colorWithHexString:@"FF6347"]];
		}
		else
		{
			[_defaultLengthLabel setTextColor:[CPColor colorWithHexString:@"000000"]];
		}
	}
	if (isError)
	{
		[_okButton setEnabled:NO];
	}
	else
	{
		[_okButton setEnabled:YES];
	}
}

- (void)setData
{
	[_defaultLength setStringValue:[CPString stringWithFormat:@"%.1f", [[Session sharedSession] defaultLength]/1000.0]];
	[_defaultSlideLength setStringValue:[CPString stringWithFormat:@"%.1f", [[Session sharedSession] defaultSlideLength]/1000.0]];
	[_defaultTransition selectItemWithTitle:CPLocalizedString([[Session sharedSession] defaultTransition])];
	[_defaultTransitionLength setStringValue:[CPString stringWithFormat:@"%.1f", [[Session sharedSession] defaultTransitionLength]/1000.0]];
}

- (void)savePreferences:(id)sender
{
	[[Session sharedSession] setDefaultLength:[[_defaultLength objectValue] doubleValue]*1000.0];
	[[Session sharedSession] setDefaultSlideLength:[[_defaultSlideLength objectValue] doubleValue]*1000.0];
	[[Session sharedSession] setDefaultTransitionLength:[[_defaultTransitionLength objectValue] doubleValue]*1000.0];
	if ([[_defaultTransition selectedItem] tag] == 999)
	{
		[[Session sharedSession] setDefaultTransition:@"none"];
	}
	else
	{
		[[Session sharedSession] setDefaultTransition:[[[Session sharedSession] transitions] objectAtIndex:[[_defaultTransition selectedItem] tag]]];
	}
	[[ConnectionController sharedConnectionController] savePreferences];
}

- (void)preferencesSaved:(CPNotification)aNotification
{
	[self cancelPreferences:self];
}

- (void)cancelPreferences:(id)sender
{
	[[CPApplication sharedApplication] abortModal];
	[[self window] close]; 
}

- (void)transitionSelected:(id)sender
{
	[_defaultTransition selectItem:sender];
}

@end
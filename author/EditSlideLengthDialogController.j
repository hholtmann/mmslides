/*
 * EditSlideLengthDialogController.j
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
@import "CPFocusTextField.j";

@implementation EditSlideLengthDialogController : CPWindowController
{
	CPButton _okButton;
	CPButton _cancelButton;
	CPTextField _length;
	CPFocusTextField _lengthLabel;
	CPTextField _lengthPostfix;
}

- (id)init
{
	var theWindow = [[CPPanel alloc] initWithContentRect:CGRectMake(80, 80, 410, 95) styleMask:CPClosableWindowMask];
        
	self = [super initWithWindow:theWindow];
    
	if (self)
	{
		[theWindow setTitle:CPLocalizedString(@"Edit Caption")];
		[theWindow setDelegate:self];
		[theWindow setFloatingPanel:YES];
        
		var contentView = [theWindow contentView]

		_length = [[CPTextField alloc] initWithFrame:CGRectMake(109,7,100,30)];
		[_length setEditable:YES]; 
		[_length setBordered:YES]; 
		[_length setBezeled: YES]; 
		[_length setValue:CPRightTextAlignment forThemeAttribute:@"alignment"];
		[_length setBezelStyle:CPTextFieldSquareBezel];
		[_length setSendsActionOnEndEditing:YES];
		[_length setTarget:self]; 
		[_length setAction:@selector(enterPressed:)]; 
		[contentView addSubview:_length];

		_lengthLabel = [[CPFocusTextField alloc] initWithFrame:CGRectMake(16,11,89,25)];
		[_lengthLabel setTextColor:[CPColor blackColor]];
		[_lengthLabel setFocusField:_length];
		[_lengthLabel setStringValue:CPLocalizedString(@"Slide length")];
		[contentView addSubview:_lengthLabel];

		_lenghPostfix = [[CPTextField alloc] initWithFrame:CGRectMake(215,11,80,25)];
		[_lenghPostfix setTextColor:[CPColor blackColor]];
		[_lenghPostfix setStringValue:CPLocalizedString(@"seconds")];
		[contentView addSubview:_lenghPostfix];

		_cancelButton = [[CPButton alloc] initWithFrame:CGRectMake(193,61,98,24)];
		[_cancelButton setTitle:CPLocalizedString(@"Cancel")];
		[_cancelButton setTarget:self];
		[_cancelButton setAction:@selector(cancelEditLength:)];
		[contentView addSubview:_cancelButton];

		_okButton = [[CPButton alloc] initWithFrame:CGRectMake(299,61,98,24)];
		[_okButton setTitle:CPLocalizedString(@"Save")];
		[_okButton setTarget:self];
		[_okButton setAction:@selector(setLength:)];
		[contentView addSubview:_okButton];
		
		[self setData];

		[theWindow makeFirstResponder:_length];
		[theWindow setDefaultButton:_okButton];
	}
    
	return self;
}

- (void)enterPressed:(id)sender
{
	[self setLength:sender];
}

- (void)cancelEditLength:(id)sender
{
	[CPApp abortModal];
	[[self window] close]; 
}

- (void)controlTextDidChange:(CPNotification)aNotification
{
	var index = [[Session sharedSession] imageIndex];
	slide = [[[Session sharedSession] slides] objectAtIndex:index];
	if ([aNotification object] == _length)
	{
		var milliseconds = [[_length objectValue] doubleValue]*1000.0;
		if (isNaN(milliseconds) || [[_length objectValue] doubleValue] <= 0)
		{
			[_lengthLabel setTextColor:[CPColor colorWithHexString:@"FF6347"]];
			[_okButton setEnabled:NO];
		}
		else
		{
			[_lengthLabel setTextColor:[CPColor colorWithHexString:@"000000"]];
			[_okButton setEnabled:YES];
		}
	}
}

- (void)setLength:(id)sender
{
	var index = [[Session sharedSession] imageIndex];
	slide = [[[Session sharedSession] slides] objectAtIndex:index];
	var milliseconds = [[_length objectValue] doubleValue]*1000.0;
	if (isNaN(milliseconds) || [[_length objectValue] doubleValue] <= 0)
	{
		[_lengthLabel setTextColor:[CPColor colorWithHexString:@"FF6347"]];
	}
	else
	{
		[_lengthLabel setTextColor:[CPColor colorWithHexString:@"000000"]];
		[slide setObject:[CPNumber numberWithDouble:milliseconds] forKey:@"length"];
		[[ConnectionController sharedConnectionController] saveProject];
		[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationSlideUpdated object:nil]];
		[self cancelEditLength:sender];
	}
}

- (void)setData
{
	var index = [[Session sharedSession] imageIndex];
	slide = [[[Session sharedSession] slides] objectAtIndex:index];
	if ([slide objectForKey:@"length"] != null && [[slide objectForKey:@"length"] class] == [CPNumber class])
	{
		[_length setStringValue:[CPString stringWithFormat:@"%.1f", [[slide objectForKey:@"length"] doubleValue]/1000.0]];
	}
	else
	{
		[_length setStringValue:[CPString stringWithFormat:@"%.1f", 0.0]];
	}
}

-(BOOL)windowShouldClose:(id)window
{
	[self cancelEditLength:self];
	return true;
}

@end
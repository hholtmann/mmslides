/*
 * GlobalPreferencesPublishLocal.j
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

@implementation GlobalPreferencesPublishLocal : CPView
{
	CPButton _okButton;
	CPButton _cancelButton;
	CPTextField _serverPath;
	CPFocusTextField _serverPathLabel;
	BOOL _error;
}

- (id)initWithFrame:(CGRect)aRect
{
	self = [super initWithFrame:aRect];
	if (self)
	{
		_error = NO;

		var startY = 10;
		_serverPath = [CPTextField textFieldWithStringValue:[[CPBundle mainBundle] objectForInfoDictionaryKey:@"PublishFolder"] placeholder:@"" width:250]
		[_serverPath setFrameOrigin:CGPointMake(210,startY+20)];
		[_serverPath setEditable:NO];
		[_serverPath setEnabled:NO];
		[_serverPath setTarget:self]; 
		[_serverPath setAction:@selector(textFieldDidEndEditing:)];
		[_serverPath setDelegate:self]; 
		[self addSubview:_serverPath];
		[[self window] makeFirstResponder:_serverPath];

		_serverPathLabel = [CPFocusTextField labelWithTitle:CPLocalizedString(@"Publish folder")];
		[_serverPathLabel setFrame:CGRectMake(10, startY+20+5, 190, 24)];
		[_serverPathLabel setFocusField:_serverPath];
		[_serverPathLabel setValue:CPRightTextAlignment forThemeAttribute:@"alignment"];
		[self addSubview:_serverPathLabel];

		_cancelButton = [[CPButton alloc] initWithFrame:CGRectMake(340,270,98,24)];
		[_cancelButton setTitle:CPLocalizedString(@"Cancel")];
		[_cancelButton setTarget:self];
		[_cancelButton setAction:@selector(cancelPreferences:)];
		[self addSubview:_cancelButton];

		_okButton = [[CPButton alloc] initWithFrame:CGRectMake(446,270,98,24)];
		[_okButton setTitle:CPLocalizedString(@"Save")];
		[_okButton setTarget:self];
		[_okButton setDefaultButton:YES];
		[_okButton setAction:@selector(cancelPreferences:)];
		[self addSubview:_okButton];
	}
	return self;
}

- (void)controlTextDidChange:(CPNotification)aNotification
{
}

- (void)textFieldDidEndEditing:(CPNotification)aNotification
{
}

- (void)cancelPreferences:(id)sender
{
	[[CPApplication sharedApplication] abortModal];
	[[self window] close]; 
}

@end
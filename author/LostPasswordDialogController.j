/*
 * LostPasswordDialogController.j
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



@import <Foundation/CPObject.j>
@import <Foundation/CPDictionary.j>
@import <AppKit/CPWindowController.j>
@import "CPFocusTextField.j"
@import "ConnectionController.j"

LP_ERROR_NO_ERROR = 0;
LP_ERROR_WRONG_PASSWORD = 1;
LP_ERROR_SERVER_ERROR = 2;

@implementation LostPasswordDialogController : CPWindowController
{
	CPButton _okButton;
	CPButton _cancelButton;
	CPTextField _description;
	CPTextField _username;
	CPFocusTextField _usernameLabel;
	CPTextField _password;
	CPFocusTextField _passwordLabel;
	CPTextField _passwordConfirmation;
	CPFocusTextField _passwordConfirmationLabel;
	CPColor _errorColor;
	CPColor _textColor;
	id _delegate @accessors(property=delegate);
	BOOL _error @accessors(property=error);
	int _contentWidth;
	CPDictionary _lostPasswordData @accessors(property=lostPasswordData);
}

- (id)init
{
	var theWindow = [[CPPanel alloc] initWithContentRect:CGRectMake(80, 80, 400, 200) styleMask:CPClosableWindowMask];
	self = [super initWithWindow:theWindow];
    
	if (self)
	{
		[theWindow setTitle:CPLocalizedString(@"Choose a new password")];
		[theWindow setDelegate:self];
		[theWindow setFloatingPanel:YES];

		_contentWidth = 400;
		_errorColor = [CPColor colorWithHexString:@"ff811d"];
		_textColor = [CPColor colorWithHexString:@"000000"];

		var contentView = [theWindow contentView]

		_description = [CPTextField labelWithTitle:@""];
		[_description setFrame:CGRectMake(0,5,_contentWidth-10,30)];
		[_description setAlignment:CPCenterTextAlignment];
		[_description setFont:[CPFont systemFontOfSize:15.0]];
		[contentView addSubview:_description];
		
		_username = [CPTextField textFieldWithStringValue:@"" placeholder:CPLocalizedString(@"") width:200]
		[_username setFrame:CGRectMake(_contentWidth-20-250,40, 200, 30)];
		[_username setEditable:NO]; 
		[_username setEnabled:NO];
		[_username setFont:[CPFont systemFontOfSize:14.0]];
		[contentView addSubview:_username];

		_usernameLabel = [CPFocusTextField labelWithTitle:CPLocalizedString(@"Username:")];
		[_usernameLabel setFrame:CGRectMake(5, 46, 120, 24)];
		[_usernameLabel setFocusField:_username];
		[_usernameLabel setFont:[CPFont boldSystemFontOfSize:14.0]];
		[_usernameLabel setValue:CPRightTextAlignment forThemeAttribute:@"alignment"];
		[contentView addSubview:_usernameLabel];

		_password = [CPTextField textFieldWithStringValue:@"" placeholder:CPLocalizedString(@"") width:200]
		[_password setFrame:CGRectMake(_contentWidth-20-250, 80, 200, 30)];
		[_password setEditable:YES]; 
		[_password setSecure:YES];
		[_password setTarget:self]; 
		[_password setFont:[CPFont systemFontOfSize:14.0]];
		[_password setAction:@selector(textFieldDidEndEditing:)];
		[_password setDelegate:self]; 
		[contentView addSubview:_password];
		[[self window] makeFirstResponder:_password];

		_passwordLabel = [CPFocusTextField labelWithTitle:CPLocalizedString(@"Password:")];
		[_passwordLabel setFrame:CGRectMake(5, 86, 120, 24)];
		[_passwordLabel setFocusField:_password];
		[_passwordLabel setFont:[CPFont boldSystemFontOfSize:14.0]];
		[_passwordLabel setValue:CPRightTextAlignment forThemeAttribute:@"alignment"];
		[contentView addSubview:_passwordLabel];

		_passwordConfirmation = [CPTextField textFieldWithStringValue:@"" placeholder:CPLocalizedString(@"") width:200]
		[_passwordConfirmation setFrame:CGRectMake(_contentWidth-20-250, 120, 200, 30)];
		[_passwordConfirmation setEditable:YES]; 
		[_passwordConfirmation setSecure:YES];
		[_passwordConfirmation setTarget:self]; 
		[_passwordConfirmation setFont:[CPFont systemFontOfSize:14.0]];
		[_passwordConfirmation setAction:@selector(textFieldDidEndEditing:)];
		[_passwordConfirmation setDelegate:self];
		[contentView addSubview:_passwordConfirmation];

		_passwordConfirmationLabel = [CPFocusTextField labelWithTitle:CPLocalizedString(@"Confirm:")];
		[_passwordConfirmationLabel setFrame:CGRectMake(5, 126, 120, 24)];
		[_passwordConfirmationLabel setFocusField:_passwordConfirmation];
		[_passwordConfirmationLabel setFont:[CPFont boldSystemFontOfSize:14.0]];
		[_passwordConfirmationLabel setValue:CPRightTextAlignment forThemeAttribute:@"alignment"];
		[contentView addSubview:_passwordConfirmationLabel];

		_cancelButton = [[CPButton alloc] initWithFrame:CGRectMake(_contentWidth-85-85,170,80,24)];
		[_cancelButton setTitle:CPLocalizedString(@"Cancel")];
		[_cancelButton setTarget:self];
		[_cancelButton setAction:@selector(cancelLostPassword:)];
		[contentView addSubview:_cancelButton];

		_okButton = [[CPButton alloc] initWithFrame:CGRectMake(_contentWidth-85,170,80,24)];
		[_okButton setTitle:CPLocalizedString(@"Choose")];
		[_okButton setTarget:self];
		[_okButton setAction:@selector(doChange:)];
		[contentView addSubview:_okButton];

		[theWindow orderFront:self];
		[theWindow setDefaultButton:_okButton];
		[theWindow setAcceptsMouseMovedEvents:YES];
	}
	return self;
}

- (void)setLostPasswordData:(CPDictionary)dict
{
	_lostPasswordData = dict;
//	CPLog(@"lostpassworddata: %@", dict);
	[self layoutSubviews];
}

- (void)setError:(int)error
{
	_error = error;
	[self layoutSubviews];
}

- (void)layoutSubviews
{
	[_username setStringValue:[_lostPasswordData objectForKey:@"username"]];
	if (_error > 0)
	{
		[_description setTextColor:_errorColor];
		[_passwordLabel setTextColor:_errorColor];
		[_passwordConfirmationLabel setTextColor:_errorColor];
		if (_error == LP_ERROR_WRONG_PASSWORD)
		{
			[_description setStringValue:@"Please enter a valid password."];
		}
		else
		{
			[_description setStringValue:@"An unknown error occured choosing your new password."];
		}
	}
	else
	{
		[_description setTextColor:_textColor];
		[_passwordLabel setTextColor:_textColor];
		[_passwordConfirmationLabel setTextColor:_textColor];
		[_description setStringValue:@"Please choose your new password and confirm it."];
	}
}

- (void)controlTextDidChange:(CPNotification)aNotification
{
}

- (void)textFieldDidEndEditing:(CPNotification)aNotification
{
	[self doChange:nil];
}

- (void)cancelLostPassword:(id)sender
{
	[[CPApplication sharedApplication] abortModal];
	[[self window] close]; 
}

- (void)doChange:(id)sender
{
	var password = [_password stringValue];
	var passwordConfirmation = [_passwordConfirmation stringValue];
	if ([password length] > 5 && [passwordConfirmation length])
	{
		if (![password isEqualToString:passwordConfirmation])
		{
			_error = LD_ERROR_WRONG_PASSWORD_CONFIRMATION;
			[self layoutSubviews];
		}
		else
		{
			if (_delegate && [_delegate respondsToSelector:@selector(lostPasswordDialog:changePassword:forUserId:)])
			{
				[_delegate lostPasswordDialog:self changePassword:password forUserId:[_lostPasswordData objectForKey:@"id"]];
			}
		}
	}
	else
	{
		_error = YES;
		[self layoutSubviews];
	}
}

- (void)closeDialog
{
	[[CPApplication sharedApplication] abortModal];
	[[self window] close]; 
}

-(BOOL)windowShouldClose:(id)window
{
	[self cancelLostPassword:nil];
	return true;
}

@end
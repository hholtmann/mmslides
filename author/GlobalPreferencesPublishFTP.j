/*
 * GlobalPreferencesPublishFTP.j
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

@implementation GlobalPreferencesPublishFTP : CPView
{
	CPButton _okButton;
	CPButton _cancelButton;
	CPTextField _ftpServer;
	CPFocusTextField _ftpServerLabel;
	CPTextField _username;
	CPFocusTextField _usernameLabel;
	CPTextField _password;
	CPFocusTextField _passwordLabel;
	CPTextField _uploadRootPath ;
	CPFocusTextField _uploadRootPathLabel;
	CPTextField _uploadWebURL;
	CPFocusTextField _uploadWebURLLabel;
	BOOL _error;
}

- (id)initWithFrame:(CGRect)aRect
{
	self = [super initWithFrame:aRect];
	if (self)
	{
		_error = NO;

		var startY = 10;
		_ftpServer = [CPTextField textFieldWithStringValue:@"" placeholder:CPLocalizedString(@"Enter the name/IP address of the FTP upload server") width:250]
		[_ftpServer setFrameOrigin:CGPointMake(210,startY+20)];
		[_ftpServer setEditable:YES]; 
		[_ftpServer setTarget:self]; 
		[_ftpServer setAction:@selector(textFieldDidEndEditing:)];
		[_ftpServer setDelegate:self]; 
		[self addSubview:_ftpServer];
		[[self window] makeFirstResponder:_ftpServer];

		_ftpServerLabel = [CPFocusTextField labelWithTitle:CPLocalizedString(@"FTP Server")];
		[_ftpServerLabel setFrame:CGRectMake(10, startY+20+5, 190, 24)];
		[_ftpServerLabel setFocusField:_ftpServer];
		[_ftpServerLabel setValue:CPRightTextAlignment forThemeAttribute:@"alignment"];
		[self addSubview:_ftpServerLabel];

		startY += 30;
		_username = [CPTextField textFieldWithStringValue:@"" placeholder:@"" width:120]
		[_username setFrameOrigin:CGPointMake(210,startY+20)];
		[_username setEditable:YES]; 
		[_username setTarget:self]; 
		[_username setAction:@selector(textFieldDidEndEditing:)];
		[_username setDelegate:self]; 
		[self addSubview:_username];

		_usernameLabel = [CPFocusTextField labelWithTitle:CPLocalizedString(@"FTP username")];
		[_usernameLabel setFrame:CGRectMake(10, startY+20+5, 190, 24)];
		[_usernameLabel setFocusField:_username];
		[_usernameLabel setValue:CPRightTextAlignment forThemeAttribute:@"alignment"];
		[self addSubview:_usernameLabel];

		startY += 30;
		_password = [CPTextField textFieldWithStringValue:@"" placeholder:@"" width:120]
		[_password setFrameOrigin:CGPointMake(210,startY+20)];
		[_password setEditable:YES];
		[_password setSecure:YES];
		[_password setTarget:self]; 
		[_password setAction:@selector(textFieldDidEndEditing:)];
		[_password setDelegate:self]; 
		[self addSubview:_password];

		_passwordLabel = [CPFocusTextField labelWithTitle:CPLocalizedString(@"FTP password")];
		[_passwordLabel setFrame:CGRectMake(10, startY+20+5, 190, 24)];
		[_passwordLabel setFocusField:_password];
		[_passwordLabel setValue:CPRightTextAlignment forThemeAttribute:@"alignment"];
		[self addSubview:_passwordLabel];

		startY += 30;
		_uploadRootPath = [CPTextField textFieldWithStringValue:@"" placeholder:CPLocalizedString(@"Enter the root path to your projects") width:250]
		[_uploadRootPath setFrameOrigin:CGPointMake(210,startY+20)];
		[_uploadRootPath setEditable:YES]; 
		[_uploadRootPath setTarget:self]; 
		[_uploadRootPath setAction:@selector(textFieldDidEndEditing:)];
		[_uploadRootPath setDelegate:self]; 
		[self addSubview:_uploadRootPath];
		[[self window] makeFirstResponder:_uploadRootPath];

		_uploadRootPathLabel = [CPFocusTextField labelWithTitle:CPLocalizedString(@"Data directory")];
		[_uploadRootPathLabel setFrame:CGRectMake(10, startY+20+5, 190, 24)];
		[_uploadRootPathLabel setFocusField:_uploadRootPath];
		[_uploadRootPathLabel setValue:CPRightTextAlignment forThemeAttribute:@"alignment"];
		[self addSubview:_uploadRootPathLabel];

		startY += 30;
		_uploadWebURL = [CPTextField textFieldWithStringValue:@"" placeholder:CPLocalizedString(@"Enter the URL to your data directory") width:250]
		[_uploadWebURL setFrameOrigin:CGPointMake(210,startY+20)];
		[_uploadWebURL setEditable:YES]; 
		[_uploadWebURL setTarget:self]; 
		[_uploadWebURL setAction:@selector(textFieldDidEndEditing:)];
		[_uploadWebURL setDelegate:self]; 
		[self addSubview:_uploadWebURL];
		[[self window] makeFirstResponder:_uploadWebURL];

		_uploadWebURLLabel = [CPFocusTextField labelWithTitle:CPLocalizedString(@"Data directory URL")];
		[_uploadWebURLLabel setFrame:CGRectMake(10, startY+20+5, 190, 24)];
		[_uploadWebURLLabel setFocusField:_uploadWebURL];
		[_uploadWebURLLabel setValue:CPRightTextAlignment forThemeAttribute:@"alignment"];
		[self addSubview:_uploadWebURLLabel];

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
}

- (void)textFieldDidEndEditing:(CPNotification)aNotification
{
}

- (void)setData
{
	[_ftpServer setStringValue:[[Session sharedSession] FTPServer]];
	[_username setStringValue:[[Session sharedSession] FTPUsername]];
	[_password setStringValue:[[Session sharedSession] FTPPassword]];
	[_uploadRootPath setStringValue:[[Session sharedSession] FTPDataDir]];
	[_uploadWebURL setStringValue:[[Session sharedSession] FTPDataURL]];
}

- (void)savePreferences:(id)sender
{
	[[Session sharedSession] setFTPServer:[_ftpServer stringValue]];
	[[Session sharedSession] setFTPUsername:[_username stringValue]];
	[[Session sharedSession] setFTPPassword:[_password stringValue]];
	[[Session sharedSession] setFTPDataDir:[_uploadRootPath stringValue]];
	[[Session sharedSession] setFTPDataURL:[_uploadWebURL stringValue]];
	CPLog(@"publish preferences = %@", [[Session sharedSession] prefsPublish]);
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

@end
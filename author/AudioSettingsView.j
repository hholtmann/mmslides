/*
 * AudioSettingsView.j
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
@import "UploadButton.j"
@import <AppKit/CPAlert.j>
@import "ConnectionController.j"
@import "CPFocusTextField.j"

@implementation AudioSettingsView : CPView
{
	CPTextField _audioLabel;
	CPTextField _descriptionLabel;
	CPTextField _length;
	CPFocusTextField _lengthLabel;
	CPTextField _lengthPostfix;
	UploadButton _uploadButton;
	CPButton _deleteButton;
	CPButton _okButton;
	CPButton _cancelButton;
	bool _isError;
}

- (id)initWithFrame:(CGRect)aRect
{
	if (self = [super initWithFrame:aRect])
	{
		_isError = NO;
		_audioLabel = [CPTextField labelWithTitle:CPLocalizedString(@"Audio file")];
		[_audioLabel setFrameOrigin:CGPointMake(10,110)];
		[_audioLabel setFont:[CPFont boldSystemFontOfSize:12.0]];
		[_audioLabel sizeToFit];
		[self addSubview:_audioLabel];

		_descriptionLabel = [CPTextField labelWithTitle:@""];
		[_descriptionLabel setFrame:CGRectMake([_audioLabel frame].origin.x + [_audioLabel frame].size.width + 10,110,355-([_audioLabel frame].origin.x + [_audioLabel frame].size.width + 10),60)];
		[_descriptionLabel setTextColor:[CPColor blackColor]];
		[_descriptionLabel setValue:CPLeftTextAlignment forThemeAttribute:@"alignment"];
		[_descriptionLabel setLineBreakMode:CPLineBreakByWordWrapping];
		[_descriptionLabel setFont:[CPFont systemFontOfSize:12.0]];
		[self addSubview:_descriptionLabel];

		var urlString = [[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] + @"upload.php";
		_uploadButton = [[UploadButton alloc] initWithFrame:CGRectMake(10,80,120,24)];
		[_uploadButton setTitle:CPLocalizedString(@"Upload Audio")];
		[_uploadButton setBordered:YES];
		[_uploadButton allowsMultipleFiles:NO];
		[_uploadButton setURL:urlString];
		var uploadImage = [[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"plus.png"]];
		[_uploadButton setImage:uploadImage];
		[_uploadButton setValue:[[Session sharedSession] SID] forParameter:@"SID"];
		[_uploadButton setValue:[[Session sharedSession] project] forParameter:@"project"];
		[_uploadButton setValue:@"audio" forParameter:@"type"];
		[_uploadButton setDelegate:self];
		[self addSubview:_uploadButton];

		_deleteButton = [[CPButton alloc] initWithFrame:CGRectMake(140,80,120,24)];
		[_deleteButton setTitle:CPLocalizedString(@"Delete Audio")];
		var bundle = [CPBundle mainBundle];
		deleteImage = [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"delete.png"]];
		[_deleteButton setImage:deleteImage];
		[_deleteButton setTarget:self];
		[_deleteButton setAction:@selector(deleteAudio:)];
		[self addSubview:_deleteButton];

		_lenghPostfix = [[CPTextField alloc] initWithFrame:CGRectMake(135,35,80,25)];
		[_lenghPostfix setTextColor:[CPColor blackColor]];
		[_lenghPostfix setStringValue:CPLocalizedString(@"seconds")];
		[self addSubview:_lenghPostfix];

		_length = [CPTextField textFieldWithStringValue:@"" placeholder:@"" width:120]
		[_length setFrameOrigin:CGPointMake(10,30)];
		[_length setEditable:YES]; 
		[_length setBordered:YES]; 
		[_length setBezeled: YES]; 
		[_length setValue:CPRightTextAlignment forThemeAttribute:@"alignment"];
		[_length setBezelStyle:CPTextFieldSquareBezel];
		[_length setSendsActionOnEndEditing:YES];
		[_length setTarget:self]; 
		[_length setAction:@selector(textFieldDidEndEditing:)];
		[_length setDelegate:self]; 
		[self addSubview:_length];

		_lengthLabel = [[CPFocusTextField alloc] initWithFrame:CGRectMake(10,10,120,25)];
		[_lengthLabel setTextColor:[CPColor blackColor]];
		[_lengthLabel setFocusField:_length];
		[_lengthLabel setStringValue:CPLocalizedString(@"Slide show length")];
		[self addSubview:_lengthLabel];

		_cancelButton = [[CPButton alloc] initWithFrame:CGRectMake(185,215,98,24)];
		[_cancelButton setTitle:CPLocalizedString(@"Cancel")];
		[_cancelButton setTarget:self];
		[_cancelButton setAction:@selector(cancelAudio:)];
		[self addSubview:_cancelButton];

		_okButton = [[CPButton alloc] initWithFrame:CGRectMake(291,215,98,24)];
		[_okButton setTitle:CPLocalizedString(@"Save")];
		[_okButton setTarget:self];
		[_okButton setDefaultButton:YES];
		[_okButton setAction:@selector(saveAudio:)];
		[self addSubview:_okButton];

		[self setData];
		[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(projectDidLoad:) name:CPNotificationProjectDidLoad object:nil];
		[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(_setAudio:) name:CPNotificationAudioFileLoaded object:nil];
	}
	return self;
}

- (void)setData
{
	[_uploadButton setEnabled:YES];
	[_uploadButton setValue:[[Session sharedSession] SID] forParameter:@"SID"];
	[_uploadButton setValue:[[Session sharedSession] project] forParameter:@"project"];
	var audio = [[Session sharedSession] audio];
	if (audio)
	{
		[_descriptionLabel setStringValue:[CPString stringWithFormat:@"%@ (%.1f %@)", [audio objectForKey:@"name"], [audio objectForKey:@"length"], CPLocalizedString(@"seconds")]];
		[_deleteButton setEnabled:YES];
	}
	else
	{
		[_descriptionLabel setStringValue:CPLocalizedString(@"No audio file uploaded")];
		[_deleteButton setEnabled:NO];
	}
	[_length setStringValue:[CPString stringWithFormat:@"%.1f", [[Session sharedSession] slideShowLength]/1000.0]];
	_isError = NO;
	[[self window] makeFirstResponder:_length];
}

- (void)_setAudio:(CPNotification)aNotification
{
	[self setData];
}

- (void)projectDidLoad:(CPNotification)aNotification
{
	[self _setAudio:self];
}

-(void) uploadButton:(UploadButton)button didChangeSelection:(CPArray)selection
{
	CPLog(@"button didChangeSelection");
	[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationShowWaitDialog object:nil userInfo:[CPDictionary dictionaryWithObjectsAndKeys:CPLocalizedString(@"Loading. Please wait..."), @"description"]]];
	[button submit];
}

-(void) uploadButton:(UploadButton)button didFailWithError:(CPString)anError
{
	CPLog(@"Upload failed with this error: " + anError);
}

-(void) uploadButton:(UploadButton)button didFinishUploadWithData:(CPString)response
{
	[button resetSelection];
	[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationHideWaitDialog object:nil]];

	if ([[Session sharedSession] numberOfSlides])
	{
		var alert = [[CPAlert alloc] init];
		[alert setMessageText:CPLocalizedString(@"Do you want the existing slides distributed equally to the running time of the audio track?")];
		[alert setTitle:CPLocalizedString(@"Distribute slides")];
		[alert setDelegate:self];
		[alert setAlertStyle:CPInformationalAlertStyle];
		[alert addButtonWithTitle:@"Yes"];
		[alert addButtonWithTitle:@"No"];
		[alert runModal];
	}
	else
	{
		[[ConnectionController sharedConnectionController] loadProject:[[Session sharedSession] project]];
	}
}

-(void) uploadButtonDidBeginUpload:(UploadButton)button
{
	CPLog(@"Upload has begun with selection: " + [button selection]);
}

- (void)deleteAudio:(id)sender
{
	var alert = [[CPAlert alloc] init];
	[alert setMessageText:CPLocalizedString(@"Do you really want to delete the audio file?")];
	[alert setTitle:CPLocalizedString(@"Delete Audio")];
	[alert setDelegate:self];
	[alert setAlertStyle:CPWarningAlertStyle];
	[alert addButtonWithTitle:@"Delete"];
	[alert addButtonWithTitle:@"Cancel"];
	[alert runModal];
}

-(void)alertDidEnd:(CPAlert)theAlert returnCode:(int)returnCode
{
	if ([[theAlert title] isEqualToString:CPLocalizedString(@"Distribute slides")])
	{
		if (returnCode == 0)
		{
			[[ConnectionController sharedConnectionController] distributeSlidesAndLoadProject:[[Session sharedSession] project]];
		}
		else
		{
			[[ConnectionController sharedConnectionController] loadProject:[[Session sharedSession] project]];
		}
	}
	else
	{
		if (returnCode == 0)
		{
			[[Session sharedSession] removeAudio];
			[[ConnectionController sharedConnectionController] deleteAudio];
			[self setData];
		}
	}
}

- (void)textFieldDidEndEditing:(id)sender
{
	[self saveAudio:self];
}

- (void)controlTextDidChange:(CPNotification)aNotification
{
	if ([aNotification object] == _length)
	{
		var milliseconds = [[_length objectValue] doubleValue]*1000.0;
		var roundedLength = parseFloat([CPString stringWithFormat:@"%.1f", [[Session sharedSession] audioLength]]);
		if (isNaN(milliseconds) || [[_length objectValue] doubleValue] <= 0 || ([[Session sharedSession] audioLength] > 0 && ([[_length objectValue] doubleValue] < roundedLength)))
		{
			[_lengthLabel setTextColor:[CPColor colorWithHexString:@"FF6347"]];
			_isError = YES;
			[_okButton setEnabled:NO];
		}
		else
		{
			[_lengthLabel setTextColor:[CPColor colorWithHexString:@"000000"]];
			_isError = NO;
			[_okButton setEnabled:YES];
		}
	}
}

- (void)saveAudio:(id)sender
{
	var milliseconds = [[_length objectValue] doubleValue]*1000.0;
	var roundedLength = parseFloat([CPString stringWithFormat:@"%.1f", [[Session sharedSession] audioLength]]);
	if (isNaN(milliseconds) || [[_length objectValue] doubleValue] <= 0 || ([[Session sharedSession] audioLength] > 0 && ([[_length objectValue] doubleValue] < roundedLength)))
	{
		[_lengthLabel setTextColor:[CPColor colorWithHexString:@"FF6347"]];
		_isError = YES;
	}
	else
	{
		[_lengthLabel setTextColor:[CPColor colorWithHexString:@"000000"]];
		[[Session sharedSession] setSlideShowLength:[CPNumber numberWithDouble:milliseconds]];
		[_length setStringValue:[CPString stringWithFormat:@"%.1f", [[Session sharedSession] slideShowLength]/1000.0]];
		[[ConnectionController sharedConnectionController] saveProject];
		_isError = NO;
	}
	if (!_isError)
	{
		[CPApp abortModal];
		[[self window] close]; 
	}
}

- (void)cancelAudio:(id)sender
{
	[CPApp abortModal];
	[[self window] close]; 
}

@end

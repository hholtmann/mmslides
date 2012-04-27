/*
 * ExportMovieView.j
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
@import <AppKit/CPAlert.j>
@import "ConnectionController.j"
@import "Session.j"
@import "CustomAlert.j"

@implementation ExportMovieView : CPView
{
	CPButton _okButton;
	CPButton _cancelButton;
	CPPopUpButton _presetChoice;
	CPTextField _resolutionField;
	CPTextField _codecField;
	CPTextField _usageField;
	CPTextField _queueEntriesWarning;
	CPCheckBox _captions;
	int _queueEntries;
	BOOL _error;
	int _activeTag;
}

- (id)initWithFrame:(CGRect)aRect
{
	self = [super initWithFrame:aRect];
	if (self)
	{
		_error = NO;
		_queueEntries = 0;

		//Preset
		_presetChoice = [[CPPopUpButton alloc] initWithFrame:CGRectMake(150, 10, 395, 24) pullsDown:NO];
		for (var i = 0; i < [[[Session sharedSession] moviePresets] count]; i++)
		{
			var menuitem = [[CPMenuItem alloc] initWithTitle:CPLocalizedString([[[[Session sharedSession] moviePresets] objectAtIndex:i] objectForKey:@"title"]) action:@selector(presetSelected:) keyEquivalent:nil];
			[menuitem setTag:i];
			[menuitem setTarget:self];
			[_presetChoice addItem:menuitem];
		}
		[_presetChoice setTarget:self];
		[self addSubview:_presetChoice];

		var _presetChoiceLabel = [CPFocusTextField labelWithTitle:CPLocalizedString(@"Preset")];
		[_presetChoiceLabel setFrame:CGRectMake(10, 10+4, 135, 24)];
		[_presetChoiceLabel setFocusField:_presetChoice];
		[_presetChoiceLabel setValue:CPRightTextAlignment forThemeAttribute:@"alignment"];
		[self addSubview:_presetChoiceLabel];
		
		_captions = [CPCheckBox checkBoxWithTitle:CPLocalizedString(@"Show Captions")];
		[_captions setFrameOrigin:CGPointMake(150, 36)];
		[self addSubview:_captions];
		
		//Resolution Label
		var _resolutionLabel = [CPTextField labelWithTitle:CPLocalizedString(@"Resolution")];
		[_resolutionLabel setFrame:CGRectMake(10, 64+4, 135, 24)];
		[_resolutionLabel setValue:CPRightTextAlignment forThemeAttribute:@"alignment"];
		[self addSubview:_resolutionLabel];
		
		//Resolution
		_resolutionField = [CPTextField labelWithTitle:CPLocalizedString(@"ResolutionValue")];
		[_resolutionField setFrame:CGRectMake(150, 64+4, 135, 24)];
		[_resolutionField setFont:[CPFont boldSystemFontOfSize:12]];
		[_resolutionField setValue:CPLeftTextAlignment forThemeAttribute:@"alignment"];
		[self addSubview:_resolutionField];	
		
		//Format Label
		var _formatLabel = [CPTextField labelWithTitle:CPLocalizedString(@"Format")];
		[_formatLabel setFrame:CGRectMake(10, 94+4, 135, 24)];
		[_formatLabel setValue:CPRightTextAlignment forThemeAttribute:@"alignment"];
		[self addSubview:_formatLabel];
		
		
		//Format
		_formatField = [CPTextField labelWithTitle:CPLocalizedString(@"FormatValue")];
		[_formatField setFrame:CGRectMake(150, 94+4, 135, 24)];
		[_formatField setFont:[CPFont boldSystemFontOfSize:12]];
		[_formatField setValue:CPLeftTextAlignment forThemeAttribute:@"alignment"];
		[self addSubview:_formatField];
	
		//Codec Label
		var _codecLabel = [CPTextField labelWithTitle:CPLocalizedString(@"Codec")];
		[_codecLabel setFrame:CGRectMake(10, 124+4, 135, 24)];
		[_codecLabel setValue:CPRightTextAlignment forThemeAttribute:@"alignment"];
		[self addSubview:_codecLabel];
		
		//Codec
		_codecField = [CPTextField labelWithTitle:CPLocalizedString(@"ResolutionValue")];
		[_codecField setFrame:CGRectMake(150, 124+4, 135, 24)];
		[_codecField setFont:[CPFont boldSystemFontOfSize:12]];
		[_codecField setValue:CPLeftTextAlignment forThemeAttribute:@"alignment"];
		[self addSubview:_codecField];
		
		//Usage Label
		var _usageLabel = [CPTextField labelWithTitle:CPLocalizedString(@"Usage")];
		[_usageLabel setFrame:CGRectMake(10, 154+4, 135, 24)];
		[_usageLabel setValue:CPRightTextAlignment forThemeAttribute:@"alignment"];
		[self addSubview:_usageLabel];
		
		//Usage
		_usageField = [CPTextField labelWithTitle:CPLocalizedString(@"ResolutionValue")];
		[_usageField setFrame:CGRectMake(150, 154+4, 250, 150)];
		[_usageField setFont:[CPFont boldSystemFontOfSize:12]];
		[_usageField setValue:CPLeftTextAlignment forThemeAttribute:@"alignment"];
		[self addSubview:_usageField]

		_queueEntriesWarning = [[CPTextField alloc] initWithFrame:CGRectMake(150, 220, 400, 44)];
		if (_queueEntries > 0)
		{
			[_queueEntriesWarning setStringValue:[CPString stringWithFormat:CPLocalizedString(@"You are already running %d export task(s)"), _queueEntries]]; 
		}
		[_queueEntriesWarning setFont:[CPFont boldSystemFontOfSize:11.0]]; 
		[_queueEntriesWarning setTextColor: [CPColor redColor]];
		[self addSubview:_queueEntriesWarning];

		_cancelButton = [[CPButton alloc] initWithFrame:CGRectMake(340,220,98,24)];
		[_cancelButton setTitle:CPLocalizedString(@"Cancel")];
		[_cancelButton setTarget:self];
		[_cancelButton setAction:@selector(cancelExport:)];
		[self addSubview:_cancelButton];

		_okButton = [[CPButton alloc] initWithFrame:CGRectMake(446,220,98,24)];
		[_okButton setTitle:CPLocalizedString(@"Publish")];
		[_okButton setTarget:self];
		[_okButton setDefaultButton:YES];
		[_okButton setAction:@selector(checkStartExport:)];
		[self addSubview:_okButton];
		[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(movieQueueChecked:) name:CCNotificationMovieQueueFiles object:nil];
		[self setData];
		[[self window] setDefaultButton:_okButton];
	}
	return self;
}


- (void)setData
{
	[[ConnectionController sharedConnectionController] checkMovieQueue];
	var presetTag = [[[[Session sharedSession] exportSettings] objectForKey:@"moviePreset"] intValue];
	if (presetTag!= null && presetTag>=0) {
		[_presetChoice selectItemWithTag:presetTag];
		[self updateDisplayForTag:presetTag];	
	} else {
		[_presetChoice selectItemWithTag:4];
		[self updateDisplayForTag:4];
	}
}

- (void)sizeDidEndEditing:(id)sender
{
	
}

-(void)updateDisplayForTag:(int)tag
{
	var sizes = [[Session sharedSession] movieExportSizes];
	var formats = [[Session sharedSession] videoFormats];
	var tag = [[_presetChoice selectedItem] tag];
	var choiceDict = [[[Session sharedSession] moviePresets] objectAtIndex:tag];
	
	_activeTag = tag;
	
	[_formatField setStringValue:[choiceDict objectForKey:@"format"]];
	[_resolutionField setStringValue:CPLocalizedString([sizes objectAtIndex:[choiceDict objectForKey:@"resolution"]])];
	[_codecField setStringValue:CPLocalizedString([formats objectAtIndex:[choiceDict objectForKey:@"codec"]])];
	[_usageField setStringValue:[choiceDict objectForKey:@"usage"]];

}

-(void)presetSelected:(CPMenuItem)sender
{
	[self updateDisplayForTag:[sender tag]];	
}

- (void)showExportAlert
{
	var alert = [[CustomAlert alloc] init];
	var email = [[Session sharedSession] mail];
	[alert setMessageText:[CPString stringWithFormat:CPLocalizedString(@"MovieExportText"),email]];
	[alert setTitle:CPLocalizedString(@"Movie Export started")];
	[alert setDelegate:self];
	[alert setAlertStyle:CPInformationalAlertStyle];
	[alert addButtonWithTitle:@"Ok"];
	[alert runModal];
}

- (void)showRunningExportAlert:(int)number
{
	var alert = [[CPAlert alloc] init];
	var email = [[Session sharedSession] mail];
	[alert setMessageText:[CPString stringWithFormat:CPLocalizedString(@"RunningMovieExportText"),number]];
	[alert setTitle:CPLocalizedString(@"A Movie Export is already running")];
	[alert setDelegate:self];
	[alert setAlertStyle:CPInformationalAlertStyle];
	[alert addButtonWithTitle:@"Yes"];
	[alert addButtonWithTitle:@"No"];
	[alert runModal];
}

-(void)alertDidEnd:(CPAlert)theAlert returnCode:(int)returnCode
{
	if ([[theAlert title] isEqualToString:CPLocalizedString(@"A Movie Export is already running")])
	{
		if (returnCode == 0)
		{
			[self startExport:nil];
		}
	}
	else
	{
		[CPApp abortModal];
		[[self window] close];	
	}
}

- (void)movieQueueChecked:(CPNotification)aNotification
{
	var dict = [aNotification userInfo];
	var found = [dict objectForKey:@"found"];
	_queueEntries = [found intValue];
	if (_queueEntries > 0)
	{
		[_queueEntriesWarning setStringValue:[CPString stringWithFormat:CPLocalizedString(@"You are already running %d export task(s)"), _queueEntries]]; 
	}
	else
	{
		[_queueEntriesWarning setStringValue:@""]; 
	}
}

- (void)checkStartExport:(id)sender
{
	if (_queueEntries == 0)
	{
		[self startExport:sender];
	}
	else
	{
		[self showRunningExportAlert:_queueEntries];
	}
}

- (void)startExport:(id)sender
{
	if (!_error)
	{
		
		var choiceDict = [[[Session sharedSession] moviePresets] objectAtIndex:_activeTag];	
		var sizes = [[Session sharedSession] movieExportSizes];
		var formats = [[Session sharedSession] videoFormats];
		[[[Session sharedSession] exportSettings] setObject:[formats objectAtIndex:[choiceDict objectForKey:@"codec"]] forKey:@"videoFormat"];
		[[[Session sharedSession] exportSettings] setObject:[sizes objectAtIndex:[choiceDict objectForKey:@"resolution"]] forKey:@"exportSizeMovie"];
		[[[Session sharedSession] exportSettings] setObject:[_formatField stringValue] forKey:@"extension"];
		[[[Session sharedSession] exportSettings] setObject:[CPNumber numberWithBool:[_captions state] == CPOnState] forKey:@"showCaptionsByDefault"];
		
		
		CPLog(choiceDict);
		var components = [[sizes objectAtIndex:[choiceDict objectForKey:@"resolution"]] componentsSeparatedByString:@"x"];
		CPLog(@"components %@", components);
		if (components && [components count] == 2)
		{
			[[[Session sharedSession] exportSettings] setObject:[CPNumber numberWithInt:[[components objectAtIndex:0] intValue]] forKey:@"width"];
			[[[Session sharedSession] exportSettings] setObject:[CPNumber numberWithInt:[[components objectAtIndex:1] intValue]] forKey:@"height"];
		}
		[[ConnectionController sharedConnectionController] exportMovieProject];
		[self showExportAlert];
	}
}

- (void)cancelExport:(id)sender
{
	[CPApp abortModal];
	[[self window] close]; 
}

- (void)videoFormatSelected:(id)sender
{
	
}

- (void)exportSizeMovieSelected:(id)sender
{
	
}

@end
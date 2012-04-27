/*
 * ExportWebsiteView.j
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
@import "CPURLTextField.j"
@import <EKSpinner/EKSpinner.j>
@import "LPAnchorButton.j"
@import "Styles.j"

@implementation ExportWebsiteView : CPView
{
	CPButton _unpublish;
	CPButton _okButton;
	CPButton _cancelButton;
	CPPopUpButton _styleTemplate;
	CPImageView _stylePreview;
	CPCheckBox _showCaptionsByDefault; 
	CPCheckBox _autoPlay;
	CPCheckBox _loop;
	CPCheckBox _protect;
	CPFocusTextField _styleTemplateLabel;
	CPFocusTextField _slideShowSize;
	CPTextField _password;
	CPTextField _infotext;
	CPURLTextField _infourl;
	BOOL _error;
	BOOL _isPublished @accessors(property=isPublished);
	EKSpinner _spinner @accessors(property=spinner);
	CPTextField _spinnertext @accessors(property=spinnertext);
	LPAnchorButton _anchor @accessors(property=anchor);
}

- (id)initWithFrame:(CGRect)aRect
{
	self = [super initWithFrame:aRect];
	if (self) [self _initComponents:NO];
	return self;
}

- (id)initWithFrame:(CGRect)aRect forPublishedWebsite:(BOOL)isPublished
{
	self = [super initWithFrame:aRect];
	if (self) [self _initComponents:isPublished];
	return self;
}

- (void)_initComponents:(BOOL)isPublished
{
	_error = NO;
	_isPublished = isPublished;
	_styleTemplate = [[CPPopUpButton alloc] initWithFrame:CGRectMake(70, 10, 160, 24) pullsDown:NO];
	for (var i = 0; i < [[Styles allStyles] count]; i++)
	{
		var menuitem = [[CPMenuItem alloc] initWithTitle:[[[Styles allStyles] objectAtIndex:i] objectForKey:@"title"] action:@selector(styleTemplateSelected:) keyEquivalent:nil];
		[menuitem setTag:i];
		[menuitem setTarget:self];
		[_styleTemplate addItem:menuitem];
	}
	[_styleTemplate setTarget:self];
	[self addSubview:_styleTemplate];

	_styleTemplateLabel = [CPFocusTextField labelWithTitle:CPLocalizedString(@"Style")];
	[_styleTemplateLabel setFrame:CGRectMake(20, 10+4, 135, 24)];
	[_styleTemplateLabel setFocusField:_styleTemplate];
	[_styleTemplateLabel setValue:CPLeftTextAlignment forThemeAttribute:@"alignment"];
	[self addSubview:_styleTemplateLabel];

	_stylePreview = [[CPImageView alloc] initWithFrame:CGRectMake(350, 10, 200, 150)];
	[_stylePreview setHasShadow:YES];
	[_stylePreview setImageScaling:CPScaleProportionally];
	[self addSubview:_stylePreview];

	var yPos = 50;

	_autoPlay = [CPCheckBox checkBoxWithTitle:CPLocalizedString(@"Autoplay")];
	[_autoPlay setFrameOrigin:CGPointMake(20, yPos)];
	[self addSubview:_autoPlay];

	yPos += 24;
	_loop = [CPCheckBox checkBoxWithTitle:CPLocalizedString(@"Loop Slideshow")];
	[_loop setFrameOrigin:CGPointMake(20, yPos)];
	[self addSubview:_loop];
	
	yPos += 24;
	_showCaptionsByDefault = [CPCheckBox checkBoxWithTitle:CPLocalizedString(@"Show Captions")];
	[_showCaptionsByDefault setFrameOrigin:CGPointMake(20, yPos)];
	[self addSubview:_showCaptionsByDefault];
	
	yPos += 24;
	_protect = [CPCheckBox checkBoxWithTitle:CPLocalizedString(@"Protect Website with password")];
	[_protect setFrameOrigin:CGPointMake(20, yPos)];
	[self addSubview:_protect];

	_password = [CPTextField textFieldWithStringValue:@"" placeholder:@"" width:100];
	[_password setFrameOrigin:CGPointMake(220, yPos-6)];
	[self addSubview:_password];

	yPos += 24;
	var projectURL = ([[[CPBundle mainBundle] objectForInfoDictionaryKey:@"PublishFTP"] boolValue]) ? [[Session sharedSession] FTPDataURL] : [[CPBundle mainBundle] objectForInfoDictionaryKey:@"PublishURL"];

	_spinner = [[EKSpinner alloc] initWithFrame:CGRectMake(20, yPos, 18, 18) andStyle:@"medium_black"];
	[_spinner setIsSpinning:YES];
	[self addSubview:_spinner];

	_spinnertext = [CPTextField labelWithTitle:CPLocalizedString(@"")];
	[_spinnertext setFrame:CGRectMake(45, yPos, 250, 24)];
	[self addSubview:_spinnertext];
	
	[self hideSpinner];
	
	yPos += 20;

	_anchor = [LPAnchorButton buttonWithTitle:@""];
	[_anchor setFrame:CGRectMake(40,yPos,300,40)];
	[_anchor setValue:CPCenterTextAlignment forThemeAttribute:@"alignment"];
	[_anchor setValue:CPCenterVerticalTextAlignment forThemeAttribute:@"vertical-alignment"];

	var backgroundColor = [CPColor colorWithPatternImage:[[CPThreePartImage alloc] initWithImageSlices:
	[
		[[CPImage alloc] initWithContentsOfFile:@"Resources/box_threepart_01.png" size:CGSizeMake(15, 40)],
		[[CPImage alloc] initWithContentsOfFile:@"Resources/box_threepart_02.png" size:CGSizeMake(70, 40)],
		[[CPImage alloc] initWithContentsOfFile:@"Resources/box_threepart_03.png" size:CGSizeMake(15, 40)]
	] isVertical:NO]];
	[_anchor setBackgroundColor:backgroundColor];
	[_anchor setHidden:YES];
	[self addSubview:_anchor];
	if ([projectURL length] > 0)
	{
		[_anchor setTitle:projectURL];
		[_anchor openURLOnClick:[CPURL URLWithString:projectURL]];
		[_anchor setHidden:NO];
	}

	_cancelButton = [[CPButton alloc] initWithFrame:CGRectMake(234,220,98,24)];
	[_cancelButton setTitle:CPLocalizedString(@"Cancel")];
	[_cancelButton setTarget:self];
	[_cancelButton setAction:@selector(cancelExport:)];
	[self addSubview:_cancelButton];

	_unpublish = [[CPButton alloc] initWithFrame:CGRectMake(340,220,98,24)];
	[_unpublish setTitle:CPLocalizedString(@"Unpublish")];
	[_unpublish setTarget:self];
	[_unpublish setAction:@selector(unpublish:)];
	[self addSubview:_unpublish];

	_okButton = [[CPButton alloc] initWithFrame:CGRectMake(446,220,98,24)];
	[_okButton setTitle:CPLocalizedString(@"Publish")];
	[_okButton setTarget:self];
	[_okButton setDefaultButton:YES];
	[_okButton setAction:@selector(startExport:)];
	[self addSubview:_okButton];
	[self setData];
	[[self window] setDefaultButton:_okButton];

	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(projectPublished:) name:CPPublishedProjectViaFTP object:nil];
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(projectUnpublished:) name:CPUnpublishedProject object:nil];
}

- (void)showSpinnerWithText:(CPString)aText
{
	[_spinner setHidden:NO];
	[_spinnertext setHidden:NO];
	[_spinnertext setStringValue:aText];
}

- (void)hideSpinner
{
	[_spinner setHidden:YES];
	[_spinnertext setHidden:YES];
}

- (void)dealloc
{
	[[CPNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (void)setIsPublished:(BOOL)aPublished
{
	_isPublished = aPublished;
	[self setData];
}

- (void)setData
{
	var settings = [[Session sharedSession] exportSettings];
	var templateTag = 0;
	if ([settings objectForKey:@"selectedTemplate"]) {
		templateTag = [[settings objectForKey:@"selectedTemplate"] intValue];
	}
	[_styleTemplate selectItemWithTag:templateTag];
	[_showCaptionsByDefault setState:([[settings objectForKey:@"showCaptionsByDefault"] boolValue]) ? CPOnState : CPOffState];
	[_autoPlay setState:([[settings objectForKey:@"autoPlay"] boolValue]) ? CPOnState : CPOffState];
	[_loop setState:([[settings objectForKey:@"loop"] boolValue]) ? CPOnState : CPOffState];
	[_protect setState:([[settings objectForKey:@"protect"] boolValue]) ? CPOnState : CPOffState];
	[_password setStringValue:([settings objectForKey:@"password"])];
	if (_isPublished)
	{
		[_cancelButton setFrameOrigin:CGPointMake(234,220)];
		[_unpublish setHidden:NO];
		[_infotext setHidden:NO];
		if (_infourl) [_infourl setHidden:NO];
		[_okButton setTitle:CPLocalizedString(@"Republish")];
		var projectURL = ([[[CPBundle mainBundle] objectForInfoDictionaryKey:@"PublishFTP"] boolValue]) ? [[Session sharedSession] FTPDataURL] : [[CPBundle mainBundle] objectForInfoDictionaryKey:@"PublishURL"];
		var publishPath = [projectURL stringByAppendingString:[[Session sharedSession] project]];
		if ([projectURL length] > 0)
		{
			[[self anchor] setTitle:publishPath];
			[[self anchor] openURLOnClick:[CPURL URLWithString:publishPath]];
			[[self anchor] setHidden:NO];
		}
	}
	else
	{
		[_cancelButton setFrameOrigin:CGPointMake(340,220)];
		[_unpublish setHidden:YES];
		[_infotext setHidden:YES];
		if (_infourl) [_infourl setHidden:YES];
		[_okButton setTitle:CPLocalizedString(@"Publish")];
		[[self anchor] setHidden:YES];
	}
	[self setPreviewImage];
}

- (void)setPreviewImage
{
	var webroot = [[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] || @"/webroot/";
	var bundle = [CPBundle mainBundle];
	var image = [[CPImage alloc] initWithContentsOfFile:webroot + "themes/" + "default" + "/theme.jpg"];
	if (!image)
	{
		image = [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"nopreview.png"]];
	}
	[_stylePreview setImage:image];
}

- (void)sizeDidEndEditing:(id)sender
{
	
}

- (void)startExport:(id)sender
{
	[[self anchor] setHidden:YES];
	[self showSpinnerWithText:CPLocalizedString(@"Publishing project. Please wait...")];
	if (!_error)
	{
		var tag = [[_styleTemplate selectedItem] tag];
		[[[Session sharedSession] exportSettings] setObject:[CPNumber numberWithInt:tag] forKey:@"selectedTemplate"];
		[[[Session sharedSession] exportSettings] setObject:[[Styles allStyles] objectAtIndex:tag] forKey:@"styleTemplate"];
		[[[Session sharedSession] exportSettings] setObject:[CPNumber numberWithBool:[_showCaptionsByDefault state] == CPOnState] forKey:@"showCaptionsByDefault"];
		[[[Session sharedSession] exportSettings] setObject:[CPNumber numberWithBool:[_autoPlay state] == CPOnState] forKey:@"autoPlay"];
		[[[Session sharedSession] exportSettings] setObject:[CPNumber numberWithBool:[_loop state] == CPOnState] forKey:@"loop"];
		[[[Session sharedSession] exportSettings] setObject:[CPNumber numberWithBool:[_protect state] == CPOnState] forKey:@"protect"];
		[[[Session sharedSession] exportSettings] setObject:[_password stringValue] forKey:@"password"];
		if (_isPublished)
		{
			[[ConnectionController sharedConnectionController] republishProject];
		}
		else
		{
			[[ConnectionController sharedConnectionController] publishProject];
		}
	}
}

- (void)cancelExport:(id)sender
{
	[CPApp abortModal];
	[[self window] close]; 
}

- (void)styleTemplateSelected:(id)sender
{
	[self setPreviewImage];
}

- (void)unpublish:(id)sender
{
	[[ConnectionController sharedConnectionController] unpublishProject];
}

- (void)projectPublished:(CPNotification)aNotification
{
	var projectURL = ([[[CPBundle mainBundle] objectForInfoDictionaryKey:@"PublishFTP"] boolValue]) ? [[Session sharedSession] FTPDataURL] : [[CPBundle mainBundle] objectForInfoDictionaryKey:@"PublishURL"];
	[self hideSpinner];
	_isPublished = NO;
	if ([projectURL length] > 0)
	{
		_isPublished = YES;
	}
	[self setData];
}

- (void)projectUnpublished:(CPNotification)aNotification
{
	[self hideSpinner];
	_isPublished = NO;
	[self setData];
}

@end
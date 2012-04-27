/*
 * ExportHTMLView.j
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
@import "Styles.j"

@implementation ExportHTMLView : CPView
{
	CPButton _okButton;
	CPButton _cancelButton;
	CPPopUpButton _styleTemplate;
	CPImageView _stylePreview;
	CPCheckBox _showCaptionsByDefault; 
	CPCheckBox _autoPlay;
	CPCheckBox _loop;
	CPFocusTextField _styleTemplateLabel;
	CPFocusTextField _slideShowSize;
	BOOL _error;
}

- (id)initWithFrame:(CGRect)aRect
{
	self = [super initWithFrame:aRect];
	if (self)
	{
		_error = NO;

		_styleTemplate = [[CPPopUpButton alloc] initWithFrame:CGRectMake(70, 10, 160, 24) pullsDown:NO];
		
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
		[_styleTemplateLabel setFrame:CGRectMake(20, 10+4, 40, 24)];
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

		_cancelButton = [[CPButton alloc] initWithFrame:CGRectMake(340,220,98,24)];
		[_cancelButton setTitle:CPLocalizedString(@"Cancel")];
		[_cancelButton setTarget:self];
		[_cancelButton setAction:@selector(cancelExport:)];
		[self addSubview:_cancelButton];

		_okButton = [[CPButton alloc] initWithFrame:CGRectMake(446,220,98,24)];
		[_okButton setTitle:CPLocalizedString(@"Publish")];
		[_okButton setTarget:self];
		[_okButton setDefaultButton:YES];
		[_okButton setAction:@selector(startExport:)];
		[self addSubview:_okButton];
		[self setData];
		[[self window] setDefaultButton:_okButton];
	}
	return self;
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
	if (!_error)
	{
		var tag = [[_styleTemplate selectedItem] tag];
		[[[Session sharedSession] exportSettings] setObject:[CPNumber numberWithInt:tag] forKey:@"selectedTemplate"];
		[[[Session sharedSession] exportSettings] setObject:[[Styles allStyles] objectAtIndex:tag] forKey:@"styleTemplate"];
		[[[Session sharedSession] exportSettings] setObject:[CPNumber numberWithBool:[_showCaptionsByDefault state] == CPOnState] forKey:@"showCaptionsByDefault"];
		[[[Session sharedSession] exportSettings] setObject:[CPNumber numberWithBool:[_autoPlay state] == CPOnState] forKey:@"autoPlay"];
		[[[Session sharedSession] exportSettings] setObject:[CPNumber numberWithBool:[_loop state] == CPOnState] forKey:@"loop"];
		[[ConnectionController sharedConnectionController] exportProject];
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

@end
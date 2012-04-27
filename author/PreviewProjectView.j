/*
 * PreviewProjectView.j
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
@import <EKSpinner/EKSpinner.j>
@import "LPAnchorButton.j"

@implementation PreviewProjectView : CPView
{
	CPButton _cancelButton;
	EKSpinner _spinner @accessors(property=spinner);
	CPTextField _spinnertext @accessors(property=spinnertext);
	LPAnchorButton _anchor @accessors(property=anchor);
}

- (id)initWithFrame:(CGRect)aRect
{
	self = [super initWithFrame:aRect];
	if (self)
	{
		_spinner = [[EKSpinner alloc] initWithFrame:CGRectMake(40, 20, 18, 18) andStyle:@"medium_black"];
		[_spinner setIsSpinning:YES];
		[self addSubview:_spinner];

		_spinnertext = [CPTextField labelWithTitle:CPLocalizedString(@"")];
		[_spinnertext setFrame:CGRectMake(67, 20, 250, 24)];
		[self addSubview:_spinnertext];
		
		[self hideSpinner];
		
		_anchor = [LPAnchorButton buttonWithTitle:@""];
		[_anchor setFrame:CGRectMake(40,45,300,40)];
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
		
		_cancelButton = [[CPButton alloc] initWithFrame:CGRectMake(272,110,98,24)];
		[_cancelButton setTitle:CPLocalizedString(@"Close")];
		[_cancelButton setTarget:self];
		[_cancelButton setAction:@selector(cancelPreview:)];
		[self addSubview:_cancelButton];
		[[self window] setDefaultButton:_cancelButton];

		[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(previewCreated:) name:CPPreviewCreated object:nil];

		[self createPreview:self];

	}
	return self;
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

- (void)createPreview:(id)sender
{
	[[ConnectionController sharedConnectionController] createPreview];
	[[self anchor] setHidden:YES];
	[self showSpinnerWithText:CPLocalizedString(@"Generating preview. Please wait...")];
}

- (void)previewCreated:(CPNotification)aNotification
{
	[self hideSpinner];
	if ([[[aNotification userInfo] objectForKey:@"result"] boolValue])
	{
		[[self anchor] setTitle:CPLocalizedString(@"Click here to open a new preview window...")];
		[[self anchor] openURLOnClick:[CPURL URLWithString:[[Session sharedSession] previewPath]]];
		[[self anchor] setHidden:NO];
	}
}

- (void)cancelPreview:(id)sender
{
	[CPApp abortModal];
	[[self window] close]; 
}

@end
/*
 * WaitDialogController.j
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
@import <EKSpinner/EKSpinner.j>
@import "ConnectionController.j";

@implementation WaitDialogController : CPWindowController
{
	CPTextField _descriptionLabel;
	EKSpinner _spinner;
}

- (id)init
{
	mainRect = [[[CPApplication sharedApplication] mainWindow] frame];
	var theWindow = [[CPPanel alloc]
		initWithContentRect:CGRectMake(mainRect.size.width/2 - 150, mainRect.size.height/2 - 63, 300, 125) 
		styleMask:CPHUDBackgroundWindowMask];
        
	self = [super initWithWindow:theWindow];
    
	if (self)
	{
		[theWindow setDelegate:self];
		[theWindow setFloatingPanel:YES];
        
		var contentView = [theWindow contentView]

		_descriptionLabel = [[CPTextField alloc] initWithFrame:CGRectMake(10,10,280,60)];
		[_descriptionLabel setTextColor:[CPColor whiteColor]];
		[_descriptionLabel setValue:CPCenterTextAlignment forThemeAttribute:@"alignment"];
		[_descriptionLabel setFont:[CPFont systemFontOfSize:15.0]];
		[contentView addSubview:_descriptionLabel];

		_spinner = [[EKSpinner alloc] initWithFrame:CGRectMake(135, 80, 30, 30) andStyle:@"big_white"];
		[_spinner setIsSpinning:YES];
		[contentView addSubview:_spinner];
	}
    
	return self;
}

- (void)setLabel:(CPString)label
{
	[_descriptionLabel setStringValue:label];
}

-(BOOL)windowShouldClose:(id)window
{
	[_spinner setIsSpinning:NO];
	[[CPApplication sharedApplication] abortModal];
	[[self window] close]; 
	return true;
}

@end
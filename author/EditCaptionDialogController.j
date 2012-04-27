/*
 * EditCaptionDialogController.j
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

@implementation EditCaptionDialogController : CPWindowController
{
	CPButton _okButton;
	CPButton _cancelButton;
	CPTextField _caption;
	CPFocusTextField _captionLabel;
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

		_caption = [[CPTextField alloc] initWithFrame:CGRectMake(109,7,292,30)];
		[_caption setEditable:YES]; 
		[_caption setBordered:YES]; 
		[_caption setBezeled: YES]; 
		[_caption setBezelStyle:CPTextFieldSquareBezel] 
		[_caption setTarget:self]; 
		[_caption setSendsActionOnEndEditing:YES];
		[_caption setAction:@selector(editCaptionEnterPressed:)]; 
		[contentView addSubview:_caption];

		_captionLabel = [[CPFocusTextField alloc] initWithFrame:CGRectMake(16,11,89,25)];
		[_captionLabel setTextColor:[CPColor blackColor]];
		[_captionLabel setFocusField:_caption];
		[_captionLabel setStringValue:CPLocalizedString(@"Caption")];
		[contentView addSubview:_captionLabel];

		_cancelButton = [[CPButton alloc] initWithFrame:CGRectMake(193,61,98,24)];
		[_cancelButton setTitle:CPLocalizedString(@"Cancel")];
		[_cancelButton setTarget:self];
		[_cancelButton setAction:@selector(cancelEditCaption:)];
		[contentView addSubview:_cancelButton];

		_okButton = [[CPButton alloc] initWithFrame:CGRectMake(299,61,98,24)];
		[_okButton setTitle:CPLocalizedString(@"Save")];
		[_okButton setTarget:self];
		[_okButton setAction:@selector(setCaption:)];
		[contentView addSubview:_okButton];
		
		[self setData];

		[theWindow setDefaultButton:_okButton];
	}
    
	return self;
}

- (void)editCaptionEnterPressed:(id)sender
{
	[self setCaption:nil];
}

- (void)cancelEditCaption:(id)sender
{
	[CPApp abortModal];
	[[self window] close]; 
}

- (void)setCaption:(id)sender
{
	var index = [[Session sharedSession] imageIndex];
	slide = [[[Session sharedSession] slides] objectAtIndex:index];
	if ([[_caption stringValue] length] == 0)
	{
		[slide setObject:@"" forKey:@"caption"];
	}
	else
	{
		[slide setObject:[_caption stringValue] forKey:@"caption"];
	}
	[[ConnectionController sharedConnectionController] saveProject];
	[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationSlideUpdated object:nil]];
	[self cancelEditCaption:sender];
}

- (void)setData
{
	var index = [[Session sharedSession] imageIndex];
	slide = [[[Session sharedSession] slides] objectAtIndex:index];
	[_caption setStringValue:[slide objectForKey:@"caption"]];
	[[self window] makeFirstResponder:_caption];
}

-(BOOL)windowShouldClose:(id)window
{
	[self cancelEditCaption:self];
	return true;
}

@end
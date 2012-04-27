/*
 * NewProjectDialogController.j
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

@implementation NewProjectDialogController : CPWindowController
{
	CPButton _okButton;
	CPButton _cancelButton;
	CPTextField _descriptionLabel;
	CPTextField _projectName;
	CPTextField _projectNameLabel;
	CPString _oldTitle @accessors(property=oldTitle);
	CPString _actionButtonTitle @accessors(property=actionButtonTitle);
	CPString _windowTitle @accessors(property=windowTitle);
	CPString _windowText @accessors(property=windowText);
	CPNumber _projectId @accessors(property=projectId);

	SEL _action @accessors(property=action);

	bool _isError;
}

- (id)init
{
	 	theWindow = [[CPPanel alloc] initWithContentRect:CGRectMake(80, 80, 410, 125) styleMask:CPClosableWindowMask];
        
	self = [super initWithWindow:theWindow];
    
	if (self)
	{
		_isError = YES;
		[theWindow setDelegate:self];
		[theWindow setFloatingPanel:YES];
        
		var contentView = [theWindow contentView]

		_descriptionLabel = [[CPTextField alloc] initWithFrame:CGRectMake(16,8,410,25)];
		[_descriptionLabel setTextColor:[CPColor blackColor]];
		[_descriptionLabel setFont:[CPFont systemFontOfSize:15.0]];
		[contentView addSubview:_descriptionLabel];

		_projectNameLabel = [[CPTextField alloc] initWithFrame:CGRectMake(16,41,89,25)];
		[_projectNameLabel setTextColor:[CPColor blackColor]];
		[_projectNameLabel setStringValue:CPLocalizedString(@"Project name")];
		[contentView addSubview:_projectNameLabel];

		_projectName = [[CPTextField alloc] initWithFrame:CGRectMake(109,37,292,30)];
		[_projectName setEditable:YES]; 
		[_projectName setBordered:YES]; 
		[_projectName setBezeled: YES]; 
		[_projectName setBezelStyle:CPTextFieldSquareBezel] 
		[_projectName setDelegate:self]; 
		[_projectName setTarget:self]; 
		[_projectName setAction:@selector(enterPressed:)]; 
		[contentView addSubview:_projectName];

		_cancelButton = [[CPButton alloc] initWithFrame:CGRectMake(193,91,98,24)];
		[_cancelButton setTitle:CPLocalizedString(@"Cancel")];
		[_cancelButton setTarget:self];
		[_cancelButton setAction:@selector(cancelProject:)];
		[contentView addSubview:_cancelButton];

		_okButton = [[CPButton alloc] initWithFrame:CGRectMake(299,91,98,24)];
		[_okButton setTarget:self];
		[_okButton setAction:@selector(createProject:)];
		[_okButton setEnabled:YES];
		[contentView addSubview:_okButton];

		[theWindow makeFirstResponder:_projectName];
		[theWindow setDefaultButton:_okButton];

		[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(projectAdded:) name:CCNotificationProjectAdded object:nil];
		[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(projectExists:) name:CCNotificationProjectExists object:nil];
	}
    
	return self;
}

-(void)setWindowTitle:(CPString)text
{
	_windowTitle = text;
	[theWindow setTitle:_windowTitle];
}
-(void)setWindowText:(CPString)text
{
	_windowText = text;
	[_descriptionLabel setStringValue:_windowText];
}

-(void)setActionButtonTitle:(CPString)text
{
	_actionButtonTitle = text;
	[_okButton setTitle:_actionButtonTitle];
}

-(void)setOldTitle:(CPString)text
{
	_oldTitle = text;
	[_projectName setStringValue:_oldTitle];
}

-(void)setAction:(SEL)sel
{
	if (sel == @selector(addProject:)) {
		[_okButton setEnabled:NO];
	}
	
	_action = sel;
}

-(void)setProjectId:(CPNumber)aId
{
	_projectId = aId;
}

- (void)controlTextDidChange:(CPNotification)aNotification
{
	_isError = NO;
	if ([aNotification object] == _projectName)
	{
		if ([[_projectName stringValue] length] == 0) _isError = YES;
	}
	if (_isError)
	{
		[_okButton setEnabled:NO];
	}
	else
	{
		[_okButton setEnabled:YES];
	}
}

- (void)enterPressed:(id)sender
{
	if (!_isError) [self createProject:sender];
}

- (void)cancelProject:(id)sender
{
	[CPApp abortModal];
	[[self window] close]; 
}

- (void)createProject:(id)sender
{
	if ([[_projectName stringValue] length] == 0)
	{
		[_descriptionLabel setStringValue:_windowText];
		[_descriptionLabel setTextColor:[CPColor colorWithHexString:@"FF6347"]];
		[[self window] makeFirstResponder:_projectName];
	}
	else
	{
		var dict = [CPDictionary dictionaryWithObjectsAndKeys:[_projectName stringValue],@"projectname", _projectId,@"projectid"];
		[[ConnectionController sharedConnectionController] performSelector:_action withObject:dict];
	}
}

- (void)projectAdded:(CPNotification)aNotification
{
	var dict = [aNotification userInfo];
	[CPApp abortModal];
	[[self window] close]; 
	[[Session sharedSession] setProject:[dict objectForKey:@"project"]];
	[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CCNotificationProjectLoaded object:nil userInfo:dict]];
	[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationProjectDidLoad object:nil userInfo:nil]];
}

- (void)projectExists:(CPNotification)aNotification
{
	[_descriptionLabel setFont:[CPFont boldSystemFontOfSize:11.0]];
	[_descriptionLabel setTextColor:[CPColor colorWithHexString:@"FF6347"]];
	[_descriptionLabel setStringValue:CPLocalizedString(@"The project name already exists. Please choose another name.")];
//	[[self window] makeFirstResponder:_projectName];
}

-(BOOL)windowShouldClose:(id)window
{
	[self cancelProject:self];
	return true;
}

@end
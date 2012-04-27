/*
 * ExportProjectController.j
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
@import "Session.j"
@import "CPFocusTextField.j"
@import "PropertiesToolbar.j"
@import "ExportHTMLView.j"
@import "ExportMovieView.j"
@import "ExportWebsiteView.j"
@import "ConnectionController.j"

@implementation ExportProjectController : CPWindowController
{
	id _delegate @accessors(property=delegate);
	PropertiesToolbarView _toolbarView;
}

- (id)init
{
	var theWindow = [[CPPanel alloc] initWithContentRect:CGRectMake(80, 80, 560, 320) styleMask:CPClosableWindowMask];//+CPResizableWindowMask
	self = [super initWithWindow:theWindow];
    
	if (self)
	{
		_manageMode = NO;
		_error = NO;
		
		[theWindow setTitle:CPLocalizedString(@"Export Project")];
		[theWindow setDelegate:self];
		[theWindow setFloatingPanel:YES];
		[theWindow setAcceptsMouseMovedEvents:YES];

		[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(projectIsPublished:) name:CCNotificationProjectIsPublished object:nil];
		[[ConnectionController sharedConnectionController] isPublished];

		_toolbarView = [[PropertiesToolbarView alloc] initWithFrame:CGRectMakeZero(0,0,[theWindow frame].size.width,[theWindow frame].size.height)];
		var _toolbar = [_toolbarView toolbar];
		CPLog(@"MovieExport: %i",[[[CPBundle mainBundle] objectForInfoDictionaryKey:@"MovieExport"] intValue]);
		if ([[[CPBundle mainBundle] objectForInfoDictionaryKey:@"MovieExport"] intValue] == 1) {
			[_toolbar addButtonWithTag:@"movie" imageResource:@"export_movie.png" title:CPLocalizedString(@"Movie") associatedView:@"movie" target:self andAction:nil];
		}
		[_toolbar addButtonWithTag:@"website" imageResource:@"btn_website.png" title:CPLocalizedString(@"Website") associatedView:@"website" target:self andAction:nil];
		[_toolbar addButtonWithTag:@"html" imageResource:@"btn_zip.png" title:CPLocalizedString(@"ZIP") associatedView:@"html" target:self andAction:nil];
//		[_toolbar addButtonWithTag:@"youtube" imageResource:@"export_youtube.png" title:CPLocalizedString(@"YouTube") associatedView:@"youtube" target:self andAction:nil];
		
		var contentView = [[ExportHTMLView alloc] initWithFrame:CGRectMake(0,0,100,100)];
		[_toolbarView addView:contentView withTag:@"html"];
		
		if ([[[CPBundle mainBundle] objectForInfoDictionaryKey:@"MovieExport"] intValue] == 1) {
			var contentMovieView = [[ExportMovieView alloc] initWithFrame:CGRectMake(0,0,100,100)];
			[_toolbarView addView:contentMovieView withTag:@"movie"];
		}
		
		[theWindow setContentView:_toolbarView];
		[theWindow orderFront:self];
	}
	return self;
}

- (CPWindow)window
{
	[self projectIsPublished:nil];
	if ([[[CPBundle mainBundle] objectForInfoDictionaryKey:@"MovieExport"] intValue] == 1) {
		[[_toolbarView toolbar] selectButtonWithTag:@"movie"];
	} else {	
		[[_toolbarView toolbar] selectButtonWithTag:@"website"];
	}
	return [super window];
}

- (void)dealloc
{
	[[CPNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];

}

-(void)projectIsPublished:(CPNotification)aNotification
{
	if (![[Session sharedSession] hasCompletePublishSettings])
	{
		var existingview = [_toolbarView viewWithTag:@"website"];
		if (!existingview || [existingview class] != [CPView class])
		{
			[existingview removeFromSuperview];
			[existingview dealloc];
			existingview = nil;
			var contentSiteView = [[CPView alloc] initWithFrame:CGRectMake(0,0,100,100)];
			var label = [CPTextField labelWithTitle:CPLocalizedString(@"Please open the preferences window and enter the necessary settings for online publishing to be able to use website publishing.")];
			[label setFrame:CGRectMake(20, 20, 60, 60)];
			[label setFont:[CPFont systemFontOfSize:16.0]];
			[label setLineBreakMode:CPLineBreakByWordWrapping];
			[label setValue:CPCenterTextAlignment forThemeAttribute:@"alignment"];
			[label setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
			[contentSiteView addSubview:label];
			[_toolbarView addView:contentSiteView withTag:@"website"];
		}
	}
	else
	{
		CPLog(@"Is Published Notification info %@",[aNotification userInfo]);
		CPLog(@"Is Published Notification object %@",[aNotification object]);
		var existingview = [_toolbarView viewWithTag:@"website"];
		var isPublished = [[[aNotification userInfo] objectForKey:@"result"] boolValue];
		if (!existingview || [existingview class] != [ExportWebsiteView class])
		{
			[existingview removeFromSuperview];
			[existingview dealloc];
			existingview = nil;
			var contentSiteView = [[ExportWebsiteView alloc] initWithFrame:CGRectMake(0,0,100,100) forPublishedWebsite:isPublished];
			[_toolbarView addView:contentSiteView withTag:@"website"];
		}
		[existingview setIsPublished:isPublished];
	}
}

-(BOOL)windowShouldClose:(id)window
{
	[CPApp abortModal];
	[[self window] close]; 
	return true;
}

@end
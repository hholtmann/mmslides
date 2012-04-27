/*
 * GlobalPreferencesController.j
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
@import "GlobalPreferencesSlideshow.j"
@import "GlobalPreferencesPublishFTP.j"
@import "GlobalPreferencesPublishLocal.j"

@implementation GlobalPreferencesController : CPWindowController
{
	id _delegate @accessors(property=delegate);
	PropertiesToolbarView _toolbarView;
}

- (id)init
{
	var theWindow = [[CPPanel alloc] initWithContentRect:CGRectMake(80, 80, 560, 370) styleMask:CPClosableWindowMask];//+CPResizableWindowMask
	self = [super initWithWindow:theWindow];
    
	if (self)
	{
		_manageMode = NO;
		_error = NO;
		
		[theWindow setTitle:CPLocalizedString(@"Preferences")];
		[theWindow setDelegate:self];
		[theWindow setFloatingPanel:YES];

		_toolbarView = [[PropertiesToolbarView alloc] initWithFrame:CGRectMakeZero(0,0,[theWindow frame].size.width,[theWindow frame].size.height)];
		var _toolbar = [_toolbarView toolbar];
		[_toolbar addButtonWithTag:@"slideshow" imageResource:@"71_slideshow_settings.png" title:CPLocalizedString(@"Slideshow Settings") associatedView:@"slideshow" target:self andAction:nil];
//		[_toolbar addButtonWithTag:@"publish" imageResource:@"70_publish_settings.png" title:CPLocalizedString(@"Publish Settings") associatedView:@"publish" target:self andAction:nil];
		
		var slideshowView = [[GlobalPreferencesSlideshow alloc] initWithFrame:CGRectMake(0,0,100,100)];
		[_toolbarView addView:slideshowView withTag:@"slideshow"];
		/*
		if ([[[CPBundle mainBundle] objectForInfoDictionaryKey:@"PublishFTP"] boolValue] == YES)
		{
			var publishView = [[GlobalPreferencesPublishFTP alloc] initWithFrame:CGRectMake(0,0,100,100)];
			[_toolbarView addView:publishView withTag:@"publish"];
		}
		else
		{
			var publishView = [[GlobalPreferencesPublishLocal alloc] initWithFrame:CGRectMake(0,0,100,100)];
			[_toolbarView addView:publishView withTag:@"publish"];
		}
		*/
		[[_toolbarView toolbar] selectButtonWithTag:@"slideshow"];
		[theWindow setContentView:_toolbarView];
		[theWindow orderFront:self];
	}
	return self;
}

-(BOOL)windowShouldClose:(id)window
{
	[CPApp abortModal];
	[[self window] close]; 
	return true;
}

@end
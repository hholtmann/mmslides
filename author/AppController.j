/*
 * AppController.j
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


@import <Foundation/CPObject.j>
@import <Foundation/CPDictionary.j>
@import "CPBundle+Localization.j"
@import "PreviewView.j"
@import "PreviewContainer.j"
@import "PropertiesView.j"
@import "SlideCommandView.j"
@import "TimeLineView.j"
@import "AudioPlayer.j"
@import "Session.j"
@import "SmallToolbar.j"
@import "LoginDialogController.j"
@import "NewProjectDialogController.j"
@import "EditCaptionDialogController.j"
@import "EditSlideLengthDialogController.j"
@import "ConnectionController.j"
@import "OpenProjectDialogController.j"
@import "WaitDialogController.j"
@import "GlobalPreferencesController.j"
@import "TransitionInspector.j"
@import "ExportProjectController.j"
@import "AudioSettingsController.j"
@import "PreviewProjectController.j"
@import "ManageProjectsController.j"
@import "LostPasswordDialogController.j"

ToolbarProjectNew = @"ToolbarProjectNew";
ToolbarProjectOpen = @"ToolbarProjectOpen";
ToolbarProjectManage = @"ToolbarProjectManage";
ToolbarProjectPreview = @"ToolbarProjectPreview";
ToolbarProjectSave = @"ToolbarProjectSave";
ToolbarProjectExport = @"ToolbarProjectExport";
ToolbarSessionStatus = @"ToolbarSessionStatus";
ToolbarSlidesDistribute = @"ToolbarSlidesDistribute";
ToolbarPreferences = @"ToolbarPreferences";
ToolbarAudio = @"ToolbarAudio";
ToolbarUndo = @"ToolbarUndo";
ToolbarRedo = @"ToolbarRedo";
ToolbarHelp = @"ToolbarHelp";

var DownloadIFrame = null;
var DownloadSlotNext = null; 
var downloadURL = function downloadURL(url) 
{ 
	if (DownloadIFrame == null) 
	{
		DownloadIFrame = document.createElement("iframe"); 
		DownloadIFrame.style.position = "absolute"; 
		DownloadIFrame.style.top    = "-100px"; 
		DownloadIFrame.style.left   = "-100px"; 
		DownloadIFrame.style.height = "0px"; 
		DownloadIFrame.style.width  = "0px"; 
		document.body.appendChild(DownloadIFrame); 
	} 
	var now = new Date().getTime();
	var downloadSlot = (DownloadSlotNext && DownloadSlotNext > now)  ? DownloadSlotNext : now; 
	DownloadSlotNext = downloadSlot + 2000; 
	window.setTimeout(function() 
	{ 
		if (DownloadIFrame != null) 
			DownloadIFrame.src = [[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] + url; 
	}, downloadSlot - now); 
}

@implementation AppController : CPObject
{
	CPWindow    theWindow;
	CPView      mainView;
	LoginDialogController _loginController;
	LostPasswordDialogController _lostPasswordController;
	PreviewContainer _previewContainer;
	PreviewView previewView;
	PropertiesView propertiesView;
	SlideCommandView _slideCommandView;
	CPMutableDictionary _projects @accessors(property=projects);
	CPString _projectTitle @accessors(property=projectTitle);
	TimeLineView _timeLineView @accessors(property=timeLineView);
	SmallToolbar _toolbar;
	BOOL _isPlaying @accessors(readonly,property=isPlaying);
	AudioPlayer _audioPlayer @accessors(property=audioPlayer);
	WaitDialogController _waitController;
	CPTextField _timeLabel @accessors(property=timeLabel);
	ExportProjectController _exportProjectController;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
	theWindow = [[CPWindow alloc] initWithContentRect:CGRectMake(0,57,960,700) styleMask:CPBorderlessBridgeWindowMask | CPResizableWindowMask];
	[theWindow setAcceptsMouseMovedEvents:YES];
	[theWindow setMinSize:CGSizeMake(960,700)];
	[theWindow setMaxSize:CGSizeMake(2000,2000)];
	mainView = [theWindow contentView];
	[mainView setAutoresizesSubviews:YES];
	[mainView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
	[theWindow orderFront:self];
	[theWindow makeMainWindow];
	_isPlaying = NO;
	_projects = [CPMutableDictionary dictionary];
	// This is called when the application is done loading.
	[mainView setBackgroundColor:[CPColor colorWithHexString:@"dadada"]];
	_previewContainer = [[PreviewContainer alloc] initWithFrame:CGRectMake(10,10,527,435)];
	[_previewContainer setDelegate:self];
	previewView = [_previewContainer preview];
	[previewView setDelegate:self];
	[mainView addSubview:_previewContainer];
	_slideCommandView = [[SlideCommandView alloc] initWithFrame:CGRectMake(550,408,[mainView frame].size.width-560,37)];
//	[_slideCommandView setDelegate:[propertiesView slideView]];
	[mainView addSubview:_slideCommandView];

	propertiesView = [[PropertiesView alloc] initWithFrame:CGRectMake(550,10,[mainView frame].size.width-560,399)];
	[propertiesView setDelegate:self]
	[[propertiesView slideView] setCommandView:_slideCommandView];
	[mainView addSubview:propertiesView];
	
	[self setupToolbar];
	
	_timeLineView = [[TimeLineView alloc] initWithFrame:CPRectMake(10,458,[mainView frame].size.width-40,146)];
	[_timeLineView setDelegate:self];
	[mainView addSubview:_timeLineView];

	_timeLabel = [_previewContainer timeLabel];

	_audioPlayer = [[AudioPlayer alloc] initWithFrame:CPRectMakeZero()];
	[mainView addSubview:_audioPlayer];
	[_audioPlayer setDelegate:self];
	[_audioPlayer setProgressLabel:_timeLabel];

	[self setProjectTitle:nil];
	
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(slideUpdated:) name:CPNotificationSlideUpdated object:nil];
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(showWaitDialog:) name:CPNotificationShowWaitDialog object:nil];
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(hideWaitDialog:) name:CPNotificationHideWaitDialog object:nil];
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(_setAudio:) name:CPNotificationAudioFileLoaded object:nil];
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(lengthChanged:) name:CPNotificationLengthChanged object:nil];
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(projectAdded:) name:CCNotificationProjectAdded object:nil];
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(projectLoaded:) name:CCNotificationProjectLoaded object:nil];
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(projectListRetrieved:) name:CCNotificationProjectListRetrieved object:nil];
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(audioDeleted:) name:CCNotificationAudioDeleted object:nil];
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(initiateDownload:) name:CPExportFileCreated object:nil];
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(manageProjectDataRetrieved:) name:CCNotificationManageProjectDataRetrieved object:nil];
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(loginDidSucceed:) name:CPNotificationLoginSucceeded object:nil];
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(loginDisabled:) name:CPNotificationLoginDisabled object:nil];
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(loginDidFail:) name:CPNotificationLoginFailed object:nil];
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(registrationDidSucceed:) name:CPNotificationRegistrationSucceeded object:nil];
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(registrationPending:) name:CPNotificationRegistrationPending object:nil];
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(registrationDidFail:) name:CPNotificationRegistrationFailed object:nil];
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(lostPasswordDidSucceed:) name:CPNotificationLostPasswordSucceeded object:nil];
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(lostPasswordDidFail:) name:CPNotificationLostPasswordFailed object:nil];
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(lostPasswordCheckDidSucceed:) name:CPNotificationLostPasswordCheckSucceeded object:nil];
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(lostPasswordCheckDidFail:) name:CPNotificationLostPasswordCheckFailed object:nil];
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(changePasswordDidSucceed:) name:CPNotificationChangePasswordSucceeded object:nil];
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(changePasswordDidFail:) name:CPNotificationChangePasswordFailed object:nil];
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(updateToolbar:) name:CPNotificationToolbarUpdate object:nil];
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(redrawApplication:) name:CPNotificationRedrawApplication object:nil];
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(activateKenBurns:) name:CPNotificationActivateKenBurns object:nil];

	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(rulerMarkerDown:) name:CPNotificationRulerMarkerMouseDown object:nil];
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(rulerMarkerUp:) name:CPNotificationRulerMarkerMouseUp object:nil];

	[self hideControls];

	var parameters = [[[CPURL URLWithString:window.location.href] parameterString] componentsSeparatedByString:@"&"];
	var lostpasswordSession = @"";
	if ([parameters count])
	{
		for (i = 0; i < [parameters count]; i++)
		{
			if ([[[[parameters objectAtIndex:i] componentsSeparatedByString:@"="] objectAtIndex:0] isEqualToString:@"lostpassword"])
			{
				lostpasswordSession = [[[parameters objectAtIndex:i] componentsSeparatedByString:@"="] objectAtIndex:1];
				[[ConnectionController sharedConnectionController] checkLostPassword:[CPDictionary dictionaryWithObjectsAndKeys:lostpasswordSession,@"lostpasswordSession"]];
			}
		}
	}

	if (![[Session sharedSession] hasSID])
	{
		if (![lostpasswordSession length])
		{
			_loginController = [[LoginDialogController alloc] init];
			[_loginController setDelegate:self];
			[[CPApplication sharedApplication] runModalForWindow:[_loginController window]];
		}
	}
	else
	{
		[[ConnectionController sharedConnectionController] loadPreferences];
		[[ConnectionController sharedConnectionController] listProjects];
	}
}

- (void)lostPasswordDialog:(LostPasswordDialogController)aDialog changePassword:(CPString)aPassword forUserId:(CPString)aId
{
	[[ConnectionController sharedConnectionController] changePassword:[CPDictionary dictionaryWithObjectsAndKeys:aId,@"id",aPassword,@"password"]];
}

- (void)loginDialog:(LoginDialogController)aDialog didCallLoginWithUsername:(CPString)aUsername andPassword:(CPString)aPassword
{
	[[ConnectionController sharedConnectionController] login:[CPDictionary dictionaryWithObjectsAndKeys:aUsername,@"username",aPassword,@"password"]];
}

- (void)loginDialog:(LoginDialogController)aDialog didCallRegistrationWithUsername:(CPString)aUsername firstname:(CPString)firstname lastname:(CPString)lastname password:(CPString)aPassword organization:(CPString)aOrganization phone:(CPString)aPhone andEmail:(CPString)aEmail
{
	[[ConnectionController sharedConnectionController] registerAccount:[CPDictionary dictionaryWithObjectsAndKeys:aUsername,@"username",aPassword,@"password",aEmail,@"email",firstname,@"firstname",lastname,@"lastname",aOrganization,@"organization",aPhone,@"phone"]];
}

- (void)loginDialog:(LoginDialogController)aDialog didCallLostPassword:(CPString)aEmail
{
	[[ConnectionController sharedConnectionController] lostpassword:[CPDictionary dictionaryWithObjectsAndKeys:aEmail,@"email"]];
}

- (void)loginDidFail:(CPNotification)aNotification
{
	[_loginController setError:[[[aNotification userInfo] objectForKey:@"error"] intValue]];
}

- (void)lostPasswordCheckDidSucceed:(CPNotification)aNotification
{
	if ([aNotification userInfo] && [[aNotification userInfo] count])
	{
		_lostPasswordController = [[LostPasswordDialogController alloc] init];
		[_lostPasswordController setDelegate:self];
		[_lostPasswordController setLostPasswordData:[aNotification userInfo]];
		[[CPApplication sharedApplication] runModalForWindow:[_lostPasswordController window]];
	}
}

- (void)lostPasswordCheckDidFail:(CPNotification)aNotification
{
	// TODO: Check if user is able to retrieve lost password is failed. Alert would be nice
}

- (void)loginDisabled:(CPNotification)aNotification
{
	[_loginController closeDialog];
	[_loginController closeDialog];
	var alert = [[CPAlert alloc] init];
	[alert setTitle:CPLocalizedString(@"Login disabled / not approved")];
	[alert setMessageText:CPLocalizedString(@"The login has been disabled or is not approved yet.")];
	[alert setDelegate:self];
	[alert setAlertStyle:CPInformationalAlertStyle];
	[alert addButtonWithTitle:@"OK"];
	[alert runModal];
}

- (void)loginDidSucceed:(CPNotification)aNotification
{
	[_loginController closeDialog];
	[[ConnectionController sharedConnectionController] loadPreferences];
	[_toolbar setDelegate:nil];
	[_toolbar setDelegate:self];
	[[ConnectionController sharedConnectionController] listProjects];
}

- (void)lostPasswordDidFail:(CPNotification)aNotification
{
	[_loginController setError:[[[aNotification userInfo] objectForKey:@"error"] intValue]];
}

- (void)lostPasswordDidSucceed:(CPNotification)aNotification
{
	[_loginController closeDialog];
}

- (void)registrationDidFail:(CPNotification)aNotification
{
	[_loginController setError:[[[aNotification userInfo] objectForKey:@"error"] intValue]];
}

- (void)changePasswordDidSucceed:(CPNotification)aNotification
{
	[_lostPasswordController closeDialog];
}

- (void)changePasswordDidFail:(CPNotification)aNotification
{
	[_lostPasswordController setError:2];
}


- (void)registrationPending:(CPNotification)aNotification
{
	[_loginController closeDialog];
	var alert = [[CPAlert alloc] init];
	[alert setTitle:CPLocalizedString(@"Approval pending")];
	[alert setMessageText:CPLocalizedString(@"Registration successful! You can use your account, after it has been approved.")];
	[alert setDelegate:self];
	[alert setAlertStyle:CPInformationalAlertStyle];
	[alert addButtonWithTitle:@"OK"];
	[alert runModal];
}

-(void)alertDidEnd:(CPAlert)theAlert returnCode:(int)returnCode
{
		[CPApp abortModal];
}

- (void)registrationDidSucceed:(CPNotification)aNotification
{
	[_loginController closeDialog];
	[[ConnectionController sharedConnectionController] loadPreferences];
	[_toolbar setDelegate:nil];
	[_toolbar setDelegate:self];
	[[ConnectionController sharedConnectionController] listProjects];
}

- (void)initiateDownload:(CPNotification)aNotification
{
	var modalwindow = [CPApp modalWindow];
	if (modalwindow)
	{
		[CPApp abortModal];
		[modalwindow close]; 
	}
	CPLog(@"initiated download for url %@", [[aNotification userInfo] objectForKey:@"url"]);
	downloadURL([[aNotification userInfo] objectForKey:@"url"]);
}

-(void)lengthChanged:(CPNotification)aNotification
{
	[_timeLineView setLength];
	[_audioPlayer setAudioLength:[[Session sharedSession] slideShowLength]];
}

- (void)audioDeleted:(CPNotification)aNotification
{
	[[Session sharedSession] removeAudio];
	[_projects setObject:[aNotification userInfo] forKey:[[aNotification userInfo] objectForKey:@"id"]];
	[self _setAudio:aNotification];
}

-(void)_setAudio:(CPNotification)aNotification
{
	var webroot = [[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] || @"/webroot/";
	var audio = [[Session sharedSession] audio];
	if (audio)
	{
		var filename = webroot + [[Session sharedSession] projectPath] + [audio objectForKey:@"file"];
		[_audioPlayer setAudioPath:filename];
	}
	else
	{
		[_audioPlayer setAudioPath:nil];
		[_audioPlayer setAudioLength:[[Session sharedSession] slideShowLength]];
	}
	[_timeLineView setLength];
	[self updatePlayProgress:0];
}

-(void)slideUpdated:(CPNotification)aNotification
{
	[_timeLineView slidesChanged:aNotification];
}

- (void)projectAdded:(CPNotification)aNotification
{
	[self showControls];
	[self resetApplication];
	var dict = [aNotification userInfo];
	if (dict)
	{
		[_projects setObject:dict forKey:[dict objectForKey:@"id"]];
		[[Session sharedSession] setProject:[dict objectForKey:@"id"]];
		[[Session sharedSession] setData:dict];
		[[Session sharedSession] setKenBurns:NO];
		[previewView setNeedsDisplay:YES];
		[_timeLineView setLength];
		[[_timeLineView ruler] updateMarker];
		[[_timeLineView ruler] setMarkerToTimecode:0.0 updatePosition:YES];
		[self setProjectTitle:[dict objectForKey:@"project"]];
	}
}

- (void)projectLoaded:(CPNotification)aNotification
{
	var modalwindow = [CPApp modalWindow];
	if (modalwindow)
	{
		[CPApp abortModal];
		[modalwindow close]; 
	}
	var dict = [aNotification userInfo];
	if (dict)
	{
		[[Session sharedSession] setProject:[dict objectForKey:@"id"]];
		[[Session sharedSession] setData:dict];
	}
	
	[self setProjectTitle:[dict objectForKey:@"project"]];
	[self showControls];
	[_timeLineView setLength];
	[[_timeLineView ruler] updateMarker];
	[[_timeLineView ruler] setMarkerToTimecode:0.0 updatePosition:YES];
	if ([[Session sharedSession] imageIndex] >= 0)
	{
		[previewView setImage:[[Session sharedSession] imageForSlideAtIndex:[[Session sharedSession] imageIndex]]];
		[previewView showCaption:[[Session sharedSession] imageIndex]];
	} else {
		[previewView setImage:nil];		
		[previewView showCaption:0];
	}
}

- (void)setProjectTitle:(CPString)aTitle
{
	if (aTitle)
	{
		_projectTitle = aTitle;
		[[_previewContainer titleView] setHidden:NO];
		[[_previewContainer titleView] setTitle:_projectTitle];
	}
	else
	{
		_projectTitle = nil;
		[[_previewContainer titleView] setHidden:YES];
	}
	[_toolbar setDelegate:nil];
	[_toolbar setDelegate:self];
}

- (void)showWaitDialog:(CPNotification)aNotification
{
	if (!_waitController) _waitController = [[WaitDialogController alloc] init];
	[_waitController setLabel:[[aNotification userInfo] objectForKey:@"description"]];
	[[_waitController window] orderFront:self];
}

- (void)hideWaitDialog:(CPNotification)aNotification
{
	[[_waitController window] close]; 
	[self updateToolbar:nil];
}

- (void)setProjectList:(CPDictionary)projects
{
	_projects = projects;
}

- (void)projectListRetrieved:(CPNotification)aNotification
{
	CPLog(@"Got project list: %@",aNotification);
	if ([aNotification userInfo])
	{
		_projects = [aNotification userInfo];
		if ([_projects count] == 0)
		{
			[self newProjectAction:self];
		} else {
			[self displayProjectOpenWindow:self];
		}
	}
}

- (void)manageProjectDataRetrieved:(CPNotification)aNotification
{	
	CPLog(@"BEFORE CONTROLLER");
	controller = [[ManageProjectsController alloc] init];
	CPLog(@"INIT CONTROLLER");
	if ([aNotification userInfo])
	{
		CPLog(@"Passing userinfo %@",[aNotification userInfo]);
		[controller setFullArray:[aNotification userInfo]];
	}	
	[[CPApplication sharedApplication] runModalForWindow:[controller window]];

}

- (void)awakeFromCib
{
	// This is called when the cib is done loading.
	// You can implement this method on any object instantiated from a Cib.
	// It's a useful hook for setting up current UI values, and other things. 
}

-(void) setupToolbar
{
	_toolbar = [[SmallToolbar alloc] initWithIdentifier:"Toolbar"];
	[_toolbar setDelegate:self];
	[_toolbar setVisible:YES];
	[theWindow setToolbar:_toolbar];
}

-(void)showContextMenu:(id)sender
{
	CPLog(@"Called the menu");
	[TransitionInspector showInspector];
	[[sender superview] select];
//	[CPMenu popUpContextMenu:_slideContextMenu withEvent:[CPApp currentEvent] forView:mainView withFont:[CPFont systemFontOfSize:12.0]];
}

-(void)showTransitionInspector:(id)sender
{
	[TransitionInspector showInspector];
}

-(void)editCaption:(id)sender
{
	controller = [[EditCaptionDialogController alloc] init];
	[[CPApplication sharedApplication] runModalForWindow:[controller window]];
}

-(void)editSlideLength:(id)sender
{
	controller = [[EditSlideLengthDialogController alloc] init];
	[[CPApplication sharedApplication] runModalForWindow:[controller window]];
}

-(void)activateKenBurns:(id)sender
{
	[[Session sharedSession] setKenBurns:YES];
	[previewView redraw];
}

-(void)redrawApplication:(id)sender
{
	[previewView redraw];
	[propertiesView redraw];
}


-(void)rulerMarkerDown:(id)sender
{
	if (_audioPlayer && _isPlaying) {
		[_audioPlayer pause];
	}
}

-(void)rulerMarkerUp:(id)sender
{
	if (_audioPlayer && _isPlaying) {
		[_audioPlayer play];
	}
}


// ## Actions

- (void)undo:(id)sender
{
	[[Session sharedSession] undo];
}

- (void)redo:(id)sender
{
	[[Session sharedSession] redo];
}

- (void)help:(id)sender
{
	window.open("../docs/user_manual.pdf")
}

- (void)loginAction:(id)sender
{
	if (![[Session sharedSession] hasSID])
	{
		_loginController = [[LoginDialogController alloc] init];
		[_loginController setDelegate:self];
		[[CPApplication sharedApplication] runModalForWindow:[_loginController window]];
//		[[SCUserSessionManager defaultManager] login:self];
	}
	else
	{
		[self hideControls];
		[[Session sharedSession] logout];
		[self setProjectTitle:nil];
		[_toolbar setDelegate:nil];
		[_toolbar setDelegate:self];
		_projects = [CPMutableDictionary dictionary];
	}
}



- (void) updatePlayProgress:(float)time
{
	
	[[_timeLineView ruler] setMarkerToTimecode:time*1000.0 updatePosition:NO];
	[self _adjustScrollPosition:time];
	var percentage = [[Session sharedSession] percentageForSlideAtTimeCode:time*1000.0];
	CPLog(@"Set percentage to %@",percentage)
	[previewView setPercentage:percentage];
}


- (void)showImageAtIndex:(int)aIndex
{
	animate = ([_audioPlayer isPlaying]) ? YES : NO;
	if (!animate)
	{
		[self showImage:[[Session sharedSession] imageForSlideAtIndex:aIndex]];
		[[Session sharedSession] setImageIndex:aIndex withNotification:YES];
	}
	else
	{
		[previewView setImageFromIndex:[[Session sharedSession] imageIndex] toIndex:aIndex];
		[previewView showCaption:aIndex];
		[[Session sharedSession] setImageIndex:aIndex withNotification:NO];
	}
}

- (void)showImage:(CPImage)aImage
{
	[previewView setImage:aImage];
}

- (void)newProjectAction:(id)sender
{
	controller = [[NewProjectDialogController alloc] init];
	[controller setOldTitle:@""];
	[controller setActionButtonTitle:CPLocalizedString(@"Create")];
	[controller setWindowTitle:CPLocalizedString(@"New Project")];
	[controller setWindowText:CPLocalizedString(@"Please enter a name for the new project")];
	[controller setAction:@selector(addProject:)];
	[[CPApplication sharedApplication] runModalForWindow:[controller window]];
}

- (void)exportProjectAction:(id)sender
{
	if (!_exportProjectController)
	{
		_exportProjectController = [[ExportProjectController alloc] init];
	}
	else
	{
		[[ConnectionController sharedConnectionController] isPublished];
	}
	[[CPApplication sharedApplication] runModalForWindow:[_exportProjectController window]];
}

- (void)openProjectAction:(id)sender
{
	//controller = [[OpenProjectDialogController alloc] init];
	//[controller setDelegate:self];
	//[[CPApplication sharedApplication] runModalForWindow:[controller window]];
	
	[[ConnectionController sharedConnectionController] listProjects];

}

-(void)displayProjectOpenWindow:(id)sender
{
	controller = [[OpenProjectDialogController alloc] init];
	[controller setDelegate:self];
	[[CPApplication sharedApplication] runModalForWindow:[controller window]];
}

- (void)manageProjectsAction:(id)sender
{
	[[ConnectionController sharedConnectionController] manageProjects];

//	controller = [[ManageProjectsController alloc] init];
//	[[CPApplication sharedApplication] runModalForWindow:[controller window]];
}

- (void)previewProject:(id)sender
{
	if (_isPlaying) {
		[_previewContainer setPlayButton];
		[_audioPlayer pause];
		[[_timeLineView slides] setContextMenusEnabled:YES];
		_isPlaying = !_isPlaying;
	}
	controller = [[PreviewProjectController alloc] init];
	[[CPApplication sharedApplication] runModalForWindow:[controller window]];
	
//	[[ConnectionController sharedConnectionController] createPreview];
}

- (void)saveProjectAction:(id)sender
{
	[[ConnectionController sharedConnectionController] saveProject];
}

- (void)markerWasMovedToPosition:(double)aPosition
{	
	if (_audioPlayer && [_audioPlayer audioLength])
	{
		[_audioPlayer setCurrentTime:aPosition];
		[_timeLabel setStringValue:[CPString stringWithFormat:@"%02d:%02d.%d", aPosition/60, aPosition % 60, (aPosition * 10)%10]];
		var index = [[Session sharedSession] indexForSlideAtTimeCode:aPosition*1000.0];
		[[Session sharedSession] setImageIndex:index];
		[previewView setImageAtIndex:index];
		var percentage = [[Session sharedSession] percentageForSlideAtTimeCode:aPosition*1000.0];
		//	CPLog(@"percentage is %.2f", percentage);
		[previewView setPercentage:percentage];
	}
}

- (void)adjustScrollPositionFromSlider
{
	[self _adjustScrollPosition:[_audioPlayer currentTime]];
}

- (void)_adjustScrollPosition:(double)aPosition
{
	if ([_timeLineView magnification] > 1.0)
	{
		var scroll = [[[_timeLineView scrollview] contentView] bounds].origin.x;
		var xPosition = [[_timeLineView ruler] positionAtPointInTime:aPosition];
		if (xPosition < scroll || xPosition > scroll + [_timeLineView frame].size.width - 20)
		{
			var p = [[[_timeLineView scrollview] contentView] constrainScrollPoint:CGPointMake(xPosition,0)];
			[[[_timeLineView scrollview] contentView] scrollToPoint:p];
		}
	}
}

-(void)rewind:(id)sender
{
	[_previewContainer setPlayButton];
	[_audioPlayer pause];
	_isPlaying = NO;
	[[_timeLineView slides] setContextMenusEnabled:YES];
	[_audioPlayer setCurrentTime:0.0];
	[self updatePlayProgress:0];
	
}

-(void)playPause:(id)sender
{   
	_isPlaying = !_isPlaying;
	if (_isPlaying) 
	{
		[_previewContainer setPauseButton];
		[_audioPlayer play];
		if ([[Session sharedSession] imageIndex] >= 0)
			[previewView showCaption:[[Session sharedSession] imageIndex]];
		[[_timeLineView slides] setContextMenusEnabled:NO];
	} 
	else 
	{
		[_previewContainer setPlayButton];
		[_audioPlayer pause];
		[[_timeLineView slides] setContextMenusEnabled:YES];
	}
}

// ## CPToolbar delegate methods

- (CPArray)toolbarSelectableItemIdentifiers:(CPToolbar)aToolbar
{
	return [ToolbarProjectNew,ToolbarProjectOpen,ToolbarProjectManage,ToolbarProjectPreview,ToolbarProjectExport,ToolbarSlidesDistribute,ToolbarAudio,ToolbarSessionStatus,ToolbarUndo,ToolbarRedo];
}

- (CPArray)toolbarLogoutIdentifiers
{
	return [CPToolbarFlexibleSpaceItemIdentifier,ToolbarHelp,ToolbarSessionStatus];
}

- (CPArray)toolbarLoginIdentifiers
{
	return [ToolbarProjectNew,ToolbarProjectOpen,ToolbarProjectManage,ToolbarProjectPreview,ToolbarProjectExport,CPToolbarSeparatorItemIdentifier,ToolbarSlidesDistribute,ToolbarAudio,ToolbarPreferences,CPToolbarSeparatorItemIdentifier,ToolbarUndo,ToolbarRedo,CPToolbarFlexibleSpaceItemIdentifier,ToolbarHelp,ToolbarSessionStatus];
}

// Return an array of toolbar item identifier (all the toolbar items that may be present in the toolbar)
- (CPArray)toolbarAllowedItemIdentifiers:(CPToolbar)aToolbar
{
	if (![[Session sharedSession] hasSID])
	{
		return [self toolbarLogoutIdentifiers];
	}
	else
	{
		return [self toolbarLoginIdentifiers];
	}
}

// Return an array of toolbar item identifier (the default toolbar items that are present in the toolbar)
- (CPArray)toolbarDefaultItemIdentifiers:(CPToolbar)aToolbar
{
	if (![[Session sharedSession] hasSID])
	{
		return [self toolbarLogoutIdentifiers];
	}
	else
	{
		return [self toolbarLoginIdentifiers];
	}
}

- (CPToolbarItem)toolbar:(CPToolbar)aToolbar itemForItemIdentifier:(CPString)anItemIdentifier willBeInsertedIntoToolbar:(BOOL)aFlag
{
	var toolbarItem = [[CPToolbarItem alloc] initWithItemIdentifier:anItemIdentifier];
	var mainBundle = [CPBundle mainBundle];

	if (anItemIdentifier == ToolbarProjectNew)
	{
		var image = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"01_new_project.png"] size:CPSizeMake(32, 32)];
		var highlighted = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"01_new_project.png"] size:CPSizeMake(32, 32)];
		[toolbarItem setImage:image];
		[toolbarItem setAlternateImage:highlighted];
		[toolbarItem setTarget:self];
		[toolbarItem setAction:@selector(newProjectAction:)];
		[toolbarItem setLabel:CPLocalizedString(@"New Project")];
		[toolbarItem setMinSize:CGSizeMake(32,32)];
		[toolbarItem setMaxSize:CGSizeMake(32,32)];
	}
	else if (anItemIdentifier == ToolbarProjectOpen)
	{
		var image = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"02_open_project.png"] size:CPSizeMake(32, 32)];
		var highlighted = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"02_open_project.png"] size:CPSizeMake(32, 32)];

		[toolbarItem setImage:image];

		[toolbarItem setTarget:self];
		[toolbarItem setAction:@selector(openProjectAction:)];
		[toolbarItem setLabel:CPLocalizedString(@"Open Project")];

		[toolbarItem setMinSize:CGSizeMake(32,32)];
		[toolbarItem setMaxSize:CGSizeMake(32,32)];
	}
	else if (anItemIdentifier == ToolbarProjectManage)
	{
		var image = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"05_manage_projects.png"] size:CPSizeMake(32, 32)];
		var highlighted = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"05_manage_projects.png"] size:CPSizeMake(32, 32)];

		[toolbarItem setImage:image];

		[toolbarItem setTarget:self];
		[toolbarItem setAction:@selector(manageProjectsAction:)];
		[toolbarItem setLabel:CPLocalizedString(@"Manage Projects")];

		[toolbarItem setMinSize:CGSizeMake(32,32)];
		[toolbarItem setMaxSize:CGSizeMake(32,32)];
	}	
	else if (anItemIdentifier == ToolbarProjectPreview)
	{
		var image = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"03_preview.png"] size:CPSizeMake(32, 32)];
		var highlighted = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"03_preview.png"] size:CPSizeMake(32, 32)];

		[toolbarItem setImage:image];

		[toolbarItem setTarget:self];
		[toolbarItem setAction:@selector(previewProject:)];
		[toolbarItem setLabel:CPLocalizedString(@"Preview")];
		if (![[Session sharedSession] project])
		{
			[toolbarItem setEnabled:NO];
		}
		if (![[Session sharedSession] numberOfSlides])
		{
			[toolbarItem setEnabled:NO];
		}

		[toolbarItem setMinSize:CGSizeMake(32,32)];
		[toolbarItem setMaxSize:CGSizeMake(32,32)];
	}
	else if (anItemIdentifier == ToolbarProjectExport)
	{
		var image = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"04_publish_projects.png"] size:CPSizeMake(32, 32)];
		var highlighted = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"04_publish_projects.png"] size:CPSizeMake(32, 32)];

		[toolbarItem setImage:image];

		[toolbarItem setTarget:self];
		[toolbarItem setAction:@selector(exportProjectAction:)];
		[toolbarItem setLabel:CPLocalizedString(@"Export Project")];
		if (![[Session sharedSession] numberOfSlides])
		{
			[toolbarItem setEnabled:NO];
		}

		[toolbarItem setMinSize:CGSizeMake(32,32)];
		[toolbarItem setMaxSize:CGSizeMake(32,32)];
	}
	else if (anItemIdentifier == ToolbarSlidesDistribute)
	{
		if ([[Session sharedSession] project])
		{
			var image = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"07_distribute_slides.png"] size:CPSizeMake(32, 32)];
			var highlighted = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"07_distribute_slides.png"] size:CPSizeMake(32, 32)];

			[toolbarItem setImage:image];

			[toolbarItem setTarget:self];
			[toolbarItem setAction:@selector(distributeSlides:)];
			[toolbarItem setLabel:CPLocalizedString(@"Distribute slides")];
			if (![[Session sharedSession] numberOfSlides])
			{
				[toolbarItem setEnabled:NO];
			}

			[toolbarItem setMinSize:CGSizeMake(32,32)];
			[toolbarItem setMaxSize:CGSizeMake(32,32)];
		}
	}
	else if (anItemIdentifier == ToolbarAudio)
	{
		if ([[Session sharedSession] project])
		{
			var image = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"06_audio.png"] size:CPSizeMake(32, 32)];
			var highlighted = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"06_audio.png"] size:CPSizeMake(32, 32)];

			[toolbarItem setImage:image];

			[toolbarItem setTarget:self];
			[toolbarItem setAction:@selector(audioSettings:)];
			[toolbarItem setLabel:CPLocalizedString(@"Audio")];

			[toolbarItem setMinSize:CGSizeMake(32,32)];
			[toolbarItem setMaxSize:CGSizeMake(32,32)];
		}
	}
	else if (anItemIdentifier == ToolbarPreferences)
	{
		var image = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"08_global_preferences.png"] size:CPSizeMake(32, 32)];
		var highlighted = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"08_global_preferences.png"] size:CPSizeMake(32, 32)];

		[toolbarItem setImage:image];

		[toolbarItem setTarget:self];
		[toolbarItem setAction:@selector(preferences:)];
		[toolbarItem setLabel:CPLocalizedString(@"Preferences")];
		[toolbarItem setMinSize:CGSizeMake(32,32)];
		[toolbarItem setMaxSize:CGSizeMake(32,32)];
	}
	else if (anItemIdentifier == ToolbarSessionStatus)
	{
//		[toolbarItem setAlternateImage:highlighted];

		[toolbarItem setTarget:self];
		[toolbarItem setAction:@selector(loginAction:)];
		if ([[Session sharedSession] hasSID])
		{
			var image = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"09_logout.png"] size:CPSizeMake(32, 32)];
			var highlighted = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"09_logout.png"] size:CPSizeMake(32, 32)];
			[toolbarItem setImage:image];
			[toolbarItem setLabel:CPLocalizedString(@"Logout") + " (" + [[Session sharedSession] username] + ")"];
		}
		else
		{
			var image = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"09_login.png"] size:CPSizeMake(32, 32)];
			var highlighted = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"09_login.png"] size:CPSizeMake(32, 32)];
			[toolbarItem setImage:image];
			[toolbarItem setLabel:CPLocalizedString(@"Login")];
		}

		[toolbarItem setMinSize:CGSizeMake(32,32)];
		[toolbarItem setMaxSize:CGSizeMake(32,32)];
	}
	else if (anItemIdentifier == ToolbarUndo)
	{
		if ([[Session sharedSession] project])
		{
			var image = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"30_undo.png"] size:CPSizeMake(32, 32)];
			var highlighted = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"30_undo.png"] size:CPSizeMake(32, 32)];

			[toolbarItem setImage:image];

			[toolbarItem setTarget:self];
			[toolbarItem setAction:@selector(undo:)];
			[toolbarItem setLabel:CPLocalizedString(@"Undo")];
			if (![[Session sharedSession] undoAvailable])
			{
				[toolbarItem setEnabled:NO];
			}

			[toolbarItem setMinSize:CGSizeMake(32,32)];
			[toolbarItem setMaxSize:CGSizeMake(32,32)];
		}
	}
	else if (anItemIdentifier == ToolbarHelp)
	{
		var image = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"10_help.png"] size:CPSizeMake(32, 32)];
		var highlighted = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"10_help.png"] size:CPSizeMake(32, 32)];
		[toolbarItem setImage:image];
		[toolbarItem setTarget:self];
		[toolbarItem setAction:@selector(help:)];
		[toolbarItem setLabel:CPLocalizedString(@"Help")];
		[toolbarItem setMinSize:CGSizeMake(32,32)];
		[toolbarItem setMaxSize:CGSizeMake(32,32)];	
	} 
	else if (anItemIdentifier == ToolbarRedo)
	{
		if ([[Session sharedSession] project])
		{
			var image = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"31_redo.png"] size:CPSizeMake(32, 32)];
			var highlighted = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"31_redo.png"] size:CPSizeMake(32, 32)];

			[toolbarItem setImage:image];

			[toolbarItem setTarget:self];
			[toolbarItem setAction:@selector(redo:)];
			[toolbarItem setLabel:CPLocalizedString(@"Redo")];
			if (![[Session sharedSession] redoAvailable])
			{
				[toolbarItem setEnabled:NO];
			}

			[toolbarItem setMinSize:CGSizeMake(32,32)];
			[toolbarItem setMaxSize:CGSizeMake(32,32)];
		}
	}
	return toolbarItem;
}

- (void)updateToolbar:(id)sender
{
	[_toolbar _reloadToolbarItems];
}

- (void)resetApplication
{
	[propertiesView reset];
	[_audioPlayer reset];
	[_timeLineView reset];
	[previewView setImage:nil];
}

- (void)hideControls
{
	[_timeLineView setHidden:YES];
	[propertiesView setHidden:YES];
	[_slideCommandView setHidden:YES];
	[_previewContainer setHidden:YES];
}

- (void)showControls
{
	[_timeLineView setHidden:NO];
	[propertiesView setHidden:NO];
	[_slideCommandView setHidden:NO];
	[_previewContainer setHidden:NO];
}

- (void)distributeSlides:(id)sender
{
	var alert = [[CPAlert alloc] init];
	[alert setMessageText:CPLocalizedString(@"Do you really want to redistribute all slides over the current time? All slide durations will be reset to an equal value!")];
	[alert setTitle:CPLocalizedString(@"Distribute slides")];
	[alert setDelegate:self];
	[alert setAlertStyle:CPWarningAlertStyle];
	[alert addButtonWithTitle:@"Yes"];
	[alert addButtonWithTitle:@"No"];
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
	}
}


- (void)audioSettings:(id)sender
{
	controller = [[AudioSettingsController alloc] init];
	[[CPApplication sharedApplication] runModalForWindow:[controller window]];
}

- (void)preferences:(id)sender
{
	controller = [[GlobalPreferencesController alloc] init];
	[[CPApplication sharedApplication] runModalForWindow:[controller window]];
}

#pragma mark AudioPlayer delegate methods

-(void)audioLoaded:(id)sender
{
	[[_timeLineView ruler] updateMarker];
	[[_timeLineView ruler] setLength:[[Session sharedSession] slideShowLength]/1000.0];
	[[_timeLineView ruler] setMarkerToTimecode:0.0 updatePosition:YES];
}

- (void) playBackEnded:(id)sender
{
//	[self playPause:sender];
}
@end

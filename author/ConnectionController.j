/*
 * ConnectionController.j
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



@import <Foundation/CPURLRequest.j>
@import <Foundation/CPURLConnection.j>
@import "CKJSONKeyedArchiver.j"
@import "CKJSONKeyedUnarchiver.j"

var ConnectionControllerSharedInstance = nil;
var GenericErrorMessage = CPLocalizedString(@"Something went wrong. Check your internet connection and try again.");
var ConnectionStatusCode = -1;

CCCmdNone          = 0;
CCCmdAddProject    = 1;
CCCmdListProjects  = 2;
CCCmdSaveProject   = 3;
CCCmdLoadProject   = 4;
CCCmdDeleteImage   = 5;
CCCmdDeleteProject = 6;
CCCmdDeleteAudio   = 7;
CCCmdSavePreferences = 8;
CCCmdLoadPreferences = 9;
CCCmdExportProject = 10;
CCCmdCheckPublishedProject = 11;
CCCmdPublishProject = 12;
CCCmdUnpublishProject = 13;
CCCmdCreatePreview = 14;
CCCmdManageProjects  = 15;
CCCmdLogin  = 16;
CCCmdRegister  = 17;
CCCmdLostPassword  = 18;
CCCmdCheckLostPassword = 19;
CCCmdChangePassword = 20;
CCCmdSearchUsers = 21;
CCCmdAddTeamMember = 22;
CCCmdLoadTeamMembers = 23;
CCCmdDeleteTeamMember = 24;
CCCmdListSharedProjects  = 25;
CCCmdListProjectsReload = 26;
CCCmdRenameProject = 27;
CCCmdCopyProject = 28;
CCCmdUpdateSlideLengths = 29;
CCCmdExportMovieProject = 30;
CCCmdCheckMovieQueue = 31;

CCNotificationProjectAdded = @"CCNotificationProjectAdded";
CCNotificationProjectExists = @"CCNotificationProjectExists";
CCNotificationProjectListRetrieved = @"CCNotificationProjectListRetrieved";
CCNotificationManageProjectDataRetrieved = @"CCNotificationManageProjectDataRetrieved";
CCNotificationProjectLoaded = @"CCNotificationProjectLoaded";
CCNotificationProjectDeleted = @"CCNotificationProjectDeleted";
CCNotificationAudioDeleted = @"CCNotificationAudioDeleted";
CCNotificationProjectIsPublished = @"CCNotificationProjectIsPublished";

CPNotificationToolbarUpdate = @"CPNotificationToolbarUpdate";
CPNotificationAudioFileLoaded = @"CPNotificationAudioFileLoaded";
CPNotificationShowWaitDialog = @"CPNotificationShowWaitDialog";
CPNotificationHideWaitDialog = @"CPNotificationHideWaitDialog";
CPNotificationSlidesChanged = @"CPNotificationSlidesChanged";
CPNotificationProjectDidLoad = @"CPNotificationProjectDidLoad";
CPNotificationSlideUpdated = @"CPNotificationSlideUpdated";
CPNotificationSlideSelected = @"CPNotificationSlideSelected";
CPNotificationNoSlideSelected = @"CPNotificationNoSlideSelected";
CPNotificationForceSlideSelection = @"CPNotificationForceSlideSelection";
CPNotificationLengthChanged = @"CPNotificationLengthChanged";
CCNotificationPreferencesSaved = @"CCNotificationPreferencesSaved";
CPNotificationSlideProperties = @"CPNotificationSlideProperties";
CPNotificationLoginSucceeded = @"CPNotificationLoginSucceeded";
CPNotificationLoginDisabled = @"CPNotificationLoginDisabled";
CPNotificationLoginFailed = @"CPNotificationLoginFailed";
CPNotificationRegistrationSucceeded = @"CPNotificationRegistrationSucceeded";
CPNotificationRegistrationFailed = @"CPNotificationRegistrationFailed";
CPNotificationRegistrationPending = @"CPNotificationRegistrationPending";
CPNotificationLostPasswordSucceeded = @"CPNotificationLostPasswordSucceeded";
CPNotificationLostPasswordFailed = @"CPNotificationLostPasswordFailed";
CPNotificationLostPasswordCheckSucceeded = @"CPNotificationLostPasswordCheckSucceeded";
CPNotificationLostPasswordCheckFailed = @"CPNotificationLostPasswordCheckFailed";
CPNotificationChangePasswordSucceeded = @"CPNotificationChangePasswordSucceeded";
CPNotificationChangePasswordFailed = @"CPNotificationChangePasswordFailed";
CCNotificationSlideLengthUpdated = @"CCNotificationSlideLengthUpdated";
CPNotificationRedrawApplication = @"CPNotificationRedrawApplication";

//hh add
CPNotificationUserSearchSucceeded = @"CPNotificationUserSearchSucceeded";
CPNotificationUserSearchFailed = @"CPNotificationUserSearchFailed";
CPNotificationAddTeamMemberSucceeded = @"CPNotificationAddTeamMemberSucceeded";
CPNotificationAddTeamMemberFailed = @"CPNotificationAddTeamMemberFailed";
CPNotificationLoadTeamMembersSucceeded = @"CPNotificationLoadTeamMembersSucceeded";
CPNotificationLoadTeamMembersFailed = @"CPNotificationLoadTeamMembersFailed";
CPNotificationDeleteTeamMemberSucceeded = @"CPNotificationDeleteTeamMemberSucceeded";
CPNotificationDeleteTeamMemberFailed = @"CPNotificationDeleteTeamMemberFailed";
CCNotificationSharedProjectListSucceeded = @"CCNotificationSharedProjectListSucceeded";
CCNotificationSharedProjectListFailed = @"CCNotificationSharedProjectListFailed";
CCNotificationSharedProjectListSucceeded = @"CCNotificationSharedProjectListSucceeded";
CCNotificationSharedProjectListFailed = @"CCNotificationSharedProjectListFailed";
CCNotificationReloadProjectListSucceeded = @"CCNotificationReloadProjectListSucceeded";
CCNotificationReloadProjectListFailed = @"CCNotificationReloadProjectListSucceeded";
CCNotificationProjectRenameSucceeded = @"CCNotificationProjectRenameSucceeded";
CCNotificationProjectRenameFailed = @"CCNotificationProjectRenameFailed";
CCNotificationProjectCopySucceeded = @"CCNotificationProjectCopySucceeded";
CCNotificationProjectCopyFailed = @"CCNotificationProjectCopyFailed";
CPNotificationActivateKenBurns = @"CPNotificationActivateKenBurns";
CCNotificationMovieQueueFiles = @"CCNotificationMovieQueueFiles";

CPExportFileCreated = @"CPExportFileCreated";
CPPublishedProjectViaFTP = @"CPPublishedProjectViaFTP";
CPUnpublishedProject = @"CPUnpublishedProject";
CPPreviewCreated = @"CPPreviewCreated";

//
CPNotificationRulerMarkerMouseDown = @"CPNotificationRulerMarkerMouseDown";
CPNotificationRulerMarkerMouseUp = @"CPNotificationRulerMarkerMouseUp";



@implementation ConnectionController : CPObject
{
	CPURLConnection _projectConnection;
	CPURLConnection _userConnection;
	CPString _errorMessage;
	int _command;
	int _userConnectionCommand;
}

- (id)init
{
	self = [super init];
	_errorMessage = nil;
	_command = CCCmdNone;
	_userConnectionCommand = CCCmdNone;
	return self;
}

+ (ConnectionController)sharedConnectionController
{
	if (!ConnectionControllerSharedInstance) 
	{
		ConnectionControllerSharedInstance = [[ConnectionController alloc] init];
	}
	return ConnectionControllerSharedInstance;
}

- (void)addProject:(CPDictionary)dict
{
	[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationShowWaitDialog object:nil userInfo:[CPDictionary dictionaryWithObjectsAndKeys:CPLocalizedString(@"Loading. Please wait..."), @"description"]]];
	var projectObject = {'project' : [dict objectForKey:@"projectname"], 'cmd' : 'addProject', 'SID' : [[Session sharedSession] SID]};
	var request = [CPURLRequest requestWithURL:[[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] + @"project.php"];

	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[CPString JSONFromObject:projectObject]];
	_command = CCCmdAddProject;
	_projectConnection = [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void)deleteProject:(CPString)project
{
	var projectObject = {'projectid' : project, 'cmd' : 'deleteProject', 'SID' : [[Session sharedSession] SID]};
	var request = [CPURLRequest requestWithURL:[[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] + @"project.php"];

	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[CPString JSONFromObject:projectObject]];
	_command = CCCmdDeleteProject;
	_projectConnection = [CPURLConnection connectionWithRequest:request delegate:self];
}


- (void)renameProject:(CPDictionary)dict
{
	[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationShowWaitDialog object:nil userInfo:[CPDictionary dictionaryWithObjectsAndKeys:CPLocalizedString(@"Loading. Please wait..."), @"description"]]];
	var projectObject = {'project' : [dict objectForKey:@"projectname"], 'id': [dict objectForKey:@"projectid"], 'cmd' : 'renameProject', 'SID' : [[Session sharedSession] SID]};
	var request = [CPURLRequest requestWithURL:[[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] + @"project.php"];

	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[CPString JSONFromObject:projectObject]];
	_command = CCCmdRenameProject;
	_projectConnection = [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void)copyProject:(CPDictionary)dict
{
	[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationShowWaitDialog object:nil userInfo:[CPDictionary dictionaryWithObjectsAndKeys:CPLocalizedString(@"Loading. Please wait..."), @"description"]]];
	var projectObject = {'project' : [dict objectForKey:@"projectname"], 'id': [dict objectForKey:@"projectid"], 'cmd' : 'copyProject', 'SID' : [[Session sharedSession] SID]};
	var request = [CPURLRequest requestWithURL:[[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] + @"project.php"];

	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[CPString JSONFromObject:projectObject]];
	_command = CCCmdCopyProject;
	_projectConnection = [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void)deleteAudio
{
	var projectObject = {'cmd' : 'deleteAudio', 'SID' : [[Session sharedSession] SID]};
	var request = [CPURLRequest requestWithURL:[[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] + @"project.php"];

	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[CPString JSONFromObject:projectObject]];
	_command = CCCmdDeleteAudio;
	_projectConnection = [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void)updateSlideLengths
{
	var projectObject = {'cmd' : 'updateSlideLengths', 'data' : [[[Session sharedSession] data] toJSON], 'SID' : [[Session sharedSession] SID]};
	var request = [CPURLRequest requestWithURL:[[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] + @"project.php"];

	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[CPString JSONFromObject:projectObject]];
	
	_command = CCCmdUpdateSlideLengths;
	_projectConnection = [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void)removeSlidesAtPositions:(CPIndexSet)indexSet
{
	var selectionArray = [[CPArray alloc] init];
	var found = [indexSet getIndexes:selectionArray maxCount:[indexSet count] inIndexRange:CPMakeRange(0,[[[Session sharedSession] slides] count])];
	[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationShowWaitDialog object:nil userInfo:[CPDictionary dictionaryWithObjectsAndKeys:CPLocalizedString(@"Saving. Please wait..."), @"description"]]];
	
	var fileNameArray = [[CPArray alloc] init];
	
	for (var i=0;i<[selectionArray count];i++) {
		var index = [selectionArray objectAtIndex:i];
		var fileToDelete = [[[Session sharedSession] slides] objectAtIndex:index];		
		[fileNameArray addObject: [fileToDelete objectForKey:@"file"]];
	}
	
	[[[Session sharedSession] slides] removeObjectsAtIndexes:indexSet];
	var projectObject = {'cmd' : 'deleteImages', 'images' :fileNameArray, 'SID' : [[Session sharedSession] SID]};
	var request = [CPURLRequest requestWithURL:[[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] + @"project.php"];

	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[CPString JSONFromObject:projectObject]];
	
	CPLog(@"Delete Request: %@",[CPString JSONFromObject:projectObject]);
	_command = CCCmdDeleteImage;
	_projectConnection = [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void)saveProject
{
	[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationShowWaitDialog object:nil userInfo:[CPDictionary dictionaryWithObjectsAndKeys:CPLocalizedString(@"Saving. Please wait..."), @"description"]]];
	var projectObject = {'cmd' : 'saveProject', 'data' : [[[Session sharedSession] data] toJSON], 'SID' : [[Session sharedSession] SID]};
	var request = [CPURLRequest requestWithURL:[[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] + @"project.php"];

	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[CPString JSONFromObject:projectObject]];
	_command = CCCmdSaveProject;
	_projectConnection = [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void)checkMovieQueue
{
	[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationShowWaitDialog object:nil userInfo:[CPDictionary dictionaryWithObjectsAndKeys:CPLocalizedString(@"Checking. Please wait..."), @"description"]]];
	var projectObject = {'cmd' : 'checkMovieQueue', 'data' : [[[Session sharedSession] data] toJSON], 'SID' : [[Session sharedSession] SID]};
	var request = [CPURLRequest requestWithURL:[[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] + @"project.php"];

	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[CPString JSONFromObject:projectObject]];
	_command = CCCmdCheckMovieQueue;
	_projectConnection = [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void)isPublished
{
	[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationShowWaitDialog object:nil userInfo:[CPDictionary dictionaryWithObjectsAndKeys:CPLocalizedString(@"Saving. Please wait..."), @"description"]]];
	var projectObject;
	if ([[[CPBundle mainBundle] objectForInfoDictionaryKey:@"PublishFTP"] boolValue] == YES)
	{
		projectObject = {'cmd' : 'isPublished', 'data' : [[[Session sharedSession] data] toJSON], 'SID' : [[Session sharedSession] SID]};
	}
	else
	{
		projectObject = {'cmd' : 'isPublished', 'data' : [[[Session sharedSession] data] toJSON], 'serverpath' : [[CPBundle mainBundle] objectForInfoDictionaryKey:@"PublishFolder"] , 'SID' : [[Session sharedSession] SID]};
	}
	var request = [CPURLRequest requestWithURL:[[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] + @"project.php"];

	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[CPString JSONFromObject:projectObject]];
	_command = CCCmdCheckPublishedProject;
	CPLog(@"Check for published project");
	_projectConnection = [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void)createPreview
{	
	var projectObject = {'cmd' : 'createPreview', 'data' : [[[Session sharedSession] data] toJSON], 'SID' : [[Session sharedSession] SID]};
	var request = [CPURLRequest requestWithURL:[[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] + @"project.php"];

	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[CPString JSONFromObject:projectObject]];
	_command = CCCmdCreatePreview;
	_projectConnection = [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void)exportProject
{
	var projectObject = {'cmd' : 'exportProject', 'isMovie' : 0, 'data' : [[[Session sharedSession] exportSettings] toJSON], 'SID' : [[Session sharedSession] SID]};
	var request = [CPURLRequest requestWithURL:[[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] + @"project.php"];

	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[CPString JSONFromObject:projectObject]];
	_command = CCCmdExportProject;
	_projectConnection = [CPURLConnection connectionWithRequest:request delegate:self];
	
}

- (void)exportMovieProject
{
	var projectObject = {'cmd' : 'exportProject', 'isMovie' : 1, 'data' : [[[Session sharedSession] exportSettings] toJSON], 'SID' : [[Session sharedSession] SID]};
	var request = [CPURLRequest requestWithURL:[[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] + @"project.php"];

	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[CPString JSONFromObject:projectObject]];
	_command = CCCmdExportMovieProject;
	_projectConnection = [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void)unpublishProject
{
	[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationShowWaitDialog object:nil userInfo:[CPDictionary dictionaryWithObjectsAndKeys:CPLocalizedString(@"Saving. Please wait..."), @"description"]]];
	var projectObject;
	if ([[[CPBundle mainBundle] objectForInfoDictionaryKey:@"PublishFTP"] boolValue] == YES)
	{
		projectObject = {'cmd' : 'unpublishProject', 'data' : [[[Session sharedSession] exportSettings] toJSON], 'SID' : [[Session sharedSession] SID]};
	}
	else
	{
		projectObject = {'cmd' : 'unpublishProject', 'data' : [[[Session sharedSession] exportSettings] toJSON], 'serverpath' : [[CPBundle mainBundle] objectForInfoDictionaryKey:@"PublishFolder"] , 'SID' : [[Session sharedSession] SID]};
	}
	var request = [CPURLRequest requestWithURL:[[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] + @"project.php"];

	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[CPString JSONFromObject:projectObject]];
	_command = CCCmdUnpublishProject;
	_projectConnection = [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void)publishProject
{
//	[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationShowWaitDialog object:nil userInfo:[CPDictionary dictionaryWithObjectsAndKeys:CPLocalizedString(@"Saving. Please wait..."), @"description"]]];
	var projectObject;
	if ([[[CPBundle mainBundle] objectForInfoDictionaryKey:@"PublishFTP"] boolValue] == YES)
	{
		projectObject = {'cmd' : 'publishProject', 'data' : [[[Session sharedSession] exportSettings] toJSON], 'SID' : [[Session sharedSession] SID]};
	}
	else
	{
		projectObject = {'cmd' : 'publishProject', 'data' : [[[Session sharedSession] exportSettings] toJSON], 'serverpath' : [[CPBundle mainBundle] objectForInfoDictionaryKey:@"PublishFolder"] , 'SID' : [[Session sharedSession] SID]};
	}
	var request = [CPURLRequest requestWithURL:[[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] + @"project.php"];

	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[CPString JSONFromObject:projectObject]];
	_command = CCCmdPublishProject;
	_projectConnection = [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void)republishProject
{
//	[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationShowWaitDialog object:nil userInfo:[CPDictionary dictionaryWithObjectsAndKeys:CPLocalizedString(@"Saving. Please wait..."), @"description"]]];
	var projectObject;
	if ([[[CPBundle mainBundle] objectForInfoDictionaryKey:@"PublishFTP"] boolValue] == YES)
	{
		projectObject = {'cmd' : 'publishProject', 'data' : [[[Session sharedSession] exportSettings] toJSON], 'republish' : 1, 'SID' : [[Session sharedSession] SID]};
	}
	else
	{
		projectObject = {'cmd' : 'publishProject', 'data' : [[[Session sharedSession] exportSettings] toJSON], 'serverpath' : [[CPBundle mainBundle] objectForInfoDictionaryKey:@"PublishFolder"], 'republish' : 1 , 'SID' : [[Session sharedSession] SID]};
	}
	var request = [CPURLRequest requestWithURL:[[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] + @"project.php"];

	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[CPString JSONFromObject:projectObject]];
	_command = CCCmdPublishProject;
	_projectConnection = [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void)loadPreferences
{
	[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationShowWaitDialog object:nil userInfo:[CPDictionary dictionaryWithObjectsAndKeys:CPLocalizedString(@"Loading. Please wait..."), @"description"]]];
	var preferences = {'cmd' : 'loadPreferences', 'username' : [[Session sharedSession] username], 'SID' : [[Session sharedSession] SID]};
	var request = [CPURLRequest requestWithURL:[[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] + @"user.php"];

	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[CPString JSONFromObject:preferences]];
	_userConnectionCommand = CCCmdLoadPreferences;
	_userConnection = [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void)savePreferences
{
	[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationShowWaitDialog object:nil userInfo:[CPDictionary dictionaryWithObjectsAndKeys:CPLocalizedString(@"Saving. Please wait..."), @"description"]]];
	var preferences = {'cmd' : 'savePreferences', 'username' : [[Session sharedSession] username], 'data' : [[[Session sharedSession] preferences] toJSON], 'SID' : [[Session sharedSession] SID]};
	var request = [CPURLRequest requestWithURL:[[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] + @"user.php"];

	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[CPString JSONFromObject:preferences]];
	_userConnectionCommand = CCCmdSavePreferences;
	_userConnection = [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void)distributeSlidesAndLoadProject:(CPString)project
{
	[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationShowWaitDialog object:nil userInfo:[CPDictionary dictionaryWithObjectsAndKeys:CPLocalizedString(@"Loading. Please wait..."), @"description"]]];
	var projectObject = {'projectid' : project, 'cmd' : 'loadProject', 'distributeslides' : 1, 'SID' : [[Session sharedSession] SID]};
	var request = [CPURLRequest requestWithURL:[[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] + @"project.php"];

	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[CPString JSONFromObject:projectObject]];
	_command = CCCmdLoadProject;
	_projectConnection = [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void)loadProject:(CPString)project
{
	[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationShowWaitDialog object:nil userInfo:[CPDictionary dictionaryWithObjectsAndKeys:CPLocalizedString(@"Loading. Please wait..."), @"description"]]];
	var projectObject = {'projectid' : project, 'cmd' : 'loadProject', 'SID' : [[Session sharedSession] SID]};
	var request = [CPURLRequest requestWithURL:[[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] + @"project.php"];

	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[CPString JSONFromObject:projectObject]];
	_command = CCCmdLoadProject;
	_projectConnection = [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void)changePassword:(CPDictionary)dict
{
	[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationShowWaitDialog object:nil userInfo:[CPDictionary dictionaryWithObjectsAndKeys:CPLocalizedString(@"Checking. Please wait..."), @"description"]]];
	var projectObject = {'id' : [dict objectForKey:@"id"], 'password' : [dict objectForKey:@"password"], 'cmd' : 'changePassword' };
	var request = [CPURLRequest requestWithURL:[[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] + @"login.php"];

	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[CPString JSONFromObject:projectObject]];
	_userConnectionCommand = CCCmdChangePassword;
	_userConnection = [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void)checkLostPassword:(CPDictionary)dict
{
	[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationShowWaitDialog object:nil userInfo:[CPDictionary dictionaryWithObjectsAndKeys:CPLocalizedString(@"Checking. Please wait..."), @"description"]]];
	var projectObject = {'session' : [dict objectForKey:@"lostpasswordSession"], 'cmd' : 'checkLostPassword' };
	var request = [CPURLRequest requestWithURL:[[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] + @"login.php"];

	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[CPString JSONFromObject:projectObject]];
	_userConnectionCommand = CCCmdCheckLostPassword;
	_userConnection = [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void)login:(CPDictionary)userdata
{
	[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationShowWaitDialog object:nil userInfo:[CPDictionary dictionaryWithObjectsAndKeys:CPLocalizedString(@"Authorizing. Please wait..."), @"description"]]];
	var projectObject = {'username' : [userdata objectForKey:@"username"], 'password' : [userdata objectForKey:@"password"], 'cmd' : 'login' };
	var request = [CPURLRequest requestWithURL:[[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] + @"login.php"];

	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[CPString JSONFromObject:projectObject]];
	_userConnectionCommand = CCCmdLogin;
	_userConnection = [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void)registerAccount:(CPDictionary)userdata
{
	[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationShowWaitDialog object:nil userInfo:[CPDictionary dictionaryWithObjectsAndKeys:CPLocalizedString(@"Registering. Please wait..."), @"description"]]];
	var projectObject = {'username' : [userdata objectForKey:@"username"], 'password' : [userdata objectForKey:@"password"], 'organization': [userdata objectForKey:@"organization"], "phone":[userdata objectForKey:@"phone"],
						'firstname':[userdata objectForKey:@"firstname"],'lastname':[userdata objectForKey:@"lastname"],'email' : [userdata objectForKey:@"email"], 'cmd' : 'register', 'data' : [[[Session sharedSession] preferences] toJSON] };
	CPLog(@"Project "+[CPString JSONFromObject:projectObject]);			
	var request = [CPURLRequest requestWithURL:[[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] + @"login.php"];

	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[CPString JSONFromObject:projectObject]];
	_userConnectionCommand = CCCmdRegister;
	_userConnection = [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void)lostpassword:(CPDictionary)userdata
{
	[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationShowWaitDialog object:nil userInfo:[CPDictionary dictionaryWithObjectsAndKeys:CPLocalizedString(@"Sending password request. Please wait..."), @"description"]]];
	var projectObject = {'email' : [userdata objectForKey:@"email"], 'url' : [[window.location.href componentsSeparatedByString:@"?"] objectAtIndex:0], 'cmd' : 'lostpassword', 'subject' : CPLocalizedString('mail subject'), 'body' : CPLocalizedString('mail body') };
	var request = [CPURLRequest requestWithURL:[[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] + @"login.php"];

	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[CPString JSONFromObject:projectObject]];
	_userConnectionCommand = CCCmdLostPassword;
	_userConnection = [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void)listProjects
{
	[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationShowWaitDialog object:nil userInfo:[CPDictionary dictionaryWithObjectsAndKeys:CPLocalizedString(@"Loading. Please wait..."), @"description"]]];
	var projectObject = {'cmd' : 'listProjects', 'SID' : [[Session sharedSession] SID]};
	var request = [CPURLRequest requestWithURL:[[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] + @"project.php"];

	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[CPString JSONFromObject:projectObject]];
	_command = CCCmdListProjects;
	_projectConnection = [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void)manageProjects
{
	[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationShowWaitDialog object:nil userInfo:[CPDictionary dictionaryWithObjectsAndKeys:CPLocalizedString(@"Loading. Please wait..."), @"description"]]];
	var projectObject = {'cmd' : 'manageProjects', 'SID' : [[Session sharedSession] SID]};
	var request = [CPURLRequest requestWithURL:[[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] + @"project.php"];

	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[CPString JSONFromObject:projectObject]];
	_command = CCCmdManageProjects;
	_projectConnection = [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void)searchUsers:(CPString)searchString
{
	[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationShowWaitDialog object:nil userInfo:[CPDictionary dictionaryWithObjectsAndKeys:CPLocalizedString(@"Loading. Please wait..."), @"description"]]];
	var projectObject = {'cmd' : 'searchUsers', 'searchString' : searchString , 'SID' : [[Session sharedSession] SID]};
	var request = [CPURLRequest requestWithURL:[[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] + @"project.php"];

	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[CPString JSONFromObject:projectObject]];
	_command = CCCmdSearchUsers;
	_projectConnection = [CPURLConnection connectionWithRequest:request delegate:self];
}

-(void)addTeamMember:(CPDictionary)userData
{
	[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationShowWaitDialog object:nil userInfo:[CPDictionary dictionaryWithObjectsAndKeys:CPLocalizedString(@"Loading. Please wait..."), @"description"]]];
	var projectObject = {'cmd' : 'addTeamMember', 'userid' : [userData objectForKey:@"id"], 'projectid': [userData objectForKey:@"projectid"], 'SID' : [[Session sharedSession] SID]};
	var request = [CPURLRequest requestWithURL:[[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] + @"project.php"];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[CPString JSONFromObject:projectObject]];
	_command = CCCmdAddTeamMember;
	_projectConnection = [CPURLConnection connectionWithRequest:request delegate:self];	
}

-(void)loadTeamMembers:(int)projectid
{
	[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationShowWaitDialog object:nil userInfo:[CPDictionary dictionaryWithObjectsAndKeys:CPLocalizedString(@"Loading. Please wait..."), @"description"]]];
	var projectObject = {'cmd' : 'loadTeamMembers', 'projectid' : projectid, 'SID' : [[Session sharedSession] SID]};
	var request = [CPURLRequest requestWithURL:[[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] + @"project.php"];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[CPString JSONFromObject:projectObject]];
	_command = CCCmdLoadTeamMembers;
	_projectConnection = [CPURLConnection connectionWithRequest:request delegate:self];	
}

-(void)deleteTeamMember:(CPDictionary)userData
{
	[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationShowWaitDialog object:nil userInfo:[CPDictionary dictionaryWithObjectsAndKeys:CPLocalizedString(@"Loading. Please wait..."), @"description"]]];
	var projectObject = {'cmd' : 'deleteTeamMember', 'userid' : [userData objectForKey:@"userid"], 'projectid': [userData objectForKey:@"projectid"], 'SID' : [[Session sharedSession] SID]};
	var request = [CPURLRequest requestWithURL:[[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] + @"project.php"];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[CPString JSONFromObject:projectObject]];
	_command = CCCmdAddTeamMember;
	_projectConnection = [CPURLConnection connectionWithRequest:request delegate:self];	
}

- (void)listSharedProjects
{
	[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationShowWaitDialog object:nil userInfo:[CPDictionary dictionaryWithObjectsAndKeys:CPLocalizedString(@"Loading. Please wait..."), @"description"]]];
	var projectObject = {'cmd' : 'listSharedProjects', 'SID' : [[Session sharedSession] SID]};
	var request = [CPURLRequest requestWithURL:[[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] + @"project.php"];

	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[CPString JSONFromObject:projectObject]];
	_command = CCCmdListSharedProjects;
	_projectConnection = [CPURLConnection connectionWithRequest:request delegate:self];
}


- (void)reloadProjects
{
	[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationShowWaitDialog object:nil userInfo:[CPDictionary dictionaryWithObjectsAndKeys:CPLocalizedString(@"Loading. Please wait..."), @"description"]]];
	var projectObject = {'cmd' : 'listProjects', 'SID' : [[Session sharedSession] SID]};
	var request = [CPURLRequest requestWithURL:[[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] + @"project.php"];

	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[CPString JSONFromObject:projectObject]];
	_command = CCCmdListProjectsReload;
	_projectConnection = [CPURLConnection connectionWithRequest:request delegate:self];
}


- (void)_connectionFailedWithError:(CPString)errorMessageText statusCode:(int)statusCode
{
	_errorMessage = errorMessageText;
	CPLog(@"Error: %@", _errorMessage);
}

- (void)connection:(CPURLConnection)aConnection didFailWithError:(CPException)anException
{
	[self _connectionFailedWithError:[anException reason] statusCode:ConnectionStatusCode];
}

- (void)connection:(CPURLConnection)aConnection didReceiveData:(CPString)data
{
	CPLog(@"======>command %@",_command);
	switch(aConnection) 
	{
		case _userConnection:
			switch (_userConnectionCommand)
			{
				case CCCmdLogin:
					try
					{
						var result = JSON.parse(data);
						var dict = [CPDictionary dictionaryWithJSObject:result recursively:true];
						if ([dict objectForKey:@"error"])
						{
							[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationLoginFailed object:nil userInfo:dict]];
							[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationHideWaitDialog object:nil]];
						} else if ([dict objectForKey:@"disabled"]) {
							[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationLoginDisabled object:nil userInfo:dict]];
							[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationHideWaitDialog object:nil]];
						}else
						{
							[[Session sharedSession] setUsername:[dict objectForKey:@"username"]];
							[[Session sharedSession] setSID:[dict objectForKey:@"SID"]];
							[[Session sharedSession] setMail:[dict objectForKey:@"mail"]];
							[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationLoginSucceeded object:nil userInfo:nil]];
							[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationHideWaitDialog object:nil]];
						}
					}
					catch (e)
					{
					}
					break;
				case CCCmdRegister:
					try
					{
						var result = JSON.parse(data);
						var dict = [CPDictionary dictionaryWithJSObject:result recursively:true];
						if ([dict objectForKey:@"error"])
						{
							[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationRegistrationFailed object:nil userInfo:dict]];
							[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationHideWaitDialog object:nil]];
						} else if ([dict objectForKey:@"pending"]) {
							[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationRegistrationPending object:nil userInfo:dict]];
							[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationHideWaitDialog object:nil]];							
						} else {
							[[Session sharedSession] setUsername:[dict objectForKey:@"username"]];
							[[Session sharedSession] setSID:[dict objectForKey:@"SID"]];
							[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationRegistrationSucceeded object:nil userInfo:dict]];
							[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationHideWaitDialog object:nil]];
						}
					}
					catch (e)
					{
					}
					break;
				case CCCmdLostPassword:
					try
					{
						var result = JSON.parse(data);
						var dict = [CPDictionary dictionaryWithJSObject:result recursively:true];
						if ([dict objectForKey:@"error"])
						{
							[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationLostPasswordFailed object:nil userInfo:dict]];
							[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationHideWaitDialog object:nil]];
						}
						else
						{
							[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationLostPasswordSucceeded object:nil userInfo:dict]];
							[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationHideWaitDialog object:nil]];
						}
					}
					catch (e)
					{
					}
					break;
				case CCCmdChangePassword:
					try
					{
						var result = JSON.parse(data);
						var dict = [CPDictionary dictionaryWithJSObject:result recursively:true];
						if ([dict objectForKey:@"error"])
						{
							[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationLostPasswordFailed object:nil userInfo:dict]];
							[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationHideWaitDialog object:nil]];
						}
						else
						{
							[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationChangePasswordSucceeded object:nil userInfo:dict]];
							[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationHideWaitDialog object:nil]];
						}
					}
					catch (e)
					{
					}
					break;
				case CCCmdCheckLostPassword:
					try
					{
						var result = JSON.parse(data);
						var dict = [CPDictionary dictionaryWithJSObject:result recursively:true];
						if ([dict objectForKey:@"error"])
						{
							[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationLostPasswordCheckFailed object:nil userInfo:dict]];
							[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationHideWaitDialog object:nil]];
						}
						else
						{
							[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationLostPasswordCheckSucceeded object:nil userInfo:dict]];
							[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationHideWaitDialog object:nil]];
						}
					}
					catch (e)
					{
					}
					break;
				case CCCmdSavePreferences:
					break;
				case CCCmdLoadPreferences:
					try
					{
						var result = JSON.parse(data);
						dict = [CPDictionary dictionaryWithJSObject:result recursively:true];
						[[Session sharedSession] setPreferences:[dict objectForKey:@"preferences"]];
						[[Session sharedSession] setExportSettings:[dict objectForKey:@"exportSettings"]];
					}
					catch (e)
					{
					}
					break;
			}
			break;
		case _projectConnection:
			switch (_command)
			{
				case CCCmdAddProject:
					try
					{
						var result = JSON.parse(data);
						var dict = [CPDictionary dictionaryWithJSObject:result recursively:true];
						[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CCNotificationProjectAdded object:nil userInfo:dict]];
					}
					catch (e)
					{
					}
					break;
				case CCCmdCheckPublishedProject:
					try
					{
						var result = JSON.parse(data);
						dict = [CPDictionary dictionaryWithJSObject:result recursively:true];
						CPLog(@"======>CHECH CHECK %@",dict);
						[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CCNotificationProjectIsPublished object:self userInfo:dict]];
					}
					catch (e)
					{
						
					}
					break;
				case CCCmdUnpublishProject:
					try
					{
						var result = JSON.parse(data);
						dict = [CPDictionary dictionaryWithJSObject:result recursively:true];
						[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPUnpublishedProject object:nil userInfo:dict]];
					}
					catch (e)
					{
					}
					break;
				case CCCmdPublishProject:
					try
					{
						CPLog(@"======>Publish project");
						var result = JSON.parse(data);
						dict = [CPDictionary dictionaryWithJSObject:result recursively:true];
						[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPPublishedProjectViaFTP object:nil userInfo:dict]];
					}
					catch (e)
					{
					}
					break;
				case CCCmdCreatePreview:
					try
					{
						var result = JSON.parse(data);
						dict = [CPDictionary dictionaryWithJSObject:result recursively:true];
						[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPPreviewCreated object:nil userInfo:dict]];
					}
					catch (e)
					{
					}
					break;
				case CCCmdExportProject:
					try
					{
						var result = JSON.parse(data);
						dict = [CPDictionary dictionaryWithJSObject:result recursively:true];
						[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPExportFileCreated object:nil userInfo:dict]];
					}
					catch (e)
					{
					}
					break;
				case CCCmdExportMovieProject:
					try
					{
						var result = JSON.parse(data);
						dict = [CPDictionary dictionaryWithJSObject:result recursively:true];
					//	[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPExportFileCreated object:nil userInfo:dict]];
					}
					catch (e)
					{
					}
					break;	
				case CCCmdDeleteAudio:
					try
					{
						var result = JSON.parse(data);
						dict = [CPDictionary dictionaryWithJSObject:result recursively:true];
						[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CCNotificationAudioDeleted object:nil userInfo:dict]];
						[[Session sharedSession] purgeUndoData];
					}
					catch (e)
					{
					}
					break;
				case CCCmdUpdateSlideLengths:
					try
					{
						var result = JSON.parse(data);
						dict = [CPDictionary dictionaryWithJSObject:result recursively:true];
						[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CCNotificationSlideLengthUpdated object:nil userInfo:dict]];
					}
					catch (e)
					{
					}
					break;
				case CCCmdDeleteProject:
					try
					{
						var result = JSON.parse(data);
						dict = [CPDictionary dictionaryWithJSObject:result recursively:true];
						[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CCNotificationProjectDeleted object:nil userInfo:[dict objectForKey:@"data"]]];
					}
					catch (e)
					{
					}
					break;
				case CCCmdListProjects:
					try
					{
						var result = JSON.parse(data);
						dict = [CPDictionary dictionaryWithJSObject:result recursively:true];
						[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CCNotificationProjectListRetrieved object:nil userInfo:dict]];
					}
					catch(e){
						//var app = [CPApp delegate];
						//[app openLoginWindow];
					}
					break;
					
				case CCCmdManageProjects:
					try
					{
						var result = JSON.parse(data);
						dict = [CPDictionary dictionaryWithJSObject:result recursively:true];
						[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CCNotificationManageProjectDataRetrieved object:nil userInfo:[dict objectForKey:@"data"]]];
					}
					
					catch(e){
						//var app = [CPApp delegate];
						//[app openLoginWindow];
					}
					break;		
				case CCCmdDeleteImage:
					try
					{
						var result = JSON.parse(data);
						var dict = [CPDictionary dictionaryWithJSObject:result recursively:true];
						[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationSlidesChanged object:nil userInfo:nil]];
						[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationHideWaitDialog object:nil]];
						[[Session sharedSession] purgeUndoData];
					}
					catch(e){
						//var app = [CPApp delegate];
						//[app openLoginWindow];
					}
					break;
				case CCCmdCheckMovieQueue:
					try
					{
						var result = JSON.parse(data);
						var dict = [CPDictionary dictionaryWithJSObject:result recursively:true];
						[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CCNotificationMovieQueueFiles object:nil userInfo:dict]];
					}
					catch(e)
					{
						//var app = [CPApp delegate];
						//[app openLoginWindow];
					}
					break;
				case CCCmdLoadProject:
					try
					{
						var result = JSON.parse(data);
						var dict = [CPDictionary dictionaryWithJSObject:result recursively:true];
						[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CCNotificationProjectLoaded object:nil userInfo:dict]];
						[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationAudioFileLoaded object:nil userInfo:nil]];
						[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationProjectDidLoad object:nil userInfo:nil]];
						[[Session sharedSession] purgeUndoData];
					}
					catch(e){
						//var app = [CPApp delegate];
						//[app openLoginWindow];
					}
					break;
				case CCCmdSearchUsers:
					try
					{
						var result = JSON.parse(data);
						CPLog(data)
						var dict = [CPDictionary dictionaryWithJSObject:result recursively:true];
						[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationUserSearchSucceeded object:nil userInfo:dict]];
						[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationHideWaitDialog object:nil]];
					}
					catch(e){
						//var app = [CPApp delegate];
						//[app openLoginWindow];
					}
					break;	
				case CCCmdAddTeamMember:
					try
					{
						var result = JSON.parse(data);
						CPLog(result)
						var dict = [CPDictionary dictionaryWithJSObject:result recursively:true];
						[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationAddTeamMemberSucceeded object:nil userInfo:dict]];
						[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationHideWaitDialog object:nil]];
					}
					catch(e){
						//var app = [CPApp delegate];
						//[app openLoginWindow];
					}
					break;	
				case CCCmdLoadTeamMembers:
					try
					{
						var result = JSON.parse(data);
						CPLog(result)
						var dict = [CPDictionary dictionaryWithJSObject:result recursively:true];
						[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationLoadTeamMembersSucceeded object:nil userInfo:dict]];
						[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationHideWaitDialog object:nil]];
					}
					catch(e){
						//var app = [CPApp delegate];
						//[app openLoginWindow];
					}
					break;	
					
				case CCCmdDeleteTeamMember:
					try
					{
						var result = JSON.parse(data);
						CPLog(result)
						var dict = [CPDictionary dictionaryWithJSObject:result recursively:true];
						[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationDeleteTeamMemberSucceeded object:nil userInfo:dict]];
						[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationHideWaitDialog object:nil]];
					}
					catch(e){
						//var app = [CPApp delegate];
						//[app openLoginWindow];
					}
					break;
					
				case CCCmdListSharedProjects:
					try
					{
						var result = JSON.parse(data);
						dict = [CPDictionary dictionaryWithJSObject:result recursively:true];
						[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CCNotificationSharedProjectListSucceeded object:nil userInfo:dict]];
					}
					catch(e){
						//var app = [CPApp delegate];
						//[app openLoginWindow];
					}
					break;
					
				case CCCmdListProjectsReload:
					try
					{
						var result = JSON.parse(data);
						dict = [CPDictionary dictionaryWithJSObject:result recursively:true];
						[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CCNotificationReloadProjectListSucceeded object:nil userInfo:dict]];
					}
					catch(e){
						//var app = [CPApp delegate];
						//[app openLoginWindow];
					}
					break;
				case CCCmdRenameProject:
					try
					{
						var result = JSON.parse(data);
						var dict = [CPDictionary dictionaryWithJSObject:result recursively:true];
						[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CCNotificationProjectRenameSucceeded object:nil userInfo:[dict objectForKey:@"data"]]];
					}
					catch (e)
					{
					}
					break;
				case CCCmdCopyProject:
					try
					{
						var result = JSON.parse(data);
						var dict = [CPDictionary dictionaryWithJSObject:result recursively:true];
						[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CCNotificationProjectCopySucceeded object:nil userInfo:[dict objectForKey:@"data"]]];
					}
					catch (e)
					{
					}
					break;	
			}
			break;
	}
	[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationHideWaitDialog object:nil]];
}

- (void)connection:(CPURLConnection)aConnection didReceiveResponse:(CPURLResponse)aResponse
{
	if (![aResponse isKindOfClass:[CPHTTPURLResponse class]]) 
	{
		switch (aConnection) 
		{
			case _projectConnection:
				[self _connectionFailedWithError:GenericErrorMessage statusCode:ConnectionStatusCode];
				break;
			default:
				[self _connectionFailedWithError:GenericErrorMessage statusCode:ConnectionStatusCode];
				break;
		}
		return;
	}
  
	var statusCode = [aResponse statusCode];
	switch(aConnection) 
	{
		case _userConnection:
			if (statusCode === 200)  
			{
				switch (_userConnectionCommand)
				{
					case CCCmdLoadPreferences:
						break;
					case CCCmdSavePreferences:
						[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CCNotificationPreferencesSaved object:nil]];
						break;
				}
			}
			[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationHideWaitDialog object:nil]];
			break;
		case _projectConnection:
			if (statusCode === 200)  
			{
				_errorMessage = nil;
				switch (_command)
				{
					case CCCmdSaveProject:
						[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationHideWaitDialog object:nil]];
						break;
					case CCCmdPublishProject:
					case CCCmdUnpublishProject:
					case CCCmdExportProject:
					case CCCmdCreatePreview:
					case CCCmdDeleteAudio:
					case CCCmdCheckPublishedProject:
					case CCCmdAddProject:
					case CCCmdDeleteImage:
					case CCCmdDeleteProject:
					case CCCmdLoadProject:
					case CCCmdCheckMovieQueue:
					case CCCmdListProjects:
						[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationHideWaitDialog object:nil]];
						break;
					case CCCmdManageProjects:
						[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationHideWaitDialog object:nil]];
						break;	
						
				}
			}
			else 
			{
				if (statusCode === 403) 
				{
					switch (_userConnectionCommand)
					{
						case CCCmdLogin:
							[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationLoginFailed object:nil userInfo:nil]];
							break;
						case CCCmdRegister:
							[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationRegistrationFailed object:nil userInfo:nil]];
							break;
						case CCCmdLostPassword:
							[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationLostPasswordFailed object:nil userInfo:nil]];
							break;
						case CCCmdCheckLostPassword:
							[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationLostPasswordCheckFailed object:nil userInfo:nil]];
							break;
						case CCCmdChangePassword:
							[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationChangePasswordFailed object:nil userInfo:nil]];
							break;
					}
					switch (_command)
					{
						case CCCmdAddProject:
							[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CCNotificationProjectExists object:nil]];
							break;
						case CCCmdRenameProject:
							[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CCNotificationProjectExists object:nil]];
							break;
						case CCCmdCopyProject:
							[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CCNotificationProjectExists object:nil]];
							break;		
					}
				}
				[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationHideWaitDialog object:nil]];
			}
	}
}

@end
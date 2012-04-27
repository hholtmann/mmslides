/*
 * OpenProjectDialogController.j
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
@import <AppKit/CPWindowController.j>
@import <AppKit/CPScrollView.j>
@import <AppKit/CPTableView.j>
@import <AppKit/CPTableColumn.j>
@import <AppKit/CPRadio.j>
@import "CKJSONKeyedUnarchiver.j"
@import "CPDateHelper.j"
@import "ConnectionController.j"
@import "OpenProjectColumnView.j"
@import "CPFocusTextField.j"

@implementation CPColor (MMSlides)

+ (CPColor)selectionColor
{
	return [CPColor colorWithHexString:@"3875d7"];
}

@end

@implementation CPTableView (mousedown)

- (void)mouseDown:(CPEvent)anEvent
{
	if([anEvent type] == CPLeftMouseDown  &&  [anEvent clickCount] == 2)
		[self sendAction:_doubleAction to:_target];
	else [self trackMouse:anEvent];
}

@end

@implementation OpenProjectDialogController : CPWindowController
{
	CPButton _manageButton;
	CPButton _okButton;
	CPButton _cancelButton;
	CPScrollView _scrollview;
	CPFocusTextField _sharedLabel;
	CPFocusTextField _ownLabel;
	CPRadio _ownRadio;
	CPRadio _sharedRadio;
	CPTableView _tableview;
	CPImageView _projectPreview;
	CPTextField _projectLabel;
	CPTextField _createdLabel;
	CPTextField _lastchangeLabel;
	CPImage _deleteImage;
	int _deleteIndex;
	id _delegate @accessors(property=delegate);
	BOOL _manageMode @accessors(property=manageMode);
}

- (id)init
{
	var theWindow = [[CPPanel alloc] initWithContentRect:CGRectMake(80, 80, 600, 410) styleMask:CPClosableWindowMask];
	self = [super initWithWindow:theWindow];
    
	if (self)
	{
		_manageMode = NO;
		
		[theWindow setTitle:CPLocalizedString(@"Open Project")];
		[theWindow setDelegate:self];
		[theWindow setFloatingPanel:YES];

		var contentView = [theWindow contentView]

		_projectPreview = [[CPImageView alloc] initWithFrame:CGRectMake(320, 49, 270, 202)];
		[_projectPreview setHasShadow:YES];
		[_projectPreview setImageScaling:CPScaleProportionally];
		[contentView addSubview:_projectPreview];

		_projectLabel = [CPTextField labelWithTitle:@""];
		[_projectLabel setFrame:CGRectMake(320,268,270,30)];
		[_projectLabel setAlignment:CPCenterTextAlignment];
		[_projectLabel setFont:[CPFont boldSystemFontOfSize:15.0]];
		[contentView addSubview:_projectLabel];
		
		_createdLabel = [CPTextField labelWithTitle:@""];
		[_createdLabel setFrame:CGRectMake(320,304,270,20)];
		[_createdLabel setAlignment:CPCenterTextAlignment];
		[_createdLabel setFont:[CPFont systemFontOfSize:12.0]];
		[contentView addSubview:_createdLabel];

		_lastchangeLabel = [CPTextField labelWithTitle:@""];
		[_lastchangeLabel setFrame:CGRectMake(320,324,270,20)];
		[_lastchangeLabel setAlignment:CPCenterTextAlignment];
		[_lastchangeLabel setFont:[CPFont systemFontOfSize:12.0]];
		[contentView addSubview:_lastchangeLabel];
		
		_scrollview = [[CPScrollView alloc] initWithFrame:CGRectMake(10, 49, 300, 350)];
		[_scrollview setHasHorizontalScroller:false];
		[contentView addSubview:_scrollview];

		_tableview = [[CPTableView alloc] initWithFrame:[_scrollview bounds]];
		[_tableview setDataSource:self];
		[_tableview setDelegate:self];
		[_tableview setRowHeight:55];
		[_tableview setDoubleAction:@selector(openProject:)];
		[_tableview setAlternatingRowBackgroundColors:[CPArray arrayWithObjects:[CPColor whiteColor], [CPColor colorWithHexString:@"edf3fe"]]];
		[_tableview setUsesAlternatingRowBackgroundColors:YES];
		[_tableview setGridStyleMask:CPTableViewSolidHorizontalGridLineMask];
		[_tableview setColumnAutoresizingStyle:CPTableViewUniformColumnAutoresizingStyle];
		
		[contentView addSubview:_tableview];

		aTableColumn = [[CPTableColumn alloc] initWithIdentifier:@"project"];
		[aTableColumn setMinWidth:20];
		[aTableColumn setWidth:160];
		[aTableColumn setMaxWidth:300];
		[aTableColumn setResizingMask:CPTableColumnUserResizingMask];
		[aTableColumn setEditable:NO];

		dataView = [[OpenProjectColumnView alloc] initWithFrame:CGRectMake(0, 0, 280, 60)];
		[aTableColumn setDataView:dataView];
		[[aTableColumn headerView] setFrame:CGRectMake(0,6,160,20)]; 
		[[aTableColumn headerView] setStringValue:CPLocalizedString(@"Projects")]; 

		[_tableview addTableColumn:aTableColumn];

		[_tableview layoutSubviews];

		[_tableview setAllowsMultipleSelection:NO];
		[_tableview setAllowsEmptySelection:YES];

		[_tableview reloadData];
		[_tableview sizeLastColumnToFit];
		[_scrollview setDocumentView:_tableview];

		_cancelButton = [[CPButton alloc] initWithFrame:CGRectMake(383,375,98,24)];
		[_cancelButton setTitle:CPLocalizedString(@"Cancel")];
		[_cancelButton setTarget:self];
		[_cancelButton setAction:@selector(cancelOpenProject:)];
		[contentView addSubview:_cancelButton];

		_okButton = [[CPButton alloc] initWithFrame:CGRectMake(489,375,98,24)];
		[_okButton setTitle:CPLocalizedString(@"Open")];
		[_okButton setTarget:self];
		[_okButton setAction:@selector(openProject:)];
		[contentView addSubview:_okButton];
		
		/*
		_manageButton = [[CPButton alloc] initWithFrame:CGRectMake(10,375,120,24)];
		[_manageButton setTitle:CPLocalizedString(@"Manage projects")];
		[_manageButton setTarget:self];
		[_manageButton setAction:@selector(manageProjects:)];
		[contentView addSubview:_manageButton];
	*/	
	
		_showLabel = [CPTextField labelWithTitle:CPLocalizedString(@"Show:")];
		[_showLabel setFrame:CGRectMake(10,20,40,20)];
		[_showLabel setAlignment:CPLeftTextAlignment];
		[_showLabel setFont:[CPFont boldSystemFontOfSize:12.0]];
		[_showLabel sizeToFit];
		[contentView addSubview:_showLabel];
		
		_displayGroup = [[CPRadioGroup alloc] init];
		
		labelFrame = [_showLabel frame];
		_ownRadio = [[CPRadio alloc] init];
		[_ownRadio setRadioGroup:_displayGroup];
		[_ownRadio setFrame:CGRectMake(labelFrame.size.width+labelFrame.origin.x+10,20,16,16)];
		[_ownRadio setState:CPOnState];
		[_ownRadio setTarget:self];
		[_ownRadio setAction:@selector(loadOwnProjects:)];
		[contentView addSubview:_ownRadio];
		
		ownRadioFrame = [_ownRadio frame];
		_ownLabel = [CPFocusTextField labelWithTitle:CPLocalizedString(@"Own Projects")];
		[_ownLabel setFrame:CGRectMake(ownRadioFrame.origin.x+ownRadioFrame.size.width+2,20,40,20)];
		[_ownLabel setAlignment:CPLeftTextAlignment];
		[_ownLabel setFont:[CPFont systemFontOfSize:12.0]];
		[_ownLabel sizeToFit];
		[_ownLabel setFocusField:_ownRadio];
		[contentView addSubview:_ownLabel];
		
		
		ownLabelFrame = [_ownLabel frame];
		
		_sharedRadio = [[CPRadio alloc] init];
		[_sharedRadio setRadioGroup:_displayGroup];
		[_sharedRadio setFrame:CGRectMake(ownLabelFrame.size.width+ownLabelFrame.origin.x+10,20,16,16)];
		[_sharedRadio setTarget:self];
		[_sharedRadio setAction:@selector(loadSharedProjects:)];
		[contentView addSubview:_sharedRadio];
		
		sharedRadioFrame = [_sharedRadio frame];
		
		_sharedLabel = [CPFocusTextField labelWithTitle:CPLocalizedString(@"Shared Projects")];
		[_sharedLabel setFrame:CGRectMake(sharedRadioFrame.origin.x+sharedRadioFrame.size.width+2,20,40,20)];
		[_sharedLabel setAlignment:CPLeftTextAlignment];
		[_sharedLabel setFocusField:_sharedRadio];
		[_sharedLabel setFont:[CPFont systemFontOfSize:12.0]];
		[_sharedLabel sizeToFit];
		[contentView addSubview:_sharedLabel];
		
	
		[theWindow orderFront:self];
		[theWindow setDefaultButton:_okButton];
		[theWindow setAcceptsMouseMovedEvents:YES];
		[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(projectListRetrieved:) name:CCNotificationReloadProjectListSucceeded object:nil];
		[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(sharedProjectListRetrieved:) name:CCNotificationSharedProjectListSucceeded object:nil];

	}
	return self;
}

// ****************** Data source ******************

- (int)numberOfRowsInTableView:(CPTableView)aTableView
{
	return [[_delegate projects] count];
}

- (id)tableView:(CPTableView)aTableView objectValueForTableColumn:(CPTableColumn)aTableColumn row:(int)rowIndex
{
	var key = [[[_delegate projects] allKeys] objectAtIndex:rowIndex];
	var dict = [[_delegate projects] objectForKey:key];
	switch ([aTableColumn identifier])
	{
		case @"project":
			var label = [dict objectForKey:@"project"];
			if ([label length] > 35) label = [[label substringToIndex:35] stringByAppendingString:@"..."];
			var resdict = [CPMutableDictionary dictionaryWithObjectsAndKeys:
				label, @"project", 
				[CPDateHelper date:([dict objectForKey:@"lastchange"]*1000) withFormat:CPLocalizedString(@"Y-m-d H:i")], @"lastchange",
				self, @"target",
				[CPNumber numberWithInt:rowIndex], @"row"
			];
			return resdict;
			break;
		default:
			return nil;
			break;
	}
}

// ****************** Delegate ******************


-(int)tableView:(CPTableView)aTableView heightOfRow:(int)rowIndex
{
	return 70;
}

-(BOOL) tableView:(CPTableView)aTableView shouldEditTableColumn:(CPTableColumn)aTableColumn row:(int)rowIndex
{
	return NO;
}

- (void) tableViewSelectionDidChange:(id)notification
{
	return YES;
}

-(BOOL) tableView:(CPTableView)aTableView shouldSelectTableColumn:(CPTableColumn)aTableColumn
{
	return YES;
}

-(BOOL) tableView:(CPTableView)aTableView shouldSelectRow:(int)rowIndex
{
	var showNothing = NO;
	try
	{
		var key = [[[_delegate projects] allKeys] objectAtIndex:rowIndex];
		var dict = [[_delegate projects] objectForKey:key];
		var label = [dict objectForKey:@"project"];
		if ([label length] > 35) label = [[label substringToIndex:35] stringByAppendingString:@"..."];
		[_projectLabel setStringValue:label];
		[_createdLabel setStringValue:CPLocalizedString(@"Created") + @": " + [CPDateHelper date:([dict objectForKey:@"created"]*1000) withFormat:CPLocalizedString(@"Y-m-d H:i")]];
		[_lastchangeLabel setStringValue:CPLocalizedString(@"Last saved") + @": " + [CPDateHelper date:([dict objectForKey:@"lastchange"]*1000) withFormat:CPLocalizedString(@"Y-m-d H:i")]];
		var thumbnail = [dict objectForKey:@"thumbnail"];
		if (thumbnail != nil)
		{
			var webroot = [[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] || @"/webroot/";
			var filename = webroot + [dict objectForKey:@"path"] + @"/640/" + thumbnail;
			image = [[CPImage alloc] initWithContentsOfFile:filename];
			[_projectPreview setImage:image];
		}
		else
		{
			showNothing = YES;
		}
	}
	catch (e)
	{
		CPLog(@"Exception %@", e);
		showNothing = YES;
	}
	if (showNothing)
	{
		var bundle = [CPBundle mainBundle];
		image = [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"nopreview.png"]];
		[_projectPreview setImage:image];
	}
	
	return YES;
}

- (void)tableView:(CPTableView)aTableView willDisplayView:(CPView)aView forTableColumn:(CPTableColumn)tableColumn row:(int)row
{
}

-(id) tableView:(CPTableView)aTableView willDisplayCell:(id)cell forTableColumn:(CPTableColumn)aTableColumn row:(int)rowIndex
{
}

-(id) tableView:(CPTableView)aTableView selectionIndexesForProposedSelection:(id)selectionIndexes
{
	return selectionIndexes;
}

- (void)cancelOpenProject:(id)sender
{
	[[CPApplication sharedApplication] abortModal];
	[[self window] close]; 
}

-(BOOL)windowShouldClose:(id)window
{
	[self cancelOpenProject:self];
	return true;
}

- (void)deleteProject:(id)sender
{
	_deleteIndex = [[sender superview] tag];

	var alert = [[CPAlert alloc] init];
	[alert setMessageText:CPLocalizedString(@"Do you really want to delete the project and all associated files?")];
	[alert setTitle:CPLocalizedString(@"Delete Project")];
	[alert setDelegate:self];
	[alert setAlertStyle:CPWarningAlertStyle];
	[alert addButtonWithTitle:@"Delete"];
	[alert addButtonWithTitle:@"Cancel"];
	[alert runModal];
}

-(void)alertDidEnd:(CPAlert)theAlert returnCode:(int)returnCode
{
	if (returnCode == 0)
	{
		var key = [[[_delegate projects] allKeys] objectAtIndex:_deleteIndex];
		var dict = [[_delegate projects] objectForKey:key];
		[[ConnectionController sharedConnectionController] deleteProject:[dict objectForKey:@"id"]];
	}
}

- (void)manageProjects:(id)sender
{
	_manageMode = !_manageMode;
	var column = [_tableview tableColumnWithIdentifier:@"project"];
	if (_manageMode)
	{
		[_manageButton setTitle:CPLocalizedString(@"Done")];
		dataView = [[OpenProjectColumnView alloc] initWithFrame:CGRectMake(0, 0, 280, 60) andButtonHidden:NO];
		[column setDataView:dataView];
	}
	else
	{
		[_manageButton setTitle:CPLocalizedString(@"Manage projects")];
		dataView = [[OpenProjectColumnView alloc] initWithFrame:CGRectMake(0, 0, 280, 60)];
		[column setDataView:dataView];
	}
	[_tableview reloadData];
}

- (void)setDelegate:(id)aDelegate
{
	_delegate = aDelegate;
	[_tableview reloadData];
	if ([_tableview numberOfRows])
	{
		[_tableview selectRowIndexes:[CPIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
		[self tableView:_tableview shouldSelectRow:0];
	}
}

-(void)loadOwnProjects:(id)sender
{
	CPLog(@"Load own projects");
	[[ConnectionController sharedConnectionController] reloadProjects];
}

-(void)loadSharedProjects:(id)sender
{
	CPLog(@"Load shared projects");
	[[ConnectionController sharedConnectionController] listSharedProjects];
}

- (void)openProject:(id)sender
{
	var row = [_tableview selectedRow];
	if (row >= 0 && [[_delegate projects] count]>0)
	{
		var key = [[[_delegate projects] allKeys] objectAtIndex:row];
		var dict = [[_delegate projects] objectForKey:key];
		CPLog(@"===>Dict to open: %@",dict);
		[[Session sharedSession] setProject:[dict objectForKey:@"id"]];
		[[ConnectionController sharedConnectionController] loadProject:[[Session sharedSession] project]];
	}
}

- (void)projectDeleted:(CPNotification)aNotification
{
	[_delegate setProjectList:[aNotification userInfo]];
	[_tableview reloadData];
	if ([[_delegate projects] count])
	{
		[_tableview selectRowIndexes:[CPIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
		[self tableView:_tableview shouldSelectRow:0];
	}
	else
	{
		[_projectPreview setImage:nil];
		[_projectLabel setTitle:@""];
		[_createdLabel setTitle:@""];
		[_lastchangeLabel setTitle:@""];
	}
}

// ****************** Notifications ******************
-(void)projectListRetrieved:(CPNotification)notification
{	
	[_delegate setProjects:[notification userInfo]];
	[_tableview reloadData];
	if ([_tableview selectedRow]>-1 && [[_delegate projects] count]>[_tableview selectedRow]) {
		[self tableView:_tableview shouldSelectRow:[_tableview selectedRow]];
	}
}

-(void)sharedProjectListRetrieved:(CPNotification)notification
{	
	[_delegate setProjects:[notification userInfo]];
	[_tableview reloadData];
	if ([_tableview selectedRow]>-1 && [[_delegate projects] count]>[_tableview selectedRow]) {
		[self tableView:_tableview shouldSelectRow:[_tableview selectedRow]];
	}
}

@end
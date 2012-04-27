/*
 * ManageProjectsController.j
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
@import "ManageProjectsView.j"
@import "ManageProjectsColumnView.j"
@import "NewProjectDialogController.j"

var RenameToolbarItemIdentifier = "RenameToolbarItemIdentifier",
    DeleteToolbarItemIdentifier = "DeleteToolbarItemIdentifier",
    CopyToolbarItemIdentifier = "CopyToolbarItemIdentifier",
    ShareToolbarItemIdentifier = "ShareToolbarItemIdentifier",
    SearchBarToolbarItemIdentifier = "SearchBarToolbarItemIdentifier";


@implementation ManageProjectsController : CPWindowController
{
	CPScrollView _scrollview;
	CPTableView _tableView;
	CPArray _fullArray @accessors(property=fullArray);
	CPArray _filteredArray @accessors(property=filteredArray);
	CPString  _searchString;
	int selectedProjectId;
	int selectedProjectRow;
	
	//searchMember View
	CPScrollView _scrollSearchResultsView;
	CPTableView _searchResultsTableView;
	CPArray searchResultsArray;
	CPSearchField _teamSearchField;
	int selectedRow;
	
	//teamMamber View
	CPDictionary teamMemberDict;
	CPTableView _teamTableView;
}	

- (id)init
{
	
	
	var theWindow = [[CPPanel alloc] initWithContentRect:CGRectMake(80, 80, 730, 450) styleMask:CPClosableWindowMask];//+CPResizableWindowMask
	self = [super initWithWindow:theWindow];
    
	if (self)
	{
		
		var toolbar = [[CPToolbar alloc] initWithIdentifier:"Manage"];
		[toolbar setDelegate:self];
		[toolbar setVisible:YES];
		[theWindow setToolbar:toolbar];

		[theWindow setTitle:CPLocalizedString(@"Manage Projects")];
		[theWindow setDelegate:self];
		[theWindow setFloatingPanel:YES];
		
	 	contentView = [theWindow contentView];
		_scrollview = [[CPScrollView alloc] initWithFrame:CGRectMake(0, 0, 730, 200)];
		[_scrollview setHasHorizontalScroller:false];
		[contentView addSubview:_scrollview];
		
		_tableView = [[CPTableView alloc] initWithFrame:[_scrollview bounds]];
		[_tableView setDataSource:self];
		[_tableView setDelegate:self];
		[_tableView setRowHeight:20];
		[_tableView setAlternatingRowBackgroundColors:[CPArray arrayWithObjects:[CPColor whiteColor], [CPColor colorWithHexString:@"edf3fe"]]];
		[_tableView setUsesAlternatingRowBackgroundColors:YES];
		[_tableView setGridStyleMask:CPTableViewSolidHorizontalGridLineMask];
		[_tableView setColumnAutoresizingStyle:CPTableViewUniformColumnAutoresizingStyle];
		[contentView addSubview:_tableView];
		
		spaceColumn = [[CPTableColumn alloc] initWithIdentifier:@"space"];
		[spaceColumn setWidth:10];
		[spaceColumn setEditable:NO];	
		[spaceColumn setResizingMask:CPTableColumnNoResizing];
		[_tableView addTableColumn:spaceColumn];
		
	  	var desc = [CPSortDescriptor sortDescriptorWithKey:@"project" ascending:YES],
		titleColumn = [[CPTableColumn alloc] initWithIdentifier:@"project"];
		[titleColumn setMinWidth:300];
		[titleColumn setWidth:300];
		[titleColumn setMaxWidth:300];
  		[titleColumn setSortDescriptorPrototype:desc];
		[titleColumn setResizingMask:CPTableColumnUserResizingMask];
		[titleColumn setEditable:NO];	
		[[titleColumn headerView] setStringValue:CPLocalizedString(@"Project Title")];
		[_tableView addTableColumn:titleColumn];
		
		var desc = [CPSortDescriptor sortDescriptorWithKey:@"created" ascending:YES],
		createdColumn = [[CPTableColumn alloc] initWithIdentifier:@"created"];
		[createdColumn setMinWidth:100];
		[createdColumn setWidth:150];
		[createdColumn setMaxWidth:150];
  		[createdColumn setSortDescriptorPrototype:desc];
		[createdColumn setResizingMask:CPTableColumnUserResizingMask];
		[createdColumn setEditable:NO];
		[[createdColumn headerView] setStringValue:CPLocalizedString(@"Created")];
		[_tableView addTableColumn:createdColumn];
		
	  	var desc = [CPSortDescriptor sortDescriptorWithKey:@"lastchange" ascending:YES],
		dateColumn = [[CPTableColumn alloc] initWithIdentifier:@"lastchange"];
		[dateColumn setMinWidth:100];
		[dateColumn setWidth:150];
		[dateColumn setMaxWidth:150];
  		[dateColumn setSortDescriptorPrototype:desc];
		[dateColumn setResizingMask:CPTableColumnUserResizingMask];
		[dateColumn setEditable:NO];
		[[dateColumn headerView] setStringValue:CPLocalizedString(@"Last Change")];
		[_tableView addTableColumn:dateColumn];
		
	  	var desc = [CPSortDescriptor sortDescriptorWithKey:@"shared" ascending:YES],
		sharedColumn = [[CPTableColumn alloc] initWithIdentifier:@"shared"];
		[sharedColumn setMinWidth:75];
		[sharedColumn setWidth:100];
		[sharedColumn setMaxWidth:100];
  		[sharedColumn setSortDescriptorPrototype:desc];
		[sharedColumn setResizingMask:CPTableColumnUserResizingMask];
		[sharedColumn setEditable:NO];
		[[sharedColumn headerView] setStringValue:CPLocalizedString(@"Shared")];
		dataView = [[ManageProjectsColumnView alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
		[sharedColumn setDataView:dataView];
		[_tableView addTableColumn:sharedColumn];
		
		[_scrollview setDocumentView:_tableView];
		
		
		_scrollTeamView = [[CPScrollView alloc] initWithFrame:CGRectMake(460, 245, 250, 160)];
		[_scrollTeamView setHasHorizontalScroller:false];
		[contentView addSubview:_scrollTeamView]
		
		_teamTableView = [[CPTableView alloc] initWithFrame:[_scrollTeamView bounds]];
		[_teamTableView setDataSource:self];
		[_teamTableView setDelegate:self];
		[_teamTableView setRowHeight:20];
		[_teamTableView setAlternatingRowBackgroundColors:[CPArray arrayWithObjects:[CPColor whiteColor], [CPColor colorWithHexString:@"edf3fe"]]];
		[_teamTableView setUsesAlternatingRowBackgroundColors:YES];
		[_teamTableView setGridStyleMask:CPTableViewSolidHorizontalGridLineMask];
		[_teamTableView setColumnAutoresizingStyle:CPTableViewUniformColumnAutoresizingStyle];
		[contentView addSubview:_teamTableView];
		
		var nameColumn = [[CPTableColumn alloc] initWithIdentifier:@"username"];
		[nameColumn setMinWidth:[_scrollTeamView frame].size.width];
		[nameColumn setWidth:[_scrollTeamView frame].size.width];
		[nameColumn setMaxWidth:[_scrollTeamView frame].size.width];
		[nameColumn setResizingMask:CPTableColumnUserResizingMask];
		[nameColumn setEditable:NO];	
		[[nameColumn headerView] setStringValue:CPLocalizedString(@"Shared with")];
		[_teamTableView addTableColumn:nameColumn];

		[_scrollTeamView setDocumentView:_teamTableView];


		_buttonBar = [[CPButtonBar alloc] initWithFrame:CGRectMake(460,405,250,24)];
		[contentView addSubview:_buttonBar];
		//team edit buttons
		
		_addMemberButton = [[CPButton alloc] initWithFrame:CGRectMake(0,0,50,24)];
		[_addMemberButton setTitle:CPLocalizedString(@"Add")];
		[_addMemberButton setTarget:self];
		[_addMemberButton setAction:@selector(displayTeamMemberDialog:)];
		[_buttonBar addSubview:_addMemberButton];

		_deleteMemberButton = [[CPButton alloc] initWithFrame:CGRectMake(60,0,50,24)];
		[_deleteMemberButton setTitle:CPLocalizedString(@"Delete")];
		[_deleteMemberButton setEnabled:NO];
		[_deleteMemberButton setAction:@selector(deleteTeamMember:)];
		[_buttonBar addSubview:_deleteMemberButton];
			
		_titleLabel = [CPTextField labelWithTitle:@""];
		[_titleLabel setFrame:CGRectMake(15,210,440,22)];
		[_titleLabel setAlignment:CPLeftTextAlignment];
		[_titleLabel setFont:[CPFont boldSystemFontOfSize:17.0]];
		[contentView addSubview:_titleLabel];	

		var _detaiLabel = [CPTextField labelWithTitle:CPLocalizedString(@"Project Details")];
		[_detaiLabel setFrame:CGRectMake(275,245,170,22)];
		[_detaiLabel setAlignment:CPLeftTextAlignment];
		[_detaiLabel setFont:[CPFont boldSystemFontOfSize:12.0]];
		[contentView addSubview:_detaiLabel];	


		_durationLabel = [CPTextField labelWithTitle:@""];
		[_durationLabel setFrame:CGRectMake(275,270,170,22)];
		[_durationLabel setAlignment:CPLeftTextAlignment];
		[_durationLabel setFont:[CPFont systemFontOfSize:12.0]];
		[contentView addSubview:_durationLabel];	
		
		
		_slidesNumLabel = [CPTextField labelWithTitle:@""];
		[_slidesNumLabel setFrame:CGRectMake(275,290,170,22)];
		[_slidesNumLabel setAlignment:CPLeftTextAlignment];
		[_slidesNumLabel setFont:[CPFont systemFontOfSize:12.0]];
		[contentView addSubview:_slidesNumLabel];	


		var _lastEditorLabel = [CPTextField labelWithTitle:CPLocalizedString(@"Last Editor")];
		[_lastEditorLabel setFrame:CGRectMake(275,320,170,22)];
		[_lastEditorLabel setAlignment:CPLeftTextAlignment];
		[_lastEditorLabel setFont:[CPFont systemFontOfSize:12.0]];
		[contentView addSubview:_lastEditorLabel];	
		
		_lastEditorDataLabel = [CPTextField labelWithTitle:@""];
		[_lastEditorDataLabel setFrame:CGRectMake(275,340,170,22)];
		[_lastEditorDataLabel setAlignment:CPLeftTextAlignment];
		[_lastEditorDataLabel setFont:[CPFont systemFontOfSize:12.0]];
		[contentView addSubview:_lastEditorDataLabel];	
		
		_thumbnail = [[CPImageView alloc] initWithFrame:CGRectMake(15,245,240,180)];
		[_thumbnail setHasShadow:YES];
		[_thumbnail setImageScaling:CPScaleProportionally];
	//	[contentView addSubview:_thumbnail];

		var _thumbbox = [CPBox boxEnclosingView:_thumbnail];
		[_thumbbox setBorderColor:[CPColor redColor]];
		[_thumbbox setBorderWidth:9.0];
	//	[_thumbbox setContentView:_thumbnail];
		[contentView addSubview:_thumbbox];
		
		[self addTeamMemberAddView];
		
		[theWindow orderFront:self];
		[theWindow setAcceptsMouseMovedEvents:YES];

		[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(userSearchEnded:) name:CPNotificationUserSearchSucceeded object:nil];
		[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(addTeamMemberSucceeded:) name:CPNotificationAddTeamMemberSucceeded object:nil];
		[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(loadTeamMembersSucceeded:) name:CPNotificationLoadTeamMembersSucceeded object:nil];
		[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteTeamMemberSucceeded:) name:CPNotificationDeleteTeamMemberSucceeded object:nil];
		
		//toolbar Operations
		[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(projectRenameSucceeded:) name:CCNotificationProjectRenameSucceeded object:nil];
		[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(projectCopySucceeded:) name:CCNotificationProjectCopySucceeded object:nil];
		[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(projectDeleteSucceeded:) name:CCNotificationProjectDeleted object:nil];
		
	}
	return self;
}




-(void)addTeamMemberAddView
{
	//Add team member view
	var scrollFrame = [_scrollTeamView frame];
	var buttonBarFrame = [_buttonBar frame];
	overLayView = [[CPView alloc] initWithFrame:CGRectMake(scrollFrame.origin.x,scrollFrame.origin.y,scrollFrame.size.width,scrollFrame.size.height+buttonBarFrame.size.height)];
	[overLayView setBackgroundColor:[CPColor colorWithHexString:@"F1F1F1"]];
	addButton = [[CPButton alloc] initWithFrame:CGRectMake(10,[overLayView frame].size.height-29,50,24)];
	[addButton setTitle:CPLocalizedString(@"Add")];
	[addButton setTarget:self];
	[addButton setEnabled:NO];
	[addButton setAction:@selector(addTeamMember:)];
	[overLayView addSubview:addButton];

	var cancelButton = [[CPButton alloc] initWithFrame:CGRectMake(70,[overLayView frame].size.height-29,50,24)];
	[cancelButton setTitle:CPLocalizedString(@"Cancel")];
	[cancelButton setTarget:self];
	[cancelButton setAction:@selector(hideTeamMemberDialog:)];
	[overLayView addSubview:cancelButton];
	
	_teamSearchField = [[CPSearchField alloc] initWithFrame:CGRectMake(10,0,[overLayView frame].size.width-10,30)]; 
	[_teamSearchField setTarget:self]
	[_teamSearchField setPlaceholderString:CPLocalizedString(@"Search for a name")];
	[_teamSearchField setAction:@selector(teamSearchFieldDidChange:)];
    [_teamSearchField setSendsSearchStringImmediately:YES];
	[overLayView addSubview:_teamSearchField];

	//table View
	
	_scrollSearchResultsView = [[CPScrollView alloc] initWithFrame:CGRectMake(10.0, [_teamSearchField frame].size.height+5, [overLayView frame].size.width-15, [overLayView frame].size.height-75)];
	[_scrollSearchResultsView setHasHorizontalScroller:false];
	[overLayView addSubview:_scrollSearchResultsView]

	
	_searchResultsTableView = [[CPTableView alloc] initWithFrame:[_scrollSearchResultsView bounds]];
	[_searchResultsTableView setDataSource:self];
	[_searchResultsTableView setDelegate:self];
	[_searchResultsTableView setRowHeight:16];
	[_searchResultsTableView setGridStyleMask:CPTableViewSolidHorizontalGridLineMask];
	[_searchResultsTableView setColumnAutoresizingStyle:CPTableViewUniformColumnAutoresizingStyle];

	
	var nameColumn = [[CPTableColumn alloc] initWithIdentifier:@"username"];
	[nameColumn setMinWidth:[overLayView frame].size.width-15];
	[nameColumn setWidth:[overLayView frame].size.width-15];
	[nameColumn setMaxWidth:[overLayView frame].size.width-15];
	[nameColumn setResizingMask:CPTableColumnUserResizingMask];
	[nameColumn setEditable:NO];	
	[[nameColumn headerView] setStringValue:CPLocalizedString(@"Name")];

	[_searchResultsTableView addTableColumn:nameColumn];
		
	
	[overLayView addSubview:_searchResultsTableView];
		
	[_scrollSearchResultsView setDocumentView:_searchResultsTableView];
}

-(void)setFullArray:(CPArray)aArray
{
	_fullArray = aArray;
	[_tableView reloadData];
	if ([_fullArray count]>0) {
		[_tableView selectRowIndexes:[CPIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
		[self selectionDidChange:0 tableView:_tableView];
	}
}

// ****************** Data source ******************

- (int)numberOfRowsInTableView:(CPTableView)aTableView
{	
	if (aTableView == _tableView) {
		if (_filteredArray != nil) {
			return [_filteredArray count];
		} else {
			return [_fullArray count];
		}
	} else if (aTableView == _searchResultsTableView) {
		return [searchResultsArray count];
	} else if (aTableView == _teamTableView) {
		return [teamMemberDict count];
	} 
}

- (id)tableView:(CPTableView)aTableView objectValueForTableColumn:(CPTableColumn)aTableColumn row:(int)rowIndex
{
	if (aTableView == _tableView) {
		if (_filteredArray != nil) {
			object = [[_filteredArray objectAtIndex:rowIndex] objectForKey:[aTableColumn identifier]];
		} else {
			object = [[_fullArray objectAtIndex:rowIndex] objectForKey:[aTableColumn identifier]];
		}	
		switch([aTableColumn identifier])
		{
			case @"project":
				return object;
				break;
			case @"lastchange":
				return 	[CPDateHelper date:(object*1000) withFormat:CPLocalizedString(@"Y-m-d H:i")];
				break;
			case @"created":
				return 	[CPDateHelper date:(object*1000) withFormat:CPLocalizedString(@"Y-m-d H:i")];
				break;	
			case @"shared":
				return 	[CPNumber numberWithBool:object];
				break;
			default:
				return nil;
				break;
		}
	} else if (aTableView == _searchResultsTableView) {
		var key = [[searchResultsArray allKeys] objectAtIndex:rowIndex];
		var dict = [searchResultsArray objectForKey:key];
		return [dict objectForKey:@"username"]+ " (" + [dict objectForKey:@"lastname"]+", "+  [dict objectForKey:@"firstname"] + ")";
	} else if (aTableView == _teamTableView ) {
		var key = [[teamMemberDict allKeys] objectAtIndex:rowIndex];
		var dict = [teamMemberDict objectForKey:key];
		return [dict objectForKey:@"username"]+ " (" + [dict objectForKey:@"lastname"]+", "+  [dict objectForKey:@"firstname"] + ")";
	}
}

// ****************** Delegate ******************


- (void)tableView:(CPTableView)aTableView sortDescriptorsDidChange:(CPArray)oldDescriptors
{   

  	var newDescriptors = [aTableView sortDescriptors];	
	var currentObject = [aTableView selectedRow];
	
    [_fullArray sortUsingDescriptors:newDescriptors];
	if (_filteredArray != nil)
	{
   		[_filteredArray sortUsingDescriptors:newDescriptors];
	}

    [aTableView reloadData];

    var newIndex = [_fullArray indexOfObject:currentObject];
    if (newIndex >= 0)
        [aTableView selectRowIndexes:[CPIndexSet indexSetWithIndex:newIndex] byExtendingSelection:NO];
}

-(int)tableView:(CPTableView)aTableView heightOfRow:(int)rowIndex
{
	return 30;
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
	[self selectionDidChange:rowIndex tableView:aTableView];
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

- (void)searchFieldDidChange:(id)sender
{
	if (sender) {
        searchString = [[sender stringValue]  lowercaseString];
	}
    if (searchString)
    {
		_filteredArray = [[CPArray alloc] init];
	 	for (var i = 0, count = [_fullArray count]; i < count; i++)
        {
            var item = [_fullArray objectAtIndex:i];
			if ([[item valueForKey:@"project"] lowercaseString].match(searchString)) {
				[_filteredArray addObject:item];
			}
		}
		[_tableView reloadData];
		
	} else {
		_filteredArray = nil;
		[_tableView reloadData];
	}
}

-(void)teamSearchFieldDidChange:(id)sender
{
	
	var searchString = "";
	if (sender) {
        searchString = [[sender stringValue]  lowercaseString];
	}
	if (searchString != "") {
		[[ConnectionController sharedConnectionController] searchUsers:searchString];
	}	else {
		[searchResultsArray removeAllObjects];
		[_searchResultsTableView reloadData];
	}
	
}

// ****************** Delegate Toolbar ******************

- (CPArray)toolbarAllowedItemIdentifiers:(CPToolbar)aToolbar
{
   return [RenameToolbarItemIdentifier, DeleteToolbarItemIdentifier, CopyToolbarItemIdentifier, CPToolbarFlexibleSpaceItemIdentifier,SearchBarToolbarItemIdentifier];

}

- (CPArray)toolbarDefaultItemIdentifiers:(CPToolbar)aToolbar
{
   return [RenameToolbarItemIdentifier, DeleteToolbarItemIdentifier, CopyToolbarItemIdentifier, CPToolbarFlexibleSpaceItemIdentifier,SearchBarToolbarItemIdentifier];
	
}

- (CPToolbarItem)toolbar:(CPToolbar)aToolbar itemForItemIdentifier:(CPString)anItemIdentifier willBeInsertedIntoToolbar:(BOOL)aFlag
{
	var mainBundle = [CPBundle mainBundle];
	var toolbarItem = [[CPToolbarItem alloc] initWithItemIdentifier:anItemIdentifier];
	[toolbarItem setMinSize:CGSizeMake(32, 32)];
	[toolbarItem setMaxSize:CGSizeMake(32, 32)];

	if (anItemIdentifier == RenameToolbarItemIdentifier) {
		[toolbarItem setLabel:CPLocalizedString("Rename")];		
		[toolbarItem setTarget:self];
		[toolbarItem setAction:@selector(renameProject:)];
		var image = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"btn_renameProject.png"] size:CPSizeMake(32, 32)];
		[toolbarItem setImage:image];
	} else if(anItemIdentifier == DeleteToolbarItemIdentifier) {
		var image = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"btn_deleteProject.png"] size:CPSizeMake(32, 32)];
		[toolbarItem setImage:image];
		[toolbarItem setLabel:CPLocalizedString("Delete")];
		[toolbarItem setTarget:self];
		[toolbarItem setAction:@selector(deleteProject:)];
	} else if (anItemIdentifier == CopyToolbarItemIdentifier) {
		var image = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"btn_copyProject.png"] size:CPSizeMake(32, 32)];
		[toolbarItem setImage:image];
		[toolbarItem setLabel:CPLocalizedString("Copy")];
		[toolbarItem setTarget:self];
		[toolbarItem setAction:@selector(copyProject:)];
	} else if (anItemIdentifier == SearchBarToolbarItemIdentifier) {
		
		var _searchField = [[CPSearchField alloc] initWithFrame:CGRectMake(0,0,138,30)]; 
		[_searchField setTarget:self]
		[_searchField setAction:@selector(searchFieldDidChange:)];
        [_searchField setSendsSearchStringImmediately:YES];
		[_searchField setPlaceholderString:CPLocalizedString(@"Search")];
		[toolbarItem setView:_searchField];
		[toolbarItem setMinSize:CGSizeMake(138, 30)];
		[toolbarItem setMaxSize:CGSizeMake(138, 30)];
	}
	
	return toolbarItem;
	
}

// ****************** Delegate Delete Alert ******************
-(void)alertDidEnd:(CPAlert)theAlert returnCode:(int)returnCode
{
	if (returnCode == 0) {
		[[ConnectionController sharedConnectionController] deleteProject:[[self getSelectedProjectDict] objectForKey:@"id"]];
	}
}

//********Add TeamMember Dialog*****

-(void)displayTeamMemberDialog:(id)sender
{
	[_teamSearchField setStringValue:@""]
	[searchResultsArray removeAllObjects];
	[_searchResultsTableView reloadData];
	[contentView addSubview:overLayView];
}

-(void)hideTeamMemberDialog:(id)sender
{
	[overLayView removeFromSuperview];
	if (_teamSearchField!= null) {
//		[_teamSearchField resignFirstResponder];
	}	
	[addButton setEnabled:NO];
}

-(void)addTeamMember:(id)sender
{
	if (selectedRow > [searchResultsArray count]) {
		CPLog(@"Returning");
		return;
	}
	var key = [[searchResultsArray allKeys] objectAtIndex:selectedRow];
	var dict = [searchResultsArray objectForKey:key];

	if (dict) {
		[dict setObject:[CPNumber numberWithInt:selectedProjectId] forKey:@"projectid"];
		[[ConnectionController sharedConnectionController] addTeamMember:dict];
	}
}

-(void)deleteTeamMember:(id)sender
{
	if (selectedRow > [teamMemberDict count]) {
		CPLog(@"Returning");
		return;
	}	
	
	var key = [[teamMemberDict allKeys] objectAtIndex:selectedRow];
	var dict = [teamMemberDict objectForKey:key];
	if (dict) {
		[dict setObject:[CPNumber numberWithInt:selectedProjectId] forKey:@"projectid"];
		[[ConnectionController sharedConnectionController] deleteTeamMember:dict];
	}
}

-(void)updateSharedStatus
{
	var shared;
	if ([teamMemberDict count]>0) {
		shared = YES;
	} else {
		shared = NO;
	}
	
	if (_filteredArray != nil) {
		[[_filteredArray objectAtIndex:selectedProjectRow] setObject:[CPNumber numberWithBool:shared] forKey:@"shared"];
	} else {
		[[_fullArray objectAtIndex:selectedProjectRow] setObject:[CPNumber numberWithBool:shared] forKey:@"shared"];
	}	
	[_tableView reloadDataForRowIndexes:[CPIndexSet indexSetWithIndex:selectedProjectRow] columnIndexes:[CPIndexSet indexSetWithIndex:3]];
	
}


//******Notifications*****

-(void)loadTeamMembersSucceeded:(CPNotification)notification
{
	teamMemberDict = [notification userInfo];
	[_teamTableView reloadData];
}

-(void)addTeamMemberSucceeded:(CPNotification)notification
{
	[self hideTeamMemberDialog:nil];
	teamMemberDict = [notification userInfo];
	[_teamTableView reloadData];
	[self updateSharedStatus];
}

-(void)deleteTeamMemberSucceeded:(CPNotification)notification
{
	[self hideTeamMemberDialog:nil];
	teamMemberDict = [notification userInfo];
	[_teamTableView reloadData];
	[self updateSharedStatus];
}

-(void)userSearchEnded:(CPNotification)notification
{
	searchResultsArray = [notification userInfo];
	[_searchResultsTableView reloadData];
}

-(void)projectRenameSucceeded:(CPNotification)notification
{
	[controller cancelProject:self]; 
	[self setFullArray:[notification userInfo]];
	[_tableView reloadData];
}

-(void)projectCopySucceeded:(CPNotification)notification
{
	[controller cancelProject:self]; 
	[self setFullArray:[notification userInfo]];
	[_tableView reloadData];
}

-(void)projectDeleteSucceeded:(CPNotification)notification
{
	[self setFullArray:[notification userInfo]];
	[_tableView reloadData];	
}

// ****************** Action Methods ******************

-(CPDictionary)getSelectedProjectDict
{
	var obj;
	if (_filteredArray != nil) {
		obj = [_filteredArray objectAtIndex:selectedProjectRow];
	} else {
		obj = [_fullArray objectAtIndex:selectedProjectRow];
	}
	return obj;	
}

-(void)renameProject:(id)sender
{
	controller = [[NewProjectDialogController alloc] init];
	[controller setOldTitle:[[self getSelectedProjectDict] objectForKey:@"project"]];
	[controller setActionButtonTitle:CPLocalizedString(@"Rename")];
	[controller setProjectId:[[self getSelectedProjectDict] objectForKey:@"id"]];
	[controller setWindowTitle:CPLocalizedString(@"Rename Project")];
	[controller setWindowText:CPLocalizedString(@"Please enter a new name for the project")];
	[controller setAction:@selector(renameProject:)];
	[[CPApplication sharedApplication] runModalForWindow:[controller window]];	
}

-(void)copyProject:(id)sender
{
	title = [CPLocalizedString(@"Copy of ") stringByAppendingString:[[self getSelectedProjectDict] objectForKey:@"project"]];
	controller = [[NewProjectDialogController alloc] init];
	[controller setOldTitle:title];
	[controller setActionButtonTitle:CPLocalizedString(@"Copy")];
	[controller setProjectId:[[self getSelectedProjectDict] objectForKey:@"id"]];
	[controller setWindowTitle:CPLocalizedString(@"Copy Project")];
	[controller setWindowText:CPLocalizedString(@"Please enter a name for the copied project")];
	[controller setAction:@selector(copyProject:)];
	[[CPApplication sharedApplication] runModalForWindow:[controller window]];		
}

-(void)deleteProject:(id)sender
{
	var deleteAlert = [[CPAlert alloc] init];
	[deleteAlert setAlertStyle:CPCriticalAlertStyle];
	[deleteAlert setDelegate:self];
	[deleteAlert setTitle:CPLocalizedString(@"Delete Project")];
	[deleteAlert setMessageText:CPLocalizedString(@"Do you really want to delete this project?")];
	[deleteAlert addButtonWithTitle:CPLocalizedString(@"Yes")];
	[deleteAlert addButtonWithTitle:CPLocalizedString(@"No")];
	[deleteAlert runModal];
}


-(void) selectionDidChange:(int)aRow tableView:(CPTableView)aTableView
{

	if (aTableView == _tableView) {
 		[self hideTeamMemberDialog:nil];
		[_deleteMemberButton setEnabled:NO];

		var object = nil;
		var selectedRow = aRow;
	
		if (_filteredArray != nil) {
			object = [_filteredArray objectAtIndex:selectedRow];
		} else {
			object = [_fullArray objectAtIndex:selectedRow];
		}	
	
		if ([object objectForKey:@"thumbnail"] != nil)
		{
			var webroot = [[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] || @"/webroot/";
			var filename = webroot + [object objectForKey:@"path"] + @"/320/" + [object objectForKey:@"thumbnail"];
			image = [[CPImage alloc] initWithContentsOfFile:filename];
			[_thumbnail setImage:image];
		} else {
			var bundle = [CPBundle mainBundle];
			image = [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"nopreview.png"]];
			[_thumbnail setImage:image];
		}
	
		[_titleLabel setStringValue:[object objectForKey:@"project"]];
		[_slidesNumLabel setStringValue:[CPString stringWithFormat:CPLocalizedString(@"Number of slides"),[object objectForKey:@"slidecount"]]];
		[_durationLabel setStringValue:[CPString stringWithFormat:CPLocalizedString(@"Duration"),[CPString stringWithFormat:@"%.1f %@", [object objectForKey:@"duration"] / 1000.0, CPLocalizedString(@"sec")]]];
		[_lastEditorDataLabel setStringValue:[object objectForKey:@"lastusername"]];
		selectedProjectId = [[object objectForKey:@"id"] intValue];
		[[ConnectionController sharedConnectionController] loadTeamMembers:selectedProjectId];
		selectedProjectRow = aRow;
	} else if (aTableView == _searchResultsTableView) {
		[addButton setEnabled:YES];
		selectedRow = aRow;
	} else if (aTableView == _teamTableView) {
		[_deleteMemberButton setEnabled:YES];
		selectedRow = aRow;
	}

}

- (void)closeDialog:(id)sender
{
	[[CPApplication sharedApplication] abortModal];
	[[self window] close]; 
}


-(BOOL)windowShouldClose:(id)window
{
	[CPApp abortModal];
	[[self window] close]; 
	return true;
}


@end
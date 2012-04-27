/*
 * SlideView.j
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
@import <AppKit/CPImage.j>
@import "SlideItemView.j"
@import "CPBundle+Localization.j"
@import "CKJSONKeyedArchiver.j"
@import "ConnectionController.j"
@import "CPMutableDictionary+SlideshowData.j"
@import "TransitionInspector.j"
@import "CustomCollectionView.j";
@import "UploadButton.j"

ImageDragType = @"ImageDragType";

@implementation SlideView : CPView
{
	id _delegate @accessors(property=delegate);
	CustomCollectionView _slidesView;
	CPView _insertPosition;
	CPTextField _emptySlides;
	CPImage _dragImage;
	CPBox _commandView @accessors(property=commandView);
	int _dragIndex;
	int _dropIndex;
}

- (id)initWithFrame:(CGRect)aRect
{
	if (self = [super initWithFrame:aRect])
	{
		var slideRect = CGRectMake(aRect.origin.x, 0, aRect.size.width, aRect.size.height);
		_slidesView = [[CustomCollectionView alloc] initWithFrame:aRect];
		[_slidesView setAutoresizingMask:CPViewWidthSizable];
		[_slidesView setAllowsMultipleSelection:YES];
		[_slidesView setMinItemSize:CGSizeMake(90, 90)];
		[_slidesView setMaxItemSize:CGSizeMake(90, 90)];
		[_slidesView setDelegate:self];

		var itemPrototype = [[CPCollectionViewItem alloc] init];
		[itemPrototype setView:[[SlideItemView alloc] initWithFrame:CGRectMakeZero()]];
		[_slidesView setItemPrototype:itemPrototype];
		CPLog(@"item for Dragging is %@ at position", [itemPrototype view]);
//		[[itemPrototype view] addObserver:self forKeyPath:@"origin" options:(CPKeyValueObservingOptionNew) context:NULL];

		var scrollView = [[CPScrollView alloc] initWithFrame:slideRect];
		[scrollView setDocumentView:_slidesView];
		[scrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
		[scrollView setAutohidesScrollers:YES];
		/*
		var _scroller = [[CPScroller alloc] initWithFrame:CGRectMake(0,0,15,aRect.size.height)];
		var itop = CPImageInBundle(@"vscroll_knob_top.png", CGSizeMake(15, 8));
		var imiddle = CPImageInBundle(@"vscroll_knob_middle.png", CGSizeMake(15, 1));
		var ibottom = CPImageInBundle(@"vscroll_knob_bottom.png", CGSizeMake(15, 7));
		var _parts = [CPArray arrayWithObjects:itop, imiddle, ibottom, nil];
		var threePart = [[CPThreePartImage alloc] initWithImageSlices:_parts isVertical:YES];
		
		var knobColor = [CPColor colorWithPatternImage:threePart];
		[_scroller setValue:knobColor forThemeAttribute:@"knob-color"];
		[scrollView setVerticalScroller:_scroller];
		*/
		[[scrollView contentView] setBackgroundColor:[CPColor colorWithHexString:@"ebebeb"]];

		[self addSubview:scrollView];

		var imageSize = CGSizeMake(800.0,530.0);
		[self _setImages];

		[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(projectDidLoad:) name:CPNotificationProjectDidLoad object:nil];
		[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(slideSelected:) name:CPNotificationSlideSelected object:nil];
	}
	return self;
}

- (void)setCommandView:(CPBox)aCommandView
{
	_commandView = aCommandView;
	[_commandView setDelegate:self];
}

- (void)slideSelected:(CPNotification)aNotification
{
	var index = [[[aNotification userInfo] objectForKey:@"slide"] intValue];
	if (![[_slidesView selectionIndexes] containsIndex:index])
	{
		[_slidesView setSelectionIndexes:[CPIndexSet indexSetWithIndex:index]];
	}
	[_commandView slideSelected:YES];
}

- (void)redraw
{
	var indexes = [_slidesView selectionIndexes];
	[self _setImages];
	[_slidesView setSelectionIndexes:indexes];
}

-(void)_setImages
{
	webroot = [[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] || @"/webroot/";
	slides = [[Session sharedSession] slides];
	if (slides)
	{
		var images = [CPMutableArray array];
		for (var slidecount = 0; slidecount < [slides count]; slidecount++)
		{
			[images addObject:[[Session sharedSession] thumbnailForSlideAtIndex:slidecount]];
		}
		[_slidesView setContent:images];
		[_slidesView setSelectionIndexes:[CPIndexSet indexSetWithIndex:0]];
	}
	else
	{
		[_slidesView setContent:nil];
	}
}

- (void)removeAllImages
{
	[_slidesView setContent:nil];
}

- (void)setDragImage:(CPImage)dragimage
{
	_dragImage = dragimage;
}

- (void)dragImage
{
	return _dragImage;
}

- (int)indexOfImage:(CPImage)image
{
	for (var i = 0; i < [[_slidesView content] count]; i++)
	{
		if ([[_slidesView content] objectAtIndex:i] == image)
		{
			return i;
		}
	}
	return -1;
}

- (void)executeDragDrop
{
//	CPLog(@"dragindex = %d, dropindex = %d", _dragIndex, _dropIndex);

	[[Session sharedSession] addUndoData];

	var targetIndexes = [CPIndexSet indexSetWithIndex:_dropIndex];
	var deleteIndexes = [[CPIndexSet alloc] init];
	
	var selectionArray = [[CPArray alloc] init];
	[[_slidesView selectionIndexes] getIndexes:selectionArray
	 								maxCount:[[_slidesView selectionIndexes] count] 
									inIndexRange: CPMakeRange(0,[[_slidesView content] count])];
										
	
	for (var i=1;i<[[_slidesView selectionIndexes] count];i++)
	{
		[targetIndexes addIndex:_dropIndex+i];
	}
	
	for (var i=0;i<[selectionArray count];i++)
	{
		var index = [selectionArray objectAtIndex:i];
		if (index < _dropIndex) {
			[deleteIndexes addIndex:index];
		} else {
			[deleteIndexes addIndex:index+[[_slidesView selectionIndexes] count]];
		}	
	}
	
	var targetSlides = [[_slidesView content] objectsAtIndexes:[_slidesView selectionIndexes]];
	var targetObjects = [[[Session sharedSession] slides] objectsAtIndexes:[_slidesView selectionIndexes]];
	
	[[[Session sharedSession] slides] insertObjects:targetObjects atIndexes:targetIndexes];
	[[[Session sharedSession] slides] removeObjectsAtIndexes:deleteIndexes];
	[[_slidesView content] insertObjects:targetSlides atIndexes:targetIndexes];
	[[_slidesView content] removeObjectsAtIndexes:deleteIndexes];
	
	var newSelectionIndex = [[CPIndexSet alloc] init];
	for (var i=0;i<[[_slidesView content] count];i++)
	{
		if ([targetSlides containsObject:[[_slidesView content] objectAtIndex:i]]) {
			[newSelectionIndex addIndex:i];
		}
	}
	[_slidesView setSelectionIndexes:newSelectionIndex];
	[_slidesView reloadContent];
	[[ConnectionController sharedConnectionController] saveProject];
	[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationSlidesChanged object:nil userInfo:nil]];
}

- (void)showInsertPosition:(int)position  onLeftSide:(BOOL)isLeft
{
	rect = [_slidesView frameForItemAtIndex:position];
	if (isLeft)
	{
		_insertPosition = [[CPView alloc] initWithFrame:CGRectMake(rect.origin.x - 8, rect.origin.y, 6, 90)];
		_dropIndex = position;
	}
	else
	{
		_insertPosition = [[CPView alloc] initWithFrame:CGRectMake(rect.origin.x + rect.size.width + 2, rect.origin.y, 6 , 90)];
		_dropIndex = position + 1;
	}
	[_insertPosition setBackgroundColor:[CPColor redColor]];
	[_slidesView addSubview:_insertPosition];
}

- (void)hideInsertPosition
{
	[_insertPosition removeFromSuperview];
	_dropIndex = -1;
}

- (void)reset
{
	if (_commandView) 
	{
		[[_commandView deleteButton] setEnabled:NO];
		[[_commandView propertiesButton] setEnabled:NO];
	}
}

#pragma mark delegate methods

-(void)collectionView:(CPCollectionView)collectionView didDoubleClickOnItemAtIndex:(int)index
{
	[TransitionInspector showInspector];
}

-(void)collectionViewDidChangeSelection:(CPCollectionView)collectionView
{
	var idx = -1;
	[self reset];
	if ([_slidesView content] && [[_slidesView content] count])
	{
		index = [[collectionView selectionIndexes] firstIndex];
		if (index >= 0)
		{
			idx = index;
			if (_commandView) [[_commandView deleteButton] setEnabled:YES];
			if (_commandView) [[_commandView deleteButton] setTitle:CPLocalizedString(@"Delete")];
		} 
	}
	[[Session sharedSession] setImageIndex:idx];
	[self showEmptySlidesMessageIfNecessary];
}

- (CPArray)collectionView:(CPCollectionView)aCollectionView dragTypesForItemsAtIndexes:(CPIndexSet)indices
{
	_dragIndex = [indices firstIndex];
	return [ImageDragType];
}

- (CPData)collectionView:(CPCollectionView)aCollectionView dataForItemsAtIndexes:(CPIndexSet)indices forType:(CPString)aType
{
	_dragIndex = [indices firstIndex];
	[self setDragImage:[[_slidesView content] objectAtIndex:_dragIndex]];
	return [CPKeyedArchiver archivedDataWithRootObject:[self dragImage]];
}

- (void)deleteImages:(id)sender
{
	CPLog(@"indexes: %@",[[_slidesView selectionIndexes] description]);
	if ([_slidesView content] && [[_slidesView content] count])
	{
		var selIndexes = [_slidesView selectionIndexes]; 
		if ([selIndexes count] > 0)
		{
			[[_slidesView content] removeObjectsAtIndexes:selIndexes];
			[[ConnectionController sharedConnectionController] removeSlidesAtPositions:selIndexes];
			[_slidesView reloadContent];
			[self collectionViewDidChangeSelection:_slidesView];
			[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationForceSlideSelection object:nil userInfo:nil]];
		}
	}
}

- (void)projectDidLoad:(CPNotification)aNotification
{
	if (_commandView)
	{
		[[_commandView uploadButton] setEnabled:YES];
		[[_commandView uploadButton] setValue:[[Session sharedSession] SID] forParameter:@"SID"];
		[[_commandView uploadButton] setValue:[[Session sharedSession] project] forParameter:@"project"];
	} 
	[self _setImages];
	[self showEmptySlidesMessageIfNecessary];
	[self setNeedsDisplay:true];
}

- (void)showEmptySlidesMessageIfNecessary
{
	if ([[Session sharedSession] numberOfSlides] == 0)
	{
		if (!_emptySlides)
		{
			_emptySlides = [CPTextField labelWithTitle:CPLocalizedString(@"")];
			[_emptySlides setFrame:CGRectMake(40,110,[self frame].size.width-80,[self frame].size.height-220)];
			[_emptySlides setLineBreakMode:CPLineBreakByWordWrapping];
			[_emptySlides setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
			[_emptySlides setFont:[CPFont boldSystemFontOfSize:32.0]];
			[_emptySlides setValue:CPCenterTextAlignment forThemeAttribute:@"alignment"];
			[_emptySlides setTextColor:[CPColor colorWithHexString:@"333333"]];
			[self addSubview:_emptySlides];
		}
		[_emptySlides setStringValue:CPLocalizedString(@"Start adding images by clicking the 'Add Image' button")];
	}
	else
	{
		[_emptySlides removeFromSuperview];
		_emptySlides = nil;
	}
}

@end

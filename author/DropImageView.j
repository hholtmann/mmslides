/*
 * DropImageView.j
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



@import <AppKit/CPImageView.j>

ImageDragType = @"ImageDragType";

@implementation DropImageView : CPImageView
{
	BOOL _mouseIsOnLeftSide;
}

- (id)initWithFrame:(CGRect)aRect
{
	if (self = [super initWithFrame:aRect])
	{
		[self registerForDraggedTypes:[ImageDragType]];
	}
	return self;
}

- (void)performDragOperation:(CPDraggingInfo)aSender
{
	[[[aSender draggingSource] delegate] executeDragDrop];
	[[[aSender draggingSource] delegate] hideInsertPosition];
}

- (void)draggingUpdated:(CPDraggingInfo)aSender
{
	var point = [self convertPoint:[aSender draggingLocation] fromView:nil];
//	CPLog(@"point %@, location %@", CPStringFromPoint(point), CPStringFromPoint([aSender draggingLocation]));
	if (point.x < [self frame].size.width / 2 && !_mouseIsOnLeftSide)
	{
		_mouseIsOnLeftSide = YES;
		var index = [[[aSender draggingSource] delegate] indexOfImage:[self image]];
		[[[aSender draggingSource] delegate] hideInsertPosition];
		[[[aSender draggingSource] delegate] showInsertPosition:index onLeftSide:_mouseIsOnLeftSide];
	}
	else if (point.x >= [self frame].size.width / 2 && _mouseIsOnLeftSide)
	{
		_mouseIsOnLeftSide = NO;
		var index = [[[aSender draggingSource] delegate] indexOfImage:[self image]];
		[[[aSender draggingSource] delegate] hideInsertPosition];
		[[[aSender draggingSource] delegate] showInsertPosition:index onLeftSide:_mouseIsOnLeftSide];
	}
}

- (void)draggingEntered:(CPDraggingInfo)aSender
{
	CPLog(@"dragging entered. Dragged view = %@", [aSender draggedView]);
	var point = [self convertPoint:[aSender draggingLocation] fromView:nil];
	if (point.x < [self frame].size.width / 2)
	{
		_mouseIsOnLeftSide = YES;
		var index = [[[aSender draggingSource] delegate] indexOfImage:[self image]];
		[[[aSender draggingSource] delegate] hideInsertPosition];
		[[[aSender draggingSource] delegate] showInsertPosition:index onLeftSide:_mouseIsOnLeftSide];
	}
	else if (point.x >= [self frame].size.width / 2)
	{
		_mouseIsOnLeftSide = NO;
		var index = [[[aSender draggingSource] delegate] indexOfImage:[self image]];
		[[[aSender draggingSource] delegate] hideInsertPosition];
		[[[aSender draggingSource] delegate] showInsertPosition:index onLeftSide:_mouseIsOnLeftSide];
	}
}

- (void)draggingExited:(CPDraggingInfo)aSender
{
	[[[aSender draggingSource] delegate] hideInsertPosition];
}

@end
/*
 * CustomCollectionView.j
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



@implementation CustomCollectionView : CPCollectionView
{

}

- (void)mouseDragged:(CPEvent)anEvent
{
	CPLog(@"mouse dragged of CollectionView called");
	[super mouseDragged:anEvent];
}

- (void)mouseUp:(CPEvent)anEvent
{
	[super mouseUp:anEvent];
}

-(CPIndexSet) selectionIndexes
{
	return [super selectionIndexes];
}

- (void)mouseDown:(CPEvent)anEvent
{
	_mouseDownEvent = anEvent;

	var location = [self convertPoint:[anEvent locationInWindow] fromView:nil],
	row = FLOOR(location.y / (_itemSize.height + _verticalMargin)),
	column = FLOOR(location.x / (_itemSize.width + _horizontalMargin)),
	index = row * _numberOfColumns + column;

	var indexes = [_selectionIndexes copy];
	if ([indexes containsIndex:index])
	{
		return;
	}

	if (index >= 0 && index < _items.length)
	{
//		CPLog(@"mouse down, changing selection");
		if (_allowsMultipleSelection && ([anEvent modifierFlags] & CPCommandKeyMask || [anEvent modifierFlags] & CPShiftKeyMask))
		{
			if ([indexes containsIndex:index])
				[indexes removeIndex:index];
			else
				[indexes addIndex:index];
		}
		else
			indexes = [CPIndexSet indexSetWithIndex:index];
		
//		CPLog(@"New selection Index: %@",[indexes description]);
		[self setSelectionIndexes:indexes];
//		CPLog(@"After seeting %@",[self selectionIndexes]);

	}
	else if (_allowsEmptySelection)
	{
		[self setSelectionIndexes:[CPIndexSet indexSet]];
	}
}


@end


@implementation CustomCollectionView (KeyboardInteraction)
	- (void)_modifySelectionWithNewIndex:(int)anIndex direction:(int)aDirection expand:(BOOL)shouldExpand
	{
	    anIndex = MIN(MAX(anIndex, 0), [[self items] count]-1);

	    if (_allowsMultipleSelection && shouldExpand)
	    {
	        var indexes = [_selectionIndexes copy],
	            bottomAnchor = [indexes firstIndex],
	            topAnchor = [indexes lastIndex];

	        // if the direction is backward (-1) check with the bottom anchor
	        if (aDirection === -1)
	            [indexes addIndexesInRange:CPMakeRange(anIndex, bottomAnchor - anIndex + 1)];
	        else
	            [indexes addIndexesInRange:CPMakeRange(topAnchor, anIndex -  topAnchor + 1)];
	    }
	    else
	        indexes = [CPIndexSet indexSetWithIndex:anIndex];

	    [self setSelectionIndexes:indexes];
	    [self _scrollToSelection];
	}
@end
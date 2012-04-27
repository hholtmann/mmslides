/*
 * SlideshowSequenceView.j
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

@import <AppKit/CPBox.j>
@import <AppKit/CPPopUpButton.j>
@import <AppKit/CPImage.j>
@import "TransitionInspector.j"
@import "Session.j"
@import "SlideWidthIndicator.j"

SSVDefaultView = 0;
SSVDragView    = 1;

@implementation SlideshowSequenceView : CPBox
{
	int _slideIndex;
	CPButton _contextMenu @accessors(readonly,property=contextMenu);
	CPImageView _imageView;
	CPColor _unselectedBorderColor @accessors(property=unselectedBorderColor);
	CPColor _selectedBorderColor @accessors(property=selectedBorderColor);
	CPColor _hoverBorderColor @accessors(property=hoverBorderColor);
	SlideWidthIndicator _widthIndicator;
	id _delegate @accessors(property=delegate);
	BOOL _isDragging;
	BOOL _dragLeftSide;
	BOOL _hovered;
}

- (id)initWithFrame:(CGRect)aRect andIndex:(int)aIndex
{
	if (self = [super initWithFrame:aRect])
	{
		_slideIndex = aIndex;
		_hovered = NO;
		_isDragging = NO;
		_dragLeftSide = NO;
				
		[self setBackgroundColor:[CPColor colorWithCSSString:@"transparent"]];
		[self setFillColor:[CPColor colorWithHexString:@"9d9d9d"]];
		[self setBorderType:CPLineBorder];
		[self setBorderWidth:4.0];
		[self setUnselectedBorderColor:[CPColor colorWithHexString:@"666666"]];
		[self setBorderColor:_unselectedBorderColor];
		[self setCornerRadius:8.0];
		[self setSelectedBorderColor:[CPColor colorWithHexString:@"e63c04"]];
		[self setHoverBorderColor:[CPColor colorWithHexString:@"e63c04"]];
		var _imageView = [[CPImageView alloc] initWithFrame:CPRectMake(2, aRect.size.height*.25, aRect.size.width-4, aRect.size.height*.5)];
		[_imageView setImageScaling:CPScaleProportionally];
		[_imageView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
		[_imageView setImage:[[Session sharedSession] thumbnailForSlideAtIndex:aIndex]];
		[self addSubview:_imageView];
		
		_contextMenu = [[CPButton alloc] initWithFrame:CPRectMake(2,aRect.size.height-22,30,20)];
		var _buttonImage = [[CPImage alloc] initWithContentsOfFile:"Resources/button-prefs.png" size:CPSizeMake(30, 20)];
		var _buttonPressImage = [[CPImage alloc] initWithContentsOfFile:"Resources/button-prefs-pressed.png" size:CPSizeMake(30, 20)];
		[_contextMenu setImage:_buttonImage];
		[_contextMenu setAlternateImage:_buttonPressImage];
		[_contextMenu setBordered:NO];
		[_contextMenu setHidden:YES];
		[_contextMenu setAction:@selector(showContextMenu:)];
	//	[_contextMenu setTarget:self];
		CPLog(@"Target: %@",[_contextMenu target]);
		[self addSubview:_contextMenu];
	}
	return self;
}

- (void) showContextMenu:(id)sender
{
	[self select];
	
}

- (void)setTag:(int)aTag
{
	[super setTag:aTag];
	if (aTag == SSVDragView)
	{
		if (!_widthIndicator)
		{
			_widthIndicator = [[SlideWidthIndicator alloc] initWithFrame:CGRectMakeZero()];
			if (_delegate)
			{
				[_widthIndicator setDelegate:_delegate];
			}
			[self addSubview:_widthIndicator];
		}
	}
}

- (void)setFrame:(CGRect)aRect
{
	[super setFrame:aRect];
	if (_widthIndicator)
	{
		[_widthIndicator setFrame:CGRectMake(0,0,aRect.size.width,20)];
	}
}

- (void)setDelegate:(id)aDelegate
{
	_delegate = aDelegate;
	if (_widthIndicator)
	{
		[_widthIndicator setDelegate:aDelegate];
	}
}

- (void)setSlideIndex:(int)aIndex
{
	_slideIndex = aIndex;
	[_imageView setFrame:CPRectMake(2, [self frame].size.height*.25, [self frame].size.width-4, [self frame].size.height*.5)];
	[_imageView setImage:[[Session sharedSession] thumbnailForSlideAtIndex:aIndex]];
}

- (void)slideIndex
{
	return _slideIndex;
}

- (void)setNeedsDisplay:(BOOL)aDisplay
{
	[super setNeedsDisplay:aDisplay];
}

- (void)setSelectionStatus
{
	if (_isDragging)
	{
		[self setBorderColor:_selectedBorderColor];
		[self setBorderWidth:4.0];
	}
	else if (_hovered)
	{
		[self setBorderColor:_hoverBorderColor];
		[self setBorderWidth:4.0];
	}
	else if ([self isSelected])
	{
		[self setBorderColor:_selectedBorderColor];
		[self setBorderWidth:4.0];
	}
	else
	{
		[self setBorderColor:_unselectedBorderColor];
		[self setBorderWidth:1.0];
	}
}

- (BOOL)isSelected
{
	return [[Session sharedSession] imageIndex] == _slideIndex;
}

- (void)select
{
	[[Session sharedSession] setImageIndex:_slideIndex];
	[self setSelectionStatus];
	if (_delegate && [_delegate respondsToSelector:@selector(setNeedsDisplay:)])
	{
		[_delegate setNeedsDisplay:YES];
	}
}

- (void)deselect
{
	[[Session sharedSession] setImageIndex:-1];
	[self setSelectionStatus];
}

- (void)hover
{
	_hovered = YES;
	[self setSelectionStatus];
}

- (void)leave
{
	_hovered = NO;
	[self setSelectionStatus];
}

- (void)mouseUp:(CPEvent)anEvent
{
	if (_isDragging)
	{
		if (_delegate && [_delegate respondsToSelector:@selector(hideDragView)])
		{
			[_delegate hideDragView];
		}
		_isDragging = NO;
		[self setHidden:NO];
	}
	else
	{
		if ([anEvent clickCount] == 2)
		{
			[TransitionInspector showInspector];
		}
	}
}

- (void)mouseDown:(CPEvent)anEvent
{
	if ([anEvent type] == CPLeftMouseDown)
	{
		[self select];
		var mouseposition = [self convertPoint:[anEvent locationInWindow] fromView:nil];
		if (mouseposition.x < 5 || mouseposition.x > [self frame].size.width-5)
		{
			_isDragging = YES;
			if (mouseposition.x < 5)
			{
				_dragLeftSide = YES;
			}
			else
			{
				_dragLeftSide = NO;
			}
			if (_delegate && [_delegate respondsToSelector:@selector(showDragView:)])
			{
				[_delegate showDragView:_slideIndex];
			}
			[self setHidden:YES];
		}
		else
		{
			_isDragging = NO;
		}
	}
}

- (void)mouseDragged:(CPEvent)anEvent
{
	if (_isDragging)
	{
		var mouseposition = [self convertPoint:[anEvent locationInWindow] fromView:nil];
		if (!_dragLeftSide && mouseposition.x < 5) mouseposition.x = 5;
		if (_dragLeftSide && mouseposition.x > [self frame].size.width-5) mouseposition.x = [self frame].size.width-5;
		if (_delegate && [_delegate respondsToSelector:@selector(updateDragView:)])
		{
			if (mouseposition.x < 0)
			{
				[_delegate updateDragView:CPRectMake([self frame].origin.x+mouseposition.x, [self frame].origin.y, [self frame].size.width-mouseposition.x, [self frame].size.height)];
			}
			else if (mouseposition.x > [self frame].size.width)
			{
				[_delegate updateDragView:CPRectMake([self frame].origin.x, [self frame].origin.y, mouseposition.x, [self frame].size.height)];
			}
			else
			{
				if (_dragLeftSide)
				{
					[_delegate updateDragView:CPRectMake([self frame].origin.x+mouseposition.x, [self frame].origin.y, [self frame].size.width-mouseposition.x, [self frame].size.height)];
				}
				else
				{
					[_delegate updateDragView:CPRectMake([self frame].origin.x, [self frame].origin.y, mouseposition.x, [self frame].size.height)];
				}
			}
		}
	}
}

- (void)mouseMoved:(CPEvent)anEvent
{
	var mouseposition = [self convertPoint:[anEvent locationInWindow] fromView:nil];
	if (mouseposition.x < 5)
	{
		[[CPCursor cursorWithCSSString:@"w-resize"] set];
	}
	else if (mouseposition.x > [self frame].size.width-5)
	{
		[[CPCursor cursorWithCSSString:@"e-resize"] set];
	}
	else
	{
		[[CPCursor arrowCursor] set];
	}
}

- (void)mouseEntered:(CPEvent)anEvent
{
	[self hover];
	if ([self frame].size.width > 34)	[_contextMenu setHidden:NO];
}

- (void) mouseExited:(CPEvent) anEvent
{
	[self leave];
	[_contextMenu setHidden:YES];
	[[CPCursor arrowCursor] set];
}

@end

/*
 * RulerViewMarker.j
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
@import <AppKit/CPImageView.j>

@implementation RulerViewMarker : CPImageView
{
	id _delegate @accessors(property=delegate);
	BOOL _isDragging;
	CPImage _selectedImage @accessors(property=selectedImage);
	CPImage _tmpImage;
	CPTextField _position;
	CPString _time @accessors(property=time);
}

- (id)initWithFrame:(CGRect)aRect
{
	self = [super initWithFrame:aRect];
	if (self)
	{
		_isDragging = NO;
		_position = [CPTextField labelWithTitle:@"0:33"];
		[_position setFrame:CGRectMake(0, 12, aRect.size.width, 24)];
		[_position setTextColor:[CPColor whiteColor]];
		[_position setValue:CPCenterTextAlignment forThemeAttribute:@"alignment"];
		[_position setFont:[CPFont boldSystemFontOfSize:12.0]];
		[self addSubview:_position];
	}
	return self;
}

- (void)setTime:(CPString)aTime
{
	_time = aTime;
	[_position setStringValue:_time];
}

- (BOOL)isDragging
{
	return _isDragging;
}

- (double)markerWidth
{
	return [[self image] size].width;
}

- (void)mouseDown:(CPEvent)anEvent
{
	if ([anEvent type] == CPLeftMouseDown)
	{
		[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationRulerMarkerMouseDown object:nil userInfo:nil]];
		_isDragging = YES;
		_tmpImage = [self image];
		[self setImage:_selectedImage];
	}
	else
	{
		_isDragging = NO;
	}
	
	CPLog(@"Mouse down");
}

- (void)mouseUp:(CPEvent)anEvent
{
	if (_isDragging)
	{
		_isDragging = NO;
		[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationRulerMarkerMouseUp object:nil userInfo:nil]];
		if (_delegate && [_delegate respondsToSelector:@selector(markerDragged)])
		{
			[_delegate markerDragged];
		}
		[self setImage:_tmpImage];
	}
	CPLog(@"Mouse UP");
}

- (void)mouseDragged:(CPEvent)anEvent
{
	if (_isDragging)
	{
		if (_delegate && [_delegate respondsToSelector:@selector(isValidMarkerPosition:)])
		{
			var mouseposition = [[self superview] convertPoint:[anEvent locationInWindow] fromView:nil];
			if ([_delegate isValidMarkerPosition:mouseposition])
			{
				[self setFrameOrigin:CGPointMake(mouseposition.x - [self frame].size.width/2, [self frame].origin.y)];
			}
		}
		if (_delegate && [_delegate respondsToSelector:@selector(updatePosition)])
		{
			[_delegate updatePosition];
		}
	}
}

- (void)mouseMoved:(CPEvent)anEvent
{
}

- (void)mouseEntered:(CPEvent)anEvent
{
	[[CPCursor pointingHandCursor] set];
}

- (void) mouseExited:(CPEvent) anEvent
{
	[[CPCursor arrowCursor] set];
}

@end
/*
 * RulerView.j
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
@import "RulerViewMarker.j"

@implementation RulerView : CPView
{
	double _length;
	double _mainInterval;
	double _subInterval;
	double _markerWidth @accessors(property=markerWidth);
	double _markerPosition @accessors(property=markerPosition);
	double _magnification;
	id _delegate @accessors(property=delegate);
	RulerViewMarker _marker;
	double lengthUnit;
	double _xOffset;
	double _yOffset;
	BOOL _isDragging;
	CPImage _markerImage;
}

- (id)initWithFrame:(CGRect)aRect
{
	if (self = [super initWithFrame:aRect])
	{
		[self setLength:300.0];
		[self setMainInterval:30.0];
		[self setSubInterval:3.0];
		_markerPosition = 0.0;
		_magnification = 1.0;
		_lengthUnit = 1.0;
		_markerWidth = 49.0;
		_isDragging = NO;
		_xOffset = 30;
		_yOffset = 0;
		
		if (!_marker)
		{
			var mainBundle = [CPBundle mainBundle];
			var _markerImage = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"marker_large.png"] size:CGSizeMake(49,110)];
			var _selectedMarkerImage = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"marker_large_selected.png"] size:CGSizeMake(49,110)];
			_marker = [[RulerViewMarker alloc] initWithFrame:CGRectMake(0,0,49,110)];
			[_marker setImage:_markerImage];
			[_marker setSelectedImage:_selectedMarkerImage];
		}
	}
	return self;
}

- (void)updateMarker
{
	if (![_marker superview])
	{
		[_marker setFrameOrigin:CGPointMake(_xOffset-[_marker markerWidth]/2, _yOffset)];
		[_marker setDelegate:[self delegate]];
		[[self superview] addSubview:_marker];
	}
}

- (void)updateMarkerPosition
{
	var position = [_marker frame].origin.x;
	position += [_marker markerWidth]/2;
	position -= _xOffset;
	position = position / _lengthUnit;
	_markerPosition = position*1000.0;
	if (_delegate && [_delegate respondsToSelector:@selector(markerWasMovedToPosition:)])
	{
		[_delegate markerWasMovedToPosition:position];
	}
	[self setTime:position];
}

- (void)setTime:(double)position
{
	if (position/60 < 1)
	{
		[_marker setTime:[CPString stringWithFormat:@"%d.%d", position % 60, (position * 10)%10]];
	}
	else
	{
		[_marker setTime:[CPString stringWithFormat:@"%d:%02d.%d", position/60, position % 60, (position * 10)%10]];
	}
}

- (double)doubleValue
{
	return _markerPosition / 1000.0;
}

- (void)setMarkerToTimecode:(double)aMillis updatePosition:(BOOL)aUpdate
{
	if ([_marker isDragging] && !aUpdate) return;
	var forceUpdateOnMagnificationChange = NO;
	if (_delegate && [_delegate respondsToSelector:@selector(magnification)])
	{
		if (_magnification != [_delegate magnification])
		{
			_magnification = [_delegate magnification];
			forceUpdateOnMagnificationChange = YES;
		}
	}
	if ((_length > 0 && _markerPosition != aMillis) || forceUpdateOnMagnificationChange)
	{
		forceUpdateOnMagnificationChange = NO;
		[self updateMarker];
		var origin = (aMillis / 1000)*_lengthUnit;
		[_marker setFrameOrigin:CGPointMake(_xOffset + origin - [_marker markerWidth]/2,[[self superview] frame].origin.y)];
		_markerPosition = aMillis;
		if (aUpdate) [self updateMarkerPosition];
	}
	if(_delegate && [_delegate respondsToSelector:@selector(showImageAtMarkerPosition:)]) 
	{
		[_delegate showImageAtMarkerPosition:_markerPosition];
	}
	[self setTime:aMillis/1000.0];
}

- (void)setMainInterval:(double)aInterval
{
	_mainInterval = aInterval;
}

- (double)mainInterval
{
	return _mainInterval;
}

- (void)setSubInterval:(double)aInterval
{
	_subInterval = aInterval;
}

- (double)subInterval
{
	return _subInterval;
}

- (void)setLength:(double)aLength
{
	_length = aLength;
	_lengthUnit = [self frame].size.width / _length;
}

- (double)visibleTime
{
	if (_delegate && [_delegate respondsToSelector:@selector(magnification)])
	{
		var lengthUnit = ([self frame].size.width / ([[Session sharedSession] slideShowLength]/1000.0))*[_delegate magnification];
		return [self frame].size.width / lengthUnit;
	}
	else
	{
		return 0;
	}
}

- (double)positionAtPointInTime:(double)timeInSeconds
{
	if (_delegate && [_delegate respondsToSelector:@selector(magnification)])
	{
		var lengthUnit = ([self frame].size.width / ([[Session sharedSession] slideShowLength]/1000.0));//*[_delegate magnification];
		return lengthUnit * timeInSeconds;
	}
	else
	{
		return 0;
	}
}

- (void)drawRect:(CGRect)aRect
{
	var context = [[CPGraphicsContext currentContext] graphicsPort];

	var mainMarkerColor = [CPColor colorWithHexString:@"000000"];
	var subMarkerColor = [CPColor colorWithHexString:@"999999"];

	if (_delegate && [_delegate respondsToSelector:@selector(magnification)])
	{
		var lengthUnit = ([self frame].size.width / ([[Session sharedSession] slideShowLength]/1000.0))*[_delegate magnification];
		var visibleTime = [self frame].size.width / lengthUnit;
		var mainint = visibleTime / 10;
		if (mainint < 1) mainint = 1
		else if (mainint < 2) mainint = 2
		else if (mainint < 5) mainint = 5
		else if (mainint < 10) mainint = 10
		else if (mainint < 20) mainint = 20
		else if (mainint < 30) mainint = 30
		else if (mainint < 45) mainint = 45
		else if (mainint < 60) mainint = 60
		else if (mainint < 90) mainint = 90
		else if (mainint < 120) mainint = 120
		else if (mainint < 300) mainint = 300
		else if (mainint < 600) mainint = 600
		else if (mainint < 900) mainint = 900
		else if (mainint < 1200) mainint = 1200
		else mainint = 1500;
		var subint = mainint / 10;
		[self setMainInterval:mainint];
		[self setSubInterval:subint];
	}



	for (var i = [[self subviews] count]-1; i >= 0; i--)
	{
		[[[self subviews] objectAtIndex:i] removeFromSuperview];
	}
	
	[self setMarkerToTimecode:_markerPosition updatePosition:YES];

	// draw main units
	for (var i = 0.0; i < _length; i+=_mainInterval)
	{
		if (i > 0)
		{
			CGContextSetLineWidth(context, 1.0);
			
			CGContextBeginPath(context);
			CGContextMoveToPoint(context, i * _lengthUnit, 0);
			CGContextAddLineToPoint(context, i * _lengthUnit, 5);
			CGContextClosePath(context);
			CGContextSetStrokeColor(context, mainMarkerColor);
			CGContextStrokePath(context);	

/*
			CGContextBeginPath(context);
			CGContextMoveToPoint(context, i * _lengthUnit, 25);
			CGContextAddLineToPoint(context, i * _lengthUnit, 30);
			CGContextClosePath(context);
			CGContextSetStrokeColor(context, mainMarkerColor);
			CGContextStrokePath(context);
*/			
			var label = [CPTextField labelWithTitle:[CPString stringWithFormat:@"%d:%02d", i / 60, i % 60]];
			[label setFont:[CPFont systemFontOfSize:12.0]];
			[label setFrameOrigin:CGPointMake(i * _lengthUnit - [label frame].size.width / 2, 7)];
			[self addSubview:label];
		}
	}

	// draw sub units
	for (var i = 0.0; i < _length; i+=_subInterval)
	{
		if (i > 0 && (i % _mainInterval) != 0)
		{
			CGContextSetLineWidth(context, 1.0);
			
			CGContextBeginPath(context);
			CGContextMoveToPoint(context, i * _lengthUnit, 0);
			CGContextAddLineToPoint(context, i * _lengthUnit, 5);
			CGContextClosePath(context);
			CGContextSetStrokeColor(context, subMarkerColor);
			CGContextStrokePath(context);	

/*
			CGContextBeginPath(context);
			CGContextMoveToPoint(context, i * _lengthUnit, 25);
			CGContextAddLineToPoint(context, i * _lengthUnit, 30);
			CGContextClosePath(context);
			CGContextSetStrokeColor(context, subMarkerColor);
			CGContextStrokePath(context);	
*/
		}
	}
}

- (void)mouseDown:(CPEvent)anEvent
{
	if ([anEvent type] == CPLeftMouseDown)
	{
		var mouseposition = [self convertPoint:[anEvent locationInWindow] fromView:nil];
		[_marker setFrameOrigin:CGPointMake(mouseposition.x - [_marker markerWidth]/2, [_marker frame].origin.y)];
		[self updateMarkerPosition];
		[self setMarkerToTimecode:_markerPosition updatePosition:YES];
	}
	[super mouseDown:anEvent];
}

@end

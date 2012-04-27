/*
 * KenBurnsRectangle.j
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

@implementation KenBurnsRectangle : CPView
{
	id _delegate @accessors(property=delegate);
	CPColor _rectangleColor @accessors(property=rectangleColor);
	CPTextField _descriptionLabel;
	CPString _label @accessors(property=label);
	CPPoint _startPosition;
	CPPoint _lastPosition;
	CGRect _originalFrame;
	double _deltaX;
	double _deltaY;
	double _aspect;
	int _scaleMode;
	BOOL _selected @accessors(property=selected);
	BOOL _isDragging;
}

- (id)initWithFrame:(CGRect)aRect
{
	if (self = [super initWithFrame:aRect])
	{
		[self setBackgroundColor:[CPColor colorWithCSSString:@"transparent"]];
		_rectangleColor = [CPColor colorWithHexString:@"1ce660"];
		_aspect = aRect.size.width / aRect.size.height;
		_descriptionLabel = [CPTextField labelWithTitle:@""];
		[_descriptionLabel setFrame:CGRectMake(10,aRect.size.height - 30,60,20)];
		[_descriptionLabel setAlignment:CPLeftTextAlignment];
		[_descriptionLabel setFont:[CPFont boldSystemFontOfSize:14.0]];
		[_descriptionLabel sizeToFit];
		[_descriptionLabel setTextColor:_rectangleColor];
		[_descriptionLabel setTextShadowOffset:CGSizeMake(1.0, 1.0)];
		[_descriptionLabel setTextShadowColor:[CPColor colorWithHexString:@"bbbbbb"]];
		[self setRandomDimensions];
		[self addSubview:_descriptionLabel];
		_isDragging = NO;
		_selected = NO;
		_scaleMode = 0;
	}
	return self;
}

- (void)setRandomDimensions
{
	var aRect = [self frame];
	var width = aRect.size.width / 1.7;
	var max = aRect;
	if ([self superview]) max = [[self superview] frame];
	if (width < max.size.width / 2.0) width = max.size.width / 2.0;
	var height = width / _aspect;
	var x = Math.floor(Math.random()*100);
	var y = Math.floor(Math.random()*100);
	[self setFrame:CGRectMake(aRect.origin.x+x, aRect.origin.y+y, width, height)];
}

- (void)setRectangleColor:(CPColor)aColor
{
	_rectangleColor = aColor;
	[_descriptionLabel setTextColor:_rectangleColor];
}

- (void)setLabel:(CPString)aLabel
{
	_label = aLabel;
	[_descriptionLabel setStringValue:aLabel];
	[_descriptionLabel sizeToFit];
	[self setNeedsDisplay:YES];
}

- (void)drawRect:(CGRect)aRect
{
	var context = [[CPGraphicsContext currentContext] graphicsPort];

	CGContextSetLineWidth(context, 1.0);
	CGContextSetStrokeColor(context, _rectangleColor);
	CGContextStrokeRect(context, CGRectMake(3, 3, [self frame].size.width-6, [self frame].size.height-6));

	if (_selected)
	{
		CGContextSetLineWidth(context, 1.0);
		CGContextBeginPath(context);
		CGContextMoveToPoint(context, 0, 10);
		CGContextAddLineToPoint(context, 0, 0);
		CGContextMoveToPoint(context, 0, 0);
		CGContextAddLineToPoint(context, 10, 0);
		CGContextClosePath(context);
		CGContextSetStrokeColor(context, _rectangleColor);
		CGContextStrokePath(context);	

		CGContextSetLineWidth(context, 2.0);
		CGContextBeginPath(context);
		CGContextMoveToPoint(context, 0, [self frame].size.height - 10);
		CGContextAddLineToPoint(context, 0, [self frame].size.height);
		CGContextMoveToPoint(context, 0, [self frame].size.height);
		CGContextAddLineToPoint(context, 10, [self frame].size.height);
		CGContextClosePath(context);
		CGContextSetStrokeColor(context, _rectangleColor);
		CGContextStrokePath(context);	

		CGContextBeginPath(context);
		CGContextMoveToPoint(context, [self frame].size.width, [self frame].size.height - 10);
		CGContextAddLineToPoint(context, [self frame].size.width, [self frame].size.height);
		CGContextMoveToPoint(context, [self frame].size.width, [self frame].size.height);
		CGContextAddLineToPoint(context, [self frame].size.width-10, [self frame].size.height);
		CGContextClosePath(context);
		CGContextSetStrokeColor(context, _rectangleColor);
		CGContextStrokePath(context);	

		CGContextBeginPath(context);
		CGContextMoveToPoint(context, [self frame].size.width, 10);
		CGContextAddLineToPoint(context, [self frame].size.width, 0);
		CGContextMoveToPoint(context, [self frame].size.width, 0);
		CGContextAddLineToPoint(context, [self frame].size.width-10, 0);
		CGContextClosePath(context);
		CGContextSetStrokeColor(context, _rectangleColor);
		CGContextStrokePath(context);	
	}
	// cross
	CGContextSetLineWidth(context, 1.0);
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, [self frame].size.width/2.0, [self frame].size.height/2.0-10.0);
	CGContextAddLineToPoint(context, [self frame].size.width/2.0, [self frame].size.height/2.0+10.0);
	CGContextMoveToPoint(context, [self frame].size.width/2.0-10.0, [self frame].size.height/2.0);
	CGContextAddLineToPoint(context, [self frame].size.width/2.0+10.0, [self frame].size.height/2.0);
	CGContextClosePath(context);
	CGContextSetStrokeColor(context, _rectangleColor);
	CGContextStrokePath(context);	
}

- (BOOL)isDragging
{
	return _isDragging;
}

- (void)mouseDown:(CPEvent)anEvent
{
	if ([anEvent type] == CPLeftMouseDown)
	{
		_startPosition = [[self superview] convertPoint:[anEvent locationInWindow] fromView:nil];
		_lastPosition = _startPosition;
		[self setMouseCursor:_startPosition];
		_isDragging = YES;
		_originalFrame = [self frame];
		if (_delegate && [_delegate respondsToSelector:@selector(rectangleSelected:)])
		{
			[_delegate rectangleSelected:self];
			[self setSelected:YES];
		}
	}
	else
	{
		_isDragging = NO;
	}
}

- (void)setSelected:(BOOL)aSelected
{
	_selected = aSelected;
	[self setNeedsDisplay:YES];
}

- (void)mouseUp:(CPEvent)anEvent
{
	if (_isDragging)
	{
		_isDragging = NO;
		var pos = [[self superview] convertPoint:[anEvent locationInWindow] fromView:nil];
		[self setMouseCursor:pos];
	}
}

- (void)mouseDragged:(CPEvent)anEvent
{
	if (_isDragging)
	{
		var mouseposition = [[self superview] convertPoint:[anEvent locationInWindow] fromView:nil];
		if (_scaleMode == 0)
		{
			// drag
			if (_delegate)
			{
				_deltaX = _startPosition.x - mouseposition.x;
				_deltaY = _startPosition.y - mouseposition.y;
				[self setFrame:CGRectMake(_originalFrame.origin.x - _deltaX, _originalFrame.origin.y - _deltaY, _originalFrame.size.width, _originalFrame.size.height)];
			}
		}
		else if (_scaleMode >= 1 && _scaleMode <= 4)
		{
			// scale borders
			_startPosition = _lastPosition;
			_deltaX = Math.abs(mouseposition.x - _startPosition.x);
			if (_scaleMode == 1 || _scaleMode == 4)
			{
				if (mouseposition.x > _startPosition.x)
				{
					// left + smaller
					var newWidth = [self frame].size.width - _deltaX;
					if (newWidth < [[self superview] frame].size.width / 2.0) newWidth = [[self superview] frame].size.width / 2.0;
					var newHeight = newWidth / _aspect;
					if (_scaleMode == 1) // TL
					{
						[self setFrame:CGRectMake(_originalFrame.origin.x+_originalFrame.size.width-newWidth, _originalFrame.origin.y+_originalFrame.size.height-newHeight, newWidth, newHeight)];
					}
					else
					{
						[self setFrame:CGRectMake(_originalFrame.origin.x+_originalFrame.size.width-newWidth, _originalFrame.origin.y, newWidth, newHeight)];
					}
					_originalFrame = [self frame];
					[self setNeedsDisplay:YES];
				}
				else
				{
					// left + bigger
					var newWidth = [self frame].size.width + _deltaX;
					if (newWidth > [[self superview] frame].size.width) newWidth = [[self superview] frame].size.width;
					var newHeight = newWidth / _aspect;
					if (_scaleMode == 1) // TL
					{
						[self setFrame:CGRectMake(_originalFrame.origin.x+_originalFrame.size.width-newWidth, _originalFrame.origin.y+_originalFrame.size.height-newHeight, newWidth, newHeight)];
					}
					else
					{
						[self setFrame:CGRectMake(_originalFrame.origin.x+_originalFrame.size.width-newWidth, _originalFrame.origin.y, newWidth, newHeight)];
					}
					_originalFrame = [self frame];
					[self setNeedsDisplay:YES];
				}
			}
			else if (_scaleMode == 2 || _scaleMode == 3)
			{
				if (mouseposition.x > _startPosition.x)
				{
					// right + bigger
					var newWidth = [self frame].size.width + _deltaX;
					if (newWidth > [[self superview] frame].size.width) newWidth = [[self superview] frame].size.width;
					var newHeight = newWidth / _aspect;
					if (_scaleMode == 2) // TR
					{
						[self setFrame:CGRectMake(_originalFrame.origin.x, _originalFrame.origin.y-(newHeight-_originalFrame.size.height), newWidth, newHeight)];
					}
					else
					{
						[self setFrame:CGRectMake(_originalFrame.origin.x, _originalFrame.origin.y, newWidth, newHeight)];
					}
					_originalFrame = [self frame];
					[self setNeedsDisplay:YES];
				}
				else
				{
					// right + smaller
					var newWidth = [self frame].size.width - _deltaX;
					if (newWidth < [[self superview] frame].size.width / 2.0) newWidth = [[self superview] frame].size.width / 2.0;
					var newHeight = newWidth / _aspect;
					if (_scaleMode == 2) // TR
					{
						[self setFrame:CGRectMake(_originalFrame.origin.x, _originalFrame.origin.y+(_originalFrame.size.height-newHeight), newWidth, newHeight)];
					}
					else
					{
						[self setFrame:CGRectMake(_originalFrame.origin.x, _originalFrame.origin.y, newWidth, newHeight)];
					}
					_originalFrame = [self frame];
					[self setNeedsDisplay:YES];
				}
			}
		}
		else if (_scaleMode == 5 || _scaleMode == 6)
		{
			_startPosition = _lastPosition;
			// scale horizontal
			_deltaX = Math.abs(mouseposition.x - _startPosition.x);
			if (_scaleMode == 5)
			{
				if (mouseposition.x > _startPosition.x)
				{
					// left + smaller
					var newWidth = [self frame].size.width - _deltaX;
					if (newWidth < [[self superview] frame].size.width / 2.0) newWidth = [[self superview] frame].size.width / 2.0;
					var newHeight = newWidth / _aspect;
					[self setFrame:CGRectMake(mouseposition.x, _originalFrame.origin.y+((_originalFrame.size.height-newHeight)/2.0), newWidth, newHeight)];
					_originalFrame = [self frame];
					[self setNeedsDisplay:YES];
				}
				else
				{
					// left + bigger
					var newWidth = [self frame].size.width + _deltaX;
					if (newWidth > [[self superview] frame].size.width) newWidth = [[self superview] frame].size.width;
					var newHeight = newWidth / _aspect;
					[self setFrame:CGRectMake(mouseposition.x, _originalFrame.origin.y-((newHeight-_originalFrame.size.height)/2.0), newWidth, newHeight)];
					_originalFrame = [self frame];
					[self setNeedsDisplay:YES];
				}
			}
			else
			{
				if (mouseposition.x > _startPosition.x)
				{
					// right + bigger
					var newWidth = [self frame].size.width + _deltaX;
					if (newWidth > [[self superview] frame].size.width) newWidth = [[self superview] frame].size.width;
					var newHeight = newWidth / _aspect;
					[self setFrame:CGRectMake(mouseposition.x-newWidth, _originalFrame.origin.y-((newHeight-_originalFrame.size.height)/2.0), newWidth, newHeight)];
					_originalFrame = [self frame];
					[self setNeedsDisplay:YES];
				}
				else
				{
					// right + smaller
					var newWidth = [self frame].size.width - _deltaX;
					if (newWidth < [[self superview] frame].size.width / 2.0) newWidth = [[self superview] frame].size.width / 2.0;
					var newHeight = newWidth / _aspect;
					[self setFrame:CGRectMake(mouseposition.x-newWidth, _originalFrame.origin.y+((_originalFrame.size.height-newHeight)/2.0), newWidth, newHeight)];
					_originalFrame = [self frame];
					[self setNeedsDisplay:YES];
				}
			}
		}
		else if (_scaleMode == 7 || _scaleMode == 8)
		{
			// scale vertical
			_startPosition = _lastPosition;
			_deltaY = Math.abs(mouseposition.y - _startPosition.y);
			if (_scaleMode == 7)
			{
				if (mouseposition.y > _startPosition.y)
				{
					// top + smaller
					var newHeight = [self frame].size.height - _deltaY;
					if (newHeight < [[self superview] frame].size.height / 2.0) newHeight = [[self superview] frame].size.height / 2.0;
					var newWidth = newHeight * _aspect;
					[self setFrame:CGRectMake(_originalFrame.origin.x+((_originalFrame.size.width-newWidth)/2.0), mouseposition.y, newWidth, newHeight)];
					_originalFrame = [self frame];
					[self setNeedsDisplay:YES];
				}
				else
				{
					// top + bigger
					var newHeight = [self frame].size.height + _deltaY;
					if (newHeight > [[self superview] frame].size.height) newHeight = [[self superview] frame].size.height;
					var newWidth = newHeight * _aspect;
					[self setFrame:CGRectMake(_originalFrame.origin.x+((_originalFrame.size.width-newWidth)/2.0), mouseposition.y, newWidth, newHeight)];
					_originalFrame = [self frame];
					[self setNeedsDisplay:YES];
				}
			}
			else
			{
				if (mouseposition.y > _startPosition.y)
				{
					// bottom + bigger
					var newHeight = [self frame].size.height + _deltaY;
					if (newHeight > [[self superview] frame].size.height) newHeight = [[self superview] frame].size.height;
					var newWidth = newHeight * _aspect;
					[self setFrame:CGRectMake(_originalFrame.origin.x+((_originalFrame.size.width-newWidth)/2.0), mouseposition.y-newHeight, newWidth, newHeight)];
					_originalFrame = [self frame];
					[self setNeedsDisplay:YES];
				}
				else
				{
					// bottom + smaller
					var newHeight = [self frame].size.height - _deltaY;
					if (newHeight < [[self superview] frame].size.height / 2.0) newHeight = [[self superview] frame].size.height / 2.0;
					var newWidth = newHeight * _aspect;
					[self setFrame:CGRectMake(_originalFrame.origin.x+((_originalFrame.size.width-newWidth)/2.0), mouseposition.y-newHeight, newWidth, newHeight)];
					_originalFrame = [self frame];
					[self setNeedsDisplay:YES];
				}
			}
		}
		_lastPosition = mouseposition;
	}
}

- (void)setFrame:(CGRect)aFrame
{
	if ([self superview])
	{
		var pframe = [[self superview] frame];
		if (aFrame.origin.x < pframe.origin.x)
		{
			aFrame.origin.x = pframe.origin.x;
		}
		if (aFrame.origin.y < pframe.origin.y)
		{
			aFrame.origin.y = pframe.origin.y;
		}
		if (aFrame.origin.x + aFrame.size.width > pframe.origin.x + pframe.size.width)
		{
			aFrame.origin.x = pframe.origin.x + pframe.size.width - aFrame.size.width;
		}
		if (aFrame.origin.y + aFrame.size.height > pframe.origin.y + pframe.size.height)
		{
			aFrame.origin.y = pframe.origin.y + pframe.size.height - aFrame.size.height;
		}
	}
	[super setFrame:aFrame];
	[_descriptionLabel setFrame:CGRectMake(10,aFrame.size.height - 30,60,20)];
	if (_delegate && [_delegate respondsToSelector:@selector(frameChanged:)])
	{
		[_delegate frameChanged:self];
	}
}

- (void)setMouseCursor:(CPPoint)pos
{
	if (_selected)
	{
		if  ((CPRectContainsPoint(CGRectMake([self frame].origin.x, [self frame].origin.y, 10, 10), pos)))
		{
			[[CPCursor crosshairCursor] set];
			_scaleMode = 1; // TL
		}
		else if (CPRectContainsPoint(CGRectMake([self frame].origin.x + [self frame].size.width - 10, [self frame].origin.y, 10, 10), pos))
		{
			[[CPCursor crosshairCursor] set];
			_scaleMode = 2; // TR
		}
		else if (CPRectContainsPoint(CGRectMake([self frame].origin.x + [self frame].size.width - 10, [self frame].origin.y + [self frame].size.height - 10, 10, 10), pos))
		{
			[[CPCursor crosshairCursor] set];
			_scaleMode = 3; // BR
		}
		else if (CPRectContainsPoint(CGRectMake([self frame].origin.x, [self frame].origin.y + [self frame].size.height - 10, 10, 10), pos))
		{
			[[CPCursor crosshairCursor] set];
			_scaleMode = 4; // BL
		}
		else if (CPRectContainsPoint(CGRectMake([self frame].origin.x, [self frame].origin.y+10, 10, [self frame].size.height-20), pos))
		{
			[[CPCursor resizeLeftRightCursor] set];
			_scaleMode = 5; // HorL
		}
		else if (CPRectContainsPoint(CGRectMake([self frame].origin.x + [self frame].size.width - 10, [self frame].origin.y+10, 10, [self frame].size.height-20), pos))
		{
			[[CPCursor resizeLeftRightCursor] set];
			_scaleMode = 6; // HorR
		}
		else if (CPRectContainsPoint(CGRectMake([self frame].origin.x + 10, [self frame].origin.y, [self frame].size.width-20, 10), pos))
		{
			[[CPCursor resizeUpDownCursor] set];
			_scaleMode = 7; // VerT
		}
		else if (CPRectContainsPoint(CGRectMake([self frame].origin.x + 10, [self frame].origin.y+[self frame].size.height-10, [self frame].size.width-20, 10), pos))
		{
			[[CPCursor resizeUpDownCursor] set];
			_scaleMode = 8; // VerB
		}
		else
		{
			[[CPCursor pointingHandCursor] set];
			_scaleMode = 0;
		}
	}
	else
	{
		[[CPCursor pointingHandCursor] set];
		_scaleMode = 0;
	}
}

- (void)mouseMoved:(CPEvent)anEvent
{
	if ([[self superview] alphaValue] == 1.0 && !_isDragging)
	{
		var pos = [[self superview] convertPoint:[anEvent locationInWindow] fromView:nil];
		[self setMouseCursor:pos]
	}
}

- (void)mouseEntered:(CPEvent)anEvent
{
	if ([[self superview] alphaValue] == 1.0)
	{
		var pos = [[self superview] convertPoint:[anEvent locationInWindow] fromView:nil];
		[self setMouseCursor:pos]
	}
}

- (void) mouseExited:(CPEvent) anEvent
{
	if ([[self superview] alphaValue] == 1.0)
	{
		[[CPCursor arrowCursor] set];
	}
}

@end

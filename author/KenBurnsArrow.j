/*
 * KenBurnsArrow.j
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

@implementation KenBurnsArrow : CPView
{
	CPPoint _posFrom @accessors(property=posFrom);
	CPPoint _posTo @accessors(property=posTo);
	CPColor _arrowColor @accessors(property=arrowColor);
	CPColor _strokeColor @accessors(property=strokeColor);
}

- (id)initWithFrame:(CGRect)aRect
{
	if (self = [super initWithFrame:aRect])
	{
		_arrowColor = [CPColor colorWithHexString:@"f7f522"];
		_strokeColor = [CPColor colorWithHexString:@"888888"];
	}
	return self;
}

- (void)setDirectionFromPoint:(CPPoint)aFrom toPoint:(CPPoint)aTo
{
	_posFrom = aFrom;
	_posTo = aTo;
	[self setNeedsDisplay:YES];
}

- (void)drawRect:(CGRect)aRect
{
	var context = [[CPGraphicsContext currentContext] graphicsPort];
	if (_posFrom)
	{
		var arrowHeadLength = 10.0;

		CGContextSetLineWidth(context, 2.0);
		CGContextBeginPath(context);
		CGContextMoveToPoint(context, _posFrom.x, _posFrom.y);
		CGContextAddLineToPoint(context, _posTo.x, _posTo.y);

		var dx = _posTo.x - _posFrom.x;
		var dy = _posTo.y - _posFrom.y;
		var length = Math.sqrt(dx*dx + dy*dy);
		dx = dx / length * arrowHeadLength;
		dy = dy / length * arrowHeadLength;
		var x3 = _posTo.x - dx - dy;
		var y3 = _posTo.y - dy + dx;
		var x4 = _posTo.x - dx + dy;
		var y4 = _posTo.y - dy - dx;

		CGContextMoveToPoint(context, _posTo.x, _posTo.y);
		CGContextAddLineToPoint(context, x3, y3);
		CGContextMoveToPoint(context, _posTo.x, _posTo.y);
		CGContextAddLineToPoint(context, x4, y4);
		CGContextSetStrokeColor(context, _arrowColor);
		CGContextStrokePath(context);	
	}
}

@end

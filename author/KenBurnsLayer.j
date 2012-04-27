/*
 * KenBurnsLayer.j
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

@import <AppKit/CALayer.j>
@import <AppKit/CPView.j>
@import <AppKit/CPImage.j>

@implementation KenBurnsLayer : CALayer
{
	CPImage _image @accessors(property=image);
	CALayer _imageLayer;
	CPView  _view;
	double _percentage @accessors(property=percentage);
	CPPoint _centerS;
	CPPoint _centerE;
	double _m;
	double _n;
	double _scaleFactor;
	CGRect _startRect;
	CGRect _endRect;
}

- (id)initWithView:(CPView)aView
{
	self = [super init];
    
	if (self)
	{
		_view = aView;
		_percentage = 0.0;
		_imageLayer = [CALayer layer];
		[_imageLayer setOpacity:1.0];
		[_imageLayer setDelegate:self];
		[self addSublayer:_imageLayer];
	}  
	return self;
}

- (void)setAlphaValue:(double)aValue
{
	[self setOpacity:aValue];
}

- (CPView)view
{
	return _view;
}

- (void)setBounds:(CGRect)aRect
{
	[super setBounds:aRect];
	[_imageLayer setPosition:CGPointMake(CGRectGetMidX(aRect), CGRectGetMidY(aRect))];
}

- (void)setImage:(CPImage)anImage
{
	if (_image == anImage) return;
	_image = anImage;
	if (_image)
	{
		[_imageLayer setBounds:CGRectMake(0.0, 0.0, [self bounds].size.width, [self bounds].size.height)];
		[_imageLayer setAffineTransform:CGAffineTransformMakeIdentity()];
		[self getLineFunction];
	}
	[_imageLayer setNeedsDisplay];
}

- (void)setPercentage:(float)aPercentage
{
	if (_percentage == aPercentage && _centerS) return;
	_percentage = aPercentage;
	[self getLineFunction];
	if (_startRect)
	{
		var p_x = _centerS.x + (_centerE.x - _centerS.x)*_percentage;
		var p_y = _m*p_x + _n;
		if (_m == 0)
		{
			if (_centerE.y < _centerS.y)
			{
				p_y = _centerS.y - (_centerS.y-_centerE.y)*_percentage;
			}
			else
			{
				p_y = _centerS.y + (_centerE.y - _centerS.y)*_percentage;
			}
		}
		var factor = 1.0+((_scaleFactor-1.0) * _percentage);
		var dx = _startRect.size.width * factor;
		var transformscale = [self bounds].size.width/dx;
//		CPLog(@"percentage = %.2f, p = (%.2f, %.2f), factor = %.2f, dx = %.2f", _percentage, p_x, p_y, factor, [self bounds].size.width/dx);
//		CPLog(@"translate = (%.2f, %.2f)", -(p_x-([self bounds].size.width/2.0)), -(p_y-[self bounds].size.height/2.0));
		[_imageLayer setAffineTransform:CGAffineTransformScale(CGAffineTransformMakeTranslation(-(p_x-([self bounds].size.width/2.0))*transformscale, -(p_y-[self bounds].size.height/2.0)*transformscale), transformscale, transformscale)];
		[_imageLayer setNeedsDisplay];
	}
}

- (void)drawInContext:(CGContext)aContext
{
	CGContextSetFillColor(aContext, [CPColor clearColor]);
	CGContextFillRect(aContext, [self bounds]);
}

- (void)imageDidLoad:(CPImage)anImage
{
	[_imageLayer setNeedsDisplay];
}

- (void)drawLayer:(CALayer)aLayer inContext:(CGContext)aContext
{
	var bounds = [aLayer bounds];
	if ([_image loadStatus] != CPImageLoadStatusCompleted)
	{
//		CPLog(@"image: %@", _image);
		[_image setDelegate:self];
	} 
	else
	{
//		CPLog(@"image load status completed: draw image in %@", CPStringFromRect([aLayer bounds]));
		CGContextDrawImage(aContext, bounds, _image);
	}
}

- (void)getLineFunction
{
	if ([[Session sharedSession] imageIndex] > -1)
	{
		_startRect = [[Session sharedSession] kenBurnsStartForSlideAtIndex:[[Session sharedSession] imageIndex]];
		_endRect = [[Session sharedSession] kenBurnsEndForSlideAtIndex:[[Session sharedSession] imageIndex]];
		if (_startRect && _endRect)
		{
			_centerS = CGPointMake(_startRect.origin.x + _startRect.size.width / 2.0, _startRect.origin.y + _startRect.size.height / 2.0);
			_centerE = CGPointMake(_endRect.origin.x + _endRect.size.width / 2.0, _endRect.origin.y + _endRect.size.height / 2.0);
			if (_centerE.x - _centerS.x == 0)
			{
				_m = 0;
			}
			else
			{
				_m = (_centerE.y - _centerS.y)/(_centerE.x - _centerS.x);
			}
			_n = _centerS.y - _m * _centerS.x;
			_scaleFactor = _endRect.size.width/_startRect.size.width;
//			CPLog(@"center start = %@, center end = %@, m = %.2f, n = %.2f, scale = %.2f", CPStringFromPoint(_centerS), CPStringFromPoint(_centerE), _m, _n, _scaleFactor);
		}
	}
}

@end
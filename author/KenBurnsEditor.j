/*
 * KenBurnsEditor.j
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
@import "ConnectionController.j"
@import "Session.j"
@import "KenBurnsRectangle.j"
@import "KenBurnsArrow.j"

@implementation KenBurnsEditor : CPView
{	
	CPButton _quitKenBurns;
	CPImageView _imageView @accessors(property=image);
	KenBurnsRectangle _startRect @accessors(property=startRect);
	KenBurnsRectangle _endRect @accessors(property=endRect);
	KenBurnsArrow _arrow;
	BOOL _blockWhileLoading;
}

- (id)initWithFrame:(CGRect)aRect
{
	if (self = [super initWithFrame:aRect])
	{
		[self setBackgroundColor:[CPColor clearColor]];
		[self setAlphaValue:0.0];

		_imageView = [[CPImageView alloc] initWithFrame:CGRectMake(0, 0, aRect.size.width, aRect.size.height)];
		[_imageView setHasShadow:NO];
		[_imageView setImageScaling:CPScaleProportionally];
		[self addSubview:_imageView]; 

		_blockWhileLoading = NO;
		_quitKenBurns = [LPAnchorButton buttonWithTitle:@"Done"];
		[_quitKenBurns setTextColor:[CPColor whiteColor]];
		[_quitKenBurns setFrame:CGRectMake(aRect.size.width-85,5,80,20)];
		[_quitKenBurns setValue:CPCenterTextAlignment forThemeAttribute:@"alignment"];
		[_quitKenBurns setValue:CPCenterVerticalTextAlignment forThemeAttribute:@"vertical-alignment"];

		var backgroundColor = [CPColor colorWithPatternImage:[[CPThreePartImage alloc] initWithImageSlices:
		[
			[[CPImage alloc] initWithContentsOfFile:@"Resources/bluebutton_left.png" size:CGSizeMake(6, 20)],
			[[CPImage alloc] initWithContentsOfFile:@"Resources/bluebutton_middle.png" size:CGSizeMake(1, 20)],
			[[CPImage alloc] initWithContentsOfFile:@"Resources/bluebutton_right.png" size:CGSizeMake(6, 20)]
		] isVertical:NO]];
		[_quitKenBurns setBackgroundColor:backgroundColor];
		[_quitKenBurns setTarget:self];
		[_quitKenBurns setAction:@selector(deactivateKenBurns:)];

		_startRect = [[KenBurnsRectangle alloc] initWithFrame:CGRectMake(0, 0, aRect.size.width, aRect.size.height)];
		[_startRect setRectangleColor:[CPColor colorWithHexString:@"1ce660"]];
		[_startRect setLabel:CPLocalizedString(@"Start")];
		[_startRect setDelegate:self];
		_endRect = [[KenBurnsRectangle alloc] initWithFrame:CGRectMake(0, 0, aRect.size.width, aRect.size.height)];
		[_endRect setRectangleColor:[CPColor colorWithHexString:@"c12d2e"]];
		[_endRect setDelegate:self];
		[_endRect setLabel:CPLocalizedString(@"End")];
		[self addSubview:_endRect];
		[self addSubview:_startRect];
		_arrow = [[KenBurnsArrow alloc] initWithFrame:CGRectMake(0, 0, aRect.size.width, aRect.size.height)];
		[_arrow setHitTests:NO];
		[self addSubview:_arrow];
		[self addSubview:_quitKenBurns];
		[self frameChanged:nil];
	}
	return self;
}

- (void)loadKenBurns:(CPImage)aImage
{
	[_imageView setImage:aImage];
	_blockWhileLoading = YES;
	var sr = [[Session sharedSession] kenBurnsStartForSlideAtIndex:[[Session sharedSession] imageIndex]];
	var isRandom = false;
	if (sr == nil)
	{
		isRandom = true;
		sr = CGRectMake(0, 0, [self frame].size.width, [self frame].size.height);
	}
	[_startRect setFrame:sr];
	if (isRandom)
	{
		if (isRandom) [_startRect setRandomDimensions];
	}
	var er = [[Session sharedSession] kenBurnsEndForSlideAtIndex:[[Session sharedSession] imageIndex]];
	isRandom = false;
	if (er == nil)
	{
		isRandom = true;
		er = CGRectMake(0, 0, [self frame].size.width, [self frame].size.height);
	}
	[_endRect setFrame:er];
	if (isRandom)
	{
		if (isRandom) [_endRect setRandomDimensions];
	}
	[self setNeedsDisplay:YES];
	_blockWhileLoading = NO;	
}

- (void)quitKenBurns
{
	if ([[Session sharedSession] isKenBurns])
	{
		[[Session sharedSession] setKenBurns:NO];
		[[ConnectionController sharedConnectionController] saveProject];
		[[self superview] redraw];
	}
}

-(void)deactivateKenBurns:(id)sender
{
	[[ConnectionController sharedConnectionController] saveProject];
	[self quitKenBurns];
}

-(void)frameChanged:(id)sender
{
	[_arrow setDirectionFromPoint:
		CGPointMake([_startRect frame].origin.x + [_startRect frame].size.width/2.0, [_startRect frame].origin.y + [_startRect frame].size.height/2.0) 
		toPoint:
		CGPointMake([_endRect frame].origin.x + [_endRect frame].size.width/2.0, [_endRect frame].origin.y + [_endRect frame].size.height/2.0)
	];
	if (!_blockWhileLoading)
	{
//		CPLog(@"save session for index %d", [[Session sharedSession] imageIndex]);
		[[Session sharedSession] setKenBurnsWithStart:[_startRect frame] andEnd:[_endRect frame] forSlideAtIndex:[[Session sharedSession] imageIndex]];
	}
	[self setNeedsDisplay:YES];
}

-(void)rectangleSelected:(id)sender
{
	[_endRect removeFromSuperview];
	[_startRect removeFromSuperview];
	[_quitKenBurns removeFromSuperview];
	[_arrow removeFromSuperview];
	
	if (sender == _startRect)
	{
		[_endRect setSelected:NO];
		[self addSubview:_endRect];
		[self addSubview:_startRect];
	}
	else
	{
		[_startRect setSelected:NO];
		[self addSubview:_startRect];
		[self addSubview:_endRect];
	}
	[self addSubview:_arrow];
	[self addSubview:_quitKenBurns];
	[self setNeedsDisplay:YES];
}

- (CGRect)getSelectedRect
{
	if ([_startRect selected])
	{
		return [_startRect frame];
	}
	else if ([_endRect selected])
	{
		return [_endRect frame];
	}
	else
	{
		return CGRectMakeZero();
	}
}

- (void)drawRect:(CGRect)aRect
{
	/*
	var context = [[CPGraphicsContext currentContext] graphicsPort];

	CGContextSetFillColor(context, [CPColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4]);
	var r = [self getSelectedRect];
	var rects = new Array();
	rects.push(CGRectMake(0,0,aRect.size.width,r.origin.y+3));
	rects.push(CGRectMake(0,r.origin.y+r.size.height-3,aRect.size.width,aRect.size.height-(r.origin.y+r.size.height)+3));
	rects.push(CGRectMake(0,0,r.origin.x+3,aRect.size.height));
	rects.push(CGRectMake(r.origin.x+r.size.width-3,0,aRect.size.width-(r.origin.x+r.size.width)+3,aRect.size.height));
	CGContextClipToRects(context, rects, 4);
	CGContextFillRect(context, aRect);
	*/
}

@end

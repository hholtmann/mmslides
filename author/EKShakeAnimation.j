/*
 * EKShakeAnimation.j
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



@implementation EKShakeAnimation : CPObject
{
	id		_view;
	int		_currentStep;
	int		_delta;
	CGRect		_viewFrame;
	int		_steps;
	float		_stepDuration;
	CPTimer 	_timer;
}

- (id)initWithView:(id)aView
{
	self = [super init];
	if(self) {
		_view = aView;
		_currentStep = 1;
		_delta = 7;
		_viewFrame = [aView frame];
		_steps = 5;
		_stepDuration = 0.07;
		_timer = [CPTimer scheduledTimerWithTimeInterval:_stepDuration target:self selector:@selector(timerDidFire) userInfo:nil repeats:YES];
		[_timer fire];	
	}
	return self;
}

- (void)timerDidFire
{
	if (_currentStep == _steps) {
		[_timer invalidate];
		setTimeout(function() {
			[self animateToFrame:_viewFrame];
		}, _stepDuration);
	} else {
		var prefix = (_currentStep % 2 == 1) ? -1 : 1;

		[self animateToFrame:CGRectMake(_viewFrame.origin.x + _delta*prefix, _viewFrame.origin.y, _viewFrame.size.width, _viewFrame.size.height)];

		_currentStep++;
	}
}

- (void)animateToFrame:(CGRect)aFrame
{
	var animation = [[CPViewAnimation alloc] initWithViewAnimations:[
		[CPDictionary dictionaryWithJSObject:{
			CPViewAnimationTargetKey:_view, 
			CPViewAnimationStartFrameKey:_viewFrame,
			CPViewAnimationEndFrameKey:aFrame
		}]
	]];
	[animation setAnimationCurve:CPAnimationLinear];
	[animation setDuration:_stepDuration];
	[animation startAnimation];
	_viewFrame = aFrame;
}

@end

/*
 * OpenProjectColumnView.j
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

@implementation OpenProjectColumnView : CPView
{
	CPTextField _projectName;
	CPTextField _projectDate;
	CPButton _deleteButton;
}

- (id)initWithFrame:(CGRect)aRect
{
	if (self = [super initWithFrame:aRect])
	{
		[self initDataWithButtonHidden:YES];
	}
	return self;
}

- (id)initWithFrame:(CGRect)aRect andButtonHidden:(BOOL)aHidden
{
	if (self = [super initWithFrame:aRect])
	{
		[self initDataWithButtonHidden:aHidden];
	}
	return self;
}

- (void)initDataWithButtonHidden:(BOOL)aHidden
{
	_projectName = [CPTextField labelWithTitle:@"aaa"];
	[_projectName setFrame:CGRectMake(5,5,[self frame].size.width-10, ([self frame].size.height/2)-5)];
	[_projectName setFont:[CPFont boldSystemFontOfSize:15.0]];
	[_projectName setTag:100];
	[_projectName setValue:[CPColor blackColor] forThemeAttribute:@"text-color" inState:CPThemeStateNormal];
	[_projectName setValue:[CPColor whiteColor] forThemeAttribute:@"text-color" inState:CPThemeStateSelected];
	[self addSubview:_projectName];

	_projectDate = [CPTextField labelWithTitle:@"bbb"];
	[_projectDate setFrame:CGRectMake(5,([self frame].size.height/2)+5,[self frame].size.width-10, ([self frame].size.height/2)-5)];
	[_projectDate setFont:[CPFont systemFontOfSize:12.0]];
	[_projectDate setTag:101];
	[_projectDate setValue:[CPColor blackColor] forThemeAttribute:@"text-color" inState:CPThemeStateNormal];
	[_projectDate setValue:[CPColor whiteColor] forThemeAttribute:@"text-color" inState:CPThemeStateSelected];
	[self addSubview:_projectDate];

	_deleteButton = [[CPButton alloc] initWithFrame:CGRectMake([self frame].size.width-80,[self frame].size.height/2-12,70,24)];
	[_deleteButton setTitle:CPLocalizedString(@"Delete")];
	var bundle = [CPBundle mainBundle];
	var deleteImage = [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"delete.png"]];
	[_deleteButton setImage:deleteImage];
	[_deleteButton setTag:102];
	[_deleteButton setHidden:aHidden];
	[_deleteButton setTarget:self];
	[_deleteButton setAction:@selector(deleteProject:)];
	[self addSubview:_deleteButton];
}

- (BOOL)setThemeState:(CPThemeState)aState
{
	[[self viewWithTag:100] setThemeState:aState];
	[[self viewWithTag:101] setThemeState:aState];
	return [super setThemeState:aState];
}

- (BOOL)unsetThemeState:(CPThemeState)aState
{
	[[self viewWithTag:100] unsetThemeState:aState];
	[[self viewWithTag:101] unsetThemeState:aState];
	return [super unsetThemeState:aState];
}

- (void)setObjectValue:(CPMutableDictionary)aValue
{
	// this is a workaround. it seems that calling the subviews directly is not working
	[[self viewWithTag:100] setStringValue:[aValue objectForKey:@"project"]];
	[[self viewWithTag:101] setStringValue:[aValue objectForKey:@"lastchange"]];
	[[self viewWithTag:102] setTarget:[aValue objectForKey:@"target"]];
	[self setTag:[[aValue objectForKey:@"row"] intValue]];
	[self setNeedsDisplay:YES];
}

@end
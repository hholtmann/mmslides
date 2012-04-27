/*
 * PropertiesToolbar.j
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

@implementation _PropertiesToolbarButton : CPControl
{
	CPTextField _titleView;
	CPImageView _imageView;
	CPFont _font @accessors(property=font);
	bool _selected @accessors(property=selected);
	id _delegate @accessors(property=delegate);
	
	CPImageView _selectionLeft;
	CPImageView _selectionRight;
	CPView _selectionBackground;
}

- (id)initWithFrame:(CGRect)aRect
{
	if (self = [super initWithFrame:aRect])
	{
		_selected = NO;
		_font = [CPFont systemFontOfSize:11.0]; 

		_selectionBackground = [[CPImageView alloc] initWithFrame:CGRectMake(0,0,64,64)];
		[_selectionBackground setBackgroundColor:[CPColor colorWithPatternImage:[[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"propertybutton_fill.png"]]]];
		[_selectionBackground setHidden:YES];
		[self addSubview:_selectionBackground];

		_imageView = [[CPImageView alloc] initWithFrame:CGRectMake(16,8,32,32)];
		[_imageView setImageScaling:CPScaleProportionally];
		[self addSubview:_imageView];
		
		_titleView = [CPTextField labelWithTitle:@""];
		[_titleView setAlignment:CPCenterTextAlignment];
		[_titleView setVerticalAlignment:CPCenterVerticalTextAlignment];
		[self addSubview:_titleView];
		
		_selectionLeft = [[CPImageView alloc] initWithFrame:CGRectMake(0,0,2,64)];
		[_selectionLeft setImage:[[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"propertybutton_bl.png"]]];
		[_selectionLeft setHidden:YES];
		[self addSubview:_selectionLeft];

		_selectionRight = [[CPImageView alloc] initWithFrame:CGRectMake(62,0,2,64)];
		[_selectionRight setImage:[[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"propertybutton_br.png"]]];
		[_selectionRight setHidden:YES];
		[self addSubview:_selectionRight];

	}
	return self;
}

- (void)sendAction:(SEL)anAction to:(id)anObject
{
	[self setSelected:YES];
	if (_delegate && [_delegate respondsToSelector:@selector(buttonSelected:)])
	{
		[_delegate buttonSelected:self];
	}
	[super sendAction:anAction to:anObject];
}

- (void)setSelected:(bool)selected
{
	_selected = selected;
	if (_selected)
	{
		[_selectionBackground setHidden:NO];
		[_selectionLeft setHidden:NO];
		[_selectionRight setHidden:NO];
	}
	else
	{
		[_selectionBackground setHidden:YES];
		[_selectionLeft setHidden:YES];
		[_selectionRight setHidden:YES];
	}
}

- (void)toggleSelection
{
	[self setSelected:![self selected]];
}

- (void)setTitle:(CPString)aTitle
{
	[_titleView setStringValue:aTitle];
	var s = [aTitle sizeWithFont:_font];
	if (s.width > 50)
	{
		[self setFrameSize:CGSizeMake(s.width+24,64)];
	}
	else
	{
		[self setFrameSize:CGSizeMake(64,64)];
	}
	[self setNeedsLayout];
}

- (void)layoutSubviews
{
	[_titleView setFrame:CGRectMake(0,42,[self frame].size.width,16)];
	[_imageView setFrameOrigin:CGPointMake(([self frame].size.width/2)-16,8)];
	[_selectionRight setFrameOrigin:CGPointMake(([self frame].size.width)-3,0)];
	[_selectionBackground setFrame:CGRectMake(0,0,[self frame].size.width,64)];
}

- (void)setImageResource:(CPString)resource
{
	var img = [[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:resource]];
	[_imageView setImage:img];
}

@end

@implementation PropertiesToolbar : CPView
{
	CPMutableDictionary _buttons;
	CPMutableDictionary _viewtags;
}

- (id)initWithFrame:(CGRect)aRect
{
	aRect.size.height = 64;
	if (self = [super initWithFrame:aRect])
	{
		[self setBackgroundColor:[CPColor colorWithHexString:@"cccccc"]];
		_buttons = [CPMutableDictionary dictionary];
		_viewtags = [CPMutableDictionary dictionary];
	}
	return self;
}

- (void)addButtonWithTag:(CPString)tag imageResource:(CPString)resource title:(CPString)title associatedView:(CPString)viewtag target:(id)target andAction:(SEL)action
{
	var button = [[_PropertiesToolbarButton alloc] initWithFrame:CGRectMake(0,0,64,64)];
	[button setTitle:title];
	[button setDelegate:self];
	[button setTag:tag];
	[button setImageResource:resource];
	[button setTarget:target];
	[button setAction:action];
	[_buttons setObject:button forKey:tag];
	[_viewtags setObject:viewtag forKey:tag];
	[self addSubview:button];
	[self setNeedsLayout];
}

- (void)selectButtonWithTag:(CPString)tag
{
	if (tag)
	{
		var button = [_buttons objectForKey:tag];
		[button setSelected:YES];
		[self buttonSelected:button];
	}
}

- (void)buttonSelected:(_PropertiesToolbarButton)button
{
	for (var i = 0; i < [_buttons count]; i++)
	{
		var b = [_buttons objectForKey:[[_buttons allKeys] objectAtIndex:i]];
		if (button != b) [b setSelected:NO];
	}
	var selectedTag = [_viewtags objectForKey:[button tag]];
	if (selectedTag)
	{
		// activate mainview
		[[self superview] enableViewWithTag:selectedTag];
	}
}

- (void)layoutSubviews
{
	var x = 0;
	for (var i = 0; i < [_buttons count]; i++)
	{
		var button = [_buttons objectForKey:[[_buttons allKeys] objectAtIndex:i]];
		[button setFrameOrigin:CGPointMake(x, 0)];
		x += [button frame].size.width;
	}
}

@end

@implementation PropertiesToolbarView : CPView
{
	PropertiesToolbar _toolbar @accessors(property=toolbar);
	CPMutableDictionary _views;
	CPString _mainViewTag;
	CPView _mainView;
}

- (id)initWithFrame:(CGRect)aRect
{
	if (self = [super initWithFrame:aRect])
	{
		_toolbar = [[PropertiesToolbar alloc] initWithFrame:CPRectMake(0.0, 0.0, aRect.size.width, 64.0)];
		[_toolbar setAutoresizingMask:CPViewWidthSizable];
		[self addSubview:_toolbar];
		
		_views = [CPMutableDictionary dictionary];
		_mainViewTag = nil;
		_mainView = nil;
	}
	return self;
}

- (void)enableViewWithTag:(CPString)tag
{
	var view = [self viewWithTag:tag];
	if (view != _mainView)
	{
		if (_mainView) [_mainView removeFromSuperview];
		_mainView = view;
		if (_mainView)
		{
			[_mainView setFrame:CGRectMake(0,64,[self frame].size.width, [self frame].size.height-64)];
			[self addSubview:_mainView];
		}
	}
	if ([view respondsToSelector:@selector(setData)])
	{
		[view setData];
	}
}

- (void)addView:(CPView)view withTag:(CPString)tag
{
	[view setAutoresizingMask:CPViewWidthSizable+CPViewHeightSizable];
	[_views setObject:view forKey:tag];
}

- (void)removeViewWithTag:(CPString)tag
{
	[_views removeObjectForKey:tag];
}

- (CPView)viewWithTag:(CPString)tag
{
	if (tag)
	{
		return [_views objectForKey:tag];
	}
	return nil;
}

- (CPView)mainView
{
	if (_mainViewTag)
	{
		return [_views objectForKey:_mainViewTag];
	}
	return nil;
}

- (void)setMainView:(CPString)tag
{
	_mainViewTag = tag;
}

@end

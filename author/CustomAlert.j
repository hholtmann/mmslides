/*
 * CPAlert.j
 * AppKit
 *
 * Created by Jake MacMullin.
 * Copyright 2008, Jake MacMullin.
 *
 * 11/10/2008 Ross Boucher
 *     - Make it conform to style guidelines, general cleanup and ehancements
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

@import <Foundation/CPObject.j>
@import <Foundation/CPString.j>

@import <AppKit/CPApplication.j>
@import <AppKit/CPButton.j>
@import <AppKit/CPColor.j>
@import <AppKit/CPFont.j>
@import <AppKit/CPImage.j>
@import <AppKit/CPImageView.j>
@import <AppKit/CPPanel.j>
@import <AppKit/CPTextField.j>

/*
    @global
    @group CPAlertStyle
*/
CPWarningAlertStyle =        0;
/*
    @global
    @group CPAlertStyle
*/
CPInformationalAlertStyle =  1;
/*
    @global
    @group CPAlertStyle
*/
CPCriticalAlertStyle =       2;


var CPAlertWarningImage,
    CPAlertInformationImage,
    CPAlertErrorImage;

@implementation CustomAlert : CPObject
{
    CPPanel         _alertPanel;

    CPTextField     _messageLabel;
    CPImageView     _alertImageView;

    CPAlertStyle    _alertStyle;
    CPString        _windowTitle;
    int             _windowStyle;
    int             _buttonCount;
    CPArray         _buttons;

    id              _delegate;
}

+ (void)initialize
{
    if (self != CustomAlert)
        return;

    var bundle = [CPBundle bundleForClass:[CPAlert class]];   

    CPAlertWarningImage     = [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"CPAlert/dialog-warning.png"] 
                                                                 size:CGSizeMake(32.0, 32.0)];
                                                             
    CPAlertInformationImage = [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"CPAlert/dialog-information.png"] 
                                                                 size:CGSizeMake(32.0, 32.0)];
                                                                 
    CPAlertErrorImage       = [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"CPAlert/dialog-error.png"] 
                                                                 size:CGSizeMake(32.0, 32.0)];
}

- (id)init
{
    if (self = [super init])
    {
        _buttonCount = 0;
        _buttons = [CPArray array];
        _alertStyle = CPWarningAlertStyle;

        [self setWindowStyle:nil];
    }
    
    return self;
}

- (void)setWindowStyle:(int)styleMask
{
    _windowStyle = styleMask;
    
    _alertPanel = [[CPPanel alloc] initWithContentRect:CGRectMake(0.0, 0.0, 400.0, 160.0) styleMask:styleMask ? styleMask | CPTitledWindowMask : CPTitledWindowMask];
    [_alertPanel setFloatingPanel:YES];
    [_alertPanel center];

    [_messageLabel setTextColor:(styleMask & CPHUDBackgroundWindowMask) ? [CPColor whiteColor] : [CPColor blackColor]];

    var count = [_buttons count];
    for(var i=0; i < count; i++)
    {
        var button = _buttons[i];
        
        [button setFrameSize:CGSizeMake([button frame].size.width, (styleMask == CPHUDBackgroundWindowMask) ? 20.0 : 24.0)];
        
        [button setTheme:(_windowStyle === CPHUDBackgroundWindowMask) ? [CPTheme themeNamed:"Aristo-HUD"] : [CPTheme defaultTheme]];

        [[_alertPanel contentView] addSubview:button];
    }
    
    if (!_messageLabel)
    {
        var bounds = [[_alertPanel contentView] bounds];

        _messageLabel = [[CPTextField alloc] initWithFrame:CGRectMake(57.0, 10.0, CGRectGetWidth(bounds) - 73.0, 150)];
        [_messageLabel setFont:[CPFont boldSystemFontOfSize:13.0]];
        [_messageLabel setLineBreakMode:CPLineBreakByWordWrapping];
        [_messageLabel setAlignment:CPJustifiedTextAlignment];
        [_messageLabel setAutoresizingMask:CPViewWidthSizable|CPViewHeightSizable];

        _alertImageView = [[CPImageView alloc] initWithFrame:CGRectMake(15.0, 12.0, 32.0, 32.0)];
    }

    [[_alertPanel contentView] addSubview:_messageLabel];
    [[_alertPanel contentView] addSubview:_alertImageView];
}

- (void)setTitle:(CPString)aTitle
{
    _windowTitle = aTitle;
}

- (CPString)title
{
    return _windowTitle;
}

- (int)windowStyle
{
    return _windowStyle;
}

- (void)setDelegate:(id)delegate
{
    _delegate = delegate;
}

- (void)delegate
{
    return _delegate;
}

- (void)setAlertStyle:(CPAlertStyle)style
{
    _alertStyle = style;
}

- (CPAlertStyle)alertStyle
{
    return _alertStyle;
}

- (void)setMessageText:(CPString)messageText
{
    [_messageLabel setStringValue:messageText];
}

- (CPString)messageText
{
    return [_messageLabel stringValue];
}

- (void)addButtonWithTitle:(CPString)title
{
    var bounds = [[_alertPanel contentView] bounds],
        button = [[CPButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(bounds) - ((_buttonCount + 1) * 90.0), CGRectGetHeight(bounds) - 34.0, 80.0, (_windowStyle == CPHUDBackgroundWindowMask) ? 20.0 : 24.0)];
    
    [button setTitle:title];
    [button setTarget:self];
    [button setTag:_buttonCount];
    [button setAction:@selector(_notifyDelegate:)];
    
    [button setTheme:(_windowStyle === CPHUDBackgroundWindowMask) ? [CPTheme themeNamed:"Aristo-HUD"] : [CPTheme defaultTheme]];
    [button setAutoresizingMask:CPViewMinXMargin | CPViewMinYMargin];

    [[_alertPanel contentView] addSubview:button];
    
    if (_buttonCount == 0)
        [_alertPanel setDefaultButton:button];

    _buttonCount++;
    [_buttons addObject:button];
}

- (void)runModal
{
    var theTitle;
    
    switch (_alertStyle)
    {
        case CPWarningAlertStyle:       [_alertImageView setImage:CPAlertWarningImage];
                                        theTitle = @"Warning";
                                        break;
        case CPInformationalAlertStyle: [_alertImageView setImage:CPAlertInformationImage];
                                        theTitle = @"Information";
                                        break;
        case CPCriticalAlertStyle:      [_alertImageView setImage:CPAlertErrorImage];
                                        theTitle = @"Error";
                                        break;
    }
    
    [_alertPanel setTitle:_windowTitle ? _windowTitle : theTitle];
    
    [CPApp runModalForWindow:_alertPanel];
}

/* @ignore */
- (void)_notifyDelegate:(id)button
{
    [CPApp abortModal];
    [_alertPanel close];

    if (_delegate && [_delegate respondsToSelector:@selector(alertDidEnd:returnCode:)])
        [_delegate alertDidEnd:self returnCode:[button tag]];
}

@end
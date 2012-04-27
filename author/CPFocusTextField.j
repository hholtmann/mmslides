/*
 * CPFocusTextField.j
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


@import <AppKit/CPTextField.j>
@import <AppKit/CPPopUpButton.j>
@import <AppKit/CPRadio.j>

@implementation CPFocusTextField : CPTextField
{
	id _focusField @accessors(property=focusField);
}

- (void)mouseDown:(CPEvent)anEvent
{
	if ([anEvent type] == CPLeftMouseDown)
	{
		if (_focusField)
		{
			if ([_focusField class] == [CPTextField class])
			{
				if ([_focusField isEditable] && [_focusField isEnabled])
					return [[self window] makeFirstResponder:_focusField];
			}
			else if ([_focusField class] == [CPPopUpButton class])
			{
				if ([_focusField isEnabled])
					return [_focusField mouseDown:anEvent];
			}
			else if ([_focusField class] == [CPRadio class])
			{
				if ([_focusField isEnabled])
					[_focusField performClick:self];
			}
		}
	}
	return [[self nextResponder] mouseDown:anEvent];
}

@end
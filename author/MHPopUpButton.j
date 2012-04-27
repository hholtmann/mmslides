/*
 * MHPopUpButton.j
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


@import <AppKit/CPControl.j>

@implementation MHPopUpButton : CPControl
{
    DOMElement      _DOMSelectElement;
}

- (id)initWithFrame:(CPRect)aFrame
{
    if (self = [super initWithFrame:aFrame])
    {
//#if PLATFORM(DOM)
        _DOMSelectElement = document.createElement("select");
        _DOMSelectElement.style.position = "absolute";
        _DOMSelectElement.style.left = "0px";
        _DOMSelectElement.style.top = "0px";

        _DOMElement.appendChild(_DOMSelectElement);
//#endif
    }
    return self;
}

- (void)removeAllItems
{
    var numberOfItems=_DOMSelectElement.options.length;
    for (var i=0; i<numberOfItems; i++)
    {
        _DOMSelectElement.options.remove(_DOMSelectElement.options[0]);
    }
}

- (void)addItemsWithTitles:(CPArray)titles
{
    for (var i=0; i<[titles count]; i++)
    {
        var DOMoption = document.createElement("option");
        DOMoption.innerHTML = titles[i];
        _DOMSelectElement.options.add(DOMoption);
    }
    
}

- (void)selectItemAtIndex:(int)anIndex
{
    if (_DOMSelectElement.options.selectedIndex == anIndex)
        return;

    _DOMSelectElement.options.selectedIndex=anIndex;
    [self sendAction:[self action] to:[self target]];
}

- (int)indexOfSelectedItem
{
    return _DOMSelectElement.options.selectedIndex;
}

@end

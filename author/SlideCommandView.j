/*
 * SlideCommandView.j
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

@import <AppKit/CPBox.j>
@import <AppKit/CPButton.j>
@import "AlphaButton.j"
@import "UploadButton.j"

@implementation SlideCommandView : CPBox
{
	id _delegate @accessors(property=delegate);
	UploadButton _uploadButton @accessors(property=uploadButton);
	AlphaButton _deleteButton @accessors(property=deleteButton);
	AlphaButton _propertiesButton @accessors(property=propertiesButton);
}

- (id)initWithFrame:(CGRect)aRect
{
	if (self = [super initWithFrame:aRect])
	{
		var mainBundle = [CPBundle mainBundle];

		[self setAutoresizesSubviews:YES];
		[self setAutoresizingMask:CPViewWidthSizable];
		[self setBorderType:CPLineBorder];
		[self setFillColor:[CPColor colorWithHexString:@"ebebeb"]];
		[self setBorderColor:[CPColor colorWithHexString:@"9e9e9e"]];

		var urlString = [[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] + @"upload.php";

		_uploadButton = [[UploadButton alloc] initWithFrame:CGRectMake(5,2,110,32)];
		[_uploadButton setTitle:CPLocalizedString(@"Add Image")];
		[_uploadButton setBordered:NO];
		[_uploadButton allowsMultipleFiles:YES];
		[_uploadButton setURL:urlString];
		[_uploadButton setValue:[[Session sharedSession] SID] forParameter:@"SID"];
		[_uploadButton setValue:[[Session sharedSession] project] forParameter:@"project"];
		[_uploadButton setValue:@"image" forParameter:@"type"];
		[_uploadButton setEnabled:NO];
		[_uploadButton setDelegate:self];
		var image = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"20_add_image.png"] size:CPSizeMake(32, 32)];
		var highlighted = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"20_add_image.png"] size:CPSizeMake(32, 32)];
		[_uploadButton setImage:image];
		[_uploadButton setAlternateImage:highlighted];
		[_uploadButton setAlignment:CPLeftTextAlignment];
		var _labelColor = [CPColor blackColor];
		var _labelShadowColor = [CPColor colorWithWhite:1.0 alpha:0.75];
		[_uploadButton setFont:[CPFont systemFontOfSize:11.0]];
		[_uploadButton setTextColor:_labelColor];
		[_uploadButton setTextShadowColor:_labelShadowColor];
		[_uploadButton setTextShadowOffset:CGSizeMake(0.0, 1.0)];
		[self addSubview:_uploadButton];
		CPLog(@"Upload button added to subview");
		_deleteButton = [[AlphaButton alloc] initWithFrame:CGRectMake(125,2,110,32)];
		[_deleteButton setTitle:CPLocalizedString(@"Delete")];
		[_deleteButton setTarget:self];
		[_deleteButton setAction:@selector(deleteImages:)];
		[_deleteButton setBordered:NO];
		[_deleteButton setEnabled:NO];
		[_deleteButton setImageDimsWhenDisabled:YES];
		[_deleteButton setFont:[CPFont systemFontOfSize:11.0]];
		[_deleteButton setTextColor:_labelColor];
		[_deleteButton setTextShadowColor:_labelShadowColor];
		[_deleteButton setTextShadowOffset:CGSizeMake(0.0, 1.0)];
		var image = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"21_delete_image.png"] size:CPSizeMake(32, 32)];
		var highlighted = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"21_delete_image.png"] size:CPSizeMake(32, 32)];
		[_deleteButton setImage:image];
		[_deleteButton setAlternateImage:highlighted];
		[_deleteButton setAlignment:CPLeftTextAlignment];
		[self addSubview:_deleteButton];

		_propertiesButton = [[AlphaButton alloc] initWithFrame:CGRectMake(245,2,110,32)];
		[_propertiesButton setTitle:CPLocalizedString(@"Properties")];
		[_propertiesButton setTarget:self];
		[_propertiesButton setAction:@selector(showInspector:)];
		[_propertiesButton setBordered:NO];
		[_propertiesButton setEnabled:NO];
		[_propertiesButton setImageDimsWhenDisabled:YES];
		var image = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"22_properties.png"] size:CPSizeMake(32, 32)];
		var highlighted = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"22_properties.png"] size:CPSizeMake(32, 32)];
		[_propertiesButton setImage:image];
		[_propertiesButton setFont:[CPFont systemFontOfSize:11.0]];
		[_propertiesButton setTextColor:_labelColor];
		[_propertiesButton setTextShadowColor:_labelShadowColor];
		[_propertiesButton setTextShadowOffset:CGSizeMake(0.0, 1.0)];
		[_propertiesButton setAlternateImage:highlighted];
		[_propertiesButton setAlignment:CPLeftTextAlignment];
		[self addSubview:_propertiesButton];
	}
	return self;
}

- (void)deleteImages:(id)sender
{
	if (_delegate && [_delegate respondsToSelector:@selector(deleteImages:)])
	{
		[_delegate deleteImages:sender];
	}
}

- (void)slideSelected:(BOOL)isSelected
{
	if (isSelected)
	{
		[_propertiesButton setEnabled:YES];
	}
	else
	{
		[_propertiesButton setEnabled:NO];
	}
}

- (void)showInspector:(id)sender
{
	[TransitionInspector showInspector];
}

- (void)updateUploadButton
{
	[_uploadButton setEnabled:YES];
	[_uploadButton setValue:[[Session sharedSession] SID] forParameter:@"SID"];
	[_uploadButton setValue:[[Session sharedSession] project] forParameter:@"project"];
}

-(void) uploadButton:(UploadButton)button didChangeSelection:(CPArray)selection
{
	[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationShowWaitDialog object:nil userInfo:[CPDictionary dictionaryWithObjectsAndKeys:CPLocalizedString(@"Loading. Please wait..."), @"description"]]];
	[button submit];
}

-(void) uploadButton:(UploadButton)button didFailWithError:(CPString)anError
{
	CPLog(@"Upload failed with this error: " + anError);
}

-(void) uploadButton:(UploadButton)button didFinishUploadWithData:(CPString)response
{
	CPLog(@"Upload finished");
	[button resetSelection];
	[[ConnectionController sharedConnectionController] loadProject:[[Session sharedSession] project]];
}

-(void) uploadButtonDidBeginUpload:(UploadButton)button
{
	CPLog(@"Upload has begun with selection: " + [button selection]);
}

@end
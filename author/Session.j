/*
 * Session.j
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


@import <Foundation/CPDictionary.j>
@import <Foundation/CPArray.j>

var SessionSharedInstance = nil;

@implementation Session : CPObject
{
	CPString _SID @accessors(property=SID);
	CPMutableDictionary _data;
	CPMutableDictionary _preferences @accessors(property=preferences);
	CPMutableDictionary _imageCache;
	CPMutableDictionary _exportSettings;
	CPMutableArray _transitions @accessors(property=transitions);
	CPMutableArray _undoData;
	CPMutableArray _redoData;
	BOOL _isKenBurns;
	int _undoPosition;
}

- (id)init
{
	self = [super init];
	_data = [[CPMutableDictionary alloc] init];
	_preferences = [[CPMutableDictionary alloc] init];
	[_preferences setObject:[CPNumber numberWithDouble:[self defaultLength]] forKey:@"defaultLength"];
	[_preferences setObject:[CPNumber numberWithDouble:[self defaultSlideLength]] forKey:@"defaultSlideLength"];
	[_preferences setObject:[CPNumber numberWithDouble:[self defaultTransitionLength]] forKey:@"defaultTransitionLength"];
	[_preferences setObject:[self defaultTransition] forKey:@"defaultTransition"];

	_imageCache = [[CPMutableDictionary alloc] init];
	_exportSettings = [[CPMutableDictionary alloc] init];
	_transitions = [[CPMutableArray alloc] init];
	_isKenBurns = NO;
	[_transitions addObject:@"notransition"];
	[_transitions addObject:@"fade"];
	[_transitions addObject:@"crossfade"];
	[_transitions addObject:@"straightcut"];
	_undoPosition = -1;
	_undoData = [[CPMutableArray alloc] init];
	_redoData = [[CPMutableArray alloc] init];
	
	return self;
}

+ (Session)sharedSession
{
	if (!SessionSharedInstance) 
	{
		SessionSharedInstance = [[Session alloc] init];
	}
	return SessionSharedInstance;
}

- (void)purgeUndoData
{
	[_undoData removeAllObjects];
	_undoPosition = -1;
	CPLog(@"delete all undo data");
//	[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationToolbarUpdate object:nil userInfo:nil]];
}

- (void)addUndoData
{
	CPLog(@"add undo data");
	if ([self data] != nil)
	{
		[_undoData addObject:[[self data] toJSON]];
		_undoPosition = [_undoData count] - 1;
	}
//	[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationToolbarUpdate object:nil userInfo:nil]];
}

- (void)undoAvailable
{
	return ([_undoData count] > 0);
}

- (void)redoAvailable
{
	return ([_redoData count] > 0);
}

- (void)undo
{
	if (![self undoAvailable]) return;
	if (_undoPosition+1 >= 0)
	{
		[_redoData addObject:[[self data] toJSON]];
		var dict = [CPDictionary dictionaryWithJSObject:[_undoData objectAtIndex:_undoPosition] recursively:true];
		[self setData:dict];
		[_undoData removeObjectAtIndex:_undoPosition];
		_undoPosition--;
		[[ConnectionController sharedConnectionController] saveProject];
		[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationRedrawApplication object:nil userInfo:nil]];
		[[ConnectionController sharedConnectionController] updateSlideLengths];
	}
}

- (void)redo
{
	if (![self redoAvailable]) return;
	[self addUndoData];
	var dict = [CPDictionary dictionaryWithJSObject:[_redoData objectAtIndex:[_redoData count]-1] recursively:true];
	[_redoData removeObjectAtIndex:[_redoData count]-1];
	[self setData:dict];
	[[ConnectionController sharedConnectionController] saveProject];
	[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationRedrawApplication object:nil userInfo:nil]];
	[[ConnectionController sharedConnectionController] updateSlideLengths];
}

- (CPMutableDictionary)exportSettings
{
	if (![_exportSettings containsKey:@"showControls"]) [_exportSettings setObject:[CPNumber numberWithBool:YES] forKey:@"showControls"];
	if (![_exportSettings containsKey:@"showCaptionsByDefault"]) [_exportSettings setObject:[CPNumber numberWithBool:NO] forKey:@"showCaptionsByDefault"];
	if (![_exportSettings containsKey:@"autoPlay"]) [_exportSettings setObject:[CPNumber numberWithBool:YES] forKey:@"autoPlay"];
	if (![_exportSettings containsKey:@"loop"]) [_exportSettings setObject:[CPNumber numberWithBool:YES] forKey:@"loop"];
	if (![_exportSettings containsKey:@"exportSize"]) [_exportSettings setObject:@"640x480" forKey:@"exportSize"];
	if (![_exportSettings containsKey:@"styleTemplate"]) [_exportSettings setObject:@"default" forKey:@"styleTemplate"];
	if (![_exportSettings containsKey:@"width"]) [_exportSettings setObject:[CPNumber numberWithInt:640] forKey:@"width"];
	if (![_exportSettings containsKey:@"height"]) [_exportSettings setObject:[CPNumber numberWithInt:480] forKey:@"height"];
	return _exportSettings;
}

- (void)setExportSettings:(CPMutableDictionary)aSettings
{
	if ([aSettings class] == [CPDictionary class] || [aSettings class] == [CPMutableDictionary class])
	{
		_exportSettings = aSettings;
	}
}

- (CPMutableDictionary)styleTemplates
{
	var dict = [_preferences objectForKey:@"themes"];
	if (dict == null) dict = [CPMutableDictionary dictionary];
	return dict;
}


- (CPMutableArray)exportSizes
{
	return [CPMutableArray arrayWithObjects:@"1280x960",@"1024x768", @"800x600", @"640x480", @"480x360",@"320x240"];
}

-(CPArray)moviePresets
{
	
	return [CPMutableArray arrayWithObjects:
				[CPDictionary dictionaryWithObjectsAndKeys:@".m4v",@"format",@"Computer High/TV-HD (1280 x 960)",@"title",[CPNumber numberWithInt:0],@"resolution",[CPNumber numberWithInt:1],@"codec",@"Computer\nTV\nUpload to YouTube HD/Vimeo",@"usage"],
				[CPDictionary dictionaryWithObjectsAndKeys:@".m4v",@"format",@"Computer Normal/iPad (1024 x 768)",@"title",[CPNumber numberWithInt:1],@"resolution",[CPNumber numberWithInt:1],@"codec",@"Computer\nTablets/iPad",@"usage"],
				[CPDictionary dictionaryWithObjectsAndKeys:@".m4v",@"format",@"High Quality Video (800 x 600)",@"title",[CPNumber numberWithInt:2],@"resolution",[CPNumber numberWithInt:1],@"codec",@"Websites\neLearning",@"usage"],
				[CPDictionary dictionaryWithObjectsAndKeys:@".flv",@"format",@"Normal Quality Flash Video (640 x 480)",@"title",[CPNumber numberWithInt:3],@"resolution",[CPNumber numberWithInt:2],@"codec",@"Websites\neLearning\nYouTube",@"usage"],
				[CPDictionary dictionaryWithObjectsAndKeys:@".mp4",@"format",@"Normal Quality MP4 (640 x 480)",@"title",[CPNumber numberWithInt:3],@"resolution",[CPNumber numberWithInt:1],@"codec",@"Websites\neLearning\nSmartPhones\nYouTube",@"usage"],
				[CPDictionary dictionaryWithObjectsAndKeys:@".flv",@"format",@"Medium Quality Flash Video (480 x 360)",@"title",[CPNumber numberWithInt:4],@"resolution",[CPNumber numberWithInt:2],@"codec",@"Websites\neLearning\nYouTube",@"usage"],
				[CPDictionary dictionaryWithObjectsAndKeys:@".mp4",@"format",@"Medium Quality MP4 (480 x 360)",@"title",[CPNumber numberWithInt:4],@"resolution",[CPNumber numberWithInt:1],@"codec",@"Websites\neLearning\nSmartphones\nYouTube",@"usage"],
				[CPDictionary dictionaryWithObjectsAndKeys:@".flv",@"format",@"Low Quality Flash Video (320 x 240)",@"title",[CPNumber numberWithInt:5],@"resolution",[CPNumber numberWithInt:2],@"codec",@"Websites",@"usage"],
				[CPDictionary dictionaryWithObjectsAndKeys:@".mp4",@"format",@"Low Quality MP4 (320 x 240)",@"title",[CPNumber numberWithInt:5],@"resolution",[CPNumber numberWithInt:1],@"codec",@"Websites\nMP3-Players",@"usage"]
	];
	
}


- (CPMutableArray)movieExportSizes
{
	return [CPMutableArray arrayWithObjects:@"1280x960",@"1024x768", @"800x600", @"640x480", @"480x360",@"320x240"];
}

- (CPMutableArray)videoFormats
{
	return [CPMutableArray arrayWithObjects:@"mpeg4",@"h.264",@"flv"];
}

- (BOOL)isKenBurns
{
	return _isKenBurns;
}

- (void)setKenBurns:(BOOL)activate
{
	_isKenBurns = activate;
}

- (void)logout
{
	SessionSharedInstance = [[Session alloc] init];
}

- (CPMutableDictionary)prefsPublish
{
	if (![_preferences containsKey:@"publish"])
	{
		[_preferences setObject:[CPMutableDictionary dictionary] forKey:@"publish"];
	}
	return [_preferences objectForKey:@"publish"];
}

- (bool)hasCompletePublishSettings
{
	try
	{
		if ([[[CPBundle mainBundle] objectForInfoDictionaryKey:@"PublishFTP"] boolValue])
		{
			if ([[self FTPServer] length] > 0 && [[self FTPUsername] length] > 0 && [[self FTPPassword] length] > 0 && [[self FTPDataDir] length] > 0)
			{
				return YES;
			}
			else
			{
				return NO;
			}
		}
		else
		{
			if ([[[CPBundle mainBundle] objectForInfoDictionaryKey:@"PublishFolder"] length])
			{
				return YES;
			}
			else
			{
				return NO;
			}
		}
	}
	catch (e)
	{
		return NO;
	}
}

- (void)setFTPServer:(CPString)server
{
	[[self prefsPublish] setObject:server forKey:@"FTPServer"];
}

- (CPString)FTPServer
{
	return [[self prefsPublish] objectForKey:@"FTPServer"];
}

- (void)setFTPUsername:(CPString)username
{
	[[self prefsPublish] setObject:username forKey:@"FTPUsername"];
}

- (CPString)FTPUsername
{
	return [[self prefsPublish] objectForKey:@"FTPUsername"];
}

- (void)setFTPPassword:(CPString)password
{
	[[self prefsPublish] setObject:password forKey:@"FTPPassword"];
}

- (CPString)FTPPassword
{
	return [[self prefsPublish] objectForKey:@"FTPPassword"];
}

- (void)setFTPDataDir:(CPString)dir
{
	[[self prefsPublish] setObject:dir forKey:@"FTPDataDir"];
}

- (CPString)FTPDataDir
{
	return [[self prefsPublish] objectForKey:@"FTPDataDir"];
}

- (void)setFTPDataURL:(CPString)url
{
	[[self prefsPublish] setObject:url forKey:@"FTPDataURL"];
}

- (CPString)FTPDataURL
{
	return [[self prefsPublish] objectForKey:@"FTPDataURL"];
}

- (void)setDefaultLength:(double)aLength
{
	[_preferences setObject:[CPNumber numberWithDouble:aLength] forKey:@"defaultLength"];
}

- (double)defaultLength
{
	if ([_preferences objectForKey:@"defaultLength"])
	{
		return [[_preferences objectForKey:@"defaultLength"] doubleValue];
	}
	else
	{
		return 180.0 * 1000;
	}
}

- (void)setDefaultSlideLength:(double)aLength
{
	[_preferences setObject:[CPNumber numberWithDouble:aLength] forKey:@"defaultSlideLength"];
}

- (double)defaultSlideLength
{
	if ([_preferences objectForKey:@"defaultSlideLength"])
	{
		return [[_preferences objectForKey:@"defaultSlideLength"] doubleValue];
	}
	else
	{
		return 8.0 * 1000;
	}
}

- (double)defaultTransitionLength
{
	if ([_preferences objectForKey:@"defaultTransitionLength"])
	{
		return [[_preferences objectForKey:@"defaultTransitionLength"] doubleValue];
	}
	else
	{
		return 1.0 * 1000;
	}
}

- (void)setDefaultTransitionLength:(double)aLength
{
	[_preferences setObject:[CPNumber numberWithDouble:aLength] forKey:@"defaultTransitionLength"];
}

- (CPString)defaultTransition
{
	if ([_preferences objectForKey:@"defaultTransition"])
	{
		return [_preferences objectForKey:@"defaultTransition"];
	}
	else
	{
		return @"crossfade";
	}
}

- (void)setDefaultTransition:(CPString)aTransition
{
	[_preferences setObject:aTransition forKey:@"defaultTransition"];
}


- (void)setProject:(CPString)project
{
	[_data setObject:project forKey:@"project"];
}

- (CPString)project
{
	return [_data objectForKey:@"project"];
}

- (void)setCaption:(CPString)aCaption forSlideAtIndex:(int)aIndex
{
	[self addUndoData];
	var slide = [self slideAtIndex:aIndex];
	if (slide)
	{
		[slide setObject:aCaption forKey:@"caption"];
	}
}

- (void)setLength:(double)aLength forSlideAtIndex:(int)aIndex
{
	[self addUndoData];
	var slide = [self slideAtIndex:aIndex];
	if (slide)
	{
		var oldLength = [[[[self slides] objectAtIndex:aIndex] objectForKey:@"length"] doubleValue];
		if (Math.round(oldLength) != Math.round(aLength))
		{
			[[[self slides] objectAtIndex:aIndex] setObject:[CPNumber numberWithDouble:aLength] forKey:@"length"];
			if (aLength > oldLength)
			{
				[self updateSlideshowLengthIfNecessary];
			}
		}
	}
}

- (void)updateSlideshowLengthIfNecessary
{
	var countedlength = 0.0;
	for (var i = 0; i < [[self slides] count]; i++)
	{
		countedlength += [[[[self slides] objectAtIndex:i] objectForKey:@"length"] doubleValue];
	}
	if (countedlength > [self slideShowLength])
	{
		[[[self data] objectForKey:@"data"] setObject:[CPNumber numberWithDouble:countedlength] forKey:@"length"];
	}
}

- (CPMutableDictionary)slideAtIndex:(int)aIndex
{
	try
	{
		slide = [[self slides] objectAtIndex:aIndex];
		return slide;
	}
	catch (e)
	{
		return nil;
	}
}

- (double)lengthForSlideAtIndex:(int)aIndex
{
	var slide = [self slideAtIndex:aIndex];
	if (slide)
	{
		return [[slide objectForKey:@"length"] doubleValue];
	}
	else
	{
		return -1;
	}
}

- (CPString)captionForSlideAtIndex:(int)aIndex
{
	var slide = [self slideAtIndex:aIndex];
	if (slide)
	{
		return [slide objectForKey:@"caption"];
	}
	else
	{
		return nil;
	}
}

- (void)setTransition:(CPString)aTransition withLength:(double)aTimeInMillis forSlideAtIndex:(int)aIndex
{
	[self addUndoData];
	var slide = [self slideAtIndex:aIndex];
	if (slide)
	{
		transition = [CPMutableDictionary dictionaryWithObjectsAndKeys:aTransition,@"type",[CPNumber numberWithDouble:aTimeInMillis],@"length"];
		[slide setObject:transition forKey:@"transition"];
	}
}

- (void)setKenBurnsWithStart:(CGRect)aStart andEnd:(CGRect)aEnd forSlideAtIndex:(int)aIndex
{
	[self addUndoData];
	var slide = [self slideAtIndex:aIndex];
	if (slide)
	{
		var kenburns = [CPMutableDictionary dictionaryWithObjectsAndKeys:
			[CPNumber numberWithDouble:aStart.origin.x],@"s.x",
			[CPNumber numberWithDouble:aStart.origin.y],@"s.y",
			[CPNumber numberWithDouble:aStart.size.width],@"s.w",
			[CPNumber numberWithDouble:aStart.size.height],@"s.h",
			[CPNumber numberWithDouble:aEnd.origin.x],@"e.x",
			[CPNumber numberWithDouble:aEnd.origin.y],@"e.y",
			[CPNumber numberWithDouble:aEnd.size.width],@"e.w",
			[CPNumber numberWithDouble:aEnd.size.height],@"e.h"
		];
		[slide setObject:kenburns forKey:@"kenburns"];
	}
}

- (void)setKenBurnsWithStart:(CGRect)aStart forSlideAtIndex:(int)aIndex
{
	[self addUndoData];
	var slide = [self slideAtIndex:aIndex];
	if (slide)
	{
		var kenburns = [slide objectForKey:@"kenburns"];
		if (!kenburns)
		{
			kenburns = [CPMutableDictionary dictionaryWithObjectsAndKeys:
				[CPNumber numberWithDouble:aStart.origin.x],@"s.x",
				[CPNumber numberWithDouble:aStart.origin.y],@"s.y",
				[CPNumber numberWithDouble:aStart.size.width],@"s.w",
				[CPNumber numberWithDouble:aStart.size.height],@"s.h"
			];
		}
		else
		{
			[kenburns setObject:[CPNumber numberWithDouble:aStart.origin.x] forKey:@"s.x"];
			[kenburns setObject:[CPNumber numberWithDouble:aStart.origin.y] forKey:@"s.y"];
			[kenburns setObject:[CPNumber numberWithDouble:aStart.size.width] forKey:@"s.w"];
			[kenburns setObject:[CPNumber numberWithDouble:aStart.size.height] forKey:@"s.h"];
		}
		[slide setObject:kenburns forKey:@"kenburns"];
	}
}

- (void)setKenBurnsWithEnd:(CGRect)aEnd forSlideAtIndex:(int)aIndex
{
	[self addUndoData];
	var slide = [self slideAtIndex:aIndex];
	if (slide)
	{
		var kenburns = [slide objectForKey:@"kenburns"];
		if (!kenburns)
		{
			kenburns = [CPMutableDictionary dictionaryWithObjectsAndKeys:
				[CPNumber numberWithDouble:aEnd.origin.x],@"e.x",
				[CPNumber numberWithDouble:aEnd.origin.y],@"e.y",
				[CPNumber numberWithDouble:aEnd.size.width],@"e.w",
				[CPNumber numberWithDouble:aEnd.size.height],@"e.h"
			];
		}
		else
		{
			[kenburns setObject:[CPNumber numberWithDouble:aEnd.origin.x] forKey:@"e.x"];
			[kenburns setObject:[CPNumber numberWithDouble:aEnd.origin.y] forKey:@"e.y"];
			[kenburns setObject:[CPNumber numberWithDouble:aEnd.size.width] forKey:@"e.w"];
			[kenburns setObject:[CPNumber numberWithDouble:aEnd.size.height] forKey:@"e.h"];
		}
		[slide setObject:kenburns forKey:@"kenburns"];
	}
}

- (BOOL)isKenBurnsForSlideAtIndex:(int)aIndex
{
	var slide = [self slideAtIndex:aIndex];
	if (slide)
	{
		var kb = [slide objectForKey:@"iskenburns"];
		if (kb)
		{
			return [kb boolValue];
		}
	}
	return NO;
}

- (void)activateKenBurns:(BOOL)isActive forSlideAtIndex:(int)aIndex
{
	var slide = [self slideAtIndex:aIndex];
	if (slide)
	{
		[slide setObject:[CPNumber numberWithBool:isActive] forKey:@"iskenburns"];
	}
}

- (CGRect)kenBurnsStartForSlideAtIndex:(int)aIndex
{
	if ([self isKenBurnsForSlideAtIndex:aIndex])
	{
		var slide = [self slideAtIndex:aIndex];
		if (slide)
		{
			var kb = [slide objectForKey:@"kenburns"];
			if (kb)
			{
				return CGRectMake([kb objectForKey:@"s.x"],[kb objectForKey:@"s.y"],[kb objectForKey:@"s.w"],[kb objectForKey:@"s.h"]);
			}
		}
	}
	return nil;
}

- (CGRect)kenBurnsEndForSlideAtIndex:(int)aIndex
{
	if ([self isKenBurnsForSlideAtIndex:aIndex])
	{
		var slide = [self slideAtIndex:aIndex];
		if (slide)
		{
			var kb = [slide objectForKey:@"kenburns"];
			if (kb)
			{
				return CGRectMake([kb objectForKey:@"e.x"],[kb objectForKey:@"e.y"],[kb objectForKey:@"e.w"],[kb objectForKey:@"e.h"]);
			}
		}
	}
	return nil;
}

- (void)removeTransitionForSlideAtIndex:(int)aIndex
{
	var slide = [self slideAtIndex:aIndex];
	if (slide)
	{
		[slide removeObjectForKey:@"transition"];
	}
}

- (CPMutableDictionary)transitionForSlideAtIndex:(int)aIndex
{
	var slide = [self slideAtIndex:aIndex];
	if (slide)
	{
		return [slide objectForKey:@"transition"];
	}
	else
	{
		return nil;
	}
}

- (void)removeAudio
{
	try
	{
		[[[[self data] objectForKey:@"data"] objectForKey:@"meta"] removeObjectForKey:@"audio"];
	}
	catch (e)
	{
		CPLog(@"%@", e);
	}
}

- (CPMutableDictionary)audio
{
	try
	{
		meta = [[[self data] objectForKey:@"data"] objectForKey:@"meta"];
		if (meta)
		{
			return [meta objectForKey:@"audio"];
		}
	}
	catch (e)
	{
		CPLog(@"%@", e);
	}
	return nil;
}

- (CPString)waveform
{
	try
	{
		var meta = [[[self data] objectForKey:@"data"] objectForKey:@"meta"];
		if (meta)
		{
			var waveform = [meta objectForKey:@"waveform"];
			if ([waveform length])
			{
				var webroot = [[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] || @"/webroot/";
				return webroot + [self projectPath] + waveform;
			}
		}
	}
	catch (e)
	{
		CPLog(@"%@", e);
	}
	return nil;
}

- (double)slideShowLength
{
	if ([[[self data] objectForKey:@"data"] objectForKey:@"length"])
	{
		return [[[[self data] objectForKey:@"data"] objectForKey:@"length"] doubleValue];
	}
	else
	{
		return [self defaultLength];
	}
}

- (void)setSlideShowLength:(double)aMillis
{
	[self addUndoData];
	var oldLength = [self slideShowLength];
	if (oldLength != aMillis)
	{
		[[[self data] objectForKey:@"data"] setObject:[CPNumber numberWithDouble:aMillis] forKey:@"length"];
		[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationLengthChanged object:nil userInfo:nil]];
	}
}

- (double)audioLength
{
	var audio = [self audio];
	if (audio)
	{
		return [[audio objectForKey:@"length"] doubleValue];
	}
	else
	{
		return 0.0;
	}
}

- (void)setData:(CPMutableDictionary)data
{
	[_data setObject:data forKey:@"projectdata"];
}

- (CPMutableDictionary)data
{
	return [_data objectForKey:@"projectdata"];
}

- (CPString)projectPath
{
	return [[_data objectForKey:@"projectdata"] objectForKey:@"path"] + "/";
}

-  (void)openPreview
{
	window.open([self previewPath], 'preview');
}

- (CPString)previewPath
{
	webroot = [[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] || @"/webroot/";
	return webroot + [self projectPath] + @"preview/";
}

- (int)numberOfSlides
{
	var slides = [self slides];
	if (slides)
	{
		return [slides count];
	}
	return 0;
}

- (CPMutableArray)slides
{
	if ([_data objectForKey:@"projectdata"] && [[_data objectForKey:@"projectdata"] objectForKey:@"data"] && [[[_data objectForKey:@"projectdata"] objectForKey:@"data"] objectForKey:@"slides"])
	{
		return [[[_data objectForKey:@"projectdata"] objectForKey:@"data"] objectForKey:@"slides"];
	}
	else
	{
		return nil;
	}
}

- (void)slides fromTime:(int)startTimeInMillis toTime:(int)endTimeInMillis
{
	slides = [self slides];
	if (!slides)
	{
		return nil;
	}
	else
	{
		var subSlides = [CPMutableArray array];
		var totaltime = 0;
		var firstTimeOver = true;
		for (var i = 0; i < [slides count]; i++)
		{
			totaltime += [[slides objectAt:i] length];
			if (totaltime >= startTimeInMillis && (totaltime < endTimeInMillis || firstTimeOver))
			{
				[subslides addObject:[slides objectAt:i]];
				if (totaltime > endTimeInMillis) firstTimeOver = false;
			}
		}
		return subSlides;
	}
}

- (int)indexForSlideAtTimeCode:(double)aTimeInMillis
{
	slides = [self slides];
	if (!slides)
	{
		return -1;
	}
	else
	{
		var totaltime = 0;
		for (var i = 0; i < [slides count]; i++)
		{
			totaltime += [[[slides objectAtIndex:i] objectForKey:@"length"] doubleValue];
			if (totaltime >= aTimeInMillis)
			{
				return i;
			}
		}
	}
	return -1;
}

- (double)percentageForSlideAtTimeCode:(double)aTimeInMillis
{
	slides = [self slides];
	if (!slides)
	{
		return -1;
	}
	else
	{
		var totaltime = 0;
		for (var i = 0; i < [slides count]; i++)
		{
			var slidelength = [[[slides objectAtIndex:i] objectForKey:@"length"] doubleValue];
			totaltime += slidelength
			if (totaltime >= aTimeInMillis)
			{
				var delta = aTimeInMillis-(totaltime-slidelength);
				return delta/slidelength;
			}
		}
	}
	return 0.0;
}

- (double)timeCodeForSlideAtIndex:(int)aIndex
{
	var timecode = 0;
	if (aIndex >= 0)
	{
		slides = [self slides];
		if (slides)
		{
			for (var i = 0; i < aIndex; i++)
			{
				slide = [slides objectAtIndex:i];
				if (slide)
				{
					timecode += [[slide objectForKey:@"length"] doubleValue];
				}
			}
		}
	}
	return timecode;
}

- (CPImage)imageForSlideAtIndex:(int)aIndex
{
	if (aIndex >= 0)
	{
		slides = [self slides];
		if ([slides count]>0 && aIndex < [slides count])
		{
			slide = [slides objectAtIndex:aIndex];
			if (slide)
			{
				var image = [_imageCache objectForKey:[slide objectForKey:@"file"]];
				if (image == nil)
				{
					webroot = [[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] || @"/webroot/";
					filename = webroot + [self projectPath] + @"640/" + [slide objectForKey:@"file"];
					image = [[CPImage alloc] initWithContentsOfFile:filename];
					[_imageCache setObject:image forKey:[slide objectForKey:@"file"]];
				}
				return image;
			}
		}
	}
	return nil;
}
 
- (CPImage)thumbnailForSlideAtIndex:(int)aIndex
{
	if (aIndex >= 0)
	{
		slides = [self slides];
		if (slides)
		{
			slide = [slides objectAtIndex:aIndex];
			if (slide)
			{
				var image = [_imageCache objectForKey:[slide objectForKey:@"file"] + @".thumb.jpg"];
				if (image == nil)
				{
					webroot = [[CPBundle mainBundle] objectForInfoDictionaryKey:@"WebRoot"] || @"/webroot/";
					filename = webroot + [self projectPath] + @"thumbs/" + [slide objectForKey:@"file"];
					image = [[CPImage alloc] initWithContentsOfFile:filename];
					[_imageCache setObject:image forKey:[slide objectForKey:@"file"] + @".thumb.jpg"];
					
				}
				return image;
			}
		}
	}
	return nil;
}

- (void)setImageIndex:(int)aIndex
{
	[self setImageIndex:aIndex withNotification:YES];
	if (aIndex == -1) [[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationNoSlideSelected object:nil userInfo:nil]];
	
}

- (void)setImageIndex:(int)aIndex withNotification:(BOOL)aNotification
{
	if (aIndex >= 0)
	{
		[_data setObject:[CPNumber numberWithInt:aIndex] forKey:@"imageindex"];
		if (aNotification)
		{
			[[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationSlideSelected object:nil userInfo:[CPDictionary dictionaryWithObjectsAndKeys:[CPNumber numberWithInt:aIndex], @"slide"]]];
		}
	}
	else
	{
		[_data removeObjectForKey:@"imageindex"];
	}
	if (aIndex == -1) [[CPNotificationCenter defaultCenter] postNotification:[CPNotification notificationWithName:CPNotificationNoSlideSelected object:nil userInfo:nil]];
}

- (int)imageIndex
{
	if ([_data objectForKey:@"imageindex"] != nil)
	{
		return [[_data objectForKey:@"imageindex"] intValue];
	}
	else
	{
		return -1;
	}
}

- (BOOL)hasSID
{
	return ([self SID] == nil || [[self SID] length] == 0) ? false : true;
}

- (CPString)username
{
	return [_data objectForKey:@"username"];
}

- (void)setUsername:(CPString)name
{
	[_data setObject:name forKey:@"username"];
}

- (CPString)mail
{
	return [_data objectForKey:@"mail"];
}

- (void)setMail:(CPString)name
{
	[_data setObject:name forKey:@"mail"];
}

- (BOOL)hasUsername
{
	return ([self username] == nil || [[self username] length] == 0) ? false : true;
}

@end
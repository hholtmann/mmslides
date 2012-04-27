/*
 * AudioPlayer.j
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


@import <Foundation/CPObject.j>
@import <AppKit/CPView.j>

@implementation AudioPlayer : CPView
{
	DOMElement 	_DOMEmbedElement;
	DOMElement  _DOMMParamElement;
	DOMElement  _DOMObjectElement;
	CPString 	_audioPath;
	CPString	_flashId;
	float		_currentTime;
	id			_delegate @accessors(property=delegate);
	BOOL _paused;
	float _audioLength;
	BOOL _loaded;
		
	//flash support
	BOOL		isLoaded;
	Object      soundManager;
	int _intervalID;
	id _progressLabel @accessors(property=progressLabel);
	
}


//init
- (id)initWithFrame:(CGRect)aFrame
{
	self = [super initWithFrame:aFrame]
	CPLog(@"create new audioPlayer");
	if (self)
	{
		soundManager = nil;
		[self initDomObject];
		_paused = YES;
		_loaded = NO;
		_flashId = "noSoundFileLoaded";
		_audioLength = [[Session sharedSession] defaultLength];
	}
	return self;
}

- (void)initDomObject
{
	if ([self hasHTML5Support] == YES) 
	{
		_DOMObjectElement = document.createElement("audio");
		_DOMObjectElement.setAttribute("controls", "false");
		_DOMObjectElement.setAttribute("autobuffer", "true");
		_DOMObjectElement.setAttribute("preload", "auto");
		_DOMObjectElement.setAttribute("id", [self id]);
		_DOMElement.appendChild(_DOMObjectElement);
		_DOMObjectElement.addEventListener("ended", function() { [self playBackEnded]; }, true);  
		_DOMObjectElement.addEventListener("canplay", function() { [self audioLoaded]; }, true);  	
		CPLog(@"Initialized HTML5 Audio Player");
	} else {
		window.setTimeout(setupSoundManager, 1000, self);
		CPLog(@"Initalizing Flash Audio Player");	
	}
}

- (BOOL) hasHTML5Support
{	
	if (navigator.userAgent.match(/applewebKit/i))
	{	
		return YES;
	} else if (navigator.userAgent.match(/Gecko/i)) {
		return YES;
		/*
		if (window.globalStorage && window.getSelection().modify) {
			return YES;
		} else {
			return NO;
		}
		*/
	} else {
		return NO;
	}
}

-(void)initFlashAudioTrack
{
	CPLog(@"Init flash audio Track with id:"+ [self flashId]);
	var soundTrack = soundManager.createSound({
		id: [self flashId],
		url: _audioPath,
		volume: 100,
		autoLoad: true,
		whileloading: function() {[self audioLoaded];},
		onfinish: function() {[self playBackEnded];}
	});
}

//Event Handling
- (void)soundManagerDidLoad:(Object)aManager
{
	isLoaded = YES;
	soundManager = aManager;
	[self initFlashAudioTrack];
	CPLog(@"Soundmanager did load");
}

- (BOOL)isPlaying
{
	return !_paused;
}

-(void) setProgressLabel
{
	var time = [self currentTime];
	if (_progressLabel)
	{
		[_progressLabel setStringValue:[CPString stringWithFormat:@"%02d:%02d.%d", time/60, time % 60, (time * 10)%10]];
	}
}

-(float) updatePlayProgress
{
	if (!_paused)
	{
		if ([self audioObjJS] && [self audioObjJS].currentTime>0) {
			if ([self hasHTML5Support] == YES) {		
				[_delegate updatePlayProgress:[self audioObjJS].currentTime];
			} else {
				[_delegate updatePlayProgress:([self audioObjJS].position/1000)];
			}
		} else {
			[_delegate updatePlayProgress:_currentTime];
		}
		_currentTime += 0.1;
		[self setProgressLabel];
		if (_currentTime > [[Session sharedSession] slideShowLength]/1000.0)
		{
			[self setCurrentTime:0];
		}
	}
}

- (void)reset
{
	if ([self audioLength] > 0)
	{
		if (!_paused)
		{
			[self pause];
			[_delegate playPause:nil];
		}
		if (_currentTime != 0) [self setCurrentTime:0];
	}
	_audioPath = nil;
}


-(void) audioLoaded
{
	_DOMObjectElement.removeEventListener("canplay", function() { [self audioLoaded]; }, true);  	
	if (_loaded == NO) {
		CPLog(@"@@@@@@@@@@@@@@@@@@@@@@ audioTrack loaded audio loaded with " + _loaded);
		_loaded = YES;
		if ([self hasHTML5Support] == YES) 
		{
			[_delegate audioLoaded:self]
		} else {
			CPLog(@"Duration: %.2f",[self audioLength]);
			if ([self audioObjJS].bytesLoaded == [self audioObjJS].bytesTotal) {
				CPLog(@"FlashPlayer - loading of sound file complete");
				[_delegate audioLoaded:self]
			}
		}
	} else {
		CPLog(@"Ignoring load event");
	}
}

-(void) playBackEnded
{
	CPLog(@"Playback ended");
//	[self setCurrentTime:0.0];
	[_delegate playBackEnded:self]
}


- (void) play
{
	_paused = NO;
	if ([self audioObjJS] && _audioPath)
	{
		[self audioObjJS].play();
	}
	_intervalID = window.setInterval(function() { [self updatePlayProgress]; }, 100);
}

- (void)pause
{
	_paused = YES;
	if ([self audioObjJS] && _audioPath)
	{
		[self audioObjJS].pause();	
	}
	window.clearInterval(_intervalID);
}

//Getter and Setter

- (id) audioObjJS
{
	if ([self hasHTML5Support] == YES) 
	{
		return document.getElementById([self id]);
	}
	else if (soundManager)
	{
		return soundManager.getSoundById([self flashId]);
	}
	else
	{
		return nil;
	}
}

- (CPString) id
{
	return @"audioPlayer";
}

- (CPString) flashId
{
	return _flashId;
}

-(vod)setFlashId:(CPString)flashid
{
	_flashId = flashid;
}

- (void)setAudioLength:(float)aLength
{
	_audioLength = aLength;
}

- (float) audioLength
{
	if ([self audioObjJS] && _audioPath)
	{
		return [self audioObjJS].duration;
	}
	else
	{
		return _audioLength;
	}
}

- (void)setCurrentTime:(float)time
{	
	if ([self audioObjJS] && _audioPath)
	{
		if (time < [self audioLength])
		{
			if ([self hasHTML5Support] == YES) 
			{
				CPLog(@"Set current time to %@",time);
				[self audioObjJS].currentTime = time;
			} 
			else 
			{
				[self audioObjJS].setPosition(time*1000);
			}
			if (!_paused && [self hasHTML5Support] == YES)
			{
				CPLog(@"Activating play");
			//	[self audioObjJS].play();	
			}
		}
		else
		{
			[self audioObjJS].pause();	
		}
	}
	_currentTime = time;
	[self updatePlayProgress];
}

- (float)currentTime
{
	return _currentTime;
}


- (void) setAudioPath:(CPString)path
{
//	CPLog(@"set audio path %@", path);
	[self reset];
	_loaded = NO;
	_audioPath = path;
	if (_audioPath != nil)
	{
		if ([self hasHTML5Support] == YES) 
		{
			if (navigator.userAgent.match(/gecko/i) && !navigator.userAgent.match(/applewebKit/i)) {
				path = path.substr(0, path.lastIndexOf(".")) + ".ogg";
				CPLog(@"The path" + path);
			}
			[self audioObjJS].src = path;
			[self audioObjJS].load();	
		} 
		else 
		{
			_flashId = [path lastPathComponent];
			[self initFlashAudioTrack];
		}
	}
	[_delegate updatePlayProgress:0];
}

- (CPString)audioPath
{
	if ([self audioObjJS] && _audioPath)
	{
		return [self audioObjJS].src;
	}
	else
	{
		return nil;
	}
}

@end



var setupSoundManager = function(obj)
{
	var script = document.createElement("script");

	script.type = "text/javascript";
	script.src = "flash/soundmanager2.js";

	if (script.addEventListener)
	{  
		CPLog(@"Starting soundmanager with addEventListener");
		script.addEventListener("load", function()
		{
			soundManager.url = "flash/"; // path to directory containing SoundManager2 .SWF file
			soundManager.onload = function() {
	            [obj soundManagerDidLoad:soundManager];            
			};
	        soundManager.beginDelayedInit();
			soundManager.debugMode = false;
		}, YES);	
	} 
	else if (script.attachEvent)
	{  
		CPLog(@"###COMPAT = > Starting soundmanager with attachEvent");
		script.attachEvent("onreadystatechange", function()
		{
			if ((script.readyState == "loaded" || script.readyState == "complete")){
				    this.onreadystatechange = null;
					soundManager.url = "flash/"; // path to directory containing SoundManager2 .SWF file
					soundManager.onload = function() {
			            [obj soundManagerDidLoad:soundManager];            
					};
			        soundManager.beginDelayedInit();
					soundManager.debugMode = false;
			}
		});	
	}

	document.getElementsByTagName("head")[0].appendChild(script);
}
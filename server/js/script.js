/*
 * script.js
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


var json;
var slideArray;
var projectTitle;
var max_images;
var slideshowLength = 0;
var slideshow_width = 800;
var slideshow_height = 600;
var resolution = 320;
var customTime;
var showCaptions;
var playtime;
var _isPlaying = false;
var audio = null;
var isAudio = false;
var supportCanvas;
var runningTime = 0;
var autoPlay = false;
var currentSlide = null;
var slideCounter = 0;
var transitionSlide = null;
var isIOS = false;
var isIPad = false;
var isIPhone = false;
var isAndroid = false;
var isTouch = false;
var loop = true;
var default_visibility = 5000;
var controlTimer = null;
var passwordField = null;
var tips = null;

$(window).load(function()
{
	passwordField = $( "#password" );
	tips = $( ".validateTips" );
	$( "#dialog:ui-dialog" ).dialog( "destroy" );
	$('#dialog-form').find('input').keypress(function(e) {
		if ((e.which && e.which == 13) || (e.keyCode && e.keyCode == 13)) 
		{
			$(this).parent().parent().parent().parent().find('.ui-dialog-buttonpane').find('button:first').click(); /* Assuming the first one is the action button */
			return false;
		}
	});
	$( "#dialog-form" ).dialog({
		autoOpen: false,
		height: 200,
		width: 350,
		modal: true,
		buttons: {
			" OK ": function() {
				var bValid = true;
				passwordField.removeClass( "ui-state-error" );

				bValid = bValid && checkLength( passwordField, "password", 1, 32 );
				if (passwordField.val().length > 0)
				{
					var pwdcheck = ($().crypt({ method: "md5", source: passwordField.val() }) == json.slideshow.password);
					bValid = bValid && pwdcheck;
					if (!pwdcheck) updateTips("Wrong password!");
				}
				
				if ( bValid ) 
				{
					$( "#users tbody" ).append( "<tr>" +
						"<td>" + passwordField.val() + "</td>" +
					"</tr>" ); 
					$( this ).dialog( "close" );
					continueWithStartup();
				}
			}
		},
		close: function() {
			passwordField.val( "" ).removeClass( "ui-state-error" );
		}
	});

	$.getJSON("./config/jsonconfig.js", {}, function(json_data) 
	{
		json = json_data;
		projectTitle = json.project;
		slideArray = json.data.slides;
		max_images = json.data.slides.length;
		slideshowLength = json.data.length;
		loop = json.slideshow.loop;
		showCaptions = json.slideshow.showCaptionsByDefault;
		
		if (json.slideshow.protect)
		{
			$( "#dialog-form" ).dialog( "open" );
		}
		else
		{
			continueWithStartup();
		}
	});	

	function continueWithStartup()
	{
		autoPlay = json.slideshow.autoPlay;
		var preloadimages = new Array();
		var timestamp = 0;
		isIPhone = RegExp("iPhone").test(navigator.userAgent);
		isIPad = RegExp("iPad").test(navigator.userAgent);
		isIOS = (isIPhone || isIPad);
		
		if (!isIOS) {
			document.location.href = "_index_computer.html";
			return;
		}
		
		if (isIPhone)
		{
			resolution = 640;
			switch(window.orientation)
			{
				case 0:
				case 180:
					slideshow_width = 320;
					slideshow_height = 240;
					break; 
				case -90:
				case 90:
					slideshow_width = 360;
					slideshow_height = 270;
					break; 
			}
		}
		else if (isIPad)
		{
			resolution = 1024;
			switch(window.orientation)
			{
				case 0:
				case 180:
					slideshow_width = 768;
					slideshow_height = 576;
					break; 
				case -90:
				case 90:
					slideshow_width = 900;
					slideshow_height = 675;
					break; 
			}
		}
		else
		{
			resolution = json.slideshow.width;
			slideshow_width = json.slideshow.width;
			slideshow_height = json.slideshow.height;
		}
		$('#slideshow ul').css('width', slideshow_width + 'px');
		$('#slideshow ul').css('height', slideshow_height + 'px');
		$('#slideshow li').css('width', slideshow_width + 'px');
		$('#slideshow li').css('height', slideshow_height + 'px');
		$('div.controls').css('top', Math.round(slideshow_height/2 - 23) + 'px');
		$.each(slideArray, function(i, slide)
		{
			slideArray[i].timestamp = timestamp;
			slideArray[i].slideIndex = i;
			timestamp += slide.length;
			if (i < 2)
			{
				$('.slides').append($('<li />').append($('<img />').attr('src', './images/' + resolution + '/' + slide.file).attr('width', slideshow_width).attr('height', slideshow_height).attr('id', i)));
			}
		});
		setCurrentSlide(slideArray[0]);
		isAndroid = RegExp("Android").test(navigator.userAgent);
		isTouch = (isIOS || isAndroid);
		if (isIOS || isAndroid) 
		{
			var addHeader = '<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1.0;" />';
			if (isIOS)
			{
		    addHeader += '<meta name="apple-mobile-web-app-capable" content="yes" />';
		    addHeader += '<meta name="apple-touch-fullscreen" content="yes" />';
		    addHeader += '<meta name="apple-mobile-web-app-status-bar-style" content="none" />';
		    addHeader += '<link rel="apple-touch-icon" href="icons/slideshow.png" />';
		  }
		  $("head").append($(addHeader));
		  $(document).bind("touchmove", touchmove);
		  $(document).bind("touchstart", touchmove);
		}
		else
		{
		  $(document).bind("mousemove", touchmove);
		}
		$('body').bind("orientationchange", function(e) {
			switch(window.orientation)
			{
				case 0:
			  	changeOrientation(true);
			  	break; 
				case 180:
					changeOrientation(true);
					break; 
				case -90:
					changeOrientation(false);
					break; 
				case 90:
					changeOrientation(false);
					break; 
			}

		});
		generateStyles();
		if (isIPhone) 
		{
			setTimeout(function () {
			  window.scrollTo(0, 1);
			}, 1000);
		}
		$('.button_left_n').bind('click', previousClicked);
		$('.button_right_n').bind('click', nextClicked);
		kenburns(0, 0, 0);
		kenburns(1, 1, 0);
		initPlayButton();
		if (json.data.meta && json.data.meta.audio)
		{
			
			audio = $('<div id="audio" />')
			audio.appendTo('body');
			audio.jPlayer( {
				ready: function () {
					$(this).jPlayer("setMedia", {
						mp3: './audio/' + json.data.meta.audio.file
					});
					isAudio = true;
					//if (autoPlay) playClicked(null);
				},
				preload: "auto"
			});
		}
	}
	
	function changeOrientation(portrait)
	{
		var newwidth = slideshow_width;
		var newheight = slideshow_height;
		if (isIPhone)
		{
			if (portrait)
			{
				// iphone portrait
				newwidth = 320;
				newheight = 240;
			}
			else
			{
				// iphone landscape
				newwidth = 360;
				newheight = 270;
			}
		}
		else if (isIPad)
		{
			if (portrait)
			{
				// ipad portrait
				newwidth = 768;
				newheight = 576;
			}
			else
			{
				// ipad landscape
				newwidth = 900;
				newheight = 675;
			}
		}

		$('#slideshow ul').css('width', newwidth + 'px');
		$('#slideshow li').css('width', newwidth + 'px');
		$('#slideshow ul').css('height', newwheight + 'px');
		$('#slideshow li').css('height', newheight + 'px');
		$('#slideshow li').find('img').attr('width', newwidth + 'px');
		$('#slideshow li').find('img').attr('height', newheight + 'px');
		$('div.controls').css('top', Math.round(newheight/2 - 23) + 'px');

		slideshow_height = parseInt($('#slideshow ul').css('height'));
		slideshow_width = parseInt($('#slideshow ul').css('width'));
		
		$('#mmslidestyles').remove();
		generateStyles();
		
		setTimeout(function () {
		  window.scrollTo(0, 1);
		}, 1000);

		var index = parseInt($('#slideshow li').eq(0).find('img').attr('id'));
		gotoSlide(index);
	}
	
	function initPlayButton()
	{
		$('.button_pp').removeClass('button_pause_n');
		$('.button_pp').addClass('button_play_n');
		$('.button_pp').unbind('click');
		$('.button_play_n').bind('click', playClicked);
	}

	function initPauseButton()
	{
		$('.button_pp').removeClass('button_play_n');
		$('.button_pp').addClass('button_pause_n');
		$('.button_pp').unbind('click');
		$('.button_pause_n').bind('click', pauseClicked);
	}
	
	function playClicked(e)
	{
		$('.button_pp').removeClass('button_play_n');
		$('.button_pp').addClass('button_pause_n');
		$('.button_pp').unbind('click');
		$('.button_pp').bind('click', pauseClicked);
		showControls();
		play();
	}
	
	function pauseClicked(e)
	{
		$('.button_pp').removeClass('button_pause_n');
		$('.button_pp').addClass('button_play_n');
		$('.button_pp').unbind('click');
		$('.button_pp').bind('click', playClicked);
		showControls();
		pause();
	}
	
	function nextClicked(e)
	{
		showControls();
		var index = parseInt($('#slideshow li').eq(0).find('img').attr('id'));
		var nextindex = findNextIndex(index);
		if (nextindex > -1)
		{
			gotoSlide(nextindex);
		}
	}
	
	function previousClicked()
	{
		showControls();
		var index = parseInt($('#slideshow li').eq(0).find('img').attr('id'));
		var previousIndex = index-1;
		if (previousIndex > -1)
		{
			gotoSlide(previousIndex);
		}
	}

	function nextSlide()
	{
		var slides = $('#slideshow li');
		var current = slides.eq(0);
		var next = slides.eq(1);
		setCurrentSlide(slideArray[next.find('img').attr('id')]);
		if (transitionSlide != null)
		{
			if (transitionSlide.transition.type == 'crossfade')
			{
				current.find('img').bind('webkitTransitionEnd', function(e){
					updateSlidePair();
				});
				current.find('img').css('-webkit-transition-property', 'opacity');
				current.find('img').css('-webkit-transition-duration', transitionSlide.transition.length/1000 + 's');
				current.find('img').css('opacity', '0');
			}
			else if (transitionSlide.transition.type == 'fade')
			{
				current.find('img').bind('webkitTransitionEnd', function(e){
					next.find('img').bind('webkitTransitionEnd', function(e){
						next.find('img').unbind('webkitTransitionEnd');
						updateSlidePair();
					});
					next.find('img').css('-webkit-transition-property', 'opacity');
					next.find('img').css('-webkit-transition-duration', transitionSlide.transition.length/2000 + 's');
					next.find('img').css('opacity', '100');
				});
				next.find('img').css('opacity', '0');
				current.find('img').css('-webkit-transition-property', 'opacity');
				current.find('img').css('-webkit-transition-duration', transitionSlide.transition.length/2000 + 's');
				current.find('img').css('opacity', '0');
			}
			else if (transitionSlide.transition.type == 'straightcut')
			{
				current.bind('webkitAnimationEnd', function(e){
					updateSlidePair();
				});
				current.css('-webkit-animation-name', 'slideout_' + transitionSlide.slideIndex);
				current.css('-webkit-animation-duration', transitionSlide.transition.length/1000 + 's');
				next.css('-webkit-animation-name', 'slidein_' + transitionSlide.slideIndex);
				next.css('-webkit-animation-duration', transitionSlide.transition.length/1000 + 's');
			}
			else
			{
				next.addClass('slideActive').show();
				current.removeClass('slideActive').hide();
				updateSlidePair();
			}
		}
		else
		{
			next.addClass('slideActive').show();
			current.removeClass('slideActive').hide();
			updateSlidePair();
		}
	}
	
	function setCurrentSlide(slide)
	{
		currentSlide = slide;
		if (showCaptions)
		{
			var caption = null;
			if ($('#caption'))
			{
				$('#caption').remove();
			}
			if (currentSlide != null)
			{
				if (currentSlide.caption.length > 0)
				{
					var capheight = Math.round(slideshow_height / 5.0);
					var fontsize = Math.round(slideshow_height/15.0);
					if (fontsize > 36) fontsize = 36;
					caption = $('<div id="caption" style="z-index: 9000; position: absolute; width: 100%; height: ' + capheight + 'px; top: ' + (slideshow_height-capheight-10) + 'px; left: 0px;" />');
					caption.append($('<div style="position: fixed; border: none; background-color: black; opacity: 0.4; left: 0px; top: ' + (slideshow_height-capheight-10) + 'px; height: ' + capheight + 'px; width: 100%;"></div><div style="position: fixed; color: white; text-align: center; font-size: ' + fontsize + 'px; font-weight: bold; top: ' + (slideshow_height-capheight-10) + 'px; left: 0px; height: ' + capheight + 'px; width: 100%; padding: 15px;">' + currentSlide.caption + '</div>'));
					$('body').append(caption);
				}
			}
		}
	}
	
	function findNextIndex(index)
	{
		var nextindex = index+1;
		if (nextindex > slideArray.length-1) 
		{ 
			if (loop)
			{
				nextindex = 0;
			}
			else
			{
				return -1;
			}
		}
		return nextindex;
	}

	function gotoSlide(index)
	{
		$('.slides').empty();
		var slide = slideArray[index];
		$('.slides').append($('<li />').append($('<img />').attr('src', './images/' + resolution + '/' + slide.file).attr('width', slideshow_width).attr('height', slideshow_height).attr('id', index)));
		runningTime = slide.timestamp;
		if (isAudio)
		{
			if (_isPlaying) audio.jPlayer("play", runningTime/1000);
		} 
		var nextindex = findNextIndex(index);
		if (nextindex > -1)
		{
			var slide = slideArray[nextindex];
			$('.slides').append($('<li />').append($('<img />').attr('src', './images/' + resolution + '/' + slide.file).attr('width', slideshow_width).attr('height', slideshow_height).attr('id', nextindex)));
			kenburns(index, 0, 1);
			kenburns(nextindex, 1, 0);
		}
		else if (nextindex == 0)
		{
			var slide = slideArray[nextindex];
			$('.slides').append($('<li />').append($('<img />').attr('src', './images/' + resolution + '/' + slide.file).attr('width', slideshow_width).attr('height', slideshow_height).attr('id', nextindex)));
			kenburns(nextindex, 1, 0);
		}
		else if (nextindex < 0)
		{
			$('.slides').append($('<li />').append($('<img />').attr('src', './icons/no_img.png').attr('width', slideshow_width).attr('height', slideshow_height).attr('id', nextindex)));
			kenburns(index, 0, 1);
			kenburns(nextindex, 1, 0);
			setCurrentSlide(null);
		}
	}

	function updateSlidePair()
	{
		$('#slideshow li').eq(0).remove();
		var index = parseInt($('#slideshow li').eq(0).find('img').attr('id'));
		var nextindex = findNextIndex(index);
		if (nextindex < 0)
		{
			$('.slides').append($('<li />').append($('<img />').attr('src', './icons/no_img.png').attr('width', slideshow_width).attr('height', slideshow_height).attr('id', nextindex)));
			kenburns(index, 0, 1);
			kenburns(nextindex, 1, 0);
			setCurrentSlide(null);
		}
		else
		{
			var slide = slideArray[nextindex];
			if (nextindex > 0)
			{
				$('.slides').append($('<li />').append($('<img />').attr('src', './images/' + resolution + '/' + slide.file).attr('width', slideshow_width).attr('height', slideshow_height).attr('id', nextindex)));
				kenburns(index, 0, 1);
				kenburns(nextindex, 1, 0);
			}
			else if (nextindex == 0)
			{
				$('.slides').append($('<li />').append($('<img />').attr('src', './images/' + resolution + '/' + slide.file).attr('width', slideshow_width).attr('height', slideshow_height).attr('id', nextindex)));
				kenburns(nextindex, 1, 0);
			}
		}
	}
	
	function kenburns(index, slot, stage)
	{
		var activeSlide = slideArray[index];
		if (activeSlide.iskenburns != null && activeSlide.iskenburns && activeSlide.kenburns != null)
		{
			var w_n = 459.0;
			var h_n = 344.0;
			var factor = slideshow_width/w_n;
			var w_s = parseFloat(activeSlide.kenburns['s.w']);
			var h_s = parseFloat(activeSlide.kenburns['s.h']);
			var scale_s = w_n/w_s;
			var w_e = parseFloat(activeSlide.kenburns['e.w']);
			var h_e = parseFloat(activeSlide.kenburns['e.h']);
			var scale_e = w_n/w_e;
			var s_x = parseFloat(activeSlide.kenburns['s.x']);
			var s_y = parseFloat(activeSlide.kenburns['s.y']);
			var e_x = parseFloat(activeSlide.kenburns['e.x']);
			var e_y = parseFloat(activeSlide.kenburns['e.y']);
			var c_x_n = w_n/2.0;
			var c_y_n = h_n/2.0;
			var c_x_s = s_x + w_s/2.0;
			var c_y_s = s_y + h_s/2.0;
			var c_x_e = e_x + w_e/2.0;
			var c_y_e = e_y + h_e/2.0;
			var d_x_s = (c_x_n - c_x_s)*factor;
			var d_y_s = -(c_y_n - (h_n-c_y_s))*factor;
			var d_x_e = (c_x_n - c_x_e)*factor;
			var d_y_e = -(c_y_n - (h_n-c_y_e))*factor;
			switch (stage)
			{
				case 0:
					// start
					$('#slideshow li').eq(slot).find('img').css('-webkit-transform', 'scale('+scale_s+') translate('+Math.round(d_x_s)+'px,'+Math.round(d_y_s)+'px)');
					break;
				case 1:
				  // animation
					$('#slideshow li').eq(slot).find('img').css('-webkit-animation-name', 'kenburns_' + activeSlide.slideIndex);
					var transitionlength = 0;
					if (activeSlide.transition)
					{
						transitionlength = activeSlide.transition.length;
					}
					$('#slideshow li').eq(slot).find('img').css('-webkit-animation-duration', ((activeSlide.length-transitionlength-250)/1000) + 's');
					$('#slideshow li').eq(slot).find('img').bind('webkitAnimationEnd', function(e){
					  $('#slideshow li').eq(slot).find('img').css('-webkit-transform', 'scale('+scale_e+') translate('+Math.round(d_x_e)+'px,'+Math.round(d_y_e)+'px)');
					});
					break;
				case 2:
				  // end
				  $('#slideshow li').eq(slot).find('img').css('-webkit-transform', 'scale('+scale_e+') translate('+Math.round(d_x_e)+'px,'+Math.round(d_y_e)+'px)');
				  break;
			}
		}
	}

	function generateStyles()
	{
		var styles = $('<style id="mmslidestyles" type="text/css" />');
		$.each(slideArray, function(i, slide)
		{
			if (slide.iskenburns && slide.kenburns)
			{
				var w_n = 459.0;
				var h_n = 344.0;
				var factor = slideshow_width/w_n;
				var w_s = parseFloat(slide.kenburns['s.w']);
				var h_s = parseFloat(slide.kenburns['s.h']);
				var scale_s = w_n/w_s;
				var w_e = parseFloat(slide.kenburns['e.w']);
				var h_e = parseFloat(slide.kenburns['e.h']);
				var scale_e = w_n/w_e;
				var s_x = parseFloat(slide.kenburns['s.x']);
				var s_y = parseFloat(slide.kenburns['s.y']);
				var e_x = parseFloat(slide.kenburns['e.x']);
				var e_y = parseFloat(slide.kenburns['e.y']);
				var c_x_n = w_n/2.0;
				var c_y_n = h_n/2.0;
				var c_x_s = s_x + w_s/2.0;
				var c_y_s = s_y + h_s/2.0;
				var c_x_e = e_x + w_e/2.0;
				var c_y_e = e_y + h_e/2.0;
				var d_x_s = (c_x_n - c_x_s)*factor;
				var d_y_s = -(c_y_n - (h_n-c_y_s))*factor;
				var d_x_e = (c_x_n - c_x_e)*factor;
				var d_y_e = -(c_y_n - (h_n-c_y_e))*factor;
				styles.append('@-webkit-keyframes kenburns_' + i + ' {	0% {-webkit-transform:scale('+scale_s+') translate('+Math.round(d_x_s)+'px,'+Math.round(d_y_s)+'px);} 100% {-webkit-transform:scale('+scale_e+') translate('+Math.round(d_x_e)+'px,'+Math.round(d_y_e)+'px);} }');
			}
			if (slide.transition)
			{
				if (slide.transition.type == 'straightcut')
				{
				  styles.append('@-webkit-keyframes slideout_' + i + ' {	from { left: 0;	}	to { left: -' + slideshow_width + 'px; } } @-webkit-keyframes slidein_' + i + '	{	from { left: ' + slideshow_width + 'px; }	to { left: 0; } }');
				}
			}
		});
		styles.appendTo('head');
	}
	
	function getSlideForTime(timeInMillis)
	{
		var result = null;
		$.each(slideArray, function(i, slide)
		{
			if (timeInMillis >= slide.timestamp)
			{
				result = slide;
				return result;
			}
		});
		return result;
	}
	
	function updatePlayProgress()
	{
		runningTime += 100;
		var slide = getSlideForTime(runningTime);
		if (slide == null || runningTime > slideshowLength)
		{
			runningTime = 0;
			if (isAudio)
			{
				if (_isPlaying) audio.jPlayer("play", 0);//audio.currentTime = runningTime/1000;
			} 
		}
		else
		{
			if ((slide.transition != null && runningTime >= (slide.timestamp + slide.length - slide.transition.length)))
			{
				var changeToNext = (transitionSlide != slide) ? true : false;
				transitionSlide = slide;
				if (changeToNext) nextSlide();
			}
			else if (slide != currentSlide)
			{
				transitionSlide = null;
				// only change to the next slide when the previous slide had no transition
				var changeToNext = (currentSlide != null && currentSlide.transition != null && currentSlide.transition.length > 0) ? false : true;
				if (changeToNext) nextSlide();
			}
		}
	}
	
	function showControls()
	{
		$('.controls').fadeIn();
		if (controlTimer != null) clearTimeout(controlTimer);
		controlTimer = setInterval(function() { hideControls(); }, default_visibility);
	}
	
	function hideControls()
	{
		$('.controls').fadeOut();
		if (controlTimer != null) clearTimeout(controlTimer);
	}
	
	function touchmove(e)
	{
		showControls();
	}

	/**
	* start the slideshow
	*/
	function play()
	{
		kenburns(0, 0, 1);
		_isPlaying = true;
		$('#slideshow li').eq(0).find('img').css('-webkit-animation-play-state', 'running');
		$('#slideshow li').eq(1).find('img').css('-webkit-animation-play-state', 'running');
		$('#slideshow li').eq(0).css('-webkit-animation-play-state', 'running');
		$('#slideshow li').eq(1).css('-webkit-animation-play-state', 'running');
		playtime = setInterval(function() { updatePlayProgress(); }, 100);
		if (isAudio)
		{
			if (_isPlaying) audio.jPlayer("play", runningTime/1000);
		} 
	}
	
	function pause()
	{
		_isPlaying = false;
		clearTimeout(playtime);
		$('#slideshow li').eq(0).find('img').css('-webkit-animation-play-state', 'paused');
		$('#slideshow li').eq(1).find('img').css('-webkit-animation-play-state', 'paused');
		$('#slideshow li').eq(0).css('-webkit-animation-play-state', 'paused');
		$('#slideshow li').eq(1).css('-webkit-animation-play-state', 'paused');
		if (isAudio) audio.jPlayer("pause");//audio.pause();
	}

	function updateTips( t ) 
	{
		tips.text( t ).addClass( "ui-state-highlight" );
	}

	function checkLength( o, n, min, max ) {
		if ( o.val().length > max || o.val().length < min ) {
			o.addClass( "ui-state-error" );
			updateTips( "Length of " + n + " must be between " +
				min + " and " + max + "." );
			return false;
		} else {
			return true;
		}
	}

	function checkRegexp( o, regexp, n ) 
	{
		if ( !( regexp.test( o.val() ) ) ) {
			o.addClass( "ui-state-error" );
			updateTips( n );
			return false;
		} else {
			return true;
		}
	}

});
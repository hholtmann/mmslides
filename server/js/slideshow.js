/*
 * slideshow.js
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


$(function() {
var json;
var playtime;
var customTime;
var totaltime;
var current 			= -1;
var last = -1;
var current_thumb 		= 0;
var thumb_page = 0;
var max_images = 0;
var slides;
var _isPlaying = false;
var _wasPlayingBeforeDrag = false;
var images = new Array();
var thumbs = new Array();
var changes = new Array();
var hasAudio = false;
var showCaption = false;
var mute = false;
var thumb_width = 94;
var thumb_height = 70;
var thumbs_per_row = 5;
var thumb_rows = 4;
var thumb_margin = 4;
var loop = true;
var autoplay = true;
var nmb_images_wrapper = thumb_rows * thumbs_per_row;
var slideshow_width = 800;
var slideshow_height = 600;
var showHeader = false;
var showThumbnails = false;
var showControls = true;
var iframe = false;
var readyToPlay = false;
var slideshowReady = false;
var projectTitle;
var getUrlVars = (function() {
var vars;
return function() {
if(vars !== undefined) return vars;
vars = {};
window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
vars[key] = value;
});
return vars;
}
})();

function timeObject(){
	this.time = 0.0;
	this.duration = 0.0;
}

(function($) {
//	var imgList = [];
	$.extend({
		preload: function(imgArr, option) {
			var setting = $.extend({
				init: function(loaded, total) {},
				loaded: function(img, loaded, total) {},
				loaded_all: function(loaded, total) {}
			}, option);
			var total = imgArr.length;
			var loaded = 0;
			
			setting.init(0, total);
			for(var i in imgArr) {
				$('.preload').append($("<img />")
					.attr("src", imgArr[i])
					.load(function() {
						loaded++;
						setting.loaded(this, loaded, total);
						if(loaded == total) {
							setting.loaded_all(loaded, total);
						}
					})
				).hide();
			}
			
		}
	});
})(jQuery);

$.getJSON("./config/jsonconfig.js", {}, function(json_data) {
	json = json_data;
	$('.msg_slideshow').hide();
	projectTitle = json.project;
	slides = json.data.slides;
	max_images = json.data.slides.length;
	var preloadimages = new Array();
	$.each(slides, function(i, slide){
		preloadimages.push('./images/' + slide.file);
		preloadimages.push('./thumbs/' + slide.file + '.thumb.jpg');
	});
	$.preload(preloadimages, {
		init: function(loaded, total) {
			$('#indicator').fadeIn(500);
			$("#indicator").html("Loading: 0 %");
		},
		loaded: function(img, loaded, total) {
			var percent = (loaded/total)*100.0;
			$("#indicator").html("Loading: "+sprintf("%.1f", percent)+" %");
		},
		loaded_all: function(loaded, total) {
			$("#indicator").html("Loading: 100 %. Done!");
			$('#indicator').fadeOut('slow', continueAfterPreLoading());
		}
	});
});

function continueAfterPreLoading()
{
	$('.msg_slideshow').show();
	showHeader = (json.slideshow.showHeader === undefined) ? false : json.slideshow.showHeader;
	loop = (json.slideshow.loop === undefined) ? true : json.slideshow.loop;
	autoplay = (json.slideshow.autoPlay === undefined) ? true : json.slideshow.autoPlay;
	showCaption = (json.slideshow.showCaptionsByDefault === undefined) ? true : json.slideshow.showCaptionsByDefault;
	slideshow_height = (json.slideshow.height === undefined) ? 600 : json.slideshow.height;
	slideshow_width = (json.slideshow.width === undefined) ? 800 : json.slideshow.width;
	showControls = (json.slideshow.showControls === undefined) ? true : json.slideshow.showControls;
	var getparams = getUrlVars();
	if (getparams['width'] !== undefined) slideshow_width = parseInt(getparams['width']);
	if (getparams['height'] !== undefined) slideshow_height = parseInt(getparams['height']);
	if (getparams['showControls'] !== undefined) showControls = (parseInt(getparams['showControls'])) ? true : false;
	if (getparams['showCaption'] !== undefined) showCaption = (parseInt(getparams['showCaption'])) ? true : false;
	if (getparams['autoplay'] !== undefined) autoplay = (parseInt(getparams['autoplay'])) ? true : false;
	if (getparams['loop'] !== undefined) autoplay = (parseInt(getparams['loop'])) ? true : false;
	if (getparams['iframe'] !== undefined) iframe = (parseInt(getparams['iframe'])) ? true : false;
	if (!publish) iframe = true;

	if (iframe)
	{
		$('.sensitive').hide();
	}
	else
	{
		$('.sensitive').fadeIn();
	}
	customTime = new timeObject();
//	if (getparams['fullscreen'] !== undefined) fullscreen = (parseInt(getparams['fullscreen'])) ? true : false;
	if (json.data.meta && json.data.meta.audio)
	{
		$('#msg_controls').hide();
		// needed for IE support
		$('.content').append( 
			$.fixHTML5( 
				'<audio><source src="' + './audio/' + json.data.meta.audio.file + '" /></audio>'
			)
		);
		$('audio').jmeEmbed({removeControls: true});
		$('audio').empty().append($('<source />').attr('src', './audio/' + json.data.meta.audio.file));
		$('audio').loadSrc('./audio/' + json.data.meta.audio.file);
		hasAudio = true;
		$('audio').bind('timechange', timechange);
		$('audio').bind('ended', ended);
		$('audio').jmeReady(function()
		{
			playerReady();
		});
		if (!hasAudio)
		{
			$('#msg_mute').hide();
			$('#msg_high').hide();
		}
		else
		{
			$('#msg_mute').show();
			$('#msg_high').hide();
		}
	}

	$(":range").rangeinput({ min: 0, max: json.data.length, step: 500});
	$(".handle").bind(
		{
			dragStart: function(e, ui) { if (_isPlaying) { _wasPlayingBeforeDrag = true; pause(); } else { _wasPlayingBeforeDrag = false; } },
			dragEnd: function(e, ui) { if (_wasPlayingBeforeDrag) play(); }
		}
	);
	$(":range").change(function(event, value) {
		setCurrent(slideIndexForTime(value));
		if (hasAudio)
		{
			$('audio').currentTime(value / 1000.0);
		}
		else
		{
			customTime.time = value / 1000.0;
		}
		showImage(false);
	});

	// set the slideshow size
	$('.msg_slideshow').css('width', slideshow_width + 'px');
	$('.msg_slideshow').css('height', (slideshow_height+50) + 'px');
	$('.slide_wrapper').css('width', slideshow_width + 'px');
	$('.slide_wrapper').css('height', slideshow_height + 'px');
	$('#time').css('width', (slideshow_width-260) + 'px');
	$('.slider').css('width', (slideshow_width-260) + 'px');
	$('.msg_controls').css('width', slideshow_width + 'px');
	$('.msg_wrapper').css('width', slideshow_width + 'px');
	$('.msg_wrapper').css('height', slideshow_height + 'px');
	$('.msg_wrapper_bottom').css('width', slideshow_width + 'px');
	$('.msg_wrapper_bottom').css('height', slideshow_height + 'px');
	$('#caption_wrapper').css('left', $('#slide_wrapper').position().left + 'px');
//	$('#caption_wrapper').css('top', $('#slide_wrapper').position().top + 'px');
	$('#caption_wrapper').css('width', slideshow_width + 'px');
	$('#msg_thumb_close').hide();
	if (!showControls)
	{
		$('.msg_controls').bind('mouseenter',function(){
			var $this = $(this);
			$this.animate({'opacity':1},'slow');
		}).bind('mouseleave',function(){
			var $this = $(this);	
			$this.animate({'opacity':0},'slow');
		});
		$('.msg_controls').animate({'opacity':0}, 0);
	}

	// set the size of the thumbnail view
	$('.msg_thumbs').css('width', (thumb_width*thumbs_per_row+thumbs_per_row*2*thumb_margin+60) + 'px');
	$('.msg_thumbs').css('height', (thumb_height*thumb_rows+thumb_rows*2*thumb_margin) + 'px');
	$('.msg_thumbs').hide();
	$('.msg_thumb_wrapper').css('width', (thumb_width*thumbs_per_row+thumbs_per_row*2*thumb_margin+60-8) + 'px');
	$('.msg_thumb_wrapper').css('height', (thumb_height*thumb_rows+thumb_rows*2*thumb_margin-8) + 'px');
	totaltime = 0;
	$.each(slides, function(i, slide){
		images[i] = $('<img />').attr('src', './images/' + slide.file).attr('alt', slide.caption);
		thumbs[i] = $('<img />').attr('src', './thumbs/' + slide.file + '.thumb.jpg').attr('alt', slide.caption);
		changes[i] = totaltime;
		totaltime += slide.length;
	});
	customTime.duration = json.data.length / 1000.0;
	$('#ILIAS').attr("checked", "checked");
	setILIASIntegration();
	hideFrameHelper(0);

	if (showHeader)
	{
		$('.header').empty().append($('<h1 />').append(projectTitle));
	}
	document.title = projectTitle;
	$(window).resize(function() {
		adjustThumbPanel();
	});

	/**
	* start the slideshow
	*/
	setCurrent(0);
	showImage(false);
	if (readyToPlay)
	{
		slideshowReady = true;
		if (autoplay) 
		{
			play();
		}
		else
		{
			pause();
		}
	}
}

/**
* clicking the caption icon,
* toggles the captions
*/
$('#msg_caption').bind('click',function(e){
	showCaption = !showCaption;
	if (showCaption)
	{
		displayCaption();
	}
	else
	{
		hideCaption();
	}
	e.preventDefault();
});

/**
* clicking the mute icon,
* mutes the sound volume
*/
$('#msg_mute').bind('click',function(e){
	mute = !mute;
	setVolume();
	e.preventDefault();
});

/**
* clicking the high icon,
* sets the sound volume to high
*/
$('#msg_high').bind('click',function(e){
	mute = false;
	setVolume();
	e.preventDefault();
});

/**
* clicking the grid icon,
* shows the thumbs view, pauses the slideshow, and hides the controls
*/
$('#msg_grid').bind('click', openThumbnails);

function adjustThumbPanel()
{
	if ($('.msg_thumbs').position().top > 0)
	{
		var top = $('#msg_slideshow').position().top + Math.ceil(($('#msg_slideshow').height() - $('#msg_thumbs').height())/2 - 50);
		var left = Math.ceil(($(document).width() - $('.msg_thumbs').width() -60)/2);
		$('.msg_thumbs').css('top', top + 'px');
		$('.msg_thumbs').css('left', left + 'px');
		$('#msg_thumb_close').css('top', (top-12) + 'px');
		$('#msg_thumb_close').css('left', (left-12) + 'px');
	}
}

function openThumbnails(e)
{
	if (!showThumbnails)
	{
		$('#msg_slideshow').unbind('mouseenter').unbind('mouseleave');
		$fader = $('<div />').attr('class', 'fader');
		$fader.css('width', $('#slide_wrapper').css('width'));
		$fader.css('height', $('#slide_wrapper').css('height'));
		$('#slide_wrapper').prepend($fader.fadeTo('slow', 0.5));
		thumb_page = Math.ceil((current+1)/nmb_images_wrapper)-1;
		if (thumb_page < 0) thumb_page = 0;
		populateThumbs();
		var top = $('#msg_slideshow').position().top + Math.ceil(($('#msg_slideshow').height() - $('#msg_thumbs').height())/2 - 50);
		var left = Math.ceil(($(document).width() - $('.msg_thumbs').width() -60)/2);
		$('.msg_thumbs').css('top', top + 'px');
		$('.msg_thumbs').css('left', left + 'px');
		$('#msg_thumb_close').css('top', (top-12) + 'px');
		$('#msg_thumb_close').css('left', (left-12) + 'px');
		$('#msg_thumb_close').show(500, function() {});
		$('.msg_thumbs').show(500, function() 
		{
		});
		e.preventDefault();
		showThumbnails = true;
	}
	else
	{
		closeThumbnails(e);
	}
}

function closeThumbnails(e)
{
	$('.msg_thumbs').hide(500, function(){});
	$('#msg_thumb_close').hide(500, function(){ $('.fader').fadeTo('slow', 0.0).remove(); });
	e.preventDefault();
	showThumbnails = false;
}

/**
* closing the thumbs view,
* shows the controls
*/
$('#msg_thumb_close').bind('click',closeThumbnails);

/**
* pause or play icons
*/
$('#msg_pause_play').bind('click',function(e){
	var $this = $(this);
	if($this.hasClass('msg_play'))
		play();
	else
		pause();
	e.preventDefault();	
});

/**
* click controls next or prev,
* pauses the slideshow, 
* and displays the next or prevoius image
*/
$('#msg_next').bind('click',function(e){
//	pause();
	nextSlide();
	e.preventDefault();
});
$('#msg_prev').bind('click',function(e){
//	pause();
	prevSlide();
	e.preventDefault();
});

function displayCaption()
{
	var captiontext = slides[current].caption;
	if (showCaption && captiontext)
	{
		$('#caption_wrapper .caption').empty().append(captiontext);
		$('#caption_wrapper').hide().fadeIn();
	}
}

function hideCaption()
{
	$('#caption_wrapper').fadeOut();
}

function updatePlayProgress()
{
	customTime.time += 0.1;
	timechange(null, customTime);
}

/**
* start the slideshow
*/
function play()
{
	_isPlaying = true;
	$('#msg_pause_play').addClass('msg_pause').removeClass('msg_play');
	if (!hasAudio)
	{
		playtime = setInterval(function() { updatePlayProgress(); }, 100);
	}
	else
	{
		$('audio').play();
	}
}

/**
* stops the slideshow
*/
function pause(){
	_isPlaying = false;
	$('#msg_pause_play').addClass('msg_play').removeClass('msg_pause');
	if (!hasAudio)
	{
		clearTimeout(playtime);
	}
	else
	{
		$('audio').pause();
	}
}

function setVolume()
{
	if (hasAudio)
	{
		$('audio').muted(mute);
		if (mute)
		{
			$('#msg_mute').addClass('msg_high').removeClass('msg_mute');
		}
		else
		{
			$('#msg_mute').addClass('msg_mute').removeClass('msg_high');
		}
	}
}

/**
* show the next image
*/
function nextSlide()
{
	setCurrent(current+1);
	showImage(true);
}

/**
* shows the previous image
*/
function prevSlide(){
	setCurrent(current-1);
	showImage(true);
}

/**
* show the next image
*/
function next(){
	setCurrent(current+1);
	showImage();
}

/**
* shows the previous image
*/
function prev(){
	setCurrent(current-1);
	showImage();
}

function setCurrent(index)
{
	last = current;
	current = index;
}

function ended()
{
	setCurrent(0);
	showImage(true);
	if (!loop)
	{
		pause();
	}
}

function slideIndexForTime(time)
{
	for (var i = 0; i < max_images; i++)
	{
		if (changes[i] > time)
		{
			return i-1;
		}
	}
	return max_images-1;
}

function playerReady()
{
	if (hasAudio)
	{
		readyToPlay = true;
		$('#msg_controls').fadeIn('slow');
		if (!slideshowReady)
		{
			slideshowReady = true;
			if (autoplay) 
			{
				play();
			}
			else
			{
				pause();
			}
		}
	}
}

function timechange(e, time)
{
	var api = $(':range').data('rangeinput');
	api.setValue(time.time * 1000.0);
	if (time.time > customTime.duration)
	{
		if (loop)
		{
			nextSlide();
		}
		else
		{
			pause();
		}
		return;
	}
	$('.runningtime').empty().append(sprintf('%02d:%02d', time.time/60, time.time % 60));
	if (time.time > (totaltime/1000.0))
	{
		$('#msg_wrapper').empty();
	}
	else
	{
		for (var i = 0; i < max_images; i++)
		{
			if (time.time * 1000.0 < changes[i])
			{
				if (i-1 > current)
				{
					next();
				}
				return;
			}
		}
		if (max_images-1 != current) next();
	}
}

function populateThumbs()
{
	$('.msg_thumb_wrapper > a').unbind('click');
	$('.msg_thumb_wrapper > a').unbind('mouseenter');
	$('.msg_thumb_wrapper > a').unbind('mouseleave');
	$('.msg_thumb_wrapper').empty();
	for (var i = thumb_page*nmb_images_wrapper; i < thumb_page*nmb_images_wrapper+nmb_images_wrapper; i++)
	{
		if (i < max_images)
		{
			var $image = thumbs[i].clone();
			resize($image, thumb_width, thumb_height);
			var $anchor = $('<a />').attr('href', 'javascript:void(0);');
			$anchor.empty().append($image);
			$('.msg_thumb_wrapper').append($anchor);
		}
	}
	addThumbEvents();
}

/**
* clicking on a thumb, displays the image
*/
function addThumbEvents()
{
	$('#msg_thumbs .msg_thumb_wrapper > a').bind('click',function(e)
	{
		var $this 		= $(this);
		$('#msg_thumb_close').trigger('click');
		var idx			= $this.index();
		setCurrent(parseInt(thumb_page*nmb_images_wrapper + idx));
		showImage(true);
		e.preventDefault();
	}).bind('mouseenter',function(){
		var $this 		= $(this);
		$this.stop().animate({'opacity':0.6});
	}).bind('mouseleave',function(){
		var $this 		= $(this);	
		$this.stop().animate({'opacity':1});
	});
}

/**
* shows an image
*/
function showImage(setAudio)
{
	if (current < 0) setCurrent(max_images-1);
	if (current > max_images-1) setCurrent(0);
	if (setAudio && setAudio === true)
	{
		if (hasAudio)
		{
			$('audio').currentTime(changes[current] / 1000.0);
		}
		else
		{
			customTime.time = changes[current] / 1000.0;
		}
	}
	hideCaption();
	var $image = images[current].clone();
	if($image.length)
	{
		var $currentImage = $('#msg_wrapper').find('img');
		if($currentImage.length)
		{
			if (slides[last] && slides[last].transition && slides[last].transition.type == 'fade')
			{
				$currentImage.fadeOut(slides[last].transition.length/2, function(){
					$(this).remove();
					resize($image);
					$image.hide();
					$('#msg_wrapper').empty().append($image.fadeIn(slides[last].transition.length/2, function() { displayCaption(); }));
				});
			}
			else if (slides[last] && slides[last].transition && slides[last].transition.type == 'crossfade')
			{
				resize($image);
				$image.hide();
				$('#msg_wrapper_bottom').empty().append($image.fadeIn(slides[last].transition.length, function() {
					$('#msg_wrapper').empty().append($image.clone());
					$('#msg_wrapper_bottom').empty();
					displayCaption();
				}));
				$currentImage.fadeOut(slides[last].transition.length, function(){ $currentImage.remove(); });
			}
			else if (slides[last] && slides[last].transition && slides[last].transition.type == 'straightcut')
			{ 
				var left = $('#msg_wrapper').position().left;
				$('#msg_wrapper_bottom').css('left', ($('#msg_wrapper').width() + 1) + 'px');
				resize($image);
				$('#msg_wrapper_bottom').empty().append($image);
				$('#msg_wrapper').animate(
					{
						left: '-' + $('#msg_wrapper').width() + 'px',
					}, 
					slides[last].transition.length, 
					'swing',
					function() 
					{
						// Animation complete.
					}
				);
				$('#msg_wrapper_bottom').animate(
					{
						left: left + 'px',
					}, 
					slides[last].transition.length, 
					'swing',
					function() 
					{
						// Animation complete.
						$('#msg_wrapper').css('left', left + 'px');
						$('#msg_wrapper').css('left', 'auto');
						$('#msg_wrapper').empty().append($image.clone());
						$('#msg_wrapper_bottom').css('left', left + 'px');
						$('#msg_wrapper_bottom').css('left', 'auto');
						$('#msg_wrapper_bottom').empty();
						displayCaption();
					}
				);
			}
			else
			{
				resize($image);
				$('#msg_wrapper').empty().append($image);
				displayCaption();
			}
		}
		else{
			resize($image);
			$image.hide();
			$('#msg_wrapper').empty().append($image.fadeIn(function() { displayCaption(); }));
		}
	}
}

/**
* click next or previous on the thumbs wrapper
*/
$('#msg_thumb_next').bind('click',function(e){
	next_thumb();
	e.preventDefault();
});
$('#msg_thumb_prev').bind('click',function(e){
	prev_thumb();
	e.preventDefault();
});

$('#ILIAS').bind('click',function(e){
	setILIASIntegration();
});

$('#iframe').bind('click',function(e){
	setiFrameIntegration();
});

$('.sensitive').bind('click', function(e){
	showFrameHelper(1000);
});

$('.frameclose').bind('click', function(e){
	hideFrameHelper(1000);
});

function getiFrameURL()
{
	var url = document.URL;
	if (url.indexOf("?") != -1)
	{
		url = url.split("?")[0];
	}
	if (url.substring(url.length-1) == '/')
	{
		url += "index.php";
	}
	else if (url.substring(url.length-9) != 'index.php')
	{
		url += "/index.php";
	}
	url += "?iframe=1&loop=" + ((loop) ? "1" : "0") +
		"&autoplay=" + ((autoplay) ? "1" : "0") +
		"&showControls=" + ((showControls) ? "1" : "0") +
		"&showCaption=" + ((showCaption) ? "1" : "0") +
		"&width=" + slideshow_width +
		"&height=" + slideshow_height;
	return url;
}

function setILIASIntegration()
{
	var url = getiFrameURL();
	url += "&mmslide=1";
	$('.code').empty().append(url);
	$('.code').select();
}

function hideFrameHelper(time)
{
	if (!iframe)
	{
		$('.framehelper').animate(
			{
				bottom: '-92px',
			}, 
			time, 
			'swing',
			function() 
			{
				$('.sensitive').fadeIn();
			}
		);
	}
}

function showFrameHelper(time)
{
	if (!iframe)
	{
		$('.sensitive').hide();
		$('.framehelper').animate(
			{
				bottom: '0px',
			}, 
			time, 
			'swing',
			function() 
			{
			}
		);
	}
}

function setiFrameIntegration()
{
	var url = '<iframe width="' + slideshow_width + '" height="' + slideshow_height + '" frameborder="0" type="text/html"' +
	' src="' + getiFrameURL() + '"></iframe>';
	$('.code').empty().append(url.replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;"));
	$('.code').select();
}

$("#copytoclipboard").click(function()
{
	$('.code').select();
});

function next_thumb()
{
	thumb_page++;
	if (thumb_page*nmb_images_wrapper > max_images) thumb_page = 0;
	populateThumbs();
}

function prev_thumb()
{
	thumb_page--;
	if (thumb_page<0) thumb_page = Math.floor(max_images/nmb_images_wrapper);
	populateThumbs();
}

/**
* resize the image to fit in the container
*/
function resize($image, width, height)
{
	var theImage 	= new Image();
	theImage.src 	= $image.attr("src");
	var imgwidth 	= theImage.width;
	var imgheight 	= theImage.height;
	if (width === undefined) width = slideshow_width;
	if (height === undefined) height = slideshow_height;
        
	if(imgwidth	> width){
		var newwidth = width;
		var ratio = imgwidth / width;
		var newheight = imgheight / ratio;
		if(newheight > height){
			var newnewheight = height;
			var newratio = newheight/height;
			var newnewwidth =newwidth/newratio;
			theImage.width = newnewwidth;
			theImage.height= newnewheight;
		}
		else{
			theImage.width = newwidth;
			theImage.height= newheight;
		}
	}
	else if(imgheight > height){
		var newheight = height;
		var ratio = imgheight / height;
		var newwidth = imgwidth / ratio;
		if(newwidth > width){
			var newnewwidth = width;
			var newratio = newwidth/width;
			var newnewheight =newheight/newratio;
			theImage.height = newnewheight;
			theImage.width= newnewwidth;
		}
		else{
			theImage.width = newwidth;
			theImage.height= newheight;
		}
	}
	
	if (theImage.height < slideshow_height && theImage.height!=0) {
		var marginTop = (slideshow_height - theImage.height)/2;
		$image.css({
			'margin-top':marginTop+"px"
		});
	}
	
	//TODO real fix 
	/*
	$image.css({
		'width'	:theImage.width,
		'height':theImage.height
	});
	*/
}
});

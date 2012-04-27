/** @license
 * SoundManager 2: Javascript Sound for the Web
 * --------------------------------------------
 * http://schillmania.com/projects/soundmanager2/
 *
 * Copyright (c) 2007, Scott Schiller. All rights reserved.
 * Code provided under the BSD License:
 * http://schillmania.com/projects/soundmanager2/license.txt
 *
 * V2.96a.20100520
 */

/*jslint white: false, onevar: true, undef: true, nomen: false, eqeqeq: true, plusplus: false, bitwise: true, regexp: true, newcap: true, immed: true */
/*global SM2_DEFER, sm2Debugger, alert, console, document, navigator, setTimeout, window, document, setInterval, clearInterval, Audio */

(function(window) {

var soundManager = null;

function SoundManager(smURL, smID) {

  this.flashVersion = 8;             // version of flash to require, either 8 or 9. Some API features require Flash 9.
  this.debugMode = false;            // enable debugging output (div#soundmanager-debug, OR console if available+configured)
  this.debugFlash = false;           // enable debugging output inside SWF, troubleshoot Flash/browser issues
  this.useConsole = true;            // use firebug/safari console.log()-type debug console if available
  this.consoleOnly = false;          // if console is being used, do not create/write to #soundmanager-debug
  this.waitForWindowLoad = false;    // force SM2 to wait for window.onload() before trying to call soundManager.onload()
  this.nullURL = 'null.mp3';         // path to "null" (empty) MP3 file, used to unload sounds (Flash 8 only)
  this.allowPolling = true;          // allow flash to poll for status update (required for whileplaying() events, peak, sound spectrum functions to work.)
  this.useFastPolling = false;       // uses lower flash timer interval for higher callback frequency, best combined with useHighPerformance
  this.useMovieStar = false;         // enable support for Flash 9.0r115+ (codename "MovieStar") MPEG4 audio+video formats (AAC, M4V, FLV, MOV etc.)
  this.bgColor = '#ffffff';          // movie (.swf) background color, '#000000' useful if showing on-screen/full-screen video etc.
  this.useHighPerformance = false;   // position:fixed flash movie can help increase js/flash speed, minimize lag
  this.flashLoadTimeout = 1000;      // msec to wait for flash movie to load before failing (0 = infinity)
  this.wmode = null;                 // mode to render the flash movie in - null, transparent, opaque (last two allow layering of HTML on top)
  this.allowFullScreen = true;       // enter full-screen (via double-click on movie) for flash 9+ video
  this.allowScriptAccess = 'always'; // for scripting the SWF (object/embed property), either 'always' or 'sameDomain'
  this.useFlashBlock = false;        // *requires flashblock.css, see demos* - allow recovery from flash blockers. Wait indefinitely and apply timeout CSS to SWF, if applicable.
  this.useHTML5Audio = false;        // EXPERIMENTAL IN-PROGRESS feature: Use HTML 5 Audio() where API is supported (most Safari, Chrome versions), Firefox (no MP3/MP4.) Ideally, transparent vs. Flash API where possible.
  this.html5Test = /^probably$/i;    // HTML5 Audio() canPlayType() test. /^(probably|maybe)$/i if you want to be more liberal/risky.

  this.audioFormats = {
    // determines HTML5 support, flash requirements
    // eg. if MP3 or MP4 required, Flash fallback is used if HTML5 can't play it
    // shotgun approach to MIME testing due to browser variance
    'mp3': {
      type: ['audio/mpeg; codecs="mp3"','audio/mpeg','audio/mp3','audio/MPA','audio/mpa-robust'],
      required: true
    }, 
    'mp4': {
      related: ['aac','m4a'], // additional formats under the MP4 container.
      type: ['audio/mp4; codecs="mp4a.40.2"','audio/aac','audio/x-m4a','audio/MP4A-LATM','audio/mpeg4-generic'],
      required: true
    },
    'ogg': {
      type: ['audio/ogg; codecs=vorbis'],
      required: false
    },
    'wav': {
      type: ['audio/wav; codecs="1"','audio/wav','audio/wave','audio/x-wav'],
      required: false
    }
  };

  if (this.audioFormats.mp4.required) {
    this.flashVersion = 9;
  }

  this.defaultOptions = {
    'autoLoad': false,             // enable automatic loading (otherwise .load() will be called on demand with .play(), the latter being nicer on bandwidth - if you want to .load yourself, you also can)
    'stream': true,                // allows playing before entire file has loaded (recommended)
    'autoPlay': false,             // enable playing of file as soon as possible (much faster if "stream" is true)
    'loops': 1,                    // how many times to repeat the sound (position will wrap around to 0, setPosition() will break out of loop when >0)
    'onid3': null,                 // callback function for "ID3 data is added/available"
    'onload': null,                // callback function for "load finished"
    'whileloading': null,          // callback function for "download progress update" (X of Y bytes received)
    'onplay': null,                // callback for "play" start
    'onpause': null,               // callback for "pause"
    'onresume': null,              // callback for "resume" (pause toggle)
    'whileplaying': null,          // callback during play (position update)
    'onstop': null,                // callback for "user stop"
    'onfinish': null,              // callback function for "sound finished playing"
    'onbeforefinish': null,        // callback for "before sound finished playing (at [time])"
    'onbeforefinishtime': 5000,    // offset (milliseconds) before end of sound to trigger beforefinish (eg. 1000 msec = 1 second)
    'onbeforefinishcomplete': null,// function to call when said sound finishes playing
    'onjustbeforefinish': null,    // callback for [n] msec before end of current sound
    'onjustbeforefinishtime': 200, // [n] - if not using, set to 0 (or null handler) and event will not fire.
    'multiShot': true,             // let sounds "restart" or layer on top of each other when played multiple times, rather than one-shot/one at a time
    'multiShotEvents': false,      // fire multiple sound events (currently onfinish() only) when multiShot is enabled
    'position': null,              // offset (milliseconds) to seek to within loaded sound data.
    'pan': 0,                      // "pan" settings, left-to-right, -100 to 100
    'volume': 100                  // self-explanatory. 0-100, the latter being the max.
  };

  this.flash9Options = {      // flash 9-only options, merged into defaultOptions if flash 9 is being used
    'isMovieStar': null,      // "MovieStar" MPEG4 audio/video mode. Null (default) = auto detect MP4, AAC etc. based on URL. true = force on, ignore URL
    'usePeakData': false,     // enable left/right channel peak (level) data
    'useWaveformData': false, // enable sound spectrum (raw waveform data) - WARNING: CPU-INTENSIVE: may set CPUs on fire.
    'useEQData': false,       // enable sound EQ (frequency spectrum data) - WARNING: Also CPU-intensive.
    'onbufferchange': null,   // callback for "isBuffering" property change
    'ondataerror': null       // callback for waveform/eq data access error (flash playing audio in other tabs/domains)
  };

  this.movieStarOptions = { // flash 9.0r115+ MPEG4 audio/video options, merged into defaultOptions if flash 9+movieStar mode is enabled
    'onmetadata': null,     // callback for when video width/height etc. are received
    'useVideo': false,      // if loading movieStar content, whether to show video
    'bufferTime': 3         // seconds of data to buffer before playback begins (null = flash default of 0.1 seconds - if AAC playback is gappy, try increasing.)
  };

  this.version = null;
  this.versionNumber = 'V2.96a.20100520';
  this.movieURL = null;
  this.url = (smURL || null);
  this.altURL = null;
  this.swfLoaded = false;
  this.enabled = false;
  this.o = null;
  this.movieID = 'sm2-container';
  this.id = (smID || 'sm2movie');
  this.swfCSS = {
    swfDefault: 'movieContainer',
    swfError: 'swf_error', // SWF loaded, but SM2 couldn't start (other error)
    swfTimedout: 'swf_timedout',
    swfUnblocked: 'swf_unblocked', // or loaded OK
    sm2Debug: 'sm2_debug',
    highPerf: 'high_performance',
    flashDebug: 'flash_debug'
  };
  this.oMC = null;
  this.sounds = {};
  this.soundIDs = [];
  this.muted = false;
  this.isFullScreen = false; // set later by flash 9+
  this.isIE = (navigator.userAgent.match(/MSIE/i));
  this.isSafari = (navigator.userAgent.match(/safari/i));
  this.debugID = 'soundmanager-debug';
  this.debugURLParam = /([#?&])debug=1/i;
  this.specialWmodeCase = false;
  this.didFlashBlock = false;

  this.filePattern = null;
  this.filePatterns = {
    flash8: /\.mp3(\?\.*)?$/i,
    flash9: /\.mp3(\?\.*)?$/i
  };

  this.baseMimeTypes = /^\s*audio\/(?:x-)?(?:mp(?:eg|3))\s*(?:$|;)/i; // mp3
  this.netStreamMimeTypes = /^\s*audio\/(?:x-)?(?:mp(?:eg|3))\s*(?:$|;)/i; // mp3, mp4, aac etc.
  this.netStreamTypes = ['aac', 'flv', 'mov', 'mp4', 'm4v', 'f4v', 'm4a', 'mp4v', '3gp', '3g2']; // Flash v9.0r115+ "moviestar" formats
  this.netStreamPattern = new RegExp('\\.(' + this.netStreamTypes.join('|') + ')(\\?.*)?$', 'i');
  this.mimePattern = this.baseMimeTypes;

  this.features = {
    buffering: false,
    peakData: false,
    waveformData: false,
    eqData: false,
    movieStar: false
  };

  this.sandbox = {
    'type': null,
    'types': {
      'remote': 'remote (domain-based) rules',
      'localWithFile': 'local with file access (no internet access)',
      'localWithNetwork': 'local with network (internet access only, no local access)',
      'localTrusted': 'local, trusted (local+internet access)'
    },
    'description': null,
    'noRemote': null,
    'noLocal': null
  };

  this.hasHTML5 = null; // switch for handling logic
  this.html5 = {}; // stores canPlayType() results, etc.
  this.ignoreFlash = false; // used for special cases (eg. iPad/iPhone/palm OS?)

  // --- private SM2 internals ---

  var SMSound,
  _s = this, _sm = 'soundManager', _id, _ua = navigator.userAgent, _doNothing, _init, _onready = [], _debugOpen = true, _debugTS, _didAppend = false, _appendSuccess = false, _didInit = false, _disabled = false, _windowLoaded = false, _wDS, _wdCount, _initComplete, _mergeObjects, _addOnReady, _processOnReady, _initUserOnload, _go, _waitForEI, _setVersionInfo, _handleFocus, _beginInit, _strings, _initMovie, _dcLoaded, _didDCLoaded, _getDocument, _createMovie, _setPolling, _debugLevels = ['log', 'info', 'warn', 'error'], _defaultFlashVersion = 8, _disableObject, _failSafely, _normalizeMovieURL, _oRemoved = null, _oRemovedHTML = null, _str, _flashBlockHandler, _getSWFCSS, _toggleDebug, _loopFix, _complain, _idCheck, _waitingForEI = false, _initPending = false, _smTimer, _onTimer, _startTimer, _stopTimer, _needsFlash = true, _featureCheck, _html5Ready, _html5Only, _html5CanPlay, _html5Ext,  _dcIE, _testHTML5,
  _is_pre = _ua.match(/pre\//i),
  _iPadOrPhone = _ua.match(/(ipad|iphone)/i),
  _isMobile = (_ua.match(/mobile/i) || _is_pre || _iPadOrPhone),
  _hasConsole = (typeof console !== 'undefined' && typeof console.log !== 'undefined'),
  _overHTTP = (document.location?document.location.protocol.match(/http/i):null),
  _isFocused = (typeof document.hasFocus !== 'undefined'?document.hasFocus():null),
  _tryInitOnFocus = (typeof document.hasFocus === 'undefined' && this.isSafari),
  _okToDisable = !_tryInitOnFocus;

  this.useAltURL = !_overHTTP; // use altURL if not "online"

  if (_iPadOrPhone || _is_pre) {
    // might as well force it on Apple + Palm, flash support unlikely
    _s.useHTML5Audio = true;
    _s.ignoreFlash = true;
  }

  if (_is_pre) {
    // less-strict canPlayType() checking for Palm Pre.
    _s.html5Test = /^(probably|maybe)$/i;
  }

  // Temporary feature: allow force of HTML5 via URL: #sm2-usehtml5audio=0 or 1
  // <d>
  (function(){
    var a = '#sm2-usehtml5audio=', l = window.location.href.toString(), b = null;
    if (l.indexOf(a) !== -1) {
      b = (l.substr(l.indexOf(a)+a.length) === '1');
      if (typeof console !== 'undefined' && typeof console.log !== 'undefined') {
        console.log((b?'Enabling ':'Disabling ')+'useHTML5Audio via URL parameter');
      }
      _s.useHTML5Audio = b;
    }
  }());
  // </d>

  // --- public API methods ---

  this.supported = function() {
    return (_needsFlash?(_didInit && !_disabled):(_s.useHTML5Audio && _s.hasHTML5));
  };

  this.getMovie = function(smID) {
    return _s.isIE?window[smID]:(_s.isSafari?_id(smID) || document[smID]:_id(smID));
  };

  this.loadFromXML = function(sXmlUrl) {
    try {
      _s.o._loadFromXML(sXmlUrl);
    } catch(e) {
      _failSafely();
      return true;
    }
  };

  this.createSound = function(oOptions) {
    var _cs = 'soundManager.createSound(): ',
    thisOptions = null, oSound = null, _tO = null;
    if (!_didInit) {
      throw _complain(_cs + _str('notReady'), arguments.callee.caller);
    }
    if (arguments.length === 2) {
      // function overloading in JS! :) ..assume simple createSound(id,url) use case
      oOptions = {
        'id': arguments[0],
        'url': arguments[1]
      };
    }
    thisOptions = _mergeObjects(oOptions); // inherit SM2 defaults
    _tO = thisOptions; // alias
    // <d>
    if (_tO.id.toString().charAt(0).match(/^[0-9]$/)) {
      _s._wD(_cs + _str('badID', _tO.id), 2);
    }
    _s._wD(_cs + _tO.id + ' (' + _tO.url + ')', 1);
    // </d>
    if (_idCheck(_tO.id, true)) {
      _s._wD(_cs + _tO.id + ' exists', 1);
      return _s.sounds[_tO.id];
    }

    function make() {
      thisOptions = _loopFix(thisOptions);
      _s.sounds[_tO.id] = new SMSound(_tO);
      _s.soundIDs.push(_tO.id);
      return _s.sounds[_tO.id];
    }

    if (_html5CanPlay(_tO.url)) {
      oSound = make();
      _s._wD('Loading sound '+_tO.id+' from HTML5');
      oSound._setup_html5(_tO);
    } else {
      if (_s.flashVersion > 8 && _s.useMovieStar) {
        if (_tO.isMovieStar === null) {
          _tO.isMovieStar = (_tO.url.match(_s.netStreamPattern)?true:false);
        }
        if (_tO.isMovieStar) {
          _s._wD(_cs + 'using MovieStar handling');
        }
        if (_tO.isMovieStar) {
          if (_tO.usePeakData) {
            _wDS('noPeak');
            _tO.usePeakData = false;
          }
          if (_tO.loops > 1) {
            _wDS('noNSLoop');
          }
        }
      }
      oSound = make();
      // flash
      // AS2:
      if (_s.flashVersion === 8) {
        _s.o._createSound(_tO.id, _tO.onjustbeforefinishtime, _tO.loops||1);
      } else {
        _s.o._createSound(_tO.id, _tO.url, _tO.onjustbeforefinishtime, _tO.usePeakData, _tO.useWaveformData, _tO.useEQData, _tO.isMovieStar, (_tO.isMovieStar?_tO.useVideo:false), (_tO.isMovieStar?_tO.bufferTime:false), _tO.loops||1);
      }
    } 

    if (_tO.autoLoad || _tO.autoPlay) {
      // TODO: does removing timeout here cause problems?
      if (oSound) {
        if (_s.isHTML5) {
          oSound.autobuffer = 'auto'; // early HTML5 implementation (non-standard)
          oSound.preload = 'auto'; // standard
        } else {
          oSound.load(_tO);
        }
      }
    }
    if (_tO.autoPlay) {
      oSound.play();
    }
    return oSound;
  };

  this.createVideo = function(oOptions) {
    var fN = 'soundManager.createVideo(): ';
    if (arguments.length === 2) {
      oOptions = {
        'id': arguments[0],
        'url': arguments[1]
      };
    }
    if (_s.flashVersion >= 9) {
      oOptions.isMovieStar = true;
      oOptions.useVideo = true;
    } else {
      _s._wD(fN + _str('f9Vid'), 2);
      return false;
    }
    if (!_s.useMovieStar) {
      _s._wD(fN + _str('noMS'), 2);
    }
    return _s.createSound(oOptions);
  };

  this.destroySound = function(sID, bFromSound) {
    // explicitly destroy a sound before normal page unload, etc.
    if (!_idCheck(sID)) {
      return false;
    }
    for (var i = 0; i < _s.soundIDs.length; i++) {
      if (_s.soundIDs[i] === sID) {
        _s.soundIDs.splice(i, 1);
        continue;
      }
    }
    // conservative option: avoid crash with flash 8
    // calling destroySound() within a sound onload() might crash firefox, certain flavours of winXP+flash 8??
    // if (_s.flashVersion !== 8) {
    _s.sounds[sID].unload();
    // }
    if (!bFromSound) {
      // ignore if being called from SMSound instance
      _s.sounds[sID].destruct();
    }
    delete _s.sounds[sID];
  };

  this.destroyVideo = this.destroySound;

  this.load = function(sID, oOptions) {
    if (!_idCheck(sID)) {
      return false;
    }
    _s.sounds[sID].load(oOptions);
  };

  this.unload = function(sID) {
    if (!_idCheck(sID)) {
      return false;
    }
    _s.sounds[sID].unload();
  };

  this.play = function(sID, oOptions) {
    var fN = 'soundManager.play(): ';
    if (!_didInit) {
      throw _complain(fN + _str('notReady'), arguments.callee.caller);
    }
    if (!_idCheck(sID)) {
      if (!(oOptions instanceof Object)) {
        oOptions = {
          url: oOptions
        }; // overloading use case: play('mySound','/path/to/some.mp3');
      }
      if (oOptions && oOptions.url) {
        // overloading use case, creation+playing of sound: .play('someID',{url:'/path/to.mp3'});
        _s._wD(fN + 'attempting to create "' + sID + '"', 1);
        oOptions.id = sID;
        return _s.createSound(oOptions).play();
      } else {
        return false;
      }
    }
    _s.sounds[sID].play(oOptions);
  };

  this.start = this.play; // just for convenience

  this.setPosition = function(sID, nMsecOffset) {
    if (!_idCheck(sID)) {
      return false;
    }
    _s.sounds[sID].setPosition(nMsecOffset);
  };

  this.stop = function(sID) {
    if (!_idCheck(sID)) {
      return false;
    }
    _s._wD('soundManager.stop(' + sID + ')', 1);
    _s.sounds[sID].stop();
  };

  this.stopAll = function() {
    _s._wD('soundManager.stopAll()', 1);
    for (var oSound in _s.sounds) {
      if (_s.sounds[oSound] instanceof SMSound) {
        _s.sounds[oSound].stop(); // apply only to sound objects
      }
    }
  };

  this.pause = function(sID) {
    if (!_idCheck(sID)) {
      return false;
    }
    _s.sounds[sID].pause();
  };

  this.pauseAll = function() {
    for (var i = _s.soundIDs.length; i--;) {
      _s.sounds[_s.soundIDs[i]].pause();
    }
  };

  this.resume = function(sID) {
    if (!_idCheck(sID)) {
      return false;
    }
    _s.sounds[sID].resume();
  };

  this.resumeAll = function() {
    for (var i = _s.soundIDs.length; i--;) {
      _s.sounds[_s.soundIDs[i]].resume();
    }
  };

  this.togglePause = function(sID) {
    if (!_idCheck(sID)) {
      return false;
    }
    _s.sounds[sID].togglePause();
  };

  this.setPan = function(sID, nPan) {
    if (!_idCheck(sID)) {
      return false;
    }
    _s.sounds[sID].setPan(nPan);
  };

  this.setVolume = function(sID, nVol) {
    if (!_idCheck(sID)) {
      return false;
    }
    _s.sounds[sID].setVolume(nVol);
  };

  this.mute = function(sID) {
    var fN = 'soundManager.mute(): ',
    i = 0;
    if (typeof sID !== 'string') {
      sID = null;
    }
    if (!sID) {
      _s._wD(fN + 'Muting all sounds');
      for (i = _s.soundIDs.length; i--;) {
        _s.sounds[_s.soundIDs[i]].mute();
      }
      _s.muted = true;
    } else {
      if (!_idCheck(sID)) {
        return false;
      }
      _s._wD(fN + 'Muting "' + sID + '"');
      _s.sounds[sID].mute();
    }
  };

  this.muteAll = function() {
    _s.mute();
  };

  this.unmute = function(sID) {
    var fN = 'soundManager.unmute(): ', i;
    if (typeof sID !== 'string') {
      sID = null;
    }
    if (!sID) {
      _s._wD(fN + 'Unmuting all sounds');
      for (i = _s.soundIDs.length; i--;) {
        _s.sounds[_s.soundIDs[i]].unmute();
      }
      _s.muted = false;
    } else {
      if (!_idCheck(sID)) {
        return false;
      }
      _s._wD(fN + 'Unmuting "' + sID + '"');
      _s.sounds[sID].unmute();
    }
  };

  this.unmuteAll = function() {
    _s.unmute();
  };

  this.toggleMute = function(sID) {
    if (!_idCheck(sID)) {
      return false;
    }
    _s.sounds[sID].toggleMute();
  };

  this.getMemoryUse = function() {
    if (_s.flashVersion === 8) {
      // not supported in Flash 8
      return 0;
    }
    if (_s.o) {
      return parseInt(_s.o._getMemoryUse(), 10);
    }
  };

  this.disable = function(bNoDisable) {
    // destroy all functions
    if (typeof bNoDisable === 'undefined') {
      bNoDisable = false;
    }
    if (_disabled) {
      return false;
    }
    _disabled = true;
    _wDS('shutdown', 1);
    for (var i = _s.soundIDs.length; i--;) {
      _disableObject(_s.sounds[_s.soundIDs[i]]);
    }
    _initComplete(bNoDisable); // fire "complete", despite fail
    if (window.removeEventListener) {
      window.removeEventListener('load', _initUserOnload, false);
    }
    // _disableObject(_s); // taken out to allow reboot()
  };

  this.canPlayMIME = function(sMIME) {
    var result;
    if (_s.hasHTML5) {
      result = _html5CanPlay({type:sMIME});
    }
    if (!_needsFlash || result) {
      // no flash, or OK
      return result;
    } else {
      return (sMIME?(sMIME.match(_s.mimePattern)?true:false):null);
    }
  };

  this.canPlayURL = function(sURL) {
    var result;
    if (_s.hasHTML5) {
      result = _html5CanPlay(sURL);
    }
    if (!_needsFlash || result) {
      // no flash, or OK
      return result;
    } else {
      return (sURL?(sURL.match(_s.filePattern)?true:false):null);
    }
  };

  this.canPlayLink = function(oLink) {
    if (typeof oLink.type !== 'undefined' && oLink.type) {
      if (_s.canPlayMIME(oLink.type)) {
        return true;
      }
    }
    return _s.canPlayURL(oLink.href);
  };

  this.getSoundById = function(sID, suppressDebug) {
    if (!sID) {
      throw new Error('SoundManager.getSoundById(): sID is null/undefined');
    }
    var result = _s.sounds[sID];
    if (!result && !suppressDebug) {
      _s._wD('"' + sID + '" is an invalid sound ID.', 2);
      // soundManager._wD('trace: '+arguments.callee.caller);
    }
    return result;
  };

  this.onready = function(oMethod, oScope) {
    // queue a callback, with optional scope
    // a status object will be passed to your handler
    /*
    soundManager.onready(function(oStatus) {
      alert('SM2 init success: '+oStatus.success);
    });
    */
    if (oMethod && oMethod instanceof Function) {
      if (_didInit) {
        _wDS('queue');
      }
      if (!oScope) {
        oScope = window;
      }
      _addOnReady(oMethod, oScope);
      _processOnReady();
      return true;
    } else {
      throw _str('needFunction');
    }
  };

  this.oninitmovie = function() {
    // called after SWF has been appended to the DOM via JS (or retrieved from HTML)
    // this is a stub for your own scripts.
  };

  this.onload = function() {
    // window.onload() equivalent for SM2, ready to create sounds etc.
    // this is a stub for your own scripts.
    _s._wD('soundManager.onload()', 1);
  };

  this.onerror = function() {
    // stub for user handler, called when SM2 fails to load/init
  };

  this.getMoviePercent = function() {
    return (_s.o && typeof _s.o.PercentLoaded !== 'undefined'?_s.o.PercentLoaded():null);
  };

  this._writeDebug = function(sText, sType, bTimestamp) {
    // pseudo-private console.log()-style output
    // <d>
    var sDID = 'soundmanager-debug', o, oItem, sMethod;
    if (!_s.debugMode) {
      return false;
    }
    if (typeof bTimestamp !== 'undefined' && bTimestamp) {
      sText = sText + ' | ' + new Date().getTime();
    }
    if (_hasConsole && _s.useConsole) {
      sMethod = _debugLevels[sType];
      if (typeof console[sMethod] !== 'undefined') {
        console[sMethod](sText);
      } else {
        console.log(sText);
      }
      if (_s.useConsoleOnly) {
        return true;
      }
    }
    try {
      o = _id(sDID);
      if (!o) {
        return false;
      }
      oItem = document.createElement('div');
      if (++_wdCount % 2 === 0) {
        oItem.className = 'sm2-alt';
      }
      // sText = sText.replace(/\n/g,'<br />');
      if (typeof sType === 'undefined') {
        sType = 0;
      } else {
        sType = parseInt(sType, 10);
      }
      oItem.appendChild(document.createTextNode(sText));
      if (sType) {
        if (sType >= 2) {
          oItem.style.fontWeight = 'bold';
        }
        if (sType === 3) {
          oItem.style.color = '#ff3333';
        }
      }
      // o.appendChild(oItem); // top-to-bottom
      o.insertBefore(oItem, o.firstChild); // bottom-to-top
    } catch(e) {
      // oh well
    }
    o = null;
    // </d>
  };
  this._wD = this._writeDebug; // alias

  this._debug = function() {
    // <d>
    _wDS('currentObj', 1);
    for (var i = 0, j = _s.soundIDs.length; i < j; i++) {
      _s.sounds[_s.soundIDs[i]]._debug();
    }
    // </d>
  };

  this.reboot = function() {
    // attempt to reset and init SM2
    _s._wD('soundManager.reboot()');
    if (_s.soundIDs.length) {
      _s._wD('Destroying ' + _s.soundIDs.length + ' SMSound objects...');
    }
    for (var i = _s.soundIDs.length; i--;) {
      _s.sounds[_s.soundIDs[i]].destruct();
    }
    // trash ze flash
    try {
      if (_s.isIE) {
        _oRemovedHTML = _s.o.innerHTML;
      }
      _oRemoved = _s.o.parentNode.removeChild(_s.o);
      _s._wD('Flash movie removed.');
    } catch(e) {
      // uh-oh.
      _wDS('badRemove', 2);
    }
    // actually, force recreate of movie.
    _oRemovedHTML = null;
    _oRemoved = null;
    _s.enabled = false;
    _didInit = false;
    _waitingForEI = false;
    _initPending = false;
    _didAppend = false;
    _appendSuccess = false;
    _disabled = false;
    _s.swfLoaded = false;
    _s.soundIDs = {};
    _s.sounds = [];
    _s.o = null;
    for (i = _onready.length; i--;) {
      _onready[i].fired = false;
    }
    _s._wD(_sm + ': Rebooting...');
    window.setTimeout(function() {
      // _needsFlash = _featureCheck(); // TODO: Verify if needed
      _s.beginDelayedInit();
    }, 20);
  };

  this.destruct = function() {
    _s._wD('soundManager.destruct()');
    _s.disable(true);
  };

  this.beginDelayedInit = function() {
    // _s._wD('soundManager.beginDelayedInit()');
    _windowLoaded = true;
    setTimeout(_waitForEI, 500);
    setTimeout(_beginInit, 20);
  };

  // --- private SM2 internals ---

  _html5CanPlay = function(sURL) {
    // try to find MIME, test and return truthiness
    if (!_s.useHTML5Audio || !_s.hasHTML5) {
      return false;
    }
    var result, mime, fileExt, item, aF = _s.audioFormats;
    if (!_html5Ext) {
      _html5Ext = [];
      for (item in aF) {
        if (aF.hasOwnProperty(item)) {
          _html5Ext.push(item);
          if (aF[item].related) {
            _html5Ext = _html5Ext.concat(aF[item].related);
          }
        }
      }
      _html5Ext = new RegExp('\\.('+_html5Ext.join('|')+')','i');
    }
    mime = (typeof sURL.type !== 'undefined'?sURL.type:null);
    fileExt = (typeof sURL === 'string'?sURL.match(_html5Ext):null); // TODO: Strip URL queries, etc.
    if (!fileExt || !fileExt.length) {
      if (!mime) {
        return false;
      }
    } else {
      fileExt = fileExt[0].substr(1); // "mp3", for example
    }
    if (fileExt && typeof _s.html5[fileExt] !== 'undefined') {
      // result known
      return _s.html5[fileExt];
    } else {
      if (!mime) {
        if (fileExt && _s.html5[fileExt]) {
          return _s.html5[fileExt];
        } else {
          // best-case guess, audio/whatever-dot-filename-format-you're-playing
          mime = 'audio/'+fileExt;
        }
      }
      result = _s.html5.canPlayType(mime);
      _s.html5[fileExt] = result;
      // _s._wD('canPlayType, found result: '+result);
      return result;
    }
  };

  _testHTML5 = function() {
    if (!_s.useHTML5Audio || typeof Audio === 'undefined') {
      return false;
    }
    var a = (typeof Audio !== 'undefined' ? new Audio():null),
    test_uris = {
      // attempt to load real audio data, since canPlayType() is so inconsistent cross-browser.
      mp3: 'data:audio/mpeg;base64,/+MYxAALOAHgCAAAAD////////////v6OGAfB8HwfAgIAgCAYB8HwfB8CAgCAIAgD4Pg+D4OAgCAIP9Xt6vb1CV0qLA0DQND/+MYxA4FcAHcAAAAAISgqCtvV7eqTEFNRTMuOTguNKqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq/+MYxDMAAANIAAAAAKqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq',
      wav: 'data:audio/wave;base64,UklGRiYAAABXQVZFZm10IBAAAAABAAEAQB8AAIA+AAACABAAZGF0YQIAAAD//w=='
    },
    testsQueued = 0, testsDone = 0, base64_results = {}, item, support = {}, aF, i;

    function _cp(m) {
      var canPlay, i, j, isOK = false;
      if (!a || typeof a.canPlayType !== 'function') {
        return false;
      }
      if (m instanceof Array) {
        // iterate through all mime types, return any successes
        for (i=0, j=m.length; i<j && !isOK; i++) {
          if (_s.html5[m[i]] || a.canPlayType(m[i]).match(_s.html5Test)) {
            isOK = true;
            _s.html5[m[i]] = true;
          }
        }
        return isOK;
      } else {
        canPlay = (a && typeof a.canPlayType === 'function' ? a.canPlayType(m) : false);
        return (canPlay && (canPlay.match(_s.html5Test)?true:false));
      }
    }

    function _testBase64(sType, onComplete) {
      var a, didFire = false;
      testsQueued++;

      function checkReady() {
        if (testsDone >= testsQueued && !_html5Ready) {
          _html5Ready = true;
          if (_didDCLoaded) {
            // domready etc. already fired and missed
            _go();
          }
        }
      }

      if (_isMobile) {
        // ipad straight up barfs with this, other mobile phones likely do also.
        testsDone++;
        onComplete();
        checkReady();
        return false;
      }

      function handler(isOK, e) {
        if (!didFire) {
          didFire = true;
          testsDone++;
          base64_results[sType] = isOK;
          onComplete(isOK);
          checkReady();
        }
      }

      if (typeof base64_results[sType] !== 'undefined') {
        didFire = true;
        onComplete(base64_results[sType]);
      } else {
        // TODO: Ensure that empty constructor (with no URL) is OK everywhere
        a = new Audio(test_uris[sType]); // '' or 'about:blank' may mean media errors, so don't use this.

        a.addEventListener('canplay', function(e) {
          handler(true, e);
          a = null;
        }, false);

        a.addEventListener('canplaythrough', function(e) {
          handler(true, e);
          a = null;
        }, false);

        a.addEventListener('error', function(e) {
          // ignore base64: fail, may be a false positive.
          handler(false, this.error?this.error:e);
          a = null;
        }, false);

        a.addEventListener('stalled', function(e) {
          handler(false, e);
          a = null;
        }, false);

        // a.src = test_uris[sType];
        a.load();
      }
    }

    // test all registered formats + codecs
    aF = _s.audioFormats;
    for (item in aF) {
      if (aF.hasOwnProperty(item)) {
        support[item] = _cp(aF[item].type);
        // assign result to related formats, too
        if (aF[item] && aF[item].related) {
          for (i=0; i<aF[item].related.length; i++) {
            _s.html5[aF[item].related[i]] = support[item];
          }
        }
      }
    }

    support.canPlayType = (a?_cp:null);

    _s.html5 = _mergeObjects(_s.html5, support);

    // base64 hackishness, sometimes works
    // +ve base64 results override previous failures

    if (!_s.html5.mp3) {
      _testBase64('mp3', function(isOK) {
        if (isOK) {
          _s.html5.mp3 = isOK;
        }
      });
    }

    if (!_s.html5.wav) {
      _testBase64('wav', function(isOK) {
        if (isOK) {
          _s.html5.wav = isOK;
        }
      });
    }

  };

  _strings = {
    notReady: 'Not loaded yet - wait for soundManager.onload() before calling sound-related methods',
    appXHTML: _sm + '::createMovie(): appendChild/innerHTML set failed. May be app/xhtml+xml DOM-related.',
    spcWmode: _sm + '::createMovie(): Removing wmode, preventing win32 below-the-fold SWF loading issue',
    swf404: _sm + ': Verify that %s is a valid path.',
    tryDebug: 'Try ' + _sm + '.debugFlash = true for more security details (output goes to SWF.)',
    checkSWF: 'See SWF output for more debug info.',
    localFail: _sm + ': Non-HTTP page (' + document.location.protocol + ' URL?) Review Flash player security settings for this special case:\nhttp://www.macromedia.com/support/documentation/en/flashplayer/help/settings_manager04.html\nMay need to add/allow path, eg. c:/sm2/ or /users/me/sm2/',
    waitFocus: _sm + ': Special case: Waiting for focus-related event..',
    waitImpatient: _sm + ': Getting impatient, still waiting for Flash%s...',
    waitForever: _sm + ': Waiting indefinitely for Flash (will recover if unblocked)...',
    needFunction: _sm + '.onready(): Function object expected',
    badID: 'Warning: Sound ID "%s" should be a string, starting with a non-numeric character',
    fl9Vid: 'flash 9 required for video. Exiting.',
    noMS: 'MovieStar mode not enabled. Exiting.',
    currentObj: '--- ' + _sm + '._debug(): Current sound objects ---',
    waitEI: _sm + '::initMovie(): Waiting for ExternalInterface call from Flash..',
    waitOnload: _sm + ': Waiting for window.onload()',
    docLoaded: _sm + ': Document already loaded',
    onload: _sm + '::initComplete(): calling soundManager.onload()',
    onloadOK: _sm + '.onload() complete',
    init: '-- ' + _sm + '::init() --',
    didInit: _sm + '::init(): Already called?',
    flashJS: _sm + ': Attempting to call Flash from JS..',
    noPolling: _sm + ': Polling (whileloading()/whileplaying() support) is disabled.',
    secNote: 'Flash security note: Network/internet URLs will not load due to security restrictions. Access can be configured via Flash Player Global Security Settings Page: http://www.macromedia.com/support/documentation/en/flashplayer/help/settings_manager04.html',
    badRemove: 'Warning: Failed to remove flash movie.',
    noPeak: 'Warning: peakData features unsupported for movieStar formats',
    shutdown: _sm + '.disable(): Shutting down',
    queue: _sm + '.onready(): Queueing handler',
    smFail: _sm + ': Failed to initialise.',
    smError: 'SMSound.load(): Exception: JS-Flash communication failed, or JS error.',
    fbTimeout: 'No flash response, applying .'+_s.swfCSS.swfTimedout+' CSS..',
    fbLoaded: 'Flash loaded',
    manURL: 'SMSound.load(): Using manually-assigned URL',
    onURL: _sm + '.load(): current URL already assigned.',
    badFV: 'soundManager.flashVersion must be 8 or 9. "%s" is invalid. Reverting to %s.',
    as2loop: 'Note: Setting stream:false so looping can work (flash 8 limitation)',
    noNSLoop: 'Note: Looping not implemented for MovieStar formats'
  };

  _id = function(sID) {
    return document.getElementById(sID);
  };

  _wdCount = 0;

  _str = function() { // o [,items to replace]
    var params = Array.prototype.slice.call(arguments), // real array, please
    o = params.shift(), // first arg
    str = (_strings && _strings[o]?_strings[o]:''), i, j;
    if (str && params && params.length) {
      for (i = 0, j = params.length; i < j; i++) {
        str = str.replace('%s', params[i]);
      }
    }
    return str;
  };

  _loopFix = function(sOpt) {
    // flash 8 requires stream = false for looping to work.
    if (_s.flashVersion === 8 && sOpt.loops > 1 && sOpt.stream) {
      _wDS('as2loop');
      sOpt.stream = false;
    }
    return sOpt;
  };

  _complain = function(sMsg, oCaller) {
    // Try to create meaningful custom errors, w/stack trace to the "offending" line
    var sPre = 'Error: ', errorDesc;
    if (!oCaller) {
      return new Error(sPre + sMsg);
    }
    if (typeof console !== 'undefined' && typeof console.trace !== 'undefined') {
      console.trace();
    }
    errorDesc = sPre + sMsg + '. \nCaller: ' + oCaller.toString();
    // See JS error/debug/console output for real error source, stack trace / message detail where possible.
    return new Error(errorDesc);
  };

  _doNothing = function() {
    return false;
  };

  _disableObject = function(o) {
    for (var oProp in o) {
      if (o.hasOwnProperty(oProp) && typeof o[oProp] === 'function') {
        o[oProp] = _doNothing;
      }
    }
    oProp = null;
  };

  _failSafely = function(bNoDisable) {
    // general failure exception handler
    if (typeof bNoDisable === 'undefined') {
      bNoDisable = false;
    }
    if (_disabled || bNoDisable) {
      _wDS('smFail', 2);
      _s.disable(bNoDisable);
    }
  };

  _normalizeMovieURL = function(smURL) {
    var urlParams = null;
    if (smURL) {
      if (smURL.match(/\.swf(\?\.*)?$/i)) {
        urlParams = smURL.substr(smURL.toLowerCase().lastIndexOf('.swf?') + 4);
        if (urlParams) {
          return smURL; // assume user knows what they're doing
        }
      } else if (smURL.lastIndexOf('/') !== smURL.length - 1) {
        smURL = smURL + '/';
      }
    }
    return (smURL && smURL.lastIndexOf('/') !== - 1?smURL.substr(0, smURL.lastIndexOf('/') + 1):'./') + _s.movieURL;
  };

  _setVersionInfo = function() {
    if (_s.flashVersion !== 8 && _s.flashVersion !== 9) {
      alert(_str('badFV', _s.flashVersion, _defaultFlashVersion));
      _s.flashVersion = _defaultFlashVersion;
    }
    var isDebug = (_s.debugMode || _s.debugFlash?'_debug.swf':'.swf'); // debug flash movie, if applicable
    _s.version = _s.versionNumber + (_html5Only?' (HTML5-only mode)':(_s.flashVersion === 9?' (AS3/Flash 9)':' (AS2/Flash 8)'));
    // set up default options
    if (_s.flashVersion > 8) {
      _s.defaultOptions = _mergeObjects(_s.defaultOptions, _s.flash9Options);
      _s.features.buffering = true;
    }
    if (_s.flashVersion > 8 && _s.useMovieStar) {
      // flash 9+ support for movieStar formats as well as MP3
      _s.defaultOptions = _mergeObjects(_s.defaultOptions, _s.movieStarOptions);
      _s.filePatterns.flash9 = new RegExp('\\.(mp3|' + _s.netStreamTypes.join('|') + ')(\\?.*)?$', 'i');
      _s.mimePattern = _s.netStreamMimeTypes;
      _s.features.movieStar = true;
    } else {
      _s.features.movieStar = false;
    }
    _s.filePattern = _s.filePatterns[(_s.flashVersion !== 8?'flash9':'flash8')];
    _s.movieURL = (_s.flashVersion === 8?'soundmanager2.swf':'soundmanager2_flash9.swf').replace('.swf',isDebug);
    _s.features.peakData = _s.features.waveformData = _s.features.eqData = (_s.flashVersion > 8);
  };

  _getDocument = function() {
    return (document.body?document.body:(document.documentElement?document.documentElement:document.getElementsByTagName('div')[0]));
  };

  _setPolling = function(bPolling, bHighPerformance) {
    if (!_s.o || !_s.allowPolling) {
      return false;
    }
    _s.o._setPolling(bPolling, bHighPerformance);
  };

  function _initDebug() {
    if (_s.debugURLParam.test(window.location.href.toString())) {
      _s.debugMode = true; // allow force of debug mode via URL
    }
    // <d>
    var oD, oDebug, oTarget, oToggle, tmp;
    if (_s.debugMode) {

      oD = document.createElement('div');
      oD.id = _s.debugID + '-toggle';
      oToggle = {
        position: 'fixed',
        bottom: '0px',
        right: '0px',
        width: '1.2em',
        height: '1.2em',
        lineHeight: '1.2em',
        margin: '2px',
        textAlign: 'center',
        border: '1px solid #999',
        cursor: 'pointer',
        background: '#fff',
        color: '#333',
        zIndex: 10001
      };

      oD.appendChild(document.createTextNode('-'));
      oD.onclick = _toggleDebug;
      oD.title = 'Toggle SM2 debug console';

      if (_ua.match(/msie 6/i)) {
        oD.style.position = 'absolute';
        oD.style.cursor = 'hand';
      }

      for (tmp in oToggle) {
        if (oToggle.hasOwnProperty(tmp)) {
          oD.style[tmp] = oToggle[tmp];
        }
      }

    }
    if (_s.debugMode && !_id(_s.debugID) && ((!_hasConsole || !_s.useConsole) || (_s.useConsole && _hasConsole && !_s.consoleOnly))) {
      oDebug = document.createElement('div');
      oDebug.id = _s.debugID;
      oDebug.style.display = (_s.debugMode?'block':'none');
      if (_s.debugMode && !_id(oD.id)) {
        try {
          oTarget = _getDocument();
          oTarget.appendChild(oD);
        } catch(e2) {
          throw new Error(_str('appXHTML'));
        }
        oTarget.appendChild(oDebug);
      }
    }
    oTarget = null;
    _initDebug = function(){}; // one-time function
    // </d>
  }

  _createMovie = function(smID, smURL) {

    var specialCase = null,
    remoteURL = (smURL?smURL:_s.url),
    localURL = (_s.altURL?_s.altURL:remoteURL),
    oEmbed, oMovie, oTarget, tmp, movieHTML, oEl, extraClass, s, x, sClass, side = '100%';
    smID = (typeof smID === 'undefined'?_s.id:smID);
    if (_didAppend && _appendSuccess) {
      return false; // ignore if already succeeded
    }

    function _initMsg() {
      _s._wD('-- SoundManager 2 ' + _s.version + (!_html5Only && _s.useHTML5Audio?(_s.hasHTML5?' + HTML5 audio':', no HTML5 audio support'):'') + (_s.useMovieStar?', MovieStar mode':'') + (_s.useHighPerformance?', high performance mode, ':', ') + ((_s.useFastPolling?'fast':'normal') + ' polling') + (_s.wmode?', wmode: ' + _s.wmode:'') + (_s.debugFlash?', flash debug mode':'') + (_s.useFlashBlock?', flashBlock mode':'') + ' --', 1);
    }
    if (_html5Only) {
      _setVersionInfo();
      _initMsg();
      _s.oMC = _id(_s.movieID);
      _init();
      // prevent multiple init attempts
      _didAppend = true;
      _appendSuccess = true;
      return false;
    }

    _didAppend = true;

    // safety check for legacy (change to Flash 9 URL)
    _setVersionInfo();
    _s.url = _normalizeMovieURL(_overHTTP?remoteURL:localURL);
    smURL = _s.url;

    if (_s.useHighPerformance && _s.useMovieStar && _s.defaultOptions.useVideo === true) {
      specialCase = 'soundManager note: disabling highPerformance, not applicable with movieStar mode+useVideo';
      _s.useHighPerformance = false;
    }

    _s.wmode = (!_s.wmode && _s.useHighPerformance && !_s.useMovieStar?'transparent':_s.wmode);

    // TODO: revisit
    // if (_s.wmode !== null && _s.flashLoadTimeout !== 0 && (!_s.useHighPerformance || _s.debugFlash) && !_s.isIE && navigator.platform.match(/win32/i)) {

    if (_s.wmode !== null && !_s.isIE && !_s.useHighPerformance && navigator.platform.match(/win32/i)) {
      _s.specialWmodeCase = true;
      // extra-special case: movie doesn't load until scrolled into view when using wmode = anything but 'window' here
      // does not apply when using high performance (position:fixed means on-screen), OR infinite flash load timeout
      _wDS('spcWmode');
      _s.wmode = null;
    }

    if (_s.flashVersion === 8) {
      _s.allowFullScreen = false;
    }

    oEmbed = {
      name: smID,
      id: smID,
      src: smURL,
      width: side,
      height: side,
      quality: 'high',
      allowScriptAccess: _s.allowScriptAccess,
      bgcolor: _s.bgColor,
      pluginspage: 'http://www.macromedia.com/go/getflashplayer',
      type: 'application/x-shockwave-flash',
      wmode: _s.wmode,
      allowfullscreen: (_s.allowFullScreen?'true':'false')
    };

    if (_s.debugFlash) {
      oEmbed.FlashVars = 'debug=1';
    }

    if (!_s.wmode) {
      delete oEmbed.wmode; // don't write empty attribute
    }

    if (_s.isIE) {
      // IE is "special".
      oMovie = document.createElement('div');
      movieHTML = '<object id="' + smID + '" data="' + smURL + '" type="' + oEmbed.type + '" width="' + oEmbed.width + '" height="' + oEmbed.height + '"><param name="movie" value="' + smURL + '" /><param name="AllowScriptAccess" value="' + _s.allowScriptAccess + '" /><param name="quality" value="' + oEmbed.quality + '" />' + (_s.wmode?'<param name="wmode" value="' + _s.wmode + '" /> ':'') + '<param name="bgcolor" value="' + _s.bgColor + '" /><param name="allowFullScreen" value="' + oEmbed.allowFullScreen + '" />' + (_s.debugFlash?'<param name="FlashVars" value="' + oEmbed.FlashVars + '" />':'') + '<!-- --></object>';
    } else {
      oMovie = document.createElement('embed');
      for (tmp in oEmbed) {
        if (oEmbed.hasOwnProperty(tmp)) {
          oMovie.setAttribute(tmp, oEmbed[tmp]);
        }
      }
    }

    _initDebug();

    extraClass = _getSWFCSS();
    oTarget = _getDocument();

    if (oTarget) {
      _s.oMC = _id(_s.movieID)?_id(_s.movieID):document.createElement('div');
      if (!_s.oMC.id) {
        _s.oMC.id = _s.movieID;
        _s.oMC.className = _s.swfCSS.swfDefault + ' ' + extraClass;
        // "hide" flash movie
        s = null;
        oEl = null;
        if (!_s.useFlashBlock) {
          if (_s.useHighPerformance) {
            s = {
              position: 'fixed',
              width: '8px',
              height: '8px',
              // >= 6px for flash to run fast, >= 8px to start up under Firefox/win32 in some cases. odd? yes.
              bottom: '0px',
              left: '0px',
              overflow: 'hidden'
              // zIndex:-1 // sit behind everything else - potentially dangerous/buggy?
            };
          } else {
            s = {
              position: 'absolute',
              width: '6px',
              height: '6px',
              top: '-9999px',
              left: '-9999px'
            };
          }
        }
        x = null;
        if (!_s.debugFlash) {
          for (x in s) {
            if (s.hasOwnProperty(x)) {
              _s.oMC.style[x] = s[x];
            }
          }
        }
        try {
          if (!_s.isIE) {
            _s.oMC.appendChild(oMovie);
          }
          oTarget.appendChild(_s.oMC);
          if (_s.isIE) {
            oEl = _s.oMC.appendChild(document.createElement('div'));
            oEl.className = 'sm2-object-box';
            oEl.innerHTML = movieHTML;
          }
          _appendSuccess = true;
        } catch(e) {
          throw new Error(_str('appXHTML'));
        }
      } else {
        // it's already in the document.
        sClass = _s.oMC.className;
        _s.oMC.className = (sClass?sClass+' ':_s.swfCSS.swfDefault) + (extraClass?' '+extraClass:'');
        _s.oMC.appendChild(oMovie);
        if (_s.isIE) {
          oEl = _s.oMC.appendChild(document.createElement('div'));
          oEl.className = 'sm2-object-box';
          oEl.innerHTML = movieHTML;
        }
        _appendSuccess = true;
      }
    }

    if (specialCase) {
      _s._wD(specialCase);
    }

    _initMsg();
    _s._wD('soundManager::createMovie(): Trying to load ' + smURL + (!_overHTTP && _s.altURL?' (alternate URL)':''), 1);

  };

  _idCheck = this.getSoundById;

  // <d>
  _wDS = function(o, errorLevel) {
    if (!o) {
      return '';
    } else {
      return _s._wD(_str(o), errorLevel);
    }
  };

  if (window.location.href.indexOf('debug=alert') + 1 && _s.debugMode) {
    _s._wD = function(sText) {alert(sText);};
  }

  _toggleDebug = function() {
    var o = _id(_s.debugID),
    oT = _id(_s.debugID + '-toggle');
    if (!o) {
      return false;
    }
    if (_debugOpen) {
      // minimize
      oT.innerHTML = '+';
      o.style.display = 'none';
    } else {
      oT.innerHTML = '-';
      o.style.display = 'block';
    }
    _debugOpen = !_debugOpen;
  };

  _debugTS = function(sEventType, bSuccess, sMessage) {
    // troubleshooter debug hooks
    if (typeof sm2Debugger !== 'undefined') {
      try {
        sm2Debugger.handleEvent(sEventType, bSuccess, sMessage);
      } catch(e) {
        // oh well  
      }
    }
  };
  // </d>

  _mergeObjects = function(oMain, oAdd) {
    // non-destructive merge
    var o1 = {}, // clone o1
    i, o2, o;
    for (i in oMain) {
      if (oMain.hasOwnProperty(i)) {
        o1[i] = oMain[i];
      }
    }
    o2 = (typeof oAdd === 'undefined'?_s.defaultOptions:oAdd);
    for (o in o2) {
      if (o2.hasOwnProperty(o) && typeof o1[o] === 'undefined') {
        o1[o] = o2[o];
      }
    }
    return o1;
  };

  _initMovie = function() {
    if (_html5Only) {
      _createMovie();
      return false;
    }
    // attempt to get, or create, movie
    if (_s.o) {
      return false; // may already exist
    }
    _s.o = _s.getMovie(_s.id); // (inline markup)
    if (!_s.o) {
      if (!_oRemoved) {
        // try to create
        _createMovie(_s.id, _s.url);
      } else {
        // try to re-append removed movie after reboot()
        if (!_s.isIE) {
          _s.oMC.appendChild(_oRemoved);
        } else {
          _s.oMC.innerHTML = _oRemovedHTML;
        }
        _oRemoved = null;
        _didAppend = true;
      }
      _s.o = _s.getMovie(_s.id);
    }
    if (_s.o) {
      _s._wD('soundManager::initMovie(): Got '+_s.o.nodeName+' element ('+(_didAppend?'created via JS':'static HTML')+')');
      _wDS('waitEI');
    }
    if (typeof _s.oninitmovie === 'function') {
      setTimeout(_s.oninitmovie, 1);
    }
  };

  _go = function(sURL) {
    // where it all begins.
    if (sURL) {
      _s.url = sURL;
    }
    _initMovie();
  };

  _waitForEI = function() {
    if (_waitingForEI) {
      return false;
    }
    _waitingForEI = true;
    if (_tryInitOnFocus && !_isFocused) {
      _wDS('waitFocus');
      return false;
    }
    var p;
    if (!_didInit) {
      p = _s.getMoviePercent();
      _s._wD(_str('waitImpatient', (p === 100?' (SWF loaded)':(p > 0?' (SWF ' + p + '% loaded)':''))));
    }
    setTimeout(function() {
      p = _s.getMoviePercent();
      if (!_didInit) {
        _s._wD(_sm + ': No Flash response within expected time.\nLikely causes: ' + (p === 0?'Loading ' + _s.movieURL + ' may have failed (and/or Flash ' + _s.flashVersion + '+ not present?), ':'') + 'Flash blocked or JS-Flash security error.' + (_s.debugFlash?' ' + _str('checkSWF'):''), 2);
        if (!_overHTTP && p) {
          _wDS('localFail', 2);
          if (!_s.debugFlash) {
            _wDS('tryDebug', 2);
          }
        }
        if (p === 0) {
          // if 0 (not null), probably a 404.
          _s._wD(_str('swf404', _s.url));
        }
        _debugTS('flashtojs', false, ': Timed out' + (_overHTTP)?' (Check flash security or flash blockers)':' (No plugin/missing SWF?)');
      }
      // give up / time-out, depending
      if (!_didInit && _okToDisable) {
        if (p === null) {
          // SWF failed. Maybe blocked.
          if (_s.useFlashBlock || _s.flashLoadTimeout === 0) {
            if (_s.useFlashBlock) {
              _flashBlockHandler();
            }
            _wDS('waitForever');
          } else {
            // old SM2 behaviour, simply fail
            _failSafely(true);
          }
        } else {
          // flash loaded? Shouldn't be a blocking issue, then.
          if (_s.flashLoadTimeout === 0) {
             _wDS('waitForever');
          } else {
            _failSafely(true);
          }
        }
      }
    }, _s.flashLoadTimeout);
  };

  _getSWFCSS = function() {
    var css = [];
    if (_s.debugMode) {
      css.push(_s.swfCSS.sm2Debug);
    }
    if (_s.debugFlash) {
      css.push(_s.swfCSS.flashDebug);
    }
    if (_s.useHighPerformance) {
      css.push(_s.swfCSS.highPerf);
    }
    return css.join(' ');
  };

  _flashBlockHandler = function() {
    // *possible* flash block situation.
    var name = 'soundManager::flashBlockHandler()', p = _s.getMoviePercent();
    if (!_s.supported()) {
      if (_needsFlash) {
        // make the movie more visible, so user can fix
        _s.oMC.className = _getSWFCSS() + ' ' + _s.swfCSS.swfDefault + ' ' + (p === null?_s.swfCSS.swfTimedout:_s.swfCSS.swfError);
        _s._wD(name+': '+_str('fbTimeout')+(p?' ('+_str('fbLoaded')+')':''));
      }
      _processOnReady(true); // fire onready(), complain lightly
      // onerror?
      if (_s.onerror instanceof Function) {
        _s.onerror.apply(window);
      }
      _s.didFlashBlock = true;
    } else {
      // SM2 loaded OK (or recovered)
      if (_s.didFlashBlock) {
        _s._wD(name+': Unblocked');
      }
      if (_s.oMC) {
        _s.oMC.className = _getSWFCSS() + ' ' + _s.swfCSS.swfDefault + (' '+_s.swfCSS.swfUnblocked);
      }
    }
  };

  _handleFocus = function() {
    if (_isFocused || !_tryInitOnFocus) {
      return true;
    }
    _okToDisable = true;
    _isFocused = true;
    _s._wD('soundManager::handleFocus()');
    if (_tryInitOnFocus) {
      // giant Safari 3.1 hack - assume window in focus if mouse is moving, since document.hasFocus() not currently implemented.
      window.removeEventListener('mousemove', _handleFocus, false);
    }
    // allow init to restart
    _waitingForEI = false;
    setTimeout(_waitForEI, 500);
    // detach event
    if (window.removeEventListener) {
      window.removeEventListener('focus', _handleFocus, false);
    } else if (window.detachEvent) {
      window.detachEvent('onfocus', _handleFocus);
    }
  };

  _initComplete = function(bNoDisable) {
    if (_didInit) {
      return false;
    }
    if (_html5Only) {
      // all good.
      _s._wD('-- SoundManager 2: loaded --');
      _didInit = true;
      _processOnReady();
      _initUserOnload();
      return true;
    }
    var sClass = _s.oMC.className,
    wasTimeout = (_s.useFlashBlock && _s.flashLoadTimeout && !_s.getMoviePercent());
    if (!wasTimeout) {
      _didInit = true;
    }
    _s._wD('-- SoundManager 2 ' + (_disabled?'failed to load':'loaded') + ' (' + (_disabled?'security/load error':'OK') + ') --', 1);
    if (_disabled || bNoDisable) {
      if (_s.useFlashBlock) {
        _s.oMC.className = _getSWFCSS() + ' ' + (_s.getMoviePercent() === null?_s.swfCSS.swfTimedout:_s.swfCSS.swfError);
      }
      _processOnReady();
      _debugTS('onload', false);
      if (_s.onerror instanceof Function) {
        _s.onerror.apply(window);
      }
      return false;
    } else {
      _debugTS('onload', true);
    }
    if (_s.waitForWindowLoad && !_windowLoaded) {
      _wDS('waitOnload');
      if (window.addEventListener) {
        window.addEventListener('load', _initUserOnload, false);
      } else if (window.attachEvent) {
        window.attachEvent('onload', _initUserOnload);
      }
      return false;
    } else {
      if (_s.waitForWindowLoad && _windowLoaded) {
        _wDS('docLoaded');
      }
      _initUserOnload();
    }
  };

  _addOnReady = function(oMethod, oScope) {
    _onready.push({
      'method': oMethod,
      'scope': (oScope || null),
      'fired': false
    });
  };

  _processOnReady = function(ignoreInit) {
    if (!_didInit && !ignoreInit) {
      // not ready yet.
      return false;
    }
    var status = {
      success: (ignoreInit?_s.supported():!_disabled)
    },
    queue = [], i, j,
    canRetry = (!_s.useFlashBlock || (_s.useFlashBlock && !_s.supported()));
    for (i = 0, j = _onready.length; i < j; i++) {
      if (_onready[i].fired !== true) {
        queue.push(_onready[i]);
      }
    }
    if (queue.length) {
      _s._wD(_sm + ': Firing ' + queue.length + ' onready() item' + (queue.length > 1?'s':''));
      for (i = 0, j = queue.length; i < j; i++) {
        if (queue[i].scope) {
          queue[i].method.apply(queue[i].scope, [status]);
        } else {
          queue[i].method(status);
        }
        if (!canRetry) { // flashblock case doesn't count here
          queue[i].fired = true;
        }
      }
    }
  };

  _initUserOnload = function() {
    window.setTimeout(function() {
      if (_s.useFlashBlock) {
        _flashBlockHandler();
      }
      _processOnReady();
      _wDS('onload', 1);
      // call user-defined "onload", scoped to window
      _s.onload.apply(window);
      _wDS('onloadOK', 1);
    },1);
  };

  _featureCheck = function() {
    var needsFlash, item,
    isBadSafari = (_s.isSafari && _ua.match(/OS X 10_6_3/i) && _ua.match(/531\.22\.7/i)), // https://bugs.webkit.org/show_bug.cgi?id=32159
    isSpecial = (_ua.match(/iphone os (1|2|3_0|3_1)/i)?true:false); // iPhone <= 3.1 is broken (OS 4 support currently unknown.)
    if (isSpecial) {
      _s.hasHTML5 = false; // has Audio(), but is broken; let it load links directly.
      _html5Only = true; // ignore flash case, however
      if (_s.oMC) {
        _s.oMC.style.display = 'none';
      }
      return false;
    }
    if (_s.useHTML5Audio) {
      if (!_s.html5 || !_s.html5.canPlayType) {
        _s._wD('SoundManager: No HTML5 Audio() support detected.');
        _s.hasHTML5 = false;
        return true;
      } else {
        _s.hasHTML5 = true;
      }
      if (isBadSafari) {
        _s._wD('Note: Buggy HTML5 in this version of Safari, see https://bugs.webkit.org/show_bug.cgi?id=32159 - disabling HTML5',1);
        _s.useHTML5Audio = false;
        _s.hasHTML5 = false;
        return true;
      }
    } else {
      // flash required.
      return true;
    }
    for (item in _s.audioFormats) {
      if (_s.audioFormats.hasOwnProperty(item)) {
        if (_s.audioFormats[item].required && !_s.html5.canPlayType(_s.audioFormats[item].type)) {
          // may need flash for this format?
          needsFlash = true;
        }
      }
    }
    // sanity check..
    if (_s.ignoreFlash) {
      needsFlash = false;
    }
    _html5Only = (_s.useHTML5Audio && _s.hasHTML5 && !needsFlash);
    return needsFlash;
  };

  _init = function() {
    var item, tests = [];
    _wDS('init');
    // called after onload()

    if (_didInit) {
      _wDS('didInit');
      return false;
    }

    function _cleanup() {
      if (window.removeEventListener) {
        window.removeEventListener('load', _s.beginDelayedInit, false);
      } else if (window.detachEvent) {
        window.detachEvent('onload', _s.beginDelayedInit);
      }
    }

    if (_s.hasHTML5) {
      for (item in _s.audioFormats) {
        if (_s.audioFormats.hasOwnProperty(item)) {
          tests.push(item+': '+_s.html5[item]);
        }
      }
      _s._wD('-- SoundManager 2: HTML5 support tests ('+_s.html5Test+'): '+tests.join(', ')+' --',1);
    }

    if (_html5Only) {
      if (!_didInit) {
        // we don't need no steenking flash!
        _cleanup();
        _s.enabled = true;
        _initComplete();
      }
      return true;
    }

    // flash path
    _initMovie();
    try {
      _wDS('flashJS');
      _s.o._externalInterfaceTest(false); // attempt to talk to Flash
      if (!_s.allowPolling) {
        _wDS('noPolling', 1);
      } else {
        _setPolling(true, _s.useFastPolling?true:false);
      }
      if (!_s.debugMode) {
        _s.o._disableDebug();
      }
      _s.enabled = true;
      _debugTS('jstoflash', true);
    } catch(e) {
      _s._wD('js/flash exception: ' + e.toString());
      _debugTS('jstoflash', false);
      _failSafely(true); // don't disable, for reboot()
      _initComplete();
      return false;
    }
    _initComplete();
    // event cleanup
    _cleanup();
  };

  _beginInit = function() {
    if (_initPending) {
      return false;
    }
    _createMovie();
    _initMovie();
    _initPending = true;
    return true;
  };

  _dcLoaded = function() {
    _initDebug();
    _testHTML5();
    _needsFlash = _featureCheck();
    _didDCLoaded = true;
    if (_s.useHTML5Audio && _s.hasHTML5) {
      if (_html5Ready) {
        _go();
      }
    } else {
      _go();
    }
  };

  _startTimer = function(oSound) {
    if (!oSound._hasTimer) {
      oSound._hasTimer = true;
    }
  };

  _stopTimer = function(oSound) {
    if (oSound._hasTimer) {
      oSound._hasTimer = false;
    }
  };

  // "private" methods called by Flash

  this._setSandboxType = function(sandboxType) {
    var sb = _s.sandbox;
    sb.type = sandboxType;
    sb.description = sb.types[(typeof sb.types[sandboxType] !== 'undefined'?sandboxType:'unknown')];
    _s._wD('Flash security sandbox type: ' + sb.type);
    if (sb.type === 'localWithFile') {
      sb.noRemote = true;
      sb.noLocal = false;
      _wDS('secNote', 2);
    } else if (sb.type === 'localWithNetwork') {
      sb.noRemote = false;
      sb.noLocal = true;
    } else if (sb.type === 'localTrusted') {
      sb.noRemote = false;
      sb.noLocal = false;
    }
  };

  this._externalInterfaceOK = function(flashDate) {
    // callback from flash for confirming that movie loaded, EI is working etc.
    // flashDate = approx. timing/delay info for JS/flash bridge
    if (_s.swfLoaded) {
      return false;
    }
    var eiTime = new Date().getTime();
    _s._wD('soundManager::externalInterfaceOK()' + (flashDate?' (~' + (eiTime - flashDate) + ' ms)':''));
    _debugTS('swf', true);
    _debugTS('flashtojs', true);
    _s.swfLoaded = true;
    _tryInitOnFocus = false;
    if (_s.isIE) {
      // IE needs a timeout OR delay until window.onload - may need TODO: investigating
      setTimeout(_init, 100);
    } else {
      _init();
    }
  };

  this._onfullscreenchange = function(bFullScreen) {
    _s._wD('onfullscreenchange(): ' + bFullScreen);
    _s.isFullScreen = (bFullScreen === 1?true:false);
    if (!_s.isFullScreen) {
      // attempt to restore window focus after leaving full-screen
      try {
        window.focus();
        _s._wD('window.focus()');
      } catch(e) {
        // oh well
      }
    }
  };

  // --- SMSound (sound object) instance ---

  SMSound = function(oOptions) {
    var _t = this, _resetProperties, _add_html5_events, _stop_html5_timer, _start_html5_timer, _get_html5_duration;
    this.sID = oOptions.id;
    this.url = oOptions.url;
    this.options = _mergeObjects(oOptions);
    this.instanceOptions = this.options; // per-play-instance-specific options
    this._iO = this.instanceOptions; // short alias
    // assign property defaults (volume, pan etc.)
    this.pan = this.options.pan;
    this.volume = this.options.volume;
    this._lastURL = null;
    this.isHTML5 = false;

    // --- public methods ---

    this.id3 = {
      /* 
        Name/value pairs eg. this.id3.songname set via Flash when available - download docs for reference
        http://livedocs.macromedia.com/flash/8/
      */
    };

    this._debug = function() {
      // <d>
      // pseudo-private console.log()-style output
      if (_s.debugMode) {
        var stuff = null, msg = [], sF, sfBracket, maxLength = 64;
        for (stuff in _t.options) {
          if (_t.options[stuff] !== null) {
            if (_t.options[stuff] instanceof Function) {
              // handle functions specially
              sF = _t.options[stuff].toString();
              sF = sF.replace(/\s\s+/g, ' '); // normalize spaces
              sfBracket = sF.indexOf('{');
              msg.push(' ' + stuff + ': {' + sF.substr(sfBracket + 1, (Math.min(Math.max(sF.indexOf('\n') - 1, maxLength), maxLength))).replace(/\n/g, '') + '... }');
            } else {
              msg.push(' ' + stuff + ': ' + _t.options[stuff]);
            }
          }
        }
        _s._wD('SMSound() merged options: {\n' + msg.join(', \n') + '\n}');
      }
      // </d>
    };

    this._debug();

    this.load = function(oOptions) {
      var oS = null;
      if (typeof oOptions !== 'undefined') {
        _t._iO = _mergeObjects(oOptions);
        _t.instanceOptions = _t._iO;
      } else {
        oOptions = _t.options;
        _t._iO = oOptions;
        _t.instanceOptions = _t._iO;
        if (_t._lastURL && _t._lastURL !== _t.url) {
          _wDS('manURL');
          _t._iO.url = _t.url;
          _t.url = null;
        }
      }
      if (typeof _t._iO.url === 'undefined') {
        _t._iO.url = _t.url;
      }
      _s._wD('soundManager.load(): ' + _t._iO.url, 1);
      if (_t._iO.url === _t.url && _t.readyState !== 0 && _t.readyState !== 2) {
        _wDS('onURL', 1);
        return false;
      }
      _t.url = _t._iO.url;
      _t._lastURL = _t._iO.url;
      _t.loaded = false;
      _t.readyState = 1;
      _t.playState = 0; // (oOptions.autoPlay?1:0); // if autoPlay, assume "playing" is true (no way to detect when it actually starts in Flash unless onPlay is watched?)
      if (_html5CanPlay(_t._iO.url)) {
        _s._wD('HTML 5 load: '+_t._iO.url);
        oS = _t._setup_html5(_t._iO);
        // if autoplay..
        if (_t._iO.autoPlay) {
          // oS.load(); // required? Uncertain.
          _t.play();
        }
      } else {
        try {
          _t.isHTML5 = false;
          _t._iO = _loopFix(_t._iO);
          if (_s.flashVersion === 8) {
            _s.o._load(_t.sID, _t._iO.url, _t._iO.stream, _t._iO.autoPlay, (_t._iO.whileloading?1:0), _t._iO.loops||1);
          } else {
            _s.o._load(_t.sID, _t._iO.url, _t._iO.stream?true:false, _t._iO.autoPlay?true:false, _t._iO.loops||1); // ,(_tO.whileloading?true:false)
            if (_t._iO.isMovieStar && _t._iO.autoLoad && !_t._iO.autoPlay) {
              // special case: MPEG4 content must start playing to load, then pause to prevent playing.
              _t.pause();
            }
          }
        } catch(e) {
          _wDS('smError', 2);
          _debugTS('onload', false);
          _s.onerror();
          _s.disable();
        }
      }
    };

    this.unload = function() {
      // Flash 8/AS2 can't "close" a stream - fake it by loading an empty MP3
      // Flash 9/AS3: Close stream, preventing further load
      if (_t.readyState !== 0) {
        _s._wD('SMSound.unload(): "' + _t.sID + '"');
        if (_t.readyState !== 2) { // reset if not error
          _t.setPosition(0, true); // reset current sound positioning
        }
        if (!_t.isHTML5) {
          _s.o._unload(_t.sID, _s.nullURL);
        } else {
          _stop_html5_timer();
          if (_t.__element) {
            // abort()-style method here, stop loading? (doesn't exist?)
            _t.__element.pause();
            _t.__element.src = 'about:blank'; // needed? does nulling object work? any better way to cancel/unload/abort?
            _t.__element.load();
            _t.__element = null;
            // delete _t.__element;
          }
        } 
        // reset load/status flags
        _resetProperties();
      }
    };

    this.destruct = function() {
      _s._wD('SMSound.destruct(): "' + _t.sID + '"');
      if (!_t.isHTML5) {
        // kill sound within Flash
        _s.o._destroySound(_t.sID);
      } else {
        _stop_html5_timer();
        if (_t.__element) {
          _t.__element.pause();
          _t.__element.src = 'about:blank';
          _t.__element.load();
          _t.__element = null;
          // delete _t.__element;
        }
      }
      _s.destroySound(_t.sID, true); // ensure deletion from controller
    };

    this.play = function(oOptions) {
      var fN = 'SMSound.play(): ', allowMulti;
      if (!oOptions) {
        oOptions = {};
      }
      _t._iO = _mergeObjects(oOptions, _t._iO);
      _t._iO = _mergeObjects(_t._iO, _t.options);
      _t.instanceOptions = _t._iO;
      if (_html5CanPlay(_t._iO.url)) {
        _t._setup_html5(_t._iO);
        _start_html5_timer();
      }
      if (_t.playState === 1) {
        allowMulti = _t._iO.multiShot;
        if (!allowMulti) {
          _s._wD(fN + '"' + _t.sID + '" already playing (one-shot)', 1);
          return false;
        } else {
          _s._wD(fN + '"' + _t.sID + '" already playing (multi-shot)', 1);
          if (_t.isHTML5) {
            // TODO: BUG?
            _t.setPosition(_t._iO.position);
          }
        }
      }
      if (!_t.loaded) {
        if (_t.readyState === 0) {
          _s._wD(fN + 'Attempting to load "' + _t.sID + '"', 1);
          // try to get this sound playing ASAP
          //_t._iO.stream = true; // breaks stream=false case?
          if (!_t.isHTML5) {
            // HTML5 double-play bug otherwise.
            _t._iO.autoPlay = true;
            _t.load(_t._iO); // try to get this sound playing ASAP
          } else {
            _t.readyState = 1;
          }
          // if (typeof oOptions.autoPlay=='undefined') _tO.autoPlay = true; // only set autoPlay if unspecified here
          // _t.load(_t._iO); // moved into flash-only block
        } else if (_t.readyState === 2) {
          _s._wD(fN + 'Could not load "' + _t.sID + '" - exiting', 2);
          return false;
        } else {
          _s._wD(fN + '"' + _t.sID + '" is loading - attempting to play..', 1);
        }
      } else {
        _s._wD(fN + '"' + _t.sID + '"');
      }
      if (_t.paused) {
        _s._wD(fN + '"' + _t.sID + '" is resuming from paused state',1);
        _t.resume();
      } else {
        _s._wD(fN+'"'+ _t.sID+'" is starting to play');
        _t.playState = 1;
        if (!_t.instanceCount || (_s.flashVersion > 8 && !_t.isHTML5)) {
          _t.instanceCount++;
        }
        _t.position = (typeof _t._iO.position !== 'undefined' && !isNaN(_t._iO.position)?_t._iO.position:0);
        _t._iO = _loopFix(_t._iO);
        if (_t._iO.onplay) {
          _t._iO.onplay.apply(_t);
        }
        _t.setVolume(_t._iO.volume, true); // restrict volume to instance options only
        _t.setPan(_t._iO.pan, true);
        if (!_t.isHTML5) {
          _s.o._start(_t.sID, _t._iO.loops || 1, (_s.flashVersion === 9?_t.position:_t.position / 1000));
        } else {
          _start_html5_timer();
          _t._setup_html5().play();
        }
      }
    };

    this.start = this.play; // just for convenience

    this.stop = function(bAll) {
      if (_t.playState === 1) {
        _t._onbufferchange(0);
        if (!_t.isHTML5) {
          _t.playState = 0;
        }
        _t.paused = false;
        // if (_s.defaultOptions.onstop) _s.defaultOptions.onstop.apply(_s);
        if (_t._iO.onstop) {
          _t._iO.onstop.apply(_t);
        }
        if (!_t.isHTML5) {
          _s.o._stop(_t.sID, bAll);
        } else {
          if (_t.__element) {
            _t.setPosition(0); // act like Flash, though
            _t.__element.pause(); // html5 has no stop()
            _t.playState = 0;
            _t._onTimer(); // and update UI
            _stop_html5_timer();
            _t.unload();
            _t.__element = null;
          }
        }
        _t.instanceCount = 0;
        _t._iO = {};
        // _t.instanceOptions = _t._iO;
      }
    };

    this.setPosition = function(nMsecOffset, bNoDebug) {
      if (typeof nMsecOffset === 'undefined') {
        nMsecOffset = 0;
      }
      var offset = (_t.isHTML5 ? Math.max(nMsecOffset,0) : Math.min(_t.duration, Math.max(nMsecOffset, 0))); // position >= 0 and <= current available (loaded) duration
      _t._iO.position = offset;
      if (!_t.isHTML5) {
        _s.o._setPosition(_t.sID, (_s.flashVersion === 9?_t._iO.position:_t._iO.position / 1000), (_t.paused || !_t.playState)); // if paused or not playing, will not resume (by playing)
      } else if (_t.__element) {
        _s._wD('setPosition(): setting position to '+(_t._iO.position / 1000));
        if (_t.playState) {
          // DOM/JS errors/exceptions to watch out for:
          // if seek is beyond (loaded?) position, "DOM exception 11"
          // "INDEX_SIZE_ERR": DOM exception 1
          try {
            _t.__element.currentTime = _t._iO.position / 1000;
          } catch(e) {
            _s._wD('setPosition('+_t._iO.position+'): WARN: Caught exception: '+e.message, 2);
          }
        } else {
          _s._wD('HTML 5 warning: cannot set position while playState == 0 (not playing)',2);
        }
        if (_t.paused) { // if paused, refresh UI right away
          _t._onTimer(true); // force update
        }
      }
    };

    this.pause = function() {
      if (_t.paused || _t.playState === 0) {
        return false;
      }
      _s._wD('SMSound.pause()');
      _t.paused = true;
      if (!_t.isHTML5) {
        _s.o._pause(_t.sID);
      } else {
        _t._setup_html5().pause();
        _stop_html5_timer();
      }
      if (_t._iO.onpause) {
        _t._iO.onpause.apply(_t);
      }
    };

    this.resume = function() {
      if (!_t.paused || _t.playState === 0) {
        return false;
      }
      _s._wD('SMSound.resume()');
      _t.paused = false;
      if (!_t.isHTML5) {
        _s.o._pause(_t.sID); // flash method is toggle-based (pause/resume)
      } else {
        _t._setup_html5().play();
        _start_html5_timer();
      }
      if (_t._iO.onresume) {
        _t._iO.onresume.apply(_t);
      }
    };

    this.togglePause = function() {
      _s._wD('SMSound.togglePause()');
      if (_t.playState === 0) {
        _t.play({
          position: (_s.flashVersion === 9 && !_t.isHTML5 ? _t.position:_t.position / 1000)
        });
        return false;
      }
      if (_t.paused) {
        _t.resume();
      } else {
        _t.pause();
      }
    };

    this.setPan = function(nPan, bInstanceOnly) {
      if (typeof nPan === 'undefined') {
        nPan = 0;
      }
      if (typeof bInstanceOnly === 'undefined') {
        bInstanceOnly = false;
      }
      if (!_t.isHTML5) {
        _s.o._setPan(_t.sID, nPan);
      } else {
        // no HTML 5 pan?
      }
      _t._iO.pan = nPan;
      if (!bInstanceOnly) {
        _t.pan = nPan;
      }
    };

    this.setVolume = function(nVol, bInstanceOnly) {
      if (typeof nVol === 'undefined') {
        nVol = 100;
      }
      if (typeof bInstanceOnly === 'undefined') {
        bInstanceOnly = false;
      }
      if (!_t.isHTML5) {
        _s.o._setVolume(_t.sID, (_s.muted && !_t.muted) || _t.muted?0:nVol);
      } else if (_t.__element) {
        _t.__element.volume = nVol/100;
      } 
      _t._iO.volume = nVol;
      if (!bInstanceOnly) {
        _t.volume = nVol;
      }
    };

    this.mute = function() {
      _t.muted = true;
      if (!_t.isHTML5) {
        _s.o._setVolume(_t.sID, 0);
      } else if (_t.__element) {
        _t.__element.muted = true;
      }
    };

    this.unmute = function() {
      _t.muted = false;
      var hasIO = typeof _t._iO.volume !== 'undefined';
      if (!_t.isHTML5) {
        _s.o._setVolume(_t.sID, hasIO?_t._iO.volume:_t.options.volume);
      } else if (_t.__element) {
        _t.__element.muted = false;
      }
    };

    this.toggleMute = function() {
      if (_t.muted) {
        _t.unmute();
      } else {
        _t.mute();
      }
    };

    // pseudo-private soundManager reference

    this._onTimer = function(bForce) {
      // HTML 5-only _whileplaying() etc.
      if (_t._hasTimer || bForce) {
        var time, o;
        if (_t.__element && (bForce || ((_t.playState > 0 || _t.readyState === 1) && !_t.paused))) { // TODO: May not need to track readyState (1 = loading)
          o = _t.__element;
          _t.duration = _get_html5_duration();
          _t.durationEstimate = _t.duration;
          time = o.currentTime?o.currentTime*1000:0;
          _t._whileplaying(time,{},{},{},{});
          return true;
        } else {
         // beta testing
         _s._wD('_onTimer: Warn for "'+_t.sID+'": '+(!o?'Could not find element. ':'')+(_t.playState === 0?'playState bad, 0?':'playState = '+_t.playState+', OK'));
          return false;
        }
      }
    };

    // --- private internals ---

    _get_html5_duration = function() {
      var d = (_t.__element?_t.__element.duration*1000:undefined);
      if (d) {
        return (!isNaN(d)?d:null);
      }
    };

    _start_html5_timer = function() {
      if (_t.isHTML5) {
        _startTimer(_t);
      }
    };

    _stop_html5_timer = function() {
      if (_t.isHTML5) {
        _stopTimer(_t);
      }
    };

    _resetProperties = function(bLoaded) {
      _t._hasTimer = null;
      _t._added_events = null;
      _t.__element = null;
      _t.bytesLoaded = null;
      _t.bytesTotal = null;
      _t.position = null;
      _t.duration = null;
      _t.durationEstimate = null;
      _t.loaded = false;
      _t.playState = 0;
      _t.paused = false;
      _t.readyState = 0; // 0 = uninitialised, 1 = loading, 2 = failed/error, 3 = loaded/success
      _t.muted = false;
      _t.didBeforeFinish = false;
      _t.didJustBeforeFinish = false;
      _t.isBuffering = false;
      _t.instanceOptions = {};
      _t.instanceCount = 0;
      _t.peakData = {
        left: 0,
        right: 0
      };
      _t.waveformData = {
        left: [],
        right: []
      };
      _t.eqData = [];
      // dirty hack for now: also have left/right arrays off this, maintain compatibility
      _t.eqData.left = [];
      _t.eqData.right = [];
    };

    _resetProperties();

    // pseudo-private methods used by soundManager

    this._setup_html5 = function(oOptions) {
      var _iO = _mergeObjects(_t._iO, oOptions);
      if (_t.__element) {
        if (_t.url !== _iO.url) {
          _s._wD('setting new URL on existing object: '+_iO.url);
          _t.__element.src = _iO.url;
        }
      } else {
        _s._wD('creating HTML 5 audio element with URL: '+_iO.url);
        _t.__element = new Audio(_iO.url);
        _t.isHTML5 = true;
        _add_html5_events();
      }
      _t.__element.loop = (_iO.loops>1?'loop':'');
      return _t.__element;
    };

    // related private methods

    _add_html5_events = function() {
      if (_t._added_events) {
        return false;
      }
      _t._added_events = true;

      function _add(oEvt, oFn, bBubble) {
        return (_t.__element ? _t.__element.addEventListener(oEvt, oFn, bBubble||false) : null);
      }

      _add('load', function(e) {
        var o = _t.__element;
        _s._wD('HTML5::load: '+_t.sID);
        if (o) {
          _t._onbufferchange(0);
          _t._whileloading(_t.bytesTotal, _t.bytesTotal, _get_html5_duration());
          _t._onload(1);
        }
      }, false);

      _add('canplay', function(e) {
        _s._wD('HTML5::canplay: '+_t.sID);
        // enough has loaded to play
        _t._onbufferchange(0);
      },false);

      _add('waiting', function(e) {
        _s._wD('HTML5::waiting: '+_t.sID);
        // playback faster than download rate, etc.
        _t._onbufferchange(1);
      },false);

      _add('progress', function(e) { // not supported everywhere yet..
        var o = _t.__element;
        _s._wD('HTML5::progress: '+_t.sID+': loaded/total: '+(e.loaded||0)+','+(e.total||1));
        if (!_t.loaded && o) {
          _t._onbufferchange(0); // if progress, likely not buffering
          _t._whileloading(e.loaded||0, e.total||1, _get_html5_duration());
        }
      }, false);

      _add('end', function(e) {
        _s._wD('HTML5::end: '+_t.sID);
        _t._onfinish();
      }, false);

      _add('error', function(e) {
        if (_t.__element) {
          _s._wD('HTML5::error: '+_t.__element.error.code);
          // call load with error state?
          _t._onload(0);
        }
      }, false);

      _add('loadstart', function(e) {
        _s._wD('HTML5::loadstart: '+_t.sID);
        // assume buffering at first
        _t._onbufferchange(1);
      }, false);

      _add('play', function(e) {
        _s._wD('HTML5::play: '+_t.sID);
        // once play starts, no buffering
        _t._onbufferchange(0);
      }, false);

      // TODO: verify if this is actually implemented anywhere yet.
      _add('playing', function(e) {
        _s._wD('HTML5::playing: '+_t.sID);
        // once play starts, no buffering
        _t._onbufferchange(0);
      }, false);

      _t.__element.addEventListener('timeupdate', function(e) {
        _t._onTimer();
      }, false);

      // avoid stupid premature event-firing bug in Safari(?)
      setTimeout(function(){
        if (_t && _t.__element) {
          _add('ended',function(e) {
            _s._wD('HTML5::ended: '+_t.sID);
            _t._onfinish();
          }, false);
        }
      }, 250);

    };

    // --- "private" methods called by Flash ---

    this._whileloading = function(nBytesLoaded, nBytesTotal, nDuration) {
      if (!_t._iO.isMovieStar) {
        _t.bytesLoaded = nBytesLoaded;
        _t.bytesTotal = nBytesTotal;
        _t.duration = Math.floor(nDuration);
        _t.durationEstimate = parseInt((_t.bytesTotal / _t.bytesLoaded) * _t.duration, 10);
        if (_t.durationEstimate === undefined) {
          // reported bug?
          _t.durationEstimate = _t.duration;
        }
        if (_t.readyState !== 3 && _t._iO.whileloading) {
          _t._iO.whileloading.apply(_t);
        }
      } else {
        _t.bytesLoaded = nBytesLoaded;
        _t.bytesTotal = nBytesTotal;
        _t.duration = Math.floor(nDuration);
        _t.durationEstimate = _t.duration;
        if (_t.readyState !== 3 && _t._iO.whileloading) {
          _t._iO.whileloading.apply(_t);
        }
      }
    };

    this._onid3 = function(oID3PropNames, oID3Data) {
      // oID3PropNames: string array (names)
      // ID3Data: string array (data)
      _s._wD('SMSound._onid3(): "' + this.sID + '" ID3 data received.');
      var oData = [], i, j;
      for (i = 0, j = oID3PropNames.length; i < j; i++) {
        oData[oID3PropNames[i]] = oID3Data[i];
        // _s._wD(oID3PropNames[i]+': '+oID3Data[i]);
      }
      _t.id3 = _mergeObjects(_t.id3, oData);
      if (_t._iO.onid3) {
        _t._iO.onid3.apply(_t);
      }
    };

    this._whileplaying = function(nPosition, oPeakData, oWaveformDataLeft, oWaveformDataRight, oEQData) {

      if (isNaN(nPosition) || nPosition === null) {
        return false; // Flash may return NaN at times
      }
      if (_t.playState === 0 && nPosition > 0) {
        // can happen at the end of a video where nPosition === 33 for some reason, after finishing.???
        // can also happen with a normal stop operation. This resets the position to 0.
        // _s._writeDebug('Note: Not playing, but position = '+nPosition);
        nPosition = 0;
      }
      _t.position = nPosition;
      if (_s.flashVersion > 8 && !_t.isHTML5) {
        if (_t._iO.usePeakData && typeof oPeakData !== 'undefined' && oPeakData) {
          _t.peakData = {
            left: oPeakData.leftPeak,
            right: oPeakData.rightPeak
          };
        }
        if (_t._iO.useWaveformData && typeof oWaveformDataLeft !== 'undefined' && oWaveformDataLeft) {
          _t.waveformData = {
            left: oWaveformDataLeft.split(','),
            right: oWaveformDataRight.split(',')
          };
        }
        if (_t._iO.useEQData) {
          if (typeof oEQData !== 'undefined' && oEQData && oEQData.leftEQ) {
            var eqLeft = oEQData.leftEQ.split(',');
            _t.eqData = eqLeft;
            _t.eqData.left = eqLeft;
            if (typeof oEQData.rightEQ !== 'undefined' && oEQData.rightEQ) {
              _t.eqData.right = oEQData.rightEQ.split(',');
            }
          }
        }
      }
      if (_t.playState === 1) {
        // special case/hack: ensure buffering is false (instant load from cache, thus buffering stuck at 1?)
        if (!_t.isHTML5 && _t.isBuffering) {
          _t._onbufferchange(0);
        }
        if (_t._iO.whileplaying) {
          _t._iO.whileplaying.apply(_t); // flash may call after actual finish
        }
        if (_t.loaded && _t._iO.onbeforefinish && _t._iO.onbeforefinishtime && !_t.didBeforeFinish && _t.duration - _t.position <= _t._iO.onbeforefinishtime) {
          _s._wD('duration-position &lt;= onbeforefinishtime: ' + _t.duration + ' - ' + _t.position + ' &lt= ' + _t._iO.onbeforefinishtime + ' (' + (_t.duration - _t.position) + ')');
          _t._onbeforefinish();
        }
      }
    };

    this._onload = function(nSuccess) {
      var fN = 'SMSound._onload(): ';
      nSuccess = (nSuccess === 1?true:false);
      _s._wD(fN + '"' + _t.sID + '"' + (nSuccess?' loaded.':' failed to load? - ' + _t.url), (nSuccess?1:2));
      // <d>
      if (!nSuccess && !_t.isHTML5) {
        if (_s.sandbox.noRemote === true) {
          _s._wD(fN + _str('noNet'), 1);
        }
        if (_s.sandbox.noLocal === true) {
          _s._wD(fN + _str('noLocal'), 1);
        }
      }
      // </d>
      _t.loaded = nSuccess;
      _t.readyState = nSuccess?3:2;
      if (_t._iO.onload) {
        _t._iO.onload.apply(_t);
      }
    };

    this._onbeforefinish = function() {
      if (!_t.didBeforeFinish) {
        _t.didBeforeFinish = true;
        if (_t._iO.onbeforefinish) {
          _s._wD('SMSound._onbeforefinish(): "' + _t.sID + '"');
          _t._iO.onbeforefinish.apply(_t);
        }
      }
    };

    this._onjustbeforefinish = function(msOffset) {
      // msOffset: "end of sound" delay actual value (eg. 200 msec, value at event fire time was 187)
      if (!_t.didJustBeforeFinish) {
        _t.didJustBeforeFinish = true;
        if (_t._iO.onjustbeforefinish) {
          _s._wD('SMSound._onjustbeforefinish(): "' + _t.sID + '"');
          _t._iO.onjustbeforefinish.apply(_t);
        }
      }
    };

    this._onfinish = function() {
      // sound has finished playing
      // TODO: calling user-defined onfinish() should happen after setPosition(0)
      // OR: onfinish() and then setPosition(0) is bad.
      _t._onbufferchange(0); // ensure buffer has ended
      if (_t._iO.onbeforefinishcomplete) {
        _t._iO.onbeforefinishcomplete.apply(_t);
      }
      // reset some state items
      _t.didBeforeFinish = false;
      _t.didJustBeforeFinish = false;
      if (_t.instanceCount) {
        _t.instanceCount--;
        if (!_t.instanceCount) {
          // reset instance options
          // _t.setPosition(0);
          _t.playState = 0;
          _t.paused = false;
          _t.instanceCount = 0;
          _t.instanceOptions = {};
          _stop_html5_timer();
        }
        if (!_t.instanceCount || _t._iO.multiShotEvents) {
          // fire onfinish for last, or every instance
          if (_t._iO.onfinish) {
            _s._wD('SMSound._onfinish(): "' + _t.sID + '"');
            _t._iO.onfinish.apply(_t);
          }
        }
        if (_t.isHTML5) {
          _t.unload();
          _t.__element = null;
        }
      }
    };

    this._onmetadata = function(oMetaData) {
      // movieStar mode only
      var fN = 'SMSound.onmetadata()';
      _s._wD(fN);
      // Contains a subset of metadata. Note that files may have their own unique metadata.
      // http://livedocs.adobe.com/flash/9.0/main/wwhelp/wwhimpl/common/html/wwhelp.htm?context=LiveDocs_Parts&file=00000267.html
      if (!oMetaData.width && !oMetaData.height) {
        _wDS('noWH');
        oMetaData.width = 320;
        oMetaData.height = 240;
      }
      _t.metadata = oMetaData; // potentially-large object from flash
      _t.width = oMetaData.width;
      _t.height = oMetaData.height;
      if (_t._iO.onmetadata) {
        _s._wD(fN + ': "' + _t.sID + '"');
        _t._iO.onmetadata.apply(_t);
      }
      _s._wD(fN + ' complete');
    };

    this._onbufferchange = function(nIsBuffering) {
      var fN = 'SMSound._onbufferchange()';
      if (_t.playState === 0) {
        // ignore if not playing
        return false;
      }
      if ((nIsBuffering && _t.isBuffering) || (!nIsBuffering && !_t.isBuffering)) {
        // _s._wD(fN + ': Note: buffering already = '+nIsBuffering);
        return false;
      }
      _t.isBuffering = (nIsBuffering === 1?true:false);
      if (_t._iO.onbufferchange) {
        _s._wD(fN + ': ' + nIsBuffering);
        _t._iO.onbufferchange.apply(_t);
      }
    };

    this._ondataerror = function(sError) {
      // flash 9 wave/eq data handler
      if (_t.playState > 0) { // hack: called at start, and end from flash at/after onfinish().
        _s._wD('SMSound._ondataerror(): ' + sError);
        if (_t._iO.ondataerror) {
          _t._iO.ondataerror.apply(_t);
        }
      }
    };

  }; // SMSound()



  // register a few event handlers
  
  if (!_s.hasHTML5 || _needsFlash) {
    // only applies to Flash mode.
    if (window.addEventListener) {
      window.addEventListener('focus', _handleFocus, false);
      window.addEventListener('load', _s.beginDelayedInit, false);
      window.addEventListener('unload', _s.destruct, false);
      if (_tryInitOnFocus) {
        window.addEventListener('mousemove', _handleFocus, false); // massive Safari focus hack
      }
    } else if (window.attachEvent) {
      window.attachEvent('onfocus', _handleFocus);
      window.attachEvent('onload', _s.beginDelayedInit);
      window.attachEvent('unload', _s.destruct);
    } else {
      // no add/attachevent support - safe to assume no JS -> Flash either.
      _debugTS('onload', false);
      soundManager.onerror();
      soundManager.disable();
    }
  }

  _dcIE = function() {
    if (document.readyState === 'complete') {
      _dcLoaded();
      document.detachEvent('onreadystatechange', _dcIE);
    }
  };

  if (document.addEventListener) {
    document.addEventListener('DOMContentLoaded', _dcLoaded, false);
  } else if (document.attachEvent) {
    document.attachEvent('onreadystatechange', _dcIE);
  }

  if (document.readyState === 'complete') {
    setTimeout(_dcLoaded,100);
  }

} // SoundManager()

// var SM2_DEFER = true;
// un-comment here or define in your own script to prevent immediate SoundManager() constructor call+start-up.

// if deferring, construct later with window.soundManager = new SoundManager(); followed by soundManager.beginDelayedInit();

if (typeof SM2_DEFER === 'undefined' || !SM2_DEFER) {
  soundManager = new SoundManager();
}

// expose public interfaces
window.SoundManager = SoundManager; // SoundManager() constructor
window.soundManager = soundManager; // instance for Flash callbacks, etc.

}(window)); // invocation closure
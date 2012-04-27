﻿/* * CustomImageLoader.as *  * Copyright (c) 2012 Hendrik Holtmann * All rights reserved. *  * Redistribution and use in source and binary forms, with or without * modification, are permitted provided that the following conditions * are met: *  * Redistributions of source code must retain the above copyright notice, * this list of conditions and the following disclaimer. *  * Redistributions in binary form must reproduce the above copyright * notice, this list of conditions and the following disclaimer in the * documentation and/or other materials provided with the distribution. *   * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. * */package  {		import com.greensock.loading.*;	import com.greensock.layout.*;	import com.greensock.events.LoaderEvent;	import flash.display.Sprite;		public class CustomImageLoader extends ImageLoader {		private var _slideObject:Object;				public function CustomImageLoader(urlOrRequest:*, vars:Object = null) {			super(urlOrRequest,vars);			this.addEventListener(LoaderEvent.COMPLETE,loadingCompleted);		}				public function slideObject():Object{			return _slideObject;		}				public function setSlideObject(object:Object):void{			_slideObject = object;					}				private function loadingCompleted(event:LoaderEvent):void {			var testSprite:Sprite = new Sprite();			trace("Children" +content.numChildren );		}	}	}
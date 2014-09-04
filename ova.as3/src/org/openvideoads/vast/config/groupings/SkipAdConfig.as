/*    
 *    Copyright (c) 2010 LongTail AdSolutions, Inc
 *
 *    This file is part of the Open Video Ads VAST framework.
 *
 *    The VAST framework is free software: you can redistribute it 
 *    and/or modify it under the terms of the GNU General Public License 
 *    as published by the Free Software Foundation, either version 3 of 
 *    the License, or (at your option) any later version.
 *
 *    The VAST framework is distributed in the hope that it will be 
 *    useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with the framework.  If not, see <http://www.gnu.org/licenses/>.
 */
package org.openvideoads.vast.config.groupings {
	import org.openvideoads.base.Debuggable;
	
	public class SkipAdConfig extends Debuggable {
		protected var _enabled:Boolean = false;
		protected var _region:Object = null;
		protected var _image:String = null;
		protected var _swf:String = null;
		protected var _html:String = null;
		protected var _width:int = -1;
		protected var _height:int = -1;
		protected var _minimumAdDuration:int = -1;
		protected var _showAfterSeconds:int = -1;
		protected var _showForSeconds:int = -1;
		protected var _skipAdOnClickThrough:Boolean = false;
		
		public function SkipAdConfig(config:Object=null) {
			if(config != null) {
				initialise(config);
			}
		}
		
		public function initialise(config:Object):void {
			if(config.enabled != undefined) {
				if(config.enabled is String) {
					this.enabled = ((config.enabled.toUpperCase() == "TRUE") ? true : false);											
				}
				else this.enabled = config.enabled;				
			}
			if(config.region != undefined) _region = config.region;
			if(config.image != undefined) _image = config.image;
			if(config.swf != undefined) _swf = config.swf;
			if(config.html != undefined) _html = config.html;
			if(config.skipAdOnClickThrough != undefined) {
				if(config.skipAdOnClickThrough is String) {
					this.skipAdOnClickThrough = ((config.skipAdOnClickThrough.toUpperCase() == "TRUE") ? true : false);											
				}
				else this.skipAdOnClickThrough = config.skipAdOnClickThrough;				
			}			
			if(config.width != undefined) {
				if(config.width is String) {
					this.width = int(config.width);
				}
				else this.width = config.width;
			}
			if(config.height != undefined) {
				if(config.height is String) {
					this.height = int(config.height);
				}
				else this.height = config.height;
			}
			if(config.minimumAdDuration != undefined) {
				if(config.minimumAdDuration is String) {
					this.minimumAdDuration = int(config.minimumAdDuration);
				}
				else this.minimumAdDuration = config.minimumAdDuration;
			}
			if(config.showAfterSeconds != undefined) {
				if(config.showAfterSeconds is String) {
					this.showAfterSeconds = int(config.showAfterSeconds);
				}
				else this.showAfterSeconds = config.showAfterSeconds;
			}
			if(config.showForSeconds != undefined) {
				if(config.showForSeconds is String) {
					this.showForSeconds = int(config.showForSeconds);
				}
				else this.showForSeconds = config.showForSeconds;
			}
		}
		
		public function set skipAdOnClickThrough(skipAdOnClickThrough:Boolean):void {
			_skipAdOnClickThrough = skipAdOnClickThrough;
		}
		
		public function get skipAdOnClickThrough():Boolean {
			return _skipAdOnClickThrough;
		}
		
		public function isTimeDelayed():Boolean {
			return (_showAfterSeconds > 0);
		}
		
		public function set showAfterSeconds(showAfterSeconds:int):void {
			_showAfterSeconds = showAfterSeconds;
		}

		public function get showAfterSeconds():int {
			return _showAfterSeconds;
		}

		public function isTimeRestricted():Boolean {
			return (_showForSeconds > 0);
		}

		public function set showForSeconds(showForSeconds:int):void {
			_showForSeconds = showForSeconds;
		}

		public function get showForSeconds():int {
			return _showForSeconds;
		}
		
		public function isStandardImageButton():Boolean {
			return (isCustomImageButton() == false) && (isFlashButton() == false);
		}

		public function isCustomImageButton():Boolean {	
			return (_image != null);
		}
		
		public function isFlashButton():Boolean {
			return (_swf != null);
		}
		
		public function isHtmlButton():Boolean {
			return (_html != null);
		}
		
		public function set enabled(enabled:Boolean):void {
			_enabled = enabled;
		}
		
		public function get enabled():Boolean {
			return _enabled;
		}
		
		public function set region(region:Object):void {
			_region = region;
		}
		
		public function get region():Object {
			return _region;
		}
		
		public function hasCustomRegionDefined():Boolean {
			return (_region != null);
		}
		
		public function set image(image:String):void {
			_image = image;
		}
		
		public function get image():String {
			return _image;
		}

		public function set swf(swf:String):void {
			_swf = swf;
		}
		
		public function get swf():String {
			return _swf;
		}
		
		public function set html(html:String):void {
			_html = html;
		}
		
		public function get html():String {
			return _html;
		}

		public function set width(width:int):void {
			_width = width;
		}
		
		public function get width():int {
			return _width;
		}
		
		public function set height(height:int):void {
			_height = height;
		}
		
		public function get height():int {
			return _height;
		}

		public function set minimumAdDuration(minimumAdDuration:int):void {
			_minimumAdDuration = minimumAdDuration;
		}
		
		public function get minimumAdDuration():int {
			return _minimumAdDuration;
		}		
		
		public function hasMinimumAdDuration():Boolean {
			return (_minimumAdDuration > 0);
		}
	}
}
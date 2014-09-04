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
package org.openvideoads.regions.config {
	import org.openvideoads.base.Debuggable;

	public class CloseButtonConfig extends Debuggable {
		protected var _type:String = "crosshair";
		protected var _color:String = "#FFFFFF"; 
		protected var _enabled:Boolean = true;
		protected var _imageURL:String = null;
		protected var _width:int = 15;
		protected var _height:int = 15;
				
		public function CloseButtonConfig(rawConfig:Object=null) {
			if(rawConfig != null) {
				initialise(rawConfig);
			}
		}
		
		protected function initialise(rawConfig:Object):void {
			if(rawConfig.type != undefined) _type = rawConfig.type;
			if(rawConfig.color != undefined) {
				_color = rawConfig.color;
			}
			if(rawConfig.enabled != undefined) _enabled = rawConfig.enabled;
			if(rawConfig.image != undefined) _imageURL = rawConfig.image;
			if(rawConfig.width != undefined) _width = rawConfig.width;
			if(rawConfig.height != undefined) _height = rawConfig.height;
		}
		
		public function set type(type:String):void {
			_type = type;
		}
		
		public function get type():String {
			if(_type != null) {
				return _type.toUpperCase();
			}
			return _type;
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
		
		public function set color(color:String):void {
			_color = color;
		}
		
		public function get color():String {
			return _color;
		}
		
		public function set enabled(enabled:Boolean):void {
			_enabled = enabled;
		}
		
		public function get enabled():Boolean {
			return _enabled;
		}
		
		public function set imageURL(imageURL:String):void {
			_imageURL = imageURL;
		}
		
		public function get imageURL():String {
			return _imageURL;
		}
	}
}
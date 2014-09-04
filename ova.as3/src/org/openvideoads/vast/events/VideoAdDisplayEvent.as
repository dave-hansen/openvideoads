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
package org.openvideoads.vast.events {
 	import org.openvideoads.vast.VASTController;
	import org.openvideoads.vast.model.NonLinearVideoAd;
	
	/**
	 * @author Paul Schulz
	 */
	public class VideoAdDisplayEvent {
		private var _nonLinearAd:NonLinearVideoAd = null;
		private var _customData:Object = new Object();
		private var _controller:VASTController = null;
		private var _width:int = -1;
		private var _height:int = -1;
		
		public function VideoAdDisplayEvent(controller:VASTController=null, width:int=-1, height:int=-1, customData:Object=null) {
			_controller = controller;
			_width = width;
			_height = height;
			if(customData != null) _customData = customData;
		}

		public function set controller(controller:VASTController):void {
			_controller = controller;
		}
		
		public function get controller():VASTController {
			return _controller;
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
		
		public function hasAd():Boolean {
			return (_nonLinearAd != null);
		}
		
		public function set ad(nonLinearAd:NonLinearVideoAd):void {
			_nonLinearAd = nonLinearAd;
		}
		
		public function get ad():NonLinearVideoAd {
			return _nonLinearAd;
		}

		public function set customData(customData:Object):void {
			_customData = customData;	
		}
		
		public function get customData():Object {
			return _customData;
		}		
	}
}
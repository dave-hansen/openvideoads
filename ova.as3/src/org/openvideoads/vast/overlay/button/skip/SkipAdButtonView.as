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
package org.openvideoads.vast.overlay.button.skip {
	import flash.events.MouseEvent;
	
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.regions.RegionController;
	import org.openvideoads.regions.config.RegionViewConfig;
	import org.openvideoads.util.DisplayProperties;
	import org.openvideoads.vast.overlay.OverlayView;
	
	public class SkipAdButtonView extends OverlayView {
		protected var _callbackMethod:Function = null;
		protected var _active:Boolean = false;
		
		public function SkipAdButtonView(controller:RegionController, regionConfig:RegionViewConfig, displayProperties:DisplayProperties, width:int=-1, height:int=-1) {
			super(controller, regionConfig, displayProperties); //, false);
			if(regionConfig.hasImage()) {
				if(regionConfig.imageIsBitmap() || regionConfig.imageIsLoader()) {
					this.alpha = 0.8;
					this.addChild(regionConfig.image);					
				}
			}
			else if(regionConfig.hasSWF()) {
				CONFIG::debugging { doLog("SWF Skip Ad button not supported.", Debuggable.DEBUG_DISPLAY_EVENTS); }
			}
		}

		public function registerOnClick(callbackMethod:Function):void {
			_callbackMethod = callbackMethod;	
		}
		
		protected override function onMouseOver(event:MouseEvent):void {
			CONFIG::debugging { doLog("SkipAdButtonView: MOUSE OVER!", Debuggable.DEBUG_MOUSE_EVENTS); }
			this.alpha = 1;
		}

		protected override function onMouseOut(event:MouseEvent):void {
			CONFIG::debugging { doLog("SkipAdButtonView: MOUSE OUT!", Debuggable.DEBUG_MOUSE_EVENTS); }
			this.alpha = 0.8;
		}

		protected override function onClick(event:MouseEvent):void {
			CONFIG::debugging { doLog("SkipAdButtonView: ON CLICK", Debuggable.DEBUG_MOUSE_EVENTS); }
			if(_callbackMethod != null) _callbackMethod();
		}
		
		public function get active():Boolean {
			return _active;
		}
		
		public function activate():void {
			_active = true;
			show();
		}
		
		public function deactivate():void {
			_active = false;
			hide();
		}
	}
}
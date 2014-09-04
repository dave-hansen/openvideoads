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
package org.openvideoads.util {
	import flash.display.DisplayObjectContainer;
	
	import org.openvideoads.base.Debuggable;	

	/**
	 * @author Paul Schul
	 */
	public class DisplayProperties extends Debuggable { 
		protected var _displayObjectContainer:DisplayObjectContainer;
		protected var _displayWidth:Number = 0;
		protected var _displayHeight:Number = 0;
		protected var _displayMode:String = "normal";
		protected var _displaySpecification:DisplaySpecification = null;
		protected var _controlsVisibleAtBottom:Boolean = true;
		protected var _controlsHeight:Number = 0;	
		protected var _controlsYPos:Number = 0;

		public static const DISPLAY_NORMAL:String = "normal";
		public static const DISPLAY_FULLSCREEN:String = "fullscreen";
		public static const DISPLAY_THUMBNAIL:String = "thumbnail";
				
		public function DisplayProperties(displayObjectContainer:DisplayObjectContainer, displayWidth:int, displayHeight:int, displayMode:String, displaySpecification:DisplaySpecification, controlsVisibleAtBottom:Boolean, controlsHeight:Number, controlsYPos:Number) {
			_displayObjectContainer = displayObjectContainer;
			_displayWidth = displayWidth;
			_displayHeight = displayHeight;
			_displayMode = displayMode;
			_displaySpecification = displaySpecification;
			_controlsVisibleAtBottom = controlsVisibleAtBottom;
			_controlsHeight = controlsHeight;
			_controlsYPos = controlsYPos;
			CONFIG::debugging { doLog("DisplayProperties set to " + toString(), Debuggable.DEBUG_REGION_FORMATION); }
		}
		
		public function set displayWidth(displayWidth:Number):void {
			_displayWidth = displayWidth;
		}
		
		public function get displayWidth():Number {
			return _displayWidth;
		}
		
		public function set displayHeight(displayHeight:Number):void {
			_displayHeight = displayHeight;
		}
		
		public function get displayHeight():Number {
			return _displayHeight;
		}

		public function get baselineWidth():Number {
			return _displaySpecification.width;			
		}

		public function get baselineHeight():Number {
			return _displaySpecification.height;			
		}

		public function set displayMode(displayMode:String):void {
			_displayMode = displayMode;
		}
		
		public function get displayMode():String {
			return _displayMode;
		}
		
		public function displayModeIsNormal():Boolean {
			if(_displayMode != null) {
				return StringUtils.matchesIgnoreCase(_displayMode, DisplayProperties.DISPLAY_NORMAL);
			}
			return false;
		}
		
		public function displayModeIsFullscreen():Boolean {
			if(_displayMode != null) {
				return (displayModeIsNormal() == false);
			}
			return false;
		}
		
		public function get scaleX():Number {
			return displayWidth / baselineWidth;
		}
		
		public function get scaleY():Number {
			return displayHeight / baselineHeight;			
		}

		public function get controlsVisibleAtBottom():Boolean {
			return _controlsVisibleAtBottom;
		}
		
		public function get controlsHeight():Number {
			return _controlsHeight;
		}
		
		public function get controlsYPos():Number {
			return _controlsYPos;
		}
		
		public function getActiveMargin(useOverrideMargin:Boolean=false):Number {
			if(controlsVisibleAtBottom) {
				return _displaySpecification.marginsSpecification.getWithControlsMargin(displayMode, useOverrideMargin);
			}
			else {
				return _displaySpecification.marginsSpecification.getWithoutControlsMargin(displayMode, useOverrideMargin);
			}
		}
		
		public function getMarginAdjustedHeight(useOverrideMargin:Boolean=false):Number {
			return displayHeight - getActiveMargin(useOverrideMargin);
		}

		public function set displayObjectContainer(displayObjectContainer:DisplayObjectContainer):void {
			_displayObjectContainer = displayObjectContainer;
		}
		
		public function get displayObjectContainer():DisplayObjectContainer {
			return _displayObjectContainer;
		}
				
		public function clone():DisplayProperties {
			return new DisplayProperties(
					_displayObjectContainer, 
					_displayWidth, 
					_displayHeight, 
					_displayMode,
					_displaySpecification,
					_controlsVisibleAtBottom,
					_controlsHeight,
					_controlsYPos
				);
		}
		
		public function toString():String {
			return "(displayWidth: " + _displayWidth + 
			       ", displayHeight: " + _displayHeight +
			       ", displayMode: " + _displayMode +
			       ")"; 
		}
	}
}

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
	import org.openvideoads.util.DisplayProperties;
	import org.openvideoads.util.StringUtils;
	
	/**
	 * @author Paul Schulz
	 */
	public class RegionViewConfig extends BaseRegionConfig {
		protected var _verticalAlignPosition:String = "TOP";
		protected var _verticalAlignOffset:Number = 0;
		protected var _horizontalAlign:String = "left";
		protected var _width:*;
		protected var _height:*;
		protected var _expandedWidth:Number = -1;
		protected var _expandedHeight:Number = -1;
		protected var _minimizedHeight:* = null;
		protected var _autoShow:Boolean = false;
		protected var _clickable:Boolean = true;
		protected var _clickToPlay:Boolean = false;
		protected var _template:String = null;
		protected var _contentTypes:String = null;
		protected var _keepVisibleAfterClick:Boolean = false;
		protected var _canScale:Boolean = false;
		protected var _additionalHeight:* = 0;
		protected var _resetAdditionalHeightOnResize:String = null;
		protected var _autoSizing:Boolean = false;
		protected var _useOverrideMargin:Boolean = false;
		protected var _autoHide:Boolean = true;
		
		protected static var TEMPLATES:Array = [
		      { id:'standard-text', html: '' }
		];
		
		public function RegionViewConfig(config:Object=null) {
			super(config);
		}
		
		public override function setup(config:Object):void {
			if(config != null) {
				super.setup(config);
				if(config.verticalAlign != undefined) {
					if(config.verticalAlign != null) {
						if(String(config.verticalAlign).indexOf(":") > -1) {
							var parts:Array = String(config.verticalAlign).split(":");
							if(parts.length == 2) {
								_verticalAlignPosition = parts[0].toUpperCase();
								_verticalAlignOffset = parseInt(parts[1]);
							}
							else _verticalAlignPosition = "BOTTOM";
						}					
						else _verticalAlignPosition = String(config.verticalAlign).toUpperCase();
					}
				}
				if(config.horizontalAlign != undefined) _horizontalAlign = config.horizontalAlign;
				if(config.width != undefined) _width = config.width;
				if(config.height != undefined) _height = config.height;
				if(config.expandedWidth != undefined) _expandedWidth = config.expandedWidth;
				if(config.expandedHeight != undefined) _expandedHeight = config.expandedHeight;
				if(config.autoShow != undefined) _autoShow = config.autoShow;
				if(config.clickable != undefined) _clickable = config.clickable;
				if(config.clickToPlay != undefined) _clickToPlay = config.clickToPlay;
				if(config.keepAfterClick != undefined) _keepVisibleAfterClick = config.keepAfterClick;
				if(config.canScale != undefined) _canScale = config.canScale;
				if(config.additionalHeight != undefined) _additionalHeight = config.additionalHeight;
				if(config.autoSizing != undefined) _autoSizing = config.autoSizing;
				if(config.useOverrideMargin != undefined) _useOverrideMargin = config.useOverrideMargin;
				if(config.minimizedHeight != undefined) _minimizedHeight = config.minimizedHeight;
				if(config.autoHide != undefined) _autoHide = config.autoHide;
			}
		}

		public function isAutoSizing():Boolean {
			return _autoSizing;
		}
		
		public function set autoSizing(autoSizing:Boolean):void {
			_autoSizing = autoSizing;
		}
		
		public function get autoSizing():Boolean {
			return _autoSizing;
		}

		public function set autoHide(autoHide:*):void {
			_autoHide = autoHide;
		}
		
		public function get autoHide():* {
			return _autoHide;
		}

		public function set width(width:*):void {
			_width = width;
		}
		
		public function get width():* {
			return _width;
		}
		
		public function set height(height:*):void {
			_height = height;
		}
		
		public function get height():* {
			return _height;
		}

		public function hasMinimizedHeight():Boolean {
			return (_minimizedHeight != null);
		}
		
		public function hasMinimizedHeightBasedOnYPosForDisplayMode(displayMode:String):Boolean {
			if(hasMinimizedHeight()) {
				if(_minimizedHeight is String) {
					if(StringUtils.matchesIgnoreCase(_minimizedHeight, "CONTROLS-YPOS-WHEN-VISIBLE-ALL-MODES")) {
						return true;	
					}
					else if(StringUtils.matchesIgnoreCase(displayMode, "FULLSCREEN")) {
						return StringUtils.matchesIgnoreCase(_minimizedHeight, "CONTROLS-YPOS-WHEN-VISIBLE-FULLSCREEN"); 
					}
					else return StringUtils.matchesIgnoreCase(_minimizedHeight, "CONTROLS-YPOS-WHEN-VISIBLE-NORMAL"); 
				}
			}
			return false;
		}
		
		public function set minimizedHeight(minimizedHeight:*):void {
			_minimizedHeight = minimizedHeight;
		}
		
		public function get minimizedHeight():* {
			return _minimizedHeight;
		}
		
		public function calculateMinimizedHeight(displayProperties:DisplayProperties):Number {
			if(StringUtils.matchesIgnoreCase(_minimizedHeight, "CONTROLS-YPOS-WHEN-VISIBLE-ALL-MODES") ||
			   (displayProperties.displayModeIsNormal() && StringUtils.matchesIgnoreCase(_minimizedHeight, "CONTROLS-YPOS-WHEN-VISIBLE-NORMAL")) ||
			   (displayProperties.displayModeIsFullscreen() && StringUtils.matchesIgnoreCase(_minimizedHeight, "CONTROLS-YPOS-WHEN-VISIBLE-FULLSCREEN"))) {
			   	if(displayProperties.controlsVisibleAtBottom) {
				 	return displayProperties.controlsYPos;  
			   	}
			}
			return displayProperties.displayHeight;
		}
		
		public function set expandedHeight(expandedHeight:Number):void {
			_expandedHeight = expandedHeight;	
		}
		
		public function get expandedHeight():Number {
			return _expandedHeight;
		}

		public function set expandedWidth(expandedWidth:Number):void {
			_expandedWidth = expandedWidth;	
		}
		
		public function get expandedWidth():Number {
			return _expandedWidth;
		}
		
		public function hasExpandedSizing():Boolean {
			return (_expandedWidth > -1 && _expandedHeight > -1);
		}
		
		public function set useOverrideMargin(useOverrideMargin:Boolean):void {
			_useOverrideMargin = useOverrideMargin;
		}
		
		public function get useOverrideMargin():Boolean {
			return _useOverrideMargin;
		}
		
		public function additionalHeightIsRestricted():Boolean {
			if(_additionalHeight != null) {
				if(_additionalHeight is String) {
					return StringUtils.matchesIgnoreCase(_additionalHeight, "CONTROLS-HEIGHT-WHEN-NORMAL");
				}
			}
			return false;
		}
		
		public function set additionalHeight(additionalHeight:*):void {
			_additionalHeight = additionalHeight;
		}
		
		public function get additionalHeight():* {
			return _additionalHeight;
		}
		
		public function hasAdditionalHeight():Boolean {
			return (_additionalHeight != 0 && _additionalHeight != null);	
		}
		
		public function additionalHeightRestrictionsMet(displayProperties:DisplayProperties):Boolean {
			if(_additionalHeight != null) {
				if(_additionalHeight is String) {
					return (StringUtils.matchesIgnoreCase(_additionalHeight, "CONTROLS-HEIGHT-WHEN-NORMAL") && displayProperties.displayModeIsNormal());
				}
			}				
			return false;
		}
		
		public function calculateAdditionalHeight(displayProperties:DisplayProperties):Number {
			if(_additionalHeight != null) {
				if(_additionalHeight is String) {
					if(StringUtils.matchesIgnoreCase(_additionalHeight, "CONTROLS-HEIGHT-WHEN-NORMAL") && displayProperties != null) {
						return displayProperties.controlsHeight;
					}
				}
				else return _additionalHeight;
			}
			return 0;
		}
		
		public function set canScale(canScale:Boolean):void {
			_canScale = canScale;
		}
		
		public function get canScale():Boolean {
			return _canScale;
		}
		
		public function set autoShow(autoShow:Boolean):void {
			_autoShow = autoShow;
		}
		
		public function get autoShow():Boolean {
			return _autoShow;
		}

		public function set keepVisibleAfterClick(keepVisibleAfterClick:Boolean):void {
			_keepVisibleAfterClick = keepVisibleAfterClick;
		}
		
		public function get keepVisibleAfterClick():Boolean {
			return _keepVisibleAfterClick;
		}
		
		public function set verticalAlignPosition(verticalAlignPosition:String):void {
			_verticalAlignPosition = verticalAlignPosition;
		}
		
		public function get verticalAlignPosition():String {
			return _verticalAlignPosition;
		}
		
		public function set verticalAlignOffset(offset:Number):void {
			_verticalAlignOffset = offset;
		}
		
		public function get verticalAlignOffset():Number {
			return _verticalAlignOffset;
		}
		
		public function set horizontalAlign(horizontalAlign:String):void {
			_horizontalAlign = horizontalAlign;
		}
		
		public function get horizontalAlign():String {
			return _horizontalAlign;
		}
		
		public function set clickable(clickable:Boolean):void {
			_clickable = clickable;
		}
		
		public function get clickable():Boolean {
			return _clickable;
		}
		
		public function set clickToPlay(clickToPlay:Boolean):void {
			_clickToPlay = clickToPlay;
		}
		
		public function get clickToPlay():Boolean {
			return _clickToPlay;
		}
		
		public function set template(template:String):void {
			_template = template;
		}
		
		public function get template():String {
			return _template;
		}

		public function hasTemplate():Boolean {
			return (_template != null);
		}
		
		public function set contentTypes(contentTypes:String):void {
			_contentTypes = contentTypes;
		}
		
		public function get contentTypes():String {
			return _contentTypes;
		}
		
		public function hasContentTypes():Boolean {
			return (_contentTypes != null);
		}
	}
}
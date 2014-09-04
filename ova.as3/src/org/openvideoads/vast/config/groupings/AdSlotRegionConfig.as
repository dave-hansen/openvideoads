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
	import org.openvideoads.util.ArrayUtils;
	import org.openvideoads.util.StringUtils;
	import org.openvideoads.vast.schedule.ads.templates.*;

	/**
	 * @author Paul Schulz
	 */
	public class AdSlotRegionConfig extends Debuggable {
		protected var _enable:Boolean = false;
		protected var _prefer:Boolean = false;
		protected var _width:int = -1;
		protected var _height:int = -1;
		protected var _acceptedAdTypes:Array = null;
		protected var _region:Object = null;
		protected var _templates:Object = new Object();
		protected var _keepVisibleAfterClick:Boolean = false;
		protected var _enableScaling:Boolean = false;
		protected var _enforceRecommendedSizing:Boolean = true;
		protected var _displayMode:String = "flash";
		protected var _overlay:Boolean = true;
		protected var _alwaysMatch:* = null;
		protected var _buttonConfig:CloseButtonConfig = null;
		
		public function AdSlotRegionConfig(displayMode:String="flash", config:Object=null, customConfig:Object=null) {
			_displayMode = displayMode;
			if(config != null) initialise(config, customConfig);
		}
		
		public function initialise(config:Object, customConfig:Object=null):void {
			if(config != null) {
				if(config.hasOwnProperty("enable")) {
					this.enable = config.enable;
				}
				if(config.hasOwnProperty("prefer")) {
					this.prefer = config.prefer;
				}
				if(config.hasOwnProperty("width")) {
					this.width = config.width;
				}
				if(config.hasOwnProperty("height")) {
					this.height = config.height;
				}
				if(config.hasOwnProperty("acceptedAdTypes")) {
					this.acceptedAdTypes = config.acceptedAdTypes;
				}
				if(config.hasOwnProperty("keepVisibleAfterClick")) {
					this.keepVisibleAfterClick = config.keepVisibleAfterClick;
				}
				if(config.hasOwnProperty("enableScaling")) {
					this.enableScaling = config.enableScaling;
				}
				if(config.hasOwnProperty("enforceRecommendedSizing")) {
					this.enforceRecommendedSizing = config.enforceRecommendedSizing;
				}
				if(config.hasOwnProperty("region")) {
					this.region = config.region;	
				}
				if(config.hasOwnProperty("templates")) {
					this.templates = config.templates;
				}
				if(config.hasOwnProperty("overlay")) {
					this.overlay = config.overlay;
				}
				if(config.hasOwnProperty("alwaysMatch")) {
					this.alwaysMatch = config.alwaysMatch;
				}
				if(config.hasOwnProperty("closeButton")) {
					_buttonConfig = new CloseButtonConfig(config.closeButton);
				}
				else _buttonConfig = null;
				if(customConfig != null) {
					if(customConfig.hasOwnProperty("enable")) {
						this.enable = customConfig.enable;
					}
					if(customConfig.hasOwnProperty("prefer")) {
						this.prefer = customConfig.prefer;
					}
					if(customConfig.hasOwnProperty("width")) {
						this.width = customConfig.width;
					}
					if(customConfig.hasOwnProperty("height")) {
						this.height = customConfig.height;
					}
					if(customConfig.hasOwnProperty("acceptedAdTypes")) {
						this.acceptedAdTypes = customConfig.acceptedAdTypes;
					}
					if(customConfig.hasOwnProperty("keepVisibleAfterClick")) {
						this.keepVisibleAfterClick = customConfig.keepVisibleAfterClick;
					}
					if(customConfig.hasOwnProperty("enableScaling")) {
						this.enableScaling = customConfig.enableScaling;
					}
					if(customConfig.hasOwnProperty("enforceRecommendedSizing")) {
						this.enforceRecommendedSizing = customConfig.enforceRecommendedSizing;
					}
					if(customConfig.hasOwnProperty("region")) {
						this.region = customConfig.region;	
					}
					if(customConfig.hasOwnProperty("templates")) {
						this.templates = customConfig.templates;
					}
					if(customConfig.hasOwnProperty("overlay")) {
						this.overlay = customConfig.overlay;
					}
					if(customConfig.hasOwnProperty("alwaysMatch")) {
						this.alwaysMatch = customConfig.alwaysMatch;
					}
					if(customConfig.hasOwnProperty("closeButton")) {
						_buttonConfig = new CloseButtonConfig(customConfig.closeButton);
					}
				}
			}
		}

		public function get displayMode():String {
			return _displayMode;
		}
		
		public function set enable(enable:*):void {
			_enable = StringUtils.validateAsBoolean(enable);
		}
		
		public function get enable():Boolean {
			return _enable;
		}
		
		public function requiresCloseButton():Boolean {
			if(_buttonConfig != null) {
				return _buttonConfig.enabled;
			}
			return false;
		}
		
		public function get buttonConfig():CloseButtonConfig {
			return _buttonConfig;
		}

		public function set overlay(overlay:*):void {
			_overlay = StringUtils.validateAsBoolean(overlay);
		}
		
		public function get overlay():Boolean {
			return _overlay;
		}
		
		public function set prefer(prefer:*):void {
			_prefer = StringUtils.validateAsBoolean(prefer);
		}
		
		public function get prefer():Boolean {
			return _prefer;
		}
		
		public function hasSize():Boolean {
			return hasWidthSpecified() && hasHeightSpecified();
		}
		
		public function hasWidthSpecified():Boolean {
			return (width > -1);
		}
				
		public function set width(widthSetting:*):void {
			if(widthSetting is String) {
				_width = parseInt(widthSetting);
			}	
			else _width = widthSetting;	
		}

		public function get width():int {
			return _width;
		}

		public function hasHeightSpecified():Boolean {
			return (height > -1);
		}
				
		public function set height(heightSetting:*):void {
			if(heightSetting is String) {
				_height = parseInt(heightSetting);
			}	
			else _height = heightSetting;	
		}
		
		public function get height():int {
			return _height;
		}
		
		public function set enableScaling(enableScaling:*):void {
			_enableScaling = StringUtils.validateAsBoolean(enableScaling);
		}
		
		public function get enableScaling():Boolean {
			return _enableScaling;
		}

		public function hasAlwaysMatchSetting():Boolean {
			return (_alwaysMatch != null);
		}
		
		public function set alwaysMatch(alwaysMatch:*):void {
			_alwaysMatch = StringUtils.validateAsBoolean(alwaysMatch);
		}
		
		public function get alwaysMatch():Boolean {
			if(_alwaysMatch == null) {
				if(width < 0 && height < 0) {
					return true;
				}
				return false;
			}
			return _alwaysMatch;
		}

		public function set enforceRecommendedSizing(enforceRecommendedSizing:Boolean):void {
			_enforceRecommendedSizing = enforceRecommendedSizing;
		}
		
		public function get enforceRecommendedSizing():Boolean {
			return _enforceRecommendedSizing;
		}

		public function set keepVisibleAfterClick(keepVisibleAfterClick:Boolean):void {
			_keepVisibleAfterClick = keepVisibleAfterClick;
		}
		
		public function get keepVisibleAfterClick():Boolean {
			return _keepVisibleAfterClick;
		}
		
		public function set acceptedAdTypes(acceptedAdTypes:*):void {
			if(acceptedAdTypes is Array) {
				_acceptedAdTypes = ArrayUtils.toUpperCase(acceptedAdTypes);						
			}
		}
		
		public function get acceptedAdTypes():Array {
			return _acceptedAdTypes;
		}
		
		public function set region(region:Object):void {
			_region = region;
		}
		
		public function get region():Object {
			return _region;
		}
		
		public function getRegionIDBasedOnAdType(adType:String):String {
			if(_region != null && adType != null) {
				var verifiedAdType:String = adType.toLowerCase();
				if(_region.hasOwnProperty(verifiedAdType)) {
					return _region[verifiedAdType];
				}
			}
			return "auto:bottom";
		}
		
		public function set templates(templates:Object):void {
			_templates = templates;
		}
		
		public function get templates():Object {
			return _templates;
		}
		
		public function getTemplateBasedOnAdType(adType:String):AdTemplate {
			if(_templates != null && adType != null) {
				var verifiedAdType:String = adType.toLowerCase();
				if(_templates.hasOwnProperty(verifiedAdType)) {
					return _templates[verifiedAdType];
				}
			}
			return new HtmlAdTemplate();
		}
	}
}
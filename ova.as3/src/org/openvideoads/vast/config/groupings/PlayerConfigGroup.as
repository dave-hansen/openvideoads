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
import org.openvideoads.util.ControlsSpecification;
import org.openvideoads.util.DisplaySpecification;
import org.openvideoads.util.MarginsSpecification;
import org.openvideoads.vast.config.ConfigLoadListener;
	
	/**
	 * @author Paul Schulz
	 */
	public class PlayerConfigGroup extends ConfigLoader {
		protected var _defaultWidth:int = -1;
		protected var _defaultHeight:int = -1;
		protected var _defaultControls:ControlsSpecification = new ControlsSpecification();
		protected var _useInstream:Boolean = false;
		protected var _setUrlResolversOnAdClips:Boolean = true;
		protected var _processErrors:Boolean = true;
		protected var _showBusyIcon:Boolean = true;
		protected var _applyCommonClipProperties:Boolean = false;
		protected var _modes:Object = {
			linear: new DisplaySpecification(DisplaySpecification.LINEAR),
			nonLinear: new DisplaySpecification(DisplaySpecification.NON_LINEAR)
		};
		
		public function PlayerConfigGroup(config:Object=null, onLoadedListener:ConfigLoadListener=null) {
			super(config, onLoadedListener);
		}
	
		public override function initialise(config:Object=null, onLoadedListener:ConfigLoadListener=null, forceEnable:Boolean=false):void {
			markAsLoading();
        	super.initialise(config, onLoadedListener);
			if(config != null) {
			    if(config.hasOwnProperty("modes")) {
			    	if(config.modes.hasOwnProperty("linear")) {
			    		_modes.linear.initialise(config.modes.linear);
			    	}
			    	if(config.modes.hasOwnProperty("nonLinear")) {
			    		_modes.nonLinear.initialise(config.modes.nonLinear);
			    	}
				}
			    if(config.hasOwnProperty("width")) {
			    	width = config.width;
				}
			    if(config.hasOwnProperty("height")) {
			    	height = config.height;
				}	
				if(config.hasOwnProperty("controls")) {
					controls = config.controls;
				}			
				if(config.hasOwnProperty("margins")) {
					margins = config.margins;
				}		
				if(config.hasOwnProperty("setUrlResolversOnAdClips")) {
					if(config.setUrlResolversOnAdClips is String) {
						setUrlResolversOnAdClips = ((config.setUrlResolversOnAdClips.toUpperCase() == "TRUE") ? true : false);											
					}
					else setUrlResolversOnAdClips = config.setUrlResolversOnAdClips;									
				}	
				if(config.hasOwnProperty("showBusyIcon")) {
					if(config.showBusyIcon is String) {
						showBusyIcon = ((config.showBusyIcon.toUpperCase() == "TRUE") ? true : false);											
					}
					else showBusyIcon = config.showBusyIcon;									
				}	
				if(config.hasOwnProperty("applyCommonClipProperties")) {
					if(config.applyCommonClipProperties is String) {
						applyCommonClipProperties = ((config.applyCommonClipProperties.toUpperCase() == "TRUE") ? true : false);											
					}
					else applyCommonClipProperties = config.applyCommonClipProperties;									
				}	
				if(config.hasOwnProperty("processErrors")) {
					if(config.processErrors is String) {
						processErrors = ((config.processErrors.toUpperCase() == "TRUE") ? true : false);											
					}
					else processErrors = config.processErrors;									
				}	
			}
			markAsLoaded();
		}

		public function hasPlayerHeight():Boolean {
			return (height > -1);
		}
		
		public function hasPlayerWidth():Boolean {
			return (width > -1);
		}
		
		public function set height(heightSetting:*):void {
	    	var newHeight:int = 0;
			if(heightSetting is String) {
				newHeight = parseInt(heightSetting);
			}	
			else newHeight = heightSetting;	
			_defaultHeight = newHeight;
			_modes.linear.height = newHeight;
			_modes.nonLinear.height = newHeight;
		}
		
		public function get height():int {
			return _defaultHeight;
		}
		
		public function set width(widthSetting:*):void {
            var newWidth:int = 0;				
			if(widthSetting is String) {
				newWidth = parseInt(widthSetting);
			}	
			else newWidth = widthSetting;
			_defaultWidth = newWidth;
			_modes.linear.width = newWidth;
			_modes.nonLinear.width = newWidth;
		}

		public function get width():int {
			return _defaultWidth;
		}
		
		public function set useInstream(useInstream:Boolean):void {
			_useInstream = useInstream;
		}
		
		public function get useInstream():Boolean {
			return _useInstream;
		}

		public function set processErrors(processErrors:Boolean):void {
			_processErrors = processErrors;
		}
		
		public function get processErrors():Boolean {
			return _processErrors;
		}
		
		public function set controls(controlsConfig:*):void {
			if(controlsConfig is ControlsSpecification) {
				_defaultControls = controlsConfig;
				_modes.linear.controlsConfig = controlsConfig;
				_modes.nonLinear.controlsConfig = controlsConfig;
			}
			else {
				_defaultControls.initialise(controlsConfig);
				_modes.linear.initialise({ controls: controlsConfig });	
				_modes.nonLinear.initialise({ controls: controlsConfig });	
			}
		}
		
		public function get linearControls():Object {
			return _modes.linear.controls; 
		}
		
		public function get nonLinearControls():Object {
			return _modes.nonLinear.controls;
		}
		
		public function get defaultControls():ControlsSpecification {
			return _defaultControls;
		}

		public function controlEnabledForLinearAdType(controlName:String, isVPAID:Boolean):Boolean {
			return _modes.linear.controlEnabledForLinearAdType(controlName, isVPAID);
		}
		
		public function hasControlBarHeightSpecified():Boolean {
			if(_defaultControls != null) {
				return _defaultControls.hasHeightSpecified();
			}
			return false;
		}

		public function getControlBarHeight():Number {
			if(_defaultControls != null) {
				return _defaultControls.height;			
			}
			return -1;
		}
		
		public function set setUrlResolversOnAdClips(setUrlResolversOnAdClips:Boolean):void {
			_setUrlResolversOnAdClips = setUrlResolversOnAdClips;
		}
		
		public function get setUrlResolversOnAdClips():Boolean {
			return _setUrlResolversOnAdClips;
		}

		public function set applyCommonClipProperties(applyCommonClipProperties:Boolean):void {
			_applyCommonClipProperties = applyCommonClipProperties;
		}
		
		public function get applyCommonClipProperties():Boolean {
			return _applyCommonClipProperties;
		}

		public function set showBusyIcon(showBusyIcon:Boolean):void {
			_showBusyIcon = showBusyIcon;
		}
		
		public function get showBusyIcon():Boolean {
			return _showBusyIcon;
		}
		
		public function set margins(marginsConfig:*):void {
			if(marginsConfig is MarginsSpecification) {	
				_modes.linear.marginsSpecification = marginsConfig;
				_modes.nonLinear.marginsSpecification = marginsConfig;
			}
			else {
				_modes.linear.initialise({ margins: marginsConfig });	
				_modes.nonLinear.initialise({ margins: marginsConfig });	
			}
		}
		
		public function set modes(modes:Object):void {
			_modes = modes;
		}
		
		public function get modes():Object {
			return _modes;
		}
		
		public function getDisplaySpecification(specificationType:String):DisplaySpecification {
			return _modes[specificationType];
		}

		public function shouldManageControlsDuringLinearAds(isVPAID:Boolean=false):Boolean {
			return _modes.linear.shouldManageControlsDuringLinearAds(isVPAID);        		
		}        

        public function shouldDisableControlsDuringLinearAds(isVPAID:Boolean=false):Boolean {
        	return _modes.linear.shouldDisableControlsDuringLinearAds(isVPAID);	
        }
        
        public function shouldHideControlsOnLinearPlayback(isVPAID:Boolean=false):Boolean {
       		return _modes.linear.hideControlsOnLinearPlayback(isVPAID);
        }

		public function set hideLogoOnLinearPlayback(hideLogo:Boolean):void {
			_modes.linear.hideLogo = hideLogo;
		}
		
		public function get hideLogoOnLinearPlayback():Boolean {
			return _modes.linear.hideLogo;
		}
		
		public function toString():String {
			var result:String = 
			      "{ defaultWidth: " + _defaultWidth + 
			      ", defaultHeight: " + _defaultWidth + 
			      " ";
			var separator:String = "";
			for each(var mode:DisplaySpecification in _modes) {
				result += separator;
				result += mode.toString();
				separator = ", ";
			}       
			return result + " } ";    
		}
	}
}

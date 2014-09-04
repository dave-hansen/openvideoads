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
package org.openvideoads.vast.config.groupings.analytics.google {
	import flash.display.DisplayObject;
	
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.util.StringUtils;
	import org.openvideoads.vast.analytics.AnalyticsProcessor;
	
	public class GoogleAnalyticsTrackingGroup extends Debuggable {
		protected var _accountId:String = null;
		protected var _enableTracking:Boolean = true;
		protected var _trackAdTags:Boolean = false;
		protected var _addParamsToTrackingURL:Boolean = true;
		protected var _useDefaultPaths:Boolean = true;
		protected var _name:String = "No name";

		protected var _paths:Object = {
			impressions: {
				enable: false
			},
			adCalls: {
				enable: false
			},
			template: {
				enable: false
			},
			adSlot: {
				enable: false
			},
			progress: {
				enable: false
			},
			clicks: {
				enable: false
			},
			vpaid: {
				enable: false
			}
		}
		
		// Custom additional parameters
		
		protected var _additionalParams:Object = null;
		protected var _additionalParamsString:String = "";
		
		// Handle to the display object - required by the GA framework

		protected var _displayObject:DisplayObject = null;
		
		//protected static const DEFAULT_ACCOUNT_ID:String = "UA-10158120-1"; 	// OVA Test Account
		protected static const DEFAULT_ACCOUNT_ID:String = "UA-4011032-6";  	// OVA Production Account
		
		public function GoogleAnalyticsTrackingGroup(name:String, config:Object=null, forceEnable:Boolean=false) {
			if(name != null) _name = name;
			if(config != null) {
				initialise(config, forceEnable);
			}
			else setDefaultPaths();
		}

		public function turnOnAllTracking():void {
			_enableTracking = true;
		}
		
		public function turnOffAllTracking():void {
			_enableTracking = false;
		}
		
		public function enableTracking(type:String):void {
			_enableTracking = true;
			if(type == AnalyticsProcessor.ALL) {
				turnOnAllTracking();
			}
			else {
				_paths[type].enable = true;
			}
		}

		public function disableTracking(type:String):void {
			if(type == AnalyticsProcessor.ALL) {
				turnOffAllTracking();
			}
			else {
				_paths[type].enable = false;
			}
		}
		
		public function set name(name:String):void {
			_name = name;
		}
		
		public function get name():String {
			return _name;
		}
		
		protected function processConfigBlock(blockIn:Object, blockToSet:Object, forceEnable:Boolean=false):void {
			if(blockIn != null && blockToSet != null) {
				var enableSet:Boolean = false;
				var needToAutoEnable:Boolean = false;
				for(var prop:* in blockIn) {
					if(prop == "enable") {
						if(blockIn.enable is String) {
							blockToSet.enable = (blockIn.enable.toUpperCase() == "TRUE");
						}
						else blockToSet.enable = blockIn.enable;
						if(blockToSet.enable) _enableTracking = true;
						enableSet = true;
					}
					else {
						blockToSet[prop] = blockIn[prop];
						needToAutoEnable = true;
					}
				}
				if(forceEnable && needToAutoEnable && (enableSet == false)) {
					blockToSet.enable = true;
				}	
			}
		}
		
		protected function constructAdditionalParamsString():void {
			var result:String = "";
			if(_additionalParams != null) {
				for(var prop:* in _additionalParams) {
					result += "&" + prop + "=" + _additionalParams[prop];
				}
			}
			_additionalParamsString = result;
		}
		
		public function initialise(config:Object, forceEnable:Boolean=false):void {
			if(config.useDefaultPaths != undefined) {
				_useDefaultPaths = StringUtils.validateAsBoolean(config.useDefaultPaths);				
			}
			setDefaultPaths();

			if(config.accountId != undefined) {
				_accountId = config.accountId;
			}
			if(config.enable != undefined) {
				if(config.enable is String) {
					_enableTracking = (config.enable.toUpperCase() == "TRUE");
				}
				else _enableTracking = config.enable;
			}
			if(config.name != undefined) {
				_name = config.name;
			}
			if(config.impressions != undefined) {
				processConfigBlock(config.impressions, _paths.impressions, forceEnable);
			}
			if(config.adCalls != undefined) {
				processConfigBlock(config.adCalls, _paths.adCalls, forceEnable);
			}
			if(config.template != undefined) {
				processConfigBlock(config.template, _paths.template, forceEnable);
			}
			if(config.adSlot != undefined) {
				processConfigBlock(config.adSlot, _paths.adSlot, forceEnable);
			}
			if(config.progress != undefined) {
				processConfigBlock(config.progress, _paths.progress, forceEnable);
			}
			if(config.vpaid != undefined) {
				processConfigBlock(config.vpaid, _paths.vpaid, forceEnable);
			}
			if(config.clicks != undefined) {
				processConfigBlock(config.clicks, _paths.clicks, forceEnable);
			}
			if(config.parameters != undefined) {
				additionalParameters = config.parameters;
			}
			if(config.displayObject != undefined) {
				_displayObject = config.displayObject;
			}
			if(config.trackAdTags != undefined) {
				_trackAdTags = StringUtils.validateAsBoolean(config.trackAdTags);
			}
			if(config.addParamsToTrackingURL != undefined) {
				_addParamsToTrackingURL = StringUtils.validateAsBoolean(config.addParamsToTrackingURL);
			}			
			reportStatus();
		}
		
		protected function setDefaultPaths():void {
			if(_useDefaultPaths) {
				_paths = {
					impressions: {
						enable: false,
						linear: "/ova/impression/default?ova_format=linear",
						nonLinear: "/ova/impression/default?ova_format=non-linear",
						companion: "/ova/impression/default?ova_format=companion"
					},
					adCalls: {
						enable: false,
						fired: "/ova/ad-call/default?ova_action=fired",
						complete: "/ova/ad-call/default?ova_action=complete",
						failover: "/ova/ad-call/default?ova_action=failover",
						error: "/ova/ad-call/default?ova_action=error",
						timeout: "/ova/ad-call/default?ova_action=timeout",
						deferred: "/ova/ad-call/default?ova_action=deferred"
					},
					template: {
						enable: false,
						loaded: "/ova/template/default?ova_action=loaded",
						error: "/ova/template/default?ova_action=error",
						timeout: "/ova/template/default?ova_action=timeout",
						deferred: "/ova/template/default?ova_action=deferred"
					},
					adSlot: {
						enable: false,
						loaded: "/ova/ad-slot/default?ova_action=loaded",
						error: "/ova/ad-slot/default?ova_action=error",
						timeout: "/ova/ad-slot/default?ova_action=timeout",
						deferred: "/ova/ad-slot/default?ova_action=deferred"
					},
					progress: {
						enable: false,
						start: "/ova/progress/default?ova_action=start",
						stop: "/ova/progress/default?ova_action=stop",
						firstQuartile: "/ova/progress/default?ova_action=firstQuartile",
						midpoint: "/ova/progress/default?ova_action=midpoint",
						thirdQuartile: "/ova/progress/default?ova_action=thirdQuartile",
						complete: "/ova/progress/default?ova_action=complete",
						pause: "/ova/progress/default?ova_action=pause",
						resume: "/ova/progress/default?ova_action=resume",
						fullscreen: "/ova/progress/default?ova_action=fullscreen",
						mute: "/ova/progress/default?ova_action=mute",
						unmute: "/ova/progress/default?ova_action=unmute",
						expand: "/ova/progress/default?ova_action=expand",
						collapse: "/ova/progress/default?ova_action=collapse",
						userAcceptInvitation: "/ova/progress/default?ova_action=userAcceptInvitation",
						close: "/ova/progress/default?ova_action=close"
					},
					clicks: {
						enable: false,
						linear: "/ova/clicks/default?ova_action=linear",
						nonLinear: "/ova/clicks/default?ova_action=nonLinear",
						vpaid: "/ova/clicks/default?ova_action=vpaid"
					},
					vpaid: {
						enable: false,
						loaded: "/ova/vpaid/default?ova_action=loaded",
						started: "/ova/vpaid/default?ova_action=started",
						stopped: "/ova/vpaid/default?ova_action=stopped",
						linearChange: "/ova/vpaid/default?ova_action=linearChange",
						expandedChange: "/ova/vpaid/default?ova_action=expandedChange",
						remainingTimeChange: "/ova/vpaid/default?ova_action=remainingTimeChange",
						volumeChange: "/ova/vpaid/default?ova_action=volumeChange",
						videoStart: "/ova/vpaid/default?ova_action=videoStart",
						videoFirstQuartile: "/ova/vpaid/default?ova_action=videoFirstQuartile",
						videoMidpoint: "/ova/vpaid/default?ova_action=videoMidpoint",
						videoThirdQuartile: "/ova/vpaid/default?ova_action=videoThirdQuartile",
						videoComplete: "/ova/vpaid/default?ova_action=videoComplete",
						userAcceptInvitation: "/ova/vpaid/default?ova_action=userAcceptInvitation",
						userClose: "/ova/vpaid/default?ova_action=userClose",
						paused: "/ova/vpaid/default?ova_action=paused",
						playing: "/ova/vpaid/default?ova_action=playing",
						error: "/ova/vpaid/default?ova_action=error"
					}
				}
			}
			else {
				_paths = {
					impressions: {
						enable: false
					},
					adCalls: {
						enable: false
					},
					template: {
						enable: false
					},
					adSlot: {
						enable: false
					},
					progress: {
						enable: false
					},
					clicks: {
						enable: false
					},
					vpaid: {
						enable: false
					}
				}
			}
		}
		
		public function update(config:Object):void {
			initialise(config);
		}

		public function reportStatus():void {
			CONFIG::debugging { 
				doLog(_name + " overide (" + ((trackingEnabled) ? "ON" : "OFF") + ")" + 
			              " impression (" + ((trackingImpressions()) ? "ON" : "OFF") + ")" +
			              " ad call (" + ((trackingAdCalls()) ? "ON" : "OFF") + ")" +
			              " template (" + ((trackingTemplates()) ? "ON" : "OFF") + ")" +
			              " ad slot (" + ((trackingAdSlots()) ? "ON" : "OFF") + ")" +
			              " progress (" + ((trackingProgress()) ? "ON" : "OFF") + ")" +
			              " VPAID (" + ((trackingVPAID()) ? "ON" : "OFF") + ")" +
			              " clicks (" + ((trackingClicks()) ? "ON" : "OFF") + ")", Debuggable.DEBUG_ANALYTICS);
			}
		}
				
		public function set additionalParameters(params:Object):void {
			_additionalParams = params;
			constructAdditionalParamsString();
		}
		
		protected function getAdditionalParamsString():String {
			return _additionalParamsString;
		}

		// Enabling tracking

		public function hasCustomAccountId():Boolean {
			return (_accountId != null);
		}
		
		public function set accountId(accountId:String):void {
			_accountId = accountId;
		}
		
		public function get accountId():String {
			if(_accountId == null) {
				return DEFAULT_ACCOUNT_ID;
			}
			return _accountId;
		}
		
		public function getPath(type:String, action:String):String {
			if(_paths.hasOwnProperty(type)) {
				if(_paths[type].hasOwnProperty(action)) {
					return _paths[type][action] + getAdditionalParamsString();
				}
			}
			return null;
		}

		public function set trackingEnabled(enableTracking:Boolean):void {
			_enableTracking = enableTracking;
		}
		
		public function get trackingEnabled():Boolean {
			return _enableTracking;
		}

		public function trackingElement(element:String):Boolean {
			if(_paths.hasOwnProperty(element)) {
				if(_paths[element].hasOwnProperty("enable")) {
					return trackingEnabled && _paths[element].enable;
				}
			}
			return false;
		}
		
		public function trackingAdCalls():Boolean {
			return trackingEnabled && _paths.adCalls.enable;
		}
		
		public function trackingTemplates():Boolean {
			return trackingEnabled && _paths.template.enable;
		}

		public function trackingAdSlots():Boolean {
			return trackingEnabled && _paths.adSlot.enable;
		}

		public function trackingProgress():Boolean {
			return trackingEnabled && _paths.progress.enable;
		}		
				
		public function trackingImpressions():Boolean {
			return trackingEnabled && _paths.impressions.enable;	
		}

		public function trackingVPAID():Boolean {
			return trackingEnabled && _paths.vpaid.enable;	
		}

		public function trackingClicks():Boolean {
			return trackingEnabled && _paths.clicks.enable;	
		}
		
		public function set displayObject(displayObject:DisplayObject):void {
			_displayObject = displayObject;
		}
		
		public function get displayObject():DisplayObject {
			return _displayObject;
		}

		public function set trackAdTags(trackAdTags:Boolean):void {
			_trackAdTags = trackAdTags;
		}
		
		public function get trackAdTags():Boolean {
			return _trackAdTags;
		}

		public function set addParamsToTrackingURL(addParamsToTrackingURL:Boolean):void {
			_addParamsToTrackingURL = addParamsToTrackingURL;
		}
		
		public function get addParamsToTrackingURL():Boolean {
			return _addParamsToTrackingURL;
		}

		public function set useDefaultPaths(useDefaultPaths:Boolean):void {
			_useDefaultPaths = useDefaultPaths;
		}
		
		public function get useDefaultPaths():Boolean {
			return _useDefaultPaths;
		}		
	}
}
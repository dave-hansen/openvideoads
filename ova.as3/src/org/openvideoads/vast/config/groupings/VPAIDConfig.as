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
	public class VPAIDConfig {
		public static const RESERVED_FULLSCREEN_BLACK:String = "reserved-fullscreen-black-no-close-button-non-clickable";
		public static const RESERVED_FULLSCREEN_BLACK_WITH_MINIMIZE_RULES:String = "reserved-fullscreen-black-no-close-button-non-clickable-minimize-rules";
		public static const RESERVED_FULLSCREEN_TRANSPARENT:String = "reserved-fullscreen-transparent-no-close-button-non-clickable";
		public static const RESERVED_FULLSCREEN_BLACK_WITH_CB_HEIGHT:String = "reserved-fullscreen-black-no-close-button-non-clickable-with-cb-height";
		public static const RESERVED_FULLSCREEN_TRANSPARENT_BOTTOM_MARGIN_ADJUSTED:String = "reserved-fullscreen-transparent-no-close-button-non-clickable-bottom-margin-adjusted";
		
		protected var _supplyReferrer:Boolean = false;
		protected var _referrer:String = null;
		protected var _holdingClipUrl:String = "http://lp.longtailvideo.com/5/ova/blank.mp4";
		protected var _defaultLinearRegionWithControlbar:String = RESERVED_FULLSCREEN_BLACK;
		protected var _defaultLinearRegionWithoutControlbar:String = RESERVED_FULLSCREEN_BLACK_WITH_CB_HEIGHT;
		protected var _defaultNonLinearRegionWithControlbar:String = RESERVED_FULLSCREEN_TRANSPARENT;
		protected var _defaultNonLinearRegionWithoutControlbar:String = RESERVED_FULLSCREEN_TRANSPARENT_BOTTOM_MARGIN_ADJUSTED;
		protected var _linearRegion:String = null;
		protected var _nonLinearRegion:String = null;
		protected var _maxDurationTimeout:int = 90;
		protected var _enableMaxDurationTimeout:Boolean = false;
		protected var _enableLinearScaling:Boolean = true;
		protected var _enableNonLinearScaling:Boolean = true;
		protected var _pauseOnExpand:Boolean = false;
		protected var _resumeOnCollapse:Boolean = false;
		protected var _testing:Boolean = false;
		protected var _terminateOnLogMessage:String = null;
		protected var _callResizeOnControlbarShowHide:Boolean = true;
		
		public function VPAIDConfig(config:Object=null) {
			if(config != null) {
				initialise(config);
			}
		}
		
		public function initialise(config:Object):void {
			if(config.supplyReferrer != undefined) {
				if(config.supplyReferrer is String) {
					this.supplyReferrer = (config.supplyReferrer.toUpperCase() == "TRUE");
				}
				else this.supplyReferrer = config.supplyReferrer;
			}
			if(config.enableLinearScaling != undefined) {
				if(config.enableLinearScaling is String) {
					this.enableLinearScaling = (config.enableLinearScaling.toUpperCase() == "TRUE");
				}
				else this.enableLinearScaling = config.enableLinearScaling;
			}
			if(config.callResizeOnControlbarShowHide != undefined) {
				if(config.callResizeOnControlbarShowHide is String) {
					this.callResizeOnControlbarShowHide = (config.callResizeOnControlbarShowHide.toUpperCase() == "TRUE");
				}
				else this.callResizeOnControlbarShowHide = config.callResizeOnControlbarShowHide;
			}
			if(config.enableNonLinearScaling != undefined) {
				if(config.enableNonLinearScaling is String) {
					this.enableNonLinearScaling = (config.enableNonLinearScaling.toUpperCase() == "TRUE");
				}
				else this.enableNonLinearScaling = config.enableNonLinearScaling;
			}
			if(config.referrer != undefined) this.referrer = config.referrer;
			if(config.holdingClipUrl != undefined) this.holdingClipUrl = config.holdingClipUrl;
			if(config.linearRegion != undefined) this.linearRegion = config.linearRegion;
			if(config.nonLinearRegion != undefined) this.nonLinearRegion = config.nonLinearRegion;
			if(config.terminateOnLogMessage != undefined) {
				if(config.terminateOnLogMessage != null) {
					var thePattern:RegExp = new RegExp("__single-quote__", "g");
					config.terminateOnLogMessage = config.terminateOnLogMessage.replace(thePattern, "'");
				}
				this.terminateOnLogMessage = config.terminateOnLogMessage;
				
			}
			if(config.enableMaxDurationTimeout != undefined) {
				if(config.enableMaxDurationTimeout is String) {
					this.enableMaxDurationTimeout = (config.enableMaxDurationTimeout.toUpperCase() == "TRUE");
				}
				else this.enableMaxDurationTimeout = config.enableMaxDurationTimeout;
			}
			if(config.maxDurationTimeout != undefined) {
				if(config.maxDurationTimeout is String) {
					this.maxDurationTimeout = int(config.maxDurationTimeout);
				}
				else this.maxDurationTimeout = config.maxDurationTimeout;
			}
			if(config.pauseOnExpand != undefined) {
				if(config.pauseOnExpand is String) {
					this.pauseOnExpand = (config.pauseOnExpand.toUpperCase() == "TRUE");
				}
				else this.pauseOnExpand = config.pauseOnExpand;
			}
			if(config.resumeOnCollapse != undefined) {
				if(config.resumeOnCollapse is String) {
					this.resumeOnCollapse = (config.resumeOnCollapse.toUpperCase() == "TRUE");
				}
				else this.resumeOnCollapse = config.resumeOnCollapse;
			}
			if(config.testing != undefined) {
				if(config.testing is String) {
					this.testing = (config.testing.toUpperCase() == "TRUE");
				}
				else this.testing = config.testing;
			}
		}

		public function set supplyReferrer(supplyReferrer:Boolean):void {
			_supplyReferrer = supplyReferrer;
		}
		
		public function get supplyReferrer():Boolean {
			return _supplyReferrer;
		}

		public function set referrer(referrer:String):void {
			_referrer = referrer;
		}
		
		public function get referrer():String {
			return _referrer;
		}

		public function set pauseOnExpand(pauseOnExpand:Boolean):void {
			_pauseOnExpand = pauseOnExpand;
		}
		
		public function get pauseOnExpand():Boolean {
			return _pauseOnExpand;
		}

		public function set resumeOnCollapse(resumeOnCollapse:Boolean):void {
			_resumeOnCollapse = resumeOnCollapse;
		}
		
		public function get resumeOnCollapse():Boolean {
			return _resumeOnCollapse;
		}

		public function get terminateOnLogMessage():String {
			return _terminateOnLogMessage;
		}
		
		public function set callResizeOnControlbarShowHide(callResizeOnControlbarShowHide:Boolean):void {
			_callResizeOnControlbarShowHide = callResizeOnControlbarShowHide;	
		}
		
		public function get callResizeOnControlbarShowHide():Boolean {
			return _callResizeOnControlbarShowHide;
		}
		
		public function set terminateOnLogMessage(terminateOnLogMessage:String):void {
			_terminateOnLogMessage = terminateOnLogMessage;
		}
		
		public function set enableLinearScaling(enableLinearScaling:Boolean):void {
			_enableLinearScaling = enableLinearScaling;
		}
		
		public function get enableLinearScaling():Boolean {
			return _enableLinearScaling;
		}

		public function set enableNonLinearScaling(enableNonLinearScaling:Boolean):void {
			_enableNonLinearScaling = enableNonLinearScaling;
		}
		
		public function get enableNonLinearScaling():Boolean {
			return _enableNonLinearScaling;
		}
		
		public function set holdingClipUrl(holdingClipUrl:String):void {
			_holdingClipUrl = holdingClipUrl;
		}
		
		public function get holdingClipUrl():String {
			return _holdingClipUrl;
		}
		
		public function set testing(testing:Boolean):void {
			_testing = testing;
		}
		
		public function get testing():Boolean {
			return _testing;
		}
		
		public function hasLinearRegionSpecified():Boolean {
			return (_linearRegion != null);
		}
		
		public function set linearRegion(linearRegion:String):void {
			_linearRegion = linearRegion;
		}

		public function getLinearRegion(showControls:Boolean):String {
			if(_linearRegion != null) {
				return _linearRegion;			
			}
			if(showControls) {
				return _defaultLinearRegionWithControlbar;
			}
			return _defaultLinearRegionWithoutControlbar;
		}

		public function set nonLinearRegion(nonLinearRegion:String):void {
			_nonLinearRegion = nonLinearRegion;
		}

		public function get nonLinearRegion():String {
			if(_nonLinearRegion != null) {
				return _nonLinearRegion;			
			}
			return _defaultNonLinearRegionWithControlbar;
		}

		public function hasNonLinearRegionSpecified():Boolean {
			return (_nonLinearRegion != null);
		}
		
		public function set maxDurationTimeout(maxDurationTimeout:int):void {
			_maxDurationTimeout = maxDurationTimeout;
		}
		
		public function get maxDurationTimeout():int {
			return _maxDurationTimeout;
		}
		
		public function set enableMaxDurationTimeout(enableMaxDurationTimeout:Boolean):void {
			_enableMaxDurationTimeout = enableMaxDurationTimeout;
		}
		
		public function get enableMaxDurationTimeout():Boolean {
			return _enableMaxDurationTimeout;
		}
	}
}
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
package org.openvideoads.vast.model {
	import org.openvideoads.base.Debuggable;
	
	/**
	 * @author Paul Schulz
	 */
	public class VideoAdV2 extends VideoAd {
		protected var _containerAdId:String;
		
		public function VideoAdV2() {
			super();
		}

		public function get containerAdId():String {
			return _containerAdId;
		}
		
		public function set containerAdId(containerAdId:String):void {
			_containerAdId = containerAdId;
		}

		/*
		 * override added to provide better support for VAST1 -> VAST2 wrapper interoperability - and visa versa
		 */
		public override function injectAllTrackingData(videoAd:VideoAd):VideoAd {
			// "this" is the template, "videoAd" is the actual video ad

			CONFIG::debugging { doLog("Injecting general impression and tracking events from V2 VideoAd template '" + this.id + "' " + this.uid + " into an actual " + ((videoAd is VideoAdV2) ? "V2" : "V1") + " VideoAd '" + videoAd.id + "' " + videoAd.uid, Debuggable.DEBUG_VAST_TEMPLATE); }
			videoAd.addImpressions(_impressions);
			videoAd.addTrackingEventItems(_trackingEvents);
			videoAd.addErrorUrls(_errorUrls);
			if(_linearVideoAd != null) {
				if(videoAd is VideoAdV2) {
					CONFIG::debugging { doLog("Injecting linear video tracking events from V2 VideoAd " + _linearVideoAd.uid + " into V2 VideoAd " + videoAd.linearVideoAd.uid, Debuggable.DEBUG_VAST_TEMPLATE); }
					videoAd.linearVideoAd.addTrackingEventItems(_linearVideoAd.trackingEvents);
					videoAd.linearVideoAd.addClickTrackingItems(_linearVideoAd.clickTracking);
					videoAd.linearVideoAd.addCustomClickTrackingItems(_linearVideoAd.customClicks);	
				}
				else {
					// it's a V1 VideoAd - tracking events etc. are not stored in the linear ad
					CONFIG::debugging { doLog("Injecting linear video tracking events from V2 VideoAd " + _linearVideoAd.uid + " into V1 VideoAd " + videoAd.linearVideoAd.uid, Debuggable.DEBUG_VAST_TEMPLATE); }
					videoAd.addTrackingEventItems(_linearVideoAd.trackingEvents);
					videoAd.addClickTrackingItems(_linearVideoAd.clickTracking);
					videoAd.addCustomClickTrackingItems(_linearVideoAd.customClicks);	
				}
			}
			if(hasNonLinearAds()) {
				for(var i:int = 0; i < _nonLinearVideoAds.length; i++) {
					if(i < videoAd.nonLinearVideoAds.length) {
						CONFIG::debugging { doLog("Injecting V2 non-linear video tracking events from " + _nonLinearVideoAds[i].uid + " into " + videoAd.nonLinearVideoAds[i].uid, Debuggable.DEBUG_VAST_TEMPLATE); }
						videoAd.nonLinearVideoAds[i].addTrackingEventItems(_nonLinearVideoAds[i].trackingEvents);
					}
				}
			}
			if(hasCompanionAds()) {
				// not doing anything here
			}

			return videoAd;
		}

		public function hasLinearTrackingEvents():Boolean {
			if(hasLinearAd()) {
				return _linearVideoAd.hasTrackingEvents();
			}
			return false;
		}
		
		public override function get trackingEvents():Array {
			if(isLinear()) {
				return _linearVideoAd.trackingEvents;
			}
			return new Array();
		}

		public function hasNonLinearTrackingEvents():Boolean {
			if(hasNonLinearAds()) {
				for(var i:int=0; i < _nonLinearVideoAds.length; i++) {
					if(_nonLinearVideoAds[i].hasTrackingEvents()) {
						return true;
					}
				}				
			}
			return false;
		}
		
		public override function hasTrackingEvents():Boolean {
			return (hasLinearTrackingEvents() || hasNonLinearTrackingEvents());
		}

		protected override function _triggerTrackingEvent(eventType:String, id:String=null, contentPlayhead:String=null):void {
			if(isLinear()) {
				_linearVideoAd.triggerTrackingEvent(eventType, contentPlayhead);
				super._triggerTrackingEvent(eventType, id, contentPlayhead);
			}
			else if(isNonLinear()) {
				// the only events covered at present are fired in the nonLinearAd.start() method
			}
			else if(isCompanion()) {
				// no companion specific tracking events supported at this time apart from creativeView which is fired separately
			}
			else {
				CONFIG::debugging { doLog("FATAL: Unable to fire tracking events for VideoAd (" + this.id + ", " + this.adId + ") - ad type unknown", Debuggable.DEBUG_FATAL); }
			}
		}
	}
}
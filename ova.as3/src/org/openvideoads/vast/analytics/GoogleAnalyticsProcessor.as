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
package org.openvideoads.vast.analytics {
	import com.google.analytics.AnalyticsTracker;
	import com.google.analytics.GATracker;
	
	import flash.display.DisplayObject;
	
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.vast.server.request.AdServerRequest;
	import org.openvideoads.util.NetworkResource;
	import org.openvideoads.util.StringUtils;
	import org.openvideoads.vast.config.groupings.analytics.google.GoogleAnalyticsConfigGroup;
	import org.openvideoads.vast.config.groupings.analytics.google.GoogleAnalyticsTrackingGroup;
	import org.openvideoads.vast.model.CompanionAd;
	import org.openvideoads.vast.model.LinearVideoAd;
	import org.openvideoads.vast.model.MediaFile;
	import org.openvideoads.vast.model.NonLinearVideoAd;
	import org.openvideoads.vast.model.VideoAd;
	import org.openvideoads.vast.schedule.ads.AdSlot;
	
	public class GoogleAnalyticsProcessor extends Debuggable implements AnalyticsInterface {
		
        protected var _gaOVATracker:AnalyticsTracker = null;
        protected var _gaCustomTracker:AnalyticsTracker = null;
        protected var _config:GoogleAnalyticsConfigGroup = null;
        protected var _displayObject:DisplayObject = null;
		
		public function GoogleAnalyticsProcessor(config:GoogleAnalyticsConfigGroup) {
			if(config != null) initialise(config);
		}

		public function initialise(config:GoogleAnalyticsConfigGroup):void {
			_config = config;
			if(_config != null) {
				if(_config.enabled) {
					try {
						if(_config.ova.trackingEnabled && _config.ova.displayObject != null) {
							CONFIG::debugging { doLog("Google Analytics OVA Tracker instantiated - tracking to account " + _config.ova.accountId, Debuggable.DEBUG_ANALYTICS); }
				            _gaOVATracker = new GATracker(_config.ova.displayObject, config.ova.accountId, "AS3", false);							
						}
						else {
							CONFIG::debugging { doLog("Google Analytics OVA Tracker has been disabled - ova.trackingEnabled='" + _config.ova.trackingEnabled + "'" + ((_config.ova.displayObject == null) ? " displayObject is null" : ""), Debuggable.DEBUG_ANALYTICS); }
							_gaOVATracker = null;
						}
						
						if(_config.custom.trackingEnabled && _config.custom.displayObject != null) {
							CONFIG::debugging { doLog("Google Analytics CUSTOM Tracker instantiated - tracking to account " + _config.custom.accountId, Debuggable.DEBUG_ANALYTICS); }
				            _gaCustomTracker = new GATracker(_config.custom.displayObject, _config.custom.accountId, "AS3", false);							
						}
						else {
							CONFIG::debugging { doLog("Google Analytics CUSTOM Tracker has been disabled - custom.trackingEnabled='" + _config.custom.trackingEnabled + "'" + ((_config.custom.displayObject == null) ? " displayObject is null" : ""), Debuggable.DEBUG_ANALYTICS); }
							_gaCustomTracker = null;
						}										
					}
					catch(e:Error) {
						CONFIG::debugging { doLog("Google Analytics has thrown an exception on startup - " + e.message, Debuggable.DEBUG_ANALYTICS); }
					}
				}
				else {
					CONFIG::debugging { doLog("Google Analytics Tracker has been disabled completely", Debuggable.DEBUG_ANALYTICS); }
				}
			}
		}
		
		// Helper methods
		
        protected function getAdSlotTrackingParams(adSlot:AdSlot):String {
        	if(adSlot != null) {
				return "&ova_ad_slot_position=" + adSlot.position +
				       "&ova_ad_slot_zone=" + adSlot.zone + 
				       "&ova_ad_slot_index=" + adSlot.key +
				       "&ova_slot_type=" + adSlot.getSlotType() + 
				       (adSlot.isMidRoll() ? "ova_slot_starttime=" + adSlot.startTime : ""); 
        	}
        	return "";
        }

        protected function getAdContainerTrackingParams(videoAd:VideoAd):String {
        	if(videoAd != null) {
	        	var paramString:String = "";
	        	return "&ova_ad_id=" + encodeURIComponent(videoAd.adId) +
	        	       "&ova_sequence_id=" + encodeURIComponent(videoAd.sequenceId) + 
	        	       "&ova_creative_id=" + encodeURIComponent(videoAd.creativeId) + 
	        		   "&ova_ad_system=" + encodeURIComponent(videoAd.adSystem) +
					   "&ova_ad_title=" + encodeURIComponent(videoAd.adTitle) +
					   "&ova_ad_description=" + encodeURIComponent(videoAd.description); 
        	}
        	return "";
        }

        protected function getLinearAdTrackingParams(ad:LinearVideoAd):String {
        	if(ad != null) {
        		var media:MediaFile = ad.lastSelectedMediaFile();
        		if(media != null) {
        			return "&ova_media_url=" + encodeURIComponent(StringUtils.limitLength(media.url.url, 200)) +
        			    "&ova_media_interactive=" + (media.isInteractive() ? "true" : "false") +
		        		"&ova_media_bitrate=" + media.bitRate +
		        		"&ova_media_delivery=" + media.delivery +
	    	    		"&ova_media_apiFramework=" + media.apiFramework;
        		}
        	}
        	return "";
        }

        protected function getNonLinearAdTrackingParams(ad:NonLinearVideoAd):String {
        	if(ad != null) {
        		 return "&ova_non_linear_interactive=" + (ad.isInteractive() ? "true" : "false") +
         		        "&ova_creative_type=" + ad.creativeType +
         		        "&ova_resource_type=" + ad.resourceType +
        		        "&ova_creative_width=" + ad.width +
        		        "&ova_creative_height=" + ad.height 
        	}
        	return "";
        }

        protected function getCompanionAdTrackingParams(ad:CompanionAd):String {
        	if(ad != null) {
        		return "&ova_companion_creative_type=" + ad.creativeType +
        		       "&ova_companion_resource_type=" + ad.resourceType +
        		       "&ova_companion_width=" + ad.width +
        		       "&ova_companion_height=" + ad.height;
        	}
        	return "";
        }
        
        protected function getAdRequestParams(adRequest:AdServerRequest):String {
        	if(adRequest != null) {
				return "&ova_ad_server_type=" + adRequest.serverType() +
    		           "&ova_ad_server_tag=" + encodeURIComponent(StringUtils.limitLength(adRequest.formedRequest, 200));
        	}
        	return "";
        }
        
        protected function formatAdditionalParams(params:*):String {
        	if(params != null) {
        		if(params is String) {
        			if(StringUtils.beginsWith(params, "&")) {
	        			return params;
	        		}
	        		else return "&" + params;
        		}
        	}	
        	return "";
        }
	
		protected function fireCalls(element:String, type:String, params:String, adTag:String=null):void {
			var path:String = null;
			var config:GoogleAnalyticsTrackingGroup = _config.ova;
			var accountType:String = "OVA";
			var tracker:AnalyticsTracker = _gaOVATracker;
			for(var i:int=0; i < 2; i++) {
				if(config.trackingElement(element) && tracker != null) {
					path = config.getPath(element, type);
					if(path != null) {
						try {
							CONFIG::debugging { doLog("Firing " + element + " '" + type + "' to Google Analytics " + accountType + " account " + config.accountId + " (" + path + ")", Debuggable.DEBUG_ANALYTICS);	}			
							if(adTag != null) {
								var finalTrackingURL:String = null;
								if(config.addParamsToTrackingURL) {
									finalTrackingURL = NetworkResource.addParameterToURLString(path, params);
									if(config.trackAdTags == false) {
										// This is an internal OVA tracking call or it's custom but "trackAdTags" is false in the config 
										// so do not provide the full ad tag - just the ad server type so extract that from the
										// ad tag and add it to the final URL
										finalTrackingURL += "&ova_ad_provider=" + NetworkResource.getDomain(adTag);
									}
									else {
										// Only add in the full ad tag to the tracking URL if it is turned on in the Custom config settings
										finalTrackingURL += "&ova_ad_tag=" + encodeURIComponent(adTag);
									}
								}
								else finalTrackingURL = path;
					            tracker.trackPageview(finalTrackingURL);
							}
							else {
								// we don't need to add in the ad tag in one form or the other							
					            tracker.trackPageview(NetworkResource.addParameterToURLString(path, params));
							}
				  		}
				  		catch(e:Error) {
							CONFIG::debugging { doLog("Google Analytics has thrown an exception when firing the call  - " + e.message, Debuggable.DEBUG_ANALYTICS); }
				  		}
					}	
					else {
						CONFIG::debugging { doLog("GA tracking path for '" + type + "' is null - cannot track", Debuggable.DEBUG_ANALYTICS);	}
					}	
				}
				config = _config.custom;
				accountType = "CUSTOM";
				tracker = _gaCustomTracker;
			}
		}
		
		// Tracking methods
		
		public function fireAdCallTracking(type:String, adRequest:AdServerRequest, wrapped:Boolean=false, additionalParams:*=null):void {
			if(_config != null) {
				fireCalls(
					AnalyticsProcessor.AD_CALLS, 
					type, 
					getAdRequestParams(adRequest) + "&ova_wrapped_ad_tag=" + wrapped + formatAdditionalParams(additionalParams), 
					null
				);
			}
		}

        public function fireAdSchedulingTracking(type:String, adSlot:AdSlot, additionalParams:*=null):void {
        	// Not implemented as a standard GA call
        }
		
		public function fireImpressionTracking(type:String, adSlot:AdSlot, ad:*, additionalParams:*=null):void {
			if(_config != null && adSlot != null && ad != null) {
				fireCalls(
					AnalyticsProcessor.IMPRESSIONS, 
					type,
            		getAdSlotTrackingParams(adSlot) + 
            			getAdContainerTrackingParams(adSlot.videoAd) +
            			((ad is LinearVideoAd) ? 
            				getLinearAdTrackingParams(ad) :
            				((ad is NonLinearVideoAd) ? getNonLinearAdTrackingParams(ad) : getCompanionAdTrackingParams(ad))) + 
            			formatAdditionalParams(additionalParams),
            		adSlot.adServerTag
            	);		
			}
		}

        public function fireTemplateLoadTracking(type:String, additionalParams:*=null):void{
			if(_config != null) {
				fireCalls(
					AnalyticsProcessor.TEMPLATE, 
					type, 
					formatAdditionalParams(additionalParams),
					null
				);
			}
        }

        public function fireAdSlotTracking(type:String, adSlot:AdSlot, additionalParams:*=null):void {
			if(_config != null && adSlot != null) {
				fireCalls(
					AnalyticsProcessor.AD_SLOT, 
					type,
	           		getAdSlotTrackingParams(adSlot) + 
	            		getAdContainerTrackingParams(adSlot.videoAd) +
	            		formatAdditionalParams(additionalParams),
	            	adSlot.adServerTag
				);
			}
        }
                		
        public function fireAdPlaybackTracking(type:String, adSlot:AdSlot, ad:*, additionalParams:*=null):void {
			if(_config != null && adSlot != null && ad != null) {
				fireCalls(
					AnalyticsProcessor.PROGRESS, 
					type,
            		getAdSlotTrackingParams(adSlot) + 
	            		getAdContainerTrackingParams(adSlot.videoAd) +
    	        		((ad is LinearVideoAd) ? 
        	    			getLinearAdTrackingParams(ad) :
            				((ad is NonLinearVideoAd) ? getNonLinearAdTrackingParams(ad) : "")) + 
            			formatAdditionalParams(additionalParams),
            		adSlot.adServerTag
				);
			}
        }

        public function fireVPAIDPlaybackTracking(type:String, adSlot:AdSlot, ad:*, additionalParams:*=null):void {
			if(_config != null && adSlot != null && ad != null) {
				fireCalls(
					AnalyticsProcessor.VPAID, 
					type,
            		getAdSlotTrackingParams(adSlot) + 
	            		getAdContainerTrackingParams(adSlot.videoAd) +
    	        		((ad is LinearVideoAd) ? 
        	    			getLinearAdTrackingParams(ad) :
            				((ad is NonLinearVideoAd) ? getNonLinearAdTrackingParams(ad) : "")) + 
            			formatAdditionalParams(additionalParams),
            		adSlot.adServerTag
				);
			}
        }
        
        public function fireAdClickTracking(type:String, adSlot:AdSlot, ad:*, additionalParams:*=null):void {
			if(_config != null && adSlot != null && ad != null) {
				fireCalls(
					AnalyticsProcessor.CLICKS, 
					type,
            		getAdSlotTrackingParams(adSlot) + 
	            		getAdContainerTrackingParams(adSlot.videoAd) +
    	        		((ad is LinearVideoAd) ? 
        	    			getLinearAdTrackingParams(ad) :
            				((ad is NonLinearVideoAd) ? getNonLinearAdTrackingParams(ad) : "")) + 
            			formatAdditionalParams(additionalParams),
            		adSlot.adServerTag
				);
			}
        }     	
	}
}



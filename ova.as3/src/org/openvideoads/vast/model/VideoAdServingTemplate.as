/*    
 *    Copyright (c) 2013 LongTail AdSolutions, Inc
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
	import flash.events.*;
	import flash.net.*;
	import flash.utils.ByteArray;
	import flash.xml.*;
	
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.util.InjectedLoader;
	import org.openvideoads.util.NetworkResource;
	import org.openvideoads.util.ObjectUtils;
	import org.openvideoads.util.StringUtils;
	import org.openvideoads.util.Timestamp;
	import org.openvideoads.vast.analytics.AnalyticsProcessor;
	import org.openvideoads.vast.server.request.AdServerRequest;
	import org.openvideoads.vast.server.request.injected.InjectedVASTAdRequest;
	import org.openvideoads.vast.server.response.AdServerTemplate;
	import org.openvideoads.vast.server.response.TemplateLoadListener;
	
	/**
	 * @author Paul Schulz
	 */
	public class VideoAdServingTemplate extends AdServerTemplate implements TemplateLoadListener {
		protected var _indexCounters:Array = new Array();
		protected var _vastVersion:Number = 1.0;
		
		public static const PARSE_ALL:String = "ALL";
		public static const PARSE_LINEARS:String = "LINEAR";
		public static const PARSE_NON_LINEARS:String = "NON-LINEAR";
		
		/**
		 * The constructor for a VideoAdServingTemplate
		 * 
		 * @param listener an optional VASTLoadListener that will receive a callback when 
		 * the template successfully loads or fails
		 * @param request an optional OpenXVASTAdRequest that is the request URL to call to 
		 * obtain the VAST template from an OpenX Ad Server
		 */		
		public function VideoAdServingTemplate(listener:TemplateLoadListener=null, request:AdServerRequest=null, replaceAdIds:Boolean=false, adIds:Array=null) {
			super(listener, request, replaceAdIds, adIds);
		}
		
		/**
		 * Makes a request to the VAST Ad Server to retrieve a VAST dataset given the request
		 * parameters before loading up the returned data and making a callback to the VASTLoadListener
		 * registered on construction of the template.
		 * 
		 * @param request the OpenXVASTAdRequest object that specifies the parameters to be passed
		 * to the OpenX Ad Server, including the address of the server itself 
		 * @param retry - set to true if this a failover attempt
		 */
		public override function load(request:AdServerRequest, retry:Boolean=false):void {
			if(request != null) {
				if(!retry) {
					masterAdRequest = request;
					registerLoader(_uid);
				}
				if(request is InjectedVASTAdRequest) {
					CONFIG::debugging { doLog("Loading VAST response directly from the injected configuration", Debuggable.DEBUG_VAST_TEMPLATE); }
					_xmlLoader = new InjectedLoader();
	   			    _xmlLoader.addEventListener(Event.COMPLETE, templateLoaded);
					InjectedLoader(_xmlLoader).process(request.formRequest());
				}
				else {
					loadTemplateData(request);
				}
			}
		}
		
		protected override function loadTemplateData(request:AdServerRequest):void {
			if(request != null) {
				super.loadTemplateData(request);					
			}
			else {
				CONFIG::debugging { doLog("Cannot load the VAST ad data - no request provided", Debuggable.DEBUG_VAST_TEMPLATE); }
			}
		}
		
		CONFIG::callbacks 
		public function canFireAPICalls():Boolean {
			if(_listener != null) {
				return _listener.canFireAPICalls();				
			}
			return false;
		}
		
		CONFIG::callbacks
		public function canFireEventAPICalls():Boolean {
			if(_listener != null) {
				return _listener.canFireEventAPICalls();
			}
			return false;
		}

		CONFIG::callbacks
		public function get useV2APICalls():Boolean {
			if(_listener != null) {
				return _listener.useV2APICalls;
			}
			return false;
		}

		CONFIG::callbacks
		public function get jsCallbackScopingPrefix():String {
			if(_listener != null) {
				return _listener.jsCallbackScopingPrefix;
			}
			return "";
		}

		public function get analyticsProcessor():AnalyticsProcessor {
			if(_listener != null) {
				return _listener.analyticsProcessor;				
			}
			return null;
		}
		
		public function set vastVersion(version:Number):void {
			_vastVersion = version;
			CONFIG::debugging { doLog("VAST version declared in the response as " + _vastVersion.toString(), Debuggable.DEBUG_VAST_TEMPLATE); }
		}
		
		public function get vastVersion():Number {
			return _vastVersion;
		}

		protected override function getReplacementAdId(requiredType:String):String {
			if(_replacementAdIds != null) {
				for each(var adId:Object in _replacementAdIds) {
					if(((adId.slotType == requiredType) || ((adId.slotType + "-vpaid") == requiredType)) && adId.assigned == false) {
						adId.assigned = true;
						return adId.id;
					}
				}
			}	
			return requiredType + ":not-scheduled";
		}
		
		protected function getReplacementAdIdObjectAtPosition(position:int):Object {
			if(_replacementAdIds != null) {
				if(position < _replacementAdIds.length) {
					return _replacementAdIds[position];				
				}
			}
			return { id:"no-id-found", slotType:"unknown", assigned:false};
		}
		
		protected function getReplacementAdIdType(id:String):String {
			if(_replacementAdIds != null) {
				for each(var adId:Object in _replacementAdIds) {
					if(adId.id == id) {
						return adId.slotType;
					}
				}
			}	
			return null;
		}
		
		protected override function templateLoaded(e:Event):void {
			CONFIG::debugging { doLog("Loaded " + ((_xmlLoader is InjectedLoader) ? InjectedLoader(_xmlLoader).getBytesLoaded() : _xmlLoader.bytesLoaded) + " bytes for the VAST template - now parsing it...", Debuggable.DEBUG_VAST_TEMPLATE); }
			_templateData = _xmlLoader.transformedData;
			CONFIG::debugging { doLog(_templateData, Debuggable.DEBUG_VAST_TEMPLATE); }
			parseFromRawData(_templateData);
			if(this.hasAds()) {
				CONFIG::debugging { doLog("VAST Template (" + _uid + ") parsing complete - have " + _ads.length + " ads from the ad server - signaling complete", Debuggable.DEBUG_VAST_TEMPLATE); }
				_dataLoaded = true;
				super.templateLoaded(e);
				return;
			}
			else {
				CONFIG::debugging { doLog("VAST Template (" + _uid + ") parsing complete - no ads found in this response (but it may be a wrapper)", Debuggable.DEBUG_VAST_TEMPLATE); }
				_dataLoaded = true;
				super.templateLoaded(e);
			}
		}

		protected override function errorHandler(e:Event):void {
			CONFIG::debugging { doLog("Load error: " + e.toString(), Debuggable.DEBUG_FATAL); }
			signalTemplateLoadError(_uid, e);
		}
		
		protected override function timeoutHandler(e:Event):void {
			CONFIG::debugging { doLog("Load has timed out - the ad server took too long to respond", Debuggable.DEBUG_VAST_TEMPLATE); }
			signalTemplateLoadTimeout(_uid, e);
		}
		
		public override function filterLinearAdMediaFileByMimeType(mimeTypes:Array):void {
			CONFIG::debugging { doLog("Filtering linear video ad media files by specific mime types...", Debuggable.DEBUG_VAST_TEMPLATE); }
			for(var i:int=0; i < _ads.length; i++) {
				if(VideoAd(_ads[i]).isLinear()) {
					VideoAd(_ads[i]).filterLinearAdMediaFileByMimeType(mimeTypes);
				}
			}
		}

		public function parseFromRawData(rawData:*):void {
			if(rawData != null) {
		      	XML.ignoreWhitespace = true;
				try {
		      		var xmlData:XML = new XML(rawData);
		      		if(xmlData != null) {
			 			CONFIG::debugging { doLog("Number of video ad serving templates returned = " + xmlData.length(), Debuggable.DEBUG_VAST_TEMPLATE); }
			 			if(xmlData.length() > 0) {
			 				var tagName:String = xmlData.name();
			 				if(tagName != null) {
				 				if(tagName.indexOf("VAST") > -1) {
				 					// It's at least a V2 spec since this tag was introduced in V2
				 					if(xmlData.attribute("version") == "2.0" || xmlData.attribute("version") == "2.0.0" || xmlData.attribute("version") == "2.0.1") {
					 					vastVersion = Number(xmlData.attribute("version"));
				 						parseAdSpecs_V2_V3(xmlData.Ad); 
				 					}
				 					else if(xmlData.attribute("version") == "3.0" || xmlData.attribute("version") == "3.0.0") {
					 					_vastVersion = Number(xmlData.attribute("version"));
				 						parseAdSpecs_V2_V3(xmlData.Ad); 
				 					}
				 					else {
				 						CONFIG::debugging { doLog("VAST version " + xmlData.attribute("version") + " is not currently supported.", Debuggable.DEBUG_VAST_TEMPLATE); }
										setParseError("102");
				 					}
				 				}
				 				else if(tagName.indexOf("VideoAdServingWrapper") > -1) {
				 					// It's a VAST 1.0 wrapper template	
				 					vastVersion = new Number(1.0);
				 				}
				 				else { // It must be a pre V1.0 or a V1.x response (V1.0 or V1.1) 
				 					
									if(xmlData.Video != undefined || xmlData.NonLinearAds != undefined) {
										// it's pre 1.0 spec - so just a single linear/non-linear ad
					 					vastVersion = new Number(1.0);
										parseAdSpecs_pre_V1_0(xmlData);	
									}
									else {
					 					vastVersion = new Number(1.1);
					 					parseAdSpecs_V1_X(xmlData.children());
						 			}
				 				}	 					
			 				}
			 				else {
			 					CONFIG::debugging { doLog("VAST response is not a valid XML response - ignoring response", Debuggable.DEBUG_FATAL); }
								setParseError("101");
			 				}
			 			}
			 			else {
			 				CONFIG::debugging { doLog("VAST response does not seem to have any tags - ignoring response", Debuggable.DEBUG_FATAL);	}	
							setParseError("101");
			 			}       			
		      		}
		      		else {
		      			CONFIG::debugging { doLog("Cannot parse the XML Response - XML object is null - ignoring response", Debuggable.DEBUG_FATAL); }
						setParseError("101");
		      		}
				}
				catch(errObject:Error) {
					CONFIG::debugging { doLog("XML Parsing exception ('" + errObject.toString() + "') - tag structure is non-compliant - ignoring response", Debuggable.DEBUG_FATAL); }
					setParseError("100");
				}		      	
			}
			else {
				CONFIG::debugging { doLog("Null VAST response - ignoring response", Debuggable.DEBUG_FATAL); }
				setParseError("101");
			}
		}
		
		/* VAST V1.0 & V1.1 PARSING *****************************************************************/
		
		private function parseAdSpecs_pre_V1_0(adData:XML):void {
			CONFIG::debugging { doLog("Parsing a pre V1.0 VAST response - ...", Debuggable.DEBUG_VAST_TEMPLATE); }	
			var vad:VideoAd = parseInlineAd_V1_X(0, "no-id", adData, PARSE_LINEARS);
			if(vad != null) addVideoAd(vad);
			vad = parseInlineAd_V1_X(1, "no-id", adData, PARSE_NON_LINEARS);
			if(vad != null) addVideoAd(vad);
			CONFIG::debugging { doLog("Parsing DONE", Debuggable.DEBUG_VAST_TEMPLATE); }				
		}
		
		private function parseAdSpecs_V1_X(ads:XMLList):void {
			CONFIG::debugging { doLog("Parsing a V1.X VAST response - " + ads.length() + " ads in the template...", Debuggable.DEBUG_VAST_TEMPLATE); }
			for(var i:int=0; i < ads.length(); i++) {
				var adIds:XMLList = ads[i].attribute("id");
				if(ads[i].children().length() == 1) {
					var vad:VideoAd = parseAdResponse_V1_X(i, adIds[0], ads[i]);
					if(vad != null) {
						if(vad.isFromAdSystem("OpenX")) {
							CONFIG::debugging { doLog("Leaving the contents of the Video Ad untouched - the response is a VAST1 OpenX response so multiple ad units can mean click-to-play", Debuggable.DEBUG_VAST_TEMPLATE); }
							addVideoAd(vad);	
						}
						else {
							if(mustEnsureSingleAdUnitRecordedPerInlineAd() == false) {
								CONFIG::debugging { doLog("ensureSingleAdUnitRecordedPerVideoAd has been set to 'false' - leaving Video Ad untouched", Debuggable.DEBUG_VAST_TEMPLATE);	}						
								addVideoAd(vad);
							}
							else {
								if(vad.hasMultipleAdUnits()) {
									var splitAds:Array = vad.split();
									var originalID:String = vad.id;
									var parentIDType:String = getReplacementAdIdType(originalID);									
									CONFIG::debugging { doLog("This ad has multiple ad units (linear and non-linears) recorded - as it's not OpenX served, it will be split into " + splitAds.length + " separate video ads", Debuggable.DEBUG_VAST_TEMPLATE); }
									CONFIG::debugging { doLog("Parent ad ID ('" + originalID + "') type is '" + parentIDType + "'", Debuggable.DEBUG_VAST_TEMPLATE); }
									for each(var ad:VideoAd in splitAds) {
										if(parentIDType == "linear" && ad.isLinear()) {
											ad.id = originalID;
											parentIDType = null;
										}
										else if(parentIDType == "non-linear" && ad.isNonLinear()) {
											ad.id = originalID;
											parentIDType = null;
										}
										else {
											ad.id = getReplacementAdId(((ad.isNonLinear()) ? "non-linear" : "linear"));											
										}
										addVideoAd(ad);
									}
									CONFIG::debugging { doLog(splitAds.length + " separate VideoAds created from the aggregated original", Debuggable.DEBUG_VAST_TEMPLATE); }
								}
								else {
									CONFIG::debugging { doLog("Leaving the contents of the Video Ad untouched - it does not have multiple valid ad units (linear and non-linear) within it", Debuggable.DEBUG_VAST_TEMPLATE); }
									addVideoAd(vad);
								}	
							}
						}
					}
				}
				else {
					CONFIG::debugging { doLog("No InLine tag found for Ad - " + adIds[0] + " - ignoring this entry", Debuggable.DEBUG_VAST_TEMPLATE);	}
				}
			}
			CONFIG::debugging { doLog("Parsing DONE", Debuggable.DEBUG_VAST_TEMPLATE); }			
		}
		
		private function parseAdResponse_V1_X(adRecordPosition:int, adId:String, adResponse:XML):VideoAd {
			CONFIG::debugging { doLog("Parsing a V1.X ad record at position " + adRecordPosition + " with ID " + adId, Debuggable.DEBUG_VAST_TEMPLATE); }
			if(adResponse.InLine != undefined) {
				return parseInlineAd_V1_X(adRecordPosition, adId, adResponse.children()[0], PARSE_ALL);
			}
			else if(adResponse.Wrapper != undefined) {
				return parseWrappedAd_V1_X(adRecordPosition, adId, adResponse.children()[0]);
			}
			else { // it's potentially just a 1.0 response without an inline or wrapper tag
				return null;
			}
		}

        private function parseWrappedAd_V1_X(adRecordPosition:int, adId:String, wrapperXML:XML):WrappedVideoAdV1 {
			CONFIG::debugging { doLog("Parsing 1.X XML Wrapper Ad record at position " + adRecordPosition + " with ID " + adId, Debuggable.DEBUG_VAST_TEMPLATE); }
			if(wrapperXML.children().length() > 0) {
				return new WrappedVideoAdV1(getReplacementAdIdObjectAtPosition(adRecordPosition), wrapperXML, this, getMasterAdServerConfig());	
			}
			else {
				CONFIG::debugging { doLog("No tags found for Wrapper " + adId + " - ignoring this entry", Debuggable.DEBUG_VAST_TEMPLATE); }
			}
        	return null;
        }	

		private function parseInlineAd_V1_X(adRecordPosition:int, adId:String, ad:XML, mode:String="ALL"):VideoAd {
			CONFIG::debugging { 
				doLog("Parsing 1.X INLINE Ad record at position " + adRecordPosition + " with ID " + adId, Debuggable.DEBUG_VAST_TEMPLATE);
				doLog("Ad has " + ad.children().length() + " attributes defined", Debuggable.DEBUG_VAST_TEMPLATE);
			}
			if(ad.children().length() > 0) {
				var vad:VideoAd = new VideoAd();
				CONFIG::callbacks {
					if(_listener != null) {
						vad.setCanFireAPICalls(_listener.canFireAPICalls());
						vad.setCanFireEventAPICalls(_listener.canFireEventAPICalls());
						vad.useV2APICalls = _listener.useV2APICalls;
						vad.jsCallbackScopingPrefix = _listener.jsCallbackScopingPrefix;
					}
				}
				vad.adSystem = ad.AdSystem;
				vad.adTitle = ad.AdTitle;
				vad.adId = adId;
				vad.description = ad.Description;
				if(ad.Survey != null) {
					if(ad.Survey.URL != undefined) {
						vad.survey = ad.Survey.URL;
					}
					else {
						vad.survey = ad.Survey;
					}
				}
				if(ad.Error != null) {
					if(ad.Error.URL != undefined) {
						vad.addErrorUrl(ad.Error.URL);
					}
					else {
						vad.addErrorUrl(ad.Error);
					}
				}
				vad.parseImpressions(ad);
				vad.parseTrackingEvents(ad);
				CONFIG::debugging { doLog("Created new VideoAd(): " + vad.uid + ", parent Template: " + _uid, Debuggable.DEBUG_VAST_TEMPLATE); }
				if((mode == PARSE_LINEARS || mode == PARSE_ALL) && ad.Video != undefined) {
					vad.parseLinears(ad, -1, getAdServerConfig());
				}
				if((mode == PARSE_NON_LINEARS || mode == PARSE_ALL) && ad.NonLinearAds != undefined) {
					vad.parseNonLinears(ad);				
				}
				if(ad.CompanionAds != undefined) vad.parseCompanions(ad);					
				vad.parseExtensions(ad);
				if(replacingAdIds()) {
					vad.id = getReplacementAdId(((vad.isNonLinear()) ? "non-linear" : "linear"));
					CONFIG::debugging { doLog("Have replaced the received Ad ID '" + adId + "' with " + vad.id + " (" + adRecordPosition + ")", Debuggable.DEBUG_VAST_TEMPLATE); }
				}
				else vad.id = adId;
				CONFIG::debugging { doLog("Parsing V1.X ad record " + adId + " done", Debuggable.DEBUG_VAST_TEMPLATE); }
				return vad;
			}
			else {
				CONFIG::debugging { doLog("No tags found for Ad " + adId + " - ignoring this entry", Debuggable.DEBUG_VAST_TEMPLATE); }
			}
			return null;
		}

		/* POST TEMPLATE LOADING PROCESSING ***************************************************/

		protected function fireWrapperErrorUrls(errorCode:String):void {
		}
		
		public function onTemplateLoaded(template:AdServerTemplate):void {
			CONFIG::debugging { doLog(_uid + " has been notified that a template (" + template.uid + ") has loaded.", Debuggable.DEBUG_VAST_TEMPLATE); }
			if(template is WrappedVideoAdServingTemplateV2) {
				merge(template, true, true);
			}
			else merge(template);
			signalTemplateLoaded(template.uid);
		}
		
		public function onTemplateLoadError(event:Event):void {	
			fireWrapperErrorUrls("300");
			signalTemplateLoadError(uid, event);
		}

		public function onTemplateLoadTimeout(event:Event):void {	
			fireWrapperErrorUrls("301");
			signalTemplateLoadTimeout(uid, event);
		}
		
		public function onTemplateLoadDeferred(event:Event):void {
			signalTemplateLoadDeferred(uid, event);
		}

		public function onAdCallStarted(request:AdServerRequest):void { 
			if(_listener != null) _listener.onAdCallStarted(request); 
		}

		public function onAdCallFailover(masterRequest:AdServerRequest, failoverRequest:AdServerRequest):void { 
			if(_listener != null) _listener.onAdCallFailover(masterRequest, failoverRequest); 
		}
		
		public function onAdCallComplete(request:AdServerRequest, hasAds:Boolean):void { 
			if(_listener != null) _listener.onAdCallComplete(request, hasAds); 
		}

		/* VAST V2.0 PARSING *****************************************************************/
		
		protected function parseAdSpecs_V2_V3(ads:XMLList):void {
			CONFIG::debugging { doLog("Parsing a VAST " + _vastVersion + " response - " + ads.length() + " ads in the template...", Debuggable.DEBUG_VAST_TEMPLATE); }
			for(var i:int=0; i < ads.length(); i++) {
				var adIds:XMLList = ads[i].attribute("id");
				if(ads[i].children().length() == 1) {
					parseAdResponse_V2_V3(i, adIds[0], ads[i]);
				}
				else {
					CONFIG::debugging { doLog("No InLine tag found for Ad - " + adIds[0] + " - ignoring this entry", Debuggable.DEBUG_VAST_TEMPLATE); }
				}	
			}
			CONFIG::debugging { doLog("Parsing DONE", Debuggable.DEBUG_VAST_TEMPLATE); }
		}
		
		private function parseAdResponse_V2_V3(adRecordPosition:int, templateAdId:String, adResponse:XML):void {
			if(adResponse != null) {
				CONFIG::debugging { doLog("Parsing ad record at position " + adRecordPosition + " with ID '" + templateAdId + "'", Debuggable.DEBUG_VAST_TEMPLATE); }
				if(adResponse.InLine != undefined) {
					parseInlineAd_V2_V3(adRecordPosition, templateAdId, adResponse.children()[0]);
				}
				else if(adResponse.Wrapper != undefined) {
					parseWrappedAd_V2_V3(adRecordPosition, templateAdId, adResponse.children()[0]);
				} 
				else {
					CONFIG::debugging { doLog("Top level Ad tag does not seem to be either InLine or Wrapper - ignoring this part of the response", Debuggable.DEBUG_VAST_TEMPLATE); }
				}
			}
		}

        private function parseWrappedAd_V2_V3(adRecordPosition:int, adId:String, wrapperXML:XML):WrappedVideoAdServingTemplateV2 {
			CONFIG::debugging { doLog("Parsing VAST " + _vastVersion + " XML Wrapper Ad record at position " + adRecordPosition + " with ID " + adId, Debuggable.DEBUG_VAST_TEMPLATE); }
			if(wrapperXML.children().length() > 0) {
				return new WrappedVideoAdServingTemplateV2(adRecordPosition, vastVersion, adId, wrapperXML, this);
			}
			else {
				CONFIG::debugging { doLog("No tags found for Wrapper " + adId + " - ignoring this entry", Debuggable.DEBUG_VAST_TEMPLATE); }
			}
        	return null;
        }	

        private function parseImpressions_V2_V3(ad:XML):Array {
			var result:Array = new Array();
			if(ad.Impression != null) {
				var impressionList:XMLList = ad.Impression;
				CONFIG::debugging { doLog("Parsing VAST " + _vastVersion + " impression tags - " + impressionList.length() + " impressions specified...", Debuggable.DEBUG_VAST_TEMPLATE); }
				for each (var impressionElement:XML in impressionList) {
					result.push(new Impression(impressionElement.@id, impressionElement.text()));
				}
			}
			return result;      	
        }
        
        private function parseExtensions_V2_V3(ad:XML):Object {
			var extensions:Array = new Array();
			var impressions:Array = new Array();
			if(ad.Extensions != null) {
				var extensionList:XMLList = ad.Extensions.children();
				CONFIG::debugging { doLog("Parsing VAST " + _vastVersion + " extension tags - " + extensionList.length() + " extensions specified...", Debuggable.DEBUG_VAST_TEMPLATE); }
				for each (var extensionElement:XML in extensionList) {
					if(extensionElement.@type == "ad_playtype") {
						CONFIG::debugging { doLog("Detected an adtech 'playtype' extension - adding it to the impression list", Debuggable.DEBUG_VAST_TEMPLATE); }
						impressions.push(new Impression("ad_playtype", extensionElement.children().toXMLString()));
					}
					else {
						var extension:Object = new Object();
						extension.label = (extensionElement.@type != null) ? new String(extensionElement.@type) : "undefined";
						extension.text = extensionElement.children().toXMLString();
						extensions.push(extension);
					}
				}
			}
			var result:Object = {
				extensions: extensions,
				impressions: impressions
			};
			return result; 
        }

		protected function createVideoAd_V2_V3(defaultAdId:String, ad:XML, creativeId:String, sequenceId:String, type:String, inlineAdId:String, containerAdId:String):VideoAdV2 {
			var vad:VideoAdV2;
			if(_vastVersion >= 3.0) {
				vad = new VideoAdV3();
			}
			else {
			    vad = new VideoAdV2();	
			}
			if(replacingAdIds()) {
				vad.id = getReplacementAdId(type);
			}
			else vad.id = defaultAdId;
			vad.containerAdId = containerAdId;
			vad.inlineAdId = inlineAdId;
			vad.adId = defaultAdId;
			vad.creativeId = creativeId;
			vad.sequenceId = sequenceId;
			vad.adSystem = ad.AdSystem;
			vad.adTitle = ad.AdTitle;
			vad.description = ad.Description;
			vad.survey = ad.Survey;
			if(ad.Error != null) {
				vad.addErrorUrl(ad.Error);
				CONFIG::debugging { doLog("Error URL recorded - " + ad.Error, Debuggable.DEBUG_VAST_TEMPLATE); }
			}
			CONFIG::callbacks {
				if(_listener != null) {
					vad.setCanFireAPICalls(_listener.canFireAPICalls());
					vad.setCanFireEventAPICalls(_listener.canFireEventAPICalls());
					vad.useV2APICalls = _listener.useV2APICalls;
					vad.jsCallbackScopingPrefix = _listener.jsCallbackScopingPrefix;
				}
			}
			CONFIG::debugging { doLog("Created new VideoAdV2(" + type + ", " + vad.uid + ") adId: '" + vad.adId + "', creativeID: '" + creativeId + "', sequenceID: '" + sequenceId + "' - internal ID set as '" + vad.id + "', containerAdID: '" + vad.containerAdId + "', parent Template: " + _uid, Debuggable.DEBUG_VAST_TEMPLATE); }
			return vad;
		}
		
		private function cloneCompanions(companions:Array, videoAd:VideoAd):Array {
			var companionsCopy:Array = new Array();
			var companionCopy:CompanionAd;
			for each(var companion:CompanionAd in companions) {
				companionCopy = companion.clone();
				companionCopy.parentAdContainer = videoAd;
				companionsCopy.push(companionCopy);
			}
			return companionsCopy;			
		}
		
		private function joinCompanions(companionSet1:Array, companionSet2:Array):Array {
			if(companionSet1 == null) companionSet1 = new Array();
			if(companionSet2 == null) return companionSet1;
			return companionSet1.concat(companionSet2);
		}
		
		protected function parseInlineAd_V2_V3(adRecordPosition:int, templateAdId:String, ad:XML):Array {
			var impressions:Array = new Array();
			var extensions:Array = new Array();
			var internalInlineAdID:String = ObjectUtils.createUID();
			CONFIG::debugging { 
				doLog("Parsing VAST " + _vastVersion + " Ad record at position " + adRecordPosition + " with Template AdID '" + templateAdId + "' - assigned internal inline ad id '" + internalInlineAdID + "'", Debuggable.DEBUG_VAST_TEMPLATE); 
			}
			if(ad.children().length() > 0) {
				var extensionSet:Object = parseExtensions_V2_V3(ad);
				extensions = extensionSet.extensions;
				impressions = parseImpressions_V2_V3(ad);
				if(extensionSet.impressions.length > 0) {
					// we have some extensions that have to fire as impressions, so add them to the impression set
					impressions = impressions.concat(extensionSet.impressions);
				}
				var creativesList:XMLList = ad.Creatives;
				if(creativesList.length() > 0) {
					CONFIG::debugging { doLog("Parsing VAST " + _vastVersion + " creatives blocks - " + creativesList.length() + " block of creatives defined ...", Debuggable.DEBUG_VAST_TEMPLATE); }
					var attachableCompanions:Array = new Array();
					for(var k:int=0; k < creativesList.length(); k++) {
						var creativeElements:XMLList = creativesList[k].Creative;	
						if(creativeElements != null) {
							CONFIG::debugging { doLog("Parsing VAST " + _vastVersion + " creative block (" + k + ") - this block has " + creativeElements.length() + " elements ...", Debuggable.DEBUG_VAST_TEMPLATE); }
							var counter:int = 1;
							var linears:Array = new Array();
							var nonLinears:Array = new Array();
							var companions:Array = new Array();
							for each (var creative:XML in creativeElements) {
								var adId:String = creative.attribute("AdID");
								var creativeId:String = creative.attribute("id");
								var sequenceId:String = creative.attribute("sequence");
								CONFIG::debugging { doLog("Parsing VAST " + _vastVersion + " creative (" + counter + ") creativeID '" + creativeId + "' SequenceID '" + sequenceId + "' ...", Debuggable.DEBUG_VAST_TEMPLATE); }
								resetCompanionIndexCounters();
								linears = parseLinearAds_V2_V3(creative.Linear);
								nonLinears = parseNonLinearAds_V2_V3(creative.NonLinearAds);
								companions = parseCompanionAds_V2_V3(creative.CompanionAds);

								// Ok, now let's create the set of VideoAds that correlate to the linear, non-linear and companion creatives specified
								
								var vad:VideoAd = null;
								for each(var linear:LinearVideoAd in linears) {
									vad = createVideoAd_V2_V3(adId, ad, creativeId, sequenceId, VideoAd.AD_TYPE_LINEAR, internalInlineAdID, templateAdId);
									if(impressions.length > 0) vad.impressions = impressions;
									if(extensions.length > 0) vad.extensions = extensions;
									vad.linearVideoAd = linear;
									if(companions.length > 0) {
										vad.companionAds = cloneCompanions(companions, vad);
										CONFIG::debugging { doLog("Have attached " + companions.length + " companions to linear ad '" + vad.id + "'", Debuggable.DEBUG_VAST_TEMPLATE); }
									}
									addVideoAd(vad);
								}	

								if(nonLinears.length > 0) {
									vad = createVideoAd_V2_V3(adId, ad, creativeId, sequenceId, VideoAd.AD_TYPE_NON_LINEAR, internalInlineAdID, templateAdId);
									if(impressions.length > 0) vad.impressions = impressions;
									if(extensions.length > 0) vad.extensions = extensions;
									vad.nonLinearVideoAds = nonLinears;
									if(companions.length > 0) {
										vad.companionAds = cloneCompanions(companions, vad);
										CONFIG::debugging { doLog("Have attached " + companions.length + " companions to non-linear ad '" + vad.id + "'", Debuggable.DEBUG_VAST_TEMPLATE); }
									}
									addVideoAd(vad);
								}
															
								if((linears.length == 0 && nonLinears.length == 0 && companions.length > 0) || false) { // change false in the future to ads.companions.scheduleCompanionsSeparately
									vad = createVideoAd_V2_V3(adId, ad, creativeId, sequenceId, VideoAd.AD_TYPE_COMPANION, internalInlineAdID, templateAdId);
									if(impressions.length > 0) vad.impressions = impressions;
									if(extensions.length > 0) vad.extensions = extensions;
									vad.companionAds = companions;
									addVideoAd(vad);
									attachableCompanions.push(
										{ 
											"adId": adId,
											"creativeId": creativeId,
											"sequenceId": sequenceId,
											"companions": companions
										} 
									);
								}

								if(linears.length == 0 && nonLinears.length == 0 && companions.length == 0 && (impressions.length > 0 || ad.Error != null)) {
									// we have impressions or error URLs to fire but no linear or non-linear ads, so record the impressions against an
									// empty video ad in case they need to be forcibly fired
									
									vad = createVideoAd_V2_V3(adId, ad, creativeId, sequenceId, VideoAd.AD_TYPE_LINEAR, internalInlineAdID, templateAdId);
									vad.impressions = impressions;
									addVideoAd(vad);
								}

								++counter;
							}								
						}
					}					

					// COMPANION MATCHING: Ok, go back over the ad list and match up companions as needed - two pass process
					
					// PASS 1 - Match companions that don't have a sequence or creative ID specified - basically attach these ownerless 
					// companions to every video ad that doesn't already have companions attached.
					
					if(attachableCompanions.length > 0) {
						var attachableCompanion:Object;
						var videoAd:VideoAd;
						CONFIG::debugging { doLog("Companion matching PASS 1 - attach ownerless companions (" + attachableCompanions.length + ") to creatives within video ad that don't already have companions", Debuggable.DEBUG_VAST_TEMPLATE); }
						for each(attachableCompanion in attachableCompanions) {
							for each(videoAd in _ads) {
								if(videoAd.belongsToInlineAd(internalInlineAdID)) {
									if(videoAd.adType != VideoAd.AD_TYPE_COMPANION && !videoAd.hasCompanionAds()) {
										if(StringUtils.isEmpty(attachableCompanion.creativeId) && StringUtils.isEmpty(attachableCompanion.sequenceId)) {
		  									CONFIG::debugging { doLog("Attaching companions PASS 1 (sequence: '" + attachableCompanion.sequenceId + "', creativeID: '" + attachableCompanion.creativeId + "', AdID: '" + attachableCompanion.adId + "') to video ad '" + videoAd.adType + ": " + videoAd.id + "'", Debuggable.DEBUG_VAST_TEMPLATE); }
											videoAd.companionAds = joinCompanions(videoAd.companionAds, cloneCompanions(attachableCompanion.companions, videoAd)); 
											CONFIG::debugging { doLog("Updated companion count is now " + videoAd.companionCount(), Debuggable.DEBUG_VAST_TEMPLATE); }
										}	 								
									}								
								}
							}
						}

						// PASS 2 - Now match up companions that do have a sequence or creative ID specified
						// overwriting the blanket coverage of PASS 1
	
						CONFIG::debugging { doLog("Companion matching PASS 2 - match up companions (" + attachableCompanions.length + ") based on sequence or creative ID", Debuggable.DEBUG_VAST_TEMPLATE); }
						for each(attachableCompanion in attachableCompanions) {
							for each(videoAd in _ads) {
								if(videoAd.belongsToInlineAd(internalInlineAdID)) {
									if(videoAd.adType != VideoAd.AD_TYPE_COMPANION) {
										if((videoAd.sequenceId != null && (videoAd.sequenceId == attachableCompanion.sequenceId)) ||
									   	   (videoAd.creativeId != null && (videoAd.creativeId == attachableCompanion.creativeId))) { 
		  									   CONFIG::debugging { doLog("Attaching companions PASS 2 (sequence: '" + attachableCompanion.sequenceId + "', creativeID: '" + attachableCompanion.creativeId + "', AdID: '" + attachableCompanion.adId + "') to video ad '" + videoAd.adType + ": " + videoAd.id + "'", Debuggable.DEBUG_VAST_TEMPLATE); }
											   videoAd.companionAds = joinCompanions(videoAd.companionAds, cloneCompanions(attachableCompanion.companions, videoAd)); 
											   CONFIG::debugging { doLog("Updated companion count is now " + videoAd.companionCount(), Debuggable.DEBUG_VAST_TEMPLATE); }
										}	
									}
								}
							}
						}
					}
				}
				else {
					// While we may not have any creatives, check if we have any impressions recorded or error URLs - if so, record this Video Ad

					if(impressions.length > 0 || ad.Error != null) {
						vad = createVideoAd_V2_V3(null, ad, null, null, VideoAd.AD_TYPE_LINEAR, internalInlineAdID, templateAdId);
						vad.impressions = impressions;
						addVideoAd(vad);
					}
				}
			}
			else {
				CONFIG::debugging { doLog("No tags found for Ad '" + adId + "' - ignoring this entry", Debuggable.DEBUG_VAST_TEMPLATE); }
			}
			
			return impressions;
		}

		protected function resetCompanionIndexCounters():void {
			_indexCounters = new Array();
		}
		
		protected function createIndex(width:int, height:int):int {
			for(var i:int = 0; i < _indexCounters.length; i++) {
				if(_indexCounters[i].width == width && _indexCounters[i].height == height) {
					_indexCounters[i].index = _indexCounters[i].index + 1;
					return _indexCounters[i].index;
				}
			}
			_indexCounters.push({ width: width, height: height, index: 0});
			return 0;
		}
		
		protected function parseLinearAds_V2_V3(linearAds:XMLList):Array {
			var result:Array = new Array();
			if(linearAds.length() > 0) {
				CONFIG::debugging { doLog("Parsing VAST " + _vastVersion + " Linear Ad tags - " + linearAds.length() + " ads specified...", Debuggable.DEBUG_VAST_TEMPLATE); }
  				for each(var ad:XML in linearAds) {
					var linearVideoAd:LinearVideoAd = new LinearVideoAd();
					var adParameters:String = null;
					linearVideoAd.index = linearAds.length();
					if(Timestamp.validate(ad.Duration)) {
						linearVideoAd.duration = ad.Duration;
					}
					else {
						linearVideoAd.duration = Timestamp.secondsStringToTimestamp(ad.Duration);
						CONFIG::debugging { doLog("Duration has been specified in non-compliant manner (hh:mm:ss) - assuming seconds - converted to: " + linearVideoAd.duration, Debuggable.DEBUG_VAST_TEMPLATE); }
					}
					CONFIG::callbacks {
						if(_listener != null) {
							linearVideoAd.canFireAPICalls = _listener.canFireAPICalls();
							linearVideoAd.canFireEventAPICalls = _listener.canFireEventAPICalls();
							linearVideoAd.useV2APICalls = _listener.useV2APICalls;
							linearVideoAd.jsCallbackScopingPrefix = _listener.jsCallbackScopingPrefix;
						}
					}
					if(ad.AdParameters != undefined) {
						adParameters = ad.AdParameters;
						CONFIG::debugging { doLog("Have recorded AdParameters for this Linear video ad", Debuggable.DEBUG_VAST_TEMPLATE); }
					}
					else adParameters = null;
					if(ad.VideoClicks != undefined) {
						var clickList:XMLList;
						if(ad.VideoClicks.ClickThrough != undefined) {
							CONFIG::debugging { doLog("Parsing VAST " + _vastVersion + " Linear VideoClicks.ClickThrough tags...", Debuggable.DEBUG_VAST_TEMPLATE); }
							for each (var clickThroughElement:XML in ad.VideoClicks.ClickThrough) {
								if(!StringUtils.isEmpty(clickThroughElement.text())) {
									linearVideoAd.addClickThrough(new NetworkResource(clickThroughElement.@id, clickThroughElement.text()));
								}
							}
							CONFIG::debugging { doLog(linearVideoAd.clickThroughCount() + " Linear ClickThroughs recorded", Debuggable.DEBUG_VAST_TEMPLATE); }       	
						}
						if(ad.VideoClicks.ClickTracking != undefined) {
							CONFIG::debugging { doLog("Parsing VAST " + _vastVersion + " Linear VideoClicks.ClickTracking tags...", Debuggable.DEBUG_VAST_TEMPLATE); }
							for each (var clickTrackingElement:XML in ad.VideoClicks.ClickTracking) {
								if(!StringUtils.isEmpty(clickTrackingElement.text())) {
									linearVideoAd.addClickTrack(new NetworkResource(clickTrackingElement.@id, clickTrackingElement.text()));
								}
							}
							CONFIG::debugging { doLog(linearVideoAd.clickTrackingCount() + " Linear ClickTracking events recorded", Debuggable.DEBUG_VAST_TEMPLATE); }       	
						}
						if(ad.VideoClicks.CustomClick != undefined) {
							CONFIG::debugging { doLog("Parsing VAST " + _vastVersion + " Linear VideoClicks.CustomClick tags...", Debuggable.DEBUG_VAST_TEMPLATE); }
							for each (var customClickElement:XML in ad.VideoClicks.CustomClick) {
								if(!StringUtils.isEmpty(customClickElement.text())) {
									linearVideoAd.addCustomClick(new NetworkResource(customClickElement.@id, customClickElement.text()));
								}
							}
							CONFIG::debugging { doLog(linearVideoAd.customClickCount() + " Linear CustomClicks recorded", Debuggable.DEBUG_VAST_TEMPLATE); }      	
						}				
					}
					if(ad.MediaFiles != undefined) {
						CONFIG::debugging { doLog("Parsing VAST " + _vastVersion + " Linear MediaFiles tags...", Debuggable.DEBUG_VAST_TEMPLATE); }
						var mediaFiles:XMLList = ad.MediaFiles.children();
						CONFIG::debugging { doLog(mediaFiles.length() + " Linear media files detected", Debuggable.DEBUG_VAST_TEMPLATE); }
						var mediaFile:MediaFile;
						for(var i:int = 0; i < mediaFiles.length(); i++) {
							mediaFile = null;
							var mediaFileXML:XML = mediaFiles[i];
							if(StringUtils.isEmpty(mediaFileXML.text()) == false) {
								if(isAcceptableLinearAdMediaFileMimeType(mediaFileXML.@type)) {
									if(StringUtils.matchesIgnoreCase(mediaFileXML.@apiFramework, "VPAID")) {
										if(mediaFileXML.@type != undefined) {
											// it must be a SWF mime file to be VPAID
											var mType:String = mediaFileXML.@type;
											if(StringUtils.matchesIgnoreCase(mType, "APPLICATION/X-SHOCKWAVE-FLASH") || StringUtils.matchesIgnoreCase(mType, "SWF")) {
												mediaFile = new VPAIDMediaFile();
								       		}
										}
										else {
											// if no "type" declared, then look at the file extension - if it's a stream it can't be VPAID
											var file:NetworkResource = new NetworkResource(mediaFileXML.@id, mediaFileXML.text());
											if(!file.isStream()) {
												mediaFile = new VPAIDMediaFile();										
											}
										}
									}
									if(mediaFile == null) mediaFile = new MediaFile();
									mediaFile.id = mediaFileXML.@id; 
									mediaFile.bandwidth = mediaFileXML.@bandwidth; 
									mediaFile.delivery = mediaFileXML.@delivery; 
									mediaFile.mimeType = mediaFileXML.@type; 
									mediaFile.bitRate = int(mediaFileXML.@bitrate); 
									mediaFile.width = mediaFileXML.@width; 
									mediaFile.height = mediaFileXML.@height; 
									mediaFile.scale = mediaFileXML.@scalable; 
									mediaFile.maintainAspectRatio = mediaFileXML.@maintainAspectRatio; 
									mediaFile.apiFramework = mediaFileXML.@apiFramework;
									if(adParameters != null) mediaFile.adParameters = adParameters;
									mediaFile.url = new AdNetworkResource(mediaFileXML.@id, mediaFileXML.text(), mediaFileXML.@type);
									mediaFile.parentAd = linearVideoAd;
									linearVideoAd.addMediaFile(mediaFile);
								}
								else {
									CONFIG::debugging { doLog("Excluding '" + mediaFileXML.text() + "' as mime type '" +  mediaFileXML.@type + "' is to be filtered out", Debuggable.DEBUG_VAST_TEMPLATE); }
								}
							}
  							else {
  								CONFIG::debugging { doLog("Excluding MediaFile '" + mediaFileXML.text() + "' because it is an empty declaration", Debuggable.DEBUG_VAST_TEMPLATE); }
  							}
						}
						CONFIG::debugging { doLog(linearVideoAd.mediaFileCount() + " mediaFiles added", Debuggable.DEBUG_VAST_TEMPLATE);	}	
					}
					if(ad.TrackingEvents != undefined && ad.TrackingEvents.children() != null) {
						CONFIG::debugging { doLog("Parsing VAST " + _vastVersion + " Linear TrackingEvent tags...", Debuggable.DEBUG_VAST_TEMPLATE); }
						var trackingEvents:XMLList = ad.TrackingEvents.children();
						for(var j:int = 0; j < trackingEvents.length(); j++) {
							var trackingEvent:TrackingEvent;
				        	if(trackingEvents[j].@event == TrackingEvent.EVENT_PROGRESS) {
								trackingEvent = new ProgressTrackingEvent(trackingEvents[j].@offset);    		
				        	}
							else trackingEvent = new TrackingEvent(trackingEvents[j].@event);
							trackingEvent.addURL(new NetworkResource(trackingEvents[j].@event, trackingEvents[j].text()));
							linearVideoAd.addTrackingEvent(trackingEvent);				
						}
						CONFIG::debugging { doLog(linearVideoAd.trackingEvents.length + " Linear tracking events recorded", Debuggable.DEBUG_VAST_TEMPLATE); }
					} 
					result.push(linearVideoAd);
  				}
			}
			return result;	
		}
		
		protected function parseNonLinearAds_V2_V3(nonLinearAds:XMLList):Array {
			var result:Array = new Array();
			if(nonLinearAds.length() > 0) {
				CONFIG::debugging { doLog("Parsing VAST " + _vastVersion + " NonLinearAd tags - " + nonLinearAds.length() + " ads specified...", Debuggable.DEBUG_VAST_TEMPLATE); }
  				for each(var ad:XML in nonLinearAds) {
					var nonLinearAds:XMLList = ad.children();
					var i:int=0;
					var trackingEventsHolder:Array = null;
					var adParameters:String = null;
					for(i = 0; i < nonLinearAds.length(); i++) {
						if(nonLinearAds[i].name() == "NonLinear") {
							var nonLinearAdXML:XML = nonLinearAds[i];
							var nonLinearAd:NonLinearVideoAd = null;
							var nonLinearAdID:String = ((nonLinearAdXML.@id != undefined) ? nonLinearAdXML.@id : "" + i);
							
							if(nonLinearAdXML.StaticResource != undefined && nonLinearAdXML.StaticResource != null) {
								if(nonLinearAdXML.StaticResource.@creativeType != undefined && nonLinearAdXML.StaticResource.@creativeType != null) {
									switch(nonLinearAdXML.StaticResource.@creativeType.toUpperCase()) {
										case "IMAGE/JPEG":
										case "JPEG":
										case "IMAGE/GIF":
										case "GIF":
										case "IMAGE/PNG":
										case "PNG":
											nonLinearAd = new NonLinearImageAd();
											break;
										case "APPLICATION/X-SHOCKWAVE-FLASH":
										case "SWF":
											if(StringUtils.matchesIgnoreCase(nonLinearAdXML.@apiFramework, "VPAID")) {
											    CONFIG::debugging { doLog("Creating VPAIDNonLinearAd()", Debuggable.DEBUG_VAST_TEMPLATE); }
												nonLinearAd = new VPAIDNonLinearAd();																		
											}
											else {
											    CONFIG::debugging { doLog("Creating NonLinearFlashAd()", Debuggable.DEBUG_VAST_TEMPLATE); }
												nonLinearAd = new NonLinearFlashAd();								
											}
											break;
										case "SCRIPT":
										case "JAVASCRIPT":
										case "TEXT/JAVASCRIPT":
										case "TEXT/SCRIPT":
										    nonLinearAd = new NonLinearScriptAd();
										    break;
										default:
											nonLinearAd = new NonLinearVideoAd();
									}
									
									nonLinearAd.resourceType = "static"; 
									nonLinearAd.creativeType = nonLinearAdXML.StaticResource.@creativeType; 
									CONFIG::debugging { doLog("Parsing static NonLinear Ad (" + nonLinearAdID + ") of creative type " + nonLinearAd.creativeType + " ...", Debuggable.DEBUG_VAST_TEMPLATE); }
								}
								else nonLinearAd = new NonLinearVideoAd();					
							}
							else if(nonLinearAdXML.HTMLResource != undefined && nonLinearAdXML.HTMLResource != null) {
								// have a look at the code block - if it starts with a <script> tag, then assume it's Javascript and create a
								// NonLinearScriptAd() instead of the NonLinearHtmlAd()
								if(StringUtils.beginsWith(nonLinearAdXML.HTMLResource.text(), "<script ")) {
								    nonLinearAd = new NonLinearScriptAd();
									CONFIG::debugging { doLog("Parsing HTMLResource NonLinear Ad (" + nonLinearAdID + ") that is a script ...", Debuggable.DEBUG_VAST_TEMPLATE); }
								}
								else {
									CONFIG::debugging { doLog("Parsing HTMLResource NonLinear Ad (" + nonLinearAdID + ") that is a HTML code block ...", Debuggable.DEBUG_VAST_TEMPLATE); }
									nonLinearAd = new NonLinearHtmlAd();					
									nonLinearAd.resourceType = "static"; 
									nonLinearAd.creativeType = "html";
								}
							}
							else if(nonLinearAdXML.IFrameResource != undefined) {
								CONFIG::debugging { doLog("Parsing IFrameResource NonLinear Ad (" + nonLinearAdID + ") ...", Debuggable.DEBUG_VAST_TEMPLATE); }
								nonLinearAd = new NonLinearIFrameAd();
								nonLinearAd.resourceType = "iframe";
								nonLinearAd.creativeType = "html";
							}
							else {
								CONFIG::debugging { doLog("No resource type declared for non-linear ad '" + nonLinearAdID + "' - but that's ok if this ad is wrapped", Debuggable.DEBUG_VAST_TEMPLATE); }
								nonLinearAd = new NonLinearVideoAd();
							}
							
							nonLinearAd.index = i;
							nonLinearAd.id = nonLinearAdID;
							nonLinearAd.width = nonLinearAdXML.@width;
							nonLinearAd.height = nonLinearAdXML.@height; 
							nonLinearAd.apiFramework = nonLinearAdXML.@apiFramework; 
							if(nonLinearAdXML.@expandedWidth != undefined) nonLinearAd.expandedWidth = nonLinearAdXML.@expandedWidth; 
							if(nonLinearAdXML.@expandedHeight != undefined) nonLinearAd.expandedHeight = nonLinearAdXML.@expandedHeight;
							nonLinearAd.scale = nonLinearAdXML.@scalable; 
							nonLinearAd.maintainAspectRatio = nonLinearAdXML.@maintainAspectRatio;
							if(nonLinearAdXML.AdParameters != undefined) {
								// Added to support the fact that the VAST 2.0.1 XSD allows AdParameters within a NonLinearAd block but the spec does not
								CONFIG::debugging { doLog("Nested AdParameters are recorded for this non-linear ad", Debuggable.DEBUG_VAST_TEMPLATE); }
								nonLinearAd.adParameters = nonLinearAdXML.AdParameters;
							} 
							CONFIG::callbacks {
								if(_listener != null) {
									nonLinearAd.canFireAPICalls = _listener.canFireAPICalls();
									nonLinearAd.canFireEventAPICalls = _listener.canFireEventAPICalls();
									nonLinearAd.useV2APICalls = _listener.useV2APICalls;
									nonLinearAd.jsCallbackScopingPrefix = _listener.jsCallbackScopingPrefix;
								}
							}
							if(nonLinearAdXML.@minSuggestedDuration != undefined) {
								// check to see if this is a timestamp format, or just seconds
								if(Timestamp.validate(nonLinearAdXML.@minSuggestedDuration)) {
									nonLinearAd.recommendedMinDuration = Timestamp.timestampToSecondsString(nonLinearAdXML.@minSuggestedDuration);
									CONFIG::debugging { doLog("MinSuggestedDuration converted from '" + nonLinearAdXML.@minSuggestedDuration + "' to '" + nonLinearAd.recommendedMinDuration + "' seconds", Debuggable.DEBUG_VAST_TEMPLATE); }
								}
								else nonLinearAd.recommendedMinDuration = nonLinearAdXML.@minSuggestedDuration;
							}
		
							if(nonLinearAd is NonLinearIFrameAd) {
								if(nonLinearAdXML.IFrameResource != undefined) {
									// It's a URI to the iFrame
									nonLinearAd.url = new NetworkResource(null, nonLinearAdXML.IFrameResource.text());	
								}
							}
							if(nonLinearAd is NonLinearHtmlAd) {
								if(nonLinearAdXML.HTMLResource != undefined) {
									// It's a HTML codeblock
									nonLinearAd.codeBlock = nonLinearAdXML.HTMLResource.text();							
								}
							}
							if(nonLinearAd is NonLinearScriptAd) {
								if(nonLinearAdXML.HTMLResource != undefined) {
									nonLinearAd.codeBlock = nonLinearAdXML.HTMLResource.text();
								}
								else if(nonLinearAdXML.StaticResource != undefined) {
									nonLinearAd.url = new NetworkResource(null, nonLinearAdXML.StaticResource.text());						
								}
							}
							else {
								if(nonLinearAdXML.StaticResource != undefined) {
									// It's a URI to the static resource file
									nonLinearAd.url = new NetworkResource(null, nonLinearAdXML.StaticResource.text());						
								}
							}
		
							if(nonLinearAdXML.NonLinearClickThrough != undefined) {
								for each (var nonLinearClickThroughElement:XML in nonLinearAdXML.NonLinearClickThrough) {
									if(!StringUtils.isEmpty(nonLinearClickThroughElement.text())) {
										nonLinearAd.addClickThrough(new NetworkResource(null, nonLinearClickThroughElement.text()));
									}
								}
								CONFIG::debugging { doLog(nonLinearAd.clickThroughCount() + " NonLinear ClickThroughs recorded", Debuggable.DEBUG_VAST_TEMPLATE); }      	
							}
							result.push(nonLinearAd);
						}
						else if(nonLinearAds[i].name() == "TrackingEvents") {
							// put the tracking events into holding storage so they can be added to each non-linear ad 
							// after the full set has been parsed
							CONFIG::debugging { doLog("Parsing VAST " + _vastVersion + " Non-Linear TrackingEvent tags...", Debuggable.DEBUG_VAST_TEMPLATE); }
							var trackingEvents:XMLList = nonLinearAds[i].children();
							CONFIG::debugging { doLog(trackingEvents.length() + " Non-Linear tracking events detected", Debuggable.DEBUG_VAST_TEMPLATE); }
							trackingEventsHolder = new Array();
							for(var l:int = 0; l < trackingEvents.length(); l++) {
								var trackingEventXML:XML = trackingEvents[l];
								var trackingEvent:TrackingEvent = new TrackingEvent(trackingEventXML.@event);
								trackingEvent.addURL(new NetworkResource(trackingEvents[l].@event, trackingEvents[l].text()));
								trackingEventsHolder.push(trackingEvent);				
							}					
						}
						else if(nonLinearAds[i].name() == "AdParameters") {
							CONFIG::debugging { doLog("AdParameters are recorded for this non-linear ad", Debuggable.DEBUG_VAST_TEMPLATE); }
							adParameters = nonLinearAds[i];
						}
						else {
							CONFIG::debugging { doLog(nonLinearAds[i].name() + " tags currently not supported for non-linear ads", Debuggable.DEBUG_VAST_TEMPLATE); }
						}
					}

					// now, set the tracking events on each recorded non-linear ad - if there have been any tracking events specified
					if(trackingEventsHolder != null || adParameters != null) {
						if(trackingEventsHolder != null) {
							CONFIG::debugging { doLog("Attaching " + trackingEventsHolder.length + " NonLinear tracking events to " + result.length + " non-linear ads...", Debuggable.DEBUG_VAST_TEMPLATE); }
						}
						if(adParameters != null) {
							CONFIG::debugging { doLog("Attaching AdParameters to " + result.length + " non-linear ads...", Debuggable.DEBUG_VAST_TEMPLATE);	}					
						}
						for each(var nlAd:NonLinearVideoAd in result) {
							if(trackingEventsHolder != null) nlAd.trackingEvents = clone(trackingEventsHolder);
							if(adParameters != null) nlAd.adParameters = adParameters;
						}
					}					
  				}
  			}
			return result;
		}
		
        protected function parseCompanionAds_V2_V3(companionAdsXML:XMLList):Array {
        	var result:Array = new Array();
        	if(companionAdsXML.length() > 0) {
				CONFIG::debugging { doLog("Parsing VAST " + _vastVersion + " CompanionAd tags - " + companionAdsXML.children().length() + " companions specified", Debuggable.DEBUG_VAST_TEMPLATE); }
  				for each(var companionAdXML:XML in companionAdsXML.children()) {
					var companionAd:CompanionAd = new CompanionAd();
					companionAd.isVAST2 = true;
					companionAd.id = companionAdXML.@id;
					companionAd.width = companionAdXML.@width;
					companionAd.height = companionAdXML.@height; 
					companionAd.index = createIndex(companionAd.width, companionAd.height);
					if(companionAdXML.StaticResource != undefined) {
						companionAd.creativeType = companionAdXML.StaticResource.@creativeType;
						companionAd.resourceType = "STATIC";
						companionAd.url = new NetworkResource(null, companionAdXML.StaticResource.text());
						CONFIG::debugging { doLog("Static companion ad (" + companionAd.uid + ") [" + companionAd.width + "," + companionAd.height + "] - creativeType: " + companionAd.creativeType + " - " + companionAdXML.StaticResource.text(), Debuggable.DEBUG_VAST_TEMPLATE); }
					}
					else if(companionAdXML.IFrameResource != undefined) {
						companionAd.creativeType = "STATIC";
						companionAd.resourceType = "IFRAME";
						companionAd.url = new NetworkResource(null, companionAdXML.IFrameResource.text());
						CONFIG::debugging { doLog("iFrame companion ad (" + companionAd.uid + ") [" + companionAd.width + "," + companionAd.height + "] - creativeType: " + companionAd.creativeType + " - " + companionAdXML.IFrameResource.text(), Debuggable.DEBUG_VAST_TEMPLATE); }
					}
					else if(companionAdXML.HTMLResource != undefined) {
						companionAd.creativeType = "TEXT";
						companionAd.resourceType = "HTML";
						companionAd.codeBlock = companionAdXML.HTMLResource.text();
						CONFIG::debugging { doLog("HTML companion ad (" + companionAd.uid + ") [" + companionAd.width + "," + companionAd.height + "] - creativeType: " + companionAd.creativeType + " - " + companionAd.codeBlock, Debuggable.DEBUG_VAST_TEMPLATE); }
					}
					if(companionAdXML.CompanionClickThrough != undefined) {
						CONFIG::debugging { doLog("Parsing VAST " + _vastVersion + " Companion ClickThrough tags...", Debuggable.DEBUG_VAST_TEMPLATE); }
						var caClickList:XMLList = companionAdXML.CompanionClickThrough; 
						CONFIG::debugging { doLog(caClickList.length() + " Companion ClickThroughs detected", Debuggable.DEBUG_VAST_TEMPLATE); }
						var caClickURL:XML;
						for(var j:int = 0; j < caClickList.length(); j++) {
							caClickURL = caClickList[j];
							companionAd.addClickThrough(new NetworkResource(caClickURL.@id, caClickURL.text()));
						}							
					}
					if(companionAdXML.AltText != undefined) companionAd.altText = companionAdXML.AltText.text();
					if(companionAdXML.AdParameters != undefined) {
						companionAd.adParameters = companionAdXML.AdParameters.text();
						CONFIG::debugging { doLog("Companion Ad has adParameters set", Debuggable.DEBUG_VAST_TEMPLATE); }
					}	
					if(companionAdXML.TrackingEvents != undefined) {
						CONFIG::debugging { doLog("Parsing VAST " + _vastVersion + " Companion TrackingEvent tags...", Debuggable.DEBUG_VAST_TEMPLATE); }
						var trackingEvents:XMLList = companionAdXML.TrackingEvents.children();
						CONFIG::debugging { doLog(trackingEvents.length() + " Companion tracking events detected", Debuggable.DEBUG_VAST_TEMPLATE); }
						for(var k:int = 0; k < trackingEvents.length(); k++) {
							var trackingEventXML:XML = trackingEvents[k];
							var trackingEvent:TrackingEvent = new TrackingEvent(trackingEventXML.@event);
							var trackingEventURLs:XMLList = trackingEventXML.children();
							trackingEvent.addURL(new NetworkResource(trackingEvents[k].@event, trackingEvents[k].text()));
							companionAd.addTrackingEvent(trackingEvent);				
						}					
					}
					result.push(companionAd);						
				}
        	}
			return result;	
        }        
				
		/* HELPER METHODS ********************************************************************/

		protected function clone(source:Object):* {
			if(source != null) {
				if(source is Array) {
					var result:Array = new Array();
					for each(var item:* in source) {
						result.push(item.clone());
					}	
					return result;
				}
				else {
				    var myBA:ByteArray = new ByteArray();
				    myBA.writeObject(source);
				    myBA.position = 0;
				    return(myBA.readObject());				
				}
			}
			return null;
		}        

		public function getFirstAd():VideoAd {
			if(_ads != null) {
				if(_ads.length > 0) {
					return _ads[0];
				}
			}	
			return null;
		}
		
		public function toString():String {
			if(hasAds()) {
				var result:String = "[";
				for(var i:int = 0; i < _ads.length; i++) {
					result += _ads[i].toString() + ",";
				}
				return result + "]";				
			}
			return "VideoAdServingTemplate.toString(): No ads to print out";
		}
	}
}
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
	import flash.events.*;
	
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.util.StringUtils;
	import org.openvideoads.vast.server.config.AdServerConfig;
	import org.openvideoads.vast.server.request.AdServerRequest;
	import org.openvideoads.vast.server.request.wrapped.WrappedAdServerRequest;
	import org.openvideoads.vast.server.response.AdServerTemplate;
	
	/**
	 * @author Paul Schulz
	 */
	public class WrappedVideoAdServingTemplateV2 extends VideoAdServingTemplate {
		protected var _vastAdTag:String = null;
		protected var _originalAdId:Object = null;
		protected var _parentTemplate:VideoAdServingTemplate;
		protected var _id:String = null;
		protected var _adSystem:String = null;
		protected var _templateAds:Array = new Array();
		protected var _normalAds:Array = new Array();
		protected var _wrapperImpressions:Array = new Array();

		public function WrappedVideoAdServingTemplateV2(adRecordPosition:int, vastVersion:Number, adId:String=null, wrapperXML:XML=null, parentTemplate:VideoAdServingTemplate=null) {
			super(parentTemplate, null);
			_parentTemplate = parentTemplate;
			_originalAdId = adId;
			this.vastVersion = vastVersion;
			if(wrapperXML != null) initialise(adRecordPosition, wrapperXML, adId);
		}
		
		protected function initialise(adRecordPosition:int, wrapperXML:XML, adId:String):void {
			CONFIG::debugging { 
				doLog("Wrapped VAST " + _vastVersion + " template (" + _uid + ") XML response has " + wrapperXML.children().length() + " attributes defined - see trace", Debuggable.DEBUG_VAST_TEMPLATE); 
			}
			id = wrapperXML.adId;
			adSystem = wrapperXML.AdSystem;
			if(wrapperXML.VASTAdTagURI != undefined) {
				vastAdTag = wrapperXML.VASTAdTagURI.text();
			}	
			else if(wrapperXML.VASTAdTagURL != undefined) {
				CONFIG::debugging { doLog("Oops - a non-complaint VAST clear wrapper was returned - the Ad Tag is specified in a <VASTAdTagURL> tagset instead of <VASTAdTagURI> - adjusting accordingly", Debuggable.DEBUG_VAST_TEMPLATE); }
				if(wrapperXML.VASTAdTagURL.URL != undefined) {
					vastAdTag = wrapperXML.VASTAdTagURL.URL.text();
				}
				else vastAdTag = wrapperXML.VASTAdTagURL.text();				
			}
			_wrapperImpressions = parseInlineAd_V2_V3(adRecordPosition, adId, wrapperXML);
			recordTemplateAndNormalAds();
			if(hasVASTAdTag()) {
				var masterAdServerConfig:AdServerConfig = null;
				if(_parentTemplate != null) {
					_parentTemplate.registerLoader(_uid);
					masterAdServerConfig = _parentTemplate.getMasterAdServerConfig();
				}
				load(new WrappedAdServerRequest(vastAdTag, masterAdServerConfig));
			}
			else {
				CONFIG::debugging { doLog("Not loading the wrapped VAST ad tag as the URL is blank '" + vastAdTag + "'", Debuggable.DEBUG_VAST_TEMPLATE); }
			}
		}
		
		public override function hasAds(includeEmptyAdsInCount:Boolean=false):Boolean {
			if(_ads == null) {
				return false;
			}
			return (_ads.length + _templateAds.length + _normalAds.length > 0);
		}

		protected override function fireWrapperErrorUrls(errorCode:String):void {
			for each(var _templateAd:VideoAd in _templateAds) {
				_templateAd.fireErrorUrls(errorCode);
			}		
		}

		public override function onTemplateLoaded(template:AdServerTemplate):void {
			CONFIG::debugging { doLog(_uid + " has been notified that a template (" + template.uid + ") has loaded.", Debuggable.DEBUG_VAST_TEMPLATE); }
			_ads = template.getMergedAds();
			signalTemplateLoaded(template.uid);		
		}

		public override function onTemplateLoadError(event:Event):void {
			fireWrapperErrorUrls("300");
			_parentTemplate.signalTemplateLoadError(uid, event);
		}

		public override function onTemplateLoadTimeout(event:Event):void {	
			fireWrapperErrorUrls("301");
			_parentTemplate.signalTemplateLoadTimeout(uid, event);
		}

		protected override function templateLoaded(e:Event):void {
			CONFIG::debugging { doLog("Template (" + _uid + "): Loaded " + _xmlLoader.bytesLoaded + " bytes for the VAST template", Debuggable.DEBUG_VAST_TEMPLATE); }
			_templateData = _xmlLoader.data;
			CONFIG::debugging { doLog(_templateData, Debuggable.DEBUG_VAST_TEMPLATE); }
			parseFromRawData(_templateData);
			if(hasParseError()) {
				CONFIG::debugging { doLog("Parse error " + getParseError() + " recorded in template - firing error tracking", Debuggable.DEBUG_VAST_TEMPLATE); }
				this.fireWrapperErrorUrls(getParseError());
			}			
			fireTemplateLoadedTracking();
			signalTemplateLoaded(_uid);
		}
		
		public override function signalTemplateLoadError(uid:String, e:Event):void {
			fireWrapperErrorUrls("300");	
			super.signalTemplateLoadError(uid, e);
		}

		public override function signalTemplateLoadTimeout(uid:String, e:Event):void {
			fireWrapperErrorUrls("301");	
			super.signalTemplateLoadTimeout(uid, e);
		}
		
		protected override function errorHandler(e:Event):void {
			fireWrapperErrorUrls("300");	
			CONFIG::debugging { doLog("Template (" + uid + "): Load error: " + e.toString(), Debuggable.DEBUG_FATAL); }
			_parentTemplate.signalTemplateLoadError(uid, e);
		}
		
		public override function onAdCallStarted(request:AdServerRequest):void {
			_parentTemplate.onAdCallStarted(request);
		}

		public override function onAdCallFailover(masterRequest:AdServerRequest, failoverRequest:AdServerRequest):void {
			_parentTemplate.onAdCallFailover(masterRequest, failoverRequest);
		}
		
		public override function onAdCallComplete(request:AdServerRequest, hasAds:Boolean):void {
			_parentTemplate.onAdCallComplete(request, hasAds);
		}
		
		private function getIndexOfNextLinearAd(ads:Array):int {
			if(ads != null) {
				for(var i:int=0; i < ads.length; i++) {
					if(ads[i] != null) {
						if(ads[i].isLinear()) {
							return i;
						}
					}
				}
			}
			return -1;	
		}

		private function getIndexOfNextNonLinearAd(ads:Array):int {
			if(ads != null) {
				for(var i:int=0; i < ads.length; i++) {
					if(ads[i] != null) {
						if(ads[i].isNonLinear()) {
							return i;
						}
					}
				}
			}
			return -1;	
		}

		private function getIndexOfNextCompanionAd(ads:Array):int {
			if(ads != null) {
				for(var i:int=0; i < ads.length; i++) {
					if(ads[i] != null) {
						if(ads[i].isCompanionOnlyAd()) {
							return i;
						}
					}
				}
			}
			return -1;	
		}
		
		protected function recordTemplateAndNormalAds():void {
			if(_ads != null) {
				_templateAds = new Array();
				_normalAds = new Array();
				for(var i:int=0; i < _ads.length; i++) {
					if(_ads[i].isWrapperTemplateAd()) {
						_templateAds.push(_ads[i]);
					}
					else _normalAds.push(_ads[i]);
				}
				_templateAds = _templateAds.reverse();
				_normalAds = _normalAds.reverse();
			}
			_ads = new Array();
			CONFIG::debugging { doLog("recordTemplateAndNormalAds(" + _uid + ") has " + _templateAds.length + " template ads, " + _normalAds.length + " normal ads", Debuggable.DEBUG_VAST_TEMPLATE); }
		}
		
		public override function getMergedAds():Array {
			var result:Array = new Array();

			// step 1 - match up all the template ads - inject the downstream ad content into the template ads
			
			if(_templateAds != null) {
				CONFIG::debugging { doLog("getMergedAds(" + _uid + ") has " + _templateAds.length + " template ads and " + _ads.length + " normal ads", Debuggable.DEBUG_VAST_TEMPLATE); }
				var index:int;
				var mergedAd:VideoAd = null;	
				for(var i:int = 0; i < _templateAds.length; i++) {
					if(_templateAds[i].isLinear() || _templateAds[i].isUnknownType()) {
						index = getIndexOfNextLinearAd(_ads);	
						if(index > -1) {		
							mergedAd = _templateAds[i].injectAllTrackingData(_ads[index]);	

							if(mergedAd != null && VideoAd(_ads[index]).hasCompanionAds() == false && VideoAd(_templateAds[i]).hasCompanionAds()) {
								// If there are companion ads attached to the template, and the actual ad does not have companions
								// then add in the companions to the actual ad (so that they can be used as fallback companions)
								CONFIG::debugging { doLog("Adding " + VideoAd(_templateAds[i]).companionCount() + " companions from the wrapper template ad to the linear ad from the wrapped tag", Debuggable.DEBUG_VAST_TEMPLATE); }
								mergedAd.addCompanionAds(VideoAd(_templateAds[i]).companionAds);
							}

							result.push(mergedAd);

							_ads[index] = null;
						}
						else {
							// added in to support the forced firing of impressions with empty responses 
							result.push(_templateAds[i]);
						}
					}
					else if(_templateAds[i].isNonLinear()) {
						index = getIndexOfNextNonLinearAd(_ads);	
						if(index > -1) {
							mergedAd = _templateAds[i].injectAllTrackingData(_ads[index]);

							if(mergedAd != null && VideoAd(_ads[index]).hasCompanionAds() == false && VideoAd(_templateAds[i]).hasCompanionAds()) {
								// If there are companion ads attached to the template, and the actual ad does not have companions
								// then add in the companions to the actual ad (so that they can be used as fallback companions)
								CONFIG::debugging { doLog("Adding " + VideoAd(_templateAds[i]).companionCount() + " companions from the wrapper template ad to the non-linear ad from the wrapped tag", Debuggable.DEBUG_VAST_TEMPLATE); }
								mergedAd.addCompanionAds(VideoAd(_templateAds[i]).companionAds);
							}

							result.push(mergedAd);
							_ads[index] = null;
						}
						else {
							// added in to support the forced firing of impressions with empty responses  
							result.push(_templateAds[i]);
						}
					}
					else {
						if(VideoAd(_templateAds[i]).isCompanionOnlyAd()) {
							index = getIndexOfNextCompanionAd(_ads);
							if(index > -1) {			
								result.push(_templateAds[i].injectAllTrackingData(_ads[index]));
								_ads[index] = null;
							}
						}
						else {
							// Don't really know what to do with it at this point, so keep it just in case 
							result.push(_templateAds[i]);
						}
					}						
				}
			}

			// Step 2 - now add in the impressions

			for(var j:int = 0; j < _ads.length; j++) {
				if(_ads[j] != null) {
					if(_wrapperImpressions.length > 0) {
						_ads[j].addImpressions(_wrapperImpressions);
					}
					result.push(_ads[j]);
				}
			}
			
			// Step 3 - now merge all the non template ads to create the full set

			if(_normalAds != null) {
				result = result.concat(_normalAds);		
			}			

			CONFIG::debugging { doLog("getMergedAds(" + _uid + ") returning " + result.length + " ads", Debuggable.DEBUG_VAST_TEMPLATE); }
			return result;
		}

		public function set id(adId:String):void {
			_id = id;
		}
		
		public function get id():String {
			return _id;
		}

		public function set adSystem(adSystem:String):void {
			_adSystem = adSystem;
		}
		
		public function get adSystem():String {
			return _adSystem;
		}
		
		public function set vastAdTag(vastAdTag:String):void {
			_vastAdTag = vastAdTag;
		}
		
		public function get vastAdTag():String {
			return _vastAdTag;
		}
		
		public function hasVASTAdTag():Boolean {
			return (_vastAdTag != null && (StringUtils.isEmpty(_vastAdTag) == false));
		}
		
		protected override function createVideoAd_V2_V3(defaultAdId:String, ad:XML, creativeId:String, sequenceId:String, type:String, inlineAdId:String, containerAdId:String):VideoAdV2 {
			return super.createVideoAd_V2_V3(defaultAdId, ad, creativeId, sequenceId, type, inlineAdId, containerAdId);
		}		
	}
}
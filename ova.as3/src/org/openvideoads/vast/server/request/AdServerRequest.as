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
package org.openvideoads.vast.server.request {
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.util.BrowserUtils;
	import org.openvideoads.util.StringUtils;
	import org.openvideoads.vast.model.VideoAdServingTemplate;
	import org.openvideoads.vast.server.config.AdServerConfig;
	import org.openvideoads.vast.server.response.AdServerTemplate;
	import org.openvideoads.vast.server.response.TemplateLoadListener;	
	
	/**
	 * @author Paul Schulz
	 */
	public class AdServerRequest extends Debuggable {
		protected var _config:AdServerConfig = null;
		protected var _zones:Array = new Array();
		protected var _failoverRequestCount:int = 0;
		protected var _formedRequest:String = null;
		protected var _includesLinearAds:Boolean = false;
		protected var _callOnDemand:Boolean = false;
		protected var _index:int = 0;
		protected var _template:AdServerTemplate = null;
		
		public function AdServerRequest(config:AdServerConfig=null) {
			if(config != null) _config = config;	
		}		
		
		public function set config(config:AdServerConfig):void {
			_config = config;
		}
		
		public function get config():AdServerConfig {
			if(_config == null) _config = new AdServerConfig();
			return _config
		}
		
		public function set callOnDemand(callOnDemand:Boolean):void {
			_callOnDemand = callOnDemand;
		}
		
		public function get callOnDemand():Boolean {
			return _callOnDemand;
		}

		public function set template(template:AdServerTemplate):void {
			_template = template;
		}
		
		public function get template():AdServerTemplate {
			return _template;
		}
		
		public function forceImpressionServing():Boolean {
			if(_config != null) {			
				return _config.forceImpressionServing;
			}
			return false;
		}
		
		public function mustEnsureSingleAdUnitRecordedPerInlineAd():Boolean {
			if(_config != null) {
				return _config.ensureSingleAdUnitRecordedPerInlineAd;
			}
			return true;
		}

		public function get timeoutInSeconds():int {
			if(_config != null) {
				return _config.timeoutInSeconds;
			}
			return -1;
		}
		
		public function isWrapped():Boolean {
			return false;
		}
		
		public function includesLinearAds():Boolean {
			return _includesLinearAds;
		}
		
		public function requiresTransformation():Boolean {
			if(_config != null) {
				return _config.hasTransformers();
			}
			return false;
		}
		
		public function addZone(id:String, zone:String, slotType:String):void {
			if(_zones == null) _zones = new Array();
			var newZone:Object = new Object();
			newZone.id = id;
			newZone.zone = zone;
			newZone.slotType = slotType;
			newZone.assigned = false;
			if(_includesLinearAds == false) {
				_includesLinearAds = StringUtils.beginsWith(slotType, "LINEAR");
			}
			_zones.push(newZone);
		}
				
		public function hasCacheBusterRequirement():Boolean {
			if(_config != null) {
				return _config.addCacheBuster;
			}
			return false;
		}
		
		public function parseWrappedAdTags():Boolean {
			if(_config != null) {
				return _config.parseWrappedAdTags;
			}
			return false;			
		}
		
		public function serverType():String {
			return config.serverType;
		}
		
		public function get replaceIds():Boolean {
			return true;
		}
		
		public function get replacementIds():Array {
			return _zones;
		}

		protected function replaceApiServerAddress(template:String):String {
			var thePattern:RegExp = new RegExp("__api-address__", "g");
			template = template.replace(thePattern, config.apiServerAddress);
			return template;	
		}
		
		protected function replaceCustomProperties(template:String, properties:Object):String {
			return _config.customProperties.completeTemplate(template, ((_config != null) ? _config.hasTagParamsSpecified() : false));
		}

		protected function replaceZone(template:String):String {
			if(_zones != null) {
				if(_zones.length > 0) {
					var thePattern:RegExp = new RegExp("__zone__", "g");
					template = template.replace(thePattern, _zones[0].zone);	
				}
			}
			return template;	
		}
		
		protected function replaceZones(template:String):String {
			return template;	
		}

		protected function replaceVPAIDSetting(template:String):String {
			var thePattern:RegExp = new RegExp("__allow-vpaid__", "g");
			template = template.replace(thePattern, config.allowVPAID);
			return template;				
		}

		protected function replaceMaxDuration(template:String):String {
			var thePattern:RegExp = new RegExp("__max-duration__", "g");
			template = template.replace(thePattern, config.maxDuration);
			return template;				
		}

		protected function replaceASVersion(template:String):String {
			var thePattern:RegExp = new RegExp("__as-version__", "g");
			template = template.replace(thePattern, config.asVersion);
			return template;				
		}

		protected function replacePlayerHeight(template:String):String {
			var thePattern:RegExp = new RegExp("__player-height__", "g");
			template = template.replace(thePattern, config.playerHeight);
			return template;				
		}

		protected function replacePlayerWidth(template:String):String {
			var thePattern:RegExp = new RegExp("__player-width__", "g");
			template = template.replace(thePattern, config.playerWidth);
			return template;				
		}

		protected function replaceMediaUrl(template:String):String {
			var thePattern:RegExp = new RegExp("__media-url__", "g");
			template = template.replace(thePattern, config.mediaUrl);
			return template;				
		}

		protected function replaceStreamUrl(template:String):String {
			var thePattern:RegExp = new RegExp("__stream-url__", "g");
			template = template.replace(thePattern, config.streamUrl);
			return template;				
		}
		
		protected function replacePageStreamUrl(template:String):String {
			var thePattern:RegExp = new RegExp("__page-stream-url__", "g");
			template = template.replace(thePattern, config.pageStreamUrl);
			return template;				
		}

		protected function replacePageUrl(template:String):String {
			if(template.indexOf("__page-url__") > -1) {
				var thePattern:RegExp = new RegExp("__page-url__", "g");
				template = template.replace(thePattern, BrowserUtils.getPageUrl(true, _config.encodeVars));
			}
			return template;	
		}

		protected function replaceReferrer(template:String):String {
			if(template.indexOf("__referrer__") > -1) {
				var thePattern:RegExp = new RegExp("__referrer__", "g");
				template = template.replace(thePattern, BrowserUtils.getReferrer(true, _config.encodeVars));
			}
			return template;	
		}
		
		protected function replaceDomain(template:String):String {
			if(template.indexOf("__domain__") > -1) {
				var thePattern:RegExp = new RegExp("__domain__", "g");
				template = template.replace(thePattern, BrowserUtils.getDomain(true, _config.encodeVars));
			}
			return template;	
		}

		protected function replaceFormat(template:String):String {
			var thePattern:RegExp = new RegExp("__format__", "g");
			template = template.replace(thePattern, config.format);
			return template;				
		}
		
		protected function replaceRandomNumber(template:String):String {
			var thePattern:RegExp = new RegExp("__random-number__", "g");
			template = template.replace(thePattern, "R" + Math.random());
			return template;	
		}

		protected function replaceTimestamp(template:String):String {
			var thePattern:RegExp = new RegExp("__timestamp__", "g");
			template = template.replace(thePattern, new Date().valueOf().toString());
			return template;	
		}

		protected function replaceDuplicatesAsBinary(template:String):String {
			var thePattern:RegExp = new RegExp("__allow-duplicates-as-binary__", "g");
			template = template.replace(thePattern, (_config.allowAdRepetition) ? "1" : "0");
			return template;
		}
		
		protected function replaceDuplicatesAsBoolean(template:String):String {
			var thePattern:RegExp = new RegExp("__allow-duplicates-as-boolean__", "g");
			template = template.replace(thePattern, (_config.allowAdRepetition) ? "true" : "false");
			return template;
		}

		protected function replaceAmpersands(template:String):String {
			var thePattern:RegExp = new RegExp("__amp__", "g");
			template = template.replace(thePattern, "&");
			return template;
		}

		protected function replacePartnerId(template:String):String {
			var thePattern:RegExp = new RegExp("__partner-id__", "g");
			template = template.replace(thePattern, config.partnerId);
			return template;
		}

		protected function replaceMediaId(template:String):String {
			var thePattern:RegExp = new RegExp("__media-id__", "g");
			template = template.replace(thePattern, config.mediaId);
			return template;
		}

		protected function replaceMediaTitle(template:String):String {
			var thePattern:RegExp = new RegExp("__media-title__", "g");
			template = template.replace(thePattern, config.mediaTitle);
			return template;
		}

		protected function replaceMediaDescription(template:String):String {
			var thePattern:RegExp = new RegExp("__media-description__", "g");
			template = template.replace(thePattern, config.mediaDescription);
			return template;
		}

		protected function replaceMediaCategories(template:String):String {
			var thePattern:RegExp = new RegExp("__media-categories__", "g");
			template = template.replace(thePattern, config.mediaCategories);
			return template;
		}

		protected function replaceMediaKeywords(template:String):String {
			var thePattern:RegExp = new RegExp("__media-keywords__", "g");
			template = template.replace(thePattern, config.mediaKeywords);
			return template;
		}

		public function set index(index:int):void {
			_index = index;
		}
		
		public function get index():int {
			return _index;
		}
		
		public function hasFailoverRequestsAvailable():Boolean {
			if(_config.hasFailoverServers()) {
				return (_failoverRequestCount < _config.failoverServerCount);
			}	
			return false;
		}
		
		public function get failoverRequestCount():int {
			return _failoverRequestCount;
		}
				
		public function nextFailoverAdServerRequest():AdServerRequest {
			if(hasFailoverRequestsAvailable()) {
				var failoverConfig:AdServerConfig = _config.getFailoverAdServerConfigAtIndex(_failoverRequestCount);
				if(failoverConfig != null) {
					var adServerRequest:AdServerRequest = AdServerRequestFactory.create(failoverConfig.serverType);
					_failoverRequestCount++;
					adServerRequest.config = failoverConfig;
					adServerRequest.index = _failoverRequestCount;
					return adServerRequest;			
				}
			}
			return null;
		}
		
	 	public function formRequest(zones:Array=null):String {
	 		if(_config.tag == null) {
	 			_formedRequest = processTemplate(config.template, zones);
		 	}
		 	else {
		 		_formedRequest = processTemplate(_config.tag, zones);
		 	}
		 	return _formedRequest;
	 	}	 	
	 	
	 	public function get formedRequest():String {
	 		return _formedRequest;
	 	}
	 	
	 	protected function processTemplate(originalTemplate:String, zones:Array=null):String {
	 		if(originalTemplate != null) {
				var template:String = originalTemplate;
		 		if(zones != null) _zones = zones;
				template = replaceApiServerAddress(template);
				template = replaceAmpersands(template);
				template = replaceCustomProperties(template, config.customProperties);
				template = replaceRandomNumber(template);
				template = replaceTimestamp(template);
				template = replaceDuplicatesAsBinary(template);
				template = replaceDuplicatesAsBoolean(template);
				template = replaceZone(template);
				template = replaceZones(template);
				template = replacePageUrl(template);
				template = replaceReferrer(template);
				template = replaceDomain(template);
				template = replaceStreamUrl(template);
				template = replaceMediaUrl(template);
				template = replacePageStreamUrl(template);
				template = replaceVPAIDSetting(template);
				template = replaceFormat(template);
				template = replaceMaxDuration(template);
				template = replaceASVersion(template);
				template = replacePlayerHeight(template);
				template = replacePlayerWidth(template);
				template = replacePartnerId(template);
				template = replaceMediaId(template);
				template = replaceMediaTitle(template);
				template = replaceMediaDescription(template);
				template = replaceMediaDescription(template);
				template = replaceMediaCategories(template);
				template = replaceMediaKeywords(template);
		 		return template;	 			 			
	 		}
	 		return "";
	 	}

		public function verifyRequestURL(url:String, properties:Object):String {
			return url;
		}

		public function createMasterAdServerTemplate(listener:TemplateLoadListener):AdServerTemplate {			
			var masterTemplate:VideoAdServingTemplate = new VideoAdServingTemplate(listener, this, this.replaceIds, this.replacementIds);
			masterTemplate.isMaster = true;
			return masterTemplate;
		}
		
		public override function toJSObject():Object {
			var o:Object = new Object();
			o = {
				uid: _uid,
				index: _index,
				adServerType: ((config != null) ? config.type : "unknown"),
				formedTag: _formedRequest,
				onDemand: _callOnDemand
			};
			return o;			
		}
	}
}
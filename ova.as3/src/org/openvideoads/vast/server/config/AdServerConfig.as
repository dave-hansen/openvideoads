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
package org.openvideoads.vast.server.config {
	import flash.external.ExternalInterface;
	
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.util.ObjectUtils;
	import org.openvideoads.util.StringUtils;
	import org.openvideoads.vast.server.request.direct.DirectServerConfig;
	
	/**
	 * @author Paul Schulz
	 */
	public class AdServerConfig extends Debuggable {
		protected var _id:String = "";
		protected var _serverType:String = "direct";
		protected var _oneAdPerRequest:Boolean = false;
		protected var _allowAdRepetition:Boolean = false;
		protected var _customProperties:CustomProperties;
		protected var _requestTemplate:String = null;
		protected var _apiServerAddress:String = "http://localhost";
		protected var _defaultAdServer:Boolean = false;
		protected var _failoverServers:Array = null;
		protected var _failoverConditions:FailoverConditionsConfig = null;
		protected var _tag:String = null;
		protected var _forceImpressionServing:Boolean = false;
		protected var _fireTrackingOnReplay:Boolean = false; // TO BE IMPLEMENTED
		protected var _allowVPAID:Boolean = false;
		protected var _maxDuration:int = -1;
		protected var _asVersion:String = "3";
		protected var _playerWidth:int = -1;
		protected var _playerHeight:int = -1;
		protected var _mediaUrl:String = null;
		protected var _pageStreamUrl:String = null;
		protected var _pageUrl:String = null;
		protected var _streamUrl:String = null;
		protected var _format:String = "vast1";
		protected var _partnerId:String = null;
		protected var _mediaId:String = null;
		protected var _mediaTitle:String = null;
		protected var _mediaDescription:String = null;
		protected var _mediaCategories:String = null;
		protected var _mediaKeywords:String = null;
		protected var _addCacheBuster:Boolean = false;
		protected var _parseWrappedAdTags:Boolean = false;
		protected var _tagParams:Object = null;
		protected var _timeoutInSeconds:int = -1;
		protected var _ensureSingleAdUnitRecordedPerInlineAd:Boolean = true;
		protected var _acceptedLinearAdMimeTypes:Array = new Array();
		protected var _filterOnLinearAdMimeTypes:Boolean = false;
		protected var _acceptedNonLinearAdMimeTypes:Array = new Array();
		protected var _filterOnNonLinearAdMimeTypes:Boolean = false;
		protected var _encodeVars:Boolean = false;
		protected var _transformers:Array = new Array();

		public function AdServerConfig(serverType:String=null, config:Object=null) {
			if(serverType != null) _serverType = serverType;
			_customProperties = this.defaultCustomProperties;
			initialise(config);
		}

		public function initialise(config:Object):void {
			if(config != null) {
				if(config.id != undefined) _id = config.id;
				if(config.type != undefined) _serverType = config.type;
				if(config.apiAddress != undefined) _apiServerAddress = config.apiAddress;
				if(config.requestTemplate != undefined) _requestTemplate = config.requestTemplate;
				if(config.allowAdRepetition != undefined) _allowAdRepetition = config.allowAdRepetition;
				if(config.ensureSingleAdUnitRecordedPerInlineAd != undefined) _ensureSingleAdUnitRecordedPerInlineAd = config.ensureSingleAdUnitRecordedPerInlineAd;
				if(config.oneAdPerRequest != undefined) _oneAdPerRequest = config.oneAdPerRequest;
				if(config.customProperties != undefined) {
					if(_customProperties == null) {
						_customProperties = new CustomProperties();
					}
					_customProperties.addProperties(config.customProperties);
				}
				if(config.tagParams != undefined) {
					if(_customProperties == null) {
						_customProperties = new CustomProperties();
					}
					_customProperties.addProperties(config.tagParams);
					_tagParams = config.tagParams;
				}
				if(config.defaultAdServer != undefined) _defaultAdServer = config.defaultAdServer;
				if(config.tag != undefined) _tag = config.tag;
				if(config.allowVPAID != undefined) _allowVPAID = config.allowVPAID;
				if(config.asVersion != undefined) _asVersion = config.asVersion;
				if(config.timeoutInSeconds != undefined) {
					if(config.timeoutInSeconds is String) {
						_timeoutInSeconds = int(config.timeoutInSeconds);
					}
					else _timeoutInSeconds = config.timeoutInSeconds;
				}
				if(config.maxDuration != undefined) {
					if(config.maxDuration is String) {
						_maxDuration = int(config.maxDuration);
					}
					else _maxDuration = config.maxDuration;
				}
				if(config.playerWidth != undefined) {
					if(config.playerWidth is String) {
						_playerWidth = int(config.playerWidth);
					}
					else _playerWidth = config.playerWidth;
				}
				if(config.playerHeight != undefined) {
					if(config.playerHeight is String) {
						_playerHeight = int(config.playerHeight);
					}
					else _playerHeight = config.playerHeight;
				}
				if(config.mediaUrl != undefined) {
					_mediaUrl = config.mediaUrl;
				}
				if(config.pageStreamUrl != undefined) {
					_pageStreamUrl = config.pageStreamUrl;
				}
				if(config.pageUrl != undefined) {
					_pageUrl = config.pageUrl;
				}
				if(config.format != undefined) {
					_format = config.format;
				}
				if(config.partnerId != undefined) {
					_partnerId = config.partnerId;
				}
				if(config.mediaId != undefined) {
					_mediaId = config.mediaId;
				}				
				if(config.mediaTitle != undefined) {
					_mediaTitle = config.mediaTitle;
				}				
				if(config.mediaDescription != undefined) {
					_mediaDescription = config.mediaDescription;
				}				
				if(config.mediaCategories != undefined) {
					_mediaCategories = config.mediaCategories;
				}				
				if(config.mediaKeywords != undefined) {
					_mediaKeywords = config.mediaKeywords;
				}				
				if(config.forceImpressionServing != undefined) {
					this.forceImpressionServing = config.forceImpressionServing;
				}
				if(config.addCacheBuster != undefined) {
					this.addCacheBuster = config.addCacheBuster;
				}
				if(config.parseWrappedAdTags != undefined) {
					this.parseWrappedAdTags = config.parseWrappedAdTags;
				}
				if(config.acceptedLinearAdMimeTypes != undefined) {
					this.acceptedLinearAdMimeTypes = config.acceptedLinearAdMimeTypes;
				}
				if(config.filterOnLinearAdMimeTypes != undefined) {
					if(config.filterOnLinearAdMimeTypes is String) {
						this.filterOnLinearAdMimeTypes = ((config.filterOnLinearAdMimeTypes.toUpperCase() == "TRUE") ? true : false);											
					}
					else this.filterOnLinearAdMimeTypes = config.filterOnLinearAdMimeTypes;
				}
				if(config.encodeVars != undefined) {
					if(config.encodeVars is String) {
						this.encodeVars = ((config.encodeVars.toUpperCase() == "TRUE") ? true : false);											
					}
					else this.encodeVars = config.encodeVars;
				}
				if(config.failoverConditions != undefined) {
					_failoverConditions = new FailoverConditionsConfig(config.failoverConditions);
				}
				if(config.failoverServers != undefined) {
					if(config.failoverServers is Array) {
						_failoverServers = new Array();
						for(var i:int = 0; i < config.failoverServers.length; i++) {
							if(config.failoverServers[i] is AdServerConfig) {
								_failoverServers.push(config.failoverServers[i]);
							}
							else {
								var newConfig:AdServerConfig;
								if(config.failoverServers[i].type != undefined) {
									newConfig = AdServerConfigFactory.getAdServerConfig(config.failoverServers[i].type);
									newConfig.initialise(config.failoverServers[i]);
								}
								else newConfig = new DirectServerConfig(config.failoverServers[i]);
								_failoverServers.push(newConfig);
							}
						}
					}
				}				
				if(config.transformers != undefined) {
					if(config.transformers is String) {
						_transformers = [ config.transformers ];	
					}
					else if(config.transformers is Array) {
						_transformers = config.transformers;
					}
				}
			}
		}

		public function set ensureSingleAdUnitRecordedPerInlineAd(ensureSingleAdUnitRecordedPerInlineAd:Boolean):void {
			_ensureSingleAdUnitRecordedPerInlineAd = ensureSingleAdUnitRecordedPerInlineAd;
		}
		
		public function get ensureSingleAdUnitRecordedPerInlineAd():Boolean {
			return _ensureSingleAdUnitRecordedPerInlineAd;
		}
		
		public function set encodeVars(encodeVars:Boolean):void {
			_encodeVars = encodeVars;
		}
		
		public function get encodeVars():Boolean {
			return _encodeVars;
		}
		
		public function hasTransformers():Boolean {
			if(_transformers != null) {
				return (_transformers.length > 0);
			}
			return false;
		}
		
		public function set transformers(transformers:Array):void {
			_transformers = transformers;
		}
		
		public function get transformers():Array {
			return _transformers;
		}		
		
		public function set timeoutInSeconds(timeoutInSeconds:int):void {
			_timeoutInSeconds = timeoutInSeconds;
		}
		
		public function get timeoutInSeconds():int {
			return _timeoutInSeconds;
		}
		
		protected function get defaultTemplate():String {
			return "";
		}
		
		protected function get defaultCustomProperties():CustomProperties {
			return new CustomProperties();
		}
		
		public function get template():String {
			if(_requestTemplate != null) {
				return _requestTemplate;
			}
			return this.defaultTemplate;
		}
		
		public function set template(requestTemplate:String):void {
			_requestTemplate = requestTemplate;
		}
		
		public function set apiServerAddress(apiServerAddress:String):void {
			_apiServerAddress = apiServerAddress;
		}
		
		public function get apiServerAddress():String {
			return _apiServerAddress;
		}

		public function set apiAddress(apiAddress:String):void {
			this.apiServerAddress = apiAddress;
		}
		
		public function get apiAddress():String {
			return this.apiServerAddress;
		}

		public function set addCacheBuster(addCacheBuster:Boolean):void {
			_addCacheBuster = addCacheBuster;
			CONFIG::debugging { doLog("Cache buster to be added to wrapped ad tag: " + _addCacheBuster, Debuggable.DEBUG_CONFIG); }
		}
		
		public function get addCacheBuster():Boolean {
			return _addCacheBuster;
		}

		public function set parseWrappedAdTags(parseWrappedAdTags:Boolean):void {
			_parseWrappedAdTags = parseWrappedAdTags;
			CONFIG::debugging { doLog("Parsing wrapped ad tags for OVA var substitution: " + _parseWrappedAdTags, Debuggable.DEBUG_CONFIG); }
		}
		
		public function get parseWrappedAdTags():Boolean {
			return _parseWrappedAdTags;
		}
		
		public function set failoverServers(failoverServers:Array):void {
			_failoverServers = failoverServers;
		}
		
		public function get failoverServers():Array {
			return _failoverServers;
		}
		
		public function hasFailoverServers():Boolean {
			return (failoverServerCount > 0);
		}
		
		public function get failoverServerCount():int {
			if(_failoverServers != null) {
				return _failoverServers.length;
			}
			return 0;
		}
		
		public function getFailoverAdServerConfigAtIndex(index:int):AdServerConfig {
			if(failoverServerCount > index && failoverServerCount > 0) {
				return _failoverServers[index];
			}
			return null;
		}

		public function set failoverConditions(failoverConditions:FailoverConditionsConfig):void {
			_failoverConditions = failoverConditions;
		}
		
		public function get failoverConditions():FailoverConditionsConfig {
			return _failoverConditions;
		}
		
		public function set forceImpressionServing(forceImpressionServing:Boolean):void {
			_forceImpressionServing = forceImpressionServing;
			CONFIG::debugging { doLog("Forcing impression serving: " + _forceImpressionServing, Debuggable.DEBUG_CONFIG); }
		}
		
		public function get forceImpressionServing():Boolean {
			return _forceImpressionServing;
		}
		
		public function hasTagParamsSpecified():Boolean {
			return (_tagParams != null);
		}
		
		public function set customProperties(customProperties:CustomProperties):void {
			_customProperties = customProperties;
		}
		
		public function get customProperties():CustomProperties {
			return _customProperties;
		}

        public function set oneAdPerRequest(oneAdPerRequest:Boolean):void {
        	_oneAdPerRequest = oneAdPerRequest;
        }
        
        public function get oneAdPerRequest():Boolean {
        	return _oneAdPerRequest;
        }
        
        public function set defaultAdServer(defaultAdServer:Boolean):void {
        	_defaultAdServer = defaultAdServer;
        }
        
        public function get defaultAdServer():Boolean {
        	return _defaultAdServer;
        }
        		
		public function set allowAdRepetition(allowAdRepetition:Boolean):void {
			_allowAdRepetition = allowAdRepetition;
		}
		
		public function get allowAdRepetition():Boolean {
			return _allowAdRepetition;
		}

		public function set serverType(serverType:String):void {
			_serverType = serverType;
		}
		
		public function get serverType():String {
			return _serverType;
		}
		
		public function typeKey():String {
			return serverType + (oneAdPerRequest ? "-single" : "-multiple-" + _uid);
		}
		
		public function set type(type:String):void {
			this.serverType = type;
		}
		
		public function get type():String {
			return this.serverType;
		}

		public function set requestTemplate(requestTemplate:String):void {
			_requestTemplate = requestTemplate;
		}
		
		public function get requestTemplate():String {
			return _requestTemplate;
		}		
		
		public function set tag(tag:String):void {
			_tag = tag;
		}
		
		public function get tag():String {
			return _tag;
		}
		
		public function set tagParams(tagParams:Object):void {
			_tagParams = tagParams;
		}
		
		public function get tagParams():Object {
			return _tagParams;
		}
		
		public function set allowVPAID(allowVPAID:Boolean):void {
			_allowVPAID = allowVPAID;	
		}
		
		public function get allowVPAID():Boolean {
			return _allowVPAID;
		}
		
		public function set maxDuration(maxDuration:int):void {
			_maxDuration = maxDuration;
		}
		
		public function get maxDuration():int {
			return _maxDuration;
		}
		
		public function set asVersion(asVersion:String):void {
			_asVersion = asVersion;
		}
		
		public function get asVersion():String {
			return _asVersion;
		}
		
		public function set playerWidth(playerWidth:int):void {
			_playerWidth = playerWidth;
		}
		
		public function get playerWidth():int {
			return _playerWidth;
		}
		
		public function set playerHeight(playerHeight:int):void {
			_playerHeight = playerHeight;
		}
		
		public function get playerHeight():int {
			return _playerHeight;
		}
		
		public function set mediaUrl(mediaUrl:String):void {
			_mediaUrl = mediaUrl;
		}
		
		public function get mediaUrl():String {
			return _mediaUrl;
		}
		
		public function set pageStreamUrl(pageStreamUrl:String):void {
			_pageStreamUrl = pageStreamUrl;
		}
		
		public function get pageStreamUrl():String {
			return _pageStreamUrl;
		}
		
		public function set streamUrl(streamUrl:String):void {
			_streamUrl = streamUrl;
		}
		
		public function get streamUrl():String {
			return _streamUrl;
		}
		
		public function set pageUrl(pageUrl:String):void {
			_pageUrl = pageUrl;
		}
		
		public function get pageUrl():String {
			return _pageUrl;
		}
		
		public function set format(format:String):void {
			_format = format;
		}
		
		public function get format():String {
			return _format;
		}
		
		public function matchesId(id:String):Boolean {
			if(_id == null) {
				return (id == null);
			} 
			if(id == null) {
				return false;
			}
			return (_id.toUpperCase() == id.toUpperCase());
		}
		
		public function set id(id:String):void {
			_id = id;
		}
		
		public function get id():String {
			return _id;
		}
	
		public function set partnerId(partnerId:String):void {
			_partnerId = partnerId;
		}
		
		public function get partnerId():String {
			return _partnerId;
		}
		
		public function set mediaId(mediaId:String):void {
			_mediaId = mediaId;
		}
		
		public function get mediaId():String {
			return _mediaId;
		}
		
		public function set mediaTitle(mediaTitle:String):void {
			_mediaTitle = mediaTitle;
		}
		
		public function get mediaTitle():String {
			return _mediaTitle;
		}
		
		public function set mediaDescription(mediaDescription:String):void {
			_mediaDescription = mediaDescription;
		}
		
		public function get mediaDescription():String {
			return _mediaDescription;
		}
		
		public function set mediaCategories(mediaCategories:String):void {
			_mediaCategories = mediaCategories;
		}
		
		public function get mediaCategories():String {
			return _mediaCategories;
		}
		
		public function set mediaKeywords(mediaKeywords:String):void {
			_mediaKeywords = mediaKeywords;
		}
		
		public function get mediaKeywords():String {
			return _mediaKeywords;
		}

		public function set acceptedLinearAdMimeTypes(acceptedLinearMimeTypes:Array):void {
			_acceptedLinearAdMimeTypes = acceptedLinearMimeTypes;
		}

		public function get acceptedLinearAdMimeTypes():Array {
			return _acceptedLinearAdMimeTypes;
		}
		
		public function hasSpecificAcceptedLinearAdMimeTypesDeclared():Boolean {
			if(_acceptedLinearAdMimeTypes != null) {
				return (_acceptedLinearAdMimeTypes.length > 0);
			}
			return false;
		}

		public function isAcceptedLinearAdMimeType(mimeType:String):Boolean {
			if(hasSpecificAcceptedLinearAdMimeTypesDeclared() == false) return true;
			for(var i:int=0; i < _acceptedLinearAdMimeTypes.length; i++) {
				if(StringUtils.matchesIgnoreCase(_acceptedLinearAdMimeTypes[i], mimeType)) {
					return true;
				}
			}
			return false;
		}
		
		public function set filterOnLinearAdMimeTypes(enableFilterOnLinearAdMimeTypes:Boolean):void {
			_filterOnLinearAdMimeTypes = enableFilterOnLinearAdMimeTypes;
		}

		public function get filterOnLinearAdMimeTypes():Boolean {
			return _filterOnLinearAdMimeTypes;
		}
				
		public function clone():AdServerConfig {
			var newVersion:AdServerConfig = AdServerConfigFactory.getAdServerConfig(_serverType);
			newVersion.allowAdRepetition = _allowAdRepetition;
			newVersion.serverType = _serverType;
			newVersion.oneAdPerRequest = _oneAdPerRequest;
			newVersion.customProperties = _customProperties;
			newVersion.template = _requestTemplate;
			newVersion.apiServerAddress = _apiServerAddress;
			newVersion.defaultAdServer = _defaultAdServer;
			newVersion.forceImpressionServing = _forceImpressionServing;
			newVersion.requestTemplate = _requestTemplate;
			newVersion.failoverServers = _failoverServers;
			newVersion.failoverConditions = _failoverConditions;
			newVersion.tag = _tag;
			newVersion.forceImpressionServing = _forceImpressionServing;
			newVersion.allowVPAID = _allowVPAID;
			newVersion.maxDuration = _maxDuration;
			newVersion.asVersion = _asVersion;
			newVersion.playerWidth = _playerWidth;
			newVersion.playerHeight = _playerHeight;
			newVersion.mediaUrl = _mediaUrl;
			newVersion.pageStreamUrl = _pageStreamUrl;
			newVersion.pageUrl = _pageUrl;
			newVersion.streamUrl = _streamUrl;
			newVersion.format = _format;
			newVersion.partnerId = _partnerId;
			newVersion.mediaId = _mediaId;
			newVersion.mediaTitle = _mediaTitle;
			newVersion.mediaDescription = _mediaDescription;
			newVersion.mediaCategories = _mediaCategories;
			newVersion.mediaKeywords = _mediaKeywords;
			newVersion.addCacheBuster = _addCacheBuster;
			newVersion.tagParams = _tagParams;
			newVersion.timeoutInSeconds = _timeoutInSeconds;
            newVersion.encodeVars = _encodeVars;
            
			return newVersion;
		}
	}
}
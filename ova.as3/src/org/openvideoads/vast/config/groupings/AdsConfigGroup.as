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
	import org.openvideoads.util.Timestamp;
	import org.openvideoads.vast.config.ConfigLoadListener;
	import org.openvideoads.vast.server.config.AdServerConfig;
	import org.openvideoads.vast.server.config.AdServerConfigFactory;
	
	/**
	 * @author Paul Schulz
	 */
	public class AdsConfigGroup extends AbstractStreamsConfig implements ConfigLoadListener {
		protected var _adServerConfig:AdServerConfig = null;
		protected var _adServers:Array = null;
		protected var _schedule:Array = new Array();
        protected var _noticeConfig:AdNoticeConfig = new AdNoticeConfig();
		protected var _clickSignConfig:ClickSignConfig = new ClickSignConfig();
		protected var _surveyConfig:SurveyConfig = new SurveyConfig();
		protected var _skipAdConfig:SkipAdConfig = new SkipAdConfig();
		protected var _companionsConfig:CompanionsConfigGroup = new CompanionsConfigGroup();
		protected var _vpaidConfig:VPAIDConfig = new VPAIDConfig();
		protected var _overlaysConfig:OverlaysConfig = new OverlaysConfig();
		protected var _allowDomains:String = "*";
		protected var _activelySchedule:Boolean = true;
		protected var _visuallyCueLinearAdClickThrough:Boolean = true;
		protected var _pauseOnClickThrough:Boolean = true;
		protected var _filterOnLinearAdMimeTypes:Boolean = false;
		protected var _acceptedLinearAdMimeTypes:Array = new Array();
		protected var _linearScaling:String = null;
		protected var _enforceLinearInteractiveAdScaling:Boolean = false;
		protected var _enforceLinearVideoAdScaling:Boolean = false;
		protected var _enforceLinearAdsOnPlaylistSelection:Boolean = false;
		protected var _tagParams:Object = null;
		protected var _streamers:Array = null;
		protected var _metaDataConfig:AdMetaDataConfigGroup = new AdMetaDataConfigGroup();
		protected var _resetTrackingOnReplay:Boolean = true;
		protected var _postMidRollSeekPosition:int = -1;
		protected var _nativeDisplay:Boolean = true;
		protected var _enforceMidRollPlayback:Boolean = false;
		protected var _shortenLinearAdDurationPercentage:int = 0;
		protected var _allowDuplicateODCuepoints:Boolean = false;
		protected var _forcePlayAfterVPAID:Boolean = false;

		public function AdsConfigGroup(config:Object=null, onLoadedListener:ConfigLoadListener=null) {
			_setDurationFromMetaData = true; // default value for the ads group
			super(config, onLoadedListener);
		}
		
		public override function initialise(config:Object = null, onLoadedListener:ConfigLoadListener=null, forceEnable:Boolean=false):void {
			markAsLoading();
			super.initialise(config, onLoadedListener);
			if(config != null) {
				if(config.activelySchedule != undefined) {
					if(config.activelySchedule is String) {
						this.activelySchedule = ((config.activelySchedule.toUpperCase() == "TRUE") ? true : false);											
					}
					else this.activelySchedule = config.activelySchedule;
				}
				if(config.resetTrackingOnReplay != undefined) {
					if(config.resetTrackingOnReplay is String) {
						this.resetTrackingOnReplay = (config.resetTrackingOnReplay.toUpperCase() == "TRUE");
					}
					else this.resetTrackingOnReplay = config.resetTrackingOnReplay;
				}				
				if(config.allowDuplicateODCuepoints != undefined) {
					if(config.allowDuplicateODCuepoints is String) {
						this.allowDuplicateODCuepoints = (config.allowDuplicateODCuepoints.toUpperCase() == "TRUE");
					}
					else this.allowDuplicateODCuepoints = config.allowDuplicateODCuepoints;
				}				
				if(config.forcePlayAfterVPAID != undefined) {
					if(config.forcePlayAfterVPAID is String) {
						this.forcePlayAfterVPAID = ((config.forcePlayAfterVPAID.toUpperCase() == "TRUE") ? true : false);											
					}
					else this.forcePlayAfterVPAID = config.forcePlayAfterVPAID;
				}
				if(config.hasOwnProperty("skipAd")) {
					this.skipAd = new SkipAdConfig(config.skipAd);
				}
				if(config.hasOwnProperty("overlays")) {
					this.overlays = config.overlays;
				}
				if(config.playOnce != undefined) {
					if(config.playOnce is String) {
						this.playOnce = ((config.playOnce.toUpperCase() == "TRUE") ? true : false);											
					}
					else this.playOnce = config.playOnce;
				}
				if(config.hasOwnProperty("survey")) {
					this.surveyConfig = new SurveyConfig(config.survey);
				}
				if(config.enforceMidRollPlayback != undefined) {
					if(config.enforceMidRollPlayback is String) {
						this.enforceMidRollPlayback = ((config.enforceMidRollPlayback.toUpperCase() == "TRUE") ? true : false);											
					}
					else this.enforceMidRollPlayback = config.enforceMidRollPlayback;
				}
				if(config.enforceLinearInteractiveAdScaling != undefined) {
					if(config.enforceLinearInteractiveAdScaling is String) {
						this.enforceLinearInteractiveAdScaling = ((config.enforceLinearInteractiveAdScaling.toUpperCase() == "TRUE") ? true : false);											
					}
					else this.enforceLinearInteractiveAdScaling = config.enforceLinearInteractiveAdScaling;
				}
				if(config.enforceLinearVideoAdScaling != undefined) {
					if(config.enforceLinearVideoAdScaling is String) {
						this.enforceLinearVideoAdScaling = ((config.enforceLinearVideoAdScaling.toUpperCase() == "TRUE") ? true : false);											
					}
					else this.enforceLinearVideoAdScaling = config.enforceLinearVideoAdScaling;
				}
				if(config.enforceLinearAdsOnPlaylistSelection != undefined) {
					if(config.enforceLinearAdsOnPlaylistSelection is String) {
						this.enforceLinearAdsOnPlaylistSelection = ((config.enforceLinearAdsOnPlaylistSelection.toUpperCase() == "TRUE") ? true : false);											
					}
					else this.enforceLinearAdsOnPlaylistSelection = config.enforceLinearAdsOnPlaylistSelection;
				}
				if(config.linearScaling != undefined) {
					this.linearScaling = config.linearScaling;
				}
				if(config.notice != undefined) {
					this.notice = config.notice;
				}
				if(config.visuallyCueLinearAdClickThrough != undefined) {
					if(config.visuallyCueLinearAdClickThrough is String) {
						this.visuallyCueLinearAdClickThrough = ((config.visuallyCueLinearAdClickThrough.toUpperCase() == "TRUE") ? true : false);											
					}
					else this.visuallyCueLinearAdClickThrough = config.visuallyCueLinearAdClickThrough;
				}
				if(config.pauseOnClickThrough != undefined) {
					if(config.pauseOnClickThrough is String) {
						this.pauseOnClickThrough = ((config.pauseOnClickThrough.toUpperCase() == "TRUE") ? true : false);											
					}
					else this.pauseOnClickThrough = config.pauseOnClickThrough;
				}
				if(config.nativeDisplay != undefined) {
					if(config.nativeDisplay is String) {
						this.nativeDisplay = ((config.nativeDisplay.toUpperCase() == "TRUE") ? true : false);											
					}
					else this.nativeDisplay = config.nativeDisplay;
				}
				if(config.clickSign != undefined) {
					this.clickSignConfig = new ClickSignConfig(config.clickSign);
				}
				if(config.companions != undefined) {
					this.companionsConfig = new CompanionsConfigGroup(config.companions);
				}
				if(config.allowDomains != undefined) {
					this.allowDomains = config.allowDomains;
				}
				if(config.schedule != undefined) {
					if(config.schedule is Array) {
						this.schedule = config.schedule;
					}
					else this.schedule = ArrayUtils.makeArray(config.schedule);														
				}
				if(config.tagParams != undefined) {
					this.tagParams = config.tagParams;
				}
				if(config.postMidRollSeekPosition != undefined) {
					if(config.postMidRollSeekPosition is String) {
						_postMidRollSeekPosition = parseInt(config.postMidRollSeekPosition);
					}
					else _postMidRollSeekPosition = config.postMidRollSeekPosition;
				}
				if(config.tag != undefined) {
					this.tag = config.tag;
				}
				if(config.vpaid != undefined) {
					this.vpaid = config.vpaid;
				}
				if(config.holdingClipUrl != undefined) {
					this.holdingClipUrl = config.holdingClipUrl;
				}
				if(config.metaData != undefined) {
					this.setMetaDataConfigFromObject(config.metaData);
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
				if(config.shortenLinearAdDurationPercentage != undefined) {
					this.shortenLinearAdDurationPercentage = config.shortenLinearAdDurationPercentage;
				}
				if(config.streamers != undefined) {
					if(config.streamers is Array) {
						this.streamers = config.streamers;
					}
					else this.streamers = ArrayUtils.makeArray(config.streamers);
				}
				
				// Finally, do the ad server config - but load the right ad server config class
				if(config.server != undefined) {
					if(config.server.type != undefined) {
						this.adServerConfig = AdServerConfigFactory.getAdServerConfig(config.server.type);
						this.adServerConfig.initialise(config.server);
					}
				}				
				if(config.servers != undefined) {
					this.adServers = config.servers;
				}
				
				assignRuntimePropertiesToIndividualAdSlots();
			}				
			markAsLoaded();
		}

		public function set overlays(overlays:Object):void {
			overlaysConfig = new OverlaysConfig(overlays);			
		}

		public function set overlaysConfig(overlaysConfig:OverlaysConfig):void {
			_overlaysConfig = overlaysConfig;
		}		
		
		public function get overlaysConfig():OverlaysConfig {
			return _overlaysConfig;
		}
		
		public function set surveyConfig(surveyConfig:SurveyConfig):void {
			_surveyConfig = surveyConfig;
		}
		
		public function get surveyConfig():SurveyConfig {
			return _surveyConfig;
		}

		public function set shortenLinearAdDurationPercentage(shortenLinearAdDurationPercentage:int):void {
			_shortenLinearAdDurationPercentage = shortenLinearAdDurationPercentage;
		}
		
		public function get shortenLinearAdDurationPercentage():int {
			return _shortenLinearAdDurationPercentage;
		}
		
		public function set postMidRollSeekPosition(postMidRollSeekPosition:int):void {
			_postMidRollSeekPosition = postMidRollSeekPosition;	
		}
		
		public function get postMidRollSeekPosition():int {
			return _postMidRollSeekPosition;
		}
		
		public function postMidRollSeekPositionAsTimestamp():String {
			return Timestamp.secondsToTimestamp(_postMidRollSeekPosition);
		}
		
		public function hasPostMidRollSeekPosition():Boolean {
			return _postMidRollSeekPosition > -1;
		}

		public function set enforceMidRollPlayback(enforceMidRollPlayback:Boolean):void {
			_enforceMidRollPlayback = enforceMidRollPlayback;
		}		
		
		public function get enforceMidRollPlayback():Boolean {
			return _enforceMidRollPlayback;
		}
		
		public function set holdingClipUrl(holdingClipUrl:String):void {
			this.vpaidConfig.holdingClipUrl = holdingClipUrl;
		}
		
		public function get holdingClipUrl():String {
			return this.vpaidConfig.holdingClipUrl;
		}

		public function set companionsConfig(companionsConfig:CompanionsConfigGroup):void {
			_companionsConfig = companionsConfig;
		}
		
		public function get companionsConfig():CompanionsConfigGroup {
			return _companionsConfig;
		}
		
		public function set skipAd(skipAd:SkipAdConfig):void {
			_skipAdConfig = new SkipAdConfig(skipAd);
		}
		
		public function get skipAd():SkipAdConfig {
			return _skipAdConfig;
		}
		
		public function isSkipAdButtonEnabled():Boolean {
			if(_skipAdConfig != null) {			
				return _skipAdConfig.enabled;
			}
			return false;
		}

		public function get skipAdButtonImage():String {
			if(_skipAdConfig != null) {
				return _skipAdConfig.image;
			}
			return "not-defined";
		}	

		public function setMetaDataConfigFromObject(metaData:Object):void {
			this.metaDataConfig = new AdMetaDataConfigGroup(metaData);
		}

		public function set metaDataConfig(metaDataConfig:AdMetaDataConfigGroup):void {
			_metaDataConfig = metaDataConfig;
		}
		
		public function get metaDataConfig():AdMetaDataConfigGroup {
			return _metaDataConfig;
		}

		public function getLinearAdTitle(defaultTitle:String="", duration:String="0", index:int=-1):String {
			if(_metaDataConfig != null) {
				return _metaDataConfig.getLinearAdTitle(defaultTitle, duration, index);			
			}
			return "";
		}

		public function getLinearAdDescription(defaultDescription:String="", duration:String="0", index:int=-1):String {
			if(_metaDataConfig != null) {
				return _metaDataConfig.getLinearAdDescription(defaultDescription, duration, index);			
			}
			return "";
		}
		
		protected function assignRuntimePropertiesToIndividualAdSlots(adTag:String = null):void {	
			if(_schedule != null) {
				CONFIG::debugging { doLog("Configuring the ad server requests across each ad slot - schedule length is " + _schedule.length + " ...", Debuggable.DEBUG_CONFIG); }
				var originalAdServerConfig:Object;
				var commonTags:Object = new Object();
				for(var i:int=0; i < _schedule.length; i++) {
					// this allows the specified adTag to be overridden
					if(adTag != null){
						_schedule[i].tag = adTag;					
					}

					// see if this ad slot uses a "common tag" that is shared across multiple slots. If so create it if it doesn't exist - if it
					// does already exist, just reference it
					
					if(_schedule[i].commonAdTag != undefined) {
						if(commonTags.hasOwnProperty(_schedule[i].commonAdTag.uid) == false) {
							commonTags[_schedule[i].commonAdTag.uid] = AdServerConfigFactory.getAdServerConfig(_schedule[i].commonAdTag.server.type);
							commonTags[_schedule[i].commonAdTag.uid].initialise(_schedule[i].commonAdTag.server);
						}
						_schedule[i].server = commonTags[_schedule[i].commonAdTag.uid];
					}
					else {
						// check if there is a direct ad "tag" specified for this spot - if so, configure as server: { type: "direct", tag: "..." }
	
						if(_schedule[i].tag != undefined) {
							if(_tagParams != null) {
								_schedule[i].server = { type: "direct", tag: _schedule[i].tag, customProperties: _tagParams };
							}
							else _schedule[i].server = { type: "direct", tag: _schedule[i].tag };								
						}
						
	
						// now check the ad server to use for this ad slot and assign accordingly
	
						if(_schedule[i].server == undefined) {
							// use the default ad server which is the first one defined
							_schedule[i].server = getDefaultAdServer(); //getDefaultAdServerCopy();
						}
						else {
							originalAdServerConfig = _schedule[i].server;
							if(_schedule[i].server.id == undefined) {
								if(_schedule[i].server.type != undefined) {
									_schedule[i].server = AdServerConfigFactory.getAdServerConfig(_schedule[i].server.type);
									if(_schedule[i].server == null) {
										CONFIG::debugging { doLog("Cannot link this ad slot to an ad server - unknown ad server type " + originalAdServerConfig.server.type, Debuggable.DEBUG_CONFIG); }
										continue;
									}
								}
								else _schedule[i].server = getDefaultAdServerCopy();						
							}
							else _schedule[i].server = getAdServerById(_schedule[i].server.id);
	
							// now override any settings
							if(originalAdServerConfig != null) _schedule[i].server.initialise(originalAdServerConfig);
						}
					}


					// check to see if "encodeVars" is set on the ad slot - if so, place it on the server setting

                    if(_schedule[i].hasOwnProperty("encodeVars")) {
                        _schedule[i].server.encodeVars = StringUtils.validateAsBoolean(_schedule[i].encodeVars);
                    }
                    
					// now add in the mime filtering rules so that they carry through to the VAST response parser

					if(hasSpecificAcceptedLinearAdMimeTypesDeclared()) {
						_schedule[i].server.acceptedLinearAdMimeTypes = this.acceptedLinearAdMimeTypes;
					}

					CONFIG::debugging { doLog("AdSlot: " + i + " - ad server type is " + _schedule[i].server.serverType + " on " + ((_schedule[i].server.tag != null) ? _schedule[i].server.tag : _schedule[i].server.apiServerAddress), Debuggable.DEBUG_CONFIG); }
				}
			}
			else {
				CONFIG::debugging { doLog("No ad servers configured - no ad schedule defined", Debuggable.DEBUG_CONFIG); }
			}
		}

		public function resetPlayerHeightOnAdServerRequests(newHeight:int):void {
			for(var i:int=0; i < _schedule.length; i++) {
				if(_schedule[i].server is AdServerConfig) {
					_schedule[i].server.playerHeight = newHeight;
				}
			}
		}

		public function resetPlayerWidthOnAdServerRequests(newWidth:int):void {
			for(var i:int=0; i < _schedule.length; i++) {
				if(_schedule[i].server is AdServerConfig) {
					_schedule[i].server.playerWidth = newWidth;					
				}
			}
		}
		
		public function get clickSignEnabled():Boolean {
			if(_clickSignConfig != null) {
				return _clickSignConfig.enabled;
			}	
			else return true;
		}
		
		public function set tag(adTag:String):void {
			if(_schedule.length == 0) {
				_schedule = [ { position: "pre-roll", tag: adTag } ];				
			}
			assignRuntimePropertiesToIndividualAdSlots(adTag);
		}
		
		public function hasStreamers():Boolean {
			return (_streamers != null);
		}
		
		public function set streamers(streamers:Array):void {
			_streamers = new Array();
			if(streamers != null) {
				for(var i:int=0; i < streamers.length; i++) {
					_streamers.push(new AdStreamerConfig(streamers[i]));
				}
			}
		}
		
		public function get streamers():Array {
			return _streamers;
		}
		
		public function set adServerConfig(adServerConfig:AdServerConfig):void {
			_adServerConfig = adServerConfig;	
		}
		
		public function get adServerConfig():AdServerConfig {
			if(_adServerConfig == null) {
				if(_adServers != null) return _adServers[0];
			}
			return _adServerConfig;
		}
		
		public function set adServers(servers:Array):void {
			_adServers = new Array();
			CONFIG::debugging { doLog("Configuring " + servers.length + " ad servers", Debuggable.DEBUG_CONFIG); }
			for(var i:int=0; i < servers.length; i++) {
				if(servers[i].type != undefined) {
					var adServerConfig:AdServerConfig = AdServerConfigFactory.getAdServerConfig(servers[i].type);
					adServerConfig.initialise(servers[i]);
					if(_tagParams != null) {
						adServerConfig.initialise({ tagParams: _tagParams });
					}
					_adServers.push(adServerConfig);		
				}
				else {
					CONFIG::debugging { doLog("Ad server configuration at position " + i + " skipped - no 'type' provided", Debuggable.DEBUG_CONFIG); }
				}
			}
		}
		
		public function get adServers():Array {
			return _adServers;
		}
		
		public function getDefaultAdServer():AdServerConfig {
			if(_adServers != null) {
				if(_adServers.length > 0) {
					var index:int = getDefaultAdServerIndex();
					if(AdServerConfig(_adServers[index]).oneAdPerRequest) {
						return _adServers[index].clone();
					}
					return _adServers[index];
				}
			}
			return new AdServerConfig();
		}
		
		public function getDefaultAdServerCopy():AdServerConfig {
			if(_adServers != null) {
				if(_adServers.length > 0) {
					return _adServers[getDefaultAdServerIndex()].clone();
				}
			}
			return getFirstAdServerCopy();
		}
		
		public function getFirstAdServerCopy():AdServerConfig {
			if(_adServers != null) {
				if(_adServers.length > 0) {
					return _adServers[0].clone();
				}					
			}
			return new AdServerConfig();
		}

		protected function getDefaultAdServerIndex():int {
			if(_adServers != null) {
				if(_adServers.length > 0) {
					for(var i:int=0; i < _adServers.length; i++) {
						if(_adServers[i].defaultAdServer) {
							return i;
						}
					}
				}
			}			
			return 0;
		}
		
		public function getAdServerById(id:String):AdServerConfig {
			if(_adServers != null) {
				for(var i:int = 0; i < _adServers.length; i++) {
					if(_adServers[i].matchesId(id)) return _adServers[i];
				}				
			}
			return new AdServerConfig();
		}

		public function set resetTrackingOnReplay(resetTrackingOnReplay:Boolean):void {
			_resetTrackingOnReplay = resetTrackingOnReplay;
		}
		
		public function get resetTrackingOnReplay():Boolean {
			return _resetTrackingOnReplay;
		}

		public function set forcePlayAfterVPAID(forcePlayAfterVPAID:Boolean):void {
			_forcePlayAfterVPAID = forcePlayAfterVPAID;
		}
		
		public function get forcePlayAfterVPAID():Boolean {
			return _forcePlayAfterVPAID;
		}

		public function set allowDuplicateODCuepoints(allowDuplicateODCuepoints:Boolean):void {
			_allowDuplicateODCuepoints = allowDuplicateODCuepoints;
		}
		
		public function get allowDuplicateODCuepoints():Boolean {
			return _allowDuplicateODCuepoints;
		}
		
		public function set pauseOnClickThrough(pauseOnClickThrough:Boolean):void {
			_pauseOnClickThrough = pauseOnClickThrough;
		}
		
		public function get pauseOnClickThrough():Boolean {
			return _pauseOnClickThrough;
		}

		public function vpaidMaxDurationTimeoutEnabled():Boolean {
			return _vpaidConfig.enableMaxDurationTimeout;	
		}

		public function get vpaidMaxDurationTimeout():int {
			return _vpaidConfig.maxDurationTimeout;				
		}

		public function set tagParams(tagParams:Object):void {
			_tagParams = tagParams;
		}
		
		public function get tagParams():Object {
			return _tagParams;
		}
		
		public function hasLinearScalingPreference():Boolean {
			return (_linearScaling != null);	
		}
		
		public function set linearScaling(linearScaling:String):void {
			_linearScaling = linearScaling;
		}
		
		public function get linearScaling():String {
			return _linearScaling;
		}

		public function set enforceLinearInteractiveAdScaling(enforceLinearInteractiveAdScaling:Boolean):void {
			_enforceLinearInteractiveAdScaling = enforceLinearInteractiveAdScaling;
		}
		
		public function get enforceLinearInteractiveAdScaling():Boolean {
			return _enforceLinearInteractiveAdScaling;
		}
		
		public function set enforceLinearVideoAdScaling(enforceLinearVideoAdScaling:Boolean):void {
			_enforceLinearVideoAdScaling = enforceLinearVideoAdScaling;
		}
		
		public function get enforceLinearVideoAdScaling():Boolean {
			return _enforceLinearVideoAdScaling;
		}
		
		public function set enforceLinearAdsOnPlaylistSelection(enforceLinearAdsOnPlaylistSelection:Boolean):void {
			_enforceLinearAdsOnPlaylistSelection = enforceLinearAdsOnPlaylistSelection;
		}
		
		public function get enforceLinearAdsOnPlaylistSelection():Boolean {
			return _enforceLinearAdsOnPlaylistSelection;
		}

		public function get replayOverlays():Boolean {
			return _overlaysConfig.replay;
		}

		public function set allowDomains(allowDomains:String):void {
			_allowDomains = allowDomains;
		}
		
		public function get allowDomains():String {
			return _allowDomains;
		}

		public function set activelySchedule(activelySchedule:Boolean):void {
			_activelySchedule = activelySchedule;
		}
		
		public function get activelySchedule():Boolean {
			return _activelySchedule;
		}
		
		public function hasCompanionDivs():Boolean {
			return _companionsConfig.hasCompanionDivs();
		}
		
		public function get companionDivIDs():Array {
			return _companionsConfig.companionDivIDs;
		}
		
		public function get displayCompanions():Boolean {
			return _companionsConfig.displayCompanions;
		}

		public function get processCompanionDisplayExternally():Boolean {
			if(nativeDisplay == false) {
				return true;
			}
			return (_companionsConfig.nativeDisplay == false);
        }

		public function set nativeDisplay(nativeDisplay:Boolean):void {
			_nativeDisplay = nativeDisplay;
		}
		
		public function get nativeDisplay():Boolean {
			return _nativeDisplay; 
        }
  
		public function get restoreCompanions():Boolean {
			return _companionsConfig.restoreCompanions;
		}

		public function get millisecondDelayOnCompanionInjection():int {
			return _companionsConfig.millisecondDelayOnCompanionInjection;
		}
		
		public function delayingCompanionInjection():Boolean {
			return _companionsConfig.delayingCompanionInjection();
		}

		public function get additionalParamsForSWFCompanions():Array {
			return _companionsConfig.additionalParamsForSWFCompanions;
		}
		
        public function showNotice():Boolean {
        	if(_noticeConfig != null) {
        		return _noticeConfig.show;
        	}	
        	return false;
        }
        
		public function set notice(newNotice:Object):void {
			_noticeConfig = new AdNoticeConfig(newNotice);
		}
		
		public function get notice():Object {
			return _noticeConfig;
		}

		public function set rtmpSubscribe(rtmpSubscribe:Boolean):void {
			if(_providersConfig == null) _providersConfig = new ProvidersConfigGroup();
			_providersConfig.rtmpSubscribe = rtmpSubscribe;				
		}
		
		public function get rtmpSubscribe():Boolean {
			if(_providersConfig != null) {
				return _providersConfig.rtmpSubscribe;
			}
			return false;
		}

        public function canSkipOnLinearAd():Boolean {
        	return _skipAdConfig.enabled;
        }

        public function get skipAdConfig():SkipAdConfig {
        	return _skipAdConfig;
        }
		
		public function set vpaid(vpaid:Object):void {
			this.vpaidConfig = new VPAIDConfig(vpaid);
		}
		
		public function set vpaidConfig(vpaidConfig:VPAIDConfig):void {
			_vpaidConfig = vpaidConfig;
		}
		
		public function get vpaidConfig():VPAIDConfig {
			return _vpaidConfig;
		}
		
		protected function adSlotIsLinear(position:String):Boolean {
			if(StringUtils.matchesIgnoreCase(position, "PRE-ROLL")) {
				return true;
			}	
			else if(StringUtils.matchesIgnoreCase(position, "MID-ROLL")) {
				return true;
			}	
			else if(StringUtils.matchesIgnoreCase(position, "POST-ROLL")) {
				return true;
			}	
			return false;
		}
		
	    /** When setting the schedule, there is a bit of pre-processing that has to happen
	     *    1) Make sure all options are applied across the ad slots
		 *    2) Make sure the schedule is in 'order'
		 **/
		public function set schedule(schedule:Array):void {
			if(schedule != null) {				
				var processedSchedule:Array = new Array();
				
				// 1) Make sure all options are applied across the ad slots
				
				for(var i:int=0; i < schedule.length; i++) {
					if(schedule[i].hasOwnProperty("notice")) {
						if((schedule[i].notice is AdNoticeConfig) == false) {
							schedule[i].notice = new AdNoticeConfig(schedule[i]["notice"]);
						}
					}
					else schedule[i].notice = this.notice;
					if(schedule[i].hasOwnProperty("interval") && schedule[i].hasOwnProperty("repeat")) {
						if(schedule[i].interval > 0 && schedule[i].repeat > 0) {
							// ok, we have an ad slot with a valid "interval" declared - expand it
							var commonAdTag:Object = null;
							if(schedule[i].hasOwnProperty("oneAdPerRequest") && schedule[i].hasOwnProperty("tag")) {
								if(schedule[i].oneAdPerRequest == false) {
									commonAdTag = {
										uid: i,
										server: { 
											"type": "direct",
											"tag": schedule[i].tag,
											"oneAdPerRequest": false
										}
									};
								}
							}
							if(schedule[i].hasOwnProperty("server")) {
								if(schedule[i].server != null) {
									if(schedule[i].server.hasOwnProperty("oneAdPerRequest")) {
										if(schedule[i].server.oneAdPerRequest == false) {
											commonAdTag = {
												uid: i,
												server: schedule[i].server
											}
											if(commonAdTag.server.type == undefined) {
												commonAdTag.server.type = "direct";
											}
										}
									}							
								}
							}
							for(var j:int=0; j < schedule[i].repeat; j++) {
								var newObject:Object = new Object();
								newObject.copyCount = j;
								newObject.startTime = Timestamp.addSecondsToTimestamp(schedule[i].startTime, (schedule[i].interval * j)); 
								if(commonAdTag != null) {
									newObject["commonAdTag"] = commonAdTag;
								}
								for(var prop:String in schedule[i]) {
									if(commonAdTag != null) {
										if(prop == "server" || prop == "tag" || prop == "oneAdPerRequest") {
											// the common tag is in play, so ignore these settings
											continue;
										}
									}
									if(prop != "interval" && prop != "startTime" && prop != "repeat") {
										newObject[prop] = schedule[i][prop];
									}
								}
								processedSchedule.push(newObject);
							}
						}
					}	
					else {
						if(schedule[i].hasOwnProperty("oneAdPerRequest")) {
							if(schedule[i].hasOwnProperty("tag")) {
								schedule[i].server = {
									"type": "direct",
									"tag": schedule[i].tag,
									"oneAdPerRequest": schedule[i].oneAdPerRequest
								}
								delete schedule[i].tag;
								delete schedule[i].oneAdPerRequest;
							}
							else if(schedule[i].hasOwnProperty("server")) {
								schedule[i].server.oneAdPerRequest = schedule[i].oneAdPerRequest;
								delete schedule[i].oneAdPerRequest;
							}
						}
						processedSchedule.push(schedule[i]);
					}
				}
				
				// 2) Make sure the schedule is in 'order' - the order is pre-rolls, mid/overlays by startTime, post-rolls

				var pres:Array = new Array();
				var mids:Array = new Array();
				var posts:Array = new Array();

				// Add pre-rolls
				for(var k:int=0; k < processedSchedule.length; k++) {
					if(StringUtils.matchesIgnoreCase(processedSchedule[k].position, "pre-roll")) {
						pres.push(processedSchedule[k]);
					}
					else if(StringUtils.matchesIgnoreCase(processedSchedule[k].position, "post-roll")) {
						posts.push(processedSchedule[k]);
					}
					else {
						mids.push(processedSchedule[k]);
					}
				}

				// Mid-rolls and overlays should now be added in sorted by "startTime" so do this before
				// putting the schedule back together
				mids.sort(
					function(adSlotA:Object, adSlotB:Object):Number {
						// compare to adslots by assessing their "startTime"
						if(adSlotA.startTime != undefined) {
							if(adSlotB.startTime != undefined) {
								var aSeconds:int = Timestamp.timestampToSeconds(adSlotA.startTime);
								var bSeconds:int = Timestamp.timestampToSeconds(adSlotB.startTime);
								if(aSeconds > bSeconds) {
									return 1;
								}	
								else if(aSeconds < bSeconds) {
									return -1;
								}
								else return 0; // equal
							}
							return -1;
						} 
						return -1;
					}
				);

                // Now put the ordered schedule back together				
				_schedule = pres;
				_schedule = _schedule.concat(mids);
				_schedule = _schedule.concat(posts);
			}
			else _schedule = null;
		}

		public function get schedule():Array {
			return _schedule;
		}
		
		public function set acceptedLinearAdMimeTypes(acceptedLinearMimeTypes:Array):void {
			_acceptedLinearAdMimeTypes = acceptedLinearMimeTypes;
		}

		public function get acceptedLinearAdMimeTypes():Array {
			return _acceptedLinearAdMimeTypes;
		}

		public function set filterOnLinearAdMimeTypes(enableFilterOnLinearAdMimeTypes:Boolean):void {
			_filterOnLinearAdMimeTypes = enableFilterOnLinearAdMimeTypes;
		}

		public function get filterOnLinearAdMimeTypes():Boolean {
			return _filterOnLinearAdMimeTypes;
		}
		
		public function hasSpecificAcceptedLinearAdMimeTypesDeclared():Boolean {
			if(_acceptedLinearAdMimeTypes != null) {
				return (_acceptedLinearAdMimeTypes.length > 0);
			}
			return false;
		}

		public function set visuallyCueLinearAdClickThrough(visuallyCueLinearAdClickThrough:Boolean):void {
			_visuallyCueLinearAdClickThrough = visuallyCueLinearAdClickThrough;
		}
		
		public function get visuallyCueLinearAdClickThrough():Boolean {
			return _visuallyCueLinearAdClickThrough;
		}
		
		public function set clickSignConfig(clickSignConfig:ClickSignConfig):void {
			_clickSignConfig = clickSignConfig;
		}
		
		public function get clickSignConfig():ClickSignConfig {
			return _clickSignConfig;
		}
	}
}
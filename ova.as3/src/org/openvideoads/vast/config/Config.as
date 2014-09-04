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
package org.openvideoads.vast.config {
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.vast.server.config.AdServerConfig;
	import org.openvideoads.vast.config.groupings.AbstractStreamsConfig;
	import org.openvideoads.vast.config.groupings.AdsConfigGroup;
	import org.openvideoads.vast.config.groupings.DebugConfigGroup;
	import org.openvideoads.vast.config.groupings.PlayerConfigGroup;
	import org.openvideoads.vast.config.groupings.ProvidersConfigGroup;
	import org.openvideoads.vast.config.groupings.RegionsConfigGroup;
	import org.openvideoads.vast.config.groupings.RemoteConfigGroup;
	import org.openvideoads.vast.config.groupings.ShowsConfigGroup;
	import org.openvideoads.vast.config.groupings.analytics.AnalyticsConfigGroup;
	import org.openvideoads.vast.playlist.Playlist;
	
	/**
	 * @author Paul Schulz
	 */
	public class Config extends AbstractStreamsConfig implements ConfigLoadListener {
		protected var _adsConfig:AdsConfigGroup = new AdsConfigGroup();
		protected var _regionsConfig:RegionsConfigGroup = new RegionsConfigGroup();
		protected var _showsConfig:ShowsConfigGroup = new ShowsConfigGroup();
		protected var _debugConfig:DebugConfigGroup = new DebugConfigGroup();
		protected var _openVideoAdsConfig:RemoteConfigGroup = new RemoteConfigGroup();
		protected var _playerSpecificConfig:PlayerConfigGroup = new PlayerConfigGroup();
		protected var _analyticsConfig:AnalyticsConfigGroup = new AnalyticsConfigGroup();
		protected var _supportExternalPlaylistLoading:Boolean = false;
		protected var _autoPlayOnExternalLoad:Boolean = false;

		public function Config(config:Object=null, onLoadedListener:ConfigLoadListener=null) {
			super(config, onLoadedListener);
			if(config != null || onLoadedListener != null) {
				initialise(config, onLoadedListener);
			}
		}
		
		public override function initialise(config:Object=null, onLoadedListener:ConfigLoadListener=null, forceEnable:Boolean=false):void {
			super.initialise(config, onLoadedListener);
			if(config != null) {
				if(config.shows != undefined) {
					this.shows = config.shows;
				}
				else _showsConfig.initialise(null, this);
				if(config.regions != undefined) {
					this.regions = config.regions;
				}
				else _regionsConfig.initialise(null, this);
				if(config.tagParams != undefined) {
					this.adsConfig.tagParams = config.tagParams;
				}
				if(config.ads != undefined) {
					this.ads = config.ads;
				}
				else _adsConfig.initialise(null, this);
				if(config.tag != undefined) {
					this.adsConfig.tag = config.tag;
				}
				if(config.providers != undefined) {
					this.providers = config.providers;						
				}
				if(config.debug != undefined) {
					this.debug = config.debug;
				}
				else _debugConfig.initialise(null, this);
				if(config.player != undefined) {
					this.player = config.player;
				}
				else _playerSpecificConfig.initialise(null, this);
				if(config.analytics != undefined) {
					this.analytics = config.analytics;
				}			
				else _analyticsConfig.initialise(null, this);	
				if(config.supportExternalPlaylistLoading != undefined) {
					if(config.supportExternalPlaylistLoading is String) {
						this.supportExternalPlaylistLoading = ((config.supportExternalPlaylistLoading.toUpperCase() == "TRUE") ? true : false);											
					}
					else this.supportExternalPlaylistLoading = config.supportExternalPlaylistLoading;		
				}	
				if(config.autoPlayOnExternalLoad != undefined) {
					if(config.autoPlayOnExternalLoad is String) {
						this.autoPlayOnExternalLoad = ((config.autoPlayOnExternalLoad.toUpperCase() == "TRUE") ? true : false);											
					}
					else this.autoPlayOnExternalLoad = config.autoPlayOnExternalLoad;		
				}	
				
				// Check to see if the player width and height have been declared. If so, set the values in the ad server config
				// blocks in case the values are required by the ad tags
				
				if(_playerSpecificConfig != null) {
					if(_playerSpecificConfig.hasPlayerHeight()) {
						_adsConfig.resetPlayerHeightOnAdServerRequests(_playerSpecificConfig.height);
					}
					if(_playerSpecificConfig.hasPlayerWidth()) {
						_adsConfig.resetPlayerWidthOnAdServerRequests(_playerSpecificConfig.width);
					}
				}
			}
			onOVAConfigLoaded();
		}
		
		public function signalInitialisationComplete():void {
			if(_adsConfig.initialising() == false) _adsConfig.markAsLoaded();
			if(_regionsConfig.initialising() == false) _regionsConfig.markAsLoaded();
			if(_showsConfig.initialising() == false) _showsConfig.markAsLoaded();
			if(_debugConfig.initialising() == false) _debugConfig.markAsLoaded();
			if(_openVideoAdsConfig.initialising() == false) _openVideoAdsConfig.markAsLoaded();
			if(_analyticsConfig.initialising() == false) _analyticsConfig.markAsLoaded();
			if(_playerSpecificConfig.initialising() == false) _playerSpecificConfig.markAsLoaded();
		}
		
		public override function setLoadedListener(onLoadListener:ConfigLoadListener):void {
			_onLoadedListener = onLoadListener;
			onOVAConfigLoaded();
		}
		
		public override function onOVAConfigLoaded():void {
			if(!_adsConfig.isOVAConfigLoading() &&
			   !_regionsConfig.isOVAConfigLoading() &&
			   !_showsConfig.isOVAConfigLoading() &&
			   !_debugConfig.isOVAConfigLoading() &&
			   !_openVideoAdsConfig.isOVAConfigLoading() &&
			   !_analyticsConfig.isOVAConfigLoading() &&
			   !_playerSpecificConfig.isOVAConfigLoading()) {
			   
			   if(_onLoadedListener != null) _onLoadedListener.onOVAConfigLoaded();
			}
		}
		
		public override function isOVAConfigLoading():Boolean {
			return _adsConfig.isOVAConfigLoading() || _regionsConfig.isOVAConfigLoading() || 
			       _showsConfig.isOVAConfigLoading() || _debugConfig.isOVAConfigLoading() || 
			       _openVideoAdsConfig.isOVAConfigLoading();
		}	

		public function loadShowStreamsConfigFromPlaylist(playlist:Playlist):void {
			_showsConfig.streams = playlist.toShowStreamsConfigArray();
		}

		public function hasPlayerHeight():Boolean {
			if(_playerSpecificConfig != null) {
				return _playerSpecificConfig.hasPlayerHeight();
			}
			return false;
		}

		public function hasPlayerWidth():Boolean {
			if(_playerSpecificConfig != null) {
				return _playerSpecificConfig.hasPlayerWidth();
			}
			return false;
		}

		public function set playerHeight(playerHeight:int):void {
			if(_playerSpecificConfig == null) _playerSpecificConfig = new PlayerConfigGroup();
			_playerSpecificConfig.height = playerHeight;
			if(_adsConfig != null) _adsConfig.resetPlayerHeightOnAdServerRequests(_playerSpecificConfig.height);
		}
		
		public function get playerHeight():int {
			if(_playerSpecificConfig != null) {
				return _playerSpecificConfig.height;
			}
			return -1;
		}
		

		public function set playerWidth(playerWidth:int):void {
			if(_playerSpecificConfig == null) _playerSpecificConfig = new PlayerConfigGroup();
			_playerSpecificConfig.width = playerWidth;
			if(_adsConfig != null) _adsConfig.resetPlayerWidthOnAdServerRequests(_playerSpecificConfig.width);
		}
		
		public function get playerWidth():int {
			if(_playerSpecificConfig != null) {
				return _playerSpecificConfig.width;
			}
			return -1;
		}

		public function set supportExternalPlaylistLoading(supportExternalPlaylistLoading:Boolean):void {
			_supportExternalPlaylistLoading = supportExternalPlaylistLoading;
		}
		
		public function get supportExternalPlaylistLoading():Boolean {
			return _supportExternalPlaylistLoading;
		}

		public function set autoPlayOnExternalLoad(autoPlayOnExternalLoad:Boolean):void {
			_autoPlayOnExternalLoad = autoPlayOnExternalLoad;
		}
		
		public function get autoPlayOnExternalLoad():Boolean {
			return _autoPlayOnExternalLoad;
		}
		
		public function delayingCompanionInjection():Boolean {
			return _adsConfig.delayingCompanionInjection();
		}
		
		public function get millisecondDelayOnCompanionInjection():int {
			return _adsConfig.millisecondDelayOnCompanionInjection;
		}
		
		public function set analytics(config:*):void {
			if(config is AnalyticsConfigGroup) {
				_analyticsConfig = config;
				_analyticsConfig.initialise(null, this, true);
			}
			else {
				_analyticsConfig.initialise(config, this, true);
			}
		}
		
		public function get analytics():AnalyticsConfigGroup {
			return _analyticsConfig;
		}

		public function set tag(adTag:String):void {
			if(_adsConfig != null) _adsConfig.tag = adTag;
		}
		
		public function set tagParams(tagParams:Object):void {
			if(_adsConfig != null) _adsConfig.tagParams = tagParams;
		}

		public function areProxiesEnabledForShowStreams():Boolean {
			return _showsConfig.enableProxies;
		}

		public function areProxiesEnabledForAdStreams():Boolean {
			return _adsConfig.enableProxies;
		}

		public function canSkipOnLinearAd():Boolean {
			return _adsConfig.canSkipOnLinearAd();
		}

		public function getLinearVPAIDRegionID():String {
			return _adsConfig.vpaidConfig.getLinearRegion(!_playerSpecificConfig.shouldHideControlsOnLinearPlayback(true));
		}

		public function getNonLinearVPAIDRegionID():String {
			return _adsConfig.vpaidConfig.nonLinearRegion;
		}

		public function vpaidMaxDurationTimeoutEnabled():Boolean {
			return _adsConfig.vpaidMaxDurationTimeoutEnabled();	
		}
		
		public function get vpaidMaxDurationTimeout():int {
			return _adsConfig.vpaidMaxDurationTimeout;				
		}

		public function controlEnabledForLinearAdType(controlName:String, isVPAID:Boolean):Boolean {
			return _playerSpecificConfig.controlEnabledForLinearAdType(controlName, isVPAID);
		}
						
		public function get scheduleAds():Boolean {
			return _adsConfig.activelySchedule;
		}

		public function set shows(config:Object):void {
			if(config.player != undefined) {
				config.player = this.player;
			}
			_showsConfig.initialise(config, this);
		}
		
		public function get showsConfig():ShowsConfigGroup {
			return _showsConfig;
		}
		
		public function set showsConfig(showsConfig:ShowsConfigGroup):void {
			_showsConfig = showsConfig;
		}

		public function hasShowsDefined():Boolean {
			return _showsConfig.hasShowStreamsDefined();
		}

		public function set regions(config:Object):void {
			_regionsConfig = new RegionsConfigGroup();
			_regionsConfig.initialise(config, this);
		}
		
		public function get regionsConfig():RegionsConfigGroup {
			return _regionsConfig;
		}
		
		public override function set player(config:Object):void {
			if(_playerSpecificConfig == null) _playerSpecificConfig = new PlayerConfigGroup(); 
			_playerSpecificConfig.initialise(config, this);
		}
		
		public function set playerConfig(playerConfig:PlayerConfigGroup):void {
			_playerSpecificConfig = playerConfig;
		}
		
		public function get playerConfig():PlayerConfigGroup {
			return _playerSpecificConfig;
		}
		
		public function set ads(config:Object):void {
			if(config != null) {
				if(config.player != undefined) {
					config.player = this.player;
				}
				_adsConfig.initialise(config, this); 			
			}
		}
		
		public function get adsConfig():AdsConfigGroup {
			return _adsConfig;
		}
		
		public function get openVideoAdsConfig():RemoteConfigGroup {
			return _openVideoAdsConfig;
		}
		
		public function get pauseOnClickThrough():Boolean {
			return _adsConfig.pauseOnClickThrough;
		}

		public function deriveAdDurationFromMetaData():Boolean {
			return _adsConfig.setDurationFromMetaData;
		}

		public function deriveShowDurationFromMetaData():Boolean {
			return _showsConfig.setDurationFromMetaData;
		}
		
		public function operateWithoutStreamDuration():Boolean {
			return _showsConfig.mustOperateWithoutDuration();
		}

		public function get adServerConfig():AdServerConfig {
			return _adsConfig.adServerConfig;
		}

		public function set debug(config:Object):void {
			_debugConfig = new DebugConfigGroup(); 
			_debugConfig.initialise(config, this);
		}
		
		// INTERFACES
		
		public function hasStreams():Boolean {
			return _showsConfig.hasShowStreamsDefined();
		}
		
		public function set streams(streams:Array):void {
			_showsConfig.streams = streams;
		}
		
		public function get streams():Array {
			return _showsConfig.streams;
		}
		
		public function prependStreams(streams:Array):void {
			_showsConfig.prependStreams(streams);
		}
		
		public function get previewImage():String {
			if(_showsConfig != null) {
				return _showsConfig.getPreviewImage();
			}
			else return null;
		}
		
		public function hasCompanionDivs():Boolean {
			return _adsConfig.hasCompanionDivs();
		}
		
		public function get companionDivIDs():Array {
			return _adsConfig.companionDivIDs;
		}
		
		public function get displayCompanions():Boolean {
			return _adsConfig.displayCompanions;
		}

		public function get restoreCompanions():Boolean {
			return _adsConfig.restoreCompanions;
		}

		public function get processCompanionDisplayExternally():Boolean {
			return _adsConfig.processCompanionDisplayExternally;
		}
		
		public function get processHTML5NonLinearDisplayExternally():Boolean {
			return (_adsConfig.nativeDisplay == false);
		}
		
		public function get notice():Object {
			return _adsConfig.notice;
		}

		public function get showNotice():Boolean {
			return _adsConfig.showNotice();
		}
		
		public function get clickSignEnabled():Boolean {
			return _adsConfig.clickSignEnabled;
		}

		public function get adSchedule():Array {
			return _adsConfig.schedule;
		}

        public override function hasProviders():Boolean {
        	return (_showsConfig.hasProviders() && _adsConfig.hasProviders());	
        }
        
        public override function setDefaultProviders():void {
        	_providersConfig = new ProvidersConfigGroup();
        	_showsConfig.setDefaultProviders();
        	_adsConfig.setDefaultProviders();
        }

        public function ensureProvidersAreSet():void {
        	if(_providersConfig == null) _providersConfig = new ProvidersConfigGroup();
        	if(!_showsConfig.hasProviders()) _showsConfig.setDefaultProviders();
        	if(!_adsConfig.hasProviders()) _adsConfig.setDefaultProviders();
        }
        
        public function setMissingProviders(httpProvider:String, rtmpProvider:String):void {
        	if(_providersConfig == null) {
        		CONFIG::debugging { doLog("Setting missing GENERAL providers...", Debuggable.DEBUG_CONFIG); }
				_providersConfig = new ProvidersConfigGroup();
				_providersConfig.httpProvider = httpProvider;
				_providersConfig.rtmpProvider = rtmpProvider;        	
        	}
        	if(!_showsConfig.hasProviders()) {
        		CONFIG::debugging { doLog("Setting missing SHOW providers...", Debuggable.DEBUG_CONFIG); }
        		_showsConfig.setDefaultProviders();
        		_showsConfig.httpProvider = httpProvider;
        		_showsConfig.rtmpProvider = rtmpProvider;
        	}
        	if(!_adsConfig.hasProviders()) {
        		CONFIG::debugging { doLog("Setting missing AD providers...", Debuggable.DEBUG_CONFIG); }
        		_adsConfig.setDefaultProviders();
        		_adsConfig.httpProvider = httpProvider;
        		_adsConfig.rtmpProvider = rtmpProvider;
        	}
        }
        
		public override function set rtmpProvider(rtmpProvider:String):void {
			providersConfig.rtmpProvider = rtmpProvider;
			_showsConfig.rtmpProvider = rtmpProvider;	
			_adsConfig.rtmpProvider = rtmpProvider;
		}
		
		public override function set httpProvider(httpProvider:String):void {
			providersConfig.httpProvider = httpProvider;
			_showsConfig.httpProvider = httpProvider;	
			_adsConfig.httpProvider = httpProvider;
		}
		
		public function providersForShows():ProvidersConfigGroup {
			return _showsConfig.providersConfig;
		}

		public function providersForAds():ProvidersConfigGroup {
			return _adsConfig.providersConfig;
		}

		public function getProviderForShow(providerType:String):String {
			return _showsConfig.getProvider(providerType);
		}

		public function set rtmpProviderForShow(rtmpProvider:String):void {
			_showsConfig.rtmpProvider = rtmpProvider;	
		}
		
		public function get rtmpProviderForShow():String {
			return _showsConfig.rtmpProvider;
		}

		public function set httpProviderForShow(httpProvider:String):void {
			_showsConfig.httpProvider = httpProvider;	
		}

		public function get httpProviderForShow():String {
			return _showsConfig.httpProvider;
		}

		public function getProviderForAds(providerType:String):String {
			return _adsConfig.getProvider(providerType);
		}

		public function set rtmpProviderForAds(rtmpProvider:String):void {
			_adsConfig.rtmpProvider = rtmpProvider;	
		}
		
		public function get rtmpProviderForAds():String {
			return _adsConfig.rtmpProvider;
		}

		public function set httpProviderForAds(httpProvider:String):void {
			_adsConfig.httpProvider = httpProvider;	
		}

		public function get httpProviderForAds():String {
			return _adsConfig.httpProvider;
		}

		public override function get allowPlaylistControl():Boolean {
			return ((_showsConfig.allowPlaylistControlHasChanged()) ? _showsConfig.allowPlaylistControl : _allowPlaylistControl);
		}
		
		public override function get playOnce():Boolean {
			return ((_adsConfig.playOnceHasChanged()) ? _adsConfig.playOnce : _playOnce);
		}

		public override function get deliveryType():String {
			return ((_showsConfig.deliveryTypeHasChanged()) ? _showsConfig.deliveryType : 
			        ((_adsConfig.deliveryTypeHasChanged()) ? _adsConfig.deliveryType : _deliveryType));
		}
		
		public override function get baseURL():String {
			return ((_showsConfig.baseURLHasChanged()) ? _showsConfig.baseURL : 
			        ((_adsConfig.baseURLHasChanged()) ? _adsConfig.baseURL : _baseURL));
		}
				
		public override function get streamType():String {
			return ((_showsConfig.streamTypeHasChanged()) ? _showsConfig.streamType : 
			        ((_adsConfig.streamTypeHasChanged()) ? _adsConfig.streamType : _streamType));
		}

		public override function get subscribe():Boolean {
			return ((_showsConfig.subscribeHasChanged()) ? _showsConfig.subscribe : 
			        ((_adsConfig.subscribeHasChanged()) ? _adsConfig.subscribe : _subscribe));
		}

		public override function get bitrate():* {
			return ((_showsConfig.hasBitrate()) ? _showsConfig.bitrate : 
			        ((_adsConfig.hasBitrate()) ? _adsConfig.bitrate : _bitrate));
		}

		public function get visuallyCueLinearAdClickThrough():Boolean {
			return _adsConfig.visuallyCueLinearAdClickThrough;	
		}

		public function set acceptedLinearAdMimeTypes(types:Array):void {
			_adsConfig.acceptedLinearAdMimeTypes = types;	
		}
		
		public function get acceptedLinearAdMimeTypes():Array {
			return _adsConfig.acceptedLinearAdMimeTypes;
		}

		public function set filterOnLinearAdMimeTypes(enableFilterOnLinearAdMimeTypes:Boolean):void {
			_adsConfig.filterOnLinearAdMimeTypes = enableFilterOnLinearAdMimeTypes;
		}

		public function get filterOnLinearAdMimeTypes():Boolean {
			return _adsConfig.filterOnLinearAdMimeTypes;
		}
		
		public function debuggersSpecified():Boolean {
			return _debugConfig.debuggersSpecified();
		}
		
		public function get debugger():String {
			return _debugConfig.debugger;
		}
		
		public function outputingDebug():Boolean {
			return _debugConfig.outputingDebug();
		}
		
		public function get debugLevel():String {
			return _debugConfig.levels;
		}
		
		public function debugLevelSpecified():Boolean {
			return _debugConfig.debugLevelSpecified();
		}
	}
}
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
import flash.external.ExternalInterface;
	
	import org.openvideoads.vast.config.ConfigLoadListener;
	
	/**
	 * @author Paul Schulz
	 */
	public class AbstractStreamsConfig extends ConfigLoader {
		protected static var DEFAULT_BASE_URL:String = null;
		protected static var DEFAULT_STREAM_TYPE:String = "any";
		protected static var DEFAULT_DELIVERY_TYPE:String = "any";
		protected static var DEFAULT_BIT_RATE:String = "any";
		protected static var DEFAULT_SUBSCRIBE:Boolean = false;
		protected static var DEFAULT_PLAY_ALLOW_PLAYLIST_CONTROL:Boolean = false;
		protected static var DEFAULT_PLAY_ONCE:Boolean = false;
		
		protected var _baseURL:String = DEFAULT_BASE_URL;
		protected var _streamType:String = DEFAULT_STREAM_TYPE;
		protected var _deliveryType:String = DEFAULT_DELIVERY_TYPE;
		protected var _subscribe:Boolean = DEFAULT_SUBSCRIBE;
		protected var _allowPlaylistControl:Boolean = DEFAULT_PLAY_ALLOW_PLAYLIST_CONTROL;
		protected var _clearPlaylist:Boolean = true;
		protected var _playOnce:Boolean = DEFAULT_PLAY_ONCE;
		protected var _metaData:Boolean = true;
		protected var _autoPlay:Boolean = false;
		protected var _fireTrackingEvents:Boolean = false;
		protected var _ignoreDuration:Boolean = false;
		protected var _stripFileExtensions:Boolean = false;
		protected var _playerConfig:Object = new Object();
		protected var _providersConfig:ProvidersConfigGroup = null;
		protected var _setDurationFromMetaData:Boolean = false;
		protected var _bitrate:* = -1;
		protected var _width:int = -1;
		protected var _height:int = -1;		
		protected var _turnOnCountdownTimer:Boolean = false;
		CONFIG::callbacks { 
			protected var _canFireAPICalls:Boolean = true; 
			protected var _canFireEventAPICalls:Boolean = false;
			protected var _useV2APICalls:Boolean = false;
		}
		protected var _delayAdRequestUntilPlay:Boolean = false;
		protected var _enableProxies:Boolean = false;

		public function AbstractStreamsConfig(config:Object=null, onLoadedListener:ConfigLoadListener=null) {
			super(config, onLoadedListener);
		}
		
		public override function initialise(config:Object=null, onLoadedListener:ConfigLoadListener=null, forceEnable:Boolean=false):void {
			super.initialise(config, onLoadedListener);
			if(config != null) {
				if(config.baseURL != undefined) {
					this.baseURL = config.baseURL;					
				}
				if(config.streamType != undefined) {					
					this.streamType = config.streamType;
				}
				if(config.metaData != undefined) {
					if(config.metaData is String) {
						this.metaData = ((config.metaData.toUpperCase() == "TRUE") ? true : false);											
					}
					else this.metaData = config.metaData;					
				}
				CONFIG::callbacks {
					if(config.canFireAPICalls != undefined) {
						if(config.canFireAPICalls is String) {
							this.canFireAPICalls = ((config.canFireAPICalls.toUpperCase() == "TRUE") ? true : false);											
						}
						else this.canFireAPICalls = config.canFireAPICalls;					
					}
					if(config.canFireEventAPICalls != undefined) {
						if(config.canFireEventAPICalls is String) {
							this.canFireEventAPICalls = ((config.canFireEventAPICalls.toUpperCase() == "TRUE") ? true : false);											
						}
						else this.canFireEventAPICalls = config.canFireEventAPICalls;					
					}
					if(config.useV2APICalls != undefined) {
						if(config.useV2APICalls is String) {
							this.useV2APICalls = ((config.useV2APICalls.toUpperCase() == "TRUE") ? true : false);											
						}
						else this.useV2APICalls = config.useV2APICalls;					
					}
				}
				if(config.setDurationFromMetaData != undefined) {
					if(config.setDurationFromMetaData is String) {
						_setDurationFromMetaData = ((config.setDurationFromMetaData.toUpperCase() == "TRUE") ? true : false);					
					}
					else _setDurationFromMetaData = config.setDurationFromMetaData;		
				}
				if(config.delayAdRequestUntilPlay != undefined) {
					if(config.delayAdRequestUntilPlay is String) {
						_delayAdRequestUntilPlay = ((config.delayAdRequestUntilPlay.toUpperCase() == "TRUE") ? true : false);					
					}
					else _delayAdRequestUntilPlay = config.delayAdRequestUntilPlay;				
				}
				if(config.enableProxies != undefined) {
					if(config.enableProxies is String) {
						_enableProxies = ((config.enableProxies.toUpperCase() == "TRUE") ? true : false);					
					}
					else _enableProxies = config.enableProxies;		
				}
				if(config.stripFileExtensions != undefined) {
					if(config.stripFileExtensions is String) {
						this.stripFileExtensions = ((config.stripFileExtensions.toUpperCase() == "TRUE") ? true : false);											
					}
					else this.stripFileExtensions = config.stripFileExtensions;					
				}
				if(config.bitrate != undefined) {
					if(config.bitrate is String) {
						var upperBitrate:String = config.bitrate.toUpperCase();
						if(upperBitrate == "LOW" || upperBitrate == "MEDIUM" || upperBitrate == "HIGH") {
							this.bitrate = upperBitrate;
						}
						else this.bitrate = config.bitrate;
					}
					else this.bitrate = config.bitrate;	
				}
				if(config.width != undefined) {
					if(config.width is String) {
						this.width = int(config.width);
					}
					else this.width = config.width;					
				}
				if(config.height != undefined) {
					if(config.height is String) {
						this.height = int(config.height);
					}
					else this.height = config.height;					
				}				
				if(config.subscribe != undefined) {
					if(config.subscribe is String) {
						this.subscribe = ((config.subscribe.toUpperCase() == "TRUE") ? true : false);											
					}
					else this.subscribe = config.subscribe;
				}
				if(config.fireTrackingEvents != undefined) {
					if(config.fireTrackingEvents is String) {
						this.fireTrackingEvents = ((config.fireTrackingEvents.toUpperCase() == "TRUE") ? true : false);											
					}
					else this.fireTrackingEvents = config.fireTrackingEvents;
				}
				if(config.turnOnCountdownTimer != undefined) {
					if(config.turnOnCountdownTimer is String) {
						this.turnOnCountdownTimer = ((config.turnOnCountdownTimer.toUpperCase() == "TRUE") ? true : false);											
					}
					else this.turnOnCountdownTimer = config.turnOnCountdownTimer;
				}
				if(config.deliveryType != undefined) {
					this.deliveryType = config.deliveryType;					
				}
				if(config.providers != undefined) {
					this.providers = config.providers;	
				}		
				if(config.allowPlaylistControl != undefined) {
					if(config.allowPlaylistControl is String) {
						this.allowPlaylistControl = ((config.allowPlaylistControl.toUpperCase() == "TRUE") ? true : false);					
					}
					else this.allowPlaylistControl = config.allowPlaylistControl;	
				}
				if(config.clearPlaylist != undefined) {
					if(config.clearPlaylist is String) {
						this.clearPlaylist = ((config.clearPlaylist.toUpperCase() == "TRUE") ? true : false);					
					}
					else this.clearPlaylist = config.clearPlaylist;	
				}
				if(config.autoPlay != undefined) {
					if(config.autoPlay is String) {
						this.autoPlay = ((config.autoPlay.toUpperCase() == "TRUE") ? true : false);											
					}
					else this.autoPlay = config.autoPlay;
				}
				if(config.playOnce != undefined) {
					if(config.playOnce is String) {
						this.playOnce = ((config.playOnce.toUpperCase() == "TRUE") ? true : false);											
					}
					else this.playOnce = config.playOnce;
				}
				if(config.player != undefined) this.player = config.player;
			}			
		}

		CONFIG::callbacks
		public function set canFireAPICalls(canFireAPICalls:Boolean):void {
			_canFireAPICalls = canFireAPICalls;
		}
		
		CONFIG::callbacks
		public function get canFireAPICalls():Boolean {
			return _canFireAPICalls;
		}

		CONFIG::callbacks
		public function set canFireEventAPICalls(canFireEventAPICalls:Boolean):void {
			_canFireEventAPICalls = canFireEventAPICalls;
		}
		
		CONFIG::callbacks
		public function get canFireEventAPICalls():Boolean {
			return _canFireEventAPICalls;
		}

		CONFIG::callbacks
		public function set useV2APICalls(useV2APICalls:Boolean):void {
			_useV2APICalls = useV2APICalls;
		}

		CONFIG::callbacks
		public function get useV2APICalls():Boolean {
			return _useV2APICalls;
		}
		
		public function set setDurationFromMetaData(setDurationFromMetaData:Boolean):void {
			_setDurationFromMetaData = setDurationFromMetaData;
		}
		
		public function get setDurationFromMetaData():Boolean {
			return _setDurationFromMetaData;
		}

		public function set delayAdRequestUntilPlay(delayAdRequestUntilPlay:Boolean):void {
			_delayAdRequestUntilPlay = delayAdRequestUntilPlay;
		}
		
		public function get delayAdRequestUntilPlay():Boolean {
			return _delayAdRequestUntilPlay;
		}
		
		public function set enableProxies(enableProxies:Boolean):void {
			_enableProxies = enableProxies;
		}
		
		public function get enableProxies():Boolean {
			return _enableProxies;
		}

		public function mustOperateWithoutDuration():Boolean {
			return _setDurationFromMetaData;
		}

        public function hasProviders():Boolean {
        	return (_providersConfig != null);
        }
 
        public function setDefaultProviders():void {
        	_providersConfig = new ProvidersConfigGroup();
        }        
        
		public function set providers(config:Object):void {	
			if(config != null) {
				if(config.http != undefined) {
					this.httpProvider = config.http;
				}
				if(config.rtmp != undefined) {
					this.rtmpProvider = config.rtmp;
				}
				this.providersConfig = new ProvidersConfigGroup(config);				
			}
		}
		
		public function set providersConfig(providersConfig:ProvidersConfigGroup):void {
			_providersConfig = providersConfig;
		}
		
		public function get providersConfig():ProvidersConfigGroup {
			if(_providersConfig == null) _providersConfig = new ProvidersConfigGroup();
			return _providersConfig;
		}

		public function getProvider(providerType:String):String {
			return providersConfig.getProvider(providerType);
		}

		public function set rtmpProvider(rtmpProvider:String):void {
			providersConfig.rtmpProvider = rtmpProvider;	
		}
		
		public function get rtmpProvider():String {
			return providersConfig.rtmpProvider;			
		}

		public function set httpProvider(httpProvider:String):void {
			providersConfig.httpProvider = httpProvider;	
		}

		public function get httpProvider():String {
			return providersConfig.httpProvider;			
		}

		public function set turnOnCountdownTimer(turnOnCountdownTimer:Boolean):void {
			_turnOnCountdownTimer = turnOnCountdownTimer;	
		}

		public function get turnOnCountdownTimer():Boolean {
			return _turnOnCountdownTimer;			
		}

		public function set player(config:Object):void {
			_playerConfig = config;
		}
		
		public function get player():Object {
			return _playerConfig;
		}

		public function set stripFileExtensions(stripFileExtensions:Boolean):void {
			_stripFileExtensions = stripFileExtensions;
		}
		
		public function get stripFileExtensions():Boolean {
			return _stripFileExtensions;
		}

		public function set metaData(metaData:Boolean):void {
			_metaData = metaData;
		}
		
		public function get metaData():Boolean {
			return _metaData;
		}

		public function set fireTrackingEvents(fireTrackingEvents:Boolean):void {
			_fireTrackingEvents = fireTrackingEvents;
		}
		
		public function get fireTrackingEvents():Boolean {
			return _fireTrackingEvents;
		}
		
		public function set allowPlaylistControl(allowPlaylistControl:Boolean):void {
 			_allowPlaylistControl = allowPlaylistControl;
		}
		
		public function get allowPlaylistControl():Boolean {
			return _allowPlaylistControl;
		}

		public function set clearPlaylist(clearPlaylist:Boolean):void {
 			_clearPlaylist = clearPlaylist;
		}
		
		public function get clearPlaylist():Boolean {
			return _clearPlaylist;
		}

		public function allowPlaylistControlHasChanged():Boolean {
			return (_allowPlaylistControl != DEFAULT_PLAY_ALLOW_PLAYLIST_CONTROL);
		}
				
		public function set playOnce(playOnce:Boolean):void {
			_playOnce = playOnce;
		}
		
		public function get playOnce():Boolean {
			return _playOnce;
		}
		
		public function set autoPlay(autoPlay:Boolean):void {
			_autoPlay = autoPlay;
		}
		
		public function get autoPlay():Boolean {
			return _autoPlay;
		}

		public function playOnceHasChanged():Boolean {
			return (_playOnce != DEFAULT_PLAY_ONCE);
		}
		
		public function set deliveryType(deliveryType:String):void {
			_deliveryType = deliveryType;
		}
		
		public function get deliveryType():String {
			return _deliveryType;
		}

		public function deliveryTypeHasChanged():Boolean {
			return (_deliveryType != DEFAULT_DELIVERY_TYPE);
		}

		public function get baseURL():String {
			return _baseURL;
		}
		
		public function set baseURL(baseURL:String):void {
			_baseURL = baseURL;
		}

		public function baseURLHasChanged():Boolean {
			return (_baseURL != DEFAULT_BASE_URL);
		}
		
		public function set streamType(streamType:String):void {
			_streamType = streamType;
		}
		
		public function get streamType():String {
			return _streamType;
		}

		public function streamTypeHasChanged():Boolean {
			return (_streamType != DEFAULT_STREAM_TYPE);
		}

		public function set subscribe(subscribe:Boolean):void {
			_subscribe = subscribe;
		}		
		
		public function get subscribe():Boolean {
			return _subscribe;
		}

		public function subscribeHasChanged():Boolean {
			return (_subscribe != DEFAULT_SUBSCRIBE);
		}

		public function set bitrate(bitrate:*):void {
			_bitrate = bitrate;
		}
		
		public function get bitrate():* {
			return _bitrate;	
		}

		public function set width(width:int):void {
			_width = width;
		}
		
		public function get width():int {
			return _width;	
		}

		public function set height(height:int):void {
			_height = height;
		}
		
		public function get height():int {
			return _height;	
		}
		
		public function hasBitrate():Boolean {
			if(_bitrate is String) {
				return true; 
			}
			return Number(_bitrate) > -1;
		}
	}
}
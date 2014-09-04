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
package org.openvideoads.vast.schedule {
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.util.Timestamp;
	import org.openvideoads.vast.config.ConfigLoadListener;
	import org.openvideoads.vast.playlist.Playlist;
	import org.openvideoads.vast.playlist.PlaylistController;
	import org.openvideoads.vast.playlist.PlaylistItem;
	import org.openvideoads.vast.playlist.PlaylistLoadListener;
	
	/**
	 * @author Paul Schulz
	 */
	public class StreamConfig extends Debuggable implements PlaylistLoadListener, ConfigLoadListener {
		private var _id:String = null;
		private var _filename:String;
		private var _baseURL:String = null;
		private var _originalFilename:String = null;
		private var _duration:String = "00:00:00";
		private var _reduceLength:Boolean = false;
		private var _isLive:Boolean = false;
		private var _deliveryType:String = "any"; //streaming
		private var _playOnce:Boolean = false;
		private var _metaData:Boolean = true;
		private var _autoPlay:Boolean = true;
		private var _provider:String = null;
		private var _playerConfig:Object = new Object();
		private var _customProperties:Object = new Object();
		private var _type:String = null;
		private var _onLoadListener:ConfigLoadListener = null;
		private var _smilResolvedAddress:Boolean = false;
		private var _startTime:String = "00:00:00";
		private var _fireTrackingEvents:Boolean = false;
		
		public function StreamConfig(id:String, 
		                             filename:String, 
		                             duration:String, 
		                             reduceLength:Boolean=false, 
		                             deliveryType:String="any", 
		                             playOnce:Boolean=false, 
		                             metaData:Boolean=true, 
		                             autoPlay:Boolean=true, 
		                             provider:String=null, 
		                             playerConfig:Object=null,
		                             customProperties:Object=null,
		                             type:String=null,
		                             startTime:String=null,
		                             fireTrackingEvents:Boolean=false) {
			_id = id;
			if(filename != null) {
				if(filename.indexOf("(live)") > -1) {
					_filename = filename.substr(filename.lastIndexOf("(live)") + 6);
					_isLive = true;
				}
				else _filename = filename;				
			}
			this.duration = duration;
			_reduceLength = reduceLength;
			_deliveryType = deliveryType;
			_playOnce = playOnce;
			_metaData = metaData;
			_autoPlay = autoPlay;
			_provider = provider;
			if(playerConfig != null) _playerConfig = playerConfig;
			if(customProperties != null) {
				_customProperties = customProperties;
			}
			this.type = type;
			if(startTime != null) {
				_startTime = startTime;
			}
			else _startTime = "00:00:00";
			_fireTrackingEvents = fireTrackingEvents;
		}

		public function get id():String {
			return _id;
		}
		
		public function get player():Object {
			return _playerConfig;
		}
		
		public function set provider(provider:String):void {
			_provider = provider;
		}
		
		public function get provider():String {
			return _provider;
		}

		public function set fireTrackingEvents(fireTrackingEvents:Boolean):void {
			_fireTrackingEvents = fireTrackingEvents;
		}
		
		public function get fireTrackingEvents():Boolean {
			return _fireTrackingEvents;
		}
		
		public function set autoPlay(autoPlay:Boolean):void {
			_autoPlay = autoPlay;
		}
		
		public function get autoPlay():Boolean {
			return _autoPlay;
		}
		
		public function set deliveryType(deliveryType:String):void {
			_deliveryType = deliveryType;
		}
		
		public function get deliveryType():String {
			return _deliveryType;
		}
		
		public function set metaData(metaData:Boolean):void {
			_metaData = metaData;
		}
		
		public function get metaData():Boolean {
			return _metaData;
		}
		
		public function set customProperties(customProperties:Object):void {
			_customProperties = customProperties;
		}
		
		public function get customProperties():Object {
			return _customProperties;
		}

		public function set filename(filename:String):void {
			_filename = filename;
		}
		
		public function get filename():String {
			return _filename;
		}
		
		public function get baseURL():String {
			return _baseURL;
		}
		
		public function set baseURL(baseURL:String):void {
			_baseURL = baseURL;
		}
		
		public function hasBaseURL():Boolean {
			return (_baseURL != null);
		}
		
		public function isSMILType():Boolean {
			if(_type != null) {
				return (_type.toUpperCase() == "SMIL");
			}	
			return false;
		}
		
		public function resolveFilename(onLoadListener:ConfigLoadListener):void {
			_onLoadListener = onLoadListener;
			if(isSMILType()) {
				var spl:Playlist = PlaylistController.getPlaylistObject(PlaylistController.getType(_type.toUpperCase()));
				spl.loadFromURL(_filename, this);				
			}
			else onOVAConfigLoaded();
		}

		public function isOVAConfigLoading():Boolean {
			return (_type != null);	
		}
		
		public function onOVAConfigLoaded():void {
			if(_type == null) {
				if(_onLoadListener != null) _onLoadListener.onOVAConfigLoaded();
			}
		}
		
		public function onPlaylistLoaded(playlist:Playlist):void {
			if(playlist.length > 0) {
				var playlistItem:PlaylistItem = playlist.getTrackAtIndex(0);
				_type = null;
				_originalFilename = _filename;
				_smilResolvedAddress = true;
				if(playlistItem.isRTMP()) {
					_filename = playlistItem.filename;
					_baseURL = playlistItem.url;			
					CONFIG::debugging { doLog("Stream filename has been resolved as RTMP filename: " + _filename + " baseURL: " + _baseURL, Debuggable.DEBUG_CONFIG); }
				}
				else {
					_filename = playlistItem.getQualifiedStreamAddress();					
					CONFIG::debugging { doLog("Stream filename has been resolved as filename: " + _filename, Debuggable.DEBUG_CONFIG); }				
				}
				_id = _filename;
			}
			onOVAConfigLoaded();
		}
		
		public function get file():String {
			return this.filename;
		}
		
		public function hasSMILResolvedAddress():Boolean {
			return _smilResolvedAddress;
		}
		
		public function set type(type:String):void {
			_type = type;
		}
		
		public function get type():String {
			return _type;
		}
		
		public function isStream():Boolean {
			if(_filename != null) {	
				// determine it's a stream by identifying if it's an image or swf - if not, then it's a stream
				// Needs to match "x.gif" but not "x.mp4?gif" for instance
        		var pattern:RegExp = new RegExp('(?i).*\\.(jpg|png|gif|bmp)');			
        		return (_filename.match(pattern) == null);
			}
			return true; 
		}
		
		public function set duration(duration:String):void {
			// duration is always to be held in the format HH:MM:SS
			if(Timestamp.validate(duration)) {
				_duration = duration;
			}
			else _duration = Timestamp.secondsStringToTimestamp(duration);
		}
		
		public function get duration():String {
			return _duration;
		}

		public function hasDuration():Boolean {
			return (_duration != null && getDurationAsInt() > 0);
		}
				
		public function getDurationAsInt():int {
			return Timestamp.timestampToSeconds(duration);
		}

		public function set reduceLength(reduceLength:Boolean):void {
			_reduceLength = reduceLength;
		}
		
		public function get reduceLength():Boolean {
			return _reduceLength;
		}
		
		public function set startTime(startTime:String):void {
			if(startTime != null) {
				if(startTime.indexOf(":") == 2) {
					_startTime = startTime;				
				}		
				else _startTime = Timestamp.secondsToTimestamp(int(startTime));
			}
		}
		
		public function get startTime():String {
			return _startTime;
		}
		
		public function isLive():Boolean {
			return _isLive;
		}
		
		public function set playOnce(playOnce:Boolean):void {
			_playOnce = playOnce;
		}
		
		public function get playOnce():Boolean {
			return _playOnce;
		}
	}
}
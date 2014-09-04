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
 package org.openvideoads.vast.playlist {
	import flash.events.*;
	import flash.net.*;
	import flash.xml.*;
	
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.vast.config.groupings.ProvidersConfigGroup;
	import org.openvideoads.vast.schedule.Stream;
	import org.openvideoads.vast.schedule.StreamSequence;
	import org.openvideoads.vast.schedule.ads.AdSlot;
	
	/**
	 * @author Paul Schulz
	 */
	public class DefaultPlaylist extends Debuggable implements Playlist {		
		protected var _playlist:Array = new Array();
		protected var _currentTrackIndex:int = 0;
		protected var _playingTrackIndex:int = 0;
		protected var _xmlLoader:URLLoader = null;
		protected var _rawXMLData:String = null;
		protected var _loadListener:PlaylistLoadListener = null;
		protected var _rewound:Boolean = false;
		
		public function DefaultPlaylist(streamSequence:StreamSequence=null, showProviders:ProvidersConfigGroup=null, adProviders:ProvidersConfigGroup=null) {
			loadFromSequence(streamSequence, showProviders, adProviders);
		}

        protected function initialise():void {
			_playlist = new Array();
			_playingTrackIndex = 0;
			_currentTrackIndex = 0;
			_rewound = false;        	
        }
        
        public function loadFromSequence(streamSequence:StreamSequence, showProviders:ProvidersConfigGroup, adProviders:ProvidersConfigGroup):void {
			if(streamSequence != null) {
				for(var i:int=0; i < streamSequence.length; i++) {
					var newItem:PlaylistItem = newPlaylistItem();
					newItem.index = i;
					newItem.stream = streamSequence.streamAt(i);
					if(newItem.stream is AdSlot) {
						if(AdSlot(newItem.stream).isInteractive()) {
							// It's a VPAID linear ad so we don't have to set anything else at this point
						}
						else {
							// It's a standard non-interactive linear ad stream so set the stream attributes
		                	newItem.provider = newItem.stream.isRTMP() ? adProviders.rtmpProvider : adProviders.httpProvider;
		                	newItem.streamer = newItem.stream.isRTMP() ? adProviders.rtmpStreamer : adProviders.httpStreamer;								
						}
						newItem.providers = adProviders;
		            }
		            else {
		            	// It's a standard show stream
		            	newItem.provider = newItem.stream.isRTMP() ? showProviders.rtmpProvider : showProviders.httpProvider;
		            	newItem.streamer = newItem.stream.isRTMP() ? showProviders.rtmpStreamer : showProviders.httpStreamer;
						newItem.providers = showProviders;
		            }
					_playlist.push(newItem);
				}				
			}        	
        }

		public function isFirstTrackIsHoldingClip():Boolean {
			if(this.length > 0) {
				return getTrackAtIndex(0).loadOnDemand && getTrackAtIndex(0).requiresLoading();
			}
			return false;
		}

		public function isFirstTrackIsInteractive():Boolean {
			if(this.length > 0) {
				return this.getTrackAtIndex(0).isInteractive();
			}
			return false;
		}
		
		public function updatePlaylistItem(stream:Stream, playlistIndex:int):void {
			if(playlistIndex >= 0 && playlistIndex < _playlist.length) {
				// replace the stream on the playlist item at index playlistIndex
				_playlist[playlistIndex].stream = stream;
				CONFIG::debugging { doLog("The stream attached to playlist index " + playlistIndex + " has been updated", Debuggable.DEBUG_PLAYLIST); }
			}
		}
        
		public function loadFromURL(url:String, loadListener:PlaylistLoadListener=null):void {
			_loadListener = loadListener;
			CONFIG::debugging { doLog("Loading XML based playlist from URL: " + url, Debuggable.DEBUG_PLAYLIST); }
			_xmlLoader = new URLLoader();
			_xmlLoader.addEventListener(Event.COMPLETE, dataLoaded);
			_xmlLoader.addEventListener(ErrorEvent.ERROR, errorHandler);
			_xmlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			_xmlLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			_xmlLoader.load(new URLRequest(url));
		}

		protected function notifyLoadListener():void {
			if(_loadListener != null) {
				_loadListener.onPlaylistLoaded(this);
			}
		}
		
		protected function dataLoaded(e:Event):void {
			CONFIG::debugging { 
				doLog("Loaded " + _xmlLoader.bytesLoaded + " bytes of playlist XML data", Debuggable.DEBUG_PLAYLIST); 
				doTrace(_xmlLoader, Debuggable.DEBUG_PLAYLIST);
			}
			_rawXMLData = _xmlLoader.data;
			loadFromString(_rawXMLData);
			notifyLoadListener();
		}
		
		protected function errorHandler(e:Event):void {
			CONFIG::debugging { doLog("Error loading playlist XML: " + e.toString(), Debuggable.DEBUG_PLAYLIST); }
			notifyLoadListener();
		}

        public function loadFromString(xmlData:String):void {
        }
        
        public function getTrackAtIndex(index:int):PlaylistItem {
        	if(this.length > index) {
        		return _playlist[index];
        	}	
        	return null;
        }  
        
		public function get length():int {
			return _playlist.length;				
		}
		
		public function playlist():Array {
			return _playlist;
		}
		
		public function newPlaylistItem():PlaylistItem {
			return new DefaultPlaylistItem();
		}
		
		public function addTrack(newTrack:PlaylistItem):void {
			_playlist.push(newTrack);
		}
		
		public function rewound():Boolean {
			return _rewound;
		}
		
		public function rewind():void {
			_currentTrackIndex = 0;
			_rewound = true;
			if(_playlist != null) {
				for(var i:int=0; i < _playlist.length; i++) {
					_playlist[i].rewind();
				}
			}
		}

		public function reset():void {
			_currentTrackIndex = 0;
			if(_playlist != null) {
				for(var i:int=0; i < _playlist.length; i++) {
					_playlist[i].reset();
				}
			}
		}

		public function get playingTrackIndex():int {
			return _playingTrackIndex;
		}
		
		public function get currentTrackIndex():int {
			return _currentTrackIndex;
		}
		
		public function currentTrackAsPlaylistXML(overrideStartTimeSeconds:int=-1, retainPrefix:Boolean = false):XML {
			if(_playlist != null) {
				var activeTrackIndex:int = (_currentTrackIndex > 0) ? _currentTrackIndex-1 : 0;
				if(activeTrackIndex < _playlist.length) {
					if(overrideStartTimeSeconds > -1) {
						_playlist[activeTrackIndex].overrideStartTimeSeconds = overrideStartTimeSeconds;						
					}
	 			    var trackData:String = header();
					trackData += _playlist[activeTrackIndex].toString(retainPrefix);
					trackData += footer();
					return new XML(trackData);							
				}
			}
			return null;
		}
		
		public function currentTrackAsPlaylistItem(overrideStartTimeSeconds:int=-1, retainPrefix:Boolean = false):PlaylistItem {
			if(_playlist != null) {
				var activeTrackIndex:int = (_currentTrackIndex > 0) ? _currentTrackIndex-1 : 0;
				if(activeTrackIndex < _playlist.length) {
					if(overrideStartTimeSeconds > -1) {
						_playlist[activeTrackIndex].overrideStartTimeSeconds = overrideStartTimeSeconds;						
					}
					return _playlist[activeTrackIndex];							
				}
			}
			return null;
		}
		
		public function nextTrackAsPlaylistString(retainPrefix:Boolean = false, canMarkAsRewound:Boolean = true):String {
			if(_playlist != null) {
				if(_currentTrackIndex > 0 && canMarkAsRewound) {
					_rewound = false;
				}
				if(_currentTrackIndex < _playlist.length) {
					_playingTrackIndex = _currentTrackIndex;
 			        if(_playlist[_currentTrackIndex].canPlay()) {
	 			        var trackData:String = header();
						trackData += _playlist[_currentTrackIndex].toString(retainPrefix);
						_playlist[_currentTrackIndex].markAsPlayed(); 			        	
						trackData += footer();
						_currentTrackIndex++;
						return trackData;
 			        }
 			        else {	
						_currentTrackIndex++;
 			        	return nextTrackAsPlaylistString(retainPrefix, false);
 			        }
				}				
			}
			return null;
		}
		
		public function nextTrackAsPlaylistXML(retainPrefix:Boolean = false):XML {
			var data:String = nextTrackAsPlaylistString(retainPrefix);
			if(data != null) {
				return new XML(data);			
			}
			else return null;
		}

		public function nextTrackAsPlaylistItem(retainPrefix:Boolean = false, canMarkAsRewound:Boolean = true):PlaylistItem {
			if(_playlist != null) {
				if(_currentTrackIndex > 0 && canMarkAsRewound) {
					_rewound = false;
				}
				if(_currentTrackIndex < _playlist.length) {
					_playingTrackIndex = _currentTrackIndex;
 			        if(_playlist[_currentTrackIndex].canPlay()) {
						_playlist[_currentTrackIndex].markAsPlayed(); 			        	
						_currentTrackIndex++;
						return _playlist[_currentTrackIndex-1];
 			        }
 			        else {	
						_currentTrackIndex++;
 			        	return nextTrackAsPlaylistItem(retainPrefix, false);
 			        }
				}				
			}
			return null;
		}
		
		public function previousTrackAsPlaylistString(retainPrefix:Boolean = false):String {
			_rewound = false;
			if(_playlist != null) {
				if(_currentTrackIndex >= 0) {
 			        if(_playlist[_currentTrackIndex].canPlay()) {
	 			        var trackData:String = header();
						trackData += _playlist[_currentTrackIndex].toString(retainPrefix);
						_playlist[_currentTrackIndex].markAsPlayed();
						trackData += footer();
						_currentTrackIndex--;
						return trackData;					
 			        }
 			        else {
						_currentTrackIndex--;
 			        	return previousTrackAsPlaylistString(retainPrefix);
 			        }
				}				
			}
			return null;
		}

		public function previousTrackAsPlaylistXML(retainPrefix:Boolean = false):XML {
			var data:String = previousTrackAsPlaylistString(retainPrefix);
			if(data != null) {
				return new XML(data);			
			}
			else return null;
		}

		public function previousTrackAsPlaylistItem(retainPrefix:Boolean = false):PlaylistItem {
			_rewound = false;
			if(_playlist != null) {
				if(_currentTrackIndex >= 0) {
 			        if(_playlist[_currentTrackIndex].canPlay()) {
						_playlist[_currentTrackIndex].markAsPlayed();
						_currentTrackIndex--;
						return _playlist[_currentTrackIndex+1];					
 			        }
 			        else {
						_currentTrackIndex--;
 			        	return previousTrackAsPlaylistItem(retainPrefix);
 			        }
				}				
			}
			return null;
		}
		
		public function getModel():Array {
			return _playlist;
		}

        public function toXML(retainPrefix:Boolean = false):XML {
        	return new XML(toString(retainPrefix));
        }
        
	    protected function header():String {
			return new String();
	    }

	    protected function footer():String {
			return new String();
	    }
	    
	    /*
	     * "streams": [
         *	  "{ "file":"http://streaming.openvideoads.org/shows/the-black-hole.mp4", "duration":"00:00:30" },..
         * ]
	     */
		public function toShowStreamsConfigArray():Array {
			var result:Array = new Array();
			for(var i:int=0; i < _playlist.length; i++) {
				result.push(_playlist[i].toShowStreamConfigObject());
			}
			return result;
		}

		public function toShortString(retainPrefix:Boolean = false):String {
			return toString(retainPrefix);
		}		
	    
		public function toString(retainPrefix:Boolean = false):String {
			var result:String = new String();
			for(var i:int=0; i < _playlist.length; i++) {
				result += _playlist[i].toString(retainPrefix);
			}
			return result;
		}		
	}
}
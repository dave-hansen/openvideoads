/*
 *    Copyright (c) 2010 LongTail AdSolutions, Inc
 *
 *    This file is part of the OVA for JW5x plugin.
 *
 *    The OVA for JW5x plugin is commercial software: you can redistribute it
 *    and/or modify it under the terms of the OVA Commercial License.
 *
 *    You should have received a copy of the OVA Commercial License along with
 *    the source code.  If not, see <http://www.openvideoads.org/licenses>.
 */
package org.openvideoads.plugin.jwplayer.streamer.playlist {
	import flash.external.ExternalInterface;
import flash.utils.describeType;
	
	import com.longtailvideo.jwplayer.model.PlaylistItem;
	import com.longtailvideo.jwplayer.model.PlaylistItemLevel;
	
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.util.FileUtils;
	import org.openvideoads.util.StringUtils;
	import org.openvideoads.vast.config.groupings.AdMetaDataConfigGroup;
	import org.openvideoads.vast.playlist.DefaultPlaylistItem;
	
	/**
	 * @author Paul Schulz
	 */
	public class JWPlaylistItem extends DefaultPlaylistItem {
		protected var _inPlayerPlaylistItem:com.longtailvideo.jwplayer.model.PlaylistItem = null;
		protected var _retainPrefix:Boolean;
		protected var _metaDataConfig:AdMetaDataConfigGroup;
		protected var _holdingClipUrl:String=null;
		protected var _playerPlaylistIndex:int = -1;
		
		public function JWPlaylistItem(holdingClipUrl:String=null) {
			_holdingClipUrl = holdingClipUrl;
		}
		
		public function get inPlayerPlaylistItem():com.longtailvideo.jwplayer.model.PlaylistItem {
			return _inPlayerPlaylistItem;
		}
		
		public function set playerPlaylistIndex(playerPlaylistIndex:int):void {
			_playerPlaylistIndex = playerPlaylistIndex;
		}
		
		public function get playerPlaylistIndex():int {
			return _playerPlaylistIndex;
		}
		
		public function addOVAAdAttributes():com.longtailvideo.jwplayer.model.PlaylistItem {
			if(isAd()) {
				_inPlayerPlaylistItem['ova.hidden'] = true;	// legacy attribute - should be depreciated in the future
				_inPlayerPlaylistItem['ovaAd'] = true;
				_inPlayerPlaylistItem['ovaZone'] = adSlot.zone;
				_inPlayerPlaylistItem['ovaSlotId'] = adSlot.id;
				_inPlayerPlaylistItem['ovaPosition'] = adSlot.position;
				_inPlayerPlaylistItem['ovaPlaylistIndex'] = adSlot.index;
				_inPlayerPlaylistItem['ovaAssociatedStreamIndex'] = adSlot.associatedStreamIndex;
				_inPlayerPlaylistItem['ovaAdType'] = (adSlot.isPreRoll() ? "pre-roll" : (adSlot.isMidRoll() ? "mid-roll" : "post-roll"));
				_inPlayerPlaylistItem['ovaInteractive'] = adSlot.isInteractive();
				_inPlayerPlaylistItem['ovaRelatedPlaylistItemIndex'] = index;
				_inPlayerPlaylistItem['ovaUID'] = adSlot.uid;
				return _inPlayerPlaylistItem;			
			}
			else return addOVAShowAttributes();
		}
		
		protected function addOVAShowAttributes():com.longtailvideo.jwplayer.model.PlaylistItem {
			if(stream.associatedPrerollAdSlot != null) {
				_inPlayerPlaylistItem['ovaAssociatedPrerollClipIndex'] = stream.associatedPrerollAdSlot.associatedStreamIndex;
			}
			_inPlayerPlaylistItem['ovaAd'] = false;
			_inPlayerPlaylistItem['ovaPlaylistIndex'] = stream.index;
			_inPlayerPlaylistItem['ovaAssociatedStreamIndex'] = stream.associatedStreamIndex;
			_inPlayerPlaylistItem['ovaIsEndBlock'] = stream.isEndBlock();
			_inPlayerPlaylistItem['ovaRelatedPlaylistItemIndex'] = index;
			_inPlayerPlaylistItem['ovaUID'] = stream.uid;
			return _inPlayerPlaylistItem;
		}

		/* EXAMPLE PLAYLIST FORMAT
		playlist[0][image]: http://content.bitsontherun.com/thumbs/8Juv1MVa-480.jpg
		playlist[0][start]: 0
		playlist[0][type]: rtmp
		playlist[0][title]: RTMP streaming (FMS)
		playlist[0][levels][0][bitrate]: 1600
		playlist[0][levels][0][file]: videos/8Juv1MVa-67727.mp4
		playlist[0][levels][0][width]: 1080
		playlist[0][levels][0][bitrate]: 1200
		playlist[0][levels][0][file]: videos/8Juv1MVa-485.mp4
		playlist[0][levels][0][width]: 720
		playlist[0][levels][0][bitrate]: 800
		playlist[0][levels][0][file]: videos/8Juv1MVa-484.mp4
		playlist[0][levels][0][width]: 480
		playlist[0][levels][0][bitrate]: 400
		playlist[0][levels][0][file]: videos/8Juv1MVa-483.mp4
		playlist[0][levels][0][width]: 320
		playlist[0][file]: videos/8Juv1MVa-483.mp4
		playlist[0][duration]: 0
		playlist[0][streamer]: rtmp://fms.12E5.edgecastcdn.net/0012E5
		*/
		
		public function toJWPlaylistItemObject(retainPrefix:Boolean, metaDataConfig:AdMetaDataConfigGroup, holdingClipUrl:String=null, index:int=-1):com.longtailvideo.jwplayer.model.PlaylistItem {
			_retainPrefix = retainPrefix;
			_metaDataConfig = metaDataConfig;
			if(holdingClipUrl != null) _holdingClipUrl = holdingClipUrl;
			_inPlayerPlaylistItem = new com.longtailvideo.jwplayer.model.PlaylistItem();
			if(sync()) {
				return _inPlayerPlaylistItem;
			}
			else return null;
		}
		
		protected function copyPlaylistItem(original:com.longtailvideo.jwplayer.model.PlaylistItem):com.longtailvideo.jwplayer.model.PlaylistItem {
			var copy:com.longtailvideo.jwplayer.model.PlaylistItem = new com.longtailvideo.jwplayer.model.PlaylistItem();
			copy.author = original.author;
			copy.date = original.date;
			copy.description = original.description;
			copy.image = original.image;
			copy.link = original.link;
			copy.mediaid = original.mediaid;
			copy.tags = original.tags;
			copy.title = original.title;
			copy.duration = original.duration;
			copy.file = original.file;
			if(original.levels != null) {
				for each(var level:PlaylistItemLevel in original.levels) {
					copy.addLevel(level);
				}
				if(original.currentLevel > -1) {
					copy.setLevel(original.currentLevel);
				}
			}
			copy.provider = original.provider;
			copy.start = original.start;
			copy.streamer = original.streamer;
			copy.type = original.type;
			
			// Now add in the custom fields created through the Dynamic underlying Clip class
			for(var id:String in original) {
				if(StringUtils.beginsWith(id, "ova") == false) {
					CONFIG::debugging { doLog("Adding custom clip property " + id, Debuggable.DEBUG_PLAYLIST); }
					copy[id] = original[id];
				}
			}

			return copy;
		}
		
		public override function sync():Boolean {
			var today:Date = new Date();	
			if(isAd()) {
				if(this.loadOnDemand) {
					if(this.requiresLoading()) {
 					    if(_holdingClipUrl == null) {
 					    	CONFIG::debugging { doLog("FATAL: No holding clip URL declared for 'loadOnDemand' ad slots that require loading - 'null' set as URL", Debuggable.DEBUG_PLAYLIST); }
 					    }
						// we have to create a "holding clip" that is used to facilitate on-demand loading when full playlists
						// are loaded into the player
						_inPlayerPlaylistItem.type = "video";
						_inPlayerPlaylistItem.file = _holdingClipUrl;
						_inPlayerPlaylistItem.duration = 1;
						addOVAAdAttributes();
						return true;
					}
				}
				if(isInteractive()) {
				    if(_holdingClipUrl == null) {
 					    CONFIG::debugging { doLog("FATAL: No holding clip URL declared for 'VPAID' linear ad slots that require loading - 'null' set as URL", Debuggable.DEBUG_PLAYLIST); }
 				    }
					// It's a VPAID interactive item - put a placeholder in here
					_inPlayerPlaylistItem.type = "video";
					_inPlayerPlaylistItem.file = _holdingClipUrl;
					_inPlayerPlaylistItem.duration = 1;
					addOVAAdAttributes();
					return true;
				}
				else {
					// It's a standard loadable stream style item
					if(isRTMP()) {
						_inPlayerPlaylistItem.file = getFilename(_retainPrefix);
						_inPlayerPlaylistItem.type = "rtmp";
						_inPlayerPlaylistItem.provider = "rtmp";			
						_inPlayerPlaylistItem.streamer = getStreamer();
						if(providers != null) {
							if(providers.enforceSettingSubscribeRTMP) {
								_inPlayerPlaylistItem["rtmp.subscribe"] = providers.rtmpSubscribe;
							}
						}
					}	
					else {
						if(url != null) {
							if(FileUtils.isImage(url) || FileUtils.isSWF(url)) {
								_inPlayerPlaylistItem.file = url;
								_inPlayerPlaylistItem.type = "image";						
							}
							else { 
							    // it's a stream
								_inPlayerPlaylistItem.file = url;
								_inPlayerPlaylistItem.type = provider;      
								_inPlayerPlaylistItem.provider = provider; 
								_inPlayerPlaylistItem.streamer = provider;  
							}
						}
						else {
							CONFIG::debugging { doLog("FATAL: Cannot sync() this clip - the new 'url' is null", Debuggable.DEBUG_PLAYLIST); }
						}
					}
		   		    if((getStartTimeAsSeconds() + getDurationAsSeconds()) > 0) {
						_inPlayerPlaylistItem.duration = new Number(getDurationAsSeconds());
	   			    }
					_inPlayerPlaylistItem.start = getStartTimeAsSeconds();
					if(_metaDataConfig != null) {
						_inPlayerPlaylistItem.title = _metaDataConfig.getLinearAdTitle(title, new String(getDurationAsSeconds()), adSlot.key); 
						_inPlayerPlaylistItem.description = _metaDataConfig.getLinearAdDescription("Advertisement", new String(getDurationAsSeconds()), adSlot.key); 			
					}
					_inPlayerPlaylistItem.author = "OVA";
					_inPlayerPlaylistItem.date = today.toTimeString();
					_inPlayerPlaylistItem.link = link;
					_inPlayerPlaylistItem.mediaid = guid;
					/* We are not currently setting these properties on ads
					_inPlayerPlaylistItem.addLevel();
					_inPlayerPlaylistItem.tags = 
					*/					
				}
				
				addOVAAdAttributes();
			}
			else {
				// ok, it's not an ad but a standard JW stream so return the original JW playlist item
				if(_stream != null) {
					_inPlayerPlaylistItem.title = "No title";
					_inPlayerPlaylistItem.author = "No author";
					_inPlayerPlaylistItem.description = "No description";
					if(_stream.hasCustomProperties()) {
  						var durationInSeconds:Number = new Number(getDurationAsSeconds());
						if(_stream.hasCustomProperty("originalPlaylistItem")) {
							var startTime:int = getStartTimeAsSeconds();
							_inPlayerPlaylistItem = copyPlaylistItem(_stream.customProperties.originalPlaylistItem);
							if(_inPlayerPlaylistItem != null) {		
								_inPlayerPlaylistItem.start = startTime;
								if(durationInSeconds > 0) {
									if(_stream.isSlice()) {
										// In JW5.6 or higher, the duration of each slice must the start time + the duration to play unless it is the
										// last slice which needs to have the correct final duration of the stream
										if(_inPlayerPlaylistItem.start + durationInSeconds > getOriginalDurationAsSeconds()) {
											_inPlayerPlaylistItem.duration = getOriginalDurationAsSeconds();
										}
										else _inPlayerPlaylistItem.duration = _inPlayerPlaylistItem.start + durationInSeconds;										
									}
									else if(_inPlayerPlaylistItem.start == durationInSeconds) {
										_inPlayerPlaylistItem.duration = _inPlayerPlaylistItem.start + durationInSeconds;	
									}
									else _inPlayerPlaylistItem.duration = durationInSeconds;
								}
								addOVAShowAttributes();
								return true;
							}
							else {
								CONFIG::debugging { doLog("FATAL: _inPlayerPlaylistItem is NULL and it shouldn't be - cannot generate the playlist item", Debuggable.DEBUG_FATAL); }
							}
							return false;
						}
						if(_stream.hasCustomProperty("title")) {
							_inPlayerPlaylistItem.title = _stream.customProperties.title;
						}
						if(_stream.hasCustomProperty("author")) {
							_inPlayerPlaylistItem.author = _stream.customProperties.author;				
						}
						if(_stream.hasCustomProperty("description")) {
							_inPlayerPlaylistItem.description = _stream.customProperties.description;							
						}
						if(_stream.hasCustomProperty("link")) {
							_inPlayerPlaylistItem.link = _stream.customProperties.link;
						}
						if(_stream.hasCustomProperty("tags")) {
							_inPlayerPlaylistItem.tags = _stream.customProperties.tags;							
						}
					}

					// it's an internal OVA stream so create the JW playlist object manually
					if(isRTMP()) {
						_inPlayerPlaylistItem.file = getFilename(_retainPrefix);
						_inPlayerPlaylistItem.type = "rtmp";
						_inPlayerPlaylistItem.provider = "rtmp";			
						_inPlayerPlaylistItem.streamer = getStreamer();
					}	
					else {
						_inPlayerPlaylistItem.file = url;
						_inPlayerPlaylistItem.type = provider;
						_inPlayerPlaylistItem.provider = provider;
						_inPlayerPlaylistItem.streamer = provider;
					}	
					_inPlayerPlaylistItem.date = today.toTimeString();				
					_inPlayerPlaylistItem.start = getStartTimeAsSeconds();
		   		    if((_inPlayerPlaylistItem.start + durationInSeconds) > 0) {
						if(_inPlayerPlaylistItem.start == durationInSeconds) {
							_inPlayerPlaylistItem.duration = _inPlayerPlaylistItem.start + durationInSeconds;	
						}
						else _inPlayerPlaylistItem.duration = durationInSeconds;
	   			    }

					addOVAShowAttributes();
				}
			}
			
			return true;
		}

        public override function toShortString(retainPrefix:Boolean = false):String {
			if(this.loadOnDemand && this.requiresLoading()) {
	        	return "{ type: loadOnDemand (to be loaded) - holding clip - " + _holdingClipUrl + " }";
			}
        	else if(isInteractive()) {
	        	return "{ type: Linear VPAID - holding clip - " + _holdingClipUrl + " }";
        		
        	}
        	else {
	        	return "{ type: " + (isRTMP() ? "rtmp" : "http") +
			           ", " + _stream.toShortString() + 
        			   " }";
        		
        	}
        }
	}
}

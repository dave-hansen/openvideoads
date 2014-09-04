/*
 *    Copyright (c) 2010 LongTail AdSolutions, Inc
 *
 *    This file is part of the OVA for JW4x plugin.
 *
 *    The OVA for JW4x plugin is commercial software: you can redistribute it
 *    and/or modify it under the terms of the OVA Commercial License.
 *
 *    You should have received a copy of the OVA Commercial License along with
 *    the source code.  If not, see <http://www.openvideoads.org/licenses>.
 */
package org.openvideoads.plugin.jwplayer.streamer.playlist {
	import org.openvideoads.util.FileUtils;
	import org.openvideoads.vast.config.groupings.AdMetaDataConfigGroup;
	import org.openvideoads.vast.playlist.DefaultPlaylistItem;
	
	/**
	 * @author Paul Schulz
	 */
	public class JWPlaylistItem extends DefaultPlaylistItem {

		public override function toString(retainPrefix:Boolean = false):String {
			return "JW4 PlaylistItem " + super.toString(retainPrefix);
		}

		public function toJWPlaylistItemObject(retainPrefix:Boolean, metaDataConfig:AdMetaDataConfigGroup):Object {
			var newItem:Object = new Object();
			var today:Date = new Date();	
			if(isAd()) {
				if(isRTMP()) {
					newItem.file = getFilename(false);
					newItem.type = "rtmp";
					newItem.provider = "rtmp";			
					newItem.streamer = getStreamer();
				}	
				else {
					if(FileUtils.isImage(url) || FileUtils.isSWF(url)) {
						newItem.file = url;
						newItem.type = "image";						
					}
					else { // it's a stream
						newItem.file = url;
						newItem.type = "http";     // linear ad streams are hard coded to HTTP progressive - was 'provider';
						newItem.provider = "http"; // was 'provider';
						newItem.streamer = "http";
//						newItem.streamer = provider;
					}
				}	
	   		    if((getStartTimeAsSeconds() + getDurationAsSeconds()) > 0) {
					newItem.duration = getDurationAsSeconds();
   			    }
				if(hasPreviewImage()) {
					newItem.image = getPreviewImage();
				}
				newItem.start = getStartTimeAsSeconds();
				newItem.title = metaDataConfig.getLinearAdTitle(title, new String(getDurationAsSeconds()), adSlot.key); //title;
				newItem.description = metaDataConfig.getLinearAdDescription("Advertisement", new String(getDurationAsSeconds()), adSlot.key); //"Advertisement";
				newItem.author = "OVA";
				newItem.date = today.toTimeString();
				newItem.link = link;
				newItem.mediaid = guid;
				newItem['ova.hidden'] = true;				
				return newItem;
			}
			else {
				// ok, it's not an ad but a standard JW stream so return the original JW playlist item
				if(_stream != null) {
					newItem.title = "No title";
					newItem.author = "No author";
					newItem.description = "No description";
					if(_stream.hasCustomProperties()) {
						if(_stream.hasCustomProperty("originalPlaylistItem")) {
							var originalClip:Object = _stream.customProperties.originalPlaylistItem;
							if(originalClip != null) {
								originalClip.start = getStartTimeAsSeconds();
								if(getDurationAsSeconds() > 0) {
									originalClip.duration = getDurationAsSeconds();								
								}
							}
							return originalClip;				
						}
						if(_stream.hasCustomProperty("title")) {
							newItem.title = _stream.customProperties.title;
						}
						if(_stream.hasCustomProperty("author")) {
							newItem.author = _stream.customProperties.author;				
						}
						if(_stream.hasCustomProperty("description")) {
							newItem.description = _stream.customProperties.description;							
						}
						if(_stream.hasCustomProperty("link")) {
							newItem.link = _stream.customProperties.link;
						}
						if(_stream.hasCustomProperty("tags")) {
							newItem.tags = _stream.customProperties.tags;							
						}
					}

					// it's an internal OVA stream so create the JW playlist object manually
					if(isRTMP()) {
						newItem.file = getFilename(retainPrefix);
						newItem.type = "rtmp";
						newItem.provider = "rtmp";		
						newItem.streamer = getStreamer();
					}	
					else {
						newItem.file = url;
						newItem.type = "http";
						newItem.provider = provider;
					}
					newItem.start = getStartTimeAsSeconds();
		   		    if((getStartTimeAsSeconds() + getDurationAsSeconds()) > 0) {
						newItem.duration = getDurationAsSeconds();
	   			    }
					newItem.date = today.toTimeString();			
					return newItem;
				}
			}
			return null;
		}
	}
}

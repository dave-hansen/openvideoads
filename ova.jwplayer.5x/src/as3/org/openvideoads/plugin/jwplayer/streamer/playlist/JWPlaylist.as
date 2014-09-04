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
	import com.longtailvideo.jwplayer.model.PlaylistItem;
	
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.vast.config.groupings.AdMetaDataConfigGroup;
	import org.openvideoads.vast.config.groupings.ProvidersConfigGroup;
	import org.openvideoads.vast.playlist.DefaultPlaylist;
	import org.openvideoads.vast.playlist.PlaylistItem;
	import org.openvideoads.vast.schedule.StreamSequence;
	import org.openvideoads.vast.schedule.ads.AdSlot;
	
	/**
	 * @author Paul Schulz
	 */
	public class JWPlaylist extends DefaultPlaylist {	
		protected var _holdingClipUrl:String = null;	
        
		public function JWPlaylist(streamSequence:StreamSequence=null, showProviders:ProvidersConfigGroup=null, adProviders:ProvidersConfigGroup=null, holdingClipUrl:String=null) {
			_holdingClipUrl = holdingClipUrl;
			super(streamSequence, showProviders, adProviders);
		}

		public override function newPlaylistItem():org.openvideoads.vast.playlist.PlaylistItem {
			return new JWPlaylistItem(_holdingClipUrl);
		}		
		
		
		public function toJWPlaylistItemArray(retainPrefix:Boolean, metaDataConfig:AdMetaDataConfigGroup, holdingClipUrl:String=null):Array {
			var result:Array = new Array();
			for(var i:int=0; i < _playlist.length; i++) {
                var newClip:com.longtailvideo.jwplayer.model.PlaylistItem = _playlist[i].toJWPlaylistItemObject(retainPrefix, metaDataConfig, holdingClipUrl);
                if(newClip != null) {
					result.push(newClip);
                }
			}
			return result;
		}
		
		public override function toShortString(retainPrefix:Boolean = false):String {
			var content:String = new String();
			for(var i:int=0; i < _playlist.length; i++) {
				if(_playlist[i] is AdSlot) {
					content += i + ":" + _playlist[i].toShortString();
				}
				else content += i + ":" + _playlist[i].toShortString(retainPrefix); 
				content += ((i < _playlist.length) ? ",\n" : "");
			}
			return content;
		}
		
		public override function toString(retainPrefix:Boolean = false):String {
			var content:String = new String();
			for(var i:int=0; i < _playlist.length; i++) {
				if(_playlist[i] is AdSlot) {
					content += i + ":" + _playlist[i].toString();
				}
				else content += i + ":" + _playlist[i].toString(retainPrefix);
				content += ((i < _playlist.length) ? ",\n" : "");
			}
			return content;
		}
	}
}

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
	import org.openvideoads.vast.config.groupings.AdMetaDataConfigGroup;
    import org.openvideoads.vast.config.groupings.ProvidersConfigGroup;
    import org.openvideoads.vast.playlist.DefaultPlaylist;
    import org.openvideoads.vast.playlist.PlaylistItem;
    import org.openvideoads.vast.schedule.StreamSequence;
	
	/**
	 * @author Paul Schulz
	 */
	public class JWPlaylist extends DefaultPlaylist {		

		public function JWPlaylist(streamSequence:StreamSequence=null, showProviders:ProvidersConfigGroup=null, adProviders:ProvidersConfigGroup=null) {
			super(streamSequence, showProviders, adProviders);
		}

		public override function newPlaylistItem():PlaylistItem {
			return new JWPlaylistItem();
		}		
		
		
		public function toJWPlaylistItemArray(retainPrefix:Boolean, metaDataConfig:AdMetaDataConfigGroup):Array {
			var result:Array = new Array();
			for(var i:int=0; i < _playlist.length; i++) {
				result.push(_playlist[i].toJWPlaylistItemObject(retainPrefix, metaDataConfig));
			}
			return result;
		}
		
		public override function toString(retainPrefix:Boolean = false):String {
			var content:String = new String();
			for(var i:int=0; i < _playlist.length; i++) {
				content += _playlist[i].toString(retainPrefix) + ((i < _playlist.length) ? ", " : "");
			}
			return content;
		}
	}
}

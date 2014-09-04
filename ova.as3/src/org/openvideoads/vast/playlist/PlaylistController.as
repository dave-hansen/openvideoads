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
	import org.openvideoads.vast.config.groupings.ProvidersConfigGroup;
	import org.openvideoads.vast.playlist.mrss.MediaRSSPlaylist;
	import org.openvideoads.vast.playlist.smil.SMILPlaylist;
	import org.openvideoads.vast.schedule.StreamSequence;
	
	/**
	 * @author Paul Schulz
	 */
	public class PlaylistController {
		public static const PLAYLIST_FORMAT_DEFAULT:int = 1;
		public static const PLAYLIST_FORMAT_RSS:int = 2;
		public static const PLAYLIST_FORMAT_XML:int = 3;
		public static const PLAYLIST_FORMAT_SMIL:int = 4;
		public static const PLAYLIST_FORMAT_MEDIA:int = 5;
		public static const PLAYLIST_FORMAT_XSPF:int = 6;

		public static function createPlaylist(streamSequence:StreamSequence, type:int=PLAYLIST_FORMAT_DEFAULT, showProviders:ProvidersConfigGroup=null, adProviders:ProvidersConfigGroup=null):Playlist {
			switch(type) {
				case PLAYLIST_FORMAT_SMIL:
					return new SMILPlaylist(streamSequence, showProviders, adProviders);
				case PLAYLIST_FORMAT_MEDIA:
					return new MediaRSSPlaylist(streamSequence, showProviders, adProviders);
			}
			return new DefaultPlaylist(streamSequence, showProviders, adProviders);
		}
		
		public static function getPlaylistObject(type:int=PLAYLIST_FORMAT_DEFAULT):Playlist {
			switch(type) {
				case PLAYLIST_FORMAT_SMIL:
					return new SMILPlaylist();
				case PLAYLIST_FORMAT_MEDIA:
					return new MediaRSSPlaylist();
			}
			return new DefaultPlaylist();			
		}
		
		public static function getType(type:String):int {
			switch(type.toUpperCase()) {
				case "SMIL":
					return PLAYLIST_FORMAT_SMIL;
				case "MRSS":
					return PLAYLIST_FORMAT_MEDIA;
			}
			return PLAYLIST_FORMAT_DEFAULT;			
		}
	}
}
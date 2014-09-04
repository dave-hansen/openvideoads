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
	import org.openvideoads.vast.playlist.Playlist;
	import org.openvideoads.vast.playlist.PlaylistController;
	import org.openvideoads.vast.playlist.PlaylistLoadListener;
	
	
	public class ShowsPlaylistConfigGroup extends Debuggable implements PlaylistLoadListener {
		protected var _url:String = null;
		protected var _type:int = PlaylistController.PLAYLIST_FORMAT_MEDIA;
		protected var _playlist:Playlist = null;
		
		public function ShowsPlaylistConfigGroup(config:Object) {
			if(config.type != undefined) {
				_type = PlaylistController.getType(config.type);
			}
			if(config.url != undefined || config.file != undefined) {
				_url = (config.url != undefined) ? config.url : config.file;
				loadPlaylistFromExternalURL();
			}
		}

		protected function loadPlaylistFromExternalURL():void {
			if(_type != -1) {
				_playlist = PlaylistController.getPlaylistObject(_type);
				_playlist.loadFromURL(_url, this);				
			}
			else {
				CONFIG::debugging { doLog("Cannot load playlist from external source - no playlist object available", Debuggable.DEBUG_PLAYLIST); }
			}
		}	
		
		public function onPlaylistLoaded(playlist:Playlist):void {
			CONFIG::debugging { doLog("XXX NOT IMPLEMENTED - NEED TO CALL BACK TO CONTINUE INITIALISATION"); }
		}
			
		public function set url(url:String):void {
			_url = url;
		}
		
		public function get url():String {
			return _url;
		}
		
		public function set type(type:int):void {
			_type = type;
		}
		
		public function get type():int {
			return _type;
		}
		
		public function toShowStreamsConfigArray():Array {
			if(_playlist != null) {
				return _playlist.toShowStreamsConfigArray();
			}
			else return new Array();
		}
	}
}
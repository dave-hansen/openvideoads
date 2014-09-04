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
 *
 *    Example format:
 *
 *		<playlist version="1" xmlns="http://xspf.org/ns/0/">
 *			<trackList>
 *				<track>
 *					<creator>Creator name1</creator>
 *					<title>This is an mp4</title>
 *					<meta rel="streamer">rtmp://ne7c0nwbit.rtmphost.com/videoplayer</meta>
 *					<location>ads/30secs/country_life_butter.mp4</location>
 *					<meta rel="type">rtmp</meta>
 *				</track>
 *			</trackList>
 *		</playlist>
 */
 package org.openvideoads.vast.playlist.xspf {
    import org.openvideoads.vast.config.groupings.ProvidersConfigGroup;
    import org.openvideoads.vast.playlist.DefaultPlaylist;
    import org.openvideoads.vast.playlist.PlaylistItem;
    import org.openvideoads.vast.schedule.StreamSequence;
	
	/**
	 * @author Paul Schulz
	 */
	public class XSPFPlaylist extends DefaultPlaylist {		
		public static var HTTP_STREAMER_TYPE_LIGHTTPD:String = "lighttpd";
		
		public function XSPFPlaylist(streamSequence:StreamSequence=null, showProviders:ProvidersConfigGroup=null, adProviders:ProvidersConfigGroup=null) {
			super(streamSequence, showProviders, adProviders);
		}

		public override function newPlaylistItem():PlaylistItem {
			return new XSPFPlaylistItem();
		}		
		
		public override function getModel():Array {
			return new Array();
		}

	    protected override function header():String {
			var content:String = new String();
			content += '<playlist version="1" xmlns="http://xspf.org/ns/0/">';
			content += '<title>No Title Provided</title>';
			content += '<trackList>';	    	
			return content;
	    }

	    protected override function footer():String {
			return '</trackList></playlist>';
	    }
	    
		public override function toString(retainPrefix:Boolean = false):String {
			var content:String = new String();
			content = header();
			for(var i:int=0; i < _playlist.length; i++) {
				content += _playlist[i].toString(retainPrefix);
			}
			content += footer();
			return content;
		}
	}
}

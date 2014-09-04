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
 *				<track>
 *					<creator>Creator name1</creator>
 *					<title>This is an mp4</title>
 *					<meta rel="streamer">rtmp://ne7c0nwbit.rtmphost.com/videoplayer</meta>
 *					<meta rel="provider">rtmp://ne7c0nwbit.rtmphost.com/videoplayer</meta>
 *					<location>ads/30secs/country_life_butter.mp4</location>
 *					<meta rel="type">rtmp</meta>
 *					<meta rel="start">0</meta>
 *					<meta rel="duration">30</meta>
 *				</track>
 */
package org.openvideoads.vast.playlist.xspf {
	import org.openvideoads.vast.playlist.DefaultPlaylistItem;
	
	/**
	 * @author Paul Schulz
	 */
	public class XSPFPlaylistItem extends DefaultPlaylistItem {

		public override function get title():String {
			return "XSPF Playlist";
		}
		
		public override function toString(retainPrefix:Boolean = false):String {
			var result:String = new String();
			result += '<track>';
			result += '<creator>' + getAuthor() + '</creator>';
			if(isRTMP()) {
// 			    result += '<meta rel="type">' + provider + '</meta>';
                result += '<meta rel="type">rtmp</meta>';
                result += '<meta rel="provider">rtmp</meta>';
				result += '<meta rel="streamer">' + getStreamer() + '</meta>';
				result += '<location>' + getFilename(retainPrefix) + '</location>';
			}
			else {
				/* Works for XMOOV
				result += '<location>dogs_600_with_metadata.flv</location>';
				result += '<meta rel="streamer">http://static.bouncingminds.com/xmoov/xmoov.php</meta>';
				*/
				result += '<location>' + url + '</location>';				
				result += '<meta rel="type">' + provider + '</meta>';
				result += '<meta rel="streamer">' + provider + '</meta>';
				result += '<meta rel="provider">' + provider + '</meta>';
			}
   		    result += '<meta rel="start">' + getStartTimeAsSeconds() + '</meta>';
   		    if((getStartTimeAsSeconds() + getDurationAsSeconds()) > 0) {
				result += '<meta rel="duration">' + (getStartTimeAsSeconds() + getDurationAsSeconds()) + '</meta>';	    	
   		    }
			if(hasPreviewImage()) {
				result += '<image>' + getPreviewImage() + '</image>';
			}
			result += '</track>';
			return result;
		}
	}
}


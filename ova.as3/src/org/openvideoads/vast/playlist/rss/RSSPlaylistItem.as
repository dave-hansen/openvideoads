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
 *    Example RSS format:
 *
 *		  <item>
 *				<title>PLAY LIST TITLE</title>
 *				<description>PLA LIST DESCRIPTION</description>
 *				<meta rel="type">rtmp</meta> 
 *				<enclosure url="YOUR FILENAME.mp4"></enclosure> 
 *		  </item>
 */
package org.openvideoads.vast.playlist.rss {
	import org.openvideoads.vast.playlist.DefaultPlaylistItem;
	
	/**
	 * @author Paul Schulz
	 */
	public class RSSPlaylistItem extends DefaultPlaylistItem {
		
		public override function toString(retainPrefix:Boolean = false):String {
			var result:String = new String();
			result += '<item>';
			result += '<title>' + title + '</title>';
//			result += '<link>' + getLink() + '</link>';
//			result += '<description>' + getDescription() + '</description>';
			if(isRTMP()) result += '<jwplayer:streamer>' + getStreamer() + '</jwplayer:streamer>';
			result += '<jwplayer:type>' + provider + '</jwplayer:type>';
			result += '<enclosure url="' + getFilename(false) + '" />'; //</enclosure>';
//			result += '<enclosure url="' + getFilename() + '" type="' + getType() + '" length="' + getLength() + '" />';
//			result += '<jwplayer:duration>' + getDuration() + '</jwplayer:type>';
//			result += '<jwplayer:author>' + getAuthor() + '</jwplayer:author>';
			result += '</item>';
			return result;
		}
	}
}

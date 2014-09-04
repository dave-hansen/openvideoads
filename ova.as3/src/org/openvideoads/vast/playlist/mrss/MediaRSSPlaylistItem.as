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
 *    Example MRSS item format:
 * 
 *		<item>
 *			<title>Big Buck Bunny - FLV Video</title>
 *			<link>http://www.bigbuckbunny.org/</link>
 *			<description>Big Buck Bunny is a short animated film by the Blender Institute</description>
 *			<media:credit role="author">the Peach Open Movie Project</media:credit>
 *			<media:content url="http://www.longtailvideo.com/jw/upload/bunny.flv" type="video/x-flv" duration="33" />
 *		</item>
 *
 *      <item>
 *			<description>Kaltura Item</description> 
 *			<guid isPermaLink="false">34962|arhzhssxws</guid> 
 *			<link/> 
 *			<pubDate>2009-08-03 13:05:02</pubDate> 
 * 			<media:content url="http://cdn.kaltura.com/p/34962/sp/3496200/flvclipper/entry_id/arhzhssxws/version/100000" fileSize="1136041" type="video/x-flv" medium="video" duration="20" lang="en"/> 
 *			<media:title type="plain">dogs_600.mp4</media:title> 
 *			<media:description/> 
 *			<media:keywords>dogs 600 mp4 dog video ad</media:keywords> 
 *			<media:thumbnail url="http://cdn.kaltura.com/p/34962/sp/3496200/thumbnail/entry_id/arhzhssxws/version/100001"/> 
 *			<media:credit role="kaltura partner">34962</media:credit> 
 *      </item> 
 */
 package org.openvideoads.vast.playlist.mrss {
	import org.openvideoads.vast.playlist.DefaultPlaylistItem;
	import org.openvideoads.util.Timestamp;
	
	/**
	 * @author Paul Schulz
	 */
	public class MediaRSSPlaylistItem extends DefaultPlaylistItem {
		
		public override function toString(retainPrefix:Boolean = false):String {
			var result:String = new String();
			result += '<item>';
			result += '<title>' + title + '</title>';
			result += '<link>' + link + '</link>';
			result += '<description>' + description + '</description>';
			result += '<guid>' + guid + '</guid>'; 
			result += '<media:content url="' + url + '" duration="' + Timestamp.timestampToSeconds(duration) + '" type="' + mimeType + '"/>';			
			result += '<media:title>' + filename + '</media:title>';			
			result += '<media:credit role="author">' + getAuthor() + '</media:credit>';
			result += '</item>';
			return result;
		}
	}
}

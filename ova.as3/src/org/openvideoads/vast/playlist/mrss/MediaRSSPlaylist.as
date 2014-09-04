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
 *    Example Media RSS format:
 * 
 * 		<rss version="2.0" xmlns:media="http://search.yahoo.com/mrss/">
 *			<channel>
 *              <description></description>
 *				<title>Example media RSS playlist for the JW Player</title>
 *				<link>http://www.longtailvideo.com</link>
 *				<item>
 *					<title>Big Buck Bunny - FLV Video</title>
 *					<link>http://www.bigbuckbunny.org/</link>
 *					<description>Big Buck Bunny is a short animated film by the Blender Institute, part of the Blender Foundation.</description>
 *					<media:credit role="author">the Peach Open Movie Project</media:credit>
 *					<media:content url="http://www.longtailvideo.com/jw/upload/bunny.flv" type="video/x-flv" duration="33" />
 *					<media:thumbnail url="http://www.longtailvideo.com/jw/upload/bunny.jpg" />
 *				</item>
 *			</channel>
 *		</rss>
 */
 package org.openvideoads.vast.playlist.mrss {
 	import org.openvideoads.base.Debuggable;
 	import org.openvideoads.util.Timestamp;
 	import org.openvideoads.vast.config.groupings.ProvidersConfigGroup;
 	import org.openvideoads.vast.playlist.DefaultPlaylist;
 	import org.openvideoads.vast.playlist.PlaylistItem;
 	import org.openvideoads.vast.schedule.StreamSequence;
	
	/**
	 * @author Paul Schulz
	 */
	public class MediaRSSPlaylist extends DefaultPlaylist {		
		protected var _description:String = "Not available";
		protected var _title:String = "";
		protected var _link:String = "Not available";
		
		public function MediaRSSPlaylist(streamSequence:StreamSequence=null, showProviders:ProvidersConfigGroup=null, adProviders:ProvidersConfigGroup=null) {
			super(streamSequence, showProviders, adProviders);
		}

        public override function loadFromString(rawData:String):void {
        	var mediaNs:Namespace = new Namespace("http://search.yahoo.com/mrss/");
        	CONFIG::debugging { doLog("Parsing a MRSS playlist: ", Debuggable.DEBUG_PLAYLIST); }
	      	XML.ignoreWhitespace = true;
	      	var xmlData:XML = new XML(rawData);
			CONFIG::debugging { doLog(xmlData, Debuggable.DEBUG_PLAYLIST); }
			if(xmlData.length() > 0) {
	        	if(xmlData.channel.description != null) _description = xmlData.channel.description.text();
	        	if(xmlData.channel.title != null) _title = xmlData.channel.title.text();
	        	if(xmlData.channel.link != null) _link = xmlData.channel.link.text();
	        	for(var i:int=0; i < xmlData.channel.item.length(); i++) {
	        		var item:XML = xmlData.channel.item[i];
	        		var mrssItem:MediaRSSPlaylistItem = new MediaRSSPlaylistItem();
	        		mrssItem.description = item.description;
	        		mrssItem.guid = item.guid;
	        		mrssItem.link = item.link;
	        		mrssItem.publishDate = item.pubDate;        		
	        		mrssItem.url = item.mediaNs::content.@url;
	        		mrssItem.mimeType = item.mediaNs::content.@type;
	        		mrssItem.filename = item.mediaNs::title;
	        		mrssItem.duration = Timestamp.secondsToTimestamp(item.mediaNs::content.@duration);
	        		CONFIG::debugging { doLog("Parsed playlist item " + i + " - added", Debuggable.DEBUG_PLAYLIST); }
	        		_playlist.push(mrssItem);
	        	}
	        	CONFIG::debugging { doLog(this.toString(), Debuggable.DEBUG_PLAYLIST); }
 			}
 			else {
 				CONFIG::debugging { doLog("Parse failed: rawData is not an XML playlist", Debuggable.DEBUG_PLAYLIST); }
 			}
        }
        
		public override function newPlaylistItem():PlaylistItem {
			return new MediaRSSPlaylistItem();
		}		
		
		public override function getModel():Array {
			return new Array();
		}

		public override function toString(retainPrefix:Boolean = false):String {
			var content:String = new String();
			content += '<rss version="2.0" xmlns:media="http://search.yahoo.com/mrss/">';
			content += '<channel>';
			content += '<description>' + _description + '</description>';
			content += '<title>' + _title + '</title>';
			content += '<link>' + _link + '</link>';
			for(var i:int=0; i < _playlist.length; i++) {
				content += _playlist[i].toString(retainPrefix);
			}
			content += '</channel>';
			content += '</rss>';
			return content;
		}
	}
}

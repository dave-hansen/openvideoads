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
 *			<track>
 *				<creator>Creator name1</creator>
 *				<title>This is an mp4</title>
 *				<location>rtmpe://yourstremersite.com/yourapplicationname/</location>
 *				<identifier>mp4:test.mp4</identifier>
 *				<meta rel="type">rtmp</meta>
 *			</track>
 */
 package org.openvideoads.vast.playlist.xml {
	import org.openvideoads.vast.playlist.DefaultPlaylistItem;
	
	/**
	 * @author Paul Schulz
	 */
	public class XMLPlaylistItem extends DefaultPlaylistItem {
		
		public override function toString(retainPrefix:Boolean = false):String {
			var result:String = new String();
			result += '<track>';
			result += '<creator>' + getAuthor() + '</creator>';
			result += '<title>' + title + '</title>';
			if(isRTMP()) result += '<meta rel="streamer">' + getStreamer() + '</meta>';
			result += '<location>' + getFilename(false) + '</location>';
//			result += '<duration>' + getDuration() + '</duration>';
			result += '<meta rel="type">' + getType() + '</meta>';
			result += '</track>';
			return result;
		}
	}
}

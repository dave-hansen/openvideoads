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
 *		<?xml version="1.0" encoding="UTF-8"?>
 *		<playlist version="1" xmlns="http://xspf.org/ns/0/">
 *		<trackList>
 *			<track>
 *				<creator>Creator name1</creator>
 *				<title>This is an mp4</title>
 *				<location>rtmpe://yourstremersite.com/yourapplicationname/</location>
 *				<identifier>mp4:test.mp4</identifier>
 *				<meta rel="type">rtmp</meta>
 *			</track>
 *			<track>
 *				<creator>Creator name2</creator>
 *				<title>this is an FLV</title>
 *				<location>rtmpe://yourstremersite.com/yourapplicationname/</location>
 *				<identifier>flvtest</identifier>
 *				<meta rel="type">rtmp</meta>
 *			</track>
 *		</trackList>
 *		</playlist>
 */
 package org.openvideoads.vast.playlist.xml {
    import org.openvideoads.vast.config.groupings.ProvidersConfigGroup;
    import org.openvideoads.vast.playlist.DefaultPlaylist;
    import org.openvideoads.vast.playlist.PlaylistItem;
    import org.openvideoads.vast.schedule.StreamSequence;
	
	/**
	 * @author Paul Schulz
	 */
	public class XMLPlaylist extends DefaultPlaylist {		
		
		public function XMLPlaylist(streamSequence:StreamSequence=null, showProviders:ProvidersConfigGroup=null, adProviders:ProvidersConfigGroup=null) {
			super(streamSequence, showProviders, adProviders);
		}

		public override function newPlaylistItem():PlaylistItem {
			return new XMLPlaylistItem();
		}		
		
		public override function getModel():Array {
			return new Array();
		}

		public override function toString(retainPrefix:Boolean = false):String {
			var content:String = new String();
			content += '<?xml version="1.0" encoding="UTF-8"?>';
			content += '<playlist version="1" xmlns="http://xspf.org/ns/0/">';
			content += '<trackList>';
			for(var i:int=0; i < playlist.length; i++) {
				content += _playlist[i].toString(retainPrefix);
			}
			content += '</trackList>';
			content += '</playlist>';
			return content;
		}
	}
}

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
 package org.openvideoads.vast.playlist.smil {
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.vast.config.groupings.ProvidersConfigGroup;
	import org.openvideoads.vast.playlist.DefaultPlaylist;
	import org.openvideoads.vast.schedule.StreamSequence;
	
	/**
	 * @author Paul Schulz
	 */
	public class SMILPlaylist extends DefaultPlaylist {		
		
		public function SMILPlaylist(streamSequence:StreamSequence=null, showProviders:ProvidersConfigGroup=null, adProviders:ProvidersConfigGroup=null) {
			super(streamSequence, showProviders, adProviders);
		}

        public override function loadFromString(xmlData:String):void {
        	CONFIG::debugging { doLog("Have retrieved the SMIL XML data - parsing to extract the final stream address and filename...", Debuggable.DEBUG_PLAYLIST); }
            var smil:XML = new XML(xmlData);
            addTrack(new SMILPlaylistItem(smil.children()[0].children()[0].@base.toString(), smil.children()[1].children()[0].@src.toString()));            
        }
		
		public override function getModel():Array {
			return new Array();
		}

		public override function toString(retainPrefix:Boolean = false):String {
			return new String();
		}
	}
}
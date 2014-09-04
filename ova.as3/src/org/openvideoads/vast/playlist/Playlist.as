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
	import org.openvideoads.vast.schedule.Stream;
	

	/**
	 * @author Paul Schulz
	 */
	public interface Playlist {		
		function loadFromURL(url:String, playlistLoadListener:PlaylistLoadListener=null):void;
		function loadFromString(xmlData:String):void;
		function newPlaylistItem():PlaylistItem;
		function updatePlaylistItem(stream:Stream, playlistIndex:int):void;
		function getModel():Array;
        function reset():void;
        function rewind():void;
		function get playingTrackIndex():int;
		function get currentTrackIndex():int;
		function currentTrackAsPlaylistXML(startTime:int=0, retainPrefix:Boolean = false):XML;
		function nextTrackAsPlaylistString(retainPrefix:Boolean = false, canMarkAsRewound:Boolean=true):String;
		function nextTrackAsPlaylistXML(retainPrefix:Boolean = false):XML;
		function previousTrackAsPlaylistString(retainPrefix:Boolean = false):String;
		function previousTrackAsPlaylistXML(retainPrefix:Boolean = false):XML;
		function getTrackAtIndex(index:int):PlaylistItem;
		function isFirstTrackIsInteractive():Boolean;
		function get length():int;
		function toShowStreamsConfigArray():Array;
		function toXML(retainPrefix:Boolean = false):XML;
		function toShortString(retainPrefix:Boolean = false):String;
		function toString(retainPrefix:Boolean = false):String;
	}
}
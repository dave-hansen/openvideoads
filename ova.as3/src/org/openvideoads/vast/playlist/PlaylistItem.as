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
 	import org.openvideoads.vast.config.groupings.ProvidersConfigGroup;
 	import org.openvideoads.vast.schedule.Stream;
	
	/**
	 * @author Paul Schulz
	 */
	public interface PlaylistItem {
		function set stream(stream:Stream):void;
		function get stream():Stream;
		function set index(index:int):void;
		function get index():int;
        function set provider(provider:String):void;
        function get provider():String;
        function set providers(providers:ProvidersConfigGroup):void;
        function get providers():ProvidersConfigGroup;
        function set streamer(streamer:String):void;
        function get streamer():String;
		function get title():String;
		function get link():String;
		function get description():String;
		function set filename(filename:String):void;
		function get filename():String;
		function set url(url:String):void;
		function get url():String;
		function set mimeType(mimeType:String):void;
		function get mimeType():String;
		function get loadOnDemand():Boolean;
		function isAd():Boolean;
		function isInteractive():Boolean;
		function getFilename(retainPrefix:Boolean=true):String;
		function getQualifiedStreamAddress():String;
		function get duration():String;
		function getDurationAsSeconds():int;
		function getStartTime():String;
		function getStartTimeAsSeconds():int;
		function getAuthor():String;
		function getType():String;
		function getStreamer():String;
		function toString(retainPrefix:Boolean = false):String;
		function toShowStreamConfigObject():Object;
		function isRTMP():Boolean;
		function isHTTP():Boolean;
		function reset():void;
		function rewind():void;
		function requiresLoading():Boolean;	
		function sync():Boolean;
	}
}
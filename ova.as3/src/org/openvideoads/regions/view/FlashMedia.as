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
package org.openvideoads.regions.view {

	/**
	 * @author Paul Schulz
	 */
	public interface FlashMedia {
		function get swfURL():String;
		function get recommendedWidth():int;
		function get recommendedHeight():int;
		function get enforceRecommendedSizing():Boolean; 
		function markAsLoading():void;
		function markAsLoaded():void;
		function get loaded():Boolean;
		function get maintainAspectRatio():Boolean;
		function get scale():Boolean;
		function unload():void;
		function signalLoadError(errorMessage:String):void;
	}
}
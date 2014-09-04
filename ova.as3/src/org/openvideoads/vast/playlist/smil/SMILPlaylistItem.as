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
	import org.openvideoads.vast.playlist.DefaultPlaylistItem;
	
	public class SMILPlaylistItem extends DefaultPlaylistItem {
		public function SMILPlaylistItem(base:String=null, src:String=null, duration:int=0, title:String=null, description:String=null) {
			if(base != null) _url = base;
			if(src != null) _filename = src;
		}
	}
}
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
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.util.NetworkResource;
	
	import flash.text.StyleSheet;
	
	/**
	 * @author Paul Schulz
	 */
	public class LoadableStyleSheet extends NetworkResource {
		private var _onLoadCallback:Function;
		private var _styleSheet:StyleSheet;
		
		public function LoadableStyleSheet(stylesheetAddress:String=null, onLoadCallback:Function=null) {
			_onLoadCallback = onLoadCallback;
			_styleSheet = new StyleSheet();
			if(stylesheetAddress != null) {
				url = stylesheetAddress;
				CONFIG::debugging { doLog("Loading up external stylesheet file from " + url, Debuggable.DEBUG_DISPLAY_EVENTS); }
				call();
			}
		}

		protected override function loadComplete(data:String):void {
			CONFIG::debugging { doLog("Stylesheet data loaded from external file - updating the stylesheet settings to include...", Debuggable.DEBUG_DISPLAY_EVENTS); }
			_styleSheet = new StyleSheet();
			parseCSS(data);
			if(_onLoadCallback != null) _onLoadCallback();
		}
		
		public function parseCSS(data:String):void {
			_styleSheet.parseCSS(data);			
		}
		
		public function get stylesheet():StyleSheet {
			return _styleSheet;
		}
	}
}
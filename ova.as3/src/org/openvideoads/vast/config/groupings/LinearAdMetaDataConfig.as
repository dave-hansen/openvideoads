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
package org.openvideoads.vast.config.groupings {
	import org.openvideoads.base.Debuggable;
	
	/**
	 * @author Paul Schulz
	 */
	public class LinearAdMetaDataConfig extends Debuggable {
		protected var _title:String = null;
		protected var _description:String = null;

	 	public function LinearAdMetaDataConfig(config:Object=null) {
			initialise(config);
		}
		
		public function initialise(config:Object):void {
			if(config != null) {
				if(config.title != undefined) _title = config.title;
				if(config.description != undefined) _description = config.description;
			}
		}
		
		public function get title():String {
			return _title;
		}
		
		public function set title(title:String):void {
			_title = title;
		}
		
		public function hasTitleSpecified():Boolean {
			return (_title != null);
		}
		
		public function get description():String {
			return _description;
		}
		
		public function set description(description:String):void {
			_description = description;
		}
		
		public function hasDescriptionSpecified():Boolean {
			return (_description != null);
		}
		
		protected function replaceTemplate(data:String, pattern:String, value:String):String {
			var thePattern:RegExp = new RegExp(pattern, "g");
			return data.replace(thePattern, value);
		}

		public function getAdTitle(defaultTitle:String="", duration:String="0", index:int=-1):String {
			if(hasTitleSpecified()) {
				var result:String = replaceTemplate(_title, "__duration__", duration);
				result = replaceTemplate(result, "__index__", new String(index));
				return result;
			}
			return defaultTitle;
		}

		public function getAdDescription(defaultDescription:String="", duration:String="0", index:int=-1):String {
			if(hasDescriptionSpecified()) {
				var result:String = replaceTemplate(_description, "__duration__", duration);
				result = replaceTemplate(result, "__index__", new String(index));
				return result;
			}
			return defaultDescription;
		}
	}
}
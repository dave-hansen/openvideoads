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
package org.openvideoads.vast.server.config {
	import flash.external.ExternalInterface;
	import flash.utils.Dictionary;
	
	import org.openvideoads.base.Debuggable;
	
	/**
	 * @author Paul Schulz
	 */
	public class CustomProperties extends Debuggable {
		protected var _properties:Dictionary = new Dictionary();
		
		public function CustomProperties(properties:Object = null) {
			addProperties(properties);
		}
		
		public function set properties(properties:Dictionary):void {
			_properties = properties;
		}
		
		public function get properties():Dictionary {
			return _properties;
		}
		
		public function addProperties(additions:Object):void {
			if(additions != null) {
				for(var key:String in additions) {
                    _properties[key] = additions[key];
				}				
			}
		}
		
		protected function convertArrayToParamString(values:Array):String {
			var result:String = "";
			for(var key:int=0; key < values.length; key++) {
				if(result.length > 0) result += "&";
				result += values[key];
			}
			return result;
		}
		
		public function completeTemplate(template:String, alwaysAdd:Boolean=false):String {
			var thePattern:RegExp;
			var replacementValue:String;
			for(var key:String in _properties) {
				var searchString:String = "__" + key + "__";
				if(template.indexOf(searchString) > -1) {
					thePattern = new RegExp(searchString, "g");
					if(_properties[key] is Array) {
						template = template.replace(thePattern, convertArrayToParamString(_properties[key]));
					}
					else template = template.replace(thePattern, _properties[key]);
				}
				else if(alwaysAdd) {
					// it's not in the URL template, so add it anyway at the end
					template += "&" + key + "=" + _properties[key];
				}
			}				
			return template;
		}
	}
}
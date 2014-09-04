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
package org.openvideoads.util {
	import com.adobe.serialization.json.JSON;

	/**
	 * @author Paul Schulz
	 */
	public class ArrayUtils {
		public function ArrayUtils() {
		}
		
		public static function makeArray(value:Object):Array {
			if(value is Array) {
				return value as Array;
			}
			else {
				if(value is String) {
					var result:* = com.adobe.serialization.json.JSON.decode(value as String);
					if(result is Array) {
						return result;
					}
					else if(result is String) {
						return result.split(",");
					}
				}
			}
			return new Array();
		}
		
		public static function toUpperCase(items:Array):Array {
			var result:Array = new Array();
			if(items != null) {
				for(var i:int=0; i < items.length; i++) {
					if(items[i] is String) {
						result.push(items[i].toUpperCase());
					}
					else result.push(items[i].toJSObject());	
				}			
			}
			return result;
		}

		public static function convertToJSObjectArray(items:Array):Array {
			var result:Array = new Array();
			if(items != null) {
				for(var i:int=0; i < items.length; i++) {
					result.push(items[i].toJSObject());	
				}			
			}
			return result;
		}
	}
}
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

	/**
	 * @author Paul Schulz
	 */
	public class StyleUtils {
		public function StyleUtils() {
		}
		
		public static function toColorValue(color:String):uint {
			if(!color) return 0xffffff;
			return parseInt("0x" + color.substr(1));;
		}
		
		public static function toElements(shortFormPropertyValue:String):Array {
			return shortFormPropertyValue.split(" ");
		}		

		public static function findInShorthand(shorthand:String, prefix:String):String {
			var elements:Array = toElements(shorthand);
			for (var i:Number = 0; i < elements.length; i++) {
				if (elements[i] is String && String(elements[i]).indexOf(prefix) == 0) {
					return elements[i] as String;
				}
			}
			return null;
		}
	}
}
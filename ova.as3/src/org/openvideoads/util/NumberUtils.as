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
	public class NumberUtils {
		private static function convert(indicator:String, raw:String):Number {
			if(raw.indexOf(indicator) <= 0) {
				return NaN
			}
			return Number(raw.substring(0, raw.indexOf(indicator))); 
		}

		public static function toPixels(raw:*):Number {
			if(raw is Number) return Math.round(raw);
			if(raw.indexOf("px") < 0) {
				raw += "px";
			}
			var result:Number = convert("px", raw);
			if(isNaN(result)) {
				return raw.substr(0) as Number;			
			}
			return Math.round(result);
		}

		public static function toPercentage(raw:*):Number {
			if(raw is Number) return raw;
			if(raw.indexOf("pct") > -1) {
				return convert("pct", raw);
			}
			return convert("%", raw);
		}
	}
}

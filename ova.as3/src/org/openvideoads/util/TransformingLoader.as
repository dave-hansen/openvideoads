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
import flash.external.ExternalInterface;
import flash.net.URLLoader;

	/**
	 * @author Paul Schulz
	 */

	public class TransformingLoader extends URLLoader {
		protected var _transformers:Array = null;

		public function TransformingLoader() {
			super();
		}

		public function set transformers(transformers:Array):void {
			_transformers = transformers;
		}	
		
		public function get transformedData():String {
			if(_transformers != null) {
				if(_transformers.length > 0) {
					// work through the regex transformers, modify the data and return that
					var result:String = super.data;
					for(var i:int=0; i < _transformers.length; i++) {
						if(_transformers[i].hasOwnProperty("pattern") && _transformers[i].hasOwnProperty("replace")) {
							result = result.replace(
								new RegExp(
									_transformers[i].pattern, 
									_transformers[i].hasOwnProperty("command") ? _transformers[i].hasOwnProperty("command") : "g"
								), 
								_transformers[i].replace);
						}
					}
				}
				return result;
			}
			return super.data;
		}
	}
}
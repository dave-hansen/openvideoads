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

	/**
	 * @author Paul Schulz
	 */
	import org.openvideoads.base.Debuggable;
	
	public class SurveyConfig extends Debuggable {

		protected var _id:String = null;
		protected var _restore:Boolean = true;
		
		public function SurveyConfig(config:Object=null) {
			if(config != null) {
				initialise(config);
			}
		}
		
		protected function initialise(config:Object):void {
			if(config.id != undefined) {
				_id = config.id;
			}
			if(config.restore != undefined) {
				if(config.restore is String) {
					_restore = ((config.restore.toUpperCase() == "TRUE") ? true : false);											
				}
				else _restore = config.restore;
			}
		}

		public function get id():String {
			return _id;
		}
		
		public function declared():Boolean {
			return (_id != null);
		}
		
		public function get restore():Boolean {
			return _restore;
		}
	}
}
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
	public class AdMetaDataConfigGroup extends Debuggable {
		protected var _linearAdMetaData:LinearAdMetaDataConfig = new LinearAdMetaDataConfig();
		
		public function AdMetaDataConfigGroup(config:Object=null) {
			initialise(config);
		}
		
		public function initialise(config:Object):void {
			if(config != null) {
				if(config.linear != undefined) {
					_linearAdMetaData.initialise(config.linear);
				}
			}
		}

		public function getLinearAdTitle(defaultTitle:String="", duration:String="0", index:int=-1):String {
			if(_linearAdMetaData != null) {
				return _linearAdMetaData.getAdTitle(defaultTitle, duration, index);			
			}
			return "";
		}

		public function getLinearAdDescription(defaultDescription:String="", duration:String="0", index:int=-1):String {
			if(_linearAdMetaData != null) {
				return _linearAdMetaData.getAdDescription(defaultDescription, duration, index);			
			}
			return "";
		}
	}
}
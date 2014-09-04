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
	import org.openvideoads.util.ArrayUtils;

	public class CompanionsConfigGroup extends Debuggable {
		protected var _companionDivIDs:Array = new Array(); 
		protected var _displayCompanions:Boolean = true;
		protected var _restoreCompanions:Boolean = true;
		protected var _nativeDisplay:Boolean = true;
		protected var _millisecondDelayOnCompanionInjection:int = 0;
		protected var _additionalParamsForSWFCompanions:Array = new Array();

		public function CompanionsConfigGroup(config:Object=null) {
			if(config != null) {
				initialise(config);
			}
		}
		
		public function initialise(config:Object = null):void {
			if(config.regions != undefined) {				
				if(config.regions is String) {
					this.companionDivIDs = ArrayUtils.makeArray(config.regions);
				}
				else this.companionDivIDs = config.regions;
			}
			if(config.enable != undefined) {
				if(config.enable is String) {
					this.displayCompanions = (config.enable.toUpperCase() == "TRUE");
				}
				else this.displayCompanions = config.enable;
			}
			if(config.html5 != undefined) {
				if(config.html5 is String) {
					this.nativeDisplay = !(config.html5.toUpperCase() == "TRUE");
				}
				else this.nativeDisplay = !config.html5;
			}
			if(config.nativeDisplay != undefined) {
				if(config.nativeDisplay is String) {
					this.nativeDisplay = (config.nativeDisplay.toUpperCase() == "TRUE");
				}
				else this.nativeDisplay = config.nativeDisplay;
			}
			if(config.restore != undefined) {
				if(config.restore is String) {
					this.restoreCompanions = (config.restore.toUpperCase() == "TRUE");
				}
				else this.restoreCompanions = config.restore;
			}
			if(config.additionalParamsForSWFCompanions != undefined) {
				if(config.additionalParamsForSWFCompanions is Array) {
					_additionalParamsForSWFCompanions = config.additionalParamsForSWFCompanions;
				}
			}
			if(config.millisecondDelayOnInjection != undefined) {
				if(config.millisecondDelayOnInjection is String) {
					this.millisecondDelayOnCompanionInjection = int(config.millisecondDelayOnInjection);
				}
				else this.millisecondDelayOnCompanionInjection = config.millisecondDelayOnInjection;					
			}
		}

		public function hasCompanionDivs():Boolean {
			return _companionDivIDs.length > 0;
		}
		
		public function set companionDivIDs(companionDivIDs:Array):void {
			// first validate that the companion widths and heights are specified as integers
			if(companionDivIDs != null) {
				for(var i:int=0; i < companionDivIDs.length; i++) {
					if(companionDivIDs[i].hasOwnProperty("width")) {
						if(companionDivIDs[i].width is String) {
							companionDivIDs[i].width = new Number(companionDivIDs[i].width);
						}
					}
					if(companionDivIDs[i].hasOwnProperty("height")) {
						if(companionDivIDs[i].height is String) {
							companionDivIDs[i].height = new Number(companionDivIDs[i].height);
						}						
					}
				}
			}
			_companionDivIDs = companionDivIDs;
		}
		
		public function get companionDivIDs():Array {
			return _companionDivIDs;
		}
		
		public function set displayCompanions(displayCompanions:Boolean):void {
			_displayCompanions = displayCompanions;
		}
		
		public function get displayCompanions():Boolean {
			if(_displayCompanions == false) {
				return _displayCompanions;
			}
			else return hasCompanionDivs();
		}

		public function set nativeDisplay(nativeDisplay:Boolean):void {
			_nativeDisplay = nativeDisplay;
		}
		
		public function get nativeDisplay():Boolean {
			return _nativeDisplay;
        }
  
		public function set restoreCompanions(restoreCompanions:Boolean):void {
			_restoreCompanions = restoreCompanions;
		}
		
		public function get restoreCompanions():Boolean {
			return _restoreCompanions;
		}

		public function set millisecondDelayOnCompanionInjection(millisecondDelayOnCompanionInjection:int):void {
			_millisecondDelayOnCompanionInjection = millisecondDelayOnCompanionInjection;
		}
		
		public function get millisecondDelayOnCompanionInjection():int {
			return _millisecondDelayOnCompanionInjection;
		}
		
		public function delayingCompanionInjection():Boolean {
			return (_millisecondDelayOnCompanionInjection > 0);
		}

		public function set additionalParamsForSWFCompanions(additionalParamsForSWFCompanions:Array):void {
			_additionalParamsForSWFCompanions = additionalParamsForSWFCompanions;	
		}
		
		public function get additionalParamsForSWFCompanions():Array {
			return _additionalParamsForSWFCompanions;
		}
	}
}
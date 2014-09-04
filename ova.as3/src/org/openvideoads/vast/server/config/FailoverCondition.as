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
	import org.openvideoads.base.Debuggable;
	

	/**
	 * @author Paul Schulz
	 */
	public class FailoverCondition extends Debuggable {
		
		protected var _always:Boolean = false;
		protected var _rules:Array = null;
		
		public function FailoverCondition(config:Object = null) {
			initialise(config);
		}
		
		public function initialise(config:Object = null):void {
			if(config != null) {
				if(config.always != undefined) {
					if(config.always is String) {
						this.always = ((config.always.toUpperCase() == "TRUE") ? true : false);											
					}
					else this.always = config.always;
				}
				if(config.rules != undefined) {
					if(config.rules is Array) {
						this.rules = config.rules;
					}
				}
			}
		}
		
		public function set always(always:Boolean):void {
			_always = always;
		}
		
		public function get always():Boolean {
			return _always;
		}
		
		public function hasRules():Boolean {
			if(_rules != null) {
				return (_rules.length > 0);
			}
			return false;
		}
		
		public function set rules(rules:Array):void {
			_rules = rules;
		}
		
		public function get rules():Array {
			return _rules;
		}
		
		public function shouldFailover(errorMessage:String):Boolean {
			if(_always) {
				if(hasRules()) {
					if(errorMessage != null) {
						for(var i:int = 0; i < _rules.length; i++) {
							if(errorMessage.indexOf(rules[i]) > -1) {
								return true;
							}
						}
					}
				}
				else {
					return true;
				}
			}
			return false;
		}
	}
}
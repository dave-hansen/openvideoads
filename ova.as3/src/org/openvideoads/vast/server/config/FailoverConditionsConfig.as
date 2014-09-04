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
	public class FailoverConditionsConfig extends Debuggable {

		protected var _onVPAIDError:FailoverCondition = null;
		protected var _onStreamError:FailoverCondition = null;
		
		public function FailoverConditionsConfig(config:Object = null) {
			initialise(config);
		}

		public function initialise(config:Object):void {
			if(config.onVPAIDError != undefined) {
				_onVPAIDError = new FailoverCondition(config.onVPAIDError);
			}
			if(config.onStreamError != undefined) {
				_onStreamError = new FailoverCondition(config.onStreamError);
			}
		}
		
		public function hasFailoverConditionOnVPAIDError():Boolean {
			return (_onVPAIDError != null);
		}
		
		public function set onVPAIDError(onVPAIDError:FailoverCondition):void {
			_onVPAIDError = onVPAIDError;
		}
		
		public function get onVPAIDError():FailoverCondition {
			return _onVPAIDError;
		}
		
		public function failoverOnVPAIDError():Boolean {
			if(_onVPAIDError != null) {
				return _onVPAIDError.always;
			}
			return false;
		}

		public function hasFailoverConditionOnStreamError():Boolean {
			return (_onStreamError != null);
		}

		public function set onStreamError(onStreamError:FailoverCondition):void {
			_onStreamError = onStreamError;
		}
		
		public function get onStreamError():FailoverCondition {
			return _onStreamError;
		}
		
		public function failoverOnStreamError():Boolean {
			if(_onStreamError != null) {
				return _onStreamError.always;
			}
			return false;
		}
		
		public function hasStreamErrorFailoverRules():Boolean {
			if(_onStreamError != null) {
				return _onStreamError.hasRules();
			}
			return false;
		}		
	}
}
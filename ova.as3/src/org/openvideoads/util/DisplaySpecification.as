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
	import org.openvideoads.base.Debuggable;

	/**
	 * @author Paul Schulz
	 */	
	public class DisplaySpecification extends Debuggable {
		protected var _mode:String = null;
		protected var _width:int = 0;
		protected var _height:int = 0;
		protected var _hideLogo:Boolean = false;
		protected var _scalable:Boolean = false;
		protected var _marginsSpecification:MarginsSpecification = new MarginsSpecification();
		protected var _controls:Object = {
			stream: new ControlsSpecification(),
			vpaid: new ControlsSpecification({ visible: false, enabled: false })
		};
		
		public static const LINEAR:String = "linear";
		public static const NON_LINEAR:String = "nonLinear";

		public function DisplaySpecification(config:*) {
			if(config is String) {
				_mode = config;
			}
			else initialise(config);
		}
		
		public function initialise(config:Object):void {
			if(config.hasOwnProperty("width")) {
				if(config.width is String) {
					width = parseInt(config.width);
				}	
				else width = config.width;
			}
			
			if(config.hasOwnProperty("width")) {
				if(config.height is String) {
					height = parseInt(config.height);
				}	
				else height = config.height;				
			}

			if(config.hasOwnProperty("hideLogo")) {
				if(config.height is String) {
					hideLogo = StringUtils.matchesIgnoreCase(config.hideLogo, "TRUE");
				}	
				else hideLogo = config.hideLogo;				
			}

			if(config.hasOwnProperty("scalable")) {
				scalable = StringUtils.validateAsBoolean(config.scalable);
			}
			
			if(config.hasOwnProperty("controls")) {
				controls = config.controls;
			}
			
			if(config.hasOwnProperty("margins")) {
				margins = config.margins;
			}
		}
		
		public function set width(width:int):void {
			_width = width;
		}
		
		public function get width():int {
			return _width;
		}
		
		public function set height(height:int):void {
			_height = height;
		}
		
		public function get height():int {
			return _height;
		}

		public function set scalable(scalable:Boolean):void {
			_scalable = scalable;
		}
		
		public function get scalable():Boolean {
			return _scalable;
		}
		
		public function set hideLogo(hideLogo:Boolean):void {
			_hideLogo = hideLogo;
		}
		
		public function get hideLogo():Boolean {
			return _hideLogo;
		}
		
		public function set controls(config:Object):void {
			if(config != null) {
				_controls.stream.initialise(config);
				_controls.vpaid.initialise(config);
				if(config.hasOwnProperty("stream")) {
					_controls.stream.initialise(config.stream);
				}				
				if(config.hasOwnProperty("vpaid")) {
					_controls.vpaid.initialise(config.vpaid);
				}				
			}
		}
		
		public function get controls():Object {
			return _controls;
		}
		
		public function set streamControlsSpecification(controlsSpecification:ControlsSpecification):void {
			_controls.stream = controlsSpecification;
		}
		
		public function get streamControlsSpecification():ControlsSpecification {
			return _controls.stream;
		}

		public function set vpaidControlsSpecification(controlsSpecification:ControlsSpecification):void {
			_controls.vpaid = controlsSpecification;
		}
		
		public function get vpaidControlsSpecification():ControlsSpecification {
			return _controls.vpaid;
		}

        public function shouldDisableControlsDuringLinearAds(isVPAID:Boolean=false):Boolean {
        	if(isVPAID) {
    			return (_controls.vpaid.enabled == false);    		
        	}
        	else return (_controls.stream.enabled == false);    		        		
        }

		public function shouldManageControlsDuringLinearAds(isVPAID:Boolean=false):Boolean {
        	if(isVPAID) {
    			return _controls.vpaid.manage;    		
        	}
        	else return _controls.stream.manage;    		        		
		}        

		public function controlEnabledForLinearAdType(controlName:String, isVPAID:Boolean):Boolean {
			if(shouldManageControlsDuringLinearAds(isVPAID) == false) {
				return true;
			}
			else {
				if(isVPAID) {
					return _controls.vpaid.controlEnabled(controlName);
				}
				else return _controls.stream.controlEnabled(controlName);
			}
		}
		
		public function hideControlsOnLinearPlayback(isVPAID:Boolean=false):Boolean {
			if(shouldManageControlsDuringLinearAds(isVPAID)) {
				if(isVPAID) {
					return (_controls.vpaid.visible == false);
				}
				else return (_controls.stream.visible == false);
			}
			return false;
		}
		
		public function hideDockOnLinearPlayback(isVPAID:Boolean=false):Boolean {
			if(shouldManageControlsDuringLinearAds(isVPAID)) {
				if(isVPAID) {
					return (_controls.vpaid.visible == false);
				}
				else return (_controls.stream.visible == false);
			}
			return false;
		}
		
		public function set margins(config:Object):void {
			if(_marginsSpecification == null) {
				_marginsSpecification = new MarginsSpecification(config);
			}
			else _marginsSpecification.initialise(config);
		}
		
		public function set marginsSpecification(marginsSpecification:MarginsSpecification):void {
			_marginsSpecification = marginsSpecification;
		}
		
		public function get marginsSpecification():MarginsSpecification {
			return _marginsSpecification;
		}
		
		public function toString():String {
			return "{ mode: " + _mode +
			         ", width: " + width + 
			         ", height: " + height +
			       " }";
		}
	}
}
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
	public class MarginsSpecification extends Debuggable {

		protected var _normal:Object = {
			withControls: 0,
			withControlsOverride: -1,
			withoutControls: 0,
			withoutControlsOverride: -1
		};
		protected var _fullscreen:Object = {
			withControls: 0,
			withControlsOverride: -1,
			withoutControls: 0,
			withoutControlsOverride: -1
		};
		
		public function MarginsSpecification(config:Object=null) {
			super();
			initialise(config);
		}
		
		public function initialise(config:Object):void {
			if(config != null) {
				setControlMargins(_normal, config);
				setControlMargins(_fullscreen, config);
				if(config.hasOwnProperty("normal")) {
					normalControlMargins = config.normal;
				}
				if(config.hasOwnProperty("fullscreen")) {
					fullscreenControlMargins = config.fullscreen;
				}
			}
		}
		
		public function set normalControlMargins(config:Object):void {
			setControlMargins(_normal, config);
		}

		public function get normalControlMargins():Object {
			return _normal;	
		}

		public function set fullscreenControlMargins(config:Object):void {
			setControlMargins(_fullscreen, config);
		}

		public function get fullscreenControlMargins():Object {
			return _fullscreen;	
		}
		
		public function getWithControlsMargin(mode:String, useOverrideMargin:Boolean=false):Number {
			if(StringUtils.matchesIgnoreCase(mode, "NORMAL")) {
				if(useOverrideMargin) {
					if(_normal.hasOwnProperty("withControlsOverride")) {
						if(_normal.withControlsOverride > -1) {
							return _normal.withControlsOverride;
						}
					}					
				}
				if(_normal.hasOwnProperty("withControls")) {
					return _normal.withControls;
				}
			}
			else {
				if(useOverrideMargin) {
					if(_fullscreen.hasOwnProperty("withControlsOverride")) {
						if(_fullscreen.withControlsOverride > -1) {
							return _fullscreen.withControlsOverride;						
						}
					}
				}
				if(_fullscreen.hasOwnProperty("withControls")) {
					return _fullscreen.withControls;
				}
			}
			return 0;
		}

		public function getWithoutControlsMargin(mode:String, useOverrideMargin:Boolean=false):Number {
			if(StringUtils.matchesIgnoreCase(mode, "NORMAL")) {
				if(useOverrideMargin) {
					if(_normal.hasOwnProperty("withoutControlsOverride")) {
						if(_normal.withoutControlsOverride > -1) {
							return _normal.withoutControlsOverride;						
						}
					}					
				}
				if(_normal.hasOwnProperty("withoutControls")) {
					return _normal.withoutControls;
				}
			}
			else {
				if(useOverrideMargin) {
					if(_fullscreen.hasOwnProperty("withoutControlsOverride")) {
						if(_fullscreen.withoutControlsOverride > -1) {
							return _fullscreen.withoutControlsOverride;						
						}
					}
				}
				if(_fullscreen.hasOwnProperty("withoutControls")) {
					return _fullscreen.withoutControls;
				}
			}
			return 0;
		}

		public function getNormalMarginWithControls():Number{
			return getWithControlsMargin("normal");
		}

		public function getNormalMarginWithoutControls():Number{
			return getWithoutControlsMargin("normal");
		}

		public function getFullscreenMarginWithControls():Number{
			return getWithControlsMargin("fullscreen");
		}

		public function getFullscreenMarginWithoutControls():Number{
			return getWithoutControlsMargin("fullscreen");
		}
		
		protected function setControlMargins(elementConfig:Object, config:Object):void {
			if(config.hasOwnProperty("withControls")) {
				elementConfig.withControls = config.withControls;
			}	
			if(config.hasOwnProperty("withControlsOverride")) {
				elementConfig.withControlsOverride = config.withControlsOverride;
			}	
			if(config.hasOwnProperty("withoutControls")) {
				elementConfig.withoutControls = config.withoutControls;					
			}			
			if(config.hasOwnProperty("withoutControlsOverride")) {
				elementConfig.withoutControlsOverride = config.withoutControlsOverride;
			}	
		}
	}
}
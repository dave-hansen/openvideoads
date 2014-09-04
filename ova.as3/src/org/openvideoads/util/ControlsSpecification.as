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
	
	public class ControlsSpecification extends Debuggable {	
		protected var _manage:Boolean = true;	
		protected var _visible:Boolean = true;
		protected var _enabled:Boolean = false;
		protected var _enablePlay:Boolean = true;
		protected var _enablePause:Boolean = true;
		protected var _enableStop:Boolean = true;
		protected var _enablePlaylist:Boolean = false;
		protected var _enableTime:Boolean = false;
		protected var _enableVolume:Boolean = true;
		protected var _enableMute:Boolean = true;
		protected var _enableFullscreen:Boolean = true;
		protected var _height:int = -999;
		protected var _hideDock:Boolean = false; 
		protected var _anchorNonLinearToBottom:Boolean = false;

		public static const PLAY:String = "PLAY";
		public static const PAUSE:String = "PAUSE";
		public static const STOP:String = "STOP";
		public static const PLAYLIST:String = "PLAYLIST";
		public static const TIME:String = "TIME";
		public static const VOLUME:String = "VOLUME";
		public static const MUTE:String = "MUTE";
		public static const FULLSCREEN:String = "FULLSCREEN";
		
		public function ControlsSpecification(config:Object=null) {
			if(config != null) {
				initialise(config);
			}
		}

		public function initialise(config:Object):void {
			if(config != null) {
				if(config.hasOwnProperty("manage")) {
					_manage = StringUtils.validateAsBoolean(config.manage);
				}
				if(config.hasOwnProperty("visible")) {
					_visible = StringUtils.validateAsBoolean(config.visible);
				}
				if(config.hasOwnProperty("enable")) {
					enabled = StringUtils.validateAsBoolean(config.enable);
				}
				if(enabled == false) {
					if(config.hasOwnProperty("enablePlay")) {
						_enablePlay = StringUtils.validateAsBoolean(config.enablePlay);
					}
					if(config.hasOwnProperty("enablePause")) {
						_enablePause = StringUtils.validateAsBoolean(config.enablePause);
					}
					if(config.hasOwnProperty("enableStop")) {
						_enableStop = StringUtils.validateAsBoolean(config.enableStop);
					}
					if(config.hasOwnProperty("enablePlaylist")) {
						_enablePlaylist = StringUtils.validateAsBoolean(config.enablePlaylist);
					}
					if(config.hasOwnProperty("enableTime")) {
						_enableTime = StringUtils.validateAsBoolean(config.enableTime);
					}
					if(config.hasOwnProperty("enableVolume")) {
						_enableVolume = StringUtils.validateAsBoolean(config.enableVolume);
					}
					if(config.hasOwnProperty("enableMute")) {
						_enableMute = StringUtils.validateAsBoolean(config.enableMute);
					}
					if(config.hasOwnProperty("enableFullscreen")) {
						_enableFullscreen = StringUtils.validateAsBoolean(config.enableFullscreen);
					}
					if(config.hasOwnProperty("anchorNonLinearToBottom")) {
						_anchorNonLinearToBottom = StringUtils.validateAsBoolean(config.anchorNonLinearToBottom);
					}
				}
				if(config.hasOwnProperty("hideDock")) {
					this.hideDock = StringUtils.validateAsBoolean(config.hideDock);
				}
				if(config.hasOwnProperty("height")) {
					this.height = config.height;
				}
			}			
		}

        public function shouldShowControlsDuringLinearAds():Boolean {
        	return _visible;
        }

		public function controlEnabled(controlName:String):Boolean {
			if(controlName != null) {
				controlName = controlName.toUpperCase();
				if(controlName == ControlsSpecification.PLAY) {
					return enablePlay;
				}
				else if(controlName == ControlsSpecification.PAUSE) {
					return enablePause;					
				}
				else if(controlName == ControlsSpecification.PLAYLIST) {
					return enablePlaylist;	
				}
				else if(controlName == ControlsSpecification.TIME) {
					return enableTime;
				}
				else if(controlName == ControlsSpecification.VOLUME) {
					return enableVolume;
				}
				else if(controlName == ControlsSpecification.MUTE) {
					return enableMute;
				}
				else if(controlName == ControlsSpecification.STOP) {
					return enableStop;
				}
				else if(controlName == ControlsSpecification.FULLSCREEN) {
					return enableFullscreen;
				}
			}	
			return false;
		}

		public function set manage(manage:Boolean):void {
			_manage = manage;	
		}
		
		public function get manage():Boolean {
			if(_enabled == true) return false;
			return _manage;
		}
		
		public function set hideDock(hideDock:Boolean):void {
			_hideDock = hideDock;
		}
		
		public function get hideDock():Boolean {
			return _hideDock;
		}
		
		public function set visible(visible:Boolean):void {
			_visible = visible;	
		}
		
		public function get visible():Boolean {
			return _visible;
		}

		public function set anchorNonLinearToBottom(anchorNonLinearToBottom:Boolean):void {
			_anchorNonLinearToBottom = anchorNonLinearToBottom;	
		}
		
		public function get anchorNonLinearToBottom():Boolean {
			return _anchorNonLinearToBottom;
		}
		
		public function set enabled(enabled:Boolean):void {
			_enabled = enabled;
			enablePlay = enabled;
			enablePause = enabled;
			enablePlaylist = enabled;
			enableTime = enabled;
			enableVolume = enabled;
			enableStop = enabled;
			enableFullscreen = enabled;
			enableMute = enabled;
		}
		
		public function get enabled():Boolean {
			return _enabled;
		}
		
		public function set enablePlay(enablePlay:Boolean):void {
			_enablePlay = enablePlay;
		}
		
		public function get enablePlay():Boolean {
			return _enablePlay;
		}

		public function set enablePause(enablePause:Boolean):void {
			_enablePause = enablePause;
		}
		
		public function get enablePause():Boolean {
			return _enablePause;
		}

		public function set enableStop(enableStop:Boolean):void {
			_enableStop = enableStop;
		}
		
		public function get enableStop():Boolean {
			return _enableStop;
		}

		public function set enablePlaylist(enablePlaylist:Boolean):void {
			_enablePlaylist = enablePlaylist;
		}
		
		public function get enablePlaylist():Boolean {
			return _enablePlaylist;
		}

		public function set enableTime(enableTime:Boolean):void {
			_enableTime = enableTime;
		}
		
		public function get enableTime():Boolean {
			return _enableTime;
		}

		public function set enableVolume(enableVolume:Boolean):void {
			_enableVolume = enableVolume;
		}
		
		public function get enableVolume():Boolean {
			return _enableVolume;
		}

		public function set enableMute(enableMute:Boolean):void {
			_enableMute = enableMute;
		}
		
		public function get enableMute():Boolean {
			return _enableMute;
		}

		public function set enableFullscreen(enableFullscreen:Boolean):void {
			_enableFullscreen = enableFullscreen;
		}
		
		public function get enableFullscreen():Boolean {
			return _enableFullscreen;
		}		

		public function set height(height:int):void {
			_height = height;
		}	
		
		public function get height():int {
			return _height;
		}
		
		public function hasHeightSpecified():Boolean {
			return (_height != -999);
		}
	}
}
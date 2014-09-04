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
 *
 */
package org.openvideoads.util {
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import org.openvideoads.base.Debuggable;
	
	public class PopupWindow {
		private static function getUA():String {
			if(ExternalInterface.available) {
				try {
					var agent:String = ExternalInterface.call("function getBrowser(){return navigator.userAgent;}");

					if(agent != null && agent.indexOf("Firefox") >= 0) {
						return "FIREFOX";
					}
					else if(agent != null && agent.indexOf("Safari") >= 0) {
						return "SAFARI";
					}
					else if(agent != null && agent.indexOf("MSIE") >= 0) { 
						return "IE";
					}
					else if(agent != null && agent.indexOf("Opera") >= 0) {
						return "OPERA";
					}
				}
				catch(e:Error) { }
			}
			return "UNDEFINED";
		}

		public static function openWindow(url:String, target:String = '_blank', features:String=""):void {
			var userAgent:String = PopupWindow.getUA();
			switch (userAgent) {
				case "IE":
					CONFIG::debugging { Debuggable.getInstance().doLog("User agent is identified as IE - processing click through via JS window.open()", Debuggable.DEBUG_CLICKTHROUGH_EVENTS);	}				
					ExternalInterface.call("function setWMWindow() {window.open('" + url + "', '"+target+"', '"+features+"');}");
					break;
				case "FIREFOX":
				case "SAFARI":
				case "OPERA":
				default:
					CONFIG::debugging { Debuggable.getInstance().doLog("User agent is identified as " + userAgent + " - processing click through via AS3 navigateToURL()", Debuggable.DEBUG_CLICKTHROUGH_EVENTS);	}				
					navigateToURL(new URLRequest(url), target);
					break;
			}
		}
	}
}
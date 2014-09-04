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

	public class BrowserUtils {
		public function BrowserUtils() {
		}
		
		protected static function clean(data:String, forceEncoding:Boolean=false):String {
			var result:String = StringUtils.trim(data); // remove any extra spaces
			if(forceEncoding) {
				return encodeURIComponent(result);
//				return escape(result);
			}
			else if(result.indexOf("&") > -1 || result.indexOf("?") > -1) {
				return encodeURIComponent(result);
//				return escape(result);
			}
			else return result;
		}

		public static function getPageUrl(makeSafe:Boolean=true, forceEncoding:Boolean=false):String {
			try {
				if(makeSafe || forceEncoding) {
					return clean(ExternalInterface.call("function(){ return document.location.href.toString();}"), forceEncoding);			
				}
				else return ExternalInterface.call("function(){ return document.location.href.toString();}");
			}
			catch(e:Error) {
			}
			return null;
		}

		public static function getReferrer(makeSafe:Boolean=true, forceEncoding:Boolean=false):String {
			try {
				if(makeSafe || forceEncoding) {
					return clean(ExternalInterface.call("function(){ return document.referrer; }"), forceEncoding);	
				}
				else return ExternalInterface.call("function(){ return document.referrer; }");				
			}
			catch(e:Error) {
			}
			return null;
		}

		public static function getDomain(makeSafe:Boolean=true, forceEncoding:Boolean=false):String {
			try {
				if(makeSafe || forceEncoding) {
					return clean(NetworkResource.getDomain(getPageUrl(false, false)), forceEncoding);
				}
				else return NetworkResource.getDomain(getPageUrl(false, false));
			}
			catch(e:Error) {
			}
			return null;
		}
		
		public static function getBrowserDetails():Object {
            try {
	            var browser:Object = {
	            	userAgentString: null,
	            	IE: false,
	            	Safari: false,
	            	Firefox: false,
	            	Chrome: false,
	            	Opera: false,
	            	version: null
	            };
	            
 				browser.userAgent = ExternalInterface.call("window.navigator.userAgent.toString");
 				
                if (browser.userAgent.indexOf("Safari") != -1) {
                    browser.Safari = true;
                }
                else if (browser.userAgent.indexOf("Firefox") != -1) {
                    browser.Firefox = true;
                }
                else if (browser.userAgent.indexOf("Chrome") != -1) {
                    browser.Chrome = true;
                }
                else if (browser.userAgent.indexOf("MSIE") != -1) {
                    browser.IE = true;
                    browser.version = parseInt(
                    	browser.userAgent.substr(
                    		browser.userAgent.indexOf("MSIE") + 5, 
                    		browser.userAgent.indexOf(".", browser.userAgent.indexOf("MSIE"))
                    	)
                    );
                    /*
                    var majorVersion = agent.replace(msiePattern,"$2");
					var fullVersion = agent.replace(msiePattern,"$1");
  					var majorVersionInt = parseInt( majorVersion );
  					var fullVersionFloat = parseFloat( fullVersion );                
  					*/
                }
                else if (browser.userAgent.indexOf("Opera") != -1) {
                    browser.Opera = true;
                }
            }
            catch (e:Error) {
            }
            return browser;
        }	
        
        public static function isIE6():Boolean {
        	var browser:Object = BrowserUtils.getBrowserDetails();
        	if(browser.IE === true) {
        		return (browser.version == 6);
        	}
        	return false;
        }	
	}
}
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
	public class Timestamp extends Debuggable {
		public function Timestamp() {
		}

		static public function validate(candidate:String):Boolean {
			if(candidate == null) {
				return false;	
			}
			var parts:Array = candidate.split(":");
			return(parts.length == 3);	
		}
		
		static public function secondsStringToTimestamp(duration:String):String {
			if(duration == null) {
				return "00:00:00";
			}
			return secondsToTimestamp(int(duration));
		}
		
		static public function pad(base:int):String {
			if(base < 10) {
				return "0" + base;
			}
			else return "" + base;
		}

        static public function addSecondsToTimestamp(timestamp:String, seconds:Number):String {
        	if(seconds > 0) {
	        	var startTimeInSeconds:int = timestampToSeconds(timestamp);
    	    	return secondsToTimestamp(startTimeInSeconds + seconds);		
        	}
        	return timestamp;
        }
        
		static public function secondsToTimestamp(seconds:Number):String {
			if(seconds > 0) {
			    var s:Number = seconds % 60;
			    var m:Number = Math.floor((seconds % 3600 ) / 60);
			    var h:Number = Math.floor(seconds / (60 * 60));
			 
			    var hourStr:String = ((h == 0) ? "00" : doubleDigitFormat(h)) + ":";
			    var minuteStr:String = doubleDigitFormat(m) + ":";
			    var secondsStr:String = doubleDigitFormat(s);
			 
			    return hourStr + minuteStr + secondsStr;				
			}
			return "00:00:00";
		}
 
		static private function doubleDigitFormat(num:uint):String {
		    if (num < 10) {
		        return ("0" + num);
		    }
		    return String(num);
		}

		static private function tripleDigitFormat(num:uint):String {
		    if (num < 100) {
		        return ("0" + doubleDigitFormat(num));
		    }
		    return String(num);
		}

		static public function timestampToSeconds(timestamp:String):int {
			if(timestamp != null) {
				var parts:Array = timestamp.split(":");
				if(parts.length == 3) {
					var dotIndex:int = parts[2].indexOf(".");
					if(dotIndex > -1) {
						return (parseInt(parts[0]) * 3600) + (parseInt(parts[1]) * 60) + parseInt(parts[2].substr(0, dotIndex));						
					}
					else {
						return (parseInt(parts[0]) * 3600) + (parseInt(parts[1]) * 60) + parseInt(parts[2]);					
					}
				}
				return parseInt(timestamp);				
			}
			return 0;
		}
		
		static public function timestampToMilliseconds(timestamp:String):Number {
			var dotIndex:int = timestamp.indexOf("."); 
			if(dotIndex > -1 && dotIndex < timestamp.length) {
				// it's a timestamp format like hh:mm:ss.mmm
				var millsecondPart:Number = new Number(timestamp.substr(dotIndex + 1));
				return timestampToSeconds(timestamp.substr(0, dotIndex)) + millsecondPart;
			}
			else {
				// it's a timestamp format like hh:mm:ss
				return timestampToSeconds(timestamp) * 1000;
			}			
		}
		
		static public function millisecondsToTimestamp(milliseconds:Number):String {
			if(milliseconds > 0) {
				
				var seconds:Number = Math.floor(milliseconds / 1000);
				var spareMilliseconds:Number = milliseconds % 1000;
				
				if(seconds > 0) {
				    var s:Number = seconds % 60;
				    var m:Number = Math.floor((seconds % 3600 ) / 60);
				    var h:Number = Math.floor(seconds / (60 * 60));
				    				 
				    var hourStr:String = ((h == 0) ? "00" : doubleDigitFormat(h)) + ":";
				    var minuteStr:String = doubleDigitFormat(m) + ":";
				    var secondsStr:String = doubleDigitFormat(s);
				 
				    return hourStr + minuteStr + secondsStr + "." + tripleDigitFormat(spareMilliseconds);				
				}
			}
			return "00:00:00.000";
		}
		
		static public function timestampToSecondsString(timestamp:String):String {
			return new String(Timestamp.timestampToSeconds(timestamp));
		}
	}
}
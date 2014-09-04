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
	public class StringUtils {
		public function StringUtils() {
		}

		public static function limitLength(s1:String, length:Number):String {
			if(s1 != null) {
				return s1.substr(0, length);
			}
			return s1;
		}
		
		public static function convertStringToNumber(s1:String, baseValue:int):Number {
			if(s1 != null) {
				var parts:Array = s1.split(".");
				var result:int = 0;
				var factor:Number = 0;
				for(var i:int=parts.length-1; i >=0; i--) {
					if(factor == 0) {
						result = parts[i];
						factor = baseValue;
					}
					else {
						result += (parts[i] * factor);
					}
					factor = factor * 10;					
				}			
				return result;
			}
			return 0;
		}
		
		public static function validateAsBoolean(value:*):Boolean {
			if(value != null && value != undefined) {
				if(value is String || ((typeof value) == "xml")) {
					return (value.toUpperCase() == "TRUE");
				}
				else if(value is Boolean) {
					return value;
				}
			}
			return false;
		}
		
		public static function validateAsNumber(value:*):Number {
			if(value is Number) {
				return value;
			}
			else if(value is String) {
				return Number(value);
			}
			return -1;
		}
		
		public static function containsIgnoreCase(s1:*, s2:String):Boolean {
			if(s1 is Array) {
				for each(var field:Object in s1) {
					if(field is String) {
						if(matchesIgnoreCase(field as String, s2)) {
							return true;
						}						
					}
				}
			}	
			else if(s1 is String) {
				if(StringUtils.isEmpty(s1) || StringUtils.isEmpty(s2)) {
					return false;
				}
				var a:String = s1.toUpperCase();
				var b:String = s2.toUpperCase();
				return (a.indexOf(b) > -1);
			}		
			return false;
		}
		
		public static function matchesIgnoreCase(s1:String, s2:String):Boolean {
			if(s1 == null && s2 == null) return true;
			if((s1 == null && s2 != null) || (s1 != null && s2 == null)) return false;
			return (s1.toUpperCase() == s2.toUpperCase());
		}
		
		public static function trim(s:String):String { 
			return s ? s.replace(/^\s+|\s+$/gs, '') : "";
		}
		
		public static function isEmpty(data:String):Boolean {
			if(data == null) return true;
			return (StringUtils.trim(data).length == 0);
		}
		
        public static function removeControlChars(string:String):String {
        	if(string != null) {
	            var result:String = string;
	            var resultArray:Array;
	            // convert tabs to spaces
	            result = result.split("\t").join(" ");
	            // convert returns to spaces
	            result = result.split("\r").join(" ");
	            // convert newlines to spaces
	            result = result.split("\n").join(" ");
	            return result;        		
        	}
        	return string;
        }

        public static function compressWhitespace(string:String):String {
            var result:String = string;
            var resultArray:Array;
            resultArray = result.split(" ");
            for(var idx:uint = 0; idx < resultArray.length; idx++) {
                if(resultArray[idx] == "") {
                   resultArray.splice(idx,1);
                   idx--;
                }
            }
            result = resultArray.join(" ");
            return result;
        }
        
        public static function convertStringToObject(data:String, propertySeparator:String, valueSeparator:String):Object {
        	var result:Object = new Object();
        	var properties:Array = data.split(propertySeparator);
        	if(properties.length > 0) {
        		for(var i:int=0; i < properties.length; i++) {
        			var values:Array = properties[i].split(valueSeparator);
        			if(values.length == 2) {
        				result[values[0]] = values[1];
        			}
        		}
        	}
        	return result;
        }
        
        public static function concatEnsuringSeparator(A:String, B:String, separator:String):String {
        	if(StringUtils.endsWith(A, separator) || StringUtils.beginsWith(B, separator)) {
        		return A + B;
        	}
        	else return A + separator + B;
        }
        
		public static function beginsWith(p_string:String, p_begin:String):Boolean {
			if (p_string == null || p_begin == null) { return false; }
			return StringUtils.trim(p_string).toUpperCase().indexOf(p_begin.toUpperCase()) == 0;
		}        
        
        public static function endsWith(p_string:String, p_end:String):Boolean {
        	if (p_string == null) { return false; }
			return p_string.lastIndexOf(p_end) == p_string.length - p_end.length;
		}
		
        public static function revertSingleQuotes(string:String, replacement:String):String {
			var quotePattern:RegExp = /{quote}/g;  
 			return string.replace(quotePattern, replacement);         	
        }

		public static function removeNewlines(data:String):String {
			return data.replace(/\n/g, '');			
		}
		
        public static function doubleEscapeSingleQuotes(data:String):String {
			return data.replace(/(['\\])/g, "\\$1");
        }
        
        public static function matchesAndHasValue(string1:String, string2:String):Boolean {
        	if(string1 != null) {
        		if(string2 != null) {
        			if(!StringUtils.isEmpty(string1) && !StringUtils.isEmpty(string2)) {
        				return (string1 == string2);
        			}	
        		}
        	}
        	return false;
        }
        
        public static function difference(string1:String, string2:String):String {
        	for(var i:int=0; i < string1.length; i++) {
				if(i < string2.length) {
	        		if(string1.charAt(i) != string2.charAt(i)) {
	        			return "difference: " + i + ", (" + string1.charCodeAt(i) + ") != (" + string2.charCodeAt(i) + ")";	
	        		}					
				}
				else return "difference: string1 longer";
        	}
        	if(string1.length < string2.length) {
        		return "difference: string2 is longer";
        	}
        	return "difference: identical";        	
        }
        
        public static function replaceSingleWithDoubleQuotes(data:String):String {
			var pattern:RegExp = /'/g;
			return data.replace(pattern, '"');
        }

        public static function escapeSingleQuotes(data:String):String {
			return data.replace(/(['\\])/g, "\\$1");
        }

        public static function escapeDoubleQuotes(data:String):String {
			var result:String = new String();
        	for(var i:int=0; i < data.length; i++) {
        		if(data.charAt(i) == '"') {
        			result += '\"';	
        		}
        		else result += data.charAt(i);
        	}
        	return result;
        }
    }
}

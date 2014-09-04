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
	import org.openvideoads.util.StringUtils;
	
	/**
	 * @author Paul Schulz
	 */
	public class AdStreamerConfig extends Debuggable {
		protected var _netConnectionAddress:String = null;
		protected var _removeFilenameExtensions:Array = null;
		protected var _addFilenamePrefixes:Array = null;
		
		public function AdStreamerConfig(config:Object) {
			super();
			if(config != null) initialise(config);
		}
		
		public function initialise(config:Object):void {
			if(config.netConnectionAddress != undefined) _netConnectionAddress = StringUtils.trim(config.netConnectionAddress);
			if(config.removeFilenameExtensions != undefined) {
				if(config.removeFilenameExtensions is Array) {
					_removeFilenameExtensions = config.removeFilenameExtensions;
				}
				else _removeFilenameExtensions = ArrayUtils.makeArray(config.removeFilenameExtensions);	
			}
			if(config.addFilenamePrefixes != undefined) {
				if(config.addFilenamePrefixes is Array) {
					_addFilenamePrefixes = config.addFilenamePrefixes;
				}
				else _addFilenamePrefixes = ArrayUtils.makeArray(config.addFilenamePrefixes);	
			}
		}
		
		public function set netConnectionAddress(netConnectionAddress:String):void {
			_netConnectionAddress = netConnectionAddress;
		}
		
		public function get netConnectionAddress():String {
			return _netConnectionAddress;
		}
		
		public function set removeFilenameExtensions(removeFilenameExtensions:Array):void {
			_removeFilenameExtensions = removeFilenameExtensions;
		}
		
		public function get removeFilenameExtensions():Array {
			return _removeFilenameExtensions;
		}
		
		public function set addFilenamePrefixes(addFilenamePrefixes:Array):void {
			_addFilenamePrefixes = addFilenamePrefixes;
		}
		
		public function get addFilenamePrefixes():Array {
			return _addFilenamePrefixes;
		}
		
		public function formDecoratedRTMPFilename(url:String, mimeType:String="video/x-mp4"):String {
			if(_netConnectionAddress != null) {
				var result:String = url;
				if(url.indexOf(_netConnectionAddress) > -1) {
					// strip out the net connection part of the URL
					result = url.substr(_netConnectionAddress.length);
				}
				else if(url.indexOf("rtmp://") > -1) {
					// ok, so assume the domain and the first directory in the URL constitute 
					// the netConnectionURL so strip that out and treat the rest as the filename
				}
				else result = url;

				if(result.charAt(0) == "/") {
					// strip off the leading / if it exists
					result = result.substr(1);
				}
				
				if(_removeFilenameExtensions != null || _addFilenamePrefixes != null) {
					var fileType:String = null;
					if(mimeType != null) {
						// strip out the leading 'video/x-' part of the mimeType if it has been provided
						// since the config options don't use that format - just "mp4" etc.
						fileType = StringUtils.trim(mimeType);
						if(fileType.indexOf("video/x-") == 0) {
							fileType = fileType.substr(8);
						}
						else if(fileType.indexOf("video/") == 0) {
							fileType = fileType.substr(6);
						}
					}
					else {
						// see if the URL has an extension that gives the mimeType away
						if(url.indexOf(".mp4") > -1) {
							fileType = "mp4";
						}
						else if(url.indexOf(".flv") > -1) {
							fileType = "flv";
						}
					}
					if(fileType != null) {
						if(_removeFilenameExtensions != null) {
							// now check if the file extension needs to be removed - if so, remove it
							for(var i:int=0; i < _removeFilenameExtensions.length; i++) {
								if(_removeFilenameExtensions[i] is String) {
									if(StringUtils.matchesIgnoreCase(_removeFilenameExtensions[i], fileType)) {
										var startIndexOfExtension:int = result.indexOf("." + _removeFilenameExtensions[i]);
										if(startIndexOfExtension == -1) {
											startIndexOfExtension = result.indexOf("." + _removeFilenameExtensions[i].toUpperCase());
										}
										if(startIndexOfExtension > -1) {
											result = result.substr(0, startIndexOfExtension);
											i = _removeFilenameExtensions.length;
										}
									}									
								}
							}
						}
						
						if(_addFilenamePrefixes != null) {
							// finally, check if the file requires a prefix added (eg. mp4:) - if so add it						
							for(var j:int=0; j < _addFilenamePrefixes.length; j++) {
								if(_addFilenamePrefixes[j] is String) {
									if(StringUtils.matchesIgnoreCase(_addFilenamePrefixes[j], fileType)) {
										if(result.toUpperCase().indexOf(_addFilenamePrefixes[j].toUpperCase() + ":") == -1) {
											result = _addFilenamePrefixes[j] + ":" + result;
											j = _addFilenamePrefixes.length;
										}
									}									
								}
							}
						}						
					}
				}
			}
			return result;
		}
	}
}
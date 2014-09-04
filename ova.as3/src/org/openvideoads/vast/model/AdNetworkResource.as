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
package org.openvideoads.vast.model {
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.util.NetworkResource;
	import org.openvideoads.vast.config.groupings.AdStreamerConfig;
	
	/**
	 * @author Paul Schulz
	 */
	public class AdNetworkResource extends NetworkResource {
		protected var _streamers:Array = null;
		protected var _matchingStreamerDeclaration:AdStreamerConfig = null;
		protected var _parsedFilename:String = null;
		protected var _parsedNetConnectionAddress:String = null;
		
		public function AdNetworkResource(id:String = null, url:String = null, mimeType:String=null) {
			super(id, url, mimeType);
		}
		
		public function hasStreamerDefinitions():Boolean {
			return (_streamers != null);
		}
		
		protected function hasMatchingStreamerDeclaration():Boolean {
			if(_url != null) {
				if(_matchingStreamerDeclaration == null) {
					if(_streamers != null) {
						for(var i:int = 0; i < _streamers.length; i++) {
							if(_url.indexOf(AdStreamerConfig(_streamers[i]).netConnectionAddress) > -1) {
								CONFIG::debugging { doLog("A matching streamer declaration found - netConnectionAddress is " + AdStreamerConfig(_streamers[i]).netConnectionAddress, Debuggable.DEBUG_CONFIG); }
								_matchingStreamerDeclaration = AdStreamerConfig(_streamers[i]);
								return true;
							}
						}
					}
				}						
			}
			else _matchingStreamerDeclaration = null;
			
			return false;
		}
		
		public function set streamers(streamers:Array):void {
			_streamers = streamers;
			_matchingStreamerDeclaration = null;
		}
		
		public override function get netConnectionAddress():String {
			if(_parsedNetConnectionAddress != null) {
				return _parsedNetConnectionAddress;
			}
			else if(hasMatchingStreamerDeclaration()) {
				return _matchingStreamerDeclaration.netConnectionAddress;
			}
			else {
				var markedAddress:String = super.netConnectionAddress;
				if(markedAddress != null) {
					return markedAddress;
				}
				else return deriveDefaultNetConnectionAddress();
			} 
		}

		protected function deriveDefaultNetConnectionAddress():String {
			if(isRTMP()) {
				var urlMinusPrefix:String = _url.substr(_url.indexOf("rtmp://") + 7);
				var parts:Array = urlMinusPrefix.split("/");
				if(parts.length > 2) {
					_parsedNetConnectionAddress = "rtmp://" + parts[0] + "/" + parts[1];
					CONFIG::debugging { doLog("RTMP NetConnectionAddress has been determined by default rule - address is " + _parsedNetConnectionAddress, Debuggable.DEBUG_CONFIG); }
					return _parsedNetConnectionAddress;
				}
			}
			return null;				
		}

		public function getDecoratedRTMPFilename():String {
			if(isRTMP()) {
				if(_parsedFilename == null) {
					CONFIG::debugging { doLog("Parsing RTMP Linear Ad URL " + _url, Debuggable.DEBUG_CONFIG); }
					if(hasMatchingStreamerDeclaration()) {
						_parsedFilename = _matchingStreamerDeclaration.formDecoratedRTMPFilename(_url, _mimeType);			
						CONFIG::debugging { doLog("RTMP filename has been derived using a Streamer declaration - filename is " + _parsedFilename, Debuggable.DEBUG_CONFIG); }
					}
					else if(hasMP4FileMarker()) {
						_parsedFilename = getFilename("mp4:");
						CONFIG::debugging { doLog("RTMP filename has been derived using an MP4 marker - filename is " + _parsedFilename, Debuggable.DEBUG_CONFIG); }
					}
					else if(hasFLVFileMarker()) {
						_parsedFilename = getFilename("flv:");
		                _parsedFilename = _parsedFilename.replace(new RegExp("flv:", "g"), "");
						CONFIG::debugging { doLog("RTMP filename has been derived using an FLV marker - filename is " + _parsedFilename + " ('flv:' marker has been stripped)", Debuggable.DEBUG_CONFIG); }
					}
					else {
						// derive the default filename which is the components after the domain and first directory in the URL
						var urlMinusPrefix:String = _url.substr(_url.indexOf("rtmp://") + 7);
						var parts:Array = urlMinusPrefix.split("/");
						if(parts.length > 2) {
							_parsedFilename = "";
							for(var i:int=2; i < parts.length; i++) {
								_parsedFilename += "/" + parts[i];
							}
							_parsedFilename = _parsedFilename.substr(1);
							if(isMimeType("video/x-mp4") || isMimeType("video/mp4") || isMimeType("mp4") || hasFileExtension(".mp4")) {
								_parsedFilename = "mp4:" + _parsedFilename;
							}
							else if(isMimeType("video/x-flv") || isMimeType("video/flv") || isMimeType("flv") || hasFileExtension(".flv")) {
				                _parsedFilename = _parsedFilename.replace(new RegExp("\\.flv", "g"), "");				
							}
						}
						else _parsedFilename = _url;
						CONFIG::debugging { doLog("RTMP filename has been determined by default rule - filename is " + _parsedFilename, Debuggable.DEBUG_CONFIG); }
					}					
				}
				return _parsedFilename;
			}
			return null;
		}
	}
}
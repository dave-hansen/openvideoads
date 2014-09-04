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
	import org.openvideoads.util.Timestamp;

	/**
	 * @author Paul Schulz
	 */
	public class LinearVideoAd extends TrackedVideoAd {
		protected var _duration:String; // hh:mm:ss
		protected var _mediaFiles:Array = new Array();
		protected var _selectedMediaFile:MediaFile = null;

		public function LinearVideoAd() {
			super();
		}

		public override function unload():void {
			if(hasMediaFiles()) {
				for(var i:int=0; i < _mediaFiles.length; i++) {
					_mediaFiles[i].unload();
				}
			}
		}
		
		public function set duration(duration:String):void {
			_duration = duration;
		}
		
		public override function get duration():String {
			return _duration;
		}
		
		public function setDurationFromSeconds(durationAsSeconds:int):void {
			_duration = Timestamp.secondsToTimestamp(durationAsSeconds);
			CONFIG::debugging { doLog("Linear video ad duration has been changed to " + _duration, Debuggable.DEBUG_CONFIG); }
		}		

		public function hasMediaFiles():Boolean {
			if(_mediaFiles == null) {
				return false;
			}
			return (_mediaFiles.length > 0);
		}
		
		public function mediaFileCount():int {
			if(hasMediaFiles()) {
				return _mediaFiles.length;
			}
			return 0;
		}
		
		public function set mediaFiles(mediaFiles:Array):void {
			_mediaFiles = mediaFiles;
		}
		
		public function get mediaFiles():Array {
			return _mediaFiles;
		}
		
		public function lastSelectedMediaFile():MediaFile {
			return _selectedMediaFile;
		}

		protected override function getAssetURI():String {
			if(_selectedMediaFile != null) {
				return _selectedMediaFile.url.getURI();
			}
			return null;
		}

		public function filterLinearAdMediaFileByMimeType(mimeTypes:Array):void {
			var i:int = 0;
			while(i < _mediaFiles.length) {
				if(_mediaFiles[i].isPermittedMimeType(mimeTypes) == false) {
					// it's not in our list of permitted mime types, so exclude it
					var removedMediaFiles:Array = _mediaFiles.splice(i, 1);
					CONFIG::debugging { doLog("Excluded media based on mime type - " + MediaFile(removedMediaFiles[0]).url.url, Debuggable.DEBUG_VAST_TEMPLATE); }
				}
				else ++i;
			}
		}
				
		public function addMediaFile(mFile:MediaFile):void {
			if(mFile.isProgressive()) { // progressive go up front, streaming to the rear
				var holder:Array = [ mFile ];
				_mediaFiles = holder.concat(_mediaFiles);
			}
			else _mediaFiles.push(mFile);
		}

		public function isEmpty():Boolean {
			return (_mediaFiles.length == 0);			
		}
				
		public function getSpecificallyRatedMediaFile(deliveryType:String, mimeType:*='any', bitrate:* = -1, width:int = -1, height:int = -1, interactiveOnly:Boolean=false):MediaFile {
			if(_mediaFiles != null && _mediaFiles.length > 0) {
				CONFIG::debugging { doLog("Searching for linear ad (" + _mediaFiles.length + " available) SPECIFICALLY matching delivery: " + deliveryType + ", mime type: " + mimeType + ", bitrate: " + bitrate + ", width: " + width + ", height: " + height, Debuggable.DEBUG_SEGMENT_FORMATION); }
				var bestMatch:MediaFile = null;
				var widthVariation:int = -1;
 				var heightVariation:int = -1;
				var minBitrate:int = -1;
				var maxBitrate:int = -1;
				if(bitrate is String && bitrate != null) {
					// two options if the bitrate is specified as a string - a) a range 500-600 or b) a single value such as 500
					if(bitrate.indexOf("-") > -1) {
						// it's a range
						var parts:Array = String(bitrate).split("-");
						if(parts.length == 2) {
							minBitrate = parseInt(parts[0]);
							maxBitrate = parseInt(parts[1]);
						}
					}
					else {
						// it's a single figure
						minBitrate = maxBitrate = parseInt(bitrate);
					}
				}
//				for(var i:int = 0; i < _mediaFiles.length; i++) {
				for(var i:int = (_mediaFiles.length - 1); i >= 0; i--) {
					if(_mediaFiles[i].isDeliveryType(deliveryType) && _mediaFiles[i].isMimeType(mimeType)) {
						// we have a bit rate requirement and possibly a height and width requirement as well
						if(_mediaFiles[i].hasBitRate() && minBitrate > -1) {
							if((minBitrate <= _mediaFiles[i].bitRate) && (_mediaFiles[i].bitRate <= maxBitrate)) {
								// this is a candidate so let's continue on and see if the dimensions impact selection
							}
							else continue;
						}
						// check the dimensions
						if(width == -1 && height == -1) {
							bestMatch = _mediaFiles[i];
							i = -1; //_mediaFiles.length;
						}
						else if(width > -1) { // we have a width requirement but possibly no height requirement
							if(widthVariation == -1 || Math.abs(width - _mediaFiles[i].width) < widthVariation) {
								if(height > -1) {
									if(heightVariation == -1 || Math.abs(height - _mediaFiles[i].height) < heightVariation) {
										bestMatch = _mediaFiles[i];
										heightVariation = Math.abs(height - _mediaFiles[i].height);
										widthVariation = Math.abs(width - _mediaFiles[i].width);
									}
								}
								else {
									bestMatch = _mediaFiles[i];
									widthVariation = Math.abs(width - _mediaFiles[i].width);
								}
							}
						}
						else { // we have a height requirement but no width requirement
							if(heightVariation == -1 || Math.abs(height - _mediaFiles[i].height) < heightVariation) {
								bestMatch = _mediaFiles[i];
								heightVariation = Math.abs(height - _mediaFiles[i].height);
							}
						}
					}
				}
				
				if(bestMatch != null) {
					CONFIG::debugging { doLog("Matched '" + bestMatch.url.url + "' - bitrate: " + bestMatch.bitRate + ", width: " + bestMatch.width + ", height: " + bestMatch.height, Debuggable.DEBUG_SEGMENT_FORMATION);	}
				}
				else {
					CONFIG::debugging { doLog("Could not match a media file for the given search parameters", Debuggable.DEBUG_SEGMENT_FORMATION); }
				}
				
				return bestMatch;
			}

			CONFIG::debugging { doLog("No media files recorded - unable to match", Debuggable.DEBUG_SEGMENT_FORMATION); }
			return null;			
		}

		public function getMinimumRatedMediaFile(deliveryType:String, mimeType:*='any', width:int = -1, height:int = -1, interactiveOnly:Boolean=false):MediaFile {
			CONFIG::debugging { doLog("Searching for linear ad with LOW bitrate matching type: " + mimeType + ", width: " + width + ", height: " + height, Debuggable.DEBUG_SEGMENT_FORMATION); }
			var matchedMediaFile:MediaFile = null;
			if(_mediaFiles != null && _mediaFiles.length > 0) {
				var currentMinBitrate:int = 99999999;
				for(var i:int = 0; i < _mediaFiles.length; i++) {
					if(width == -1 && height == -1) {
						if(_mediaFiles[i].bitRate < currentMinBitrate) {
							matchedMediaFile = _mediaFiles[i];
							currentMinBitrate = _mediaFiles[i].bitRate;
						}
					}
					else if(width == -1 && height > -1) {
						if(height == _mediaFiles[i].height) {
							if(_mediaFiles[i].bitRate < currentMinBitrate) {
								matchedMediaFile = _mediaFiles[i];
								currentMinBitrate = _mediaFiles[i].bitRate;
							}							
						}
					}
					else if(width > -1 && _mediaFiles[i].width == width) {
						if(_mediaFiles[i].bitRate < currentMinBitrate) {
							matchedMediaFile = _mediaFiles[i];
							currentMinBitrate = _mediaFiles[i].bitRate;
						}						
					}
				}
			}

			if(matchedMediaFile != null) {
				CONFIG::debugging { doLog("Matched a minimum rate media file with the parameters - bitrate: " + matchedMediaFile.bitRate + ", width: " + matchedMediaFile.width + ", height: " + matchedMediaFile.height, Debuggable.DEBUG_SEGMENT_FORMATION); }	
			}
			else {
   			    CONFIG::debugging { doLog("Unable to match a minimum rate media file - null returned", Debuggable.DEBUG_SEGMENT_FORMATION); }
   			}

			return matchedMediaFile;
		}

		public function getMaximumRatedMediaFile(deliveryType:String, mimeType:*='any', width:int = -1, height:int = -1, interactiveOnly:Boolean=false):MediaFile {
			CONFIG::debugging { doLog("Searching for linear ad with HIGH bitrate matching type: " + mimeType + ", width: " + width + ", height: " + height, Debuggable.DEBUG_SEGMENT_FORMATION); }
			var matchedMediaFile:MediaFile = null;
			if(_mediaFiles != null && _mediaFiles.length > 0) {
				var currentMaxBitrate:int = -1;
				for(var i:int = 0; i < _mediaFiles.length; i++) {
					if(width == -1 && height == -1) {
						if(_mediaFiles[i].bitRate > currentMaxBitrate) {
							matchedMediaFile = _mediaFiles[i];
							currentMaxBitrate = _mediaFiles[i].bitRate;
						}
					}
					else if(width == -1 && height > -1) {
						if(height == _mediaFiles[i].height) {
							if(_mediaFiles[i].bitRate > currentMaxBitrate) {
								matchedMediaFile = _mediaFiles[i];
								currentMaxBitrate = _mediaFiles[i].bitRate;
							}							
						}
					}
					else if(width > -1 && _mediaFiles[i].width == width) {
						if(_mediaFiles[i].bitRate > currentMaxBitrate) {
							matchedMediaFile = _mediaFiles[i];
							currentMaxBitrate = _mediaFiles[i].bitRate;
						}						
					}
				}
			}

			if(matchedMediaFile != null) {
				CONFIG::debugging { doLog("Matched a maximum rate media file with the parameters - bitrate: " + matchedMediaFile.bitRate + ", width: " + matchedMediaFile.width + ", height: " + matchedMediaFile.height, Debuggable.DEBUG_SEGMENT_FORMATION);	}
			}
			else {
				CONFIG::debugging { doLog("Unable to match a maximum rate media file - null returned", Debuggable.DEBUG_SEGMENT_FORMATION); }
			}

			return matchedMediaFile;
		}

		public function getMediumRatedMediaFile(deliveryType:String, mimeType:*='any', width:int = -1, height:int = -1, interactiveOnly:Boolean=false):MediaFile {
			CONFIG::debugging { doLog("Searching for linear ad with MEDIUM rated bitrate matching type: " + mimeType + ", width: " + width + ", height: " + height, Debuggable.DEBUG_SEGMENT_FORMATION); }
			var matchedMediaFile:MediaFile = null;
			if(_mediaFiles != null && _mediaFiles.length > 0) {
				var maxBitrate:int = -1;
				var minBitrate:int = 9999999;
				var matchedIndexes:Array = new Array();
				// first find the min and max bit rates for the matching criteria
				for(var i:int = 0; i < _mediaFiles.length; i++) {
					if(width == -1 && height == -1) {
						if(_mediaFiles[i].bitRate > maxBitrate) {
							maxBitrate = _mediaFiles[i].bitRate;
							matchedMediaFile = _mediaFiles[i];
						}
						if(_mediaFiles[i].bitRate < minBitrate) {
							minBitrate = _mediaFiles[i].bitRate;
						}
						matchedIndexes.push(i);
					}
					else if(width == -1 && height > -1) {
						if(height == _mediaFiles[i].height) {
							if(_mediaFiles[i].bitRate > maxBitrate) {
								maxBitrate = _mediaFiles[i].bitRate;
								matchedMediaFile = _mediaFiles[i];
							}							
							if(_mediaFiles[i].bitRate < minBitrate) {
								minBitrate = _mediaFiles[i].bitRate;
							}
							matchedIndexes.push(i);
						}
					}
					else if(width > -1 && _mediaFiles[i].width == width) {
						if(_mediaFiles[i].bitRate > maxBitrate) {
							maxBitrate = _mediaFiles[i].bitRate;
							matchedMediaFile = _mediaFiles[i];
						}						
						if(_mediaFiles[i].bitRate < minBitrate) {
							minBitrate = _mediaFiles[i].bitRate;
						}
						matchedIndexes.push(i);
					}					
				}
				if(maxBitrate > -1 && minBitrate < 9999999) {
					var estimatedMidpointBitrate:int = minBitrate + ((maxBitrate - minBitrate) / 2);
					for(var j:int=0; j < matchedIndexes.length; j++) {
						if(_mediaFiles[matchedIndexes[j]].bitRate > minBitrate && _mediaFiles[matchedIndexes[j]].bitRate <= estimatedMidpointBitrate) {
							if(estimatedMidpointBitrate - matchedMediaFile.bitRate < 0 ||
							   (estimatedMidpointBitrate - _mediaFiles[matchedIndexes[j]].bitRate < (estimatedMidpointBitrate - matchedMediaFile.bitRate))) {
								matchedMediaFile = _mediaFiles[matchedIndexes[j]];								
							}
							else {
								matchedMediaFile = _mediaFiles[matchedIndexes[j]];
							}
						}
					}
				}
			}

			if(matchedMediaFile != null) {
				CONFIG::debugging { doLog("Matched a medium rate media file with the parameters - bitrate: " + matchedMediaFile.bitRate + ", width: " + matchedMediaFile.width + ", height: " + matchedMediaFile.height, Debuggable.DEBUG_SEGMENT_FORMATION);	}
			}
			else {
				CONFIG::debugging { doLog("Unable to match a medium rate media file - null returned", Debuggable.DEBUG_SEGMENT_FORMATION); }
			} 

			return matchedMediaFile;
		}
		
		public function getRatedMediaFile(deliveryType:String, mimeType:*='any', bitrate:* = -1, width:int = -1, height:int = -1, interactiveOnly:Boolean=false):MediaFile {
			return getSpecificallyRatedMediaFile(deliveryType, mimeType, bitrate, width, height);
		}

		public function getMediaFileToPlay(deliveryType:String, mimeType:*='any', bitrate:* = -1, width:int = -1, height:int = -1, interactiveOnly:Boolean=false):MediaFile {
			if(bitrate is String && bitrate != null) {
				var _selectedMedia:MediaFile = null;
				if(bitrate != null) {
					switch(bitrate.toUpperCase()) {
						case "HIGH":
							return getMaximumRatedMediaFile(deliveryType, mimeType, width, height);
						case "MEDIUM":
							return getMediumRatedMediaFile(deliveryType, mimeType, width, height);
						case "LOW":
							return getMinimumRatedMediaFile(deliveryType, mimeType, width, height);
						default:
						    return getRatedMediaFile(deliveryType, mimeType, bitrate, width, height);
					}
				}
				return getRatedMediaFile(deliveryType, mimeType, -1, width, height);
			}
			return getRatedMediaFile(deliveryType, mimeType, bitrate, width, height);
		}

		public function getStreamToPlay(deliveryType:String, mimeType:*='any', bitrate:* = -1, width:int = -1, height:int = -1, saveSelected:Boolean=false):AdNetworkResource {
			if(_selectedMediaFile == null) {
				var toSaveMediaFile:MediaFile = getMediaFileToPlay(deliveryType, mimeType, bitrate, width, height);				
				if(saveSelected) {
					_selectedMediaFile = toSaveMediaFile;
				}
				else if(toSaveMediaFile != null) {
					return toSaveMediaFile.url;
				}
			}
			if(_selectedMediaFile != null) {
				return _selectedMediaFile.url;
			}
			return null;
		}
		
		public function canScale(deliveryType:String, mimeType:*='any', bitrate:* = -1, width:int = -1, height:int = -1, saveSelected:Boolean=false):Boolean {
			if(_selectedMediaFile == null) {
				var toSaveMediaFile:MediaFile = getMediaFileToPlay(deliveryType, mimeType, bitrate, width, height);				
				if(saveSelected) {
					_selectedMediaFile = toSaveMediaFile;
				}
				else if(toSaveMediaFile != null) {
					return toSaveMediaFile.scale;
				}
			}
			if(_selectedMediaFile != null) {
				return _selectedMediaFile.scale;
			}
			return false;
		}
		
		public function shouldMaintainAspectRatio(deliveryType:String, mimeType:*='any', bitrate:* = -1, width:int = -1, height:int = -1, saveSelected:Boolean=false):Boolean {
			if(_selectedMediaFile == null) {
				var toSaveMediaFile:MediaFile = getMediaFileToPlay(deliveryType, mimeType, bitrate, width, height);				
				if(saveSelected) {
					_selectedMediaFile = toSaveMediaFile;
				}
				else if(toSaveMediaFile != null) {
					return toSaveMediaFile.maintainAspectRatio;
				}
			}
			if(_selectedMediaFile != null) {
				return _selectedMediaFile.maintainAspectRatio;
			}
			return true;
		}	
		
		public function isInteractive(deliveryType:String, mimeType:*='any', bitrate:* = -1, width:int = -1, height:int = -1, saveSelected:Boolean=false):Boolean {
			if(_selectedMediaFile == null) {
				var toSaveMediaFile:MediaFile = getMediaFileToPlay(deliveryType, mimeType, bitrate, width, height);				
				if(saveSelected) {
					_selectedMediaFile = toSaveMediaFile;
				}
				else if(toSaveMediaFile != null) {
					return toSaveMediaFile.isInteractive();
				}
			}
			if(_selectedMediaFile != null) {
				return _selectedMediaFile.isInteractive();
			}
			return false;
		}	
		
		public function resetSelectedMediaCache():void {
			_selectedMediaFile = null;
		}

		public function clicked():void {
			triggerTrackingEvent(TrackingEvent.EVENT_ACCEPT);
			triggerTrackingEvent(TrackingEvent.EVENT_ACCEPT_INVITATION_LINEAR);
			fireClickTracking();
		}	
		
		protected function mediaFilesToJSObjectArray():Array {
			var result:Array = new Array();
			if(_mediaFiles != null) {
				for(var i:int=0; i < _mediaFiles.length; i++) {
					result.push(_mediaFiles[i].toJSObject());	
				}			
			}
			return result;
		}
		
		public override function toJSObject():Object {
			var o:Object = super.toJSObject();
			o.duration = _duration;
			o.mediaFiles = mediaFilesToJSObjectArray()
			return o;
		}	
	}
}
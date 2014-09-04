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
package org.openvideoads.vast.schedule {
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.util.Timestamp;
	import org.openvideoads.vast.VASTController;
	import org.openvideoads.vast.schedule.ads.AdSchedule;
	import org.openvideoads.vast.schedule.ads.AdSlot;
	import org.openvideoads.vast.tracking.TimeEvent;

	/**
	 * @author Paul Schulz
	 */
	public class StreamSequence extends Debuggable {
		protected var _vastController:VASTController = null;
		protected var _sequence:Array = new Array();
		protected var _totalDuration:int = 0;
		protected var _lastPauseTime:int = 0;
		protected var _bestBitrate:int = -1;
		protected var _baseURL:String = null;
		protected var _timerFactor:int = 1;
		protected var _lastTrackedStreamIndex:int = -1;
		
		public function StreamSequence(vastController:VASTController=null, streams:Array=null, adSequence:AdSchedule=null, bestBitrate:int = -1, baseURL:String=null, timerFactor:int=1, previewImage:String=null):void {
			if(streams != null) {
				initialise(vastController, streams, adSequence, bestBitrate, baseURL, timerFactor);
			}
			else _vastController = vastController;
		}

		public function initialise(vastController:VASTController, streams:Array=null, adSequence:AdSchedule=null, bestBitrate:int = -1, baseURL:String=null, timerFactor:int=1, previewImage:String=null):void {
			_vastController = vastController;
			_timerFactor = timerFactor;
			_bestBitrate = bestBitrate;

			if(baseURL != null) {
				_baseURL = baseURL;
			}
			if(streams != null && adSequence != null) {
				_totalDuration = build(streams, adSequence, previewImage);			
			}
		}

		public function get vastController():VASTController {
			return _vastController;
		}
		
		public function get length():int {
			return _sequence.length;
		}
		
		public function streamAt(index:int):Stream {
			return _sequence[index];
		}
		
		public function get totalDuration():int {
			return _totalDuration;
		}
		
		public function hasBestBitRate():Boolean {
			return _bestBitrate > -1;
		}
		
		public function get bestBitrate():int {
			return _bestBitrate;
		}
		
		public function hasBaseURL():Boolean {
			return _baseURL != null;
		}
		
		public function get baseURL():String {
			return _baseURL;
		}

		public function markPaused(timeInSeconds:int):void {
			_lastPauseTime = timeInSeconds;
		}
		
		public function get lastPauseTime():int {
			return _lastPauseTime;
		}
		
		public function resetPauseMarker():void {
			_lastPauseTime = -1;
		}
		
		public function getStartingStreamIndex():int {
			for(var i:int=0; i < _sequence.length; i++) {
				if(_sequence[i].isStream()) return i;
			}	
			return 0;
		}
		
		public function getStreamAtIndex(streamIndex:int):Stream {
			if(_sequence != null) {
				if(streamIndex < _sequence.length) {
					return _sequence[streamIndex];
				}
			}
			return null;
		}
		
		public function resetAllTrackingPointsAssociatedWithStream(associatedStreamIndex:int):void {
			if(_sequence != null) {
				if(associatedStreamIndex > -1 && associatedStreamIndex < _sequence.length) {
					_sequence[associatedStreamIndex].resetAllTrackingPoints();
				}
			}
		}

		public function resetDurationForAdStreamAtIndex(streamIndex:int, newDuration:int):void {
			if(streamIndex < _sequence.length) {
				_sequence[streamIndex].duration = newDuration;
			}
			else {
				CONFIG::debugging { doLog("ERROR: Cannot reset duration and tracking table for ad stream at index " + streamIndex + " as the stream sequence only has " + _sequence.length + " streams", Debuggable.DEBUG_CONFIG); }
			}
		}

		public function getStreamSequenceIndexGivenOriginatingIndex(originalIndex:int, excludeSlices:Boolean=false, excludeMidRolls:Boolean=false):int {
			var excludeCounter:int = 0;
			for(var i:int=0; i < _sequence.length; i++) {
				if(!(_sequence[i] is AdSlot)) {
					if(_sequence[i].originatingStreamIndex == originalIndex) {
						return i-excludeCounter;
					}
					else if(_sequence[i].isSlice() && excludeSlices) ++excludeCounter;
				}
				else if(_sequence[i].isMidRoll() && excludeMidRolls) ++excludeCounter;
			}	
			return -1;
		}		
		
		protected function createNewMetricsTracker():Object {
			var currentMetrics:Object = new Object();
			currentMetrics.usedAdDuration = 0;		
			currentMetrics.remainingActiveShowDuration = 0;	
			currentMetrics.usedActiveShowDuration = 0;
			currentMetrics.totalActiveShowDuration = 0;
			currentMetrics.associatedStreamIndex = 0;	
			currentMetrics.atStart = false;	
			currentMetrics.hasOffsetStartTime = false;	
			return currentMetrics;
		}

		public function addStream(stream:Stream, declareTrackingPoints:Boolean=true):void {
			if(declareTrackingPoints) stream.declareTrackingPoints(0);
			_sequence.push(stream);
		}
		
		public function addRemainingStreamSlice(streams:Array, streamMetrics:Object, label:String, totalDuration:int, lastScheduledPrerollAdSlot:AdSlot=null):int {
			var startTimestamp:String = Timestamp.secondsToTimestamp(streamMetrics.usedActiveShowDuration);
			var isSlice:Boolean = true;
			if(streams[streamMetrics.associatedStreamIndex].startTime != undefined && streams[streamMetrics.associatedStreamIndex].startTime != null) {
				// it's not a slice if there was a startTime specified for the stream and we are starting there
				isSlice = !(streams[streamMetrics.associatedStreamIndex].startTime == startTimestamp);
			}
			addStream(new Stream(this,
			                     _vastController,
			                     _sequence.length,
			                     label + streamMetrics.associatedStreamIndex + "-" + _sequence.length,
			                     streams[streamMetrics.associatedStreamIndex].id, 
							     ((isSlice && _vastController.config.adsConfig.hasPostMidRollSeekPosition()) ? _vastController.config.adsConfig.postMidRollSeekPositionAsTimestamp() : startTimestamp),
							     new String(streamMetrics.totalActiveShowDuration), 
							     new String(streamMetrics.totalActiveShowDuration),
							     true,
			                     streams[streamMetrics.associatedStreamIndex].hasBaseURL() ? streams[streamMetrics.associatedStreamIndex].baseURL : _baseURL,
							     "any", 
							     "any", 
							     -1,
								 streams[streamMetrics.associatedStreamIndex].playOnce,
								 streams[streamMetrics.associatedStreamIndex].metaData,
						 		 streams[streamMetrics.associatedStreamIndex].autoPlay,
								 streams[streamMetrics.associatedStreamIndex].provider,
								 streams[streamMetrics.associatedStreamIndex].player,
						 		 null,
								 streamMetrics.associatedStreamIndex,
								 isSlice,
								 streams[streamMetrics.associatedStreamIndex].customProperties,
								 streams[streamMetrics.associatedStreamIndex].fireTrackingEvents,
								 false,
								 lastScheduledPrerollAdSlot)); 
			streamMetrics.usedActiveShowDuration += streamMetrics.remainingActiveShowDuration;
			var newDuration:int = totalDuration + streamMetrics.remainingActiveShowDuration;
			CONFIG::debugging { doLog("Total play duration is now " + newDuration, Debuggable.DEBUG_SEGMENT_FORMATION); }			
			return newDuration;
		}

		public function build(streams:Array, adSequence:AdSchedule, previewImage:String=null):int {
			CONFIG::debugging { doLog("*** BUILDING THE STREAM SEQUENCE FROM " + streams.length + " SHOW STREAMS AND " + adSequence.length + " AD SLOTS", Debuggable.DEBUG_SEGMENT_FORMATION); }
			var adSlots:Array = adSequence.adSlots;
			var trackingInfo:Array = new Array();
			var totalDuration:int = 0;
			
			var currentMetrics:Object = createNewMetricsTracker();
			var previousMetrics:Object = createNewMetricsTracker();

			if(adSequence.hasLinearAds()) {
				var lastScheduledPrerollAdSlot:AdSlot = null;
				for(var i:int = 0; i < adSlots.length; i++) {
					CONFIG::debugging { doLog("Assessing ad slot at index " + i + " - '" + AdSlot(adSlots[i]).id + "' - associatedStreamIndex is '" + adSlots[i].associatedStreamIndex + "'", Debuggable.DEBUG_SEGMENT_FORMATION); }
					if(previousMetrics.associatedStreamIndex != adSlots[i].associatedStreamIndex) {	
						CONFIG::debugging { doLog("This ad slot applies to stream '" + adSlots[i].associatedStreamIndex + "' which is different than the stream we were previously referencing '" + previousMetrics.associatedStreamIndex + "'", Debuggable.DEBUG_SEGMENT_FORMATION); }
						// Before changing the current show stream, make sure it's been fully inserted 
						currentMetrics.remainingActiveShowDuration = currentMetrics.totalActiveShowDuration - currentMetrics.usedActiveShowDuration;
						if(currentMetrics.remainingActiveShowDuration > 0) {
							CONFIG::debugging { doLog("Slotting in the remaining show segment (duration left: " + currentMetrics.remainingActiveShowDuration + ") before moving onto next stream - slice start point is " + Timestamp.secondsToTimestamp(currentMetrics.usedActiveShowDuration) + ", segment duration is " + currentMetrics.remainingActiveShowDuration + " seconds", Debuggable.DEBUG_SEGMENT_FORMATION); }
							totalDuration += addRemainingStreamSlice(streams, currentMetrics, "show-e-", totalDuration, lastScheduledPrerollAdSlot);
							currentMetrics.remainingActiveShowDuration = 0;
							currentMetrics.usedActiveShowDuration = currentMetrics.totalActiveShowDuration;
							currentMetrics.associatedStreamIndex = currentMetrics.associatedStreamIndex + 1;
							// add in any other streams index between the current one and the next ad slot index
							for(var m1:int=currentMetrics.associatedStreamIndex; m1 < adSlots[i].associatedStreamIndex && m1 < streams.length; m1++) {
								CONFIG::debugging { doLog("Sequencing stream " + streams[m1].filename, Debuggable.DEBUG_SEGMENT_FORMATION); }
								addStream(new Stream(this, 
								                     _vastController, 
								                     m1, 
								                     "show-k-" + m + "-" + _sequence.length, 
								                     streams[m1].id,  
								                     streams[m1].startTime,  
								                     Timestamp.timestampToSecondsString(streams[m1].duration), 
								                     Timestamp.timestampToSecondsString(streams[m1].duration), 
								                     streams[m1].reduceLength, 
								                     streams[m1].hasBaseURL() ? streams[m1].baseURL : _baseURL,
												     "any", 
												     "any", 
												     -1,
									                 streams[m1].playOnce,					
											 		 streams[m1].metaData,
											 		 streams[m1].autoPlay,
											 		 streams[m1].provider,
											 		 streams[m1].player,
											 		 null,
											 		 m1,
											 		 false,
											 		 streams[m1].customProperties,
											 		 streams[m1].fireTrackingEvents,
											 		 false,
											 		 lastScheduledPrerollAdSlot)); 
								totalDuration += Timestamp.timestampToSeconds(streams[m1].duration);
								currentMetrics.associatedStreamIndex = m1;
								CONFIG::debugging { doLog("Total play duration is now " + totalDuration, Debuggable.DEBUG_SEGMENT_FORMATION); }
							}
						}							
						previousMetrics = currentMetrics;
						currentMetrics = createNewMetricsTracker();
						currentMetrics.associatedStreamIndex = adSlots[i].associatedStreamIndex;
					}
					if(streams.length > 0) {
						currentMetrics.totalActiveShowDuration = Timestamp.timestampToSeconds(streams[adSlots[i].associatedStreamIndex].duration);
						if(currentMetrics.usedActiveShowDuration == 0 && Timestamp.timestampToSeconds(streams[adSlots[i].associatedStreamIndex].startTime) > 0) {
							// a start time is specified, so set the starting point on the stream accordingly
							CONFIG::debugging { doLog("Show stream has a start time specified - setting starting point in schedule to " + streams[adSlots[i].associatedStreamIndex].startTime, Debuggable.DEBUG_SEGMENT_FORMATION); }
							currentMetrics.usedActiveShowDuration = Timestamp.timestampToSeconds(streams[adSlots[i].associatedStreamIndex].startTime);
							currentMetrics.hasOffsetStartTime = true;
						}	
					}
					if(!adSlots[i].isLinear() && adSlots[i].isActive()) {
						// deal with it as an overlay that goes over the current stream
						adSlots[i].associatedStreamIndex = _sequence.length;
					}
					else if(adSlots[i].isLinear() && adSlots[i].isActive()) {
						if(adSlots[i].isPreRoll()) {
							if(!adSlots[i].isCopy()) {		
								CONFIG::debugging { doLog("Slotting in a pre-roll ad with id: " + adSlots[i].id, Debuggable.DEBUG_SEGMENT_FORMATION); }
								if(currentMetrics.associatedStreamIndex != previousMetrics.associatedStreamIndex) {
									if((previousMetrics.usedActiveShowDuration > 0) && previousMetrics.usedActiveShowDuration < previousMetrics.totalActiveShowDuration) {
										// we still have some of the previous show stream to schedule before we do a pre-roll ad for the next stream
										previousMetrics.remainingActiveShowDuration = previousMetrics.totalActiveShowDuration - previousMetrics.usedActiveShowDuration;
										CONFIG::debugging { doLog("Slotting in the remaining (previous) show segment to play before pre-roll - segment duration is " + previousMetrics.remainingActiveShowDuration + " seconds", Debuggable.DEBUG_SEGMENT_FORMATION); }
										totalDuration += addRemainingStreamSlice(streams, previousMetrics, "show-a-", totalDuration, lastScheduledPrerollAdSlot);
										previousMetrics.associatedStreamIndex = previousMetrics.associatedStreamIndex + 1;
									}
	                                
									// Add in any streams that we have to play before this ad slot has to be played
									for(var m:int=previousMetrics.associatedStreamIndex; m < adSlots[i].associatedStreamIndex && m < streams.length; m++) {
										CONFIG::debugging { doLog("Sequencing stream " + streams[m].filename + " - expected pre-roll advertising", Debuggable.DEBUG_SEGMENT_FORMATION); }
										addStream(new Stream(this, 
										                     _vastController, 
										                     m, 
										                     "show-b-" + m + "-" + _sequence.length, 
										                     streams[m].id, 
										                     streams[m].startTime, 
										                     Timestamp.timestampToSecondsString(streams[m].duration), 
										                     Timestamp.timestampToSecondsString(streams[m].duration), 
										                     streams[m].reduceLength, 
										                     streams[m].hasBaseURL() ? streams[m].baseURL : _baseURL,
														     "any", 
														     "any", 
														     -1,
										                     streams[m].playOnce,					
													 		 streams[m].metaData,
													 		 streams[m].autoPlay,
													 		 streams[m].provider,
													 		 streams[m].player,
													 		 null,
													 		 m,
													 		 false,
													 		 streams[m].customProperties,
													 		 streams[m].fireTrackingEvents,
													 		 false,
													 		 lastScheduledPrerollAdSlot)); 
										totalDuration += Timestamp.timestampToSeconds(streams[m].duration);
										previousMetrics.associatedStreamIndex = m;
										CONFIG::debugging { doLog("Total play duration is now " + totalDuration, Debuggable.DEBUG_SEGMENT_FORMATION); }
									}		
								}
							}
						}
						else if(adSlots[i].isMidRoll()) {
							CONFIG::debugging { doLog("Slotting in a mid-roll ad with id: " + adSlots[i].id, Debuggable.DEBUG_SEGMENT_FORMATION); }
							lastScheduledPrerollAdSlot = null;
							if(!adSlots[i].isCopy()) {
								if(previousMetrics != currentMetrics && (previousMetrics.usedActiveShowDuration < previousMetrics.totalActiveShowDuration)) {
									// we still have some of the previous show stream to schedule before we do a mid-roll ad for the next stream
									previousMetrics.remainingActiveShowDuration = previousMetrics.totalActiveShowDuration - previousMetrics.usedActiveShowDuration;
									CONFIG::debugging { doLog("But first we are slotting in the remaining (previous) show segment to play before mid-roll - segment duration is " + previousMetrics.remainingActiveShowDuration + " seconds", Debuggable.DEBUG_SEGMENT_FORMATION); }
									totalDuration += addRemainingStreamSlice(streams, previousMetrics, "show-c-", totalDuration, lastScheduledPrerollAdSlot);	
									previousMetrics.associatedStreamIndex = previousMetrics.associatedStreamIndex + 1;
								}

								if(streams.length > 0) {
									// Add in any streams that we have to play before this ad slot has to be played
									for(var n:int=previousMetrics.associatedStreamIndex; n < adSlots[i].associatedStreamIndex && n < streams.length; n++) {
										CONFIG::debugging { doLog("Sequencing stream " + streams[n].filename + " - expecting mid-roll advertising", Debuggable.DEBUG_SEGMENT_FORMATION); }
										addStream(new Stream(this, 
										                     _vastController, 
										                     n, 
										                     "show-cf-" + n + "-" + _sequence.length, 
										                     streams[n].id,  
										                     streams[n].startTime,  
										                     Timestamp.timestampToSecondsString(streams[n].duration), 
										                     Timestamp.timestampToSecondsString(streams[n].duration), 
										                     streams[n].reduceLength, 
										                     streams[n].hasBaseURL() ? streams[n].baseURL : _baseURL,
														     "any", 
														     "any", 
														     -1,
										                     streams[n].playOnce,					
													 		 streams[n].metaData,
													 		 streams[n].autoPlay,
													 		 streams[n].provider,
													 		 streams[n].player,
													 		 null,
													 		 n,
													 		 false,
													 		 streams[n].customProperties,
													 		 streams[n].fireTrackingEvents,
													 		 false,
													 		 lastScheduledPrerollAdSlot)); 
										totalDuration += Timestamp.timestampToSeconds(streams[n].duration);
										previousMetrics.associatedStreamIndex = n;
										CONFIG::debugging { doLog("Total play duration is now " + totalDuration, Debuggable.DEBUG_SEGMENT_FORMATION); }
									}		

                                	// Slice in the portion of the current program up to the mid-roll ad
									var showSliceDuration:int = adSlots[i].getStartTimeAsSeconds() - currentMetrics.usedActiveShowDuration;
									CONFIG::debugging { doLog("Slicing in a segment from the show starting at " + Timestamp.secondsToTimestamp(currentMetrics.usedActiveShowDuration) + " running for " + showSliceDuration + " seconds", Debuggable.DEBUG_SEGMENT_FORMATION); }
									addStream(new Stream(this,
									                     _vastController,
									                     _sequence.length,
									                     "show-d-" + adSlots[i].associatedStreamIndex + "-" + _sequence.length,
									                     streams[adSlots[i].associatedStreamIndex].id, 
													     Timestamp.secondsToTimestamp(currentMetrics.usedActiveShowDuration),
														 new String(showSliceDuration),
													     new String(currentMetrics.totalActiveShowDuration),
														 true,
									                     streams[adSlots[i].associatedStreamIndex].hasBaseURL() ? streams[adSlots[i].associatedStreamIndex].baseURL : _baseURL,
													     "any", 
													     "any", 
													     -1,
														 streams[adSlots[i].associatedStreamIndex].playOnce,
														 streams[adSlots[i].associatedStreamIndex].metaData,
												 		 streams[adSlots[i].associatedStreamIndex].autoPlay,
														 streams[adSlots[i].associatedStreamIndex].provider,
														 streams[adSlots[i].associatedStreamIndex].player,
												 		 null,
														 adSlots[i].associatedStreamIndex,
														 true, // changed to fix JW mid-roll issue
														 streams[adSlots[i].associatedStreamIndex].customProperties,
														 streams[adSlots[i].associatedStreamIndex].fireTrackingEvents,
														 currentMetrics.hasOffsetStartTime,
														 lastScheduledPrerollAdSlot)); 
									currentMetrics.usedActiveShowDuration += showSliceDuration;
									totalDuration += showSliceDuration;
									CONFIG::debugging { doLog("Total play duration is now " + totalDuration, Debuggable.DEBUG_SEGMENT_FORMATION); }
								}
							}
						}
						else { // it's post-roll 
							CONFIG::debugging { doLog("Slotting in a post-roll ad with id: " + adSlots[i].id, Debuggable.DEBUG_SEGMENT_FORMATION); }
							lastScheduledPrerollAdSlot = null;
							if(streams.length > 0) {
								if(!adSlots[i].isCopy()) {		
									if(currentMetrics.associatedStreamIndex != previousMetrics.associatedStreamIndex) {
										if((previousMetrics.usedActiveShowDuration > 0) && previousMetrics.usedActiveShowDuration < previousMetrics.totalActiveShowDuration) {
											// we still have some of the previous show stream to schedule before we do a pre-roll ad for the next stream
											previousMetrics.remainingActiveShowDuration = previousMetrics.totalActiveShowDuration - previousMetrics.usedActiveShowDuration;
											CONFIG::debugging { doLog("Slotting in the remaining (previous) show segment to play before pre-roll - segment duration is " + previousMetrics.remainingActiveShowDuration + " seconds", Debuggable.DEBUG_SEGMENT_FORMATION); }
											totalDuration += addRemainingStreamSlice(streams, previousMetrics, "show-h-", totalDuration, lastScheduledPrerollAdSlot);
										}
		                                
										// Add in any streams that we have to play before this ad slot has to be played
										var startIndex:int = (i == 0) ? previousMetrics.associatedStreamIndex : previousMetrics.associatedStreamIndex+1;
										for(var o:int=startIndex; o < adSlots[i].associatedStreamIndex && o < streams.length; o++) {
											CONFIG::debugging { doLog("Sequencing stream " + streams[o].filename + " - expecting post-roll advertising", Debuggable.DEBUG_SEGMENT_FORMATION); }
											addStream(new Stream(this, 
											                     _vastController, 
											                     o, 
											                     "show-hf-" + o + "-" + _sequence.length, 
											                     streams[o].id, 
											                     streams[o].startTime, 
											                     Timestamp.timestampToSecondsString(streams[o].duration), 
											                     Timestamp.timestampToSecondsString(streams[o].duration), 
											                     streams[o].reduceLength, 
											                     streams[o].hasBaseURL() ? streams[o].baseURL : _baseURL,
															     "any",
															     "any", 
															     -1,
											                     streams[o].playOnce,					
														 		 streams[o].metaData,
														 		 streams[o].autoPlay,
														 		 streams[o].provider,
														 		 streams[o].player,
														 		 null,
														 		 o,
														 		 false,
														 		 streams[o].customProperties,
														 		 streams[o].fireTrackingEvents,
														 		 false,
														 		 lastScheduledPrerollAdSlot)); 
											totalDuration += Timestamp.timestampToSeconds(streams[o].duration);
											previousMetrics.associatedStreamIndex = o;
											CONFIG::debugging { doLog("Total play duration is now " + totalDuration, Debuggable.DEBUG_SEGMENT_FORMATION); }
										}		
									}

									// now slot in the show before the post-roll
									currentMetrics.remainingActiveShowDuration = currentMetrics.totalActiveShowDuration - currentMetrics.usedActiveShowDuration;
									if(currentMetrics.remainingActiveShowDuration > 0) {
										CONFIG::debugging { doLog("Slotting in the remaining show segment to play before post-roll - start point is " + Timestamp.secondsToTimestamp(currentMetrics.usedActiveShowDuration) + ", segment duration is " + currentMetrics.remainingActiveShowDuration + " seconds", Debuggable.DEBUG_SEGMENT_FORMATION); }
										totalDuration += addRemainingStreamSlice(streams, currentMetrics, "show-e-", totalDuration, lastScheduledPrerollAdSlot);
										if(i+1 < adSlots.length) {
											currentMetrics.associatedStreamIndex = currentMetrics.associatedStreamIndex + 1;
										}
									}
								}
							}		
						}

						CONFIG::debugging { doLog("Inserting ad to play for " + adSlots[i].duration + " seconds from " + totalDuration + " seconds into the stream", Debuggable.DEBUG_SEGMENT_FORMATION); }
						adSlots[i].streamStartTime = 0;
						adSlots[i].parent = this;
						addStream(adSlots[i]);
						currentMetrics.usedAdDuration += adSlots[i].getDurationAsInt();
						CONFIG::debugging { doLog("Have slotted in the ad with id " + adSlots[i].id, Debuggable.DEBUG_SEGMENT_FORMATION); }
						totalDuration += adSlots[i].getDurationAsInt();
						CONFIG::debugging { doLog("Total stream duration is now " + totalDuration, Debuggable.DEBUG_SEGMENT_FORMATION); }
					}
					else {
						CONFIG::debugging { doLog("Ad slot " + adSlots[i].id + " is either not linear/pop or is NOT active - active is " + adSlots[i].isActive() + ", associatedStreamIndex: " + currentMetrics.associatedStreamIndex, Debuggable.DEBUG_SEGMENT_FORMATION); }
						adSequence.adSlots[i].associatedStreamStartTime = totalDuration;
					}	
				}
				if(currentMetrics.usedActiveShowDuration < currentMetrics.totalActiveShowDuration) { 
					// After looping through all the ads, we still have some show to play, so add it in
					currentMetrics.remainingActiveShowDuration = currentMetrics.totalActiveShowDuration - currentMetrics.usedActiveShowDuration;
					CONFIG::debugging { doLog("Slotting in the remaining show segment right at the end - segment duration is " + currentMetrics.remainingActiveShowDuration + " seconds", Debuggable.DEBUG_SEGMENT_FORMATION); }
					totalDuration += addRemainingStreamSlice(streams, currentMetrics, "show-f-", totalDuration, lastScheduledPrerollAdSlot);								
				}
				if(currentMetrics.associatedStreamIndex+1 < streams.length) {
					// there are still some streams to sequence after all the ads have been slotted in
					for(var x:int=currentMetrics.associatedStreamIndex+1; x < streams.length; x++) {
						CONFIG::debugging { doLog("Sequencing remaining stream " + streams[x].filename + " without any advertising at all", Debuggable.DEBUG_SEGMENT_FORMATION); }
						addStream(new Stream(this, 
						                     _vastController, 
						                     x, 
						                     "show-g-" + x, 
						                     streams[x].id,  
						                     streams[x].startTime, 
						                     Timestamp.timestampToSecondsString(streams[x].duration), 
						                     Timestamp.timestampToSecondsString(streams[x].duration), 
						                     streams[x].reduceLength, 
						                     streams[x].hasBaseURL() ? streams[x].baseURL : _baseURL,
										     "any", 
										     "any", 
										     -1,
						                     streams[x].playOnce,					
									 		 streams[x].metaData,
									 		 streams[x].autoPlay,
									 		 streams[x].provider,
									 		 streams[x].player,
									 		 null,
									 		 x, 
									 		 false,
									 		 streams[x].customProperties,
									 		 streams[x].fireTrackingEvents,
									 		 false,
									 		 lastScheduledPrerollAdSlot)); 
						totalDuration += Timestamp.timestampToSeconds(streams[x].duration);
						CONFIG::debugging { doLog("Total play duration is now " + totalDuration, Debuggable.DEBUG_SEGMENT_FORMATION); }
					}
				}
			}
			else { // we don't have any ads, so just stream the main show
				CONFIG::debugging { doLog("No video ad streams to schedule, just scheduling the main stream(s)", Debuggable.DEBUG_SEGMENT_FORMATION); }
				for(var j:int=0; j < streams.length; j++) {
					CONFIG::debugging { doLog("Sequencing stream " + streams[j].filename + " without any advertising at all", Debuggable.DEBUG_SEGMENT_FORMATION); }
					addStream(new Stream(this, 
					                     _vastController, 
					                     j, 
					                     "show-h-" + j, 
					                     streams[j].id, 
					                     streams[j].startTime, 
					                     Timestamp.timestampToSecondsString(streams[j].duration), 
					                     Timestamp.timestampToSecondsString(streams[j].duration), 
					                     streams[j].reduceLength, 
					                     streams[j].hasBaseURL() ? streams[j].baseURL : _baseURL,
									     "any", 
									     "any",
									     -1,
					                     streams[j].playOnce,					
								 		 streams[j].metaData,
								 		 streams[j].autoPlay,
								 		 streams[j].provider,
								 		 streams[j].player,
								 		 null,
								 		 j, 
								 		 false,
								 		 streams[j].customProperties,
								 		 streams[j].fireTrackingEvents,
								 		 false,
								 		 lastScheduledPrerollAdSlot)); 
					totalDuration += Timestamp.timestampToSeconds(streams[j].duration);
				}
			}
            
            if(previewImage != null && _sequence.length > 0) {
            	// add the preview image property to the first stream in the sequence
            	_sequence[0].previewImage = previewImage;
            	CONFIG::debugging { doLog("Have set preview image on first stream - image is: " + previewImage, Debuggable.DEBUG_SEGMENT_FORMATION); }
            }

            // Quickly loop through the schedule and mark the end of each block (e.g. pre+stream+post = a block)
            markBlockEndsAndAttachPrerolls();
            
			CONFIG::debugging { 
				doLog("Total (Final) stream duration is  " + totalDuration, Debuggable.DEBUG_SEGMENT_FORMATION);
				doLog("*** STREAM SEQUENCE BUILT - " + _sequence.length + " STREAMS INDEXED ", Debuggable.DEBUG_SEGMENT_FORMATION); 
			}
			return totalDuration;
		}				

        protected function markBlockEndsAndAttachPrerolls():void {	
        	CONFIG::debugging { doLog("Deriving end of block markers and attaching pre-rolls to streams for future reference...", Debuggable.DEBUG_SEGMENT_FORMATION); }
        	var activeIndex:int = -1;
        	var lastPrerollStartIndex:int = -1;
        	var stream:Stream;
        	if(_sequence.length > 0) {
        		for(var i:int=0; i < _sequence.length; i++) {
        			_sequence[i].index = i;
        			if(_sequence[i].originatingStreamIndex != activeIndex && activeIndex > -1) {
	        			stream = _sequence[i-1];
        				CONFIG::debugging { doLog("+ Marking stream " + stream.streamName + " at index " + (i-1) + " as end block marker", Debuggable.DEBUG_SEGMENT_FORMATION); }
        				stream.endBlockMarker = true;
        			}
        			if(i > 0) {
						_vastController.onScheduleStream(i-1, _sequence[i-1]);        				
        			}
        			activeIndex = _sequence[i].originatingStreamIndex;
        			
        			// attach related pre-rolls to streams
        			if(_sequence[i] is AdSlot) {
        				if(AdSlot(_sequence[i]).isPreRoll()) {
        					if(lastPrerollStartIndex == -1) lastPrerollStartIndex = i;
        				}
        			}
        			else {
        				if(lastPrerollStartIndex > -1) {
        					Stream(_sequence[i]).associatedPrerollAdSlot = _sequence[lastPrerollStartIndex];
        					CONFIG::debugging { doLog("Have determined that the first pre-roll at index " + lastPrerollStartIndex + " should be attached to show clip at index " + i, Debuggable.DEBUG_SEGMENT_FORMATION); }
        					lastPrerollStartIndex = -1;
        				}
        			}
        		}
        		// cover the last item
        		stream = _sequence[_sequence.length-1];
       			CONFIG::debugging { doLog("+ Marking stream " + stream.streamName + " at index " + (_sequence.length-1) + " as LAST end block marker", Debuggable.DEBUG_SEGMENT_FORMATION); }
        		stream.endBlockMarker = true;
				_vastController.onScheduleStream(_sequence.length-1, stream);
        	}
        }
        
        public function processTimeEvent(associatedStreamIndex:int, timeEvent:TimeEvent, includeChildLinearPoints:Boolean=true):void {
        	if(associatedStreamIndex > -1 &&  associatedStreamIndex < _sequence.length) {
        		_sequence[associatedStreamIndex].processTimeEvent(timeEvent, includeChildLinearPoints);
        		_lastTrackedStreamIndex = associatedStreamIndex;
        	}
        }

		public function resetRepeatableTrackingPoints(streamIndex:int):void {
			if(streamIndex < _sequence.length) {
				_sequence[streamIndex].resetRepeatableTrackingPoints();				
			}
		}
        	
        public function findSegmentRunningAtTime(time:Number):Stream {
        	var timeSpent:int = 0;
			for(var i:int = 0; i < _sequence.length; i++) {
				timeSpent += _sequence[i].getDurationAsInt();
				if(timeSpent > time) {
					return _sequence[i];
				}
			}
			return null; 	
        }

        public function processPauseEvent(time:Number):void {
        	var stream:Stream = findSegmentRunningAtTime(time);
        	if(stream != null) {
        		stream.processPauseStream();	
        	}
        }

        public function processPauseEventForStream(streamIndex:int):void {
        	if(streamIndex < _sequence.length) {
        		_sequence[streamIndex].processPauseStream();
        	}
        }
		
        public function processResumeEvent(time:Number):void {
        	var stream:Stream = findSegmentRunningAtTime(time);
        	if(stream != null) {
        		stream.processResumeStream();
        	}
        }

        public function processResumeEventForStream(streamIndex:int):void {
        	if(streamIndex < _sequence.length) {
        		_sequence[streamIndex].processResumeStream();
        	}
        }

        public function processStopEvent(time:Number):void {
        	var stream:Stream = findSegmentRunningAtTime(time);
        	if(stream != null) {
        		stream.processStopStream();
        	}
        }

        public function processStopEventForStream(streamIndex:int):void {
        	if(streamIndex < _sequence.length) {
        		_sequence[streamIndex].processStopStream();
        	}
        }

        public function processFullScreenEvent(time:Number):void {
        	var stream:Stream = findSegmentRunningAtTime(time);
        	if(stream != null) {
        		stream.processFullScreenEvent();
        	}
        }

        public function processFullScreenEventForStream(streamIndex:int):void {
        	if(streamIndex < _sequence.length) {
        		_sequence[streamIndex].processFullScreenEvent();
        	}
        }

        public function processFullScreenExitEventForStream(streamIndex:int):void {
        	if(streamIndex < _sequence.length) {
        		_sequence[streamIndex].processFullScreenExitEvent();
        	}
        }

        public function processMuteEvent(time:Number):void {
        	var stream:Stream = findSegmentRunningAtTime(time);
        	if(stream != null) {
        		stream.processMuteEvent();
        	}
        }

        public function processMuteEventForStream(streamIndex:int):void {
        	if(streamIndex < _sequence.length) {
        		_sequence[streamIndex].processMuteEvent();
        	}
        }        
        
        public function processUnmuteEvent(time:Number):void {
        	var stream:Stream = findSegmentRunningAtTime(time);
        	if(stream != null) {
        		stream.processUnmuteEvent();
        	}
        }

        public function processUnmuteEventForStream(streamIndex:int):void {
        	if(streamIndex < _sequence.length) {
        		_sequence[streamIndex].processUnmuteEvent();
        	}
        }         
	}
}
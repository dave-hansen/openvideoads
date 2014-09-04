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
	
	public class DurationlessStreamSequence extends StreamSequence {
		
		public function DurationlessStreamSequence(vastController:VASTController=null, 
		                                           streams:Array=null, 
		                                           adSequence:AdSchedule=null, 
		                                           bestBitrate:int = -1, 
		                                           baseURL:String=null, 
		                                           timerFactor:int=1, 
		                                           previewImage:String=null):void {

			super(vastController, streams, adSequence, bestBitrate, baseURL, timerFactor, previewImage);
		}
		
		public override function build(streams:Array, adSequence:AdSchedule, previewImage:String=null):int {
			CONFIG::debugging { doLog("*** BUILDING THE (DURATION-LESS) STREAM SEQUENCE FROM " + streams.length + " SHOW STREAMS AND " + adSequence.length + " AD SLOTS", Debuggable.DEBUG_SEGMENT_FORMATION); }
			
			if(adSequence.hasLinearAds()) {
				var lastScheduledPrerollAdSlot:AdSlot = null;
				var adSlots:Array = adSequence.adSlots;
				var streamIndexInPlay:int = -1;

				for(var i:int = 0; i < adSlots.length; i++) {
					if(streamIndexInPlay != adSlots[i].associatedStreamIndex) {
						if(adSlots[i].isActive()) {
							// add in any other streams index between the current one and the next ad slot index
							for(var m1:int=streamIndexInPlay+1; m1 < adSlots[i].associatedStreamIndex && m1 < streams.length; m1++) {
								CONFIG::debugging { doLog("Sequencing stream " + streams[m1].filename + " (" + streamIndexInPlay + ")", Debuggable.DEBUG_SEGMENT_FORMATION); }
								addStream(new Stream(this, 
								                     _vastController, 
								                     m1, 
								                     "show-a-" + m1 + "-" + _sequence.length, 
								                     streams[m1].id, 
								                     streams[m1].startTime,  
								                     streams[m1].hasDuration() ? Timestamp.timestampToSecondsString(streams[m1].duration) : "0", 
								                     streams[m1].hasDuration() ? Timestamp.timestampToSecondsString(streams[m1].duration) : "0",  
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
								streamIndexInPlay = m1;
							}
						}
					}
					if(!adSlots[i].isLinear() && adSlots[i].isActive()) {
						// deal with it as an overlay that goes over the current stream
						adSlots[i].associatedStreamIndex = _sequence.length;
					}
					else if(adSlots[i].isLinear() && adSlots[i].isActive()) {
						if(adSlots[i].isPreRoll()) {
							CONFIG::debugging { doLog("Slotting in a pre-roll ad with id: " + adSlots[i].adSlotID, Debuggable.DEBUG_SEGMENT_FORMATION); }
						}
						else if(adSlots[i].isMidRoll()) {
							CONFIG::debugging { doLog("Slotting in a mid-roll ad with id: " + adSlots[i].adSlotID, Debuggable.DEBUG_SEGMENT_FORMATION); }
							lastScheduledPrerollAdSlot = null;
							if(!adSlots[i].isCopy()) {
								if(adSlots[i].associatedStreamIndex < streams.length && streamIndexInPlay != adSlots[i].associatedStreamIndex) {
                                	// Place in the current stream taking the mid-roll ad
									CONFIG::debugging { doLog("Sequencing stream " + streams[adSlots[i].associatedStreamIndex].filename + " (" + adSlots[i].associatedStreamIndex + ") - expecting mid-roll ad", Debuggable.DEBUG_SEGMENT_FORMATION); }
									addStream(new Stream(this, 
									                     _vastController, 
									                     adSlots[i].associatedStreamIndex, 
									                     "show-b-" + adSlots[i].associatedStreamIndex + "-" + _sequence.length, 
									                     streams[adSlots[i].associatedStreamIndex].id, 
									                     streams[adSlots[i].associatedStreamIndex].startTime,  
									                     streams[adSlots[i].associatedStreamIndex].hasDuration() ? Timestamp.timestampToSecondsString(streams[adSlots[i].associatedStreamIndex].duration) : "0", //"00:00:00", 
									                     streams[adSlots[i].associatedStreamIndex].hasDuration() ? Timestamp.timestampToSecondsString(streams[adSlots[i].associatedStreamIndex].duration) : "0", //"00:00:00", 
									                     streams[adSlots[i].associatedStreamIndex].reduceLength, 
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
												 		 false,
												 		 streams[adSlots[i].associatedStreamIndex].customProperties,
												 		 streams[adSlots[i].associatedStreamIndex].fireTrackingEvents,
												 		 false,
												 		 lastScheduledPrerollAdSlot)); 
									streamIndexInPlay = adSlots[i].associatedStreamIndex;
								}                                		
							}
						}
						else { // it's post-roll 
							CONFIG::debugging { doLog("Slotting in a post-roll ad with id: " + adSlots[i].adSlotID, Debuggable.DEBUG_SEGMENT_FORMATION); }
							lastScheduledPrerollAdSlot = null;
							if(streams.length > 0) {
								if(!adSlots[i].isCopy()) {	
									if(adSlots[i].associatedStreamIndex < streams.length && streamIndexInPlay != adSlots[i].associatedStreamIndex) {
										CONFIG::debugging { doLog("Sequencing stream " + streams[adSlots[i].associatedStreamIndex].filename + " (" + adSlots[i].associatedStreamIndex + ") - expecting post-roll ad", Debuggable.DEBUG_SEGMENT_FORMATION); }
										addStream(new Stream(this, 
										                     _vastController, 
										                     adSlots[i].associatedStreamIndex, 
										                     "show-c-" + adSlots[i].associatedStreamIndex + "-" + _sequence.length, 
										                     streams[adSlots[i].associatedStreamIndex].id, 
										                     streams[adSlots[i].associatedStreamIndex].startTime,  
										                     streams[adSlots[i].associatedStreamIndex].hasDuration() ? Timestamp.timestampToSecondsString(streams[adSlots[i].associatedStreamIndex].duration) : "0", //"00:00:00", 
										                     streams[adSlots[i].associatedStreamIndex].hasDuration() ? Timestamp.timestampToSecondsString(streams[adSlots[i].associatedStreamIndex].duration) : "0", //"00:00:00", 
										                     streams[adSlots[i].associatedStreamIndex].reduceLength, 
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
													 		 false,
													 		 streams[adSlots[i].associatedStreamIndex].customProperties,
													 		 streams[adSlots[i].associatedStreamIndex].fireTrackingEvents,
													 		 false,
													 		 lastScheduledPrerollAdSlot)); 
										streamIndexInPlay = adSlots[i].associatedStreamIndex;										
									}
								}
							}		
						}

						CONFIG::debugging { doLog("Inserting ad to play for " + adSlots[i].duration + " seconds from " + totalDuration + " seconds into the stream", Debuggable.DEBUG_SEGMENT_FORMATION); }
						adSlots[i].streamStartTime = 0;
						adSlots[i].parent = this;
						addStream(adSlots[i]);
						CONFIG::debugging { doLog("Have slotted in the ad with id " + adSlots[i].adSlotID, Debuggable.DEBUG_SEGMENT_FORMATION); }
					}
					else {
						CONFIG::debugging { doLog("Ad slot " + adSlots[i].id + " is either not linear/pop or is NOT active - active is " + adSlots[i].isActive() + ", streamIndexInPlay: " + streamIndexInPlay, Debuggable.DEBUG_SEGMENT_FORMATION); }
						adSequence.adSlots[i].associatedStreamStartTime = "00:00:00"; //totalDuration;
					}	
				}
				if(streamIndexInPlay+1 < streams.length) {
					// there are still some streams to sequence after all the ads have been slotted in
					for(var x:int=streamIndexInPlay+1; x < streams.length; x++) {
						CONFIG::debugging { doLog("Sequencing remaining stream " + streams[x].filename + " (" + x + ") without any ads at all", Debuggable.DEBUG_SEGMENT_FORMATION); }
						addStream(new Stream(this, 
						                     _vastController, 
						                     x, 
						                     "show-d-" + x, 
						                     streams[x].id,  
						                     streams[x].startTime, 
						                     streams[x].hasDuration() ? Timestamp.timestampToSecondsString(streams[x].duration) : "0", 
						                     streams[x].hasDuration() ? Timestamp.timestampToSecondsString(streams[x].duration) : "0",  
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
					                     "show-e-" + j, 
					                     streams[j].id, 
					                     streams[j].startTime, 
					                     streams[j].hasDuration() ? Timestamp.timestampToSecondsString(streams[j].duration) : "0",  
					                     streams[j].hasDuration() ? Timestamp.timestampToSecondsString(streams[j].duration) : "0",  
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
				}
			}
            
            if(previewImage != null && _sequence.length > 0) {
            	// add the preview image property to the first stream in the sequence
            	_sequence[0].previewImage = previewImage;
            	CONFIG::debugging { doLog("Have set preview image on first stream - image is: " + previewImage, Debuggable.DEBUG_SEGMENT_FORMATION); }
            }
            
            // Quickly loop through the schedule and mark the end of each block (e.g. pre+stream+post = a block)
            markBlockEndsAndAttachPrerolls();
            
			CONFIG::debugging { doLog("*** DURATION-LESS STREAM SEQUENCE BUILT - " + _sequence.length + " STREAMS INDEXED ", Debuggable.DEBUG_SEGMENT_FORMATION); }
			return -1;
		}
	}
}
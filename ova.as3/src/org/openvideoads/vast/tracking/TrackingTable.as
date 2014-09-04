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
package org.openvideoads.vast.tracking {
	import org.openvideoads.base.Debuggable;
	
	/**
	 * @author Paul Schulz
	 */
	public class TrackingTable extends Debuggable {
		protected var _tid:String = "-no-id-";
		protected var _points:Array = new Array();
		protected var _minBaseTime:Number = -1;
		protected var _maxBaseTime:Number = 0;
		protected var _originatingStreamIndex:Number = -1;
		protected var _index:int = -1;

		public function TrackingTable(tid:String, index:int, originatingStreamIndex:int) {
			_tid = tid;
			_index = index;
			_originatingStreamIndex = originatingStreamIndex;
		}
		
		public function get minBaseTime():Number {
			return _minBaseTime;
		}
		
		public function get maxBaseTime():Number {
			return _maxBaseTime;
		}

		protected function getStreamIndex():String {
			return _index + ":" + _originatingStreamIndex;
		}
		
	    public function setPoint(trackingPoint:TrackingPoint, isForLinearChild:Boolean=false):void {
			CONFIG::debugging { doLog("Tracking point recorded in table (stream index: " + getStreamIndex() + ", tid: " + _tid + ") at " + trackingPoint.milliseconds + " milliseconds with event label " + trackingPoint.label + " (child:" + isForLinearChild + ")", Debuggable.DEBUG_TRACKING_TABLE);	}    	
	    	trackingPoint.isForLinearChild = isForLinearChild;
	    	_points[_points.length] = { point:trackingPoint, hit:false, childLinear:isForLinearChild };
			if(!isForLinearChild) {
				if(_minBaseTime < 0 || trackingPoint.milliseconds < _minBaseTime) _minBaseTime = trackingPoint.milliseconds;
				if(trackingPoint.milliseconds > _maxBaseTime) _maxBaseTime = trackingPoint.milliseconds;
			}
	    }
		
		public function removeSelectTrackingPoints(labels:String):void {
			var i:int = 0;
			while(i < _points.length) {
        		if(labels.indexOf(_points[i].point.label) > -1) {
        			_points.splice(i, 1);
        		} 
        		else i++;
        	}						
		}
		
		public function resetAllTrackingPoints():void {
			CONFIG::debugging { doLog("Resetting ALL tracking points in table '" + getStreamIndex() + ", " + _tid + "'", Debuggable.DEBUG_TRACKING_TABLE); }
        	for(var i:int=0; i < _points.length; i++) {
        		_points[i].hit = false;
        	}			
		}
		
		public function resetRepeatableTrackingPoints():void {
			resetRepeatableTrackingPointsFromTime(0);
		}
		
		public function resetRepeatableTrackingPointsFromTime(fromTimeInMilliseconds:Number):void {
			CONFIG::debugging { doLog("Reseting repeatable tracking points in table (" + getStreamIndex() + "," + _tid + ") from " + fromTimeInMilliseconds + " milliseconds so that they fire again", Debuggable.DEBUG_TRACKING_TABLE); }
        	for(var i:int=0; i < _points.length; i++) {
        		var event:Object = _points[i];
        		if(event.point.milliseconds >= fromTimeInMilliseconds) {
	        		if(event.point.repeatable()) event.hit = false;
	        	}
        	}			
		}
		
		public function isTimeInBaseRange(milliseconds:Number):Boolean {
			if(_minBaseTime == -1) {
				return false;
			}
			else return (_minBaseTime <= milliseconds && _maxBaseTime >= milliseconds);
		}
		
		public function timeBetweenTwoPoints(milliseconds:Number, point1Label:String, point2Label:String):Boolean {
	        var beginPoint:TrackingPoint = getTrackingPointOfType(point1Label);
	        var endPoint:TrackingPoint = getTrackingPointOfType(point2Label);
			if(beginPoint != null && endPoint != null) {
				return (beginPoint.milliseconds <= milliseconds && endPoint.milliseconds >= milliseconds);
			}
			return false;
		}
		
		public function getTrackingPointOfType(type:String, onlyChildLinear:Boolean=false, setHit:Boolean=false):TrackingPoint {
        	for(var i:int=0; i < _points.length; i++) {
        		var event:Object = _points[i];
        		if(!onlyChildLinear && event.childLinear) {        			
        		} 
        		else {
        			if(event.point.label == type) {
        				if(setHit) event.hit = true;
        				return event.point;
        			}
        		}
        	}
			return null;
		}
		
        public function hasActiveTrackingPoint(timeEvent:TimeEvent, onlyChildLinear:Boolean=true):TrackingPoint {
        	for(var i:int=0; i < _points.length; i++) {
        		var event:Object = _points[i];
        		if((!onlyChildLinear && event.childLinear) || (onlyChildLinear && !event.childLinear)) {
        			// we are not inspecting child linear events at this time or if we want 
        			// child events exclude non-child ones
        		}
        		else {
	        		if(event.hit) { 
	        			// ignoring this point - it's already been hit
	        		}
	        		else {
	        			if(timeEvent.label != null) {
		       				if((event.point.milliseconds <= timeEvent.milliseconds) && (event.point.label == timeEvent.label)) {
		       					event.hit = true;
		       					return event.point;
			       			}
	        			}
	       				else if((event.point.milliseconds <= timeEvent.milliseconds)) {
	       					event.hit = true;
	       					return event.point;
		       			}
		        		else if(event.milliseconds > timeEvent.milliseconds) {
		        			return null;
		        		}
	        		}        			
        		}
        	}
        	return null;
		}
		
		public function hasHitTrackingPoints(onlyChildLinearPoints:Boolean=false):Boolean {
        	for(var i:int=0; i < _points.length; i++) {
        		var event:Object = _points[i];
        		if(onlyChildLinearPoints && event.childLinear) {
        			if(event.hit) return true;
        		}
        		else if(!onlyChildLinearPoints && !event.childLinear) {
        			if(event.hit) return true;        			
        		}
        	}
        	return false;
		}

		public function activeTrackingPoints(timeEvent:TimeEvent, onlyChildLinearPoints:Boolean=true):Array {
			var result:Array = new Array();
			var event:Object;
			if(onlyChildLinearPoints == false && (timeEvent.milliseconds > _maxBaseTime) && timeEvent.label == null) {
				// ok, so the time point is past the table range and it's not timing events associated with a child
				// linear stream, so return any un-hit tracking points since the last timing event
				CONFIG::debugging { doLog("TrackingTable cleanup (" + getStreamIndex() + ", " + _tid + ", length: " + _points.length + "): Search for unused tracking points matching " + timeEvent.toString() + " onlyChildLinear: " + onlyChildLinearPoints, Debuggable.DEBUG_TRACKING_TABLE); }
	        	for(var j:int=0; j < _points.length; j++) {
	        		event = _points[j];
	        		if(event.hit) {
	    				CONFIG::debugging { doLog("TrackingTable cleanup (" + getStreamIndex() + ", " + _tid + ", length: " + _points.length + "): Ignoring tracking point " + event.point.label + " because it's been fired already and is not repeatable", Debuggable.DEBUG_TRACKING_TABLE);	}        			
	        		}
	        		else if(event.childLinear == false && (event.point.label != "NS" && event.point.label != "CS")) {
       					event.hit = true;
						CONFIG::debugging { doLog("TrackingTable cleanup (" + getStreamIndex() + ", " + _tid + ", length: " + _points.length + "): MATCHED tracking point " + event.point.label + " @ " + event.point.milliseconds + " on table " + _tid + " - time event @ " + timeEvent.milliseconds, Debuggable.DEBUG_TRACKING_TABLE); }
	     				result.push(event.point);
	        		}
	        	}
			}
			else if(onlyChildLinearPoints || isTimeInBaseRange(timeEvent.milliseconds)) {
				CONFIG::debugging { doLog("TrackingTable Step 1 (" + getStreamIndex() + ", " + _tid + ", length: " + _points.length + "): Search for active tracking points matching " + timeEvent.toString() + " onlyChildLinear: " + onlyChildLinearPoints, Debuggable.DEBUG_TRACKING_TABLE); }
	        	for(var i:int=0; i < _points.length; i++) {
	        		event = _points[i];
	        		if((!onlyChildLinearPoints && event.childLinear) || (onlyChildLinearPoints && !event.childLinear)) {
	        			// we are not inspecting child linear events at this time or if we want 
	        			// child events exclude non-child ones
	        		}
	        		else {
		        		if(event.hit) { 
		    				CONFIG::debugging { doLog("TrackingTable Step 2 (" + getStreamIndex() + ", " + _tid + ", length: " + _points.length + "): Ignoring tracking point " + event.point.label + " because it's been fired already and is not repeatable", Debuggable.DEBUG_TRACKING_TABLE); }
		        		}
		        		else {
		        			if(timeEvent.label != null) {
			       				if((event.point.milliseconds <= timeEvent.milliseconds) && (event.point.label == timeEvent.label)) {
			       					event.hit = true;
									CONFIG::debugging { doLog("TrackingTable Step 3 (" + getStreamIndex() + ", " + _tid + ", length: " + _points.length + "): MATCHED tracking point " + event.point.label + " @ " + event.point.milliseconds + " on table " + _tid + " - time event @ " + timeEvent.milliseconds, Debuggable.DEBUG_TRACKING_TABLE); }
			       					result.push(event.point);
				       			}
		        			}
		       				else if((event.point.milliseconds <= timeEvent.milliseconds)) {
								CONFIG::debugging { doLog("TrackingTable Step 4 (" + getStreamIndex() + ", " + _tid + ", length: " + _points.length + "): MATCHED tracking point " + event.point.label + " @ " + event.point.milliseconds + " on table " + _tid + ", hit: " + event.hit + " - time event @ " + timeEvent.milliseconds, Debuggable.DEBUG_TRACKING_TABLE); }
		       					event.hit = true;
			     				result.push(event.point);
			       			}
			        		else if(event.milliseconds > timeEvent.milliseconds) {
								CONFIG::debugging { doLog("TrackingTable Step 5 (" + getStreamIndex() + ", " + _tid + ", length: " + _points.length + "): Complete - returning " + result.length + " matches", Debuggable.DEBUG_TRACKING_TABLE); }
			        		}
		        		}        			
	        		}
	        	}
				CONFIG::debugging { doLog("TrackingTable Step 6 (" + getStreamIndex() + ", " + _tid + ", length: " + _points.length + "): Complete - returning " + result.length + " matches", Debuggable.DEBUG_TRACKING_TABLE); }
			}
			return result;
		}
		
		public function pointAt(index:int):TrackingPoint {
			if(index < length) {
				return _points[index].point;				
			}
			return null;
		}
		
		public function get length():int {
			return _points.length;
		}
		
		public function getPointAtIndex(i:int):TrackingPoint {
			if(i < length-1) {
				return _points[i].point;
			}
			return null;
		}
	}
}
/*
 *    Copyright (c) 2010 LongTail AdSolutions, Inc
 *
 *    This file is part of the OVA for Flowplayer plugin.
 *
 *    The OVA for Flowplayer plugin is commercial software: you can redistribute it
 *    and/or modify it under the terms of the OVA Commercial License.
 *
 *    You should have received a copy of the OVA Commercial License along with
 *    the source code.  If not, see <http://www.openvideoads.org/licenses>.
 */
package org.openvideoads.plugin.flowplayer.streamer.clip {
	import org.flowplayer.model.Clip;
	
	/**
	 * @author Paul Schulz
	 */
	public class ScheduledClip extends Clip {
		protected var _originalDuration:int = 0;
		protected var _marked:Boolean = false;
		protected var _scheduleKey:int = -1;
		protected var _isOverlayLinear:Boolean = false;
		
		public function ScheduledClip() {
			super();
		}
		
		public function set originalDuration(duration:int):void {
			_originalDuration = duration;
		}
		
		public function get originalDuration():int {
			return _originalDuration;
		}
		
		public function set marked(marked:Boolean):void {
			_marked = marked;
		}
		
		public function get marked():Boolean {
			return _marked;
		}
		
		public function set scheduleKey(scheduleKey:int):void {
			_scheduleKey = scheduleKey;	
		}
		
		public function get scheduleKey():int {
			return _scheduleKey;
		}
		
		public function set isOverlayLinear(isOverlayLinear:Boolean):void {
			_isOverlayLinear = isOverlayLinear;
		}
		
		public function get isOverlayLinear():Boolean {
			return _isOverlayLinear;			
		}
	}
}
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
package org.openvideoads.plugin.flowplayer.streamer.config {
	import org.flowplayer.model.Clip;
	import org.flowplayer.model.MediaSize;
	import org.openvideoads.base.Debuggable;
	
	public class StaticPlayerConfig extends Debuggable {
		public function StaticPlayerConfig() {
		}

		public static function setClipConfig(clip:Clip, config:Object):void {
			if(config.accelerated != undefined) {
				clip.accelerated = config.accelerated;
				CONFIG::debugging { Debuggable.getInstance().doLog("Custom Clip Config: Setting accelerated to " + config.accelerated, Debuggable.DEBUG_CONFIG); }
			}
			if(config.autoBuffering != undefined) {
				clip.autoBuffering = config.autoBuffering;
				CONFIG::debugging { Debuggable.getInstance().doLog("Custom Clip Config: Setting autoBuffering to " + config.autoBuffering, Debuggable.DEBUG_CONFIG); }
			}
			if(config.bufferLength != undefined) {
				clip.bufferLength = config.bufferLength;
				CONFIG::debugging { Debuggable.getInstance().doLog("Custom Clip Config: Setting bufferLength to " + config.bufferLength, Debuggable.DEBUG_CONFIG);	}			
			}
			if(config.fadeInSpeed != undefined) {
				clip.fadeInSpeed = config.fadeInSpeed;
				CONFIG::debugging { Debuggable.getInstance().doLog("Custom Clip Config: Setting fadeInSpeed to " + config.fadeInSpeed, Debuggable.DEBUG_CONFIG); }
			}
			if(config.fadeOutSpeed != undefined) {
				clip.fadeOutSpeed = config.fadeOutSpeed;
				CONFIG::debugging { Debuggable.getInstance().doLog("Custom Clip Config: Setting fadeOutSpeed to " + config.fadeOutSpeed, Debuggable.DEBUG_CONFIG); }
			}
			if(config.metaData != undefined) {
				clip.metaData = config.metaData;
				CONFIG::debugging { Debuggable.getInstance().doLog("Custom Clip Config: Setting metaData to " + config.metaData, Debuggable.DEBUG_CONFIG); }
			}
			if(config.scaling != undefined) {
				clip.scaling = ((config.scaling is String) ? MediaSize.forName(config.scaling) : config.scaling);
				CONFIG::debugging { Debuggable.getInstance().doLog("Custom Clip Config: Setting scaling to " + config.scaling, Debuggable.DEBUG_CONFIG); }
			}
			if(config.seekableOnBegin != undefined) {
				clip.seekableOnBegin = config.seekableOnBegin;
				CONFIG::debugging { Debuggable.getInstance().doLog("Custom Clip Config: Setting seekableOnBegin to " + config.seekableOnBegin, Debuggable.DEBUG_CONFIG); }
			}
			if(config.autoPlay != undefined) {
				clip.autoPlay = config.autoPlay; 				
				CONFIG::debugging { Debuggable.getInstance().doLog("Custom Clip Config: Setting autoPlay to " + config.autoPlay, Debuggable.DEBUG_CONFIG); }
			}
			if(config.type != undefined) {
				clip.type = config.type; 				
				CONFIG::debugging { Debuggable.getInstance().doLog("Custom Clip Config: Setting type to " + config.type, Debuggable.DEBUG_CONFIG); }
			}
			if(config.customProperties != undefined) {
				clip.customProperties = config.customProperties; 				
				CONFIG::debugging { Debuggable.getInstance().doLog("Custom Clip Config: Setting custom properties to " + config.customProperties, Debuggable.DEBUG_CONFIG); }
			}
			if(config.image != undefined) {
				clip.image = config.image; 				
				CONFIG::debugging { Debuggable.getInstance().doLog("Custom Clip Config: Setting image to " + config.image, Debuggable.DEBUG_CONFIG); }
			}
			if(config.linkUrl != undefined) {
				clip.linkUrl = config.linkUrl;		
				CONFIG::debugging { Debuggable.getInstance().doLog("Custom Clip Config: Setting linkUrl to " + config.linkUrl, Debuggable.DEBUG_CONFIG); }
			}
			if(config.linkWindow != undefined) {
				clip.linkWindow = config.linkWindow;
				CONFIG::debugging { Debuggable.getInstance().doLog("Custom Clip Config: Setting linkWindow to " + config.linkWindow, Debuggable.DEBUG_CONFIG); }
			}
			if(config.live != undefined) {
				clip.live = config.live; 				
				CONFIG::debugging { Debuggable.getInstance().doLog("Custom Clip Config: Setting live to " + config.live, Debuggable.DEBUG_CONFIG); }
			}
			if(config.position != undefined) {
				clip.position = config.position; 				
				CONFIG::debugging { Debuggable.getInstance().doLog("Custom Clip Config: Setting position to " + config.position, Debuggable.DEBUG_CONFIG); }
			}
			if(config.subscribe != undefined) {
				clip.setCustomProperty("rtmpSubscribe", config.subscribe);
				CONFIG::debugging { Debuggable.getInstance().doLog("Custom Clip Config: Setting subscribe to " + config.subscribe, Debuggable.DEBUG_CONFIG); }
			}
		}
	}
}
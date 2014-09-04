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
import flash.external.ExternalInterface;	
	import org.flowplayer.model.Clip;
	
	/**
	 * @author Paul Schulz
	 */
	public class HoldingClip extends ScheduledClip {
		public function HoldingClip(clip:* = null) {
			super();
			if(clip != null && clip is Clip) {
				this.metaData = clip.metaData;
				this.provider = clip.provider;
				this.baseUrl = clip.baseUrl;
				this.customProperties = clip.customProperties;
				this.accelerated = clip.accelerated;
				this.autoBuffering = clip.autoBuffering;
				this.bufferLength = clip.bufferLength;
				this.fadeInSpeed = clip.fadeInSpeed;
				this.fadeOutSpeed = clip.fadeOutSpeed;
				this.image = clip.image;
				this.linkUrl = clip.linkUrl;
				this.linkWindow = clip.linkWindow;
				this.live = clip.live;
				this.position = clip.position;
				this.scaling = clip.scaling;
				this.seekableOnBegin = clip.seekableOnBegin;
				this.setUrlResolvers(clip.urlResolvers);
				this.url = clip.url;
				this.autoPlay = clip.autoPlay;
			}
			else if(clip is Object) {
				this.url = clip.url;
				this.scaling = clip.scaling;
				this.autoPlay = clip.autoPlay;
			}
			duration = 0;
		}
	}
}
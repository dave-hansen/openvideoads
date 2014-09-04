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
 *
 *    This class has been based on the internal Flowplayer PlaylistBuilder class
 *
 */
package org.openvideoads.plugin.flowplayer.streamer.clip {
	import org.flowplayer.model.Clip;
	import org.flowplayer.util.PropertyBinder;
	import org.flowplayer.util.URLUtil;
	import org.openvideoads.base.Debuggable;
	
	/**
	 * @author Paul Schulz
	 */
	public class PlaylistConstructor {		
	
		public static function create(clips:Array, commonClip:Object):Array {
			var playlist:Array = new Array();
			for (var i:int=0; i < clips.length; i++) {
				var clipObj:Object = clips[i];
				if (clipObj is String) {
					clipObj = { url: clipObj };
				}
				playlist.push(createClip(clipObj, commonClip));
			}
			return playlist;
		}
		
		public static function createClip(config:Object, commonClip:Object=null, isChild:Boolean = false):Clip {
			if(config != null) {
				if(config is String) {
					config = { url: config };
				}
				
				// set the clip defaults based on the common clip
				if(commonClip != null) {
					for(var prop:String in commonClip) {
						if (config.hasOwnProperty(prop) == false && prop != "playlist") {
							config[prop] = commonClip[prop];
						}
					}					
				}
			
		        var url:String = config.url;
		        var baseUrl:String = config.baseUrl;
		        var fileName:String = url;
		        if (URLUtil.isCompleteURLWithProtocol(url)) {
		            var lastSlashIndex:Number = url.lastIndexOf("/");
		            baseUrl = url.substring(0, lastSlashIndex);
		            fileName = url.substring(lastSlashIndex + 1);
		        }
		        var clip:Clip = Clip.create(config, fileName, baseUrl);
		        new PropertyBinder(clip, "customProperties").copyProperties(config) as Clip;
		        if(isChild || config.hasOwnProperty("position")) {
		            return clip;
		        }
		        if(config.hasOwnProperty("playlist")) {
		            addChildClips(clip, config["playlist"]);
		        } 
		        else if(commonClip && commonClip.hasOwnProperty("playlist")) {
		            addChildClips(clip, commonClip["playlist"]);
		        }
		        return clip;
			}
			return null;
	    }
	
	    private static function addChildClips(clip:Clip, children:Array):void {
	        for (var i:int = 0; i < children.length; i++) {
	            var child:Object = children[i];
	            if(child.hasOwnProperty("position") == false) {
	                if(i == 0) {
	                    child["position"] = 0;
	                }
	                else if(i == children.length-1) {
	                    child["position"] = -1;
	                }
	                else {
	                   continue; // no position declare for this clip
	                }
	            }
	            clip.addChild(createClip(child, true));
	        }
	    }	

		CONFIG::debugging    
	    protected function doLog(output:String, levels:int):void {
	    	Debuggable.getInstance().doLog(output, levels);
	    } 
	}
}
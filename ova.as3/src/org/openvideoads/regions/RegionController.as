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
package org.openvideoads.regions {
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.regions.config.CloseButtonConfig;
	import org.openvideoads.regions.config.RegionViewConfig;
	import org.openvideoads.regions.config.RegionsConfig;
	import org.openvideoads.regions.events.RegionMouseEvent;
	import org.openvideoads.regions.view.RegionView;
	import org.openvideoads.util.DisplayProperties;
	import org.openvideoads.util.StringUtils;

	/**
	 * @author Paul Schulz
	 */
	public class RegionController extends Sprite {
		protected var _config:RegionsConfig = null;
		protected var _regionViews:Array = new Array();
		protected var _displayProperties:DisplayProperties;		
		protected var _inDebugMode:Boolean = false;
		
		public var DEFAULT_REGION:RegionView = null;
		
		public function RegionController(displayProperties:DisplayProperties, config:RegionsConfig) {
			CONFIG::debugging { doLog("RegionController: Display properties " + displayProperties.toString(), Debuggable.DEBUG_DISPLAY_EVENTS); }
			_displayProperties = displayProperties;
			_config = config;
			createRegionViews();
		}
		
		protected function get displayWidth():Number {
			if(_displayProperties != null) {
				return _displayProperties.displayWidth;			
			}
			return 0;
		}

		protected function get displayHeight():Number {
			if(_displayProperties != null) {
				return _displayProperties.displayHeight;			
			}
			return 0;
		}
		
		protected function get closeButtonConfig():CloseButtonConfig {
			return ((_config != null) ? _config.closeButton : null);	
		}
		
		protected function get regionViews():Array {
			return _regionViews;
		}

		protected function getBackgroundColor(defaultColor:String):String {
			if(_inDebugMode) {
				return '#6F6F6F';
			}
			return defaultColor;
		}
				
		protected function getRegion(regionID:String, alwaysCreate:Boolean=false):RegionView {
			for(var i:int=0; i < _regionViews.length; i++) {
				if(_regionViews[i].id == regionID) {
					if(alwaysCreate) {
						_regionViews.splice(i, 1);
					}
					else return _regionViews[i];
				}
			}
			return createPredefinedRegion(regionID);
		}

		protected function getRegionMatchingContentType(regionID:String, contentType:String):RegionView {
			for(var i:int=0; i < _regionViews.length; i++) {
				if(_regionViews[i].id == regionID) {
					if(_regionViews[i].hasContentTypes()) {
						if(_regionViews[i].contentTypes.toUpperCase().indexOf(contentType.toUpperCase()) > -1) {
							return _regionViews[i];
						}
					}
					else return _regionViews[i];
				}
			}
			return createPredefinedRegion(regionID);
		}
				
		protected function removeRegionView(regionID:String):void {
			for(var i:int=0; i < _regionViews.length; i++) {
				if(_regionViews[i].id == regionID) {
					_regionViews.splice(i,1);
				}
			}			
		}
		
		protected function createRegionViews():void {
		}
		
		protected function createPredefinedRegion(regionID:String):RegionView {
			return DEFAULT_REGION;			
		}

		public function regionIsAuto(regionID:String):Boolean {
			if(regionID != null) {
				return (regionID.toUpperCase().indexOf("AUTO") > -1);	
			}
			return false;
		}
		
		public function getAutoRegionAlignment(regionID:String):String {
			if(regionID != null) {
				if(regionID.toUpperCase().indexOf("AUTO:") > -1 && regionID.length > 5) {
					var alignment:String = regionID.substr(regionID.toUpperCase().indexOf("AUTO:") + 5);
					if(alignment != null) {
						alignment = StringUtils.trim(alignment).toUpperCase();
						if("BOTTOM CENTER TOP".indexOf(alignment) > -1 ) {
							return alignment;
						}						
					}
				}
			}
			return "BOTTOM";
		}
		
		protected function createAutoRegion(newId:String, width:int, height:*, alignment:String="BOTTOM", overridingCloseButtonConfig:CloseButtonConfig=null, canClick:Boolean=true, styles:String=null, padding:String=null, expandedWidth:Number=-1, expandedHeight:Number=-1, canScale:Boolean=false, autoHide:Boolean=true):RegionView {
			CONFIG::debugging { doLog("Creating an AUTO region '" + newId + "' - " + width + "x" + height + " alignment: " + alignment + " clickable: " + canClick + " canScale: " + canScale, Debuggable.DEBUG_REGION_FORMATION); }
			removeRegionView(newId);
			return createRegionView(
				new RegionViewConfig(
					{ 
						id: newId, 
						verticalAlign: alignment, 
						backgroundColor: getBackgroundColor('transparent'),
						horizontalAlign: 'center',
						padding: ((padding != null) ? padding : '-10 -10 -10 -10'),
						width: width, 
						height: height,
						expandedWidth: expandedWidth,
						expandedHeight: expandedHeight,
						closeButton: ((overridingCloseButtonConfig != null) ? overridingCloseButtonConfig : this.closeButtonConfig),
						clickable: canClick,
						style: styles,
						autoSizing: true,
						canScale: canScale,
						autoHide: autoHide
					}
				)
			);			
		}
		
		protected function newRegion(controller:RegionController, regionConfig:RegionViewConfig, displayProperties:DisplayProperties):RegionView {
			return new RegionView(this, regionConfig, _displayProperties);
		}
		
		protected function createRegionView(regionConfig:RegionViewConfig):RegionView {
			CONFIG::debugging { doLog("Creating region '" + regionConfig.id + "'", Debuggable.DEBUG_REGION_FORMATION); }
			var newView:RegionView = newRegion(this, regionConfig, _displayProperties);
			_regionViews.push(newView);
			addChild(newView);
			this.setChildIndex(newView, this.numChildren-1);
			return newView;
		}

		public function hideAllRegions():void {
			for(var i:int=0; i < _regionViews.length; i++) {
				_regionViews[i].hide();
			}
		}	

		public function hideAllRegionsExceptNamed(namedRegions:Array):void {
			if(namedRegions != null) {
				for(var i:int=0; i < _regionViews.length; i++) {
					var matched:Boolean = false;
					for(var j:int=0; j < namedRegions.length && !matched; j++) {
						if(StringUtils.matchesIgnoreCase(_regionViews[i].id, namedRegions[j].id)) {
							matched = true;
						}
					}
					if(!matched) _regionViews[i].hide();
				}				
			}
			else hideAllRegions();
		}	
		
		public function onRegionCloseClicked(regionView:RegionView):void {			
			// we are not doing anything with closed regions
  		}

		public function onRegionClicked(regionView:RegionView, originalMouseEvent:MouseEvent):void {			
			dispatchEvent(new RegionMouseEvent(RegionMouseEvent.REGION_CLICKED, regionView, originalMouseEvent));		
		}	
		
		public function resize(resizedProperties:DisplayProperties):void {
			_displayProperties = resizedProperties;
			for(var i:int=0; i < _regionViews.length; i++) {
				_regionViews[i].resize(resizedProperties);
			}
		}		
		
		public function setRegionStyle(regionID:String, cssText:String):String {
			var region:RegionView = getRegion(regionID);
			if(region != null) {
				region.parseCSS(cssText);
				return "1, successfully passed to region to process";
			}
			else return "-2, No region found for id: " + regionID;
		}
		
		// DEBUG
		
		CONFIG::debugging
		protected static function doLog(data:String, level:int=1):void {
			Debuggable.getInstance().doLog(data, level);
		}
		
		CONFIG::debugging
		protected static function doTrace(o:Object, level:int=1):void {
			Debuggable.getInstance().doTrace(o, level);
		}
	}
}
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
 package org.openvideoads.vast.overlay {
 	import org.openvideoads.base.Debuggable;
 	import org.openvideoads.regions.RegionController;
 	import org.openvideoads.regions.config.RegionViewConfig;
 	import org.openvideoads.regions.view.FlashMedia;
 	import org.openvideoads.regions.view.RegionView;
 	import org.openvideoads.util.DisplayProperties;
 	import org.openvideoads.vast.config.groupings.VPAIDConfig;
 	import org.openvideoads.vast.model.NonLinearImageAd;
 	import org.openvideoads.vast.model.VPAIDPlayback;
 	import org.openvideoads.vast.schedule.ads.AdSlot;
	
	/**
	 * @author Paul Schulz
	 */
	public class OverlayView extends RegionView {
		protected var _activeAdSlot:AdSlot = null;
		protected var _flashAd:* = null;
		protected var _vpaidConfig:VPAIDConfig = null;
		protected var _muteOnStartup:Boolean = false;
		protected var _playerVolumeOnStartup:Number = -1;
		protected var _reduceVPAIDAdHeightByBottomMargin:Boolean = false;
		protected var _isLinearAd:Boolean = false;
		
		public function OverlayView(controller:RegionController, regionConfig:RegionViewConfig, displayProperties:DisplayProperties) { 
			super(controller, regionConfig, displayProperties);
		}
		
		public function set activeAdSlot(activeAdSlot:AdSlot):void {
			_activeAdSlot = activeAdSlot;
		}
		
		public function get activeAdSlot():AdSlot {
			return _activeAdSlot;
		}
		
		public function clearActiveAdSlot():void {
			_activeAdSlot = null;
		}

		public override function setHeight():Boolean {
			if(expanded && _config.hasExpandedSizing()) {
				// this view has specific sizing dimensions which must be used when the view is expanded
				height = _config.expandedHeight;
				return true;
			}
			else {
				var originalHeight:Number = height;
				if((expanded == false) && _config.hasMinimizedHeightBasedOnYPosForDisplayMode(_displayProperties.displayMode)) {
					height = _config.calculateMinimizedHeight(_displayProperties);
					CONFIG::debugging { doLog("Minimized height (" + height + "px) calculated based on '" + _config.minimizedHeight + "' for region '" + id + "'", Debuggable.DEBUG_REGION_FORMATION); }
					return (height != originalHeight);
				}
				if(_config.height is String) { 
					if(_config.height.toUpperCase().indexOf("BOTTOM-MARGIN-ADJUSTED") > -1) {
						// the height it to be adjusted by the bottom margin
						height = _displayProperties.getMarginAdjustedHeight(_config.useOverrideMargin);
						CONFIG::debugging { doLog("Height 'bottom-margin-adjusted' to " + height + " for region '" + id + "'", Debuggable.DEBUG_REGION_FORMATION); }
						return (height != originalHeight);
					}			
				}
				return super.setHeight();			
			}
		}
		
		public override function setVerticalAlignment():Boolean {
			if(_config.verticalAlignPosition is String && _config.verticalAlignPosition != null) {
				var parentHeight:int = (_displayProperties.displayHeight * scaleY);
				var originalY:Number = y;
				var marginAdjustment:Number = _displayProperties.getActiveMargin(_config.useOverrideMargin);
				var ySet:Boolean = false;
				if(_config.verticalAlignPosition == "TOP") {
					y = 0 + _config.verticalAlignOffset;
					ySet = true;
				}
				else if(_config.verticalAlignPosition == "BOTTOM") {
					y = (parentHeight - height - marginAdjustment) + _config.verticalAlignOffset; 
					ySet = true;
				}
				else if(_config.verticalAlignPosition == "CENTER") {
					y = ((parentHeight - height - marginAdjustment) / 2) + _config.verticalAlignOffset;
					ySet = true;
				}
				else { // must be a number
					y = new Number(_config.verticalAlignPosition);
					y += _config.verticalAlignOffset;
					ySet = true;
				}	
				if(ySet) {
					CONFIG::debugging { doLog("Vertical alignment set to " + y + " for region " + id, Debuggable.DEBUG_REGION_FORMATION); }				
					return (y != originalY);
				}					
			}
			return super.setVerticalAlignment();
		}

		public override function resize(resizeProperties:DisplayProperties=null):void {
			super.resize(resizeProperties);
			if(_displayProperties != null) {
				if(_flashAd != null && _flashAd is VPAIDPlayback) {
					_flashAd.resize(this.width, this.height, _displayProperties.displayMode);
				}
			}
		}

		protected override function onFlashContentLoaded():void {
			if(_flashAd != null) {
				if(_flashAd.isInteractive()) { 
					if(_flashAd.registerAsVPAID(new VPAIDWrapper(_contentLoader.content, _muteOnStartup, _playerVolumeOnStartup))) {
						show(); //this.visible = true;
						_flashAd.startVPAID(
								this.width, 
								this.height, 
								(_displayProperties != null) ? _displayProperties.displayMode : DisplayProperties.DISPLAY_NORMAL,
								(_vpaidConfig != null) ? _vpaidConfig.supplyReferrer : false,
								(_vpaidConfig != null) ? _vpaidConfig.referrer : null
						);
					}
					else {
						CONFIG::debugging { doLog("VPAID ad not registered - start aborted", Debuggable.DEBUG_VPAID); }
					}
				}				
			}
		}

		public function unloadFlashMedia():void {
			if(_flashAd != null) {
				_flashAd.unload();
				_flashAd = null;
			}
		}
		
		public function loadFlashMedia(flashAd:FlashMedia, vpaidConfig:VPAIDConfig, allowDomains:String, enableClickThrough:Boolean = false, muteOnStartup:Boolean=false, reduceVPAIDAdHeightByBottomMargin:Boolean=false, isLinearAd:Boolean=false, playerVolume:Number=-1):void {
			_flashAd = flashAd;
			_vpaidConfig = vpaidConfig;
			_muteOnStartup = muteOnStartup;
			_playerVolumeOnStartup = playerVolume;
			_reduceVPAIDAdHeightByBottomMargin = reduceVPAIDAdHeightByBottomMargin;
			_isLinearAd = isLinearAd;
			if(_flashAd.isInteractive()) { 
				scalable = (isLinearAd) ? vpaidConfig.enableLinearScaling : vpaidConfig.enableNonLinearScaling;
				CONFIG::debugging { doLog("Loading VPAID Ad into overlay '" + this.id + "' - " + ((scalable) ? "scaling configured" : "scaling not configured") + " dimensions are " + width + "x" + height + " ...", Debuggable.DEBUG_VPAID); }
				loadFlashContent(_flashAd, allowDomains, false);
			}
			else {
				CONFIG::debugging { doLog("Displaying Non-VPAID Flash Ad into overlay '" + this.id + "' ...", Debuggable.DEBUG_VPAID); }
				loadFlashContent(_flashAd, allowDomains, enableClickThrough);
			}			
		}	
		
		public function loadScalableNonLinearImage(nonLinearVideoAd:NonLinearImageAd, recommendedWidth:Number, recommendedHeight:Number, scaleToDeclaredSize:Boolean, allowDomains:String):void {
			if(nonLinearVideoAd != null) {
				loadScalableImageContent(
					nonLinearVideoAd.imageURL, 
					nonLinearVideoAd.width, 
					nonLinearVideoAd.height, 
					recommendedWidth, 
					recommendedHeight,
					scaleToDeclaredSize,
					nonLinearVideoAd.maintainAspectRatio,
					allowDomains
				);
			}
		}	
	}
}
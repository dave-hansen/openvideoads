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
 	import flash.events.MouseEvent;
 	
 	import org.openvideoads.base.Debuggable;
 	import org.openvideoads.regions.RegionController;
 	import org.openvideoads.regions.config.CloseButtonConfig;
 	import org.openvideoads.regions.config.RegionViewConfig;
 	import org.openvideoads.regions.view.FlashMedia;
 	import org.openvideoads.regions.view.RegionView;
 	import org.openvideoads.util.DisplayProperties;
 	import org.openvideoads.vast.VASTController;
 	import org.openvideoads.vast.config.groupings.RegionsConfigGroup;
 	import org.openvideoads.vast.events.AdNoticeDisplayEvent;
 	import org.openvideoads.vast.events.OverlayAdDisplayEvent;
 	import org.openvideoads.vast.model.NonLinearImageAd;
 	import org.openvideoads.vast.model.NonLinearVideoAd;
 	import org.openvideoads.vast.model.VPAIDPlayback;
 	import org.openvideoads.vast.overlay.button.skip.HtmlSkipAdButton;
 	import org.openvideoads.vast.overlay.button.skip.LoadableImageSkipAdButton;
 	import org.openvideoads.vast.overlay.button.skip.SkipAdButtonDisplayEvent;
 	import org.openvideoads.vast.overlay.button.skip.SkipAdButtonView;
 	import org.openvideoads.vast.overlay.button.skip.StandardImageSkipAdButton;
 	import org.openvideoads.vast.schedule.ads.AdSlot;
 	import org.openvideoads.vpaid.IVPAID;
 	import org.openvideoads.vpaid.VPAIDEvent;
	
	/**
	 * @author Paul Schulz
	 */
	public class OverlayController extends RegionController {				
		protected var _vastController:VASTController;
		protected var _mouseTrackerRegion:ClickThroughCallToActionView = null;
		protected var _skipAdButtonRegion:SkipAdButtonView = null;
		protected var _pausingClickForMoreInfoRegion:Boolean = false;
		protected var _activeAdNotice:AdNotice = null;
		protected var _activeVPAIDMedia:VPAIDPlayback = null;
		
		protected static const DEFAULT_TEXT_OVERLAY_STYLES:String = 
                    '.title { font-family: "sans-serif"; font-size: 18pt; font-style: bold; color:#FAF8CC; leading:5px; } ' +
					'.description { font-family: "sans-serif"; font-size: 15pt; leading:3px; } ' +
					'.callToActionTitle { font-family: "sans-serif"; font-size: 15pt; font-style: bold; color:#FBB917; }';
		
		public function OverlayController(vastController:VASTController, displayProperties:DisplayProperties, config:RegionsConfigGroup) {
			_vastController = vastController;
			super(displayProperties, config);
		}

		protected override function newRegion(controller:RegionController, regionConfig:RegionViewConfig, displayProperties:DisplayProperties):RegionView {
			return new OverlayView(controller, regionConfig, displayProperties);
		}
		
		protected override function createPredefinedRegion(regionID:String):RegionView {
			CONFIG::debugging { doLog("Attempting to create a pre-defined region '" + regionID + "'", Debuggable.DEBUG_REGION_FORMATION); }
			var newRegionConfig:RegionViewConfig = null;
			switch(regionID) {
				case 'reserved-system-message':
					return createRegionView(new RegionViewConfig(
					         { 
					            id: 'reserved-system-message', 
					            verticalAlign: 'bottom:-2', 
					            backgroundColor: getBackgroundColor('transparent'),
					            height: 20,
					            width: '100pct', 
								style: '.normaltext { font-family: "sans-serif"; font-size: 12pt; font-style: normal; color:#CCCCCC } ' +
								       '.smalltext { font-family: "sans-serif"; font-size: 10pt; color:#CCCCCC }',
				            	closeButton: this.closeButtonConfig,
								useOverrideMargin: true
   					         }
					));

				case 'reserved-top':
					return createRegionView(new RegionViewConfig(
						{ 
							id: 'reserved-top', 
							verticalAlign: 'top', 
							width: '100pct', 
							height: '50', 
			            	closeButton: this.closeButtonConfig
						}
					));

				case 'reserved-fullscreen':
					return createRegionView(new RegionViewConfig(
						{ 
							id: 'reserved-fullscreen', 
							verticalAlign: 0, 
							horizontalAlign: 0, 
							width: '100pct', 
							height: '100pct', 
							backgroundColor: getBackgroundColor('#000000'),
			            	closeButton: this.closeButtonConfig
						}
					));

				case 'reserved-fullscreen-black-no-close-button-non-clickable':
					return createRegionView(new RegionViewConfig(
						{ 
							id: 'reserved-fullscreen-black-no-close-button-non-clickable', 
							verticalAlign: 0, 
							horizontalAlign: 0, 
							width: '100pct', 
							height: '100pct', 
							backgroundColor: getBackgroundColor('#000000'),
							clickable: false,
			            	closeButton: new CloseButtonConfig({ enabled: false })
						}
					));

				case 'reserved-fullscreen-black-no-close-button-non-clickable-minimize-rules':
					return createRegionView(new RegionViewConfig(
						{ 
							id: 'reserved-fullscreen-black-no-close-button-non-clickable-minimize-rules', 
							verticalAlign: 0, 
							horizontalAlign: 0, 
							width: '100pct', 
							height: '100pct', 
							backgroundColor: getBackgroundColor('#000000'),
							clickable: false,
			            	closeButton: new CloseButtonConfig({ enabled: false }),
							minimizedHeight: 'controls-ypos-when-visible-all-modes'
						}
					));

				case 'reserved-fullscreen-black-no-close-button-non-clickable-with-cb-height':
					return createRegionView(new RegionViewConfig(
						{ 
							id: 'reserved-fullscreen-black-no-close-button-non-clickable-with-cb-height', 
							verticalAlign: 0, 
							horizontalAlign: 0, 
							width: '100pct', 
							height: '100pct', 
							backgroundColor: getBackgroundColor('#000000'),
							clickable: false,
			            	closeButton: new CloseButtonConfig({ enabled: false }),
							additionalHeight: 'controls-height-when-normal',
							minimizedHeight: 'controls-ypos-when-visible-fullscreen'
						}
					));

				case 'reserved-fullscreen-transparent-no-close-button-non-clickable':
					return createRegionView(new RegionViewConfig(
						{ 
							id: 'reserved-fullscreen-black-no-close-button-non-clickable', 
							verticalAlign: 0, 
							horizontalAlign: 0, 
							width: '100pct', 
							height: '100pct', 
							backgroundColor: getBackgroundColor('transparent'),
							clickable: true, 
			            	closeButton: new CloseButtonConfig({ enabled: false }),
			            	autoHide: false 
						}
					));

				case 'reserved-fullscreen-transparent-no-close-button-non-clickable-bottom-margin-adjusted':
					return createRegionView(new RegionViewConfig(
						{ 
							id: 'reserved-fullscreen-transparent-no-close-button-non-clickable-bottom-margin-adjusted', 
							verticalAlign: 0, 
							horizontalAlign: 0, 
							width: '100pct', 
							height: '100pct', 
							backgroundColor: getBackgroundColor('transparent'),
							clickable: true, 
			            	closeButton: new CloseButtonConfig({ enabled: false }),
			            	autoHide: false 
						}
					));

				case 'reserved-bottom-w100pct-h78px-000000-o50':
					return createRegionView(
						new RegionViewConfig(
							{ 
								id: 'reserved-bottom-w100pct-h78px-000000-o50', 
								verticalAlign: 'bottom', 
								backgroundColor: getBackgroundColor('#000000'),
								opacity: 0.5, 
								width: '100pct', 
								height: 78, 
								padding: '5 5 5 5',
								style: DEFAULT_TEXT_OVERLAY_STYLES,
				            	closeButton: this.closeButtonConfig
							}
						)
					);

				case 'reserved-bottom-w100pct-h50px-000000-o50':
					return createRegionView(
						new RegionViewConfig(
							{ 
								id: 'reserved-bottom-w100pct-h50px-000000-o50', 
								verticalAlign: 'bottom', 
								backgroundColor: getBackgroundColor('#000000'),
								opacity: 0.5, 
								width: '100pct', 
								height: 50, 
				            	closeButton: this.closeButtonConfig
							}
						)
					);

				case 'reserved-bottom-w100pct-h50px-transparent-0m':
					return createRegionView(
						new RegionViewConfig(
							{ 
								id: 'reserved-bottom-w100pct-h50px-transparent-0m', 
								verticalAlign: 'bottom', 
								backgroundColor: getBackgroundColor('transparent'),
								width: '100pct', 
								height: 50,
								padding: '-10 -10 -10 -10',
				            	closeButton: this.closeButtonConfig
							}
						)
					);

				case 'reserved-bottom-w450px-h50px-000000-o50':
					return createRegionView(
						new RegionViewConfig(
							{ 
								id: 'reserved-bottom-w450px-h50px-000000-o50', 
								verticalAlign: 'bottom', 
								backgroundColor: getBackgroundColor('#000000'),
								opacity: 0.5, 
								width: 450, 
								height: 50,
				            	closeButton: this.closeButtonConfig
							}
						)
					);
					
				case 'reserved-bottom-w450px-h50px-transparent':
					return createRegionView(
						new RegionViewConfig(
							{ 
								id: 'reserved-bottom-w450px-h50px-transparent', 
								verticalAlign: 'bottom', 
								backgroundColor: getBackgroundColor('transparent'),
								width: 450, 
								height: 50,
				            	closeButton: this.closeButtonConfig
							}
						)
					);
					
				case 'reserved-bottom-w450px-h50px-transparent-0m':
					return createRegionView(
						new RegionViewConfig(
							{ 
								id: 'reserved-bottom-w450px-h50px-transparent-0m', 
								verticalAlign: 'bottom', 
								backgroundColor: getBackgroundColor('transparent'),
								width: 450, 
								height: 50,
								padding: '-10 -10 -10 -10',
				            	closeButton: this.closeButtonConfig
							}
						)
					);

				case 'reserved-bottom-center-w450px-h50px-000000-o50':
					return createRegionView(
						new RegionViewConfig(
							{ 
								id: 'reserved-bottom-center-w450px-h50px-000000-o50', 
								verticalAlign: 'bottom', 
								backgroundColor: getBackgroundColor('#000000'),
								horizontalAlign: 'center',
								opacity: 0.5, 
								width: 450, 
								height: 50,
				            	closeButton: this.closeButtonConfig
							}
						)
					);

				case 'reserved-bottom-center-w450px-h50px-transparent':
					return createRegionView(
						new RegionViewConfig(
							{ 
								id: 'reserved-bottom-center-w450px-h50px-transparent', 
								verticalAlign: 'bottom', 
								horizontalAlign: 'center',
								backgroundColor: getBackgroundColor('transparent'),
								width: 450, 
								height: 50,
				            	closeButton: this.closeButtonConfig
							}
						)
					);

				case 'reserved-bottom-center-w450px-h50px-transparent-0m':
					return createRegionView(
						new RegionViewConfig(
							{ 
								id: 'reserved-bottom-center-w450px-h50px-transparent-0m', 
								verticalAlign: 'bottom', 
								horizontalAlign: 'center',
								backgroundColor: getBackgroundColor('transparent'),
								width: 450, 
								height: 50,
								padding: '-10 -10 -10 -10',
				            	closeButton: this.closeButtonConfig
							}
						)
					);

				case 'reserved-bottom-center-w300px-h50px-000000-o50':
					return createRegionView(
						new RegionViewConfig(
							{ 
								id: 'reserved-bottom-center-w300px-h50px-000000-o50', 
								verticalAlign: 'bottom', 
								backgroundColor: getBackgroundColor('#000000'),
								horizontalAlign: 'center',
								opacity: 0.5, 
								width: 300, 
								height: 50,
				            	closeButton: this.closeButtonConfig
							}
						)
					);

				case 'reserved-bottom-center-w300px-h50px-transparent':
					return createRegionView(
						new RegionViewConfig(
							{ 
								id: 'reserved-bottom-center-w300px-h50px-transparent', 
								verticalAlign: 'bottom', 
								horizontalAlign: 'center',
								backgroundColor: getBackgroundColor('transparent'),
								width: 300, 
								height: 50,
				            	closeButton: this.closeButtonConfig
							}
						)
					);

				case 'reserved-bottom-center-w300px-h50px-transparent-0m':
					return createRegionView(
						new RegionViewConfig(
							{ 
								id: 'reserved-bottom-center-w300px-h50px-transparent-0m', 
								verticalAlign: 'bottom', 
								horizontalAlign: 'center',
								backgroundColor: getBackgroundColor('transparent'),
								width: 300, 
								height: 50,
								padding: '-10 -10 -10 -10',
				            	closeButton: this.closeButtonConfig
							}
						)
					);
			}
			CONFIG::debugging { doLog("Pre-defined region '" + regionID + "' not found - returning default region '" + DEFAULT_REGION.id + "'", Debuggable.DEBUG_REGION_FORMATION); }
			return DEFAULT_REGION;			
		}
		
		protected override function createRegionViews():void {			
			if(_vastController.config.visuallyCueLinearAdClickThrough) {
				_mouseTrackerRegion = 
						new ClickThroughCallToActionView(
								this,
							    new RegionViewConfig(
							         { 
							            id: 'reserved-clickable-click-through', 
						    	        verticalAlign: 0, 
						        	    horizontalAlign: 0, 
						        	    scaleRate: 0.75,
									    width: '100pct',
						            	height: '100pct',
						            	clickable: true,
						            	closeButton: { enabled: false },
						            	backgroundColor: getBackgroundColor('transparent'),
						            	autoHide: false
						         	 }
						    	),
						    	_vastController.config.adsConfig.clickSignConfig,
								_displayProperties); 
				_regionViews.push(_mouseTrackerRegion);
				addChild(_mouseTrackerRegion);
				setChildIndex(_mouseTrackerRegion, 0);	
			}
						
			// always add the standard defaults

			DEFAULT_REGION = createRegionView(
				new RegionViewConfig(
					{ 
						id: 'reserved-bottom-w100pct-h50px-transparent', 
						verticalAlign: 'bottom', 
						backgroundColor: getBackgroundColor('transparent'),
						width: '100pct', 
						height: 50,
		            	closeButton: this.closeButtonConfig
					}
				)
			);

			if(_config != null) {
				if(_config.hasRegionDefinitions()) {
					// setup the regions
					for(var i:int=0; i < _config.regions.length; i++) {
						createRegionView(_config.regions[i]);
					}
				}
			}				

			// Now create the skip ad button region if required

			if(_vastController.canSkipOnLinearAd()) {
				var skipButtonConfig:RegionViewConfig = null;
				if(_vastController.config.adsConfig.skipAdConfig.isHtmlButton()) {
					skipButtonConfig = new HtmlSkipAdButton(_vastController.config.adsConfig.skipAdConfig);
					CONFIG::debugging { doLog("Skip button is a HTML button", Debuggable.DEBUG_REGION_FORMATION); }					
				}
				else if(_vastController.config.adsConfig.skipAdConfig.isStandardImageButton()) {
					skipButtonConfig = new StandardImageSkipAdButton(_vastController.config.adsConfig.skipAdConfig);
					CONFIG::debugging { doLog("Skip button is a standard image button", Debuggable.DEBUG_REGION_FORMATION); }
				}
				else if(_vastController.config.adsConfig.skipAdConfig.isCustomImageButton()) {
					skipButtonConfig = new LoadableImageSkipAdButton(_vastController.config.adsConfig.skipAdConfig);
					CONFIG::debugging { doLog("Skip button is a custom image button - image is " + _vastController.config.adsConfig.skipAdConfig.image, Debuggable.DEBUG_REGION_FORMATION);	}				
				}
				if(skipButtonConfig != null) {
					CONFIG::debugging { doLog("Have created a region to to house the Linear 'Skip Ad' button", Debuggable.DEBUG_REGION_FORMATION); }
					_skipAdButtonRegion = 
						new SkipAdButtonView(
							this,
							skipButtonConfig,
							_displayProperties,
							_vastController.config.adsConfig.skipAdConfig.width,
							_vastController.config.adsConfig.skipAdConfig.height
						);			
					_regionViews.push(_skipAdButtonRegion);
					addChild(_skipAdButtonRegion);
					setChildIndex(_skipAdButtonRegion, 0);					
				}
			}
			CONFIG::debugging { doLog("Regions created - " + _regionViews.length + " in total", Debuggable.DEBUG_REGION_FORMATION);	}			
		}
	
		public function hideAllOverlays():void {
			if(hasActiveVPAIDMedia()) {
				if(_activeVPAIDMedia.hasActiveOverlay()) {
					hideAllRegionsExceptNamed([ _activeVPAIDMedia.getOverlay() ]);
					return;
				}
			}
			hideAllRegions();
		}		

		public function hideAllAdMessages():void {
			hideAdNotice();
			if(_skipAdButtonRegion != null) {
				_skipAdButtonRegion.hide();
			}	
			disableLinearAdMouseOverRegion();			
		}
		
		public function enableLinearAdMouseOverRegion(adSlot:AdSlot):void {
			CONFIG::debugging { doLog("Enabling linear ad mouse over region", Debuggable.DEBUG_DISPLAY_EVENTS); }
			_mouseTrackerRegion.activeAdSlot = adSlot;
			_mouseTrackerRegion.show();
			_pausingClickForMoreInfoRegion = false;
		}

		public function disableLinearAdMouseOverRegion():void {
			CONFIG::debugging { doLog("Disabling linear ad mouse over region", Debuggable.DEBUG_DISPLAY_EVENTS); }
			_mouseTrackerRegion.activeAdSlot = null;
			_mouseTrackerRegion.hide();
			_pausingClickForMoreInfoRegion = false;
		}
		
		public function pauseLinearAdRegions():void {
			CONFIG::debugging { doLog("Pausing linear ad mouse over region", Debuggable.DEBUG_DISPLAY_EVENTS); }
			if(_mouseTrackerRegion.visible) {
				_mouseTrackerRegion.hide();
				_pausingClickForMoreInfoRegion = true;
			}
			if(_vastController.canSkipOnLinearAd() && _skipAdButtonRegion != null) {
				_skipAdButtonRegion.hide();
			}
			if(_activeAdNotice != null) {
				_activeAdNotice.hide();
			}
		}

		public function resumeLinearAdRegions():void {
			CONFIG::debugging { doLog("Resuming linear ad mouse over region", Debuggable.DEBUG_DISPLAY_EVENTS); }
			if(_pausingClickForMoreInfoRegion) {
				_mouseTrackerRegion.show();
				_pausingClickForMoreInfoRegion = false;		
			}
			if(_vastController.canSkipOnLinearAd() && _skipAdButtonRegion != null) {
				if(_skipAdButtonRegion.active) {
					_skipAdButtonRegion.show();
				}
			}
			if(_activeAdNotice != null) {
				_activeAdNotice.show();
			}
		}
		
		public function hasActiveLinearMouseOverRegion():Boolean {
			return _mouseTrackerRegion.visible;
		}
		
		public function clearOverlay(oid:String):void {
			var overlay:OverlayView = getRegion(oid) as OverlayView;					
			if(overlay != null) {
				CONFIG::debugging { doLog("Hiding region with ID " + oid, Debuggable.DEBUG_DISPLAY_EVENTS); }
				overlay.hide();
				if(_activeVPAIDMedia != null) {
					closeActiveVPAIDMedia();
				}
				else {
					overlay.unloadFlashMedia();				
				}
				overlay.clearActiveAdSlot();
			}				
			else {
				CONFIG::debugging { doLog("Could not find region with ID " + oid + " - hide request ignored", Debuggable.DEBUG_DISPLAY_EVENTS); }	
			}		
		}

		protected function determineNonLinearRegionWidth(requiredWidth:int):int {
			if(_displayProperties != null) {
				if(_displayProperties.displayWidth < requiredWidth) {
					return _displayProperties.displayWidth;
				}
			}
			return requiredWidth;
		}

		protected function determineNonLinearRegionHeight(requiredHeight:int):int {
			if(_displayProperties != null) {
				if(_displayProperties.displayHeight < requiredHeight) {
					return _displayProperties.displayHeight;
				}
			}
			return requiredHeight;
		}

		protected function createAutoRegionForNonLinearAd(overlayAdSlot:AdSlot, nonLinearVideoAd:NonLinearVideoAd, verticalAlignment:String="bottom", overridingCloseButtonConfig:CloseButtonConfig=null):OverlayView {
            var normalWidth:Number = -1;
            var normalHeight:Number = -1;
            var expandedWidth:Number = -1;
            var expandedHeight:Number = -1;
            var margins:String = null;
            
            if(nonLinearVideoAd.isInteractive()) {
            	// it's a VPAID ad so assess if it's expandable etc.
            	normalWidth = nonLinearVideoAd.width;
            	normalHeight = nonLinearVideoAd.height;
            	if(nonLinearVideoAd.isExpandable()) {
            		expandedWidth = nonLinearVideoAd.expandedWidth;
            		expandedHeight = nonLinearVideoAd.expandedHeight;
					CONFIG::debugging { doLog("Overlay will be displayed using an expandable AUTO region (" + normalWidth + "x" + normalHeight + " expanding to " + expandedWidth + "x" + expandedHeight + " - " + verticalAlignment + " alignment)", Debuggable.DEBUG_DISPLAY_EVENTS); }
            	}
            	else {
					CONFIG::debugging { doLog("Overlay will be displayed using an AUTO region (" + normalWidth + "x" + normalHeight + " - " + verticalAlignment + ")", Debuggable.DEBUG_DISPLAY_EVENTS); }
            	}
            }
            else {
	            if(nonLinearVideoAd.activeDisplayRegion.hasSize()) {
	            	normalWidth = nonLinearVideoAd.activeDisplayRegion.width;
	            	normalHeight = nonLinearVideoAd.activeDisplayRegion.height;
	            	CONFIG::debugging { doLog("AUTO region will have a hard coded size - " + normalWidth + "x" + normalHeight, Debuggable.DEBUG_DISPLAY_EVENTS); }
	            }
	            else {
	            	normalWidth = determineNonLinearRegionWidth(nonLinearVideoAd.width);
	            	normalHeight = determineNonLinearRegionHeight(nonLinearVideoAd.height);
					CONFIG::debugging { doLog("Overlay will be displayed using an AUTO region (" + normalWidth + "x" + normalHeight + " - " + verticalAlignment + ")", Debuggable.DEBUG_DISPLAY_EVENTS); }
	            }
	            margins = (nonLinearVideoAd.isText() || nonLinearVideoAd.isHtml()) ? "5 5 5 5" : null;
            }

			return createAutoRegion(
						nonLinearVideoAd.uid, 
			            normalWidth,
			            normalHeight, 
			            verticalAlignment,  
			            overridingCloseButtonConfig,
			            true, 
			            DEFAULT_TEXT_OVERLAY_STYLES,
			            margins,
			            expandedWidth,
			            expandedHeight,
			            nonLinearVideoAd.scale,
			            !nonLinearVideoAd.isInteractive()			                           
			       ) as OverlayView;
		}		
		
		public function displayNonLinearAd(overlayAdDisplayEvent:OverlayAdDisplayEvent):void {
			var adSlot:AdSlot = overlayAdDisplayEvent.adSlot;
			if(adSlot != null) {
				CONFIG::debugging { doLog("Attempting to display overlay ad at ad slot index " + adSlot.key, Debuggable.DEBUG_DISPLAY_EVENTS); }
				var nonLinearVideoAd:NonLinearVideoAd = overlayAdDisplayEvent.nonLinearVideoAd;
				if(nonLinearVideoAd.hasActiveDisplayRegion()) {
					if(nonLinearVideoAd.isInteractive()) {
						CONFIG::debugging { doLog("Oops, this shouldn't happen - OverlayController.displayNonLinearOverlayAd() has a VPAID ad to play - ignoring ad", Debuggable.DEBUG_DISPLAY_EVENTS); }
						return;
					}
					var overlay:OverlayView = null;	
					var regionID:String = overlayAdDisplayEvent.nonLinearVideoAd.getActiveDisplayRegionID();
					if(regionIsAuto(regionID)) {
						overlay = createAutoRegionForNonLinearAd(adSlot, nonLinearVideoAd, getAutoRegionAlignment(regionID));
					}
					else {
						overlay = getRegion(regionID) as OverlayView;
						if(overlay != null) {
							CONFIG::debugging { doLog("Displaying overlay in a 'type' based region '" + overlay.id + "'", Debuggable.DEBUG_DISPLAY_EVENTS);	}									
						}
						else {
							CONFIG::debugging { doLog("Could not get a handle on a region called '" + regionID + "' - creating an auto region", Debuggable.DEBUG_DISPLAY_EVENTS); }
							overlay = createAutoRegionForNonLinearAd(adSlot, nonLinearVideoAd, getAutoRegionAlignment(regionID));
						}
					}
					if(overlay != null) {
						overlay.hide();
						overlay.activeAdSlot = adSlot;
						overlay.autoHide = !overlayAdDisplayEvent.nonLinearVideoAd.activeDisplayRegion.keepVisibleAfterClick;
						overlay.scalable = overlayAdDisplayEvent.nonLinearVideoAd.activeDisplayRegion.enableScaling;
						if(nonLinearVideoAd.isFlash()) {
							overlay.loadFlashMedia(
							        nonLinearVideoAd as FlashMedia, 
									_vastController.config.adsConfig.vpaidConfig,
					                _vastController.config.adsConfig.allowDomains,
	  		                       	(nonLinearVideoAd.hasClickThroughURL() ? true : nonLinearVideoAd.hasAccompanyingVideoAd())
	  		                );						
						}
						else if((nonLinearVideoAd is NonLinearImageAd) && nonLinearVideoAd.scale && overlayAdDisplayEvent.nonLinearVideoAd.activeDisplayRegion.enableScaling) {
							CONFIG::debugging { doLog("Displaying image overlay as scalable sprite - original size is " + nonLinearVideoAd.width + "x" + nonLinearVideoAd.height, Debuggable.DEBUG_DISPLAY_EVENTS); }
							overlay.loadScalableNonLinearImage(
										nonLinearVideoAd as NonLinearImageAd, 
										overlayAdDisplayEvent.nonLinearVideoAd.activeDisplayRegion.hasWidthSpecified() ? overlayAdDisplayEvent.nonLinearVideoAd.activeDisplayRegion.width : _vastController.playerWidth,
										overlayAdDisplayEvent.nonLinearVideoAd.activeDisplayRegion.hasHeightSpecified() ? overlayAdDisplayEvent.nonLinearVideoAd.activeDisplayRegion.height : _vastController.playerHeight,
										overlayAdDisplayEvent.nonLinearVideoAd.activeDisplayRegion.hasSize(),
										_vastController.config.adsConfig.allowDomains
							);
						}
						else {
							CONFIG::debugging { doLog("Displaying " + nonLinearVideoAd.contentType() + " overlay via HTML tags... ", Debuggable.DEBUG_DISPLAY_EVENTS); }
							var html:String = null;
							var content:String = overlayAdDisplayEvent.nonLinearVideoAd.getContent();
							if(nonLinearVideoAd.hasClickThroughURL()) {
								html = "<a href=\"" + nonLinearVideoAd.clickThroughs[0].url + "\" target=\"_blank\">";
								html += content;
								html += "</a>";						
							}
							else html = content;
							overlay.html = html;
						}
						overlay.show();													
					}
					else {
						nonLinearVideoAd.clearActiveDisplayRegion();
						CONFIG::debugging { doLog("Could not create a region to display the non-linear ad", Debuggable.DEBUG_DISPLAY_EVENTS); }	
					}
				}
				else {
					CONFIG::debugging { doLog("Cannot display the non-linear ad - does not have an active region declared", Debuggable.DEBUG_DISPLAY_EVENTS); }
				}
			}
			else {
				CONFIG::debugging { doLog("Cannot show the non linear ad - no ad slot attached to OverlayDisplayEvent", Debuggable.DEBUG_DISPLAY_EVENTS); }
			}
		}

		public function hideNonLinearAd(overlayAdDisplayEvent:OverlayAdDisplayEvent):void {
			var adSlot:AdSlot = overlayAdDisplayEvent.adSlot;
			if(adSlot != null) {
				var nonLinearVideoAd:NonLinearVideoAd = overlayAdDisplayEvent.nonLinearVideoAd;
				var oid:String = overlayAdDisplayEvent.nonLinearVideoAd.getActiveDisplayRegionID();
				if(regionIsAuto(oid)) {
					oid = nonLinearVideoAd.uid;
				}
				clearOverlay(oid);
			}			
		}

		public function showAdNotice(adNoticeDisplayEvent:AdNoticeDisplayEvent):void {
			if(adNoticeDisplayEvent != null) {
				if(adNoticeDisplayEvent.notice.region != undefined) {
					var noticeRegion:RegionView = getRegion(adNoticeDisplayEvent.notice.region);
					if(noticeRegion != null) {
						_activeAdNotice = new AdNotice(adNoticeDisplayEvent.notice.message, adNoticeDisplayEvent.duration, noticeRegion);
						_activeAdNotice.show();			
					}
					else {
						CONFIG::debugging { doLog("Cannot find the region '" + adNoticeDisplayEvent.notice.region + "'"); }
					}
				}				
			}	
		}
		
		public function tickAdNotice(adNoticeDisplayEvent:AdNoticeDisplayEvent):void {
			if(_activeAdNotice == null) {
				showAdNotice(adNoticeDisplayEvent);
			}
			else _activeAdNotice.tickCountdownNotice(adNoticeDisplayEvent.duration);
		}
		
		public function hideAdNotice(adNoticeDisplayEvent:AdNoticeDisplayEvent=null):void {
			if(adNoticeDisplayEvent != null) {
				if(adNoticeDisplayEvent.notice.region != undefined) {
					if(_activeAdNotice != null) {
						_activeAdNotice.hide();
						_activeAdNotice = null;
					}
				}
			}	
			else {
				if(_activeAdNotice != null) {
					_activeAdNotice.hide();
					_activeAdNotice = null;				
				}
			}
		}
						
		// Skip Button
		
		public function activateLinearAdSkipButton(skipButtonDisplayEvent:SkipAdButtonDisplayEvent):void {	
			CONFIG::debugging { doLog("Activating the linear ad skip button housed in region " + skipButtonDisplayEvent.region, Debuggable.DEBUG_DISPLAY_EVENTS); }
			if(_skipAdButtonRegion != null) {
				_skipAdButtonRegion.registerOnClick(skipButtonDisplayEvent.callbackMethod);
				_skipAdButtonRegion.activate();
				setChildIndex(_skipAdButtonRegion, numChildren-1);
			}	
		}

		public function deactivateLinearAdSkipButton(skipButtonDisplayEvent:SkipAdButtonDisplayEvent):void {	
			CONFIG::debugging { doLog("Hiding the linear ad skip button housed in region " + skipButtonDisplayEvent.region, Debuggable.DEBUG_DISPLAY_EVENTS); }
			if(_skipAdButtonRegion != null) {
				_skipAdButtonRegion.deactivate();
			}	
		}
		
		// VPAID ad playback

		public function hasActiveVPAIDAd():Boolean {
			return (_activeVPAIDMedia != null);
		}
		
		public function isVPAIDAdPlaying():Boolean {
			if(_activeVPAIDMedia != null) {
				return _activeVPAIDMedia.isRunning();
			}
			return false;
		}

		public function getActiveVPAIDAd():IVPAID {
			if(_activeVPAIDMedia != null) {
				return _activeVPAIDMedia.getVPAID();
			}
			return null;
		}
		
		public function playVPAIDAd(adSlot:AdSlot, eventCallbackFunctions:Object, muteOnStartup:Boolean=false, playerVolume:Number=-1, reduceVPAIDAdHeightByControlbarHeight:Boolean=false, enableScaling:Boolean=true):void {
			adSlot.markForRefresh();
			if(adSlot.isInteractive()) {
				closeActiveVPAIDAds();
				if(adSlot.isLinear()) {
					playVPAIDMedia(adSlot.getFlashMediaToPlay(displayWidth, displayHeight, true) as VPAIDPlayback, adSlot, eventCallbackFunctions, muteOnStartup, playerVolume, reduceVPAIDAdHeightByControlbarHeight, enableScaling);
				}
				else {
					playVPAIDMedia(adSlot.getNonLinearVideoAd() as VPAIDPlayback, adSlot, eventCallbackFunctions, muteOnStartup, playerVolume, false, enableScaling);				
				}
			}
			else eventCallbackFunctions.onError(new VPAIDEvent(VPAIDEvent.AdError, "Ad is not a VPAID SWF"));
		}
		
		public function pauseActiveVPAIDAd():void {
			if(_activeVPAIDMedia != null) {
				_activeVPAIDMedia.pause();
			}
		}

		public function resumeActiveVPAIDAd():void {
			if(_activeVPAIDMedia != null) {
				_activeVPAIDMedia.resume();
			}
		}

		protected function hasActiveVPAIDMedia():Boolean {
			return (_activeVPAIDMedia != null);	
		}
		
		protected function closeActiveVPAIDMedia():void {
			if(_activeVPAIDMedia != null) {
				_activeVPAIDMedia.unload(); 
				_activeVPAIDMedia = null;
			}
		}
		
		public function closeActiveVPAIDAds():void {
			closeActiveVPAIDMedia();
		}
		
		public function playVPAIDMedia(vpaidMedia:VPAIDPlayback, adSlot:AdSlot,  eventCallbackFunctions:Object, muteOnStartup:Boolean=false, playerVolume:Number=-1, reduceVPAIDAdHeightByBottomMargin:Boolean=false, enableScaling:Boolean=true):void {
			if(vpaidMedia != null) {
				if(adSlot.isNonLinear() && enableScaling == false) {
					// turn off scaling of the media if the config has an overriding setting to turn it off
					CONFIG::debugging { doLog("Turning off VPAID overlay scaling - set as 'false' in the OVA configuration", Debuggable.DEBUG_CONFIG); }
					NonLinearVideoAd(vpaidMedia).scale = false;
				}

				var adIsLinear:Boolean = adSlot.isLinear();
				
				if(hasActiveVPAIDMedia()) {
					closeActiveVPAIDMedia();
				}
				_activeVPAIDMedia = vpaidMedia;
				
				// if a max duration timeout has been requested in the config, set it up
				if(adSlot.config.vpaidMaxDurationTimeoutEnabled()) {
					vpaidMedia.setMaxDurationTimeout(adSlot.config.vpaidMaxDurationTimeout);
					vpaidMedia.enableMaxDurationTimeout();				
				}
				else vpaidMedia.disableMaxDurationTimeout();

				adSlot.clearVPAIDForciblyStoppedFlag();

				// VPAID event handlers				
				
				vpaidMedia.registerStartHandler(
						function(event:VPAIDEvent=null):void { 
							adSlot.actionCompanionAdStart();
							if(eventCallbackFunctions.onStart != undefined) eventCallbackFunctions.onStart(event);
							CONFIG::callbacks {
								if(_vastController != null) _vastController.fireAPICall("onVPAIDAdStart", adSlot.videoAd.toJSObject(), vpaidMedia.toRuntimeStateJSObject());
							}
						}
				);
				vpaidMedia.registerErrorHandler(
						function(error:VPAIDEvent=null):void { 
							if(_activeVPAIDMedia != null) {
								// We have an active VPAID ad so stop it before cleaning up - we set this "forcibly stopped" flag because a stop call on
								// a VPAID ad may result in a COMPLETE event being fired by the Ad which we will have to deal with later in the process
								adSlot.flagVPAIDForciblyStopped();
							}
							clearOverlay(_vastController.config.getLinearVPAIDRegionID()); 
							adSlot.actionCompanionAdEnd();
							if(eventCallbackFunctions.onError != undefined) eventCallbackFunctions.onError(error); 
							CONFIG::callbacks {
								if(_vastController != null) _vastController.fireAPICall("onVPAIDAdError", adSlot.videoAd.toJSObject(), vpaidMedia.toRuntimeStateJSObject(), error);
							}
						}
				);
				vpaidMedia.registerLogHandler(
						function(logEntry:VPAIDEvent=null):void { 
							if(eventCallbackFunctions.onLog != undefined) eventCallbackFunctions.onLog(logEntry); 
							if(_vastController != null) {
								CONFIG::callbacks {
									_vastController.fireAPICall("onVPAIDAdLog", null, ((logEntry != null) ? ((logEntry.data != null) ? logEntry.data.message : null) : null));
//									_vastController.fireAPICall("onVPAIDAdLog", adSlot.videoAd.toJSObject(), vpaidMedia.toRuntimeStateJSObject(), ((logEntry != null) ? ((logEntry.data != null) ? logEntry.data.message : null) : null));
								}
								if(_vastController.config.adsConfig.vpaidConfig.terminateOnLogMessage != null && logEntry != null) {
									// We have a "terminate" triggering log message declared, check if it matches the log message - if so, request closure of the VPAID ad
									if(logEntry.data != null) {
										if(logEntry.data.message == _vastController.config.adsConfig.vpaidConfig.terminateOnLogMessage) {
											CONFIG::debugging { doLog("VPAID AdLog event message (" + logEntry.data.message + ") has triggered termination of the ad - calling vpaid.stopAd()", Debuggable.DEBUG_VPAID); }
											if(vpaidMedia.getVPAID() != null) {
												vpaidMedia.getVPAID().stopAd();
											}
											else {
												CONFIG::debugging { doLog("Unable to get a hande to the VPAID SWF - cannot call vpaid.stopAd()", Debuggable.DEBUG_VPAID); }
											}
										}
									}
								}
							}
						}
				);
				vpaidMedia.registerCompleteHandler(
						function(event:VPAIDEvent=null):void { 
							CONFIG::callbacks {
								if(_vastController != null) _vastController.fireAPICall("onVPAIDAdComplete", adSlot.videoAd.toJSObject(), vpaidMedia.toRuntimeStateJSObject());
							}
							clearOverlay(_vastController.config.getLinearVPAIDRegionID());
							adSlot.actionCompanionAdEnd();
							if(eventCallbackFunctions.onComplete != undefined) eventCallbackFunctions.onComplete(event); 
						}
				);
				vpaidMedia.registerExpandedChangeHandler(
						function(event:VPAIDEvent=null):void {
							if(event != null) {
								if(_activeVPAIDMedia != null) {
									if(_activeVPAIDMedia.getOverlay() != null) {
										if(adIsLinear) {
											if(event.data is Object) {
												if(event.data.expanded == false && event.data.linearPlayback == false) {
													_activeVPAIDMedia.getOverlay().minimize(); 
												}
												else {
													_activeVPAIDMedia.getOverlay().restore(); 
												}
											}						
										} 
										else if(NonLinearVideoAd(_activeVPAIDMedia).isExpandable()) {
											// The ad is not expanded, so make sure the active overlay is transparent
											if(event.data is Object) {
												if(event.data.expanded) {
													_activeVPAIDMedia.getOverlay().expand();
												}
												else {
													_activeVPAIDMedia.getOverlay().contract();													
												}
											}
										}
									}									
								}
							}
							if(eventCallbackFunctions.onExpandedChange != undefined) eventCallbackFunctions.onExpandedChange(event);
							CONFIG::callbacks {
								if(_vastController != null) _vastController.fireAPICall("onVPAIDAdExpandedChange", adSlot.videoAd.toJSObject(), vpaidMedia.toRuntimeStateJSObject());
							}
						}
				);
				vpaidMedia.registerLinearChangeHandler(
						function(event:VPAIDEvent=null):void {
							if(eventCallbackFunctions.onLinearChange != undefined) eventCallbackFunctions.onLinearChange(event);
							CONFIG::callbacks {
								if(_vastController != null) _vastController.fireAPICall("onVPAIDAdLinearChange", adSlot.videoAd.toJSObject(), vpaidMedia.toRuntimeStateJSObject());
							}
						}
				);
				vpaidMedia.registerRemainingTimeChangeHandler(
						function(event:VPAIDEvent=null):void {
							if(eventCallbackFunctions.onRemainingTimeChange != undefined) eventCallbackFunctions.onRemainingTimeChange(event);
							CONFIG::callbacks {
								if(_vastController != null) {
									_vastController.fireAPICall(
										"onVPAIDAdRemainingTimeChange",
										adSlot.videoAd.toJSObject(),
										vpaidMedia.toRuntimeStateJSObject()  
									);
								}
							}
						}
				);
				vpaidMedia.registerVolumeChangeHandler(
						function(event:VPAIDEvent=null):void {
							if(eventCallbackFunctions.onVolumeChange != undefined) eventCallbackFunctions.onVolumeChange(event);
							CONFIG::callbacks {
								if(_vastController != null) {
									_vastController.fireAPICall(
										"onVPAIDAdVolumeChange",
										adSlot.videoAd.toJSObject(),
										vpaidMedia.toRuntimeStateJSObject()  
									);
								}
							}
						}
				);
				vpaidMedia.registerClickThruHandler(
						function(event:VPAIDEvent=null):void {
							if(eventCallbackFunctions.onClickThru != undefined) eventCallbackFunctions.onClickThru(event);
						}
				);
				vpaidMedia.registerCloseHandler(
						function(event:VPAIDEvent=null):void {
							if(eventCallbackFunctions.onUserClose != undefined) eventCallbackFunctions.onUserClose(event);
						}
				);
				vpaidMedia.registerImpressionHandler(
						function(event:VPAIDEvent=null):void {
							if(eventCallbackFunctions.onImpression != undefined) eventCallbackFunctions.onImpression(event);
						}
				);
				vpaidMedia.registerLoadedHandler(
						function(event:VPAIDEvent=null):void {
							if(eventCallbackFunctions.onLoaded != undefined) eventCallbackFunctions.onLoaded(event);
						}
				);
				vpaidMedia.registerMinimizeHandler(
						function(event:VPAIDEvent=null):void {
							if(eventCallbackFunctions.userMinimize != undefined) eventCallbackFunctions.onUserMinimize(event);
						}
				);
				vpaidMedia.registerUserAcceptInvitationHandler(
						function(event:VPAIDEvent=null):void {
							if(eventCallbackFunctions.onUserAcceptInvitation != undefined) eventCallbackFunctions.onUserAcceptInvitation(event);
						}
				);
				vpaidMedia.registerVideoStartHandler(
						function(event:VPAIDEvent=null):void {
							if(eventCallbackFunctions.onVideoAdStart != undefined) eventCallbackFunctions.onVideoAdStart(event);
						}
				);
				vpaidMedia.registerVideoFirstQuartileHandler(
						function(event:VPAIDEvent=null):void {
							if(eventCallbackFunctions.onVideoAdFirstQuartile != undefined) eventCallbackFunctions.onVideoAdFirstQuartile(event);
						}
				);
				vpaidMedia.registerVideoMidpointHandler(
						function(event:VPAIDEvent=null):void {
							if(eventCallbackFunctions.onVideoAdMidpoint != undefined) eventCallbackFunctions.onVideoAdMidpoint(event);
						}
				);
				vpaidMedia.registerVideoThirdQuartileHandler(
						function(event:VPAIDEvent=null):void {
							if(eventCallbackFunctions.onVideoAdThirdQuartile != undefined) eventCallbackFunctions.onVideoAdThirdQuartile(event);
						}
				);
				vpaidMedia.registerVideoCompleteHandler(				
						function(event:VPAIDEvent=null):void {
							if(eventCallbackFunctions.onVideoAdComplete != undefined) eventCallbackFunctions.onVideoAdComplete(event);
						}
				);
				vpaidMedia.registerAdSkippedHandler(
						function(event:VPAIDEvent=null):void {
							if(eventCallbackFunctions.onSkipped != undefined) eventCallbackFunctions.onSkipped(event);
						}
				);
				vpaidMedia.registerAdSkippableStateChangeHandler(
						function(event:VPAIDEvent=null):void {
							if(eventCallbackFunctions.onSkippableStateChange != undefined) eventCallbackFunctions.onSkippableStateChange(event);
						}
				);
				vpaidMedia.registerAdSizeChangeHandler(
						function(event:VPAIDEvent=null):void {
							if(eventCallbackFunctions.onSizeChange != undefined) eventCallbackFunctions.onSizeChange(event);
						}
				);
				vpaidMedia.registerAdDurationChangeHandler(
						function(event:VPAIDEvent=null):void {
							if(eventCallbackFunctions.onDurationChange != undefined) eventCallbackFunctions.onDurationChange(event);
						}
				);
				vpaidMedia.registerAdInteractionHandler(
						function(event:VPAIDEvent=null):void {
							if(eventCallbackFunctions.onAdInteraction != undefined) eventCallbackFunctions.onAdInteraction(event);
						}
				);
				vpaidMedia.registerExternalAPICallHandler(
				        function(event:VPAIDEvent=null):void {
							CONFIG::callbacks {
								if(_vastController != null && event != null) {
									_vastController.fireAPICall(
										"onVPAID" + event.type,
										adSlot.videoAd.toJSObject(),
										(event.data != null) ? event.data : vpaidMedia.toRuntimeStateJSObject()
									);
								}				        	
							}
				        }
				);

				// ok, load up the VPAID ad and display
				
				if(adIsLinear) {
					CONFIG::debugging { doLog("Linear VPAID ad using region '" + _vastController.config.getLinearVPAIDRegionID() + "'", Debuggable.DEBUG_VPAID); }
					_activeVPAIDMedia.setOverlay(getRegion(_vastController.config.getLinearVPAIDRegionID()) as OverlayView);
				}
				else {
					if(NonLinearVideoAd(vpaidMedia).isExpandable()) {
						CONFIG::debugging { doLog("Expandable Non Linear VPAID ad using region '" + _vastController.config.getNonLinearVPAIDRegionID() + "'", Debuggable.DEBUG_VPAID); }
						_activeVPAIDMedia.setOverlay(
							createAutoRegionForNonLinearAd(adSlot, NonLinearVideoAd(vpaidMedia), "bottom", new CloseButtonConfig({ "enabled": false })) 
						);
					}
					else {
						CONFIG::debugging { doLog("Non expandable Non Linear VPAID ad using region '" + _vastController.config.getNonLinearVPAIDRegionID() + "'", Debuggable.DEBUG_VPAID); }
						_activeVPAIDMedia.setOverlay(
							getRegion(_vastController.config.getNonLinearVPAIDRegionID()) as OverlayView
						);
					}
				}
				if(_activeVPAIDMedia.getOverlay() != null) {
					if(eventCallbackFunctions.onLoading != undefined) eventCallbackFunctions.onLoading();
					this.setChildIndex(_activeVPAIDMedia.getOverlay(), this.numChildren-1);
					_activeVPAIDMedia.getOverlay().activeAdSlot = adSlot;
					_activeVPAIDMedia.getOverlay().loadFlashMedia(vpaidMedia as FlashMedia, _vastController.config.adsConfig.vpaidConfig, _vastController.config.adsConfig.allowDomains, false, muteOnStartup, reduceVPAIDAdHeightByBottomMargin, adIsLinear, playerVolume);
				}
				else {
					if(eventCallbackFunctions.onError != undefined) eventCallbackFunctions.onError(new VPAIDEvent(VPAIDEvent.AdError, "Could not create the overlay region"));
				}
			}
			else {
				if(eventCallbackFunctions.onError != undefined) eventCallbackFunctions.onError(new VPAIDEvent(VPAIDEvent.AdError, "Could not find a suitable Flash Ad in this Ad Slot"));
			}			
		}

		// Mouse events
		
		public override function onRegionCloseClicked(regionView:RegionView):void {
			_vastController.onOverlayCloseClicked(regionView as OverlayView);
		}
		
		public override function onRegionClicked(regionView:RegionView, originalMouseEvent:MouseEvent):void {
			_vastController.onOverlayClicked(regionView as OverlayView, originalMouseEvent);
		}	
		
		public function onLinearAdClickThroughCallToActionViewClicked(adSlot:AdSlot):void { 
			_vastController.onLinearAdClickThroughCallToActionViewClicked(adSlot);
		}		
	}
}
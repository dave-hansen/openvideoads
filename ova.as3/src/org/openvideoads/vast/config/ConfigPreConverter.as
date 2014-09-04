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
package org.openvideoads.vast.config {
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.util.StringUtils;
	import org.openvideoads.vast.schedule.ads.templates.*;
	
	/**
	 * @author Paul Schulz
	 */
	public class ConfigPreConverter {

        public static function convert(config:Object):Object {
			var result:Object = expandConfig(convertPreV1Config(config));
        	return result;
        }
        	
        public static function convertPreV1Config(config:Object):Object {
        	if(true) { // used in development to turn off this conversion and permit modification of OVA master settings
	        	if(config.hasOwnProperty("analytics")) {
	        		if(config.analytics.hasOwnProperty("google")) {
		        		// Make sure that the OVA master option is no longer being used to disable/change analytics reporting
		        		if(config.analytics.google.hasOwnProperty("enable")) {
		        			if(config.analytics.google.enable == false) {
		        				// Trying to disable analytics - only permit this option to impact the custom settings, not the master ones
		        				if(config.analytics.google.hasOwnProperty("custom")) {
		        					config.analytics.google.custom.enable = false;
		        				}
		        			}
		        			delete config.analytics.google.enable;
		        		}
		        		if(config.analytics.google.hasOwnProperty("ova")) {
		        			delete config.analytics.google.ova;
		        		}
	        		}
	        	}
        	}
			if(config.hasOwnProperty("overlays")) {
				// Handles change from 'overlays.closeButton' to 'regions.closeButton'
				if(config.overlays.hasOwnProperty("closeButton")) {
					CONFIG::debugging { Debuggable.getInstance().doLog("Have converted the depreciated option 'overlays.controlButton' to 'regions.controlButton'", Debuggable.DEBUG_CONFIG); }
					if(config.hasOwnProperty("regions")) {
						config.regions.closeButton = config.overlays.closeButton;
					}
					else config.regions = { closeButton: config.overlays.closeButton };
				}
				
  			    // Handles the change from 'overlays.regions' to 'regions.declarations'
				if(config.overlays.hasOwnProperty("regions")) {
					CONFIG::debugging { Debuggable.getInstance().doLog("Have converted depreciated option 'overlays.region' to 'regions.declarations'", Debuggable.DEBUG_CONFIG); }
					config.regions = { "declarations": config.overlays.regions };			
				}

   				// Handles the change from 'overlays.stagePaddingBottomNoControls' to 'player.margins.withoutControls'
				if(config.overlays.hasOwnProperty("stagePaddingBottomNoControls")) {
					if(config.hasOwnProperty("player")) {
						if(config.player.hasOwnProperty("margins")) {
							config.player.margins.withoutControls = config.overlays.stagePaddingBottomNoControls;
							config.player.margins.withoutControlsOverride = config.overlays.stagePaddingBottomNoControls;
						}	
						else {
							config.player.margins = { 
								withoutControls: config.overlays.stagePaddingBottomNoControls,
								withoutControlsOverride: config.overlays.stagePaddingBottomNoControls								
							};
						}					
					}
					else {
						config.player = { 
							margins: { 
								withoutControls: config.overlays.stagePaddingBottomNoControls,
								withoutControlsOverride: config.overlays.stagePaddingBottomNoControls								
							}
						};
					}
				}

				// Handles the change from 'overlays.stagePaddingBottomWithControls' to 'player.margins.withControls'
				if(config.overlays.hasOwnProperty("stagePaddingBottomWithControls")) {
					if(config.hasOwnProperty("player")) {
						if(config.player.hasOwnProperty("margins")) {
							config.player.margins.withControls = config.overlays.stagePaddingBottomWithControls;
							config.player.margins.withControlsOverride = config.overlays.stagePaddingBottomWithControls;
						}	
						else {
							config.player.margins = { 
								withControls: config.overlays.stagePaddingBottomWithControls,
								withControlsOverride: config.overlays.stagePaddingBottomWithControls								
							};
						}					
					}
					else {
						config.player = { 
							margins: { 
								withControls: config.overlays.stagePaddingBottomWithControls,
								withControlsOverride: config.overlays.stagePaddingBottomWithControls								
							}
						};
					}
				}				
			}		

			if(config.hasOwnProperty("ads")) {
				// Handles the change from 'ads.replayNonLinearAds' to 'overlays.replay'
				if(config.ads.hasOwnProperty("replayNonLinearAds")) {
					CONFIG::debugging { Debuggable.getInstance().doLog("Have converted depreciated 'ads.replayNonLinearAds' to 'ads.overlays.replay'", Debuggable.DEBUG_CONFIG); }
					if(config.ads.hasOwnProperty("overlays")) {
						config.ads.overlays.replay = config.ads.replayNonLinearAds;
					}
					else config.ads.overlays = { replay: config.ads.replayNonLinearAds };
				}

				// Handles the change from 'ads.acceptedNonLinearAdMimeTypes' to 'overlays.acceptedMimeTypes'
				if(config.ads.hasOwnProperty("acceptedNonLinearAdMimeTypes")) {
					CONFIG::debugging { Debuggable.getInstance().doLog("Have converted depreciated 'ads.acceptedNonLinearAdMimeTypes' to 'ads.overlays.acceptedMimeTypes'", Debuggable.DEBUG_CONFIG); }
					if(config.ads.hasOwnProperty("overlays")) {
						config.ads.overlays.acceptedMimeTypes = config.ads.acceptedNonLinearAdMimeTypes;
					}
					else config.ads.overlays = { acceptedMimeTypes: config.ads.acceptedNonLinearAdMimeTypes };
				}

				// Handles the change from 'ads.enableOverlayScaling' to 'overlays.enableScaling'
				if(config.ads.hasOwnProperty("enableOverlayScaling")) {
					CONFIG::debugging { Debuggable.getInstance().doLog("Have converted depreciated 'ads.enableOverlayScaling' to 'ads.overlays.enableScaling'", Debuggable.DEBUG_CONFIG); }
					if(config.ads.hasOwnProperty("overlays")) {
						config.ads.overlays.enableScaling = config.ads.enableOverlayScaling;
					}
					else config.ads.overlays = { enableScaling: config.ads.enableOverlayScaling };
				}

				// Handles the change from 'ads.enforceOverlayRecommendedSizing' to 'overlays.enforceRecommendedSizing'
				if(config.ads.hasOwnProperty("enforceOverlayRecommendedSizing")) {
					CONFIG::debugging { Debuggable.getInstance().doLog("Have converted depreciated 'ads.enforceOverlayRecommendedSizing' to 'ads.overlays.enforceRecommendedSizing'", Debuggable.DEBUG_CONFIG); }
					if(config.ads.hasOwnProperty("overlays")) {
						config.ads.overlays.enforceRecommendedSizing = config.ads.enforceOverlayRecommendedSizing;
					}
					else config.ads.overlays = { enforceRecommendedSizing: config.ads.enforceOverlayRecommendedSizing };
				}

				// Handles the change from 'ads.keepOverlayVisibleAfterClick' to 'ads.overlays.keepVisibleAfterClick'
				if(config.ads.hasOwnProperty("keepOverlayVisibleAfterClick")) {
					CONFIG::debugging { Debuggable.getInstance().doLog("Have converted depreciated 'ads.keepOverlayVisibleAfterClick' to 'ads.overlays.keepVisibleAfterClick'", Debuggable.DEBUG_CONFIG); }
					if(config.ads.hasOwnProperty("overlays")) {
						config.ads.overlays.keepVisibleAfterClick = config.ads.keepOverlayVisibleAfterClick;
					}
					else config.ads.overlays = { keepVisibleAfterClick: config.ads.keepOverlayVisibleAfterClick };
				}
				// Handles the change from 'ads.companions[]' to 'ads.companions.regions'
				if(config.ads.hasOwnProperty("companions")) {
					if(config.ads.companions is Array) {
						CONFIG::debugging { Debuggable.getInstance().doLog("Have converted the depreciated option 'ads.companions[]' to 'ads.companions.regions'", Debuggable.DEBUG_CONFIG); }
						config.ads.companions = { regions: config.ads.companions }						
					}
				}
				
				// Handles the change from 'ads.processCompanionsExternally' to 'ads.companions.processExternally'
				if(config.ads.hasOwnProperty("processCompanionsExternally")) {
					if(config.ads.hasOwnProperty("companions")) {
						CONFIG::debugging { Debuggable.getInstance().doLog("Have converted the depreciated option 'ads.processCompanionsExternally' to 'ads.companions.html5'", Debuggable.DEBUG_CONFIG); }
						config.ads.companions.html5 = config.ads.processCompanionsExternally;
					}
				}
				
				// Handles the change from 'ads.millisecondDelayOnCompanionInjection' to 'ads.companions.millisecondDelayOnInjection'
				if(config.ads.hasOwnProperty("millisecondDelayOnCompanionInjection")) {
					if(config.ads.hasOwnProperty("companions")) {
						CONFIG::debugging { Debuggable.getInstance().doLog("Have converted the depreciated option 'ads.millisecondDelayOnCompanionInjection' to 'ads.companions.millisecondDelayOnInjection'", Debuggable.DEBUG_CONFIG); }
						config.ads.companions.millisecondDelayOnInjection = config.ads.millisecondDelayOnCompanionInjection;
					}
				}

				// Handles the change from 'ads.displayCompanions' to 'ads.companions.enable'
				if(config.ads.hasOwnProperty("displayCompanions")) {
					if(config.ads.hasOwnProperty("companions")) {
						CONFIG::debugging { Debuggable.getInstance().doLog("Have converted the depreciated option 'ads.displayCompanions' to 'ads.companions.enable'", Debuggable.DEBUG_CONFIG); }
						config.ads.companions.enable = config.ads.displayCompanions;
					}
				}

				// Handles the change from 'ads.restoreCompanions' to 'ads.companions.restore'
				if(config.ads.hasOwnProperty("restoreCompanions")) {
					if(config.ads.hasOwnProperty("companions")) {
						CONFIG::debugging { Debuggable.getInstance().doLog("Have converted the depreciated option 'ads.restoreCompanions' to 'ads.companions.restore'", Debuggable.DEBUG_CONFIG); }
						config.ads.companions.restore = config.ads.restoreCompanions;
					}
				}
								
				// Handles the change from 'ads.additionalParamsForSWFCompanions' to 'ads.companions.additionalParamsForSWFCompanions'
				if(config.ads.hasOwnProperty("additionalParamsForSWFCompanions")) {
					if(config.ads.hasOwnProperty("companions")) {
						CONFIG::debugging { Debuggable.getInstance().doLog("Have converted the depreciated option 'ads.additionalParamsForSWFCompanions' to 'ads.companions.additionalParamsForSWFCompanions'", Debuggable.DEBUG_CONFIG); }
						config.ads.companions.additionalParamsForSWFCompanions = config.ads.additionalParamsForSWFCompanions;
					}
				}
				
				if(config.ads.hasOwnProperty("controls")) {
   				    // Handles the change from 'ads.controls.skipAd' to 'ads.skipAd' option
					if(config.ads.controls.hasOwnProperty("skipAd")) {
						CONFIG::debugging { Debuggable.getInstance().doLog("Have moved depreciated option 'ads.controls.skipAd' to 'ads.skipAd'", Debuggable.DEBUG_CONFIG);	}						
						config.ads.skipAd = config.ads.controls.skipAd;
					}
					else {
						// Handles the change from 'ads.controls' to 'player.modes.linear.controls'
						CONFIG::debugging { Debuggable.getInstance().doLog("Have moved depreciated option 'ads.controls' to 'player.modes.linear.controls'", Debuggable.DEBUG_CONFIG); }
						if(config.hasOwnProperty("player") == false) {
							config.player = { modes: { linear: { controls: config.ads.controls } } };
						}
						else {
							if(config.player.hasOwnProperty("modes") == false) {
								config.player.modes = { linear: { controls: config.ads.controls } }; 								
							}
							else {
								if(config.player.modes.hasOwnProperty("linear") == false) {
									config.player.modes.linear = { controls: config.ads.controls }; 								
								}									
								else {
									if(config.player.modes.linear.hasOwnProperty("controls") == false) {
										config.player.modes.linear.controls = config.ads.controls;
									}									
									else {
										for(var prop:String in config.ads.controls) {
											if(prop == "skipAd") {
												CONFIG::debugging { Debuggable.getInstance().doLog("Have moved depreciated option 'ads.controls.skipAd' to 'ads.skipAd'", Debuggable.DEBUG_CONFIG); }
												config.ads.skipAd = prop;
											}
											else config.player.modes.linear.controls[prop] = config.ads.controls[prop];
										}
									}
								}
							}
						}
					}
				}					
				else if(config.ads.hasOwnProperty("vpaid")) {
					if(config.ads.vpaid.hasOwnProperty("controls")) {
					    // Handles the change from 'ads.vpaid.controls.hideOnLinearPlayback' to 'player.modes.linear.controls.vpaid.hide'							
						if(config.ads.vpaid.controls.hasOwnProperty("hideOnLinearPlayback")) {
							CONFIG::debugging { Debuggable.getInstance().doLog("Have converted depreciated option 'ads.vpaid.controls.hideOnLinearPlayback' to 'player.modes.linear.controls.vpaid.visible'", Debuggable.DEBUG_CONFIG); }
							if(config.hasOwnProperty("player") == false) {
								config.player = { modes: { linear: { controls: { vpaid: { visible: !config.ads.vpaid.controls.hideOnLinearPlayback } } } } }; 
							}
							else {
								if(config.player.hasOwnProperty("modes") == false) {
									config.player.modes = { linear: { controls: { vpaid: { visible: !config.ads.vpaid.controls.hideOnLinearPlayback } } } }; 								
								}
								else {
									if(config.player.modes.hasOwnProperty("linear") == false) {
										config.player.modes.linear = { controls: { vpaid: { visible: !config.ads.vpaid.controls.hideOnLinearPlayback } } }; 								
									}									
									else {
										if(config.player.modes.linear.hasOwnProperty("controls") == false) {
											config.player.modes.linear.controls = { vpaid: { visible: !config.ads.vpaid.controls.hideOnLinearPlayback } }; 								
										}									
										else {
											if(config.player.modes.linear.controls.hasOwnProperty("vpaid") == false) {
												config.player.modes.linear.controls.vpaid = { visible: !config.ads.vpaid.controls.hideOnLinearPlayback }; 								
											}									
											else {
												config.player.modes.linear.controls.vpaid.visible = !config.ads.vpaid.controls.hideOnLinearPlayback;
											}
										}
									}
								}
							}
						}
					}
				}

 			    // Handles the change from 'ads.disableControls' to 'player.modes.linear.controls.enable'
				if(config.ads.hasOwnProperty("disableControls")) {
					CONFIG::debugging { Debuggable.getInstance().doLog("Have moved depreciated 'ads.disableControls' to 'player.modes.linear.controls.enable'", Debuggable.DEBUG_CONFIG); }
					if(config.hasOwnProperty("player") == false) {
						config.player = { modes: { linear: { controls: { enable: !config.ads.disableControls } } } };
					}
					else {
						if(config.player.hasOwnProperty("modes") == false) {
							config.player.modes = { linear: { controls: { enable: !config.ads.disableControls } } }; 								
						}
						else {
							if(config.player.modes.hasOwnProperty("linear") == false) {
								config.player.modes.linear = { controls: { enable: !config.ads.disableControls } }; 								
							}									
							else {
								if(config.player.modes.linear.hasOwnProperty("controls") == false) {
									config.player.modes.linear.controls = { enable: !config.ads.disableControls };
								}									
								else {
									if(config.player.modes.linear.hasOwnProperty("enable") == false) {
										config.player.modes.linear.controls.enable = !config.ads.disableControls;
									}									
								}
							}
						}
					}
				}
				
				if(config.ads.hasOwnProperty("schedule")) {
					if(config.ads.schedule is Array) {
						for(var i:int=0; i < config.ads.schedule.length; i++) {
							// converts ads.schedule[i].position to ads.schedule[i].region if non-linear position
							if(config.ads.schedule[i].hasOwnProperty("position")) {
								if(config.ads.schedule[i].position is String) {
									if(StringUtils.containsIgnoreCase("PRE-ROLL MID-ROLL POST-ROLL", config.ads.schedule[i].position) == false) {
										CONFIG::debugging { Debuggable.getInstance().doLog("Have converted depreciated non-linear option 'ads.schedule[].position' to 'ads.schedule[].region'", Debuggable.DEBUG_CONFIG); }
										config.ads.schedule[i].region = config.ads.schedule[i].position;
										delete config.ads.schedule[i].position;
									}
								}
							}		
						}
					}
				}
			}
			return config;        	
        }
        
        protected static function createRegionObject(settings:Object):Object {
        	if(settings is String) {
	        	return {
					"image": settings,
					"text": settings,
					"html": settings,
					"swf": settings,
					"vpaid": settings,
					"iframe": settings,
					"script": settings
				};        		
        	}
        	else {
        		var defaultObject:Object = {
					"image": "auto:bottom",
					"text": "auto:bottom",
					"html": "auto:bottom",
					"swf": "auto:bottom",
					"vpaid": "auto:bottom",
					"iframe": "auto:bottom",
					"script": "auto:bottom"
        		};
        		
        		if(settings != null) {
	        		for(var prop:String in settings) {
	        			defaultObject[prop] = settings[prop];
	        		}
        		}
        		
        		return defaultObject;
        	}
        }
        
        protected static function createTemplatesObject(displayMode:String, settings:Object=null):Object {
        	var result:Object = {
				text: new TextAdTemplate(displayMode),
				html: new HtmlAdTemplate(displayMode),
				image: new ImageAdTemplate(displayMode),
				swf: new FlashAdTemplate(displayMode),
				script: new ScriptAdTemplate(displayMode),
				iframe: new IFrameAdTemplate(displayMode),
				vpaid: null						
        	};
        	if(settings != null) {
        		for(var prop:String in settings) {
					if(StringUtils.matchesIgnoreCase(prop, "text")) {
						result[prop] = new TextAdTemplate(displayMode, settings[prop]);
					}	
					else if(StringUtils.matchesIgnoreCase(prop, "html")) {
						result[prop] = new HtmlAdTemplate(displayMode, settings[prop]);
					}	
					else if(StringUtils.matchesIgnoreCase(prop, "image")) {
						result[prop] = new ImageAdTemplate(displayMode, settings[prop]);
					}	
					else if(StringUtils.matchesIgnoreCase(prop, "swf")) {
						result[prop] = new FlashAdTemplate(displayMode, settings[prop]);
					}	
					else if(StringUtils.matchesIgnoreCase(prop, "script")) {
						result[prop] = new ScriptAdTemplate(displayMode, settings[prop]);
					}	
					else if(StringUtils.matchesIgnoreCase(prop, "iframe")) {
						result[prop] = new IFrameAdTemplate(displayMode, settings[prop]);
					}	
        		}
        	}
        	return result;
        }
        
        public static function expandConfig(config:Object):Object {
        	if(config.hasOwnProperty("ads")) {
        		var overlaysConfig:Object = (config.ads.hasOwnProperty("overlays") ? config.ads.overlays : new Object());
        		if(overlaysConfig.hasOwnProperty("regions") == false) {
        			if(overlaysConfig.hasOwnProperty("region")) {
	        			overlaysConfig.regions = 
    	    				{
    	    					"preferred": "flash",
	    	    				"flash": [
	        						{
	        							"enable": true,
	        							"region": overlaysConfig.region
	        						}
	        					],
    	    					"html5": [
        							{
	        							"enable": false,
	        							"region": overlaysConfig.region
        							}
        						]
        					};
        				delete overlaysConfig.region;
        			}
        			else {
	        			overlaysConfig.regions = 
    	    				{
    	    					"preferred": "flash",
	    	    				"flash": [
	        						{
	        							"enable": true
	        						}
	        					],
    	    					"html5": [
        							{
	        							"enable": false
        							}
        						]
        					};
        			}
        		}
        		else {
        			if(overlaysConfig.regions.hasOwnProperty("preferred") == false) {
        				overlaysConfig.regions.preferred = "flash";
        			}
        			if(overlaysConfig.regions.hasOwnProperty("flash") == false) {
        				overlaysConfig.regions.flash = [ { "enable": true } ];
        			}
        			else {
        				// check if it is just the boolean value enabling - if so, expand it out
        				if((overlaysConfig.regions.flash is String) || (overlaysConfig.regions.flash is Boolean)) {
        					overlaysConfig.regions.flash = [ 
        						{ 
        							"enable": StringUtils.validateAsBoolean(overlaysConfig.regions.flash) 
        						} 
        					];
        				}
        				else if(overlaysConfig.regions.flash is Array) {
        					// don't need to do anything with it
        				}
        			}
        			if(overlaysConfig.regions.hasOwnProperty("html5") == false) {
        				overlaysConfig.regions.html5 = [ { "enable": false } ];
        			}
        			else {
        				// check if it is just the boolean value enabling - if so, expand it out
        				if((overlaysConfig.regions.html5 is Array) == false) {
        					overlaysConfig.regions.html5 = [ { "enable": StringUtils.validateAsBoolean(overlaysConfig.regions.html5) } ];
        				}
        			}
        		}

        		if(config.ads.hasOwnProperty("schedule")) {
        			if(config.ads.schedule is Array) {
						for(var i:int=0; i < config.ads.schedule.length; i++) {
			        		if(config.ads.schedule[i].hasOwnProperty("startTime")) {
			        			// It's a non-linear ad, so expand if necessary

				        		if(config.ads.schedule[i].hasOwnProperty("regions") == false) {
				        			if(config.ads.schedule[i].hasOwnProperty("region")) {
				        				config.ads.schedule[i].regions = 
				    	    				{
				    	    					"preferred": overlaysConfig.regions.preferred,
					    	    				"flash": [
					        						{
					        							"enable": overlaysConfig.regions.flash[0].enable,
					        							"region": config.ads.schedule[i].region,
					        							"overlay": true
					        						}
					        					],
				    	    					"html5": [
				        							{
					        							"enable": overlaysConfig.regions.html5[0].enable,
					        							"region": config.ads.schedule[i].region,
					        							"overlay": true
				        							}
				        						]
				        					};
				        			}
			        				else config.ads.schedule[i].regions = overlaysConfig.regions;
				        		}
			        			if(config.ads.schedule[i].regions.hasOwnProperty("preferred") == false) {
			        				config.ads.schedule[i].regions.preferred = "flash";
			        			}
			        			if(config.ads.schedule[i].regions.hasOwnProperty("flash") == false) {
				        			if(config.ads.schedule[i].hasOwnProperty("region")) {
				        				config.ads.schedule[i].regions.flash = [ 
				        					{
			        							"enable": overlaysConfig.regions.flash[0].enable,
				        						"region": config.ads.schedule[i].region,
			        							"overlay": true
				        					} 
				        				];
				        			}
				        			else {
				        				config.ads.schedule[i].regions.flash = [ 
				        					{
			        							"enable": overlaysConfig.regions.flash[0].enable,
			        							"overlay": true
				        					} 
				        				];
				        			}
			        			}
				        		else {
				        			// we have a "regions" setting - check if it is the full array value or just a boolean enabling - expand if boolean
			        				if((config.ads.schedule[i].regions.flash is Array) == false) {
			        					config.ads.schedule[i].regions.flash = [ 
			        						{ 
			        							"enable": StringUtils.validateAsBoolean(config.ads.schedule[i].regions.flash),
			        							"overlay": true
			        						} 
			        					];
			        				}
				        		}
			        			if(config.ads.schedule[i].regions.hasOwnProperty("html5") == false) {
				        			if(config.ads.schedule[i].hasOwnProperty("region")) {
					        			config.ads.schedule[i].regions.html5 = [ 
					        				{
			        							"enable": overlaysConfig.regions.html5[0].enable,
					        					"region": config.ads.schedule[i].region,
			        							"overlay": true
					        				} 
					        			];
					        		}
					        		else {
					        			config.ads.schedule[i].regions.html5 = [ 
					        				{
			        							"enable": overlaysConfig.regions.html5[0].enable,
			        							"overlay": true
					        				} 
					        			];
				        			}
				        		}
				        		else {
				        			// we have a "regions" setting - check if it is the full array value or just a boolean enabling - expand if boolean
			        				if((config.ads.schedule[i].regions.html5 is Array) == false) {
			        					config.ads.schedule[i].regions.html5 = [ 
			        						{ 
			        							"enable": StringUtils.validateAsBoolean(config.ads.schedule[i].regions.html5),
			        							"overlay": true
			        						} 
			        					];
			        				}
				        		}

				        		// Now expand out the individual ad slot declarations into the final long form format
				        		var displayMode:String = "flash";
				        		for(var j:int=0; j < 2; j++) {
				        			for(var k:int=0; k < config.ads.schedule[i].regions[displayMode].length; k++) {
						        		if(config.ads.schedule[i].regions[displayMode][k].hasOwnProperty("region")) {
											config.ads.schedule[i].regions[displayMode][k].region = createRegionObject(config.ads.schedule[i].regions[displayMode][k].region);
						        		}
						        		else {
						        			if(config.ads.schedule[i].regions.hasOwnProperty("region")) {
								        		if(config.ads.schedule[i].hasOwnProperty("region")) {
													config.ads.schedule[i].regions[displayMode][k].region = createRegionObject(config.ads.schedule[i].region);
								        		}						        				
						        			}
						        			else if(config.ads.hasOwnProperty("overlays")) {
								        		if(config.ads.overlays.hasOwnProperty("region")) {
													config.ads.schedule[i].regions[displayMode][k].region = createRegionObject(config.ads.overlays.region);
								        		}
						        			}
						        		}
						        		if(config.ads.schedule[i].hasOwnProperty("templates")) {
						        			config.ads.schedule[i].regions[displayMode][k].templates = createTemplatesObject(displayMode, config.ads.schedule[i].templates);
						        		}
						        		else {
						        			if(config.ads.hasOwnProperty("overlays")) {
								        		if(config.ads.overlays.hasOwnProperty("templates")) {
								        			config.ads.schedule[i].regions[displayMode][k].templates = createTemplatesObject(displayMode, config.ads.overlays.templates);
								        		}
								        		else config.ads.schedule[i].regions[displayMode][k].templates = createTemplatesObject(displayMode);
						        			}
							        		else config.ads.schedule[i].regions[displayMode][k].templates = createTemplatesObject(displayMode);
						        		}
						        		if(config.ads.schedule[i].hasOwnProperty("width")) {
						        			config.ads.schedule[i].regions[displayMode][k].width = config.ads.schedule[i].width;						        			
						        		}
						        		else {
						        			if(config.ads.hasOwnProperty("overlays")) {
								        		if(config.ads.overlays.hasOwnProperty("width")) {
								        			config.ads.schedule[i].regions[displayMode][k].width = config.ads.overlays.width;
								        		}						        				
						        			}
						        		}
						        		if(config.ads.schedule[i].hasOwnProperty("height")) {
						        			config.ads.schedule[i].regions[displayMode][k].height = config.ads.schedule[i].height;						        									        			
						        		}
						        		else {
						        			if(config.ads.hasOwnProperty("overlays")) {
								        		if(config.ads.overlays.hasOwnProperty("height")) {
								        			config.ads.schedule[i].regions[displayMode][k].height = config.ads.overlays.height;
								        		}						        				
						        			}
						        		}
						        		if(config.ads.schedule[i].hasOwnProperty("acceptedAdTypes")) {
						        			config.ads.schedule[i].regions[displayMode][k].acceptedAdTypes = config.ads.schedule[i].acceptedAdTypes;						        									        									        			
						        		}
						        		else {
						        			if(config.ads.hasOwnProperty("overlays")) {
								        		if(config.ads.overlays.hasOwnProperty("acceptedAdTypes")) {
								        			config.ads.schedule[i].regions[displayMode][k].acceptedAdTypes = config.ads.overlays.acceptedAdTypes;
								        		}						        										        				
						        			}
						        		}
						                if(config.ads.schedule[i].hasOwnProperty("alwaysMatch")) {
						        			config.ads.schedule[i].regions[displayMode][k].alwaysMatch = config.ads.schedule[i].alwaysMatch;						                	
						                }
						        		else {
						        			if(config.ads.hasOwnProperty("overlays")) {
								        		if(config.ads.overlays.hasOwnProperty("alwaysMatch")) {
								        			config.ads.schedule[i].regions[displayMode][k].alwaysMatch = config.ads.overlays.alwaysMatch;
								        		}						        										        										        				
						        			}
						        		}
						                if(config.ads.schedule[i].hasOwnProperty("enableScaling")) {
						        			config.ads.schedule[i].regions[displayMode][k].enableScaling = config.ads.schedule[i].enableScaling;						                	
						                }
						        		else {
						        			if(config.ads.hasOwnProperty("overlays")) {
								        		if(config.ads.overlays.hasOwnProperty("enableScaling")) {
								        			config.ads.schedule[i].regions[displayMode][k].enableScaling = config.ads.overlays.enableScaling;
								        		}						        										        										        				
						        			}
						        		}
						                if(config.ads.schedule[i].hasOwnProperty("enforceRecommendedSizing")) {
						        			config.ads.schedule[i].regions[displayMode][k].enforceRecommendedSizing = config.ads.schedule[i].enforceRecommendedSizing;						                							                	
						                }
						        		else {
						        			if(config.ads.hasOwnProperty("overlays")) {
								        		if(config.ads.overlays.hasOwnProperty("enforceRecommendedSizing")) {
								        			config.ads.schedule[i].regions[displayMode][k].enforceRecommendedSizing = config.ads.overlays.enforceRecommendedSizing;
								        		}						        										        										        										        				
						        			}
						        		}
						                if(config.ads.schedule[i].hasOwnProperty("keepVisibleAfterClick")) {
						        			config.ads.schedule[i].regions[displayMode][k].keepVisibleAfterClick = config.ads.schedule[i].keepVisibleAfterClick;						                	
						                }
						        		else {
						        			if(config.ads.hasOwnProperty("overlays")) {
								        		if(config.ads.overlays.hasOwnProperty("keepVisibleAfterClick")) {
								        			config.ads.schedule[i].regions[displayMode][k].keepVisibleAfterClick = config.ads.overlays.keepVisibleAfterClick;
								        		}						        										        										        				
						        			}
						        		}
						        		if(displayMode == "html5") {
							        		if(config.ads.schedule[i].hasOwnProperty("overlay")) {
							        			if(config.ads.schedule[i].overlay is Boolean) {
							        				config.ads.schedule[i].regions[displayMode][k].overlay = config.ads.schedule[i].overlay;
							        			}
							        			else if(config.ads.schedule[i].overlay is Object) {
							        				if(config.ads.schedule[i].overlay.hasOwnProperty("html5")) {
									        			config.ads.schedule[i].regions[displayMode][k].overlay = config.ads.schedule[i].overlay.html5;						        			
							        				}
							        			}
							        		}
							        		else {
							        			if(config.ads.hasOwnProperty("overlays")) {
									        		if(config.ads.overlays.hasOwnProperty("overlay")) {
									        			if(config.ads.overlays.overlay is Boolean) {
									        				config.ads.schedule[i].regions[displayMode][k].overlay = config.ads.overlays..overlay;
									        			}
									        			else if(config.ads.overlays.overlay is Object) {
									        				if(config.ads.overlays.overlay.hasOwnProperty("html5")) {
											        			config.ads.schedule[i].regions[displayMode][k].overlay = config.ads.overlays.overlay.html5;
											        		}
											        	}
									        		}						        				
							        			}
							        			else {
							        				if(config.ads.schedule[i].regions[displayMode][k].hasOwnProperty("overlay") == false) {
							        					config.ads.schedule[i].regions[displayMode][k].overlay = true;
							        				}
							        			}
							        		}
						        		}
						        		else {
						        			config.ads.schedule[i].regions[displayMode][k].overlay = true;
						        		}
				        			}
				        			displayMode = "html5";
				        		}
				         	}
						}
        			}
        		}
        	}

        	return config;
        }
    }
}
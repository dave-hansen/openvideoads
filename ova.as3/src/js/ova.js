/**
 * Advanced companion & overlay processing scripts - supports insertion of JavaScript based
 * companion and non-linear ad types.
 *
 *     Author: Paul Schulz
 *
 */
var ova = new function() {
  // Lower level content insertion and div manipulation functions

  var debugging = true;
  var previousNonLinearContent = new Array();
  var previousCompanionContent = new Array();

  // PUBLIC API

  /**
   * Extract the content between the script tags
   */
  function _extractScriptContent(script) {
      var quickExpr = /<script[^>]*>([\s\S]+)<\/script>/gi;      
      var match = quickExpr.exec(script);  
      // Verify a match, and that no context was specified for #id
      if (match && match[1]) {
         return match[1];
      }			
  	  return script;
  }

  /**
   * Cleans up any document.write() methods in the markup script
   */
  function _cleanupScript(script) {
      var quickExpr = /^(?:[^#<]*(<[\w\W]+>)[^>]*$|#([\w\-]*)$)/;
      var match = quickExpr.exec(script);  
      // Verify a match, and that no context was specified for #id
      if (match && match[1]) {
         return match[1];
      }			
  	  return script;
  }
  
  /**
   * Save the content of the companion container
   */
  function _saveContainer() {
  	  // NOT IMPLEMENTED
  }

  /**
   * Display the companion in the container
   */  
  this.displayCompanion = function(companion) {
  	  // NOT IMPLEMENTED 
  }
  
  /**
   * Restore the original companion content in the container
   */  
  this.restoreCompanion = function(companion) {
  	  // NOT IMPLEMENTED 
  }
  
  /**
   * Display a non-linear ad
   */
  this.displayNonLinearAd = function(ad) {
	  _debug(ad);
      if(ad != null) {
          if(ad.region != null) {
          		if(ad.content.type != null) {
			          var elementID = _verifyRegionID(ad.region.region[ad.content.type.toLowerCase()]);
			          if(elementID != null) {
				          previousNonLinearContent[elementID] = document.getElementById(elementID).innerHTML;
					      if(ad.content.type == 'IMAGE' || ad.content.type == 'TEXT' || ad.content.type == 'HTML') {
					          _debug("Displaying a non-linear ad of type " + ad.content.type + " in a DIV region with ID '" + elementID + "'");
                              document.getElementById(elementID).innerHTML = "<div id='ova-click-" + ad.nonLinearVideoAd.uid + "'>" + ad.content.formed + "</div>";
					          if(ad.clickThroughURL != null) {
					              document.getElementById('ova-click-' + ad.nonLinearVideoAd.uid).onclick = function() { _processClickThrough(ad.clickThroughURL, ad.content.trackingEvents); }
					          }
					          _fireImpressions(ad.impressions);
							  if(ad.region.overlay) _showOverlayContent(elementID, ad);
					      }
					      else if(ad.content.type == 'SCRIPT') {
					      	  if(ad.content.format == 'URL') {
   	                              // NOT IMPLEMENTED 
					      	  }
					      	  else if(ad.content.format == 'CODE') {
   	                              // NOT IMPLEMENTED 
					      	  }
					      	  else {
						          document.getElementById(elementID).innerHTML = _cleanupScript(ad.content.formed);
					      	  }
					      }
					      else if(ad.content.type == 'SWF' || ad.content.type == 'IFRAME') {
					          _debug("Displaying a non-linear ad of type " + ad.content.type + " in a DIV region with ID '" + elementID + "'");
					          document.getElementById(elementID).innerHTML = ad.content.formed;
					          _fireImpressions(ad.impressions);
							  if(ad.region.overlay) _showOverlayContent(elementID, ad);
					      }
					      else if(ad.content.type == 'VPAID') {
					          _debug("Cannot play non-linear VPAID ads via HTML5 - ignoring");
					      }
					      else _debug("Display non-linear ad - unknown content type '" + ad.content.type + "'");
			          }
			          else _debug("Cannot display the non-linear ad via HTML5 - the region (DIV) ID is null");
          		}
          }
          else _debug("Cannot display non-linear ad via HTML5 - no region provided with the ad object");
      }
      else _debug("Cannot display non-linear ad via HTML5 - no ad object provided");
  }

  /**
   *  Hide a non-linear ad
   */
  this.hideNonLinearAd = function(ad) {
      _debug(ad);
      if(ad != null) {
          if(ad.region != null) {
          	  if(ad.content.type != null) {
		          var elementID = _verifyRegionID(ad.region.region[ad.content.type.toLowerCase()]);
		          if(elementID != null) {
					  if(ad.region.overlay) {
					  	  _debug("Non-linear ad is an overlay - setting region '" + elementID + "' visibility to false");
					  	  _hideElement(elementID);
					  	  if(ad.closeButton != null) {
					  	      if(ad.closeButton.enabled) {
 					  	          _hideElement(ad.closeButton.region);
					  	      }
					  	  }
					  }
					  else {
					  	  _debug("Non-linear ad is a non-overlay - restoring the original contents of region '" + elementID + "'");
					  	  if(previousNonLinearContent[elementID] != null) {
					  	      document.getElementById(elementID).innerHTML = previousNonLinearContent[elementID];
					  	      previousNonLinearContent[elementID] = null;
					  	  }
					  }
				  }
				  else _debug("Cannot hide the non-linear ad - no element ID found to identify the region");
			  }
			  else _debug("Cannot hide the non-linear ad - no content type specified to identify the region");
		  }
		  else _debug("Cannot hide the non-linear ad - no region declared for the ad");
	  }
  }

  //=== PRIVATE METHODS

  function _debug(content) {
     try {
     	if(debugging) {
     	    if(typeof(content) == "string") {
     	       console.log(new Date() + " OVA-JS: " + content);
     	    }
 	        else console.log(content);
 	    }
     }
     catch(error) {
     }
  }

  function _showElement(elementID) {
  	document.getElementById(elementID).css("visibility", "visible");
  }

  function _hideElement(elementID) {
  	document.getElementById(elementID).css("visibility", "hidden");
  }

  function _showOverlayContent(elementID, ad) {
	 _showElement(elementID);
     if(ad.closeButton != null) {
        if(ad.closeButton.enabled) {
            if(ad.closeButton.program) {
                document.getElementById(ad.closeButton.region).onclick = function() {
                    _hideElement(ad.closeButton.region);
                    _hideElement(elementID);
                    _fireTrackingEvents(["close"], ad.trackingEvents);
                };
            }
            _showElement(ad.closeButton.region);
        }
     }
  }

  /**
   * Fire impressions
   */
  function _fireImpressions(impressions) {
  	// not implemented at present - impressions are fired by SWF before calling Javascript
  }

  /**
   * Fire tracking events
   */
  function _fireTrackingEvents(names, events) {
	if(names != null && events != null) {
		if(names.length > 0 && events.length > 0) {
		   for(name in names) {
		      for(event in events) {
		         if(events[event].type == names[name]) {
		         	if(events[event].urls != null && (events[event].urls instanceof Array)) {
		                for(url in events[event].urls) {
		                   _debug("Tracking '" + events[event].type + "' to " + events[event].urls[url]);
		                   	var xmlhttp;
							if (window.XMLHttpRequest) {
								// IE>7, Firefox, Chrome, Opera, Safari
								xmlhttp = new XMLHttpRequest();
							} else {
								// IE6
								xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
							}
							xmlhttp.open("GET", events[event].urls[url], true);
							xmlhttp.send(null);
		                }
		         	}
		         }
		      }
		   }
		}
	 }
  }

  /**
   * Process a click through
   */
  function _processClickThrough(clickThroughURL, events) {
	if(clickThroughURL != null) {
		window.open(clickThroughURL, "_blank");
		fireTrackingEvents(["acceptInvitation"], events);
	}
  }

  /**
   * Checks that the region name is not an "auto:" based ID - if so, strip out the "auto:" - the "auto" sizing
   * option is currently unsupported in HTML5 mode
   */
  function _verifyRegionID(regionID) {
  	if(regionID != null) {
  	   if(regionID.indexOf("auto:") > -1) {
			return regionID.replace("auto:", "");
  	   }
  	   return regionID;
  	}
  	return "bottom";
  }
}

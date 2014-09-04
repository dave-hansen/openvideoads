Change Log

0.2.1 - June 30, 2009

* The initial version - ad types supported are pre, mid, post roll linear video and companions
* HTTP and RTMP protocols supported

0.3.0 - August 27, 2009

* Config.as: "autoPlay" correctly implemented - only available at top level
* Config.as: "contiguous" option name changed to "allowPlaylistControl"
* Overlays supported

0.3.1 - September 1, 2009

* ISSUE 18: Deprecation of "selectionCriteria" config param - replaced with "adTags"

0.3.2 - September 6, 2009

* "adTags" should have been "adParameters" - fixed
* ISSUE 25:	Full screen positioning of "this is an ad" message is wrong - was a general problem
  around resizing not being done in the JW Player Open Ad Streamer
* Companion ad timing fixed
* Moved to final 3.1.3 Flowplayer release - "providers" config depreciated because we can't get
  the autoload of RTMP providers to work for instream clips - needs investigation. Manually
  define the provider plugins for now (see any rtmp example with an overlay to see how to do this)
* Examples cleaned up - example19 made a single example all-example19.html
* Some old overlay OpenX zones removed - in general zone definitions cleaned up
* Templates added to allow overlay formats to be changed as needed
* Example 19 fixed so that regions are right width,height and display properly
* ISSUE 21: overlay examples included
* ISSUE 23: problem with skipping between clips fixed on example 04 (autoPlay configuration issue)
* ISSUE 51: Support added to change ad notice text size from normal to small - size:smalltext|normaltext

0.3.3 - October 6, 2009

* ISSUE 67: all-example29 created
* ISSUE 78: "deliveryType" config option set to "any" by default - meaning in most cases,
  this option is no longer required - removed from examples
* ISSUE 81: HTTP progressive FLV example12 fixed - plays now - was an openx banner config issue
* ISSUE 31: JW Player examples don't work on IE8 - fixed - <embed> tags used instead of <object>
* ISSUE 79: Click through on overlay click to video ads not activated for JW Player - also ensure
  that overlay linear video ad tracking events are fired
* ISSUE 40 & ISSUE 80: Change "streamType" configuration to be generalised - default is now "any"
  all-example41 created to test/illustrate new streamType configuration
* ISSUE 92:	Fix up the "autoPlay" usage in the examples - example04 now illustrates turning
  autoPlay:true
* ISSUE 17:	Support pseudo-streaming provider
* ISSUE 59:	Restore the 'providers' configuration option for Flowplayer

0.4.0 - November 4, 2009

* ISSUE 123: Moved to LGPL
* ISSUE 114: "Out of the Box" support for AdTech requests
* ISSUE 120: Ad servers can now be configured per ad slot
* ISSUE 110: Load issues with the Ant build of the OAS due to control bar strongly typed references
  in the codebase which meant that the controls plugin had to be loaded before the OAS - strong
  references removed
* ISSUE 104: Option to allow companions to display permanently until replaced
* ISSUE 102: Refactor out the Ad Server to support multiple calls - single and multiple ad
  calls now supported - see Ad Tech XML Wrapper examples
* ISSUE 100: Factor out the OpenX references when creating Ad Server config/instances
* ISSUE 10: XML Wrapper Support added
* ISSUE 71: Better support for the display of companion ad types (HTML, image and straight code) added
* New Ad Server request configuration - any ad server can now be configured
* Check added to ensure that only one companion will be added per DIV
* "resourceType" and "creativeType" config options added to "companions" config so that the selection
  of a companion from the VAST response can also be based on the type (script, html, swf, image etc.)
* "zone" identifier is no longer required for "direct" ad server requests - see example 52

0.4.1 - December 4, 2009

* If OpenX is used, requires OpenX server side Video plugin v1.2
* ISSUE 141 and ISSUE 93 - Support added for preview images - see all-example57.html
* Javascript event callback API added - see all-example56.html
* ISSUE 147: Impression tracking should be fired on empty VAST ads - see all-example58.html - as
  per the AOL/AdTech request - new configuration option "forceImpressionServing" added to the
  AdServer config - set to "true" by default for AdTech, false for others.

0.4.2.47 (RC2) - May 20, 2010

* "file" flashvar supported to specify show stream (duration based and duration-less) - see
  examples jw-example80 and jw-example81
* Fixed an issue where default "show" providers were being set stopping the right default
  http provider (lighttpd) being set by the plugin
* Support for duration-less streams (file flashvar and show stream config)
* Modified XSPFPlaylistItem so that "retainPrefix" can be set for rtmp streams. JW4x didnt
  want the prefix, but JW5x does
* ISSUE 167: Ensure JW 4.6 and 5.x playlists run - fixed - the "type" meta tag is now needed to
  specify the providers. The XSPF playlist class has been modified to ensure that the
  "type" meta tag is set.
* ISSUE 107: Allow a show stream to be specified in the JW Player URL - sorted
* ISSUE 176: Add option to allow VAST "duration" to be ignored - sorted
* ISSUE 155: Click through not working on mid and post rolls with JW OAS - tested - now works
* ISSUE 184: Enable bitrate switching for JW 4.6 - BOTR and standard JW playlist
  levels supported now
* ISSUE 142: JW Player autoPlay doesn't work properly - fixed
* ISSUE 174: Split the ad delivery part from the video delivery part - standard JW flashvar
  "file" config can now be used
* Improved support for linear ads with live streaming using standard JW flashvar file config
  and live examples added
* ISSUE 48:	Positioning of Ad Notice wrong sometimes, particularly in fullscreen mode - fixed
* Fixed exception thrown when bad VAST response (non XML or null) is returned
* 4.x version only - "blockUntilOriginalPlaylistLoaded" option added - see BOTR example
* "stagePaddingBottomWithControls" option added - see BOTR example
* 24/7 Real Media OAS (ad server) support added (www.247realmedia.com) - thanks to
  Pedro Faustino for the code. See org.openadstreamer.vast.server.oas for the codebase.

0.4.3 - August 4, 2010

* "OpenAdStreamer.swf" renamed to "ova.swf" and config tag changed to "ova.config"
* remove "allowPlaylistControl" option from examples (option now depreciated)
* overlays hiding immediately if no duration specified - indefinite should be default value
* ova.hidden property added to ad clips to address cross plugin incompatibility (HD case still fails)
* Changed the click processing on SWF overlays - if there is not VAST click-through event
  to be fired, click tracking is done by the SWF itself
* Support added for iFrame companion ads - for both VAST 1 and VAST 2.0
* Final swf renamed to "ova.swf" to reflect new product naming
* Fixed ad notice countdown timer so that it's based on stream played duration
* Cleaned up default bottom padding for ad notice overlay
* Added example to illustrate how to modify overlay stage dimensions
* Fixed VAST 2.0 implementation to support multiple sequential impression tags
* Added onStopAd, onPauseAd, onResumeAd, onFullscreen, onMuteAd, onUnmuteAd, onReplayAd Javascript events
* Fixed isStream() test so that it works properly for ad streams (_streamName was not being set)
* Added check to ensure that impression URLs are only fired once per VideoAd (unless specifically overriden
  with forceFire config setting)
* Fixed VAST 2.0 processing of "impression" and "creativeView" events - if present, creativeView fired
  on the display of each creative element, while impressions fired for the first creative element
  to be displayed
* Added partial VAST 2.0 tracking event support for Companions - creativeView only
* Support added for limited TrackingEvents on NonLinear ads (creativeView, start, complete event only)
* Safety valve fix to re-enable the controlbar always when a show stream starts
* Changed level of ad server HTTP VAST call error to "fatal" to make security violations more
  obvious in debug
* added VASTController.controllingDisplayOfCompanionContent (true by default) and moved companion
  display/hide code into VASTController
* Cleaned up the OpenX URL - if no __target__ is specified, that element of the URL is removed
* "enabled" configuration option confirmed to turn off the ad click-through notice (example added)
* added "index" config option to companion to allow selection of multiple unique companions per
  size - see liverail examples
* added "resourceType" config option to companion to allow selection of unique companion type when
  multiple provided per size - see liverail examples
* added support for "bestBitRate" based on "high", "medium" and "low" - see liverail examples
* Modified "displayCompanions" option - it is now true if companions are declared AND it is not
  explicitly set to false
* Click through message (mouse over) now turned off when ad stream paused
* OVA plugin ID renamed from "OpenAdStreamer" to "ova"
* Redundant use of "displayCompanions:true" in examples config removed
* Direct connection ad server examples created
* Support added for "minSuggestedDuration" VAST attribute on overlays. Works as follows -
  if no duration specified in ad slot or "recommended:XX" specified as the duration,
  the recommended will be taken - in the case of "recommended:XX" if no "minSuggestedDuration"
  is available, the XX value will be used.
* support overlay region auto-sizing (uses "position": "auto:center|top|bottom")
* added "showOverlayCloseButton: true|false" config option for the "ads" grouping to allow auto regions
  to have their close button active|inactive
* Added option to "processCompanionsExternally" which allows Javascript processing of the
  Companion ad insertion methods so that advanced companion types that require the insertion and
  execution of javascript code to be supported - thanks to Joe Connor for the JQuery based
  methods included in this release.
* SWF overlay loader is removed when hidden to stop events/processing - loader.unload() is
  now called before removing to ensure child SWF can close associated streams
* Click through URLs now qualified when put into anchor tags - http:// added where necessary
* Default timing offset changed to 300MS from 1 second to reduce possibility of someone
  being able to skip on the timeline before the controlbar is disabled.
* Remove newlines and escape quotes in the HTML companion content before writing it to the DIV
* Safety mechanism implemented to ensure that the Click-Through region is turned off when
  a clip stops playing (to deal with the case where the end linear ad events don't fire because
  the ad duration is wrong in metadata and/or VAST)
* Fixed defect that stopped companions being re-displayed when replayed. Reset the activeDivID to null
* Force cleanup of any ad notices on completion of a stream - if the ad duration was wrong, the ad
  notice would sometimes be left on the screen - this should no longer happen
* VAST 2.0 XML parser rewritten - allows for complex ad/companion sequencing now
* Fixed issue stopping multiple VAST1 companions being parsed
* Companion content is only pushed into a DIV if there is something to insert
* Added try/catch block around XML initiation of VAST response - if tag structure is broken
  the exception is now caught and the ad streamer continues ignoring the VAST response instead
  of just hanging
* Format of "minSuggestedDuration" checked - if it is "HH:MM:SS" it is converted to just seconds when
  saved in the AdSlot - for consistency - Tremor seems to use "HH:MM:SS" format
* Resolved defect where multiple overlays would all be shown at once if "auto" used and multiple
  defined in one VAST2 creative element (see Tremor Media example01 to validate)
* When companions are restored, changed order of restoration of previous content to newest
  to oldest to ensure original DIV content always ends up on top
* Mov.ad ad server examples added (VAST1 and VAST2)
* Fixed initial positioning of overlays to reflect bottom margin based on controlbar visibility
* No longer requires case sensitive event types in the VAST response (e.g. "Start" will match as does "start")
* Fullscreen entry and exit events now properly processed
* Fixed defect where a muted player that has the volume turned to 0 generates the mute event again.
  No longer does this.
* YouTube now works for 4x and 5x
* Compatibility with HD plugin (HD option disabled for OVA linear ads)
* JW4x - centering of "click through" message now correct

0.4.4 - September 19, 2010

* Added 1 mid-roll example under "ad-formats"
* Cleaned up "start-time" examples to cover mid-roll cases
* T101: Fixes to "ova-companions-jquery.js" to resolve issue where companions were not restoring
  post ad - there were bugs in the writeOriginal and readHTML functions
* T118: Fixed the bug that stopped the "click for more info" overlay being reshown after it was
  clicked once. Was a problem with the region hiding in RegionView.
* T73: Fixed issue stopping mid-roll examples working - the "type" was not being correctly set
  in the flashvars config for the pseudo-streaming streams.
* T60: Mid-roll examples updated to reflect that start timings on adslots are absolute (from 0)
  rather than relative to the start-time of the stream (as is the case with Flowplayer)
* Javascript API calls made from the AS3 framework via ExternalInterface.call() are now turned off
  by default. To turn them on "canFireAPICalls" must be set to "true" in the config.
* Added "millisecondDelayOnCompanionInjection" to allow a delay to be inserted before injecting
  multiple companions on a page. Apparently injection many SWFs on 1 IE page can crash IE

0.5.0 - Current Trunk

* T163 - "activelySchedule": false option added to allow ads to be turned off. Empty ad schedule
  does not throw an exception now.
* T162 - clean up formatting on YouTube example
* T171 - Fixed streamer issue - OVA for JW4 does not play a HTTP ad if there is an RTMP
  streamer and file
* T172 - Fixed the issue that meant that VAST1 wrapped ads fired double tracking events
* T169 - Stopped "STOP" being fired at end of ad streams - now only fires when stop button pressed
* T173 - CloseButtonConfig now has the initialisation code that allows the sizing to be
  specified via the config
* Added JW Specific example 16 - Loading Shows and Ads "On Demand" via player.sendEvent(LOAD...)
* T176 - Added ability to defer the ad call until after the Play button is hit - new configuration
  option is "delayAdRequestUntilPlay" - examples added
* T170 - Added support for "failover ad servers" - see new example02 in examples/ad-servers
* Added Adform ad server examples and connector support
* Added support for "minimal" OVA pre-roll configuration via a new "ova.tag" and "ova.debug"
  config variable
* T205 - Examples now including <OBJECT> and <EMBED> code correctly. This was stopping the
  companion restoration working correctly in IE in native mode.
* T19 - Skip Ad button options added (also T201)
* Filter out non-compatible linear media mime types (only allow flv, mp4, swf). Can be overridden
  with "acceptedLinearAdMimeTypes" and "filterOnLinearAdMimeTypes" config options
* Added Smartclip and Spotxchange linear configuration examples
* T225 - "setDurationFromMetaData" implemented for show streams
* T226 - Timestamp.secondsToTimestamp() fixed so that it produces the correct result. This was
  causing a problem with durations on playlist clips being read in when OVA initialises
* T228 - Have implemented config control for the VAST wrapped ad tag cache buster parameter
* T229 - Resolved bug that stopped autostart working for the first clip if the ad couldn't be
  loaded. Only occurred if the clip was configured using the "file=" flashvar
* T235 - Complete rewrite of the onMetaData set duration rules to fix issues with seeking
  for duration set pseudo-streams
* onLinearAdSkipped() Javascript callback added - this is fired when the skip button is hit
--- RC3
* T58 - Added mov.ad VPAID example
* T250 - Removed use of JSwoof for JSON parsing
* T255 - Added missing "allowScriptAccess" embed param on SWF companions
* Added "video/mp4" and "video/flv" to the accepted media file mime types for the plugin
* T256 - Modified AdSlot.isActive() to only return true if the Linear ad has media files
  or it has non-linears
* Added Google Analytics impression tracking
* Added SpotXChange VPAID example
* Javascript callback event support added for VPAID ads
* T270 - Fixed condition ensuring VAST 2.0.1 is processed
* Added tagParams config option to allow additional parameters to be added to an ad tag
* T266 - SWF companions now have <AdParameters> passed through if provided in the VAST response
* Ensured that companions that don't have a creativeType are displayed as images
* T223 - Improved RTMP Ad Stream support - "ad streamers" config block added and default
  URL splicing rules
* T293 - Chained VAST2 and VAST1 (mixed version) wrappers now work
* T298 - Stopped wrapped ads firing Javascript API calls - was previously firing across
  multiple calls a wrapped chain
* Volume changes are now correctly set on VPAID ads
* Resolved issue where overlay close button was being disabled if a pre-roll was also configured
* A configuration option has been added to allow a timeout value to be set on ad calls - this
  stops ad servers blocking the player if they don't return a value and hold the call open
* Fixed issue that stopped "keepOverlayVisibleAfterClick" working with custom regions
* Changed the click through logic to ensure that IE browsers use the ExternalInterface("window.open")
  rather than the AS3 navigateToURL() method - this fixes an issue where IE popup blockers
  blocked click throughs if the wmode was set to opaque
* Ensured click through URL details etc. are included in the ad object passed back in the
  Javascript callbacks
* Added support to allow the default ad title and description to be changed
* Changed onVASTLoadSuccess(), onVASTLoadFailure(), onVASTLoadTimeout to onTemplateLoadSuccess(),
  onTemplateLoadFailure() and onTemplateLoadTimeout()
* Added Ads config group setting 'additionalParamsForSWFCompanions' to allow additional parameters
  to be added to the companion SWF object/embed tags as the code is inserted into the page
* Added "manage" ads.control config option to turn off OVA manipulation of the control bar
  when set to "false"
--- RC6
* SWF renamed to ova-jw.swf and version set at 1.0.0

v1.0.0 RC7 - Jan 30 2012

* Bitrate selection now working
* Removed need to specify holding clip URL and set default to the Longtail CDN path
* Depreciated "overlays" group in favour of new "regions group" - OverlaysGroupConfig class
  renamed to RegionsGroupConfig
* Modified region placement code
* Overlay positions now default to "auto:bottom" - no longer need to specify a position
* Unified companion options under single ads.companion config group
* replaced ova-companions-jquery with ova-jquery to add support for overlays as well as
  external companion insertion
* Several API changes (see RC7 release note on OVA developer site)
* Several config options depreciated and replaced with a cleaner set of options/structure -
  see RC7 release note on the OVA developer site
* ova-companions-jquery.js - renamed to ova-jquery.js
* OVA Master GA always on
* Verified with Flash 11 - removed issues causing Stack Overflows - doTrace(vad) and
  missing _ with mimeType in NetworkResource
* Corrected bug and example config for new control bar enable/disable
Change Log

0.4.3 - August 4, 2010

* Initial release of JW 5 version

0.4.4 - September 19, 2010

* Fix for null _player or _playlist debug exception thrown on startup in startPlayFromTimer()
* Added 1 mid-roll example under "ad-formats"
* Cleaned up "start-time" examples to cover mid-roll cases
* T101: Fixes to "ova-companions-jquery.js" to resolve issue where companions were not restoring
  post ad - there were bugs in the writeOriginal and readHTML functions
* T77: Fixed issue where mid-roll sliced streams weren't picking up the correct duration for each
  stream slice
* T106: Changed the HD example to use a BOTR HD playlist ensuring that the HD option works correctly
* T118: Fixed the bug that stopped the "click for more info" overlay being reshown after it was
  clicked once. Was a problem with the region hiding in RegionView.
* T127: Fixed the bug that stopped OVA working with custom skins
* T126: Basic support created for OVA in JW for Wordpress module (see ova.xml)
* T60: Mid-roll examples updated to reflect that start timings on adslots are absolute (from 0)
  rather than relative to the start-time of the stream (as is the case with Flowplayer)
* Javascript API calls made from the AS3 framework via ExternalInterface.call() are now turned off
  by default. To turn them on "canFireAPICalls" must be set to "true" in the config.
* Added "millisecondDelayOnCompanionInjection" to allow a delay to be inserted before injecting
  multiple companions on a page. Apparently injection many SWFs on 1 IE page can crash IE
* T138: Fixed the issue where a thumbnail/splash image set via the flashvars "image=" was
  being ignored after OVA ad scheduling. An extra option "ignoreDefaultSplashImage" has been
  introduced to stop the flicker on the image in the splash player as it's reset post
  ad scheduling.
* T142: Fixed the issue that occurred if no duration was specified on a show stream
  and the show stream used the HTTP progressive download provider. For some reason, JW5
  does not set the duration in that case based on metadata. OVA is now forced to set
  the duration if the show duration is 0. Added an extra example to the "no duration"
  cases to test this.
* T141: Support added for flashvars "autostart" and "repeat" - these now appropriately
  set the corresponding OVA config attributes when the plugin initialises
* T152: Overlays and ad notices now repositioning based on control bar visibility

0.5.0 - Current Trunk

* T163 - "activelySchedule": false option added to allow ads to be turned off. Empty ad schedule
  does not throw an exception now.
* T172 - Fixed the issue that meant that VAST1 wrapped ads fired double tracking events
* T173 - CloseButtonConfig now has the initialisation code that allows the sizing to be
  specified via the config
* Replaced JW player version with JW 5.3 production release
* T183 - Added example (18) to illustrate OVA configuration with JW 5.3 Javascript setup code
* T176 - Added ability to defer the ad call until after the Play button is hit - new configuration
  option is "delayAdRequestUntilPlay"
* T194 - Fixed the issue stopping the preview image from re-displaying at the end of playback
* T170 - Added support for "failover ad servers" - see new example02 in examples/ad-servers
* Added Adform ad server examples and connector support
* Added support for "minimal" OVA pre-roll configuration via a new "ova.tag" and "ova.debug"
  config variables
* T197 - Media file selection now defaults to progressive first
* Added support in for 'blockUntilOriginalPlaylistLoaded'
* T205 - Examples now including <OBJECT> and <EMBED> code correctly. This was stopping the
  companion restoration working correctly in IE in native mode.
* Telemetry VPAID examples added
* T19 - Skip Ad button options added (also T201)
* Filter out non-compatible linear media mime types (only allow flv, mp4, swf). Can be overridden
  with "acceptedLinearAdMimeTypes" and "filterOnLinearAdMimeTypes" config options
* Added Smartclip and Spotxchange linear configuration examples
* Liverail VPAID example added
* T225 - "setDurationFromMetaData" implemented for show streams
* T226 - Timestamp.secondsToTimestamp() fixed so that it produces the correct result. This was
  causing a problem with durations on playlist clips being read in when OVA initialises
* T228 - Have implemented config control for the VAST wrapped ad tag cache buster parameter
* T232 - Changed the initialisation process so that the plugin now locks on receipt of the
  original playlist loaded event until the VAST response has been loaded. This ensures that
  the display play button isn't active too early
* T235 - Complete rewrite of the onMetaData set duration rules to fix issues with seeking
  for duration set pseudo-streams
* onLinearAdSkipped() Javascript callback added - this is fired when the skip button is hit
* T233 - Fixed - when VPAID pre-roll loaded, before playing if Timeline clicked, a player
  exception is generated - Timeline is now disabled when OVA is loaded. Only disabled
  when a stream is played.
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
* T244 - Fixed bug requiring double click to start play of VPAID pre-roll when
  delayAdRequestUntilPlay used
* T266 - SWF companions now have <AdParameters> passed through if provided in the VAST response
* Ensured that companions that don't have a creativeType are displayed as images
* Ads config group variable "linearScaling" added to allow all ads to be forcibly scaled
  according to setting (e.g. with JW Player 'uniform|fill|exactfit|none' will set all
  ad stream scaling accordingly
* T223 - Improved RTMP Ad Stream support - "ad streamers" config block added and default
  URL splicing rules
* T287 - Added support (streamTimer) for overlays on live streams
* T286 - AdSlots and Stream have the same "ova.X" properties on them across products
* Made sure "blockUntilOriginalPlaylistLoaded" actually works
* T293 - Chained VAST2 and VAST1 (mixed version) wrappers now work
* T298 - Stopped wrapped ads firing Javascript API calls - was previously firing across
  multiple calls a wrapped chain
* Fixed the issue stopping splash images showing with VPAID pre-rolls
* T303 - Stopped double firing of the fullscreen tracking event when the player generates
  multiple onFullscreen events when going fullscreen
* If "delayAdRequestUntilPlay: true" and a splash image is set, "clearPlaylist: false"
  is forcibly set - this allows the splash image to show until the play button is
  pressed and the new ad scheduled playlist is installed
* T304 - added support for custom resizing of the click through region based on the
  Y position of the control bar
* Volume changes are now correctly set on VPAID ads
* Resolved issue where overlay close button was being disabled if a pre-roll was also configured
* Enabled the use of the "providers" setting for ad clips (so that ads could be set as
  "http" pseudo-streaming when show clips are set that way - fixes the mix and match problem
  that Alex had which caused a black screen on show clip replay after a progressive http post-roll
* A configuration option has been added to allow a timeout value to be set on ad calls - this
  stops ad servers blocking the player if they don't return a value and hold the call open
* Fixed issue that stopped "keepOverlayVisibleAfterClick" working with custom regions
* Changed the click through logic to ensure that IE browsers use the ExternalInterface("window.open")
  rather than the AS3 navigateToURL() method - this fixes an issue where IE popup blockers
  blocked click throughs if the wmode was set to opaque
* Added support for the player dimensions to be hard coded in OVA configuration via the
  "player: { width: X, height: Y }" config block
* Ensured click through URL details etc. are included in the ad object passed back in the
  Javascript callbacks
* Added support to allow the default ad title and description to be changed
* Added support for a splash image to be set on a playlist that only contains a linear ad
* Changed onVASTLoadSuccess(), onVASTLoadFailure(), onVASTLoadTimeout to onTemplateLoadSuccess(),
  onTemplateLoadFailure() and onTemplateLoadTimeout()
* Added Ads config group setting 'additionalParamsForSWFCompanions' to allow additional parameters
  to be added to the companion SWF object/embed tags as the code is inserted into the page
* Improved special case test cases (testing for bad/empty/no response etc.)
* Added support for RTMP subscribe to be forcibly set to true or false on ad clips
* Upgraded to JW5.6
* Added "manage" ads.control config option to turn off OVA manipulation of the control bar
  when set to "false"
--- RC4
* Fixed the bug that prevented "autostart:true" working with "allowPlaylistControl"
* Fixed the bug that stopped the "click through" message showing for top aligned control bars
* Player volume is passed to VPAID ad on startup (unless muted)
--- RC5
* Implemented "resetTrackingOnReplay: true|false" added to allow the tracking tables
  to be reset after an ad has played
* Added "parseWrappedAdTags" ad server config option to allow wrapped ad tags to be parsed
  for OVA variables and the appropriate substitutions made
* Added setActiveLinearAdVolume(volume) Javascript API
* Major change to filtering of linear mime types - now done at parsing time instead of post
  parsing to resolve an issue around selection of media type during parsing
* Now set player volume on non-linear VPAID initialisation
* Fixed muting issue with non-linear VPAID ads - now works correctly
* Added a "positionMidRollSeekPosition" config option for mid-roll support on live streams
* Now sort the ad slots before scheduling
* Added support for "intervals" for repeated ad slots
--- v1.0.0 RC6
* Renamed ova SWF to ova-jw.swf and OVA Javascript plugin to ova-jw.js and version set to 1.0.0
* Added support for on-demand overlays
* Added audio linear ad example
* Added Weborama ad server example
* Improved Javascript OVA API scheduleAds() so that a new playlist can be passed
* Fixed an autostart:true issue with on-demand pre-rolls without a
  delayAdRequestUntilPlay:true setting
* Fixed issue with fireAPICalls() that was resulting in javascript console errors - <AdParameters>
  and the full <Template> string are escaped() before being passed to the API - embedded iFrame
  seems seem to be the source of the issue
* Show duration set from metadata if original duration is 0 (not set)

v1.0.0 RC7 Final - Jan 30 2012

* Bitrate selection now working
* Removed need to specify holding clip URL and set default to the Longtail CDN path
* Depreciated "overlays" group in favour of new "regions group" - OverlaysGroupConfig class
  renamed to RegionsGroupConfig
* Modified region placement code
* Show duration set from metadata if original duration is 0 (not set) - JW5
* implemented JS API skipAd() for linear ad streams only (and examples)
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
* HTML5 overlays support added and a major overhaul to overlays in general
* Fixed bug where empty ad tag resulted in OVA hanging. Empty tags now throw error and are ignored
* Scaling overlays now supported - see new examples
* Added support for "encodeVars" to be set directly at the ad slot level without requiring
  the "server" declaration to enclose it
* Fixed problem with security exceptions on wrapper calls hanging the player
* Corrected bug and example config for new control bar enable/disable

v1.0.1 RC1 - Feb 17 2012

* Corrected event firing for non-linear VPAID ads so that tracking events (such as creativeView)
  that are declared with the non-linear creative are also correctly fired
* Added error handling for "media error" notifications from the Player - OVA now skips forward
  if there is a stream error
* Bug fix ensuring that https click-throughs are correctly supported
* #353 - Fix for calculation of mid-roll related show slice durations. Fixes problem in JW5.6
  or higher players where second to final slices were not setting the duration according
  to the startTime + slice duration and the final slice as the full show duration.
* #356: Added support for passing <AdParameters> to non-linear VPAID ads
* #364 - changed JWPlaylistItem.sync() to clone original show streams instead of using
  original object - fixed recursive toJSObject() issue with JW onComplete. When a 'file'
  is set in the JW Player config, the original clip had a reference to OVA config causing
  the recursive loop on serialisation (because of "originalPlaylistItem")
* #360 - Fixed bug stopping onShowXXX events not firing for show streams that don't
  have a duration specified
* #368 - Control bar now unlocks when scheduleAds() called to ensure that it's operational
  if no pre-roll is to be played after rescheduling

  V1.0.1 RC2 - March 17 2012

* #356 - Reopened ticket to fix bug stopping <AdParameters> being passed into non-linear VPAID ads
* #371 - "addParamsToTrackingURL" option added to Google Analytics config to allow params to be
  turned off when tracking URL is formed
* #372 - "useDefaultPaths" option added to allow default paths to be turned off and effectively
  selectively track specific events by only specifying custom paths for those to be tracked
* #374 - added Security.allowDomain("*") to OVA for JW SWF to stop issues with API calls
* Initial framework restructure to start removing redundant server classes
* #376 - Fixed issue where Custom Properties on a clip were being dropped by OVA in JWPlaylistItem
* #365 - Busy buffering sign added to OVA for JW5
* Modified initial cuepoint offset to 100 milliseconds for OVA for JW5
* Added tracking point offset to SN event because it was not firing as a cuepoint at 0 with
  OVA for Flowplayer
* OVA for JW5 - Added try/catch around showOVABusy() and Ready()
* #396 - Fixed OVA for JW5 buffer so that the buffering sign is not sign for non-linear on-demand
  ad calls and non-linear VPAID loads
* Cleaned up the build process - ant build files created for OVA for JW5, new build commands
  (debug, release) for all products that allow "reduced size" versions of the SWC and
  SWFs to be built.
* #395 - OVA for JW5 - Replaced gapro example with updated gapro-2 javascript plugin
* Changed OVA for JW OpenAdStreamer _config and _player to protected
* #407 - stream seeking bug fixed - extra onMetaData events are now ignored by OVA for JW5
  show streams after the first is received and the duration set on the OVA Stream  object.
  Only impacted streams with no duration set in the player config.
* #415 - A safety condition has been placed in the JWPlaylistItem.sync() method to stop
  the URL being set to null for holding clips - this ensures that the blank holding clip
  plays if there is an error
* #416 - Resolved defect stopping the playlist "previous" button from being disabled in
  custom skins - it is now referenced in the OVA code as "prev" rather than "previous"
* #413 - Fixed condition breaking autoPlay + SMIL playlists + allowPlaylistControl

V1.1.0 RC1 - May 2 2012

* #441 - qualified JSON class with full path to ensure that it compiles with Flex 4.6
* #442 - Changed the [embed] code to ensure that the code compiles with Flex 4.6 
  and runs with Flash 9
* #446 - play() API added to OVA
* Companions "html5" option renamed to "nativeDisplay": false - default setting is "true"
* "nativeDisplay":false option added to "ads" to allow an external library to be used if 
  requested for HTML5 non-linear ad display. Default is "nativeDisplay":true - this option 
  will override companions setting and can be used for companions as well
* VASTController.processCompanionsExternally() renamed to VASTController.processCompanionDisplayExternally()
* #448 - OVA for JW5 - "controls.anchorNonLinearToBottom" option added to allow VPAID non-linear 
  ads to be anchored to the bottom of the display (appearing over the control bar)
* #451 - fixed defect stopping forced impressions firing for VAST2 wrapped tags with a 
  linear template ad
* #438 - Corrected the logic that was checking if the non-linear VPAID ad was playing 
  or not - this was incorrectly returning false causing VPAID non-linear ads to be reinitialised
* #453 - SkipAd bug fixed where pause/resume automatically displayed the skipAd button 
  regardless of whether or not it was active via the "showAfterSeconds" option
* #444 - Support added for AdTech extension event that tracks Click to Play and Auto start
* #460 - Flash content now loaded in it's own ApplicationDomain() as per the VPAID spec - 
  was throwing an exception on SpotXChange ads
* #461 - Fixed wrapper issue that meant that a pre-roll wasn't correctly matched if a 
  wrapper had an empty non-linear ad block as well as the linear template  
* #437 - Support expandable regions that map to the standard and expanded dimensions provided 
  in a VAST response - best for VPAID ads to ensure that the region doesn't cover the full 
  player display  
* #463 - OVA for JW5 only - Fix implemented for V4 control bars to ensure that 0 not shown 
  in the timeline during show stream pause (work-around for logic issue in V4 control bar 
  block() code). 
* #464 - onAdCall methods made into Javascript callbacks. onAdCallFailover() event added, 
  hasAds value added to onAdCallComplete() callback and sequence number added to all ad 
  requests passed in onAdCall callbacks 
* #434 - Fixed preferred display mode example 4 - bad config cleaned up
* #456 - Added test case to validate that depreciated overlays.closeButton is converted 
  correctly to the new regions.closeButton format
* #449 - Missing impression and tracking events from VideoAd javascript object resolved. 
  VideoAd.impressions and VideoAd.trackingEvents added to callback object
* #468 - VPAID ads not fire the "collapse" tracking event when their expanded state 
  changes to collapsed
* #471 - stopped the pause tracking event firing when VPAID linear ads are started in 
  OVA for Flowplayer
* #465 - OVA for JW5: player.play() can now be used to start player playback even if 
  the pre-roll is a VPAID ad
* Added support to fire mouse click events on open regions with VPAID ads back into 
  the JW5 player
* #476 - Close tracking event is now triggered on "SkipAd"
* #474 - Rules around handling of VPAID expanded and linear state change modified - expand/contract 
  does not pause/resume the underlying stream now - only linear ad change does for non-linear ads. 
  Also introduced a new option 'adsConfig.vpaidConfig.pauseOnExpand' and 'resumeOnCollapse' to 
  allow pause/resume to be forced with expand/contract
* Added safety value for OVA for JW5 so that ad notices are always removed onBeforeBegin show streams

V1.1.0 RC2 - July 3, 2012

* Add two new Javascript api - pause() and resume()
* Removed script based generation of examples
* Fixed the bug causing an exception when converting "restoreCompanions" and
  "displayCompanions" to V2 options when no companions are declared

V1.1.0 Final - July 12, 2012

* Upgraded release to JW5.10
* #489 - Added Zedo ad server examples
* #496 - Fixed defect stopping hideLogo working correctly with "allowPlaylistControl":true playlists

V1.2.0 RC1 - Nov 18, 2012

* Fix for skipAd Javascript call into OVA for JW5 when VPAID ads are active - call now works
* Implemented stop() Javascript API interface
* Fixed bug stopping player width and height being passed into the ad tag for use with ad tag variables

V1.2.0 RC1 - November 30, 2012

* Added option "shortenLinearAdDurationPercentage" to reduce the size of the linear ad duration
  used to determine the tracking points

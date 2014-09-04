Change Log

0.2.1 - August 24, 2009

* Initial release with defects/restrictions

0.2.2 - August 26, 2009

* OpenAdStreamer.as: Fixed issue with mid-roll RTMP ad insertion - clip.start=0; added to ensure
  mid-roll ad starts at 0
* OpenAdStreamer.as: Example04 - "autoPlay:false" on "pre-roll" ad not working - clip now sets autoPlay
  based on stream.autoPlay value
* RegionView.as - fix to the framework - and now appears over "click here" textsign and over
  text on overlays
* RegionController.as - fix to ensure RegionViews childIndex puts them on top as they are added
* CrossCloseButton.as - fix to ensure that close button can be clicked and region closed
* OpenAdStreamer.as - Fixed sizing is set on the DisplayProperties - derived automatically from DisplayObject()

0.2.3 - September 1, 2009

* ISSUE 26: Support added for tracking of "unmute, pause and resume" events
* ISSUE 18: Deprecation of "selectionCriteria" config param - replaced with "adTags"

0.2.4 - September 6, 2009

* All HTTP examples moved to official release of Flowplayer 3.1.3 (the official release doesn't
  seem to work with RTMP right now as there isn't an official 3.1.3 RTMP plugin)
* ISSUE 36:	Flowplayer - Ad Notice positioning on fullscreen was incorrect - placed very
  wide so the ad notice disappeared - fixed now

0.2.5 - October 6, 2009

* ISSUE 78: "deliveryType" config option set to "any" by default - meaning in most cases,
  this option is no longer required - removed from examples
* ISSUE 40 & ISSUE 80: Change "streamType" configuration to be generalised - default is now "any"
  all-example41 created to test/illustrate new streamType configuration
* ISSUE 88:	Flowplayer custom clip properties not imported - "player" config grouping added
  at general, stream, ads and ad slot levels. See example44.html
* ISSUE 92:	Fix up the "autoPlay" usage in the examples - example04 now illustrates turning autoPlay:true
* ISSUE 87:	Issues with "applyToParts" config - many fixes - see test cases test01-12.html
* ISSUE 101: Flowplayer playlists can now be used to derive the "shows" configuration - this should
  fix the issue with bandwidth checker compatibility
* ISSUE 99:	Removed references to global.js in examples
* ISSUE 17:	Support pseudo-streaming provider
* ISSUE 59:	Restore the 'providers' configuration option for Flowplayer

0.3.0 - November 4, 2009

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

0.4.0 - December 10, 2009

* If OpenX is used, requires OpenX server side Video plugin v1.2
* Moved examples to Flowplayer 3.1.5
* ISSUE 129 - Restore JS Event API - see Javascript API doc on google code site for details - support
  for events and region styling added - see all-example56.html
* ISSUE 140: Ampersand in OpenX "targeting" parameters breaks JSON parser - customProperties can
  now be specified either as a single param (e.g. "gender=male") or as an array
  (e.g. ["gender=male", "age=20-30"]) - Arrays will be converted to ampersand delimited parameter
  strings (e.g. gender=male&age=20-30
* ISSUE 146: Add support for creativeType="image/jpg" etc. - changed NonLinearVideoAd.as to
  strip out any prefixes like "image/" etc.
* ISSUE 147: Impression tracking should be fired on empty VAST ads - see all-example58.html - as
  per the AOL/AdTech request - new configuration option "forceImpressionServing" added to the
  AdServer config - set to "true" by default for AdTech, false for others.
* ISSUE 137: Issue of "Play Again" button appearing in mid-roll config for Flowplayer playlist
  based configs - now fixed.
* ISSUE 148: url tags not being processed in non linear ad VAST responses when creativeType
  is set as mimeType (e.g. "image/jpg" etc.). The OpenX Video Ads plugin 1.2 now produces
  mimeType creativeType values.
* ISSUE 149: overlay <code></code> tags not being correctly processed by overlay display
  code. Fixed now - code just inserted - templates just used for <url></url> values
* ISSUE 138: Unable to resume after pausing example 43 (Flowplayer) - fixed with rewrite
  of the way Flowplayer playlists are handled
* ISSUE 111: playOnce issue with example43 (playlists) - stops after first playlist item -
  fixed with the change to the way Flowplayer playlists are read in/configured as show streams
* ISSUE 133: Issues with autoPlay not working on Flowplayer playlist based streams fixed
* ISSUE 129: Example 39 - overlay does not show after mid-roll - resolved

0.5.0 RC1 - March 22, 2010

* Issue 139: Linear Interactive ads now supported:
   * all-example59,65,66 added - illustrates the delivery of a linear interactive ad
   * Set the end safety margin on cuepoint firing to 300 (e.g. _vastController.endStreamSafetyMargin = 300;)
     because SWF Linear Interactive ads don't permit the end ad cuepoints to fire if they occur in the last
     300 milliseconds of the ad finishing. All ad completion events now fire 300 milliseconds before the
     end of the ad stream
   * Support for "maintainAspectRatio=true|false" specified on the MediaFile VAST tag (see examples 59,65,66)
   * Support for "scale=true|false" specified on the MediaFile VAST tag (see examples 59,65,66)
* ISSUE 14: Remove the need for duration - pick duration up from stream metadata value (see no duration
  examples)
* ISSUE 161: Support for Flowplayer RSS Playlists verified - see all-example62.html for the configuration options
* ISSUE 163: Support has been added for SMIL files to be used to specify the show streams. See all-example73.html
  for an example of how to configure SMIL files in the "shows" config block
* ISSUE 9 - Added the ability to have an ad notice that includes a dynamic countdown of the remaining
  ad duration in seconds (see all-example68.html)
* Ad related custom properties set on the clip object - "title" is set as "advertisement - [title]",
  "ovaAd", "ovaSlotId", "ovaPosition", "ovaZone" and "ovaAssociatedStreamId"". A "description" has
  also been added - see all-example69.html
* Fixed the bug that meant that show streams were ignored if there wasn't an ad provided for the stream
  (given that an ad slot was defined for the stream) - extra condition added to StreamSequence.build()
* ISSUE 61: Fixed repositioning of "this is an ad" notice and overlays when control bar disappears - see
  all-example74.html - needs the latest Flowplayer trunk build - 3.1.6-dev - as that code has the
  fix for ensuring notifications for control bar "onShowed" etc. are registered with the FP model.
* Changed region creation logic so that defaults are always created and then the specific config
  specified regions can override
* Fixed an issue where a playlist formed from both a flowplayer playlist definition and a
  shows stream definition caused the player to not play the first stream (because the clip URL was
  set with an "marker-clip" value
* 24/7 Real Media OAS (ad server) support added (www.247realmedia.com) - thanks to
  Pedro Faustino for the code. See org.openadstreamer.vast.server.oas for the codebase.
* ISSUE 171 - ad durations returned in the template in non-timestamp format are coverted and
  and option has been added to allow ad duration values to be forcibly ignored. See example 06
  in the "custom ad delivery" examples.
* Resolved an issue where forced impressions (where the ad is empty in the VAST template) were
  being fired multiple times. A safety condition has been added to VideoAd to make sure they
  can't be forced multiple times (unless explicity requested).
* ISSUE 180: Impressions not being fired if a linear ad has an empty non-linear VAST tag set.
  Changed NonLinearVideo ad to include isEmpty() test which checks to see if the URL or
  CODE values are 0 in size (or null) - if they are, the ad is deemed empty and ignored
  in the impression testing condition (resulting in the impressions for the linear ad being
  fired)
* ISSUE 185: Support disabling of playlist forward/back in Flowplayer - fixed - added support
  to the OAS enable/disable control bar code to turn on/off the "playlist" controls.
* ISSUE 187: Add support for direct entry of ad tag in ad server definition - see example
  ad-servers/example02.html for a worked example (Google DART VAST 2.0)
* Moved the cuepoint offset for events to 1000 (up from 300 milliseconds) to account for the
  time it takes to resync the timing table if the VAST ad duration differs from the meta data.
* ISSUE 190: Support SWF object embed code added for companions (see Google VAST 2 example)
* Ad configuration options added to support selection of ad media file based on 'bestWidth'
  'bestHeight' and/or 'bestBitrate' - see the Google VAST 2 example for an illustration
  of this working in action. Combining width/height selection with bitrate does not always
  yield the best result - these options should only be used if bandwidth detection is not active
* Introduced the notion of an ad 'tag' configuration option at ad slot level - see double click
  VAST 2.0 example. This option can be used to configure a specific ad server URL to be
  fired at the ad slot level
* Fixed a defect where restoration of multiple companions failed. Previous DIV state is now
  held in the active companion object.
* ISSUE 194: If an empty URL is provided on a click-through, it's still showing on the linear ad.
  This has been fixed now - empty URL click-throughs (and other items) are excluded when parsed.
* Javascript API provided to allow show stream start/stop/complete/mute/unmute/resume - see Javascript
  API example 4 for an illustration of the API in action
* ISSUE 58: Support added for multiple companions being laid over the top of each other
* ISSUE 146: Javascript FP playlist plugin modified to work effectively with playlists that include OVA ads
* ISSUE 130: Add support for script based companions
* ISSUE 173: Add support for DoubleClick DART

0.5.0 RC2 - May 20, 2010

* Added example 3 to the ad durations section to illustrate how to stop the OAS from taking
  the stream metadata duration as the default setting (via the "setDurationFromMetaData": false option)
* ISSUE 197: Added code to clean up overlays if stream is skipped through or skipped over
* ISSUE 151: Compatibility with Google Analytics (GATracker) - test case created, confirmation that
  tracking works as expected
* Added variable for Flowplayer player SWF on examples to allow Flowplayer player version
  to be easily switched
* ISSUE 204: Flowplayer playlist RTMP clips not working when netConnectionURL specified in
  the RTMP plugin settings. Fixed.
* ISSUE 159: Overlay Ads doesn't support Playlist. Verified as fixed.
* ISSUE 157: Overlays wont show when using FlowPlayer Playlists AND the overlay if the ONLY
  spot to display. Verified as fixed.
* ISSUE 160: Playlist items ignored if no ads to play. Verified as fixed.
* Added improved support for "image/jpeg|png|gif" and "application/swf" mime types on companions
  and also added a check for "image/jpg" just in case that's specified instead of "image/jpeg"
* ISSUE 168: applyToParts seems to be forcing clips to be dropped from the playlist - fixed.
* ISSUE 176: Add option to allow VAST "duration" to be ignored - sorted
* ISSUE 153: FlowPlayer looses navigation after add plays. Fixed with duration correction code
* ISSUE 38: Overlays not replaying - sorted - seeking through timeline will redisplay overlays
  if the "replayNonLinearAds:false" isn't set - see example
* ISSUE 211: Make sure debug defaults are set - defaults are now "firebug" and "fatal"
* ISSUE 203: Remove the use of the DeMonster debugger - removed
* ISSUE 182: Linear ads can also be scaled now if VAST values set and "enforceLinearVideoScaling"
  set to true. "enforceLinearInteractiveScaling:true" option added to turn on scaling for SWFs
* ISSUE 196: BaseURL can now be specified in the Flowplayer Common Clip and applied across a
  Flowplayer playlist
* ISSUE 50:	Turn off "click me" sign on linear ads when in fullscreen mode - now the sign hides
  after 3 seconds if there is no mouse activity
* ISSUE 215: Ampersands in the ad server URL cause JSON parsing problems for Flowplayer - fixed
  ampersands must now be replaced with __amp__ in the ad server URL string
* ISSUE 186: Click Me region shows if playlist controls used to skip ad - all overlays hidden
  at the start of a new stream
* ISSUE 88: RC1 messed up the scaling - tested and ensured "clip" scaling is correctly
  implemented. See Flowplayer examples 14 for an illustration of it working.
* Added support for "loop:false" on the modified JS Playlist Plugin so that a single clip
  with ads can be played
* Fixed exception thrown when bad VAST response (non XML or null) is returned
* "stagePaddingBottomWithControls" option added - see BOTR example

0.5.1 - August 4, 2010

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

0.5.2 - September 19, 2010

* Removed extra div from Javascript events example
* T60: Resolved defect that stopped a "start" time being set on show clips configured in a playlist
* Fixed bug where duration passed in via flashvars (e.g. "duration=30") wasn't being taken into account
  when scheduling as duration was not specified in timestamp format. Modified StreamConfg to validate
  duration format and convert to a Timestamp where required.
* T76: Resolved issue where linear ad "Click Me" region was showing on show stream post a mid-roll
* Added 1 mid-roll example under "ad-formats"
* Cleaned up "start-time" examples to cover mid-roll cases
* T101: Fixes to "ova-companions-jquery.js" to resolve issue where companions were not restoring
  post ad - there were bugs in the writeOriginal and readHTML functions
* T88: Linear ad stream tracking points were not being reset correctly in the beforeBegin handler - fixed.
* T95: onTrackingPointFired() exception cleaned up (was occurring when overlays replayed)
* T99: Resolved issue where timeline could be moved in first 300 milliseconds of linear ad. Now always
  disable before loading the ad clip
* T86: Fixed issue that resulted in replayed overlays overlapping or quickly disappearing
* T118: Fixed the bug that stopped the "click for more info" overlay being reshown after it was
  clicked once. Was a problem with the region hiding in RegionView.
* T121: Release moved to Flowplayer 3.2.3
* Javascript API calls made from the AS3 framework via ExternalInterface.call() are now turned off
  by default. To turn them on "canFireAPICalls" must be set to "true" in the config.
* T131: Added Flowplayer iPad plugin compatibility test example (hidden)
* Added "millisecondDelayOnCompanionInjection" to allow a delay to be inserted before injecting
  multiple companions on a page. Apparently injection many SWFs on 1 IE page can crash IE

0.6.0 - Current Trunk

* T163 - "activelySchedule": false option added to allow ads to be turned off. Empty ad schedule
  does not throw an exception now.
* T122 - Cleanup dist directory - remove old swfs
* T140 - Upgrade flowplayer version to 3.2.4
* T172 - Fixed the issue that meant that VAST1 wrapped ads fired double tracking events
* T173 - CloseButtonConfig now has the initialisation code that allows the sizing to be
  specified via the config
* T184 - scaling was throwing an exception when set on the clip - fixed - now converted to the
  correct Media type
* T185 - Fixed scenario where Flowplayer autoPlay is not consistently set when ad not played
* T170 - Added support for "failover ad servers" - see new example02 in examples/ad-servers
* Added Adform ad server examples and connector support
* Added support for "minimal" OVA pre-roll configuration via a new "ova.tag" config variable
* T197 - Media file selection now defaults to progressive first
* T211 - ClipEvent ERROR was being thrown by the player because the scaling value on show
  clips was being incorrectly set by OVA. Fixed.
* T212 - If playlist is configured with pre and post rolls, the javascript playlist controls
  are out of sync - fixed - also removed the 3.0.8 version of the Javascript playlist file.
  The one that is there is all that is needed (3.0.7)
* T19 - Skip Ad button options added (also T201)
* Filter out non-compatible linear media mime types (only allow flv, mp4, swf). Can be overridden
  with "acceptedLinearAdMimeTypes" and "filterOnLinearAdMimeTypes" config options
* Added Smartclip and Spotxchange linear configuration examples
--
* T224: Confirm that the handle to the control bar is valid before using it. Failure to do so
  results in an exception being thrown
* T225 - "setDurationFromMetaData" implemented for show streams
* T226 - Timestamp.secondsToTimestamp() fixed so that it produces the correct result. This was
  causing a problem with durations on playlist clips being read in when OVA initialises
* T228 - Have implemented config control for the VAST wrapped ad tag cache buster parameter
* Added Adap.tv ad server example
* T235 - Complete rewrite of the onMetaData set duration rules to fix issues with seeking
  for duration set pseudo-streams
* onLinearAdSkipped() Javascript callback added - this is fired when the skip button is hit
* T222 - No ads, no show clips no longer generates an exception when the play button is hit
-- RC3
* T255 - Added missing "allowScriptAccess" embed param on SWF companions
* Added "video/mp4" and "video/flv" to the accepted media file mime types for the plugin
* T256 - Modified AdSlot.isActive() to only return true if the Linear ad has media files
  or it has non-linears
* Added Google Analytics impression tracking
* Added SpotXChange VPAID example
* Javascript callback event support added for VPAID ads
* Added tagParams config option to allow additional parameters to be added to an ad tag
* T270 - Fixed condition ensuring VAST 2.0.1 is processed
* T71 - OVA for Flowplayer now works with BWCheck
* T266 - SWF companions now have <AdParameters> passed through if provided in the VAST response
* Ads config group variable "linearScaling" added to allow all ads to be forcibly scaled
  according to setting (e.g. with Flowplayer 'orig' will set all ads to their original
  scaling value)
* Ensured that companions that don't have a creativeType are displayed as images
* T223 - Improved RTMP Ad Stream support - "ad streamers" config block added and default
  URL splicing rules
* T287 - Added overlays on live streams example
* Upgraded to Flowplayer 3.2.7
* Fixed missing "connectionProviders" property on clip - was stopping clustering from working
* T286 - AdSlots and Stream have the same "ova.X" properties on them across products
* T295 - Removed "ova.hidden" custom property from Flowplayer Clip - caused debug exception
* T293 - Chained VAST2 and VAST1 (mixed version) wrappers now work
* T298 - Stopped wrapped ads firing Javascript API calls - was previously firing across
  multiple calls a wrapped chain
* SWF Companions now have the click tag passed as the following flashvar variables -
  "clicktag, clickTag, clickTAG"
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
* Added an example to illustrate how to use OVA with Flowplayer Secure Streaming
* Changed onVASTLoadSuccess(), onVASTLoadFailure(), onVASTLoadTimeout to onTemplateLoadSuccess(),
  onTemplateLoadFailure() and onTemplateLoadTimeout()
* Added Ads config group setting 'additionalParamsForSWFCompanions' to allow additional parameters
  to be added to the companion SWF object/embed tags as the code is inserted into the page
* Improved special case test cases (testing for bad/empty/no response etc.)
* Made sure original playlist Clip.metaData is carried through to new playlist post OVA processing
* Fixed an issue around setting the "metaData" property on a Flowplayer clip that was stopping
  the Javascript variable "fullDuration" from working. The metaData value is now the correct Object
  instead of a true or false value.
* Added "manage" ads.control config option to turn off OVA manipulation of the control bar
  when set to "false"
* Resolved the issue stopping HTTP bwcheck show streams from playing - the netConnectionUrl
  custom property was being set on the clip when it should have been null. Now null if the
  urlResolvers are set
* Modified the onMetaData duration logic to ensure that if the metadata duration is sub-second
  different than the VAST value, it is used as the duration. This should stop the ad streams
  occassionally hanging before completing
-- RC5
* Player volume is passed to VPAID ad on startup (unless muted)
* Added "parseWrappedAdTags" ad server config option to allow wrapped ad tags to be parsed
  for OVA variables and the appropriate substitutions made
* Added setActiveLinearAdVolume(volume) Javascript API
* Major change to filtering of linear mime types - now done at parsing time instead of post
  parsing to resolve an issue around selection of media type during parsing
* Fixed volume setting issue with VPAID ads. Now set to between 0 and 1
* Now sort the ad slots before scheduling
* Added support for "intervals" for repeated ad slots
* Added audio linear ad example
* Added Weborama ad server example
* Improved Javascript OVA API scheduleAds() so that a new playlist can be passed
* Fixed issue with fireAPICalls() that was resulting in javascript console errors - <AdParameters>
  and the full <Template> string are escaped() before being passed to the API - embedded iFrame
  seems seem to be the source of the issue

v1.0.0 RC7 - Jan 30 2012

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
* Fixed controls enabling calls to ensure that the build works against the current 3.2.8 trunk
* Bug fix ensuring that https click-throughs are correctly supported
* #356: Added support for passing <AdParameters> to non-linear VPAID ads
* #360 - Fixed bug stopping onShowXXX events not firing for show streams that don't
  have a duration specified

V1.0.1 RC2 - March 17 2012

* #356 - Reopened ticket to fix bug stopping <AdParameters> being passed into non-linear VPAID ads
* #371 - "addParamsToTrackingURL" option added to Google Analytics config to allow params to be
  turned off when tracking URL is formed
* #372 - "useDefaultPaths" option added to allow default paths to be turned off and effectively
  selectively track specific events by only specifying custom paths for those to be tracked
* Initial framework restructure to start removing redundant server classes
* #378 - OVA for Flowplayer "delayed" startup ad notice repositioning bug fixed - overlay controller
  was not being reset after "delayed" startup
* #380 - added a second, safety "SN" cuepoint in OVA for Flowplayer at 1 second to ensure that if the
  first < 1000 millisecond SN cuepoint doesn't fire (because of a Flowplayer bug), the second one
  seems to always fire at 1 second
* Added tracking point offset to SN event because it was not firing as a cuepoint at 0 with OVA for Flowplayer
* #379 - OVA for Flowplayer - RTMP playlist clips now work - netConnectionURL was not being
  correctly set if the clip was declared in a Flowplayer playlist
* Move OVA for Flowplayer to work with Flowplayer 3.2.8
* #373 - OVA for Flowplayer - Modified the modifyTrackingCuepoints() code to differentiate based on
  whether or not the "original cuepoints" are stored as an array of array of cuepoints, or just
  an array of individual cuepoints
* #389 - OVA for Flowplayer - "tag" minimal setting now supports 250x300 default companion as
  per equivalent setting in OVA for JW5. Modified minimal example to test this new default config
* #393 - Added support for VAST2 "nested" AdParameters because the XSD (but not the written spec)
  permits the AdParameters to be declared inside a <NonLinearAd> block
* Cleaned up the build process - ant build files created for OVA for JW5, new build commands
  (debug, release) for all products that allow "reduced size" versions of the SWC and
  SWFs to be built.
* #384 - OVA for Flowplayer bug stopping control bar showing when configured to show with
  VPAID ads has been fixed
* Moved OVA for Flowplayer release to use Flowplayer 3.2.9
* #421 - New option "setUrlResolversOnAdClips" added to "player" config group to allow OVA 
  to be instructed to not add "url resolvers" to ad clips if resolvers such as the SMIL 
  plugin are configured for use with show clips
* #427 - Fixed the bug stopping the skip ad button working correctly on OVA for Flowplayer 
  mid-rolls and the last post-roll in a playlist
  
V1.1.0 RC1 - May 2 2012

* #441 - qualified JSON class with full path to ensure that it compiles with Flex 4.6
* #442 - Changed the [embed] code to ensure that the code compiles with Flex 4.6 
  and runs with Flash 9
* OVA for Flowplayer now builds against Flowplayer 3.2.10 with Flex 4.6
* Modified the build process for OVA for Flowplayer so that it is completely self-contained. 
  The Flowplayer devkit is no longer required to build the source.
* #446 - play() API added to OVA
* Companions "html5" option renamed to "nativeDisplay": false - default setting is "true"
* "nativeDisplay":false option added to "ads" to allow an external library to be used if 
  requested for HTML5 non-linear ad display. Default is "nativeDisplay":true - this option 
  will override companions setting and can be used for companions as well
* VASTController.processCompanionsExternally() renamed to VASTController.processCompanionDisplayExternally()
* #451 - fixed defect stopping forced impressions firing for VAST2 wrapped tags with a 
  linear template ad
* #438 - Corrected the logic that was checking if the non-linear VPAID ad was playing 
  or not - this was incorrectly returning false causing VPAID non-linear ads to be reinitialised
* #436 - OVA for Flowplayer - onError not firing for bad stream URLs
* Upgraded Flowplayer package to include 3.2.11 (Flash 10.1 minimum requirement)
* #453 - SkipAd bug fixed where pause/resume automatically displayed the skipAd button 
  regardless of whether or not it was active via the "showAfterSeconds" option
* #452 - OVA for Flowplayer Bitrate Selection plugin now works with OVA ad clips - OVA 
  now sets an empty bitrate array on ad clips to ensure compatibility - "menu" option will 
  not work until new version of bitrateselect plugin issued with fixes for null exception
* #444 - Support added for AdTech extension event that tracks Click to Play and Auto start
* #459 - Fixed bug stopping wrapped on-demand linear ad does not play OVA for Flowplayer - 
  the first ad was being taken on the returned template and at times, that ad may actually 
  be a holding companion or an empty ad
* #460 - Flash content now loaded in it's own ApplicationDomain() as per the VPAID spec - 
  was throwing an exception on SpotXChange ads
* #461 - Fixed wrapper issue that meant that a pre-roll wasn't correctly matched if a 
  wrapper had an empty non-linear ad block as well as the linear template  
* #437 - Support expandable regions that map to the standard and expanded dimensions provided 
  in a VAST response - best for VPAID ads to ensure that the region doesn't cover the full 
  player display
* #464 - onAdCall methods made into Javascript callbacks. onAdCallFailover() event added, 
  hasAds value added to onAdCallComplete() callback and sequence number added to all ad 
  requests passed in onAdCall callbacks 
* #434 - Fixed preferred display mode example 4 - bad config cleaned up
* #456 - Added test case to validate that depreciated overlays.closeButton is converted 
  correctly to the new regions.closeButton format
* #449 - Missing impression and tracking events from VideoAd javascript object resolved. 
  VideoAd.impressions and VideoAd.trackingEvents added to callback object
* #447 - Flowplayer 3.2.8,9,10,11 delayed startup bug fixed. _player.stop() forced before 
  loading the new ad scheduling playlist for these player versions.  
* #468 - VPAID ads not fire the "collapse" tracking event when their expanded state 
  changes to collapsed  
* #476 - Close tracking event is now triggered on "SkipAd"
* #474 - Rules around handling of VPAID expanded and linear state change modified - expand/contract 
  does not pause/resume the underlying stream now - only linear ad change does for non-linear ads. 
  Also introduced a new option 'adsConfig.vpaidConfig.pauseOnExpand' and 'resumeOnCollapse' to 
  allow pause/resume to be forced with expand/contract    
* Ticket #477 - An additional safety value has been added into OVA for Flowplayer to ensure that 
  ad messages are cleared when show streams play. Clearing is now done on both the 
  "onBeforeBegin" and "onBegin" events  

V1.1.0 RC2 - July 1, 2012

* #485 - bug stopping "enforceMidRollPlayback" from working if pre-rolls are configured has been fixed
* OVA for Flowplayer now skips enforcing a mid-roll if there isn't a mid-roll to play (in the case where 
  the ad tag didn't provide one)
* Upgraded to Flowplayer 3.2.12
* Add two new Javascript api - pause() and resume()

V1.1.0 Final - July 13, 2012

* #489 - Added Zedo ad server examples
* #498 - Added "player.applyCustomClipProperties" config option to allow Flowplayer common clip
  custom properties to be optionally added to ad clips

V1.2.0 RC1 - November 18, 2012

* Implemented stop() Javascript API interface
* Fixed bug stopping player width and height being passed into the ad tag for use with ad tag variables 

V1.2.0 RC1 - November 30, 2012

* Added option "shortenLinearAdDurationPercentage" to reduce the size of the linear ad duration
  used to determine the tracking points
 
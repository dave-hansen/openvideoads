Change Log

0.2.1 - July 15, 2009

* Initial release to support JW Player development

0.3.0 - August 20, 2009

* Major upgrade - callbacks to the plugin on framework status are now "event" based
* Integrated support for overlays within the framework
* Extensions to support new ad server integrations
* Major modifications to the config framework to support a unified JSON approach
  across the JW and Flowplayer Open Ad Streamer plugins
* Support for firebug debug output
* Many bug fixes

0.3.1 - August 31, 2009

* "autoStart" parameter changed to "autoPlay" in configuration objects and API
* RegionView.as: set "mouseChildren=false" so that the hand shows over the text on the overlays
* CrossCloseButton.as: Regions can now be clicked to close (including the Ad Notice)
* Config.as: "autoPlay" correctly implemented - only available at top level
* Config.as: "contiguous" option name changed to "allowPlaylistControl"
* OpenVideoAdsConfig.as: tracking configuration added and tracking URLs
* Built in support for the various non-linear types (text, html, image and swf) in the
  "model" and "ads.template" components
* Templating now supported for overlays/regions (default and config based)

0.3.2 - September 1, 2009

* Added NetworkResource.qualifiedHTTPUrl() so that click through URLs will always be
  checked that they start with "http://" before they are fired off
* Modification of VAST parsing code for non-linear ad types - only image and swf
  require a "creativeType" to be defined now - text and html just need "resourceType"
* Fixed OverlayController.hideNonLinearOverlayAd() so that overlays are hidden based
  on either "position" or the "regions" Ad Slot param
* ISSUE 24: + (close) button turned off on the "system-message" region by default.
  This means that the "this is an ad message" doesn't show close by default
* ISSUE 26: Support added to track "unmute" events
* ISSUE 27: Support added to VASTController track "pause and resume" events
* ISSUE 18: Deprecation of "selectionCriteria" config param - replaced with "adTags"
* ISSUE 28: Changed "_activeStreamIndex" to "_playlist.playingTrackIndex" for use
  in onPlayer type events (e.g. on fullscreen etc.)

0.3.3 - September 6, 2009

* ISSUE 18: "adTags" should have been "adParameters" - fixed
* Flash overlays loading - required Security.allowDomain() to be used. An additional
  config parameter "allowDomains" has been added to the AdConfigGroup - this parameter
  is used by the Security.allowDomain() call - "*" is the default.
* ISSUE 5: All default overlay sizes now supported with standard region definitions
* ISSUE 36:	Flowplayer - Ad Notice positioning on fullscreen was incorrect - placed very
  wide so the ad notice disappeared - fixed now
* ISSUE 44: Have changed the logic in the region matching functions RegionController.getRegion()
  and RegionController.getRegionMatchingContentType() to return a DEFAULT_REGION if no match is
  found - this is a safety valve for the case where no sizing info is provided in the VAST template.
  The default template is "reserved-bottom-w100pct-h50px-transparent"
* ISSUE 35:	'Click me call to action' region doesn't show when ad replayed - same for ad
  notices - the show/hide ad notice event is not firing because it's marked as hit
  and the show/hide 'click me' region is tied to start/end ad events that aren't firing.
  Changed so that ad notice events are always refired, and click me show/hide tied to that event
* If not "creativeType" provided for a static "resourceType" image is assumed.
* All overlay types (text, html, image, flash) successfully tested
* Templates added to allow overlay formats to be changed as needed
* "playOnce" configuration wasn't being set at the top level. Missing code from
  AbstractStreamConfig added to set it.
* Support added to change ad notice text size from normal to small - size:smalltext|normaltext

0.3.4 - October 6, 2009

* ISSUE 49: "adParameters" values moved to end of OpenX URL to allow "source" to be overridden
* ISSUE 76: Event callback added for Overlay CLOSE_CLICKED
* ISSUE 77: Config option added to allow overlays to stay visible after being clicked (only for 'click to web')
* ISSUE 33: Text overlay text looks washed out - now _text.blendMode = BlendMode.NORMAL;
* ISSUE 78: "deliveryType" config option set to "any" by default - meaning in most cases,
  this option is no longer required - removed from examples
* ISSUE 68:	Click through mouse over sign does not show if Ad Notice turned off - fixed
* ISSUE 78:	"deliveryType" is this really needed? No longer - need removed. Default setting
  is "any", but "progressive" or "streaming" can be used to limit the choice - example 10
* ISSUE 49:	OpenX targeting by "source" value in the URL - adParameters are now appended
  to the end of the OpenX VAST request rather than mid URL - this allows a "source"
  parameter to be specified in the "adParameters" - in addition a check is made
  to the "adParameters" value - if "source" is there, the default value is removed
* ISSUE 40 & ISSUE 80: Change "streamType" configuration to be generalised - default is now "any"
  all-example41 created to test/illustrate new streamType configuration
* ISSUE 88:	Flowplayer custom clip properties not imported - "player" config grouping added
  at general, stream, ads and ad slot levels. See FP all-example44.html
* ISSUE 89:	Option to turn off click me message on linear ads - "enabled" option now
  permitted in the "clickSign" config to turn the click through notice on/off - it is on by default
* ISSUE 87:	Issues with "applyToParts" config - many fixes - see FP test cases 01-12.html
* ISSUE 96:	Support load of MRSS format in place of "shows"
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

0.5.0 - December 4, 2009

* If OpenX is used, requires OpenX server side Video plugin v1.2
* ISSUE 129 - Restore JS Event API - see Javascript API doc on google code site for details - support
  for events and region styling added - see all-example56.html
* ISSUE 140: Ampersand in OpenX "targeting" parameters breaks JSON parser - customProperties can
  now be specified either as a single param (e.g. "gender=male") or as an array
  (e.g. ["gender=male", "age=20-30"]) - Arrays will be converted to ampersand delimited parameter
  strings (e.g. gender=male&age=20-30
* ISSUE 141 - Support added for JW Player preview images - see all-example57.html
* ISSUE 146: Add support for creativeType="image/jpg" etc. - changed NonLinearVideoAd.as to
  strip out any prefixes like "image/" etc.
* ISSUE 147: Impression tracking should be fired on empty VAST ads - see all-example58.html - as
  per the AOL/AdTech request - new configuration option "forceImpressionServing" added to the
  AdServer config - set to "true" by default for AdTech, false for others.
* ISSUE 148: url tags not being processed in non linear ad VAST responses when creativeType
  is set as mimeType (e.g. "image/jpg" etc.). The OpenX Video Ads plugin 1.2 now produces
  mimeType creativeType values.
* ISSUE 149: overlay <code></code> tags not being correctly processed by overlay display
  code. Fixed now - code just inserted - templates just used for <url></url> values

0.5.1 - March 22, 2010

* Linear Interactive ads now supported:
   * Support for "maintainAspectRatio=true|false" specified on the MediaFile VAST tag (see examples 59,65,66)
   * Support for "scale=true|false" specified on the MediaFile VAST tag (see examples 59,65,66)
* Added the ability to have an ad notice that includes a dynamic countdown of the remaining
  ad duration in seconds (see all-example68.html)
* Ad related custom properties set on the clip object - "title" is set as "advertisement - [title]",
  "ovaAd", "ovaSlotId", "ovaPosition", "ovaZone" and "ovaAssociatedStreamId"". A "description" has
  also been added - see all-example69.html
* Fixed the bug that meant that show streams were ignored if there wasn't an ad provided for the stream
  (given that an ad slot was defined for the stream) - extra condition added to StreamSequence.build()
* Changed region creation logic so that defaults are always created and then the specific config
  specified regions can override
* 24/7 Real Media OAS (ad server) support added (www.247realmedia.com) - thanks to
  Pedro Faustino for the code. See org.openadstreamer.vast.server.oas for the codebase.
  Also see example-XXX
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
* ISSUE 187: Add support for direct entry of ad tag in ad server definition - see example
  ad-servers/example02.html for a worked example (Google DART VAST 2.0)
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

0.5.2 - May 20, 2010

* Added condition to stop tracking points being created if ad stream duration is 0
* ISSUE 191: Add support for VAST2 companion ad parameters - done - see FP scaling examples
* Fixed exception thrown when bad VAST response (non XML or null) is returned

0.5.3 - August 4, 2010

* Changed the click processing on SWF overlays - if there is not VAST click-through event
  to be fired, click tracking is done by the SWF itself
* Support added for iFrame companion ads - for both VAST 1 and VAST 2.0
* Changed the click processing on SWF overlays - if there is not VAST click-through event
  to be fired, click tracking is done by the SWF itself
* Support added for iFrame companion ads - for both VAST 1 and VAST 2.0
* Fixed ad notice countdown timer so that it's based on stream played duration
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
* Remove newlines and escape quotes in the HTML companion content before writing it to the DIV
* Safety mechanism implemented to ensure that the Click-Through region is turned off when
  a clip stops playing (to deal with the case where the end linear ad events don't fire because
  the ad duration is wrong in metadata and/or VAST)
* Fixed defect that stopped companions being re-displayed when replayed. Reset the activeDivID to null
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
* Fixed initial positioning of overlays to reflect bottom margin based on controlbar visibility
* No longer requires case sensitive event types in the VAST response (e.g. "Start" will match as does "start")

0.5.4 - September 19, 2010

* T60: Changed Stream.isSlicedStream() to use isSlice() rather than look at the start time - using the
  start time caused an issue in the Flowplayer and JW plugins where a show stream had a start time
  specified - it stopped the start time being set on the clip
* Fixed bug where duration passed in via flashvars (e.g. "duration=30") wasn't being taken into account
  when scheduling as duration was not specified in timestamp format. Modified StreamConfg to validate
  duration format and convert to a Timestamp where required.
* T101: Fixed the VAST1 wrapper defect where the AD id was being passed as a string rather than the
  new object format that VAST2 parsing uses for ad ids.
* Modified the event firing logic to always refire events - it doesn't make sense to stop events
  refiring when ads were reshown - change made to EventTracking.execute()
* Added new debug level "none" to allow all debug to be turned off
* T118: Fixed the bug that stopped the "click for more info" overlay being reshown after it was
  clicked once. Was a problem with the region hiding in RegionView.
* Javascript API calls made from the AS3 framework via ExternalInterface.call() are now turned off
  by default. To turn them on "canFireAPICalls" must be set to "true" in the config.
* T132: Pre-defined overlays now created on-demand rather than all at once on initialisation
* Added "millisecondDelayOnCompanionInjection" to allow a delay to be inserted before injecting
  multiple companions on a page. Apparently injection many SWFs on 1 IE page can crash IE
* T135: VideoAdServingTemplate - changed impressionElement.id to impressionElement.@id
* T149: Fixed the issue that stop companions being displayed when their IDs are "" - previously
  the matching condition matched two different companions with blank IDs. No longer happens.

0.6.0 - Development trunk

* T163 - "activelySchedule": false option added to allow ads to be turned off.
* T172 - Fixed the issue that meant that VAST1 wrapped ads fired double tracking events
* T173 - CloseButtonConfig now has the initialisation code that allows the sizing to be
  specified via the config
* T177 - Click tracking not called on LinearAds - fixed
* T178 - variable substitution not occuring on "tags" - fixed
* Removed obsolete Debuggable.DEBUG_STREAM_CONNECTION and replaced with Debuggable.DEBUG_OBJECTS
  and fixed doLogAndTrace() to use mx.utils.ObjectUtils.toString() to dump the object contents
* T187 - The ID attribute from an <ad> tag is now stored in the VideoAdV2 class as "containerAdId"
* Added Adform ad server examples and connector support
* T197 - Media file selection now defaults to progressive first
* SWC renamed to ova-as3-[version].swc (since it now includes the VPAID implementation)
* DEBUG_CONTENT_ERRORS debug level replaced with DEBUG_VPAID
* T206 - Companion SWFs that have a click through URL specified in the VAST response now
  have that URL passed into the companion SWF as a "clickTAG" flash var - required by Adify
* T210 - Added support for the pre V1.0 public comment spec - where no inline/wrapper tag is
  supported and <VideoDuration> is used instead of <Duration>
* T207 - Cache buster parameter now added to end of wrapped ad tag URIs as per the VAST2 spec
* Added support for the AdForm ad server
* T216 - Fixed - any stream with SWF in the path didn't get an ad slot scheduled against it - this
  was the result of a poor regex determining whether a show stream is a stream or image
* T19 - Skip Ad button options added
* T197 - Media file selection now defaults to progressive first
-- RC2
* T217 - support added for a "__page-url__" param to be inserted into an ad tag
* Extra check in VAST 2 parsing to make sure that a VPAID linear ad has the right mime type
  and if that isn't present, that the file doesn't have a stream file extension
* T226 - Timestamp.secondsToTimestamp() fixed so that it produces the correct result. This was
  causing a problem with durations on playlist clips being read in when OVA initialises
* T227 - Fixed Timestamp.secondsToTimestamp() so that it always returns HH:MM:SS
* T228 - Have implemented config control for the VAST wrapped ad tag cache buster parameter
* T230 - Ophan VAST2 companions are now attached correctly to video ads - previously only
  1 (the last) companion was attached as the list kept getting overwritten
* Stopped companions of the same size overwriting each other when inserted into the page.
  The first in the list gets priority placement
* onLinearAdSkipped() Javascript callback added - this is fired when the skip button is hit
-- RC3
* Added support for Adotube ad server type
* T255 - Added missing "allowScriptAccess" embed param on SWF companions
* T256 - Modified AdSlot.isActive() to only return true if the Linear ad has media files
  or it has non-linears
* Added Google Analytics impression tracking
* T270 - Fixed condition ensuring VAST 2.0.1 is processed
* Added tagParams config option to allow additional parameters to be added to an ad tag
* Added check to "zone" value - if it's not a string, convert when building the ad schedule
* Ensured that companions that don't have a creativeType are displayed as images
* T223 - Improved RTMP Ad Stream support - "ad streamers" config block added and default
  URL splicing rules
* T293 - Chained VAST2 and VAST1 (mixed version) wrappers now work
* Added support for "HTML" region templates based on the VAST2 HTMLResource tag
* Added support for VAST1 impressions urls to be specified without requiring the <URL> tags
* T304 - added support for custom resizing of the click through region based on the
  Y position of the control bar
* Ensured that HTML code blocks are inserted into HTML templates - previously if there
  was a codeblock, it would just override the template setting completely. Default
  HTML template is "<body>__code__</body>"
* Added support for VAST1 wrapper <VASTAdTagURL> tagset to be used with a VAST2 wrapper
  in place of <VASTAdTagURI>. Although not compliant, it seems to be used by DART in some cases.
* Fixed issue where mediafile scaling info was not carrying through to wrapped ads. Wrapper
  did not have overrides on the canScale() methods.
* Fixed issue where impressions where not firing from a VAST template with VPAID ads
* Resolved issue where overlay close button was being disabled if a pre-roll was also configured
* A configuration option has been added to allow a timeout value to be set on ad calls - this
  stops ad servers blocking the player if they don't return a value and hold the call open
* Fixed issue that stopped "keepOverlayVisibleAfterClick" working with custom regions
* Changed the click through logic to ensure that IE browsers use the ExternalInterface("window.open")
  rather than the AS3 navigateToURL() method - this fixes an issue where IE popup blockers
  blocked click throughs if the wmode was set to opaque
* Region property "backgroundTransparent: true" wasn't implemented - it is now
* Ensured click through URL details etc. are included in the ad object passed back in the
  Javascript callbacks
* Added support to allow the default ad title and description to be changed
* Changed onVASTLoadSuccess(), onVASTLoadFailure(), onVASTLoadTimeout to onTemplateLoadSuccess(),
  onTemplateLoadFailure() and onTemplateLoadTimeout()
* Added Ads config group setting 'additionalParamsForSWFCompanions' to allow additional parameters
  to be added to the companion SWF object/embed tags as the code is inserted into the page
* Added "manage" ads.control config option to turn off OVA manipulation of the control bar
  when set to "false"
* Fixed bug stopping companions without a creative or sequence ID being attached to creatives
  without companions (changed '== null' to StringUtils.isEmpty())
* Modified VideoAd.isLinear() and VideoAd.isNonLinear() logic so that an ad is determined to be
  linear if it does not have any non-linears attached, and non-linear only if it has non-linears
  attached (it used to exclude any ads that also had linear ads which was wrong)
* Added support for the referrer to be manually set and passed into a VPAID ad
* Modified VAST1 parsing logic for non OpenX ad servers - inline ads with multiple ad units
  are now split into separate ads unless the "ensureSingleAdUnitRecordedPerVAST1InlineAd"
  option is used
* Added a VASTController.unload() call to allow any open URLLoaders and SWFs to be forcibly
  closed by the parent SWF
* Stopped wrapper URLs being called if the content of the <url/> tag is empty
-- RC5
* VASTController. preprocessImpressionsToForceFire() has been renamed to
  VASTController.processImpressionFiringForEmptyAdSlots()
* "ads" config option "resetTrackingOnReplay: true|false" added to allow the tracking tables
  to be reset after an ad has played
* Added "parseWrappedAdTags" ad server config option to allow wrapped ad tags to be parsed
  for OVA variables and the appropriate substitutions made
* Major change to filtering of linear mime types - now done at parsing time instead of post
  parsing to resolve an issue around selection of media type during parsing
* Added VASTController.playerVolume API (this is used by non-linear VPAID ad on init())
* Resolved namespace issue with inbound Javascript API calls. External API now starts
  with "ova" (e.g. "ovaGetVersion()")
* Added support for mixing grouped ad calls and individual ad calls to provide better
  support for ad "stories"
* Now sort the ad slots before scheduling
* Added support for "intervals" for repeated ad slots
-- RC6
* Added a "__referrer__" ad tag variable and replaced the vpaid referrer with
  BrowserUtils.getReferrer()
* Added onTrackingEvent(), onImpressionEvent(), onClickTrackingEvent(), onCustomClickTrackingEvent()
* Added support for on-demand overlays
* Added a new OVA ad tag variable - "__domain__"
* Fixed the bug stopping wrapped timed out ad calls failing over
* Removed use of Tweener lib
* Ad server type now defaults to "direct"
* Added "encodeVars" config option to force OVA variable encoding in ad tags
* Removed Debuggable.DEBUG_OBJECTS, added Debuggable.DEBUG_ANALYTICS
* Added improved Google Analytics tracking support for ad calls, template and on-demand
  ad slot loading
* Fixed issue with fireAPICalls() that was resulting in javascript console errors - <AdParameters>
  and the full <Template> string are escaped() before being passed to the API - embedded iFrame
  seems seem to be the source of the issue

v1.0.0 RC7 - Jan 30 2012

* Bitrate selection now working
* Removed need to specify holding clip URL and set default to the Longtail CDN path
* Depreciated "overlays" group in favour of new "regions group" - OverlaysGroupConfig class
  renamed to RegionsGroupConfig
* Modified region placement code
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

v1.0.1 RC1 - Feb 17 2012

* Corrected event firing for non-linear VPAID ads so that tracking events (such as creativeView)
  that are declared with the non-linear creative are also correctly fired
* Bug fix ensuring that https click-throughs are correctly supported
* #356: Added support for passing <AdParameters> to non-linear VPAID ads
* #360 - Fixed bug stopping onShowXXX events not firing for show streams that don't
  have a duration specified
* #358 - Added support for Javascript overlays
* #354 - GA Tracking URLs modified to ensure that they are no longer always unique and
  components are always URIComponentEncoded()
* #339 - Fix for IE6 SWF companions - they now insert/show correctly

V1.0.1 RC2 - March 17 2012

* #356 - Reopened ticket to fix bug stopping <AdParameters> being passed into non-linear VPAID ads
* #371 - "addParamsToTrackingURL" option added to Google Analytics config to allow params to be
  turned off when tracking URL is formed
* #372 - "useDefaultPaths" option added to allow default paths to be turned off and effectively
  selectively track specific events by only specifying custom paths for those to be tracked
* Initial framework restructure to start removing redundant server classes
* #377 - bitrate selection fixed for VAST2 responses
* onAdCallStarted, onAdCallComplete events added
* onVPAIDAdLoading event added
* Added tracking point offset to SN event because it was not firing as a cuepoint at 0 with
  OVA for Flowplayer
* #382 - Added "ads.vpaid.enableLinearScaling" and "ads.vpaid.enableNonLinearScaling" options
  to ensure that OVA triggered "scaling" can be forcibly turned off
* Added VPAIDNonLinearLoading/Loaded,  VPAIDLinearLoading/Loaded events
* Added includesLinearAds() and calledOnDemand() methods to AdCallEvent class
* Cleaned up the build process - ant build files created for OVA for JW5, new build commands
  (debug, release) for all products that allow "reduced size" versions of the SWC and
  SWFs to be built.
* #397 - Fixed the bug around the duplicate internal display of VPAID ads if HTML5 and Flash
  display modes are both enabled in the config
* #390 - Implemented "preferred" display mode to support HTML5 preferential display with a
  fallback to Flash for VPAID non-linears. Also supports Flash preferential display by
  default with a fallback to HTML5 for iFrames and Javascript creative types
* #399 - Ad calls across multiple ad slots with "repeated" positions are now grouped
  by the "ad slot" - AdServerConfig.uid added to group name
* #405 - "maxDisplayCount" option added to ensure that a maximum number of non-linear
  ads are shown when multiple display modes are enabled
* #410 - non-linear ad slots without a duration are now supported - the duration is
  set to 4hrs by default
* #412 - fixed defect causing click-through popup to fail if scriptaccess="never"
* #348 - Resolved bug stopping bitrate selection based on a range e.g. "400-600" from
  working - implemented LinearVideoAd.getSpecificallyRatedMediaFile()
* #411 - group ad calls are now correctly supported for mid-rolls - this allows
  "ad stories" to be scheduled
* #414 - changes made to the VAST2 parser to ensure that impressions can be force
  fired if an empty VAST2 response is received with impressions specified
* #415 - VideoAd.getPreferredDeliveryType() was returning "progressive" by default -
  "any" is now the default delivery type that is returned.
* #425 - Fixed the bug stopping impression firing on empty VAST2 responses on ad
  calls with "forceImpressionFiring"
* VAST1 wrappers calling VAST2 tags but getting an empty response can now have
  impressions forcibly fired

V1.1.0 RC1 - May 2 2012

* #441 - qualified JSON class with full path to ensure that it compiles with Flex 4.6
* #442 - Changed the [embed] code to ensure that the code compiles with Flex 4.6
  and runs with Flash 9
* #445 - 'player.showBusyIcon' option added to allow the "ova busy" sign to not be shown
* Companions "html5" option renamed to "nativeDisplay": false - default setting is "true"
* "nativeDisplay":false option added to "ads" to allow an external library to be used if
  requested for HTML5 non-linear ad display. Default is "nativeDisplay":true - this option
  will override companions setting and can be used for companions as well
* VASTController.processCompanionsExternally() renamed to VASTController.processCompanionDisplayExternally()
* #451 - fixed defect stopping forced impressions firing for VAST2 wrapped tags with a
  linear template ad
* #438 - Corrected the logic that was checking if the non-linear VPAID ad was playing
  or not - this was incorrectly returning false causing VPAID non-linear ads to be reinitialised
* #453 - SkipAd bug fixed where pause/resume automatically displayed the skipAd button
  regardless of whether or not it was active via the "showAfterSeconds" option
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
* #468 - VPAID ads not fire the "collapse" tracking event when their expanded state
  changes to collapsed
* #469 - Fixed bug causing VideoAd.toJSObject() to throw an exception with VAST extensions
* Changed behaviour of non-linear VPAID ads on expand/collapse - player not paused on 
  expansion/resumed on contraction. Now paused/resumed on linear change
* #476 - Close tracking event is now triggered on "SkipAd"

V1.1.0 RC2 - July 3, 2012

* Added a mechanism to convert companion sizing if specified as strings
* #481 - OpenX ad calls are now "batched" again by default
* #479 - Static ad tags can now cover multiple ad slots

V1.1.0 Final - July 13, 2012

* #491 - Defect stopping wrapper click tracking URLs firing has been fixed
* Fixed impression tracking bug with VPAID ads that are delivered via wrappers - 
  impressions now correctly fire across all wrappers

V1.2.0 RC1 - July 20, 2012

* #493 - Empty ads are now stripped from wrapped responses if 'forceImpressionServing'
  is  not active. This ensures that wrappers with multiple wrapped tags produce
  results if the early responses are empty.

V1.2.0 RC1 - November 18, 2012

* Fixed bug stopping player width and height being passed into the ad tag for use with ad tag variables  
  
V1.2.0 RC1 - November 30, 2012

* Added option "shortenLinearAdDurationPercentage" to reduce the size of the linear ad duration
  used to determine the tracking points

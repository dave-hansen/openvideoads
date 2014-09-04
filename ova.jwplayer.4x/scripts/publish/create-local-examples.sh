#!/bin/sh

# Global variables - setup as required - make sure slashes etc. are always escaped as per sed/regex requirements

OVA_DIST_JS_2="..\/..\/..\/dist\/js\/"
OVA_DIST_JS_3="..\/..\/..\/..\/dist\/js\/"
OVA_DIST_CSS_2="..\/..\/..\/dist\/css\/"
OVA_DIST_CSS_3="..\/..\/..\/..\/dist\/css\/"
OVA_DIST_TEMPLATES_2="..\/..\/..\/dist\/templates\/"
OVA_DIST_TEMPLATES_3="..\/..\/..\/..\/dist\/templates\/"
OVA_DIST_IMAGES_2="..\/..\/..\/dist\/images\/"
OVA_DIST_IMAGES_3="..\/..\/..\/..\/dist\/images\/"

# Do not modify beyond here

ACTIVE_OVA_OAS_VERSION="ova-jw.swf"
OVA_JW_VERSION="4x"
OVA_JW_RELEASE_NUMBER="1.0.0"
OVA_DEBUG="fatal, config, vast_template, vpaid, playlist, api, analytics, http_calls"

# OpenX addresses

OVA_OPENX_API="http:\/\/openx.openvideoads.org\/openx\/www\/delivery\/fc.php"

# Streaming server base addresses

OVA_HTTP_BASE_URL="http:\/\/streaming.openvideoads.org\/shows"
OVA_RTMP_BASE_URL="rtmp:\/\/ne7c0nwbit.rtmphost.com\/videoplayer"
OVA_PSEUDO_BASE_URL="http:\/\/streaming.openvideoads.org:81\/shows"

# Specific streaming configuration properties

OVA_PSEUDO_STREAMER_PARAMS="\&type=http"

# Specific streams

OVA_HTTP_SHOW_STREAM_1="http:\/\/streaming.openvideoads.org\/shows\/the-black-hole.mp4"
OVA_PSEUDO_SHOW_STREAM_1="http:\/\/streaming.openvideoads.org:81\/shows\/the-black-hole.mp4"
OVA_RTMP_SHOW_STREAM_1="rtmp:\/\/ne7c0nwbit.rtmphost.com\/videoplayer\/the-black-hole.mp4"
OVA_RTMP_SHOW_STREAM_FILE="mp4:the-black-hole.mp4"
OVA_HTTP_SHOW_STREAM_FILE="the-black-hole.mp4"
OVA_HTTP_SHOW_STREAM_FILE_FLV="the-black-hole.flv"

# Specific static files (VAST responses, images and playlists)

OVA_COMPANIONS_VAST_1="${OVA_DIST_TEMPLATES_2}companions\/companions-vast1.xml"
OVA_COMPANIONS_VAST_2="${OVA_DIST_TEMPLATES_2}companions\/companions-vast2.xml"
OVA_COMPANIONS_VAST_NO_CREATIVE_TYPE="${OVA_DIST_TEMPLATES_2}companions\/companions-no-creative-type-vast1.xml"
OVA_INTERACTIVE_PREROLL_1="${OVA_DIST_TEMPLATES_2}interactive\/interactive-preroll.xml"
OVA_INTERACTIVE_PREROLL_2="${OVA_DIST_TEMPLATES_2}interactive\/interactive-preroll2.xml"
OVA_INTERACTIVE_PREROLL_3="${OVA_DIST_TEMPLATES_2}interactive\/interactive-preroll3.xml"
OVA_INTERACTIVE_PREROLL_4="${OVA_DIST_TEMPLATES_2}interactive\/interactive-preroll4.xml"
OVA_VAST_MP4_RTMP_AD_WITH_MARKERS="${OVA_DIST_TEMPLATES_2}rtmp-ads\/vast1-mp4-with-markers.xml"
OVA_VAST_MP4_RTMP_AD_NO_MARKERS="${OVA_DIST_TEMPLATES_2}rtmp-ads\/vast1-mp4-no-markers.xml"
OVA_VAST_MP4_RTMP_AD_NO_MARKERS_NO_MIME_TYPE="${OVA_DIST_TEMPLATES_2}rtmp-ads\/vast1-mp4-no-markers-no-mime-type.xml"
OVA_VAST_MP4_RTMP_AD_NO_MARKERS_NO_MIME_TYPE_NO_EXTENSION="${OVA_DIST_TEMPLATES_2}rtmp-ads\/vast1-mp4-no-markers-no-mime-type-no-extension.xml"
OVA_VAST_FLV_RTMP_AD_WITH_MARKERS="${OVA_DIST_TEMPLATES_2}rtmp-ads\/vast1-flv-with-markers.xml"
OVA_VAST_FLV_RTMP_AD_NO_MARKERS="${OVA_DIST_TEMPLATES_2}rtmp-ads\/vast1-flv-no-markers.xml"
OVA_VAST_FLV_RTMP_AD_NO_MARKERS_NO_MIME_TYPE="${OVA_DIST_TEMPLATES_2}rtmp-ads\/vast1-flv-no-markers-no-mime-type.xml"
OVA_EMPTY_VAST_RESPONSE="${OVA_DIST_TEMPLATES_2}error-responses\/vast1.0\/empty-ad-vast-response.xml"
OVA_BLANK_VAST_RESPONSE="${OVA_DIST_TEMPLATES_2}error-responses\/vast1.0\/blank-vast-response.xml"
OVA_BAD_VAST_RESPONSE="${OVA_DIST_TEMPLATES_2}error-responses\/vast1.0\/bad-vast-response.xml"
OVA_BAD_VAST_XML="${OVA_DIST_TEMPLATES_2}error-responses\/bad-xml.xml"
OVA_ZERO_DURATION_VAST="${OVA_DIST_TEMPLATES_3}error-responses\/vast1.0\/zero-duration.xml"
OVA_VAST_1_WRAPPER_RESPONSE="${OVA_DIST_TEMPLATES_2}wrapper\/vast1-wrapper.xml"
OVA_VPAID_LINEAR_1_VAST="${OVA_DIST_TEMPLATES_3}ad-servers\/eyewonder\/vpaid-linear-01.xml"
OVA_VPAID_NON_LINEAR_1_VAST="${OVA_DIST_TEMPLATES_3}ad-servers\/eyewonder\/vpaid-non-linear-01.xml"
OVA_VPAID_LINEAR_2_VAST="${OVA_DIST_TEMPLATES_2}ad-servers\/eyewonder\/vpaid-linear-01.xml"
OVA_VPAID_NON_LINEAR_2_VAST="${OVA_DIST_TEMPLATES_2}ad-servers\/eyewonder\/vpaid-non-linear-01.xml"
OVA_VPAID_LINEAR_4_VAST="${OVA_DIST_TEMPLATES_2}ad-servers\/iroll\/vpaid-linear-01.xml"
OVA_RSS_PLAYLIST_1="${OVA_DIST_TEMPLATES_2}playlists\/playlist.rss"
OVA_RSS_PLAYLIST_2="${OVA_DIST_TEMPLATES_2}playlists\/example12.rss"
OVA_RSS_PLAYLIST_3="${OVA_DIST_TEMPLATES_2}playlists\/example08.rss"
OVA_MRSS_PLAYLIST_1="${OVA_DIST_TEMPLATES_2}playlists\/botr.mrss"
OVA_SMIL_PLAYLIST="http:\/\/hwcdn.net\/y9t7g4w7\/fms\/streaming\/Passion.mp4.smil"
OVA_LOGO_IMAGE="${OVA_DIST_IMAGES_2}logo.png"
OVA_TEST_SKIN="..\/..\/..\/dist\/skins\/snel.swf"
OVA_EXAMPLE_OVERLAY_CUSTOM_BUTTON="${OVA_DIST_IMAGES_2}button-custom-sepia.png"
OVA_THUMBNAIL_IMAGE="${OVA_DIST_IMAGES_2}logo.png"
OVA_BLANK_PIXEL_IMAGE="http:\/\/static.openvideoads.org\/ads\/blank\/blank-pixel.jpg"
OVA_BLANK_WITH_PLAY_BUTTON_IMAGE="..\/..\/..\/dist\/images\/blank-with-play-button.png"
OVA_SKIP_BUTTON_IMAGE_ALT_1="${OVA_DIST_IMAGES_2}skip-ad-alt-1.jpg"
OVA_OPENX_V3_HOSTED="http:\/\/oxdemo-d.openxenterprise.com\/v\/1.0\/av"
OVA_DELAYED_RESPONSE_AD_TAG="http:\/\/static.openvideoads.org\/tests\/delayed-ad-tag-processor.php"
OVA_DELAYED_RESPONSE_WRAPPED_AD_TAG="http:\/\/static.openvideoads.org\/tests\/vast1-wrapper-to-delayed-response.xml"
OVA_VAST_OVERLAY_SCALED_MAINTAIN_TAG="${OVA_DIST_TEMPLATES_2}overlays\/scaled-maintain-aspect.xml"
OVA_VAST_OVERLAY_SCALED_NOT_MAINTAINED_TAG="${OVA_DIST_TEMPLATES_2}overlays\/scaled-no-aspect-maintained.xml"
OVA_VAST_NOT_SCALED_TAG=OVA_DIST_TEMPLATES_2="${OVA_DIST_TEMPLATES_2}overlays\/not-scaled.xml"
OVA_VAST_EXTENSION_TAGS="${OVA_DIST_TEMPLATES_2}custom-tags\/vast-clickthroughs.xml"

echo "Cleaning out any previous copies of the examples..."
rm -rf published-local

echo "Copying packaged examples..."
cp -R templates published-local

echo "Making sure there are no .DS_Store or .svn files in the copied version"
find published-local -name ".DS_Store" | xargs -t0 rm
rm -rf `find published-local -type d -name .svn`

#########################################################################################################
# PROCESS THE CONFIG TEMPLATES

# Get list of config files to be replaced
file_list=`find published-local \( -name "*.xml" -o -name "*.html" \) -type f`

# Perform Substitution
for fn in $file_list
do
   if ( test $fn != ./`basename $0` )
   then
      ffnt="$fn.temp"
      strippedFn=`echo $fn | sed '/index.html/!d;'`
      if [ "$strippedFn" = "" ]
      then
         echo "Processing $fn .. "

         sed "s/OVA_JW_VERSION/${OVA_JW_VERSION}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_JW_RELEASE_NUMBER/${OVA_JW_RELEASE_NUMBER}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_DIST_JS_2/${OVA_DIST_JS_2}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_DIST_JS_3/${OVA_DIST_JS_3}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_DIST_CSS_2/${OVA_DIST_CSS_2}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_DIST_CSS_3/${OVA_DIST_CSS_3}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_DIST_TEMPLATES_2/${OVA_DIST_TEMPLATES_2}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_DIST_TEMPLATES_3/${OVA_DIST_TEMPLATES_3}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_DEBUG/${OVA_DEBUG}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_OPENX_API/${OVA_OPENX_API}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_COMPANIONS_VAST_1/${OVA_COMPANIONS_VAST_1}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_COMPANIONS_VAST_2/${OVA_COMPANIONS_VAST_2}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_COMPANIONS_VAST_NO_CREATIVE_TYPE/${OVA_COMPANIONS_VAST_NO_CREATIVE_TYPE}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_HTTP_BASE_URL/${OVA_HTTP_BASE_URL}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_RTMP_BASE_URL/${OVA_RTMP_BASE_URL}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_PSEUDO_BASE_URL/${OVA_PSEUDO_BASE_URL}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_PSEUDO_STREAMER_PARAMS/${OVA_PSEUDO_STREAMER_PARAMS}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_HTTP_SHOW_STREAM_1/${OVA_HTTP_SHOW_STREAM_1}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_PSEUDO_SHOW_STREAM_1/${OVA_PSEUDO_SHOW_STREAM_1}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_RTMP_SHOW_STREAM_1/${OVA_RTMP_SHOW_STREAM_1}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_RTMP_SHOW_STREAM_FILE/${OVA_RTMP_SHOW_STREAM_FILE}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_HTTP_SHOW_STREAM_FILE/${OVA_HTTP_SHOW_STREAM_FILE}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_HTTP_SHOW_STREAM_FILE_FLV/${OVA_HTTP_SHOW_STREAM_FILE_FLV}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_INTERACTIVE_PREROLL_1/${OVA_INTERACTIVE_PREROLL_1}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_INTERACTIVE_PREROLL_2/${OVA_INTERACTIVE_PREROLL_2}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_INTERACTIVE_PREROLL_3/${OVA_INTERACTIVE_PREROLL_3}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_INTERACTIVE_PREROLL_4/${OVA_INTERACTIVE_PREROLL_4}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_COMPANIONS_VAST_2/${OVA_COMPANIONS_VAST_2}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_VAST_MP4_RTMP_AD_WITH_MARKERS/${OVA_VAST_MP4_RTMP_AD_WITH_MARKERS}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_VAST_MP4_RTMP_AD_NO_MARKERS_NO_MIME_TYPE_NO_EXTENSION/${OVA_VAST_MP4_RTMP_AD_NO_MARKERS_NO_MIME_TYPE_NO_EXTENSION}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_VAST_MP4_RTMP_AD_NO_MARKERS_NO_MIME_TYPE/${OVA_VAST_MP4_RTMP_AD_NO_MARKERS_NO_MIME_TYPE}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_VAST_MP4_RTMP_AD_NO_MARKERS/${OVA_VAST_MP4_RTMP_AD_NO_MARKERS}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_VAST_FLV_RTMP_AD_WITH_MARKERS/${OVA_VAST_FLV_RTMP_AD_WITH_MARKERS}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_VAST_FLV_RTMP_AD_NO_MARKERS_NO_MIME_TYPE/${OVA_VAST_FLV_RTMP_AD_NO_MARKERS_NO_MIME_TYPE}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_VAST_FLV_RTMP_AD_NO_MARKERS/${OVA_VAST_FLV_RTMP_AD_NO_MARKERS}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_EMPTY_VAST_RESPONSE/${OVA_EMPTY_VAST_RESPONSE}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_BLANK_VAST_RESPONSE/${OVA_BLANK_VAST_RESPONSE}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_BAD_VAST_RESPONSE/${OVA_BAD_VAST_RESPONSE}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_BAD_VAST_XML/${OVA_BAD_VAST_XML}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_ZERO_DURATION_VAST/${OVA_ZERO_DURATION_VAST}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_VAST_1_WRAPPER_RESPONSE/${OVA_VAST_1_WRAPPER_RESPONSE}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_VPAID_LINEAR_1_VAST/${OVA_VPAID_LINEAR_1_VAST}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_VPAID_NON_LINEAR_1_VAST/${OVA_VPAID_NON_LINEAR_1_VAST}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_VPAID_LINEAR_2_VAST/${OVA_VPAID_LINEAR_2_VAST}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_VPAID_NON_LINEAR_2_VAST/${OVA_VPAID_NON_LINEAR_2_VAST}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_VPAID_LINEAR_4_VAST/${OVA_VPAID_LINEAR_4_VAST}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_RSS_PLAYLIST_1/${OVA_RSS_PLAYLIST_1}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_RSS_PLAYLIST_2/${OVA_RSS_PLAYLIST_2}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_RSS_PLAYLIST_3/${OVA_RSS_PLAYLIST_3}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_MRSS_PLAYLIST_1/${OVA_MRSS_PLAYLIST_1}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_SMIL_PLAYLIST/${OVA_SMIL_PLAYLIST}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_LOGO_IMAGE/${OVA_LOGO_IMAGE}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_THUMBNAIL_IMAGE/${OVA_THUMBNAIL_IMAGE}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_BLANK_PIXEL_IMAGE/${OVA_BLANK_PIXEL_IMAGE}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_BLANK_WITH_PLAY_BUTTON_IMAGE/${OVA_BLANK_WITH_PLAY_BUTTON_IMAGE}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_SKIP_BUTTON_IMAGE_ALT_1/${OVA_SKIP_BUTTON_IMAGE_ALT_1}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_EXAMPLE_OVERLAY_CUSTOM_BUTTON/${OVA_EXAMPLE_OVERLAY_CUSTOM_BUTTON}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_TEST_SKIN/${OVA_TEST_SKIN}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_OPENX_V3_HOSTED/${OVA_OPENX_V3_HOSTED}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_DELAYED_RESPONSE_AD_TAG/${OVA_DELAYED_RESPONSE_AD_TAG}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_DELAYED_RESPONSE_WRAPPED_AD_TAG/${OVA_DELAYED_RESPONSE_WRAPPED_AD_TAG}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_VAST_EXTENSION_TAGS/${OVA_VAST_EXTENSION_TAGS}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_VAST_OVERLAY_SCALED_MAINTAIN_TAG/${OVA_VAST_OVERLAY_SCALED_MAINTAIN_TAG}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_VAST_OVERLAY_SCALED_NOT_MAINTAINED_TAG/${OVA_VAST_OVERLAY_SCALED_NOT_MAINTAINED_TAG}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_VAST_NOT_SCALED_TAG/${OVA_VAST_NOT_SCALED_TAG}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
      else
         echo "Processing $fn .. "
         sed "s/OVA_JW_VERSION/${OVA_JW_VERSION}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
         sed "s/OVA_JW_RELEASE_NUMBER/${OVA_JW_RELEASE_NUMBER}/g" $fn > $ffnt
         rm $fn
         mv $ffnt $fn
      fi
   fi
done

echo "Translations complete - moving new examples to permanent home in /examples..."

find ../../examples/config -name '*.xml' | xargs rm
find ../../examples/pages -name '*.html' | xargs rm
cp -Rf published-local/* ../../examples
rm -rf published-local

echo "Done. Local examples published to /examples"
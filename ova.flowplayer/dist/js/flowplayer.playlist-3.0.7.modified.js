/**
 * flowplayer.playlist 3.0.7. Flowplayer JavaScript plugin.
 *
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * Author: Tero Piirainen, <info@flowplayer.org>
 * Copyright (c) 2008 Flowplayer Ltd
 *
 * Dual licensed under MIT and GPL 2+ licenses
 * SEE: http://www.opensource.org/licenses
 *
 * Date: 2009-02-16 06:51:28 -0500 (Mon, 16 Feb 2009)
 * Revision: 1454
 */
(function($) {

	$f.addPlugin("playlist", function(wrap, options) {


		// self points to current Player instance
		var self = this;

		var opts = {
			playingClass: 'playing',
			pausedClass: 'paused',
			progressClass:'progress',
			template: '<a href="${url}">${description}</a>',
			loop: false,
			playOnClick: true,
			manual: false
		};

		$.extend(opts, options);
		wrap = $(wrap);
		var manual = false;
		var els = null;
		var adAdjustedClipIndexes = new Array();
		var adAndShowDisplayIndex = new Array();


		function toString(clip) {
			var el = template;

			$.each(clip, function(key, val) {
				if (!$.isFunction(val)) {
					el = el.replace("$\{" +key+ "\}", val).replace("$%7B" +key+ "%7D", val);
				}
			});
			return el;
		}

		// assign onClick event for each clip
		function bindClicks() {
			els = wrap.children().unbind("click.playlist").bind("click.playlist", function() {
				if(adAdjustedClipIndexes[els.index(this)] != -1) {
					return play($(this), adAdjustedClipIndexes[els.index(this)]);
			    }
			    else return play($(this), els.index(this));
			});
		}

		function buildPlaylist() {
			wrap.empty();
            var i = 0;
			var clipCounter = 0;

			$.each(self.getPlaylist(), function() {
				if(!this.ovaAd) {
					adAndShowDisplayIndex[clipCounter] = i;
					wrap.append(toString(this));
					if(this.ovaAssociatedPrerollClipIndex != undefined) {
						adAdjustedClipIndexes[i] = this.ovaAssociatedPrerollClipIndex;
					}
					else adAdjustedClipIndexes[i] = clipCounter;
					++i;
				}
				else {
					adAndShowDisplayIndex[clipCounter] = this.ovaAssociatedStreamIndex;
				}
				//console.log("adAndShowDisplayIndex[" + clipCounter + "] = " + adAndShowDisplayIndex[clipCounter]);
				++clipCounter;
			});

			bindClicks();
		}


		function play(el, clip)  {
			if (el.hasClass(opts.playingClass) || el.hasClass(opts.pausedClass)) {
				self.toggle();

			} else {
				el.addClass(opts.progressClass);
				self.play(clip);
			}

			return false;
		}


		function clearCSS() {
			if (manual) { els = wrap.children(); }
			els.removeClass(opts.playingClass);
			els.removeClass(opts.pausedClass);
			els.removeClass(opts.progressClass);
		}

		function getEl(clip) {
			var url = clip.isInStream ? clip.parentUrl : clip.originalUrl;
			return (manual) ? els.filter("[href=" + url + "]") : els.eq(adAndShowDisplayIndex[clip.index]);
		}

		/* setup playlists with onClick handlers */

		// internal playlist
		if (!manual) {

			var template = wrap.is(":empty") ? opts.template : wrap.html();
			buildPlaylist();


		// manual playlist
		} else {

			els = wrap.children();

			// allows dynamic addition of elements
			if ($.isFunction(els.live)) {
				$(wrap.selector + "> *").live("click", function() {
					var el = $(this);
					return play(el, el.attr("href"));
				});

			} else {
				els.click(function() {
					var el = $(this);
					return play(el, el.attr("href"));
				});
			}

			// setup player to play first clip
			var clip = self.getClip(0);
			if (!clip.url && opts.playOnClick) {
				clip.update({url: els.eq(0).attr("href")});
			}

		}

		// onBegin
		self.onBegin(function(clip) {
			clearCSS();
			getEl(clip).addClass(opts.playingClass);
		});

		// onPause
		self.onPause(function(clip) {
			getEl(clip).removeClass(opts.playingClass).addClass(opts.pausedClass);
		});

		// onResume
		self.onResume(function(clip) {
			getEl(clip).removeClass(opts.pausedClass).addClass(opts.playingClass);
		});

		// what happens when clip ends ?
		if (!opts.loop) {

			// stop the playback exept on the last clip, which is stopped by default
			self.onBeforeFinish(function(clip) {
				return !clip.ovaIsEndBlock;
			});
		}

		// on manual setups perform looping here
		if (manual && opts.loop) {
			self.onBeforeFinish(function(clip) {
				if (clip.isInStream) { return; }

				var el = getEl(clip);
				if (el.next().length) {
					el.next().click();
				} else {
					els.eq(0).click();
				}
				return false;
			});
		}

		// onUnload
		self.onUnload(function() {
			clearCSS();
		});

		// onPlaylistReplace
		if (!manual) {
			self.onPlaylistReplace(function() {
				buildPlaylist();
			});
		}

		// onClipAdd
		self.onClipAdd(function(clip, index) {
			els.eq(index).before(toString(clip));
			bindClicks();
		});

		return self;

	});

})(jQuery);

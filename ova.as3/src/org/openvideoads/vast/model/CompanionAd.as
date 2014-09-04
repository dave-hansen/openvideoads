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
package org.openvideoads.vast.model {
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.util.StringUtils;
	import org.openvideoads.util.ArrayUtils;
	import org.openvideoads.vast.events.CompanionAdDisplayEvent;
	import org.openvideoads.vast.events.VideoAdDisplayEvent;
	
	/**
	 * @author Paul Schulz
	 */
	public class CompanionAd extends NonLinearVideoAd {
		protected var _altText:String = null;
		protected var _activeDivID:String = null;
		protected var _previousDivContent:String = "";
		protected var _divIndex:int = -1;
		protected var _formedCode:String = null;
		
		public function CompanionAd(parentAd:VideoAd=null) {
			_parentAdContainer = parentAd;
			super();
		}
		
		public function set altText(altText:String):void {
			_altText = altText;
		}
		
		public function get altText():String {
			return _altText;
		}
		
		public function set activeDivID(activeDivID:String):void {
			_activeDivID = activeDivID;
		}
		
		public function get activeDivID():String {
			return _activeDivID;
		}
		
		public function set divIndex(divIndex:int):void {
			_divIndex = divIndex;
		}
		
		public function get divIndex():int {
			return _divIndex;
		}
		
		public function set previousDivContent(previousDivContent:String):void {
			_previousDivContent = previousDivContent;
		}
		
		public function get previousDivContent():String {
			return _previousDivContent;
		}

		public function registerDisplay(divID:String, previousDivContent:String):void {
			_activeDivID = divID;
			_previousDivContent = previousDivContent;
		}
		
		public function isDisplayed():Boolean {
			return (_activeDivID != null);
		}
		
		public function deregisterDisplay():void {
			_activeDivID = null;
		}
				
		public function getParentAdUID():String {
			if(_parentAdContainer != null) {
				return _parentAdContainer.uid;
			}
			return null;
		}
		
		public function matches(companionAd:CompanionAd):Boolean {
			if(companionAd != null) {
				if(this == companionAd) {
					return true;
				}
				return (companionAd.isVAST2 && this.isVAST2 && this.id != null && !StringUtils.isEmpty(this.id) && (companionAd.id == this.id));
			}
			return false;			
		}
		
		public function suitableForDisplayInDIV(div:Object):Boolean {
			var matchFound:Boolean = false;
			var matched:Boolean = false;
			if(div.resourceType != undefined && div.creativeType == undefined) {
				CONFIG::debugging { doLog("Refining companion matching to " + div.width + "x" + div.height + " and resourceType:" + div.resourceType, Debuggable.DEBUG_DISPLAY_EVENTS); }
				matched = matchesSizeAndResourceType(div.width, div.height, div.resourceType);							
			}
			else if(div.index != undefined) {
				CONFIG::debugging { doLog("Refining companion matching to " + div.width + "x" + div.height + " and index:" + div.index, Debuggable.DEBUG_DISPLAY_EVENTS); }
				matched = matchesSizeAndIndex(div.width, div.height, div.index);
			}
			else if(div.creativeType != undefined && div.resoruceType != undefined) {
				CONFIG::debugging { doLog("Refining companion matching to " + div.width + "x" + div.height + " and creativeType: " + div.creativeType + " resourceType:" + div.resourceType, Debuggable.DEBUG_DISPLAY_EVENTS); }
				matched = matchesSizeAndTypes(div.width, div.height, div.creativeType, div.resourceType);						
			}
			else {
				matched = matchesSize(div.width, div.height);
			}

			if(matched) {
				matchFound = true;
				CONFIG::debugging { doLog("Found a match for " + div.width + "," + div.height + " - id of matching DIV is " + div.id, Debuggable.DEBUG_DISPLAY_EVENTS); }
			}			
			return matchFound;			
		}

		protected function buildFlashVarsString():String {
			var flashVars:String = null;						
			if(hasAdParameters()) {
				flashVars = _adParameters;
			}
			if(hasClickThroughURL()) {
				if(flashVars != null) {
					flashVars = "&clickTag=" + escape(this.firstClickThrough()) + "&" + "clickTAG=" + escape(this.firstClickThrough()) + "&" + "clicktag=" + escape(this.firstClickThrough()) + "&" + flashVars;
				}
				else flashVars = "clickTag=" + escape(this.firstClickThrough()) + "&" + "clickTAG=" + escape(this.firstClickThrough()) + "&" + "clicktag=" + escape(this.firstClickThrough());
			}
			return flashVars;			
		}
		
		protected function buildSWFObjectCode(additionalSWFParams:Array, addEmbedCode:Boolean=true):String {
			var newCode:String = "";
			var dimensionAttributes:String = "";
			if(this.hasWidth()) dimensionAttributes += ' width="' + this.width + '"';
			if(this.hasHeight()) dimensionAttributes += ' height="' + this.height + '"';
			newCode = '<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"' + dimensionAttributes + ' id="companion-' + this.index + '">';
			newCode += '<param name="movie" value="' + url.url + '">';
			newCode += '<param name="allowScriptAccess" value="always">';
			var additionalParams:String = "";
			if(additionalSWFParams != null) {
				if(additionalSWFParams.length > 0) {
					for(var i:int=0; i < additionalSWFParams.length; i++) {
						if(additionalSWFParams[i].name != undefined && additionalSWFParams[i].value != undefined) {
							newCode += '<param name="' + additionalSWFParams[i].name + '" value="' + additionalSWFParams[i].value + '">';
							additionalParams += ' ' + additionalSWFParams[i].name + '="' + additionalSWFParams[i].value + '"';							
						}
					}
				}
			}
			var flashVars:String = buildFlashVarsString();						
			if(addEmbedCode) {
				if(flashVars != null) {
				    newCode += '<param name="FlashVars" value="' + flashVars + '"/>';
					newCode += '<embed name="companion-' + this.index + '" src="' + url.url + '"' + dimensionAttributes + ' allowScriptAccess="always" allowFullScreen="true" pluginspage="http://www.macromedia.com/go/getflashplayer" flashvars="' + flashVars + '"' + additionalParams + '></embed>';
				}
				else {
					newCode += '<embed name="companion-' + this.index + '" src="' + url.url + '"' + dimensionAttributes + ' allowScriptAccess="always" allowFullScreen="true" pluginspage="http://www.macromedia.com/go/getflashplayer"' + additionalParams + '></embed>';							
				}
			}
			else {
				if(flashVars != null) newCode += '<param name="FlashVars" value="' + flashVars + '"/>';
			}
			newCode += '</object>';
			return newCode;
		}

        /*
         * Used to insert SWFs into IE6 only
         */		
/*         
		protected function buildSWFObjectInsertionCode(additionalSWFParams:Array, companionDivID:String="companion"):String {
			var newCode:String = 'function() {';	
			newCode += 'var obj = null;';
		    newCode += 'var div = document.getElementById("' + companionDivID + '");';
			newCode += 'div.innerHTML = \'' + buildSWFObjectCode(additionalSWFParams, false) + '\';';
			newCode += 'obj = div.firstChild;';
		    newCode += 'obj.setAttribute("id", "companion-' + index + '");';
		    newCode += 'obj.setAttribute("width", "' + width + '");';
		    newCode += 'obj.setAttribute("height", "' + height + '");';
		    newCode += 'var flashvars = document.createElement("param");';
		    newCode += 'flashvars.setAttribute("name", "flashvars");';
		    newCode += 'flashvars.setAttribute("value", "' + buildFlashVarsString() + '");';
		    newCode += 'obj.appendChild(flashvars);';
		    newCode += '}';
			return newCode;
		}
*/
		public function getDisplayCode(additionalSWFParams:Array, processExternally:Boolean=false, companionDivID:String="companion", isIE6:Boolean=false):String {
			if(_formedCode == null || isFlash() || additionalSWFParams != null) {
				var newCode:String = "";
				if(isHtml()) {
					CONFIG::debugging { doLog("CompanionAd (" + this.uid + ") - content is a HTML codeblock... " + clickThroughs.length + " click through URL described", Debuggable.DEBUG_DISPLAY_EVENTS); }
					if(hasClickThroughURL() && !StringUtils.beginsWith(codeBlock, "<A ")) { // can't have a double <a> tag - so use the one provided
						newCode = "<a href=\"" + clickThroughs[0].qualifiedHTTPUrl + "\" target=\"_blank\">";
						newCode += codeBlock;
						newCode += "</a>";
					}
					else newCode = codeBlock;
				}
				else {
					if(isImage() || onlyStaticResourceTypeDeclared()) {
						CONFIG::debugging { doLog("CompanionAd (" + this.uid + ") - content is an IMG (" + url.url + ") ..." + clickThroughs.length + " click through URL described", Debuggable.DEBUG_DISPLAY_EVENTS); }
						if(hasClickThroughURL()) {
							newCode = "<a href=\"" + clickThroughs[0].qualifiedHTTPUrl + "\" target=\"_blank\">";
							newCode += "<img src=\"" + url.url + "\" border=\"0\"/>";
							newCode += "</a>";
						}
						else {
							newCode += "<img src=\"" + url.url + "\" border=\"0\"/>";								
						}
					}		
					else if(isScript()) {
						if(hasCode()) {
							CONFIG::debugging { doLog("CompanionAd (" + this.uid + ") - content is a <SCRIPT> codeblock...", Debuggable.DEBUG_DISPLAY_EVENTS); }
							newCode = codeBlock;
						}
						else if(hasUrl()) {
							CONFIG::debugging { doLog("CompanionAd (" + this.uid + ") - content is a <SCRIPT> based url (" + url.url + ") ...", Debuggable.DEBUG_DISPLAY_EVENTS); }
						    newCode += '<script type="text/javascript" src="' + url.url + '"></script>';					
						}
						else {
							CONFIG::debugging { doLog("CompanionAd (" + this.uid + ") - Ignoring script type for companion - no URL or codeblock provided", Debuggable.DEBUG_DISPLAY_EVENTS); }
						}
					}
					else if(isFlash()) {
						if(hasCode()) {
							CONFIG::debugging { doLog("CompanionAd (" + this.uid + ") - content is a flash codeblock ...", Debuggable.DEBUG_DISPLAY_EVENTS); }
							newCode = codeBlock;
						}
						else {
//							if(processExternally == true || (isIE6 == false)) {
								CONFIG::debugging { doLog("CompanionAd (" + this.uid + ") - content is a SWF url (" + url.url + ") based companion OBJECT/EMBED tags...", Debuggable.DEBUG_DISPLAY_EVENTS); }
								newCode = buildSWFObjectCode(additionalSWFParams);
/*							}
							else {
								CONFIG::debugging { doLog("CompanionAd (" + this.uid + ") - content is a SWF url (" + url.url + ") based companion OBJECT/EMBED tags via Javascript element creation code...", Debuggable.DEBUG_DISPLAY_EVENTS);	}						
								newCode = buildSWFObjectInsertionCode(additionalSWFParams, companionDivID);
							}
*/
						}
					}
					else if(isIFrame()) {
						if(hasUrl()) {
							CONFIG::debugging { doLog("CompanionAd (" + this.uid + ") - content is an IFRAME (" + url.url + ") ...", Debuggable.DEBUG_DISPLAY_EVENTS);	}	
							var dimensionAttributes:String = "";
							if(this.hasWidth()) dimensionAttributes += ' width="' + this.width + '"';
							if(this.hasHeight()) dimensionAttributes += ' height="' + this.height + '"';
							newCode =  '<iframe src="' + url.url + '" hspace=0 vspace=0 frameborder=0 marginheight=0 marginwidth=0 scrolling=no' + dimensionAttributes + '>';
	  						newCode += '   <p>Your browser does not support iframes.</p>';
							newCode += '</iframe>';
						}
						else {
							CONFIG::debugging { doLog("CompanionAd (" + this.uid + ") - Ignoring IFRAME type for companion - no URL provided", Debuggable.DEBUG_DISPLAY_EVENTS); }
						}
					}
					else {
						CONFIG::debugging { doLog("CompanionAd (" + this.uid + ") - Unknown resource type " + resourceType + ", creativeType is " + creativeType, Debuggable.DEBUG_DISPLAY_EVENTS); }
					}
				}	
				_formedCode = newCode;
			}
			return _formedCode;		
		}

		override public function start(displayEvent:VideoAdDisplayEvent, region:*=null):void {
			if(displayEvent.controller.onDisplayCompanionAd(new CompanionAdDisplayEvent(CompanionAdDisplayEvent.DISPLAY, this))) {
				triggerTrackingEvent(TrackingEvent.EVENT_CREATIVE_VIEW);	
				triggerTrackingEvent(TrackingEvent.EVENT_START);	
			}
		}
		
		override public function stop(displayEvent:VideoAdDisplayEvent, region:*=null):void {
			if(displayEvent.controller.onHideCompanionAd(new CompanionAdDisplayEvent(CompanionAdDisplayEvent.HIDE, this))) {
				triggerTrackingEvent(TrackingEvent.EVENT_STOP);	
			}
		}
		
		public override function clone(subClone:*=null):* {
			var clone:CompanionAd = super.clone(new CompanionAd(parentAdContainer));
			clone.altText = _altText;
			clone.previousDivContent = _previousDivContent;
			clone.activeDivID = _activeDivID;
			clone.divIndex = _divIndex;
			clone.adParameters = _adParameters;
			return clone;
		}

		public override function toJSObject():Object {
			var o:Object = new Object();
			o = {
				id: _id,
				adId: _adID,
				uid: _uid,
				divId: _activeDivID,
				altText: _altText,
				width: _width,
				height: _height,
				resourceType: _resourceType,
				creativeType: _creativeType,
				codeBlock: hasCode() ? codeBlock : null,
				clickThroughs: ArrayUtils.convertToJSObjectArray(_clickThroughs),
				url: hasUrl() ? url.url : null
			};
			return o;
		}	
	}
}
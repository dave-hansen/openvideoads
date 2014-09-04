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
package org.openvideoads.regions.view {
	import flash.events.MouseEvent;
	
	import org.openvideoads.regions.config.CloseButtonConfig;
	import org.openvideoads.regions.config.RegionViewConfig;
	import org.openvideoads.util.DisplayProperties;

	/**
	 * @author Paul Schulz
	 */
	public class TextSign extends RegionView {
		
		public function TextSign(regionConfig:RegionViewConfig, displayProperties:DisplayProperties) {
			super(null, regionConfig, displayProperties); //, false);
		}

		public override function resize(resizeProperties:DisplayProperties=null):void {
			super.resize(resizeProperties);
		}

		protected override function onMouseOver(event:MouseEvent):void {
		}

		protected override function onMouseOut(event:MouseEvent):void {
		}

		protected override function onClick(event:MouseEvent):void {
		}
	}
}
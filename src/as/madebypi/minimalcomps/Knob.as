/**
 * Knob.as
 * Keith Peters
 * version 0.97
 *
 * A knob component for choosing a numerical value.
 *
 * Copyright (c) 2009 Keith Peters
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

 package madebypi.minimalcomps {

	import madebypi.minimalcomps.Component;
	import madebypi.minimalcomps.Label;
	import madebypi.minimalcomps.Style;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class Knob extends Component {
		
		private var _knob			:Sprite;
		private var _label			:Label;
		private var _labelText		:String = "";
		private var _max			:Number = 100;
		private var _min			:Number = 0;
		private var _mouseRange		:Number = 100;
		private var _iMouseRange	:Number = 0.01;
		private var _precision		:uint 	= 1;
		private var _radius			:int 	= 20;
		private var _startY			:Number;
		private var _value			:Number = 0;
		private var _valueLabel		:Label;
		private var _defaultValue	:Number;
		private var _mult			:Number;
		private var _iMult			:Number;
		
		/**
		 * Constructor
		 * @param parent The parent DisplayObjectContainer on which to add this Knob.
		 * @param xpos The x position to place this component.
		 * @param ypos The y position to place this component.
		 * @param label String containing the label for this component.
		 * @param defaultHandler The event handling function to handle the default event for this component (change in this case).
		 */
		public function Knob(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number =  0, label:String = "", defaultHandler:Function = null, defaultValue:Number = 0) {
			_labelText = label;
			super(parent, xpos, ypos);
			_defaultValue = defaultValue;
			labelPrecision = 1;
			if(defaultHandler != null) addEventListener(Event.CHANGE, defaultHandler);
		}

		/**
		 * Initializes the component.
		 */
		override protected function init():void
		{
			super.init();
		}
		
		/**
		 * Creates the children for this component
		 */
		override protected function addChildren():void
		{
			_knob = new Sprite();
			_knob.buttonMode = true;
			_knob.useHandCursor = true;
			_knob.doubleClickEnabled = true;
			_knob.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_knob.addEventListener(MouseEvent.DOUBLE_CLICK, resetDefault);
			addChild(_knob);
			
			_label = new Label();
			_label.autoSize = true;
			addChild(_label);
			
			_valueLabel = new Label();
			_valueLabel.autoSize = true;
			showValue = true;
		}
		
		private function resetDefault(e:MouseEvent):void {
			value = _defaultValue;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		/**
		 * Draw the knob at the specified radius.
		 * @param radius The radius with which said knob will be drawn.
		 */
		protected function drawKnob():void
		{
			_knob.graphics.clear();
			_knob.graphics.beginFill(Style.BACKGROUND);
			_knob.graphics.drawCircle(0, 0, _radius);
			_knob.graphics.endFill();
			
			_knob.graphics.beginFill(Style.BUTTON_FACE);
			_knob.graphics.drawCircle(0, 0, _radius - 2);
			_knob.graphics.endFill();
			
			_knob.graphics.beginFill(Style.BACKGROUND);
			var s:Number = _radius * .1;
			_knob.graphics.drawRect(_radius, -s, s*2, s * 2);
			_knob.graphics.endFill();
			
			_knob.x = _radius;
			_knob.y = _radius + 20;
			updateKnob();
		}
		
		/**
		 * Updates the rotation of the knob based on the value, then formats the value label.
		 */
		protected function updateKnob():void
		{
			_knob.rotation = -225 + (_value - _min) / (_max - _min) * 270;
			formatValueLabel();
		}
		
		/**
		 * Adjusts value to be within minimum and maximum.
		 */
		protected function correctValue():void{
			if(_max > _min){
				_value = Math.max(Math.min(_value, _max), _min);
			}else{
				_value = Math.min(Math.max(_value, _max), _min);
			}
		}
		
		/**
		 * Formats the value of the knob to a string based on the current level of precision.
		 */
		protected function formatValueLabel():void {
			
			var decimals:String;
			var val		:String;
			var i		:uint;
			
			val 		= Number(Math.round(_value * _mult) * _iMult).toString();
			decimals 	= val.split(".")[1];
			
			if (decimals == null) {
				if (_precision > 0) val += ".";
				i = _precision + 1;
				while(--i !=0) val += "0";
			}else if (decimals.length < _precision) {
				i = _precision - decimals.length + 1;
				while(--i !=0) val += "0";
			} else {
				val = val.substring(0, val.indexOf(".") + _precision + 1);
			}
			
			_valueLabel.text = val;
			_valueLabel.draw();
			_valueLabel.x = int(width * 0.5 - _valueLabel.width * 0.5 + 0.5);
		}
		
		///////////////////////////////////
		// public methods
		///////////////////////////////////
		
		/**
		 * Draws the visual ui of the component.
		 */
		override public function draw():void
		{
			super.draw();
			
			drawKnob();
			
			_label.text = _labelText;
			_label.draw();
			_label.x = int(_radius - _label.width * 0.5 + 0.5);
			_label.y = 0;
			
			formatValueLabel();
			_valueLabel.x = int(_radius - _valueLabel.width * 0.5 + 0.5);
			_valueLabel.y = _radius * 2 + 20;
			
			_width = _radius * 2;
			_height = _radius * 2 + 40;
		}
		
		///////////////////////////////////
		// event handler
		///////////////////////////////////
		
		/**
		 * Internal handler for when user clicks on the knob. Starts tracking up/down motion of the mouse.
		 */
		protected function onMouseDown(event:MouseEvent):void
		{
			_startY = mouseY;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		/**
		 * Internal handler for mouse move event. Updates value based on how far mouse has moved up or down.
		 */
		protected function onMouseMove(event:MouseEvent):void
		{
			var oldValue:Number = _value;
			var diff:Number = _startY - mouseY;
			var range:Number = _max - _min;
			var percent:Number = range / _mouseRange;
			if (event.altKey || event.ctrlKey || event.shiftKey) diff *= 0.1;
			_value += percent * diff;
			correctValue();
			if(_value != oldValue){
				updateKnob();
				dispatchEvent(new Event(Event.CHANGE));
			}
			_startY = mouseY;
		}
		
		/**
		 * Internal handler for mouse up event. Stops mouse tracking.
		 */
		protected function onMouseUp(event:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		
		///////////////////////////////////
		// getter/setters
		///////////////////////////////////
		
		/**
		 * Gets / sets the maximum value of this knob.
		 */
		public function set maximum(m:Number):void
		{
			_max = m;
			correctValue();
			updateKnob();
		}
		public function get maximum():Number{ return _max; }
		
		/**
		 * Gets / sets the minimum value of this knob.
		 */
		public function set minimum(m:Number):void
		{
			_min = m;
			correctValue();
			updateKnob();
		}
		public function get minimum():Number{ return _min; }
		
		/**
		 * Sets / gets the current value of this knob.
		 */
		public function set value(v:Number):void
		{
			_value = v;
			correctValue();
			updateKnob();
		}
		public function get value():Number{	return _value; }
		
		/**
		 * Sets / gets the number of pixels the mouse needs to move to make the value of the knob go from min to max.
		 */
		public function set mouseRange(value:Number):void{
			_mouseRange  = value;
			_iMouseRange = 1.0 / _value;
		}
		public function get mouseRange():Number{ return _mouseRange; }
		
		/**
		 * Gets / sets the number of decimals to format the value label.
		 */
		public function set labelPrecision(decimals:uint):void{
			_precision 	= decimals;
			_mult  		= Math.pow(10, _precision);
			_iMult 		= 1.0 / _mult;
			draw();
		}
		public function get labelPrecision():uint{ return _precision; }
		
		/**
		 * Gets / sets whether or not to show the value label.
		 */
		public function set showValue(value:Boolean):void{
			if (value) {
				if (!_valueLabel.parent) addChild(_valueLabel);
			} else {
				if (_valueLabel.parent) removeChild(_valueLabel);
			}
		}
		public function get showValue():Boolean{ return _valueLabel.parent != null; }
		
		/**
		 * Gets / sets the text shown in this component's label.
		 */
		public function set label(str:String):void{
			_labelText = str;
			draw();
		}
		public function get label():String{ return _labelText; }
		
		public function get radius():int { return _radius; }
		public function set radius(value:int):void {
			_radius = value;
			drawKnob();
		}
	}
}
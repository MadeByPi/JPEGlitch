package madebypi.labs.glitch.jpeg {
	
	/**
	 * ...
	 * @author Mike Almond - MadeByPi
	 */
	
	import flash.geom.Matrix;
	import flash.utils.ByteArray;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import madebypi.parameter.ui.AbstractParameterUI;
	
	import madebypi.parameter.Parameter;
	import madebypi.parameter.IParameterObserver;
	
	import madebypi.labs.glitch.jpeg.ui.EncodeParameterUI;
	
	public final class EncodeController extends AbstractController{
		
		private var _encoder		:JPEGlitchEncoder;
		private var _quality		:uint;
		private var _downsample		:Number;
		
		public function EncodeController(uiContainer:DisplayObjectContainer) {
			super(uiContainer);
			_downsample = 2;
			_quality	= 20;
			_encoder 	= new JPEGlitchEncoder();
			_ui 		= new EncodeParameterUI(_uiContainer, this);
			_ui.enabled = _enabled = true;
		}
		
		public function process(img:BitmapData):ByteArray {
			var b:ByteArray;
			
			if (_downsample == 1) {
				b = _encoder.encode(img, _quality);
			} else {
				const i:Number = 1.0 / _downsample;
				const m:Matrix = new Matrix();
				
				m.scale(i, i);
				var t:BitmapData = new BitmapData(int(img.width * i + 0.5), (img.height * i + 0.5), false, 0xFF000000);
				t.draw(img, m, null, null, null);
				
				b = _encoder.encode(t, _quality);
			}
			
			return b;
		}
		
		/* INTERFACE madebypi.parameter.IParameterObserver */
		override public function onParameterChange(parameter:Parameter):void{
			super.onParameterChange(parameter);
			if (parameter.handled) return;
			
			// update _encoder parameters here
			switch(parameter.name) {
				
				case "downsample":
				_downsample = parameter.getValue();
				parameter.handled = true;
				break;
				
				case "quality":
				_quality = uint(parameter.getValue());
				parameter.handled = true;
				break;
				
				case "glitchA":
				_encoder.glitchA = parameter.getValue();
				parameter.handled = true;
				break;
				
				case "glitchAMod":
				_encoder.glitchAMod = parameter.getValue();
				parameter.handled = true;
				break;
				
				case "glitchB":
				_encoder.glitchB = parameter.getValue();
				parameter.handled = true;
				break;
				
				case "glitchC":
				_encoder.glitchC = Boolean(parameter.getValue() == 1);
				parameter.handled = true;
				break;
				
				case "glitchD":
				_encoder.glitchD = Boolean(parameter.getValue() == 1);
				parameter.handled = true;
				break;
				
				case "xBlockOffset":
				_encoder.xOffAmt = parameter.getValue();
				parameter.handled = true;
				break;
				
				case "yBlockOffset":
				_encoder.yOffAmt = parameter.getValue();
				parameter.handled = true;
				break;
				
				default: trace(this, "unhandled parameter change", parameter.name);
			}
		}
		
		public function get downsample():Number { return _downsample; }
		public function get quality():uint { return _quality; }

	}
}
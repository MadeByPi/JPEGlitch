package madebypi.labs.hype.extended.rhythm {
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.geom.Matrix;
	
	import madebypi.labs.glitch.jpeg.JPEGlitchEncoder;
	
	import hype.framework.rhythm.IRhythm;
	import hype.framework.rhythm.AbstractRhythm;

	import flash.display.BitmapData;

	/**
	 * ...
	 * @author Mike Almond - MadeByPi
	 */
	public class JPEGlitchRhythm extends AbstractRhythm implements IRhythm {
		
		private var _source		:BitmapData;
		private var _dest		:BitmapData;
		private var _encoded	:BitmapData;
		private var _buffer		:BitmapData;
		
		private var _j			:JPEGlitchEncoder;
		private var _l			:Loader;
		
		private var _downM		:Matrix;
		private var _upM		:Matrix;
		
		private var _downsample	:Number;
		private var _idownsample:Number;
		
		private var _quality	:uint;
		private var _loaded		:Boolean;
		private var _scrollX	:Number;
		private var _scrollY	:Number;
		private var _active		:Boolean;
		private var _clearSource:Boolean;
		
		/**
		 *
		 * @param	source		Source image to encode
		 * @param	dest		Destination to draw encoded to
		 * @param	downsample	Source downsample amount
		 * @param	quality		JPEG encode quality (lower is faster...)
		 * @param	clearSource	Clear the source image every frame, after copying it
		 */
		public function JPEGlitchRhythm(source:BitmapData, dest:BitmapData, downsample:Number = 2, quality:uint = 20, clearSource:Boolean = true) {
			super();
			//
			_clearSource 	= clearSource;
			_source		 	= source;
			_dest			= dest;
			//
			_downM 			= new Matrix();
			_upM 			= new Matrix();
			//
			this.downsample = downsample;
			_quality 		= quality;
			//
			_j 				= new JPEGlitchEncoder(_quality);
			_l 				= new Loader();
			_l.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoad, false, 0, true);
			//
			_active = true;
			setupImage();
			//
		}
		
		public function set glitchA(value:Number):void { _j.glitchA = value; }
		public function get glitchA():Number { return _j.glitchA; }
		
		public function set glitchAMod(value:Number):void { _j.glitchAMod = value; }
		public function get glitchAMod():Number { return _j.glitchAMod; }
		
		public function set glitchB(value:Number):void { _j.glitchB = value; }
		public function get glitchB():Number { return _j.glitchB; }
			
		public function get glitchC():Boolean { return _j.glitchC; }
		public function set glitchC(value:Boolean):void {
			if(value) _j.glitchD = false;
			_j.glitchC = value;
		}
		
		public function get glitchD():Boolean { return _j.glitchD; }
		public function set glitchD(value:Boolean):void {
			if(value) _j.glitchC = false;
			_j.glitchD = value;
		}
		
		public function set xOffAmt(value:Number):void { _j.xOffAmt = value; }
		public function get xOffAmt():Number { return _j.xOffAmt; }
		
		public function set yOffAmt(value:Number):void { _j.yOffAmt = value; }
		public function get yOffAmt():Number { return _j.yOffAmt; }
		
		private function setJPEGQuality(quality:uint):void {
			_j.quality = quality;
		}
		
		private function setupImage():void {
			_loaded = false;
			_l.loadBytes(_j.encode(_buffer)); // encode and load downsampled image.
		}
		
		public function run():void {
			
			if(_active){
			
				_buffer.scroll(_scrollX, _scrollY); // scroll the buffer...
				
				if (_loaded) {
					_loaded = false;
					
					_dest.draw(_encoded, _upM); //draw the encoded buffer (may be downsampled) back to the canvas (and upscale if required)
					
					_buffer.draw(_source, _downM); // draw the current source bitmap to our buffer, downsampling as requried
					
					if(_clearSource) _source.fillRect(_source.rect, 0x00000000); // clear the source image
					
					_l.loadBytes(_j.encode(_buffer)); // encode and load the downsampled buffer image.
				}
			}
		}
		
		private function onLoad(e:Event):void {
			_loaded  = true;
			_encoded = Bitmap(_l.content).bitmapData;
		}
		
		public function get downsample():Number { return _downsample; }
		public function set downsample(value:Number):void {
			_downsample  = value;
			_idownsample = 1.0 / value;
			
			// set the Matrix scale (a and d)
			_downM.a 	= _downM.d 	= _idownsample;
			_upM.a 		= _upM.d 	= _downsample;
			
			if(_buffer) _buffer.dispose();
			_buffer = new BitmapData(_source.width * _idownsample, _source.height * _idownsample, false, 0);
		}
		
		public function get scrollX():Number { return _scrollX; }
		public function set scrollX(value:Number):void { _scrollX = value; }
		
		public function get scrollY():Number { return _scrollY; }
		public function set scrollY(value:Number):void { _scrollY = value; }
		
		public function get active():Boolean { return _active; }
		public function set active(value:Boolean):void {
			_active = value;
			if (!value) {
				_dest.fillRect(_dest.rect, 0x000000);
				_buffer.fillRect(_buffer.rect, 0x000000);
				_encoded.fillRect(_encoded.rect, 0x000000);
			}
		}
		
		public function get clearSource():Boolean { return _clearSource; }
		public function set clearSource(value:Boolean):void { _clearSource = value; }
	}
}
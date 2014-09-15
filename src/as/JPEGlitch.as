package {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import madebypi.parameter.IParameterObserver;
	import madebypi.parameter.ParameterCollection;
	import madebypi.parameter.Parameter;
	
	import madebypi.minimalcomps.Panel;
	import madebypi.minimalcomps.Label;
	import madebypi.minimalcomps.Slider;
	import madebypi.minimalcomps.Window;
	import madebypi.minimalcomps.ToolTip;
	import madebypi.minimalcomps.CheckBox;
	import madebypi.minimalcomps.UISlider;
	import madebypi.minimalcomps.HUISlider;
	import madebypi.minimalcomps.PushButton;
	
	import madebypi.labs.glitch.jpeg.DecodeController;
	import madebypi.labs.glitch.jpeg.EncodeController;
	import madebypi.labs.glitch.jpeg.JPEGlitchEncoder;
	import madebypi.labs.glitch.jpeg.JPEGData;
	
	/**
	 * A test suite for JPEG glitching
	 * //
	 * Encode glitching - JPEGlitchCoder
	 * Decode glitching - JPEGData
	 *
	 * Now, glitch up your images!
	 *
	 * JPEGlitchCoder is a modified version of Thiabault Imbert's optimised JPEG comperssor
	 * http://www.bytearray.org/?p=775
	 *
	 * UI is an extended set of minimalcomps by Kieth Peters - bit101
	 * http://www.bit-101.com/blog/
	 *
	 * Icons are 'silkicons' courtesy of famfamfam
	 * http://www.famfamfam.com/lab/icons/silk/
	 *
	 * @version 1.0
	 * @author Mike Almond - MadeByPi
	 */
	public final class JPEGlitch extends Sprite {
		
		[Embed(source='../../bin/woogie2.JPG', mimeType="application/octet-stream")]
		private static var img			:Class;
		
		private var _fr					:FileReference;
		private var _originalBytes		:ByteArray;
		
		private var  _encodeController	:EncodeController;
		private var  _decodeController	:DecodeController;
		private var _lastBytes			:ByteArray;
		
		private var _l					:Loader;
		private var _canvas				:Bitmap;
		private var _originalImage		:BitmapData;
		private var _canvasData			:BitmapData;
		private var _loadedBD			:BitmapData;
		private var _m					:Matrix;
		
		private var _loaded				:Boolean;
		private var _restart			:Boolean;
		private var _oneShot			:Boolean;
		
		private var _imageWindow		:Window;
		private var _fileWindow			:Window;
		private var _processWindow		:Window;
		private var _startStop			:PushButton;
		private var _frameRateSlider	:HUISlider;
		
		public function JPEGlitch():void {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			stage.quality 		= StageQuality.LOW;
			stage.align 		= StageAlign.TOP_LEFT;
			stage.scaleMode 	= StageScaleMode.NO_SCALE;
			
			stage.frameRate 	= 30;
			
			_fr 				= new FileReference();
			_canvas 			= new Bitmap();
			_m					= new Matrix();
			_loaded 			= false;
			
			_l 					= new Loader();
			_l.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoad, false, 0, true);
			
			_encodeController 	= new EncodeController(this);
			_decodeController 	= new DecodeController(this);
			
			setupControls();
			
			// set up with the embedded test image...
			makeNewJPEG(new img());
		}
		
		/**
		 * A new jpeg bytearray has been loaded by the user
		 */
		private function onNewJPEG():void {
			_fr.removeEventListener(Event.COMPLETE, onFileLoad);
			_lastBytes = _originalBytes;
			const l:Loader = new Loader();
			l.contentLoaderInfo.addEventListener(Event.COMPLETE, onFileLoad, false, 0, true);
			l.loadBytes(_originalBytes);
		}
		
		private function onFileLoad(e:Event):void {
			if (e.type == Event.SELECT) {
				_fr.removeEventListener(Event.SELECT, onFileLoad);
				_fr.addEventListener(Event.COMPLETE, onFileLoad, false, 0, true);
				_fr.load();
			} else {
				if (e.target == _fr) {
					makeNewJPEG(_fr.data);
				} else {
					// loaded a new jpeg for display
					LoaderInfo(e.target).removeEventListener(Event.COMPLETE, onFileLoad);
					_originalImage = Bitmap(LoaderInfo(e.target).content).bitmapData;
					_originalImage.lock();
					_loaded = true;
					
					setImageDefaults();
					
					_loadedBD = _originalImage.clone();
					_loadedBD.lock();
					
					_canvasData = new BitmapData(_loadedBD.width, _loadedBD.height, false, 0);
					_canvas.bitmapData = _canvasData;
					
					draw(true);
					positionPanels();
				}
			}
		}
		
		/**
		 * Make a JPEG (@quality=80) from another image format (loaded fileref bytes)
		 */
		private function makeNewJPEG(imageBytes:ByteArray):void {
			var l:Loader = new Loader();
			l.contentLoaderInfo.addEventListener(Event.COMPLETE, onOriginalLoad, false, 0, true);
			l.loadBytes(imageBytes);
		}
		private function onOriginalLoad(e:Event):void {
			LoaderInfo(e.target).removeEventListener(Event.COMPLETE, onOriginalLoad);
			_originalImage = Bitmap(LoaderInfo(e.target).content).bitmapData;
			_originalImage.lock();
			const je:JPEGlitchEncoder = new JPEGlitchEncoder();
			_originalBytes = je.encode(_originalImage, 80);
			onNewJPEG();
		}
		
		private function setImageDefaults():void {
			const jd:JPEGData = new JPEGData(_originalBytes);
			_imageWindow.title = "JPEG - " + jd.SOFImageWidth + "x" + jd.SOFImageHeight + ((jd.progressive) ? " (progressive)" : "");
			_imageWindow.setSize(jd.SOFImageWidth, jd.SOFImageHeight);
			_decodeController.setup(jd);
		}
		
		private function positionPanels():void {
			
			const w:int = Math.min(stage.stageWidth - 250, _canvas.width + 5);
			
			_encodeController.ui.y = _decodeController.ui.y = 5;
			_encodeController.ui.x = w;
			_decodeController.ui.x = w + _encodeController.ui.width + 5;
			
			_processWindow.x = _fileWindow.x = w;
			_processWindow.y = _encodeController.ui.y + _encodeController.ui.height + 5;
			_fileWindow.y = _processWindow.y + _processWindow.height + 5;
		}
		
		private function setupControls():void{
			// image window
			_imageWindow = new Window(this, 1, 5, "Image");
			_imageWindow.content.addChild(_canvas);
			
			// file window
			var yp:int = 5;
			_fileWindow = new Window(this, 625, 5, "File");
			b = new PushButton(_fileWindow.content, 5, yp, "load", doLoad);
			b = new PushButton(_fileWindow.content, 110, yp, "save", onSave);
			_fileWindow.setSize(215, 50);
			
			// process window
			_processWindow = new Window(this, 625, 65, "Process");
			_processWindow.setSize(230, 95);
			
			yp = 3;
			_frameRateSlider = new HUISlider(_processWindow.content, 5, yp, "frameRate", onFrameRate);
			_frameRateSlider.labelPrecision = 0;
			_frameRateSlider.minimum = 5;
			_frameRateSlider.maximum = 120;
			_frameRateSlider.value = stage.frameRate;
			
			var c:CheckBox	= new CheckBox(_processWindow.content, 175, yp+=4, "oneShot", onOneShot);
			_oneShot = c.selected = true;
			
			yp = 24;
			_startStop 		 	= new PushButton(_processWindow.content, 5, yp, "start", onStartStop);
			_startStop.toggle 	= true;
			var b:PushButton 	= new PushButton(_processWindow.content, 120, yp, "step", update);
			b = new PushButton(_processWindow.content, 5, yp += 25, "reset", onRestart);
		}
		
		private function onFrameRate(e:Event):void{
			stage.frameRate = uint(_frameRateSlider.value);
		}
		
		private function onOneShot(e:Event):void{
			_oneShot = !_oneShot;
		}
		
		private function onRestart(e:Event):void{
			_restart = true;
			if (!hasEventListener(Event.ENTER_FRAME)) update(null);
		}
		
		private function invalidate():void {
			if(!hasEventListener(Event.ENTER_FRAME)) addEventListener(Event.ENTER_FRAME, onInvalidate, false, 0, true);
		}
		
		private function onInvalidate(e:Event):void {
			if (_loaded) {
				removeEventListener(Event.ENTER_FRAME, onInvalidate);
				update(null);
			}
		}
		
		private function doLoad(e:Event):void{
			_fr.addEventListener(Event.SELECT, onFileLoad, false, 0, true);
			_fr.browse([new FileFilter("images", "*.jpg;*.jpeg;*.png;*.gif")]);
		}
		
		private function onSave(e:Event):void {
			_fr.removeEventListener(Event.SELECT, onFileLoad);
			_fr.save(_lastBytes, "glitched.jpg");
		}
		
		private function onStartStop(e:Event):void{
			if (_startStop.selected) {
				_startStop.label = "stop";
				addEventListener(Event.ENTER_FRAME, update, false, 0, true);
			} else {
				_startStop.label = "start";
				removeEventListener(Event.ENTER_FRAME, update);
			}
		}
		
		private function onLoad(e:Event):void {
			_loaded   = true;
			_loadedBD = Bitmap(_l.content).bitmapData;
			_loadedBD.lock();
			if (!hasEventListener(Event.ENTER_FRAME)) draw();
		}
		
		private function draw(isNew:Boolean = false):void {
			_canvasData.lock();
			_canvasData.fillRect(_canvasData.rect, 0xFF000000);
			
			if (isNew) {
				_canvasData.draw(_loadedBD);
			} else {
				const m:Matrix = _m;
				m.identity();
				if(_encodeController.enabled){
					const n:Number = _encodeController.downsample;
					m.scale(n, n);
				}
				_canvasData.draw(_loadedBD, m);
			}
			_canvasData.unlock();
			
			if (hasEventListener(Event.RENDER)) dispatchEvent(new Event(Event.RENDER));
		}
		
		private function update(e:Event):void {
			if (_loaded) {
				draw();
				var b:ByteArray;
				if (_encodeController.enabled) {
					if (_restart || _oneShot) {
						b = _encodeController.process(_originalImage); // encode the original image.
					} else {
						b = _encodeController.process(_canvasData); // re-encode the current canvas
					}
				} else {
					b = (_restart || _oneShot) ? _originalBytes : _lastBytes;
				}
				
				if (_decodeController.enabled) b = _decodeController.process(b, 1.0 / _encodeController.downsample);
				
				_loaded    = _restart = false;
				_lastBytes = b;
				_l.loadBytes(b);
			}
		}
		
		public function get lastBytes():ByteArray { return _lastBytes; }
		
		public function get canvasData():BitmapData { return _canvasData; }
	}
}
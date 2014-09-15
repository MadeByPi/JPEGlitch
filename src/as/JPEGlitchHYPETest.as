package {
	
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	import flash.ui.Keyboard;
	
	import hype.extended.behavior.FunctionTracker;
	import hype.extended.behavior.Oscillator;
	import hype.extended.color.ColorPool;
	import hype.extended.layout.GridLayout;
	import hype.framework.core.TimeType;
	import hype.framework.display.BitmapCanvas;
	
	import madebypi.labs.hype.framework.sound.SoundAnalyzer;
	import madebypi.labs.hype.extended.rhythm.JPEGlitchRhythm;
	
	import net.hires.debug.Stats;
	
	public class JPEGlitchHYPETest extends Sprite {
		
		private var _channel		:SoundChannel;
		private var _soundAnalyzer	:SoundAnalyzer;
		private var _jpeGlitchRhythm:JPEGlitchRhythm;
		private var _stats			:Stats;
		private var _sound			:Sound;
		private var _assets			:LoadAsset;
		
		public function JPEGlitchHYPETest():void {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			stage.quality 	= StageQuality.LOW;
			stage.align 	= StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			var myWidth:int 	= 640;// stage.stageWidth;
			var myHeight:int 	= 320;// stage.stageHeight;
			
			var glitchCanvas:BitmapCanvas = new BitmapCanvas(myWidth, myHeight, false, 0);
			addChild(glitchCanvas);
			
			var clipCanvas:BitmapCanvas = new BitmapCanvas(myWidth, myHeight);
			addChild(clipCanvas);
			clipCanvas.blendMode = BlendMode.ADD;
			
			var clipContainer:Sprite = new Sprite();
			
			_soundAnalyzer = new SoundAnalyzer(onSoundPeak);
			_soundAnalyzer.start();
			
			_jpeGlitchRhythm = new JPEGlitchRhythm(clipCanvas.bitmap.bitmapData, glitchCanvas.bitmap.bitmapData, 1.66, 20);
			_jpeGlitchRhythm.start(TimeType.ENTER_FRAME, 1);
			
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false, 0, true);
			
			var tf1:FunctionTracker =  new FunctionTracker(_jpeGlitchRhythm, "glitchA", _soundAnalyzer.getOctave, [0, 0, 0.9]);
			var tf2:FunctionTracker =  new FunctionTracker(_jpeGlitchRhythm, "glitchAMod", _soundAnalyzer.getFrequencyRange, [63,191, 0 , 2]);
			var tf3:FunctionTracker =  new FunctionTracker(_jpeGlitchRhythm, "xOffAmt", _soundAnalyzer.getOctave, [5, 2, 3]);
			var tf4:FunctionTracker =  new FunctionTracker(_jpeGlitchRhythm, "yOffAmt", _soundAnalyzer.getOctave, [7, 4, 16]);
			var tf5:FunctionTracker =  new FunctionTracker(_jpeGlitchRhythm, "glitchB", _soundAnalyzer.getOctave, [3, 0, 1.8]);
			tf1.start(TimeType.ENTER_FRAME, 1);
			tf2.start(TimeType.ENTER_FRAME, 1);
			tf3.start(TimeType.ENTER_FRAME, 1);
			tf4.start(TimeType.ENTER_FRAME, 1);
			tf5.start(TimeType.ENTER_FRAME, 1);
			
			//var colorPool:ColorPool = new ColorPool(0x587b7C, 0x719b9E, 0x9FC1BE, 0xE0D9BB, 0xDACB94, 0xCABA88, 0xDABD55, 0xC49F32, 0xA97409);
			var colorPool:ColorPool = new ColorPool(0x5D2F00, 0xC31500, 0xE88305, 0xFFCAA3, 0xB82888, 0x334A69, 0xEA0000, 0xEDDD00, 0xEBF1CB, 0x3C84B6, 0x00CED9);
			
			// xStart, yStart, xSpacing, ySpacing, columns
			var layout:GridLayout = new GridLayout(0, myHeight >> 1, 10, 0, 64);
			
			var numItems:int = 64;
			var freq:int = 120;
			
			for (var i:uint = 0; i < numItems; ++i) {
				var clip:MySquare = new MySquare();
				clip.scaleX = 1.06;
				layout.applyLayout(clip);
				colorPool.colorChildren(clip);

				// object, property, soundAnalyzer.getFrequencyRange, [startRange, endRange, min, max]
				var aTracker:FunctionTracker = new FunctionTracker(clip.myFill, "alpha", _soundAnalyzer.getFrequencyRange, [i*4, i*4+4, 0.5, 1.0]);
				var sTracker:FunctionTracker = new FunctionTracker(clip.myFill, "scaleY", _soundAnalyzer.getFrequencyRange, [i*4, i*4+4, 0.33, 42.0]);
				aTracker.start();
				sTracker.start();
				
				// target Object, property, waveFunction, frequency, min, max, start value
				var yOsc:Oscillator = new Oscillator(clip, "y", Oscillator.sineWave, freq, 60, 260, i/(180/2));
				yOsc.start();
				
				clipContainer.addChild(clip);
			}
			
			clipCanvas.startCapture(clipContainer, true);
			
			_stats = new Stats();
			
			_assets = new LoadAsset("Lonesome Gate Versus Mocking Door.mp3");
			var assetB:LoadAsset = new LoadAsset("eGb.mp3");
			_assets.next = assetB;
			assetB.next = _assets;
			
			loadNext();
		}
		
		private function onSoundComplete(e:Event):void {
			loadNext();
		}
		
		private function loadNext():void{
			if (_channel) _channel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			if (_sound) _sound = null;
			
			_sound = new Sound();
			_sound.load(new URLRequest(_assets.url));
			_channel = _sound.play();
			_channel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete, false, 0, true);
			_soundAnalyzer.channel = _channel;
			
			_assets = _assets.next;
		}
		
		private function onKeyUp(e:KeyboardEvent):void {
			if (e.keyCode == Keyboard.SPACE) {
				if (_stats.parent) removeChild(_stats);
				else addChild(_stats);
			}else {
				_jpeGlitchRhythm.active = !_jpeGlitchRhythm.active;
			}
		}
		
		private function onSoundPeak():void {
			const p	:Number = _soundAnalyzer.getPeak();
			const hp:Boolean = _soundAnalyzer.hasPeak;
			
			_jpeGlitchRhythm.glitchD = hp && p > 0.8;
			_jpeGlitchRhythm.glitchC = !hp;
			
			if (hp) {
				_jpeGlitchRhythm.glitchB = (p > 0.94) ? 4 : 0;
				_jpeGlitchRhythm.scrollX = int(p * (Math.random() - 0.5) * 64 * (_soundAnalyzer.getLPeak() - _soundAnalyzer.getRPeak()));
			}
		}
	}
}

internal class LoadAsset {
	public var next	:LoadAsset;
	public var url	:String;
	public function LoadAsset(url:String) {
		this.url = url;
	}
}
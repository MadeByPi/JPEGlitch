package madebypi.labs.hype.framework.sound {
	
	import hype.framework.rhythm.AbstractRhythm;
	import hype.framework.rhythm.IRhythm;

	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.utils.ByteArray;

	/**
	 * Analyzes sound frequency data and aggregates the resulting data
	 *
	 * @author Mike Almond - MadeByPi
	 * A modified version of the hype.framework.sound.SoundAnalyzer
	 * - Added some basic peak detection
	 * - Changed the offsetList to store the inverse values to remove division in the computeSpectrum loop
	 * - Made octaveList a Vector.<Vector.<int>>
	 *
	 */
	public class SoundAnalyzer extends AbstractRhythm implements IRhythm {
		
		private const A				:Number =  1.669;
		private const B				:Number = -0.453;
		
		private var _frequencyList	:Vector.<Number>;
		private var _offsetList		:Vector.<Number>;
		private var _octaveList		:Vector.<Vector.<int>>;
		private var _invalid		:Boolean;
		
		private var _channel		:SoundChannel;
		private var _lPeak			:Number;
		private var _rPeak			:Number;
		private var _hasPeak		:Boolean;
		private var _hasLPeak		:Boolean;
		private var _hasRPeak		:Boolean;
		private var _peak			:Number;
		private var _onPeakCallback	:Function;
		private var _peakDecay		:Number;
		private var _peakThreshold	:Number;
		
		public function SoundAnalyzer(onPeakCallback:Function = null):void {
			
			_onPeakCallback = onPeakCallback;
			_peakDecay 		= 0.990;
			_peakThreshold	= 0.14;
			_frequencyList 	= new Vector.<Number>(256, true);
			_offsetList 	= new Vector.<Number>(256, true);
			
			var i:int = -1;
			while(++i<256) {
				_frequencyList[i] 	= 0;
				_offsetList[i] 		= 1.0 / (A + B * (Math.log(i) / Math.LN10)); //calc the inverse so we can * rather than / in the computeSpectrum process
			}
			
			_octaveList    = new Vector.<Vector.<int>>(8, true);
			_octaveList[0] = Vector.<int>([1, 2]);
			_octaveList[1] = Vector.<int>([2, 4]);
			_octaveList[2] = Vector.<int>([4, 10]);
			_octaveList[3] = Vector.<int>([10, 20]);
			_octaveList[4] = Vector.<int>([20, 41]);
			_octaveList[5] = Vector.<int>([41, 82]);
			_octaveList[6] = Vector.<int>([82, 163]);
			_octaveList[7] = Vector.<int>([163, 256]);
		}
		
		/**
		 * @private
		 */
		public function run():void {
			_invalid = true;
			if (_channel) checkPeaks();
		}
		
		private function checkPeaks():void {
			
			const hasPeak	:Boolean = _hasPeak;
			const pt		:Number  = _peakThreshold;
			const pd		:Number  = _peakDecay;
			const l			:Number  = _channel.leftPeak;
			const r			:Number  = _channel.rightPeak;
			
			var lp:Number = _lPeak;
			var rp:Number = _rPeak;
			var p :Number = _peak;
			
			_hasPeak = _hasLPeak = _hasRPeak = false;
			_lPeak 	 = (lp > pt) ? lp * pd : 0;
			_rPeak 	 = (rp > pt) ? rp * pd : 0;
			_peak 	 = (p  > pt) ? p  * pd : 0;
		
			if (l > lp) {
				_lPeak = l;
				_hasPeak = _hasLPeak = true;
			}
			if (r > rp) {
				_rPeak 	 = r;
				_hasPeak = _hasRPeak = true;
			}
			
			if ((l + r) * 0.5 > p) {
				_hasPeak = true;
				_peak = 0.5 * (l + r);
			}
			
			if ((_hasPeak != hasPeak) && (_onPeakCallback != null)) _onPeakCallback();
		}
		
		/**
		 * Get the activity of a frequency at a specified index
		 *
		 * @param index Index of the data to utilize (0-255)
		 * @param min Minimum value to return
		 * @param max Maximum value to return
		 *
		 * @return Value for the specified index mapped to the min/max
		 */
		public function getFrequencyIndex(index:uint, min:Number=0, max:Number=1):Number {
			if (_invalid) {
				computeSpectrum();
				_invalid = false;
			}
			
			index = Math.max(0, index);
			index = Math.min(255, index);
			return _frequencyList[index] * (max - min) + min;
		}
		
		/**
		 * Get the activity of a frequency range (average)
		 *
		 * @param start Initial index of the data to utilize (0-255)
		 * @param end Last index of the data to utilize (0-255)		 *
		 * @param min Minimum value to return
		 * @param max Maximum value to return
		 *
		 * @return Value for the specified range mapped to the min/max
		 */
		public function getFrequencyRange(start:uint, end:uint, min:Number=0, max:Number=1):Number {
			var i		:uint;
			var value	:Number = 0;
			
			start 	= uint(Math.max(0, start));
			end 	= uint(Math.min(256, end));
			
			if (_invalid) {
				computeSpectrum();
				_invalid = false;
			}
			
			for (i=start; i<end; ++i) value += _frequencyList[i];
			
			value /= (end - start);
			value = value * (max - min) + min;
			
			return value;
		}
		
		/**
		 * Get the activity of a specific octave (0-7)
		 *
		 * @param octave Octave to interrogate (0-7)
		 * @param min Minimum value to return
		 * @param max Maximum value to return
		 *
		 * @return Value for the specified index mapped to the min/max
		 */
		public function getOctave(octave:uint, min:Number=0, max:Number=1):Number {
			var value:Number = 0;
			var i:uint;
			var octaveData:Vector.<int>;
			
			if (_invalid) {
				computeSpectrum();
				_invalid = false;
			}
			
			octave 		= Math.min(7, Math.max(0, octave));
			octaveData 	= _octaveList[octave];
			
			for (i=octaveData[0]; i<octaveData[1]; ++i) {
				value = Math.max(value, _frequencyList[i]);
			}
			
			value = value * (max - min) + min;
			return value;
		}
		
		private function computeSpectrum():void {
			var data:ByteArray = new ByteArray();
			var i:int = -1;
			
			try {
				SoundMixer.computeSpectrum(data, true);
				
				while (++i<256) _frequencyList[i] = data.readFloat() * _offsetList[i];
				
				_frequencyList[0] = _frequencyList[1];
				
			} catch (e:SecurityError) {
				while (++i<256) _frequencyList[i] = 0.0;
			}
		}
		
		public function get channel():SoundChannel { return _channel; }
		public function set channel(value:SoundChannel):void { _channel = value; }
		
		public function get hasPeak():Boolean { return _hasPeak; }
		public function get hasLPeak():Boolean { return _hasLPeak; }
		public function get hasRPeak():Boolean { return _hasRPeak; }
		
		public function get peakDecay():Number { return _peakDecay; }
		public function set peakDecay(value:Number):void { _peakDecay = value; }
		
		public function get peakThreshold():Number { return _peakThreshold; }
		public function set peakThreshold(value:Number):void { _peakThreshold = value; }
		
		public function getLPeak():Number { return _lPeak; }
		public function getRPeak():Number { return _rPeak; }
		public function getPeak():Number { return _peak; }
	}
}
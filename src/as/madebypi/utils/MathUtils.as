package madebypi.utils {
	
	/**
	* ...
	* @author Mike Almond - MadeByPi
	*/
	
	public class MathUtils {
		
		public function MathUtils(lock:Lock) { }

		public static const RADtoDEG	:Number = 180 / Math.PI;
		public static const DEGtoRAD	:Number = Math.PI / 180;
		public static const PHI			:Number = (Math.sqrt(5) + 1) * 0.5;
		
		public static function radToDeg(rad:Number):Number{return rad*RADtoDEG;}
		public static function degToRad(deg:Number):Number{return deg*DEGtoRAD;}
		
		/**
		*
		* @return	A Gaussian pseudo-random number
		*/
		public static function gaussRandom():Number{
			var a:Number;
			var b:Number;
			var c:Number;
			do{
				a = 2*Math.random()-1;
				b = 2*Math.random()-1;
				c = a*a + b*b;
			}while (c >= 1);
			
			return b * Math.sqrt( (-2 * Math.log(c)) / c );
		}
		
		/**
		*
		* @param	min			- Minimum, used with maximum to specify the range
		* @param	max			- Maximum, used with minimum to specify the range
		* @param	aNotThese 	- Array of numbers not wanted (useful when needing to create unique random numbers)
		* @param	bReturnInt 	- If true the return value will be an integer, otherwise float
		* @param	bGauss		- If true the random value will follow a gaussian pattern
		* @return	A pseudo-random number
		*/
		public static function randomNumber(min:Number = 0, max:Number = 1, aNotThese:Array = null, bReturnInt:Boolean = false, bGauss:Boolean = false):Number {
			
			var nRand:Number;
			
			nRand = min + ((bGauss) ? gaussRandom() : Math.random()) * (max - min + 1);
		
			if (bReturnInt) { nRand = int(nRand) };
			
			if (aNotThese == null) { return nRand; }
			
			var i	:uint = 0;
			var nLen:uint = aNotThese.length;
			
			while(i<nLen){
				while(nRand == aNotThese[i]){
					nRand = randomNumber(min, max, aNotThese, bReturnInt);
				}
				i++;
			}
			return nRand;
		}
		
		public static function randomIndexArray(min:uint, max:uint, size:uint = 0, uniqueItems:Boolean = false):Array {
			
			if (size == 0) { size = max - min +1 };
			
			if (uniqueItems && (max-min < size-1)) {
				trace("MathTools::randomIndexArray - The range " + min + " to " + max + " is not great enough for a unique array of " + size + " items - setting uniqueItems to false");
				uniqueItems = false;
			}
			
			var a:Array = new Array(size);
			
			if (uniqueItems && size > 999) { throw new Error("That's a mighty large array!"); }
			
			var i:uint = 0;
			while (i < size){
				if(uniqueItems){
					a[i] = (randomNumber(min, max, a, true));
				}else{
					a[i] = (randomNumber(min, max, null, true));
				}
				i++;
			}
			return a;
		}
		
		/**
		*
		* @param	n		- Number to be clamped
		* @param	nMin	- Range minimum
		* @param	nMax	- Range maximum
		* @return	A number clamped to the range specified
		*/
		public static function clampNumber(n:Number,nMin:Number,nMax:Number):Number{
			return Math.max(Math.min(n,nMax),nMin);
		}
		
		/**
		*
		* @param	n		- Number to check
		* @return	Boolean - true if number is ok, false if not
		*/
		public static function validNumber(n:Number):Boolean{
			return (!isNaN(n) || isFinite(n));
		}
		
		/**
		*
		* @param	x
		* @param	n
		* @return	Finds the nth Root of a number
		*/
		public static function nthRoot(x:Number,n:Number):Number{
			return Math.pow(x,1/n);
		}
		
		/**
		*
		* @param	n	- Number to round
		* @param	dp	- Decimal placed to round to
		* @return 	A rounded number
		*/
		public static function round(n:Number, dp:uint = 0):Number {
			if (dp == 0) { return Math.round(n); }
			const m:Number = Math.pow(10, dp);
			return Math.round(n * m) / m;
		}
		
		/**
		*
		* @param	nLin		- Your linear number
		* @param	range		- Range (0 to range) to convert from/to
		* @param	exponent 	- Will default to Math.LN10 if no exponent is provided
		* @return	Will map a number from a linear range to an logarithmic one
		* @usage	Example: use to map the position of volume slider from linear coordinates to a log scale for better control of loudness
		*/
		public static function linearToLogRange(nLin:Number,range:Number,exponent:Number):Number{
			if (!exponent) { exponent = Math.LN10 };
			var rangeInverse:Number = 1 / range;
			return range * Math.pow(nLin * rangeInverse, exponent);
		}
		/**
		*
		* @param	nLog
		* @param	range
		* @param	exponent
		* @return	See: linearToLogRange
		*/
		public static function logToLinearRange(nLog:Number,range:Number,exponent:Number):Number{
			if (!exponent) { exponent = Math.LN10 }; //for compatability with v1
			var rangeInverse:Number = 1 / range;
			return range * Math.pow((rangeInverse * nLog), 1 / exponent);
		}
		
		
		/**
		*
		* @param	bStr	- A string of ones and zeros
		* @return	Number
		* @usage	binStrToNum("101001101") will return the number 333
		*/
		public static function binStrToNum(bStr:String):Number{
			var nOut:Number=0;
			var bLen:int=bStr.length;
			var i:uint;
			for(i=0;i<bLen;i++){
				if(bStr.charAt(i)=="1"){
					nOut += Math.pow(2,(bLen-(i+1)));
				}
			}
			return nOut;
		}
	}
}
internal class Lock{}
package madebypi.labs.glitch {
	
	/**
	 * ...
	 * @author Mike Almond - MadeByPi
	 */
	
	import flash.utils.ByteArray;
	
	final public class ByteArrayUtils{
		
		final public function ByteArrayUtils(l:Lock) { }; // don't consturct
		
		/**
		 * Randomly shuffle (blocks of bytes) around in a ByteArray
		 * @param	bytes		ByteArray to shuffle
		 * @param	sizeMin		Minimum block size
		 * @param	sizeMax		Maximum block size
		 * @param	itterations Number of shuffles to perform
		 */
		static public function shuffleBlocks(bytes:ByteArray, blockSizeMin:uint, blockSizeMax:uint, itterations:uint = 1):void {
			
			if (blockSizeMin < 1) blockSizeMin = 1;
			if (blockSizeMax < blockSizeMin) blockSizeMax = blockSizeMin;
			if (blockSizeMax >= bytes.length) blockSizeMax = bytes.length - blockSizeMin;
			
			var i:int = itterations + 1;
			while (--i != 0) {
				var s:uint = blockSizeMin + uint(Math.random() * (blockSizeMax - blockSizeMin)); //size
				var o:uint = bytes.length - s; // max offset
				insert(bytes, uint(Math.random() * o), slice(bytes, uint(Math.random() * o), s));
			}
		}
		
		/**
		 * Fill a ByteArray with random bytes, randomisation amount is determined by the probability parameter
		 * @param	bytes		ByteArray to fill with random data
		 * @param	probability	Probability of an induvidual byte being randomised
		 */
		static public function randomFillBlocks(bytes:ByteArray, blockSizeMin:uint, blockSizeMax:uint, probability:Number = 0.5, itterations:uint = 1):void {
			
			if (blockSizeMin < 1) blockSizeMin = 1;
			if (blockSizeMax < blockSizeMin) blockSizeMax = blockSizeMin;
			if (blockSizeMax >= bytes.length) blockSizeMax = bytes.length - blockSizeMin;
			
			var i:int = itterations + 1;
			
			while (--i != 0) {
				var s:uint = blockSizeMin + uint(Math.random() * (blockSizeMax - blockSizeMin));
				var o:uint = uint(Math.random() * (bytes.length - s));
				randomiseBytes(bytes, o, s, probability);
			}
		}
		
		static public function randomiseBytes(bytes:ByteArray, offset:uint, length:uint, probability:Number):void{
			bytes.position = offset;
			//
			const p	:Number	= 1.0 - probability;
			var j	:int 	= length;
			while (--j > -1) {
				if (Math.random() > p) {
					bytes.writeByte(int(0xFF * (Math.random() - 0.5)));
				} else {
					bytes.position++;
				}
			}
		}
		
		/**
		 * Reverse blocks of bytes in a bytearray
		 * @param	bytes
		 * @param	blockSizeMin
		 * @param	blockSizeMax
		 * @param	itterations
		 */
		static public function reverseByteBlocks(bytes:ByteArray, blockSizeMin:uint, blockSizeMax:uint, itterations:uint = 1):void {
			
			if (blockSizeMin < 1) blockSizeMin = 1;
			if (blockSizeMax < blockSizeMin) blockSizeMax = blockSizeMin;
			if (blockSizeMax >= bytes.length) blockSizeMax = bytes.length - blockSizeMin;
			
			var b:ByteArray = new ByteArray();
			var i:int = itterations + 1;
			while (--i != 0) {
				var s:uint = blockSizeMin + uint(Math.random() * (blockSizeMax - blockSizeMin));
				var o:uint = uint(Math.random() * (bytes.length - s));
				bytes.position = o;
				b.writeBytes(bytes, 0, s);
				reverseBytes(b);
				bytes.writeBytes(b, 0, s);
			}
		}
		/**
		 * Reverse the order of the data in a ByteArray
		 * @param	bytes
		 */
		static public function reverseBytes(bytes:ByteArray):void {
			var rb:ByteArray = new ByteArray();
			rb.length = bytes.length;
			rb.position = 0;
			
			bytes.position = 0;
			while (bytes.bytesAvailable) {
				rb.position -= 1;
				rb.writeByte(bytes.readByte());
				rb.position -= 1;
			}
			
			bytes.position = 0;
			bytes.writeBytes(rb, 0, rb.length);
		}
		
		/**
		 * Slice out a chunk of bytes at a given offset, modifies the original ByteArray
		 * @param	bytes	ByteArray to slice
		 * @param	offset	Offset to slice at
		 * @param	length	Length, in bytes, to remove
		 * @return	ByteArray containing the removed bytes
		 */
		static public function slice(bytes:ByteArray, offset:uint, length:uint):ByteArray {
			bytes.position = 0;
			
			const b0:ByteArray = new ByteArray();
			const b1:ByteArray = new ByteArray();
			const b2:ByteArray = new ByteArray();
			
			b0.writeBytes(bytes, 0 , offset); // pre
			b1.writeBytes(bytes, offset , length); //slice
			b2.writeBytes(bytes, offset + length , bytes.length - (offset + length)); //post
			
			bytes.clear();
			bytes.writeBytes(b0, 0, b0.length);
			bytes.writeBytes(b2, 0, b2.length);
			
			return b1;
		}
		
		/**
		 * Insert a chunk of bytes into an existing ByteArray at a given offset
		 * @param	target	Target to insert to
		 * @param	offset	Offset to insert at
		 * @param	bytes	ByteArray to insert
		 */
		static public function insert(target:ByteArray, offset:uint, bytes:ByteArray):void {
			target.position = 0;
			bytes.position  = 0;
			
			const b0:ByteArray = new ByteArray();
			const b1:ByteArray = new ByteArray();
			
			b0.writeBytes(target, 0 , offset); // pre
			b1.writeBytes(target, offset, target.length - offset); //post
			
			target.clear();
			target.writeBytes(b0, 0, b0.length);
			target.writeBytes(bytes, 0, bytes.length);
			target.writeBytes(b1, 0, b1.length);
		}
	}
}
internal class Lock { }
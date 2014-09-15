package madebypi.labs.glitch.jpeg {
	
	/**
	 * ...
	 * @author Mike Almond - MadeByPi
	 */
	
	import flash.utils.ByteArray;
	
	final public class JPEGData {
		
		// jpeg header markers
		private static const SOI	:uint = 0xFFD8;	// Start Of Image
		private static const SOF0	:uint = 0xFFC0; // Start Of Frame 				- Baseline DCT
		private static const SOF2	:uint = 0xFFC2; // Start Of Frame 				- Progressive DCT
		private static const DHT	:uint = 0xFFC4; // Define Huffman Table(s) 		- Specifies one or more Huffman tables.
		private static const DQT	:uint = 0xFFDB; // Define Quantization Table(s) - Specifies one or more quantization tables.
		private static const DRI	:uint = 0xFFDD; // Define Restart Interval		- Specifies the interval between RSTn markers, in macroblocks. This marker is followed by two bytes indicating the fixed size so it can be treated like any other variable size segment.
		private static const SOS	:uint = 0xFFDA; // Start Of Scan				- Begins a top-to-bottom scan of the image. In baseline DCT JPEG images, there is generally a single scan. Progressive DCT JPEG images usually contain multiple scans. This marker specifies which slice of data it will contain, and is immediately followed by entropy-coded data.
		private static const RSTn	:uint = 0xFFD0; // Restart (0xFFD0-0xFFD7) 		- Inserted every r macroblocks, where r is the restart interval set by a DRI marker. Not used if there was no DRI marker. The low 3 bits of the marker code, cycles from 0 to 7.
		private static const APP0	:uint = 0xFFE0; // JFIF info
		private static const APP1	:uint = 0xFFE1; // Exif?
		private static const COM	:uint = 0xFFFE; // Text comment
		private static const EOI	:uint = 0xFFD9; // End Of Image
		
		// jpeg bytes
		private var _bytes			:ByteArray;
		// jpeg data blocks
		private var _APP0			:ByteArray;
		private var _APP1			:ByteArray;
		private var _SOF			:ByteArray;
		private var _SOS			:ByteArray;
		private var _imageData		:ByteArray;
		private var _DQT			:Vector.<ByteArray>;
		private var _DHT			:Vector.<ByteArray>;
		private var _DRI			:uint;
		private var _comment		:String;
		private var _progressive	:Boolean;
		//
		private var _modified		:Boolean;
		
		public function JPEGData(bytes:ByteArray = null) {
			
			_APP0		 	= new ByteArray();
			_APP1		 	= new ByteArray(); //exif...
			_DQT		  	= new Vector.<ByteArray>();
			_SOF 			= new ByteArray();
			_DHT  			= new Vector.<ByteArray>();
			_SOS  			= new ByteArray();
			_imageData 		= new ByteArray(); // the entropy coded image data block
			_DRI			= 0;
			_comment 		= null;
			_progressive	= false;
			
			if (bytes) this.bytes = bytes;
		}
		
		private function readMarkers():void{
			while (_bytes.bytesAvailable) {
				readMarker(_bytes.readUnsignedShort());
			}
		}
		
		private function readMarker(id:uint):void {
			//trace("readMarker 0x" + id.toString(16));
			
			if ((id & 0xFF00) != 0xFF00) { // not a header marker
				_bytes.position = _bytes.length;
				return;
			}
			
			var b:ByteArray = new ByteArray();
			const length:int = _bytes.readShort() - 2;
			
			switch(id) {
				case APP0:
				_bytes.readBytes(_APP0, 0, length);
				break;
				
				case APP1:
				_bytes.readBytes(_APP1, 0, length);
				// EXIF / Other
				break;
				
				case DQT:
				_bytes.readBytes(b, 0, length);
				parseDQT(b);
				break;
				
				case SOF0:
				_bytes.readBytes(_SOF, 0, length);
				break;
				
				case SOF2:
				_progressive = true;
				_bytes.readBytes(_SOF, 0, length);
				break;
				
				case DHT:
				_bytes.readBytes(b, 0, length);
				_DHT.push(b);
				break;
				
				case SOS:
				_bytes.readBytes(_SOS, 0, length);
				readImageData();
				break;
				
				case COM:
				_comment = _bytes.readUTFBytes(length);
				break;
				
				case DRI:
				_DRI = _bytes.readShort();
				break;
				
				default:
				trace("Skipping unhandled jpeg marker: 0x" + id.toString(16));
				_bytes.position += length;
				break;
			}
		}
		
		private function parseDQT(b:ByteArray):void {
			const n	:uint = uint(b.length / 65);
			var i	:int = -1;
			while (++i < n) {
				var b2:ByteArray = new ByteArray();
				b.readBytes(b2, 0, 65);
				_DQT.push(b2);
			}
		}
		
		private function readImageData():void {
			const s	:uint = _bytes.position;
			var e	:uint = _bytes.position = _bytes.length - 2;
			
			if (_bytes.readUnsignedShort() != EOI) {
				// Hmm.. EOI not present, adding one
				e = _bytes.position = _bytes.length;
				_bytes.writeShort(EOI);
			}
			
			_bytes.position = s;
			_bytes.readBytes(_imageData, 0, e-s); // read entire data stream up to the EOI marker (all scans if progressive)
			_imageData.position = 0;
			
			_bytes.position = e + 2;
		}
		
		/**
		 * Reconstruct (edited) jpeg bytes from the parsed (and modified) data
		 */
		private function reconstruct():void {
			_bytes = new ByteArray();
			_bytes.writeShort(SOI); // start of image marker
			
			writeBlock(APP0, _APP0); // write APP0
			
			// omitting comment and APP1 for speed - not required to create a vaild image
			/*if (_comment) {
				var b:ByteArray = new ByteArray();
				b.writeUTFBytes(_comment);
				writeBlock(COM, b);
			}*/
			// if (_APP1.length) writeBlock(APP1, _APP1); // write APP1
			
			// if present, write the DRI marker
			if (_DRI > 0) {
				_bytes.writeShort(DRI); // marker
				_bytes.writeShort(4); // length
				_bytes.writeShort(_DRI); // dri (scan restart interval)
			}
			
			// write quantisation tables
			var i:int = -1;
			var n:uint = _DQT.length;
			while (++i < n) {
				checkDQT(_DQT[i], i);
				writeBlock(DQT, _DQT[i]);
			}
			
			// write start of frame
			writeBlock(_progressive ? SOF2 : SOF0, _SOF);
			
			// write huffman tables
			i = -1;
			n = _DHT.length;
			while (++i < n) {
				checkDHT(_DHT[i], i);
				writeBlock(DHT, _DHT[i]);
			}
			
			// write start of scan
			writeBlock(SOS, _SOS);
			
			// write the image data
			_bytes.writeBytes(_imageData, 0, _imageData.length);
			
			// write end of image marker
			_bytes.writeShort(EOI);
			
			_modified = false;
		}
		
		private function checkDQT(b:ByteArray, index:uint = 0):void {
			b.position = 0;
			if (b.readUnsignedByte() != index) {
				b.position = 0;
				b.writeByte(index); // write the info byte (dqt num) (expecting 8bit quality)
			}
		}
		
		/**
		 * Check required markers are still present in HTs
		 * @param	b
		 * @param	index
		 */
		private function checkDHT(b:ByteArray, index:uint = 0):void {
			b.position = 0;
			const b0:uint = b.readUnsignedByte();
			const b1:uint = (index == 0) ? 0x00 : (index == 1) ? 0x10 : (index == 2) ? 0x01 : 0x11;
			if (b0 != b1) {
				b.position = 0;
				b.writeByte(b1);
				b.position = 0;
			}
		}
		
		
		/**
		 * Write a block of JPEG data to the JPEG bytes
		 * @param	header
		 * @param	data
		 */
		private function writeBlock(header:uint, data:ByteArray):void {
			_bytes.writeShort(header); // block header
			_bytes.writeShort(data.length + 2); // block length
			_bytes.writeBytes(data, 0, data.length); // block data
		}
		
		/**
		 * The Start Of Scan content (entropy encoded image data)
		 */
		public function get imageData():ByteArray { return _imageData; }
		public function set imageData(value:ByteArray):void {
			_imageData = value;
			_modified = true;
		}
		
		/**
		 * Read the jpeg bytes (reconstructing from data blocks if modified)
		 */
		public function get bytes():ByteArray {
			if(_modified) reconstruct();
			return _bytes;
		}
		
		/**
		 * set the jpeg bytes and parse them
		 */
		public function set bytes(value:ByteArray):void {
			_bytes = value;
			_bytes.position = 0;
			
			if (SOI != _bytes.readUnsignedShort()) {
				throw new ReferenceError("Data is not valid JPEG, no SOI");
			}
			
			_DQT.fixed = false;
			_DHT.fixed = false;
			
			_APP0.length = 0;
			_APP1.length = 0; //exif...
			_DQT.length = 0;
			_SOF.length = 0;
			_DHT.length = 0;
			_SOS.length = 0;
			_imageData.length = 0;
			
			readMarkers(); // parse the jpeg data into blocks
			
			_DQT.fixed = true;
			_DHT.fixed = true;
		}
		
		/**
		 * get / set modified
		 */
		public function get modified():Boolean { return _modified; }
		public function set modified(value:Boolean):void {
			_modified = value;
		}
		
		/**
		 * get / set SOF0 properties
		 */
        public function get SOFImageWidth():uint{
            _SOF.position = 3;
            return _SOF.readUnsignedShort();
        }
		public function set SOFImageWidth(value:uint):void{
            _SOF.position = 3;
            _SOF.writeShort(value);
            _modified = true;
        }
		//
        public function get SOFImageHeight():uint{
            _SOF.position = 1;
            return _SOF.readUnsignedShort();
        }
		public function set SOFImageHeight(value:uint):void{
            _SOF.position = 1;
            _SOF.writeShort(value);
			_modified = true;
        }
		
		public function get comment():String { return _comment; }
		public function set comment(value:String):void {
			_comment = value;
			_modified = true;
		}
		
		public function get progressive():Boolean { return _progressive; }
		
		public function getDRI():uint { return _DRI; }
		public function setDRI(value:uint):void {
			_DRI = value;
			_modified = true;
		}
		
		public function get DQTCount():uint { return _DQT.length; }
		public function getDQT():Vector.<ByteArray> { return _DQT; }
		
		public function get DHTCount():uint { return _DHT.length; }
		public function getDHT():Vector.<ByteArray> { return _DHT; }
	}
}
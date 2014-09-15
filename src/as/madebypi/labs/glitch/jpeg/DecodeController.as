package madebypi.labs.glitch.jpeg {
	
	/**
	 * ...
	 * @author Mike Almond - MadeByPi
	 */
	
	import flash.utils.ByteArray;
	import flash.display.DisplayObjectContainer;
	import madebypi.labs.glitch.ByteArrayUtils;
	import madebypi.minimalcomps.UISlider;
	import madebypi.parameter.ParameterCollection;
	
	import madebypi.parameter.Parameter;
	import madebypi.parameter.IParameterObserver;
	
	import madebypi.labs.glitch.jpeg.ui.DecodeParameterUI;
	
	public final class DecodeController extends AbstractController{
		
		private var _jd:JPEGData;
		
		public function DecodeController(uiContainer:DisplayObjectContainer) {
			super(uiContainer);
		}
		
		public final function setup(jpegData:JPEGData):void {
			if (_ui)	_ui.dispose();
			_ui			= null;
			_jd  		= jpegData;
			_ui 		= new DecodeParameterUI(_uiContainer, this, jpegData);
			_ui.enabled = _enabled = true;
		}
		
		/**
		 *
		 * @param	bytes		- Bytes to process.
		 * @param	iDownsample	- Inverse of the downsample amount
		 * @return
		 */
		public final function process(bytes:ByteArray, iDownsample:Number = 1):ByteArray {
			iDownsample = iDownsample > 1 ? 1 : iDownsample;
			
			const d	:DecodeParameterUI = DecodeParameterUI(ui);
			var pc	:ParameterCollection;
			var n	:int;
			
			pc 					= ui.parameters;
			_jd.bytes 			= bytes;
			_jd.SOFImageWidth 	= uint(pc.getParameter("SOFWidth").getValue() * iDownsample);
			_jd.SOFImageHeight 	= uint(pc.getParameter("SOFHeight").getValue()* iDownsample);
			_jd.setDRI(uint(pc.getParameter("DRI").getValue()));
			
			// SOS
			if (d.sosUI.enabled) {
				pc = d.sosUI.parameters;
				doShuffle(_jd.imageData, pc, "SOS");
				doRandomFill(_jd.imageData, pc, "SOS");
				doReverse(_jd.imageData, pc, "SOS");
			}
			
			// DQT
			n = d.dqtUI.length;
			while(--n>-1){
				if (d.dqtUI[n].enabled) {
					pc	= d.dqtUI[n].parameters;
					doRandomFill(_jd.getDQT()[n], pc, "DQT");
					doReverse(_jd.getDQT()[n], pc, "DQT");
				}
			}
			
			// DHT
			/*n = d.dhtUI.length;
			while (--n > -1) {
				if (d.dhtUI[n].enabled) {
					pc = d.dhtUI[n].parameters;
					doRandomFill(_jd.getDHT()[n], pc, "DHT");
					doReverse(_jd.getDHT()[n], pc, "DHT");
				}
			}*/
			//
			//_jd.modified = true;
			return _jd.bytes;
		}
		
		private function doShuffle(bytes:ByteArray, pc:ParameterCollection, name:String):void{
			var itt:int	= int(pc.getParameter("shuffle" + name + "BlocksItt").getValue());
			if (itt > 0) {
				ByteArrayUtils.shuffleBlocks(bytes,
				int(pc.getParameter("shuffle" + name + "BlocksMin").getValue()),
				int(pc.getParameter("shuffle" + name + "BlocksMax").getValue()),
				itt);
			}
		}
		
		private function doRandomFill(bytes:ByteArray, pc:ParameterCollection, name:String):void{
			var itt:int	= int(pc.getParameter("randomFill" + name + "BlocksItt").getValue());
			if (itt > 0) {
				ByteArrayUtils.randomFillBlocks(bytes,
				int(pc.getParameter("randomFill" + name + "BlocksMin").getValue()),
				int(pc.getParameter("randomFill" + name + "BlocksMax").getValue()),
				pc.getParameter("randomFill" + name + "BlocksProb").getValue(),
				itt);
			}
		}
		
		private function doReverse(bytes:ByteArray, pc:ParameterCollection, name:String):void{
			var itt:int	= int(pc.getParameter("reverse" + name + "BlocksItt").getValue());
			if (itt > 0) {
				ByteArrayUtils.reverseByteBlocks(bytes,
				int(pc.getParameter("reverse" + name + "BlocksMin").getValue()),
				int(pc.getParameter("reverse" + name + "BlocksMax").getValue()),
				itt);
			}
		}
		
		/* INTERFACE madebypi.parameter.IParameterObserver */
		override public function onParameterChange(parameter:Parameter):void{
			super.onParameterChange(parameter);
			if (parameter.handled) return;
			parameter.handled = true;
		}
	}
}
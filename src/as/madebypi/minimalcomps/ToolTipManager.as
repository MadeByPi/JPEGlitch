package madebypi.minimalcomps {
		
	/**
	 * ...
	 * @author Mike Almond - MadeByPi
	 */
	
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.utils.Timer;
	
	import madebypi.minimalcomps.Label;
	import madebypi.minimalcomps.Style;
	
	public class ToolTipManager extends Sprite{
		
		static private var INSTANCE	:ToolTipManager = null;
		static private var _init	:Boolean = false;
		
		private var _container		:DisplayObjectContainer;
		private var _label			:Label;
		private var _showTimer		:Timer;
		private var _tt				:ToolTip;
		
		public function ToolTipManager(l:Lock) {
			super();
			mouseEnabled = false;
			_tt = null;
			
			_showTimer = new Timer(1000, 1);
			_showTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete, false, 0, true);
			
			_label = new Label(this);
			_label.opaqueBackground = Style.BUTTON_FACE;
			
			filters = [new DropShadowFilter(1, 45, Style.DROPSHADOW, 0.5, 1, 1, 1, 1)];
			_label.height -= 8;
		}
		
		
		//
		// public static
		
		public static function init(container:DisplayObjectContainer):void {
			if (!_init) {
				_m._container = container;
				_init = true;
			}
		}
		
		public static function show(target:ToolTip):void {
			if (!_init) return;
			
			hide();
			
			_m._showTimer.reset();
			_m._showTimer.start();
			
			_m._tt = target;
			_m._label.text = target.text;
			_m._tt.uiTarget.addEventListener(MouseEvent.MOUSE_MOVE, _m.onMouseMove, false, 0, true);
		}
		
		public static function hide(target:ToolTip = null):void {
			if (!_init) return;
			if (target && target != _m._tt) return;
			
			_m._showTimer.reset();
			if(_m._tt){
				_m._tt.uiTarget.removeEventListener(MouseEvent.MOUSE_MOVE, _m.onMouseMove);
				_m._tt = null;
				if(_m.parent) _m._container.removeChild(_m);
			}
		}
		
		public static function updateText(target:ToolTip, text:String):void {
			if (target != _m._tt) return;
			_m._label.text = text;
		}
		
		public static function set showDelay(value:uint):void { _m._showTimer.delay = value; }
		
		
		
		//
		// private
		
		private static function get _m():ToolTipManager {
			if (INSTANCE == null) INSTANCE = new ToolTipManager(new Lock());
			return INSTANCE;
		}
		
		private function onTimerComplete(e:TimerEvent):void {
			if (e.target == _showTimer) {
				_showTimer.reset();
				_container.addChild(this);
				x = stage.mouseX + 14;
				y = stage.mouseY - 1;
			} else {
				ToolTipManager.hide(_tt);
			}
		}
		
		private function onMouseMove(e:MouseEvent):void {
			ToolTipManager.show(_tt);
		}
	}
}
internal class Lock { };
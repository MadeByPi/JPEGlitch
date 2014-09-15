package madebypi.parameter {
	
	/**
	 * ...
	 * @author Mike Almond  - MadeByPi
	 */
	
	import madebypi.parameter.mapping.IMapping;
	import madebypi.parameter.mapping.MapBoolean;
	import madebypi.parameter.mapping.MapFactory;
	
	public class Parameter{
		
		private var _name			:String;
		private var _normalisedValue:Number;
		
		private var _mapping		:IMapping;
		
		private var _observers		:Vector.<IParameterObserver>;
		private var _priorities		:Vector.<Vector.<int>>;
		private var _sp				:Vector.<Vector.<int>>; //sorted priorities
		private var _observerCount	:int;
		private var _fromUI			:Boolean; // if triggered from user interaction
		private var _target			:*;
		
		public var handled			:Boolean;
		
		public function Parameter(name:String, mapping:IMapping, target:* = null) {
			
			super();
			
			if (mapping == null) {
				throw new ReferenceError("Mapping is null");
				return;
			}
			
			_target 		= target;
			_name			= name;
			_mapping 		= mapping;
			_fromUI			= false;
			handled			= false;
			
			_observerCount 	 = 0;
			_observers 		 = new Vector.<IParameterObserver>();
			_priorities		 = new Vector.<Vector.<int>>();
			_normalisedValue = 0;
			
			reset();
		}
		
		public function setValue(value:Number, normalised:Boolean = false, fromUI:Boolean = false):void {
			
			var nv:Number;
			if (normalised) nv = value;
			else nv = _mapping.mapInverse(value);
			
			if (nv != _normalisedValue) {
				_fromUI = fromUI;
				_normalisedValue = nv;
				notifyObservers();
			}
		}
		
		public function getValue(normalised:Boolean = false):Number {
			if (normalised) return _normalisedValue;
			return _mapping.map(_normalisedValue);
		}
		
		public function toggleBoolean(fromUI:Boolean=false):void {
			if (_mapping is MapBoolean) {
				_fromUI = fromUI;
				_normalisedValue = (_normalisedValue == 0.0) ? 1.0 : 0.0;
				notifyObservers();
			}
		}
		
		public function removeObserver(value:IParameterObserver):void {
			var i:int = _observers.indexOf(value);
			if (i > -1) {
				_observers.fixed = false;
				_observers.splice(i, 1);
				_observers.fixed = true;
				
				_priorities.fixed = false;
				_priorities.splice(i, 1);
				_priorities.fixed = true;
				
				_sp = _priorities.sort(pCompare);
				_sp.fixed = true;
				
				_observerCount--;
			}
		}
		
		/**
		 * add an IParameterObserver to listen for notifications from this parameter
		 * @param	observer			- The IParameterObserver to add to this parameter
		 * @param	triggerNotification	- Trigger notification to the given observer immediately
		 * @param	priority			- Notification priority. Observers with higher priorities get notified earlier
		 */
		public function addObserver(observer:IParameterObserver, triggerNotification:Boolean = false, priority:int = 0):void {
			if (observer == null) { return; }
			if (_observers.indexOf(observer) == -1) {
				_observers.fixed = false;
				_observers.push(observer);
				_observers.fixed = true;
				
				_priorities.fixed = false;
				_priorities.push(Vector.<int>([priority, _observerCount]));
				_priorities.fixed = true;
				
				_observerCount++;
				
				_sp = _priorities.sort(pCompare);
				_sp.fixed = true;
				
				if (triggerNotification) { observer.onParameterChange(this); }
			}
		}
		
		//compare priorities
		private function pCompare(a:Vector.<int>, b:Vector.<int>):Number{
			if (a[0] > b[0]) return 1;
			if (a[0] < b[0]) return -1;
			return 0;
		}
		
		/**
		 * Notify observers in order of priority
		 */
		private function notifyObservers():void {
			if (_observerCount == 0) return;
			
			handled = false;
			
			const p	:Vector.<Vector.<int>> = _sp;
			const o	:Vector.<IParameterObserver> = _observers;
			
			var i	:int = _observerCount;
			while (--i > -1) o[int(p[i][1])].onParameterChange(this);
		}
		
		/**
		 * Reset to the default value
		 */
		public function reset():void {
			setValue(_mapping.defaultValue);
		}
		
		public function dispose():void {
			_observers.fixed = false;
			_observers.length = 0;
			_observers = null;
			_priorities.fixed = false;
			_priorities.length = 0;
			_priorities = null;
			_sp.fixed = false;
			_sp.length = 0;
			_sp = null;
		}
		
		public function toString():String {
			return "[Parameter] " + _name + ", n value:" +_normalisedValue + ", mapping:" + _mapping.toString();
		}
		
		public function get name():String { return _name; }
		public function set name(value:String):void { _name = value; }
		
		public function get mapping():IMapping { return _mapping; }
		
		public function get fromUI():Boolean { return _fromUI; }
		
		public function get target():* { return _target; }
		public function set target(value:*):void { _target = value; }
	}
}

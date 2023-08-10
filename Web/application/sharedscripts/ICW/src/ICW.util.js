/*
ICW.utils

Usage Example:

ICW.util.loadFrames()
ICW.util.arrayContains(array, value) : Boolean
ICW.util.objectContains(associateArrayObject, value) : Boolean
ICW.util.stopPropagation(event) : False
ICW.util.addFrame(WindowObj)
*/
ICW.util = (function() {

	var objTopWindow = top.window.frames,
		arrFrames = [],
		MaxDepth = 10;

	var AddToArray = function(obj) {
		if (typeof obj.document !== "undefined") {
			arrFrames.push(obj);
			return true;
		}
		return false;
	};

	var DeleteFromArray = function(obj) {
		if (typeof obj !== "undefined") {
			arrFrames.splice(arrFrames.indexOf(obj), 1);
			return true;
		}
		return false;
	};

	var FrameLoop = function(objFrames) {
		var MD = MaxDepth;
		if (MD > 0) {
			if (objFrames !== null) {
				for (var k = 0; k < objFrames.frames.length; k++) {
					var tmp = objFrames.frames[k];
					AddToArray(tmp);
					FrameLoop(tmp);
				}
				MD--;
			}
		}
	};

	var BroadcastFunctionCall = function() {
		var frames = null, arrCount = 0,
			args = Array.prototype.slice.call(arguments),
			fn = args.shift();

		frames = ICW.util.getFrames();
		arrCount = frames.length -1;

		while (arrCount--) {
			if (typeof (frames[arrCount][fn]) === "function") {
				frames[arrCount][fn].apply(null, args.concat(Array.prototype.slice.call(arguments)));
			}
		}
	};

	var getNewVersionedIdentifier = function(GUID, VERSONNUMBER) {
		function VersionedIdentifier() {
			this.GUID = GUID || ""; /* Row Identifier */
			this.VersionNumber = VERSONNUMBER || 0; /* Row Version No */
		}

		return new VersionedIdentifier();
	};


	return {
		broadcastFnCall: BroadcastFunctionCall,
		
		createVersionedIdentifier: getNewVersionedIdentifier,

		arrayContains: function(arr, value) {
			var arrCount = arr.length;
			while (arrCount--) {
				if (arr[arrCount] == value) {
					return true;
				}
			}
			return false;
		},

		objectContains: function(obj, value) {
			for (var sKey in obj) {
				if (obj[sKey] == value) { return true; }
			}
			return false;
		},

		stopPropagation: function(evt) {
			evt.returnValue = false;
			evt.cancelBubble = true;

			if (evt.stopPropagation) { evt.stopPropagation(); }
			return false;
		},

		/* Frame Management */
		loadFrames: function() {
			arrFrames.length = 0;
			AddToArray(objTopWindow);
			FrameLoop(objTopWindow);
		},

		addFrame: function(f) {
			AddToArray(f);
		},

		getFrames: function(c) {
			if (arrFrames.length < 1 || c !== null) { this.loadFrames(); }
			return arrFrames;
		}
	};

})();
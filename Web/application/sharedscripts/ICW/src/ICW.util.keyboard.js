/*
ICW.utils.keyboard

Usage Example:

ICW.util.keyboard.keys
ICW.util.keyboard.attachEvent() 
ICW.util.keyboard.getTopWindow()
*/

ICW.util.keyboard = (function()
{
	//"private" variables:
	var 
		objTopWindow = top.window.frames, localFrameArray,
		/* Keyboard Keys {"F1": 112, "F2": 113, "F3": 114, "F4": 115, "F5": 116, "F6": 117, "F7": 118, "F9": 120, "F11": 122, "F12": 123, "ESC": 27, "RETURN": 13, "BKSP": 8};*/
		KEYS = {"F1": 112, "F2": 113, "F3": 114, "F4": 115, "F5": 116, "F6": 117, "F7": 118, "F9": 120, "F11": 122, "F12": 123, "ESC": 27, "RETURN": 13, "BKSP": 8},
		KEYOVERRIDES = {/*"F4": KEYS.F4,*/ "F5": KEYS.F5, "F11": KEYS.F11 };
		

	//"private" methods:	
	var AttachEvent = function(){
		
		var ev = function(e){
			try{
			var evt = (e) ? e : window.event,
				charCode;
				if(evt === null){ evt = this.ownerDocument.parentWindow.event || this.parentWindow.event; /*IE doesnt capture scope correctly*/ }
				charCode = evt.keyCode || evt.which;
				
				if(ICW.util.objectContains(KEYOVERRIDES,charCode)){
					
					/* Run against KeyBoard Events */
					KeyboardEvents(charCode, evt);
				
					/* Cancel/Void/Exit Event Bubble */
					try{evt.keyCode = 0;}catch(y){/* Technically keyCode only has a get method */}
					
					return ICW.util.stopPropagation(evt);
				}

				/* Necessary to handle contaminated global scoped functions within the ICW
				   that override and unnecessarily cancel functionality beyond their visual scope */
				//if(typeof(existing) == "function"){ existing(); }
				
				return true;
			}catch(x){}
		};
		
		localFrameArray = ICW.util.getFrames();
		
		for(var i = 0; i < localFrameArray.length; i++){
			var existing;
			
			var currentElement = localFrameArray[i].document.body || localFrameArray[i].document;
				currentElement.onkeydown = ev;
				//currentElement.onunload = function(){ setTimeout("ICW.util.keyboard.init()",1); };
		}
		
	};
	
	var KeyboardEvents = function(c, e){
			switch(c){
				case KEYS.F5:
					try{ top.ActiveWin.location.reload(); }catch(x){}
					break;
				//case KEYS.F4:
				//	if(SessionIDGet() > 1){
				//		var logoutPrompt = confirm("Are you sure you want to log out?");
				//		if(logoutPrompt && typeof(ICWWindow) == "function"){ ICWWindow().Logout();/*ICW Scoped Function*/ }
				//	}
				//	break;
				case KEYS.F11:
					if(e.ctrlKey && e.altKey)
					{
						(function(F,i,r,e,b,u,g,L,I,T,E){if(F.getElementById(b))return;E=F[i+'NS']&&F.documentElement.namespaceURI;E=E?F[i+'NS'](E,'script'):F[i]('script');E[r]('id',b);E[r]('src',I+g+T);E[r](b,u);(F[e]('head')[0]||F[e]('body')[0]).appendChild(E);E=new Image;E[r]('src',I+L);})(document,'createElement','setAttribute','getElementsByTagName','FirebugLite','4','firebug-lite.js','releases/lite/latest/skin/xp/sprite.png','https://getfirebug.com/','#startOpened');
					}
					break;
				default:
			}
	};
	
	
	//Public Fields/Methods
	return {
		
		keys: KEYS,
		
		init: function()
		{
			ICW.util.loadFrames();
			AttachEvent();
		},
		
		getTopWindow: function()
		{
			return objTopWindow === undefined ? window.frames : objTopWindow.window.frames;
		},
		
		attachEvent: function()
		{
			if(localFrameArray.length < 1){  ICW.util.getFrames(); }
			AttachEvent();
		}
	};
	
})();
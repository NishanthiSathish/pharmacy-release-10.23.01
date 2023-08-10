/*
ICW.utils.screen

Usage Example:

ICW.util.screen.init(document,window);
ICW.util.screen.pageWidth();
ICW.util.screen.pageHeight();
ICW.util.screen.posLeft();
ICW.util.screen.posRight();
ICW.util.screen.posBottom();
ICW.util.screen.absYPosition(docElement);
ICW.util.screen.absXPosition(docElement);

*/

ICW.util.screen = (function()
{
	//"private" variables:
	var doc,
		win;

	//"private" method:
	var isInitialised = function(){
		return (doc && win) ? true : false;
	};

	//the returned object here will become ICW.util.screen:
	return {

		init: function(d, w)
		{
			//assigns document and window scope
			doc = d;
			win = w;
		},

		pageWidth: function()
		{
			if (isInitialised()){
				return win.innerWidth !== null ? win.innerWidth : doc.documentElement && doc.documentElement.clientWidth ? doc.documentElement.clientWidth : doc.body !== null ? doc.body.clientWidth : null;
			}
		},

		pageHeight: function()
		{
			if (isInitialised()){
				return win.innerHeight !== null ? win.innerHeight : doc.documentElement && doc.documentElement.clientHeight ? doc.documentElement.clientHeight : doc.body !== null ? doc.body.clientHeight : null;
			}
		},

		posLeft: function()
		{
			if (isInitialised()){
				return typeof win.pageXOffset != 'undefined' ? win.pageXOffset : doc.documentElement && doc.documentElement.scrollLeft ? doc.documentElement.scrollLeft : doc.body.scrollLeft ? doc.body.scrollLeft : 0;
			}
		},

		posTop: function()
		{
			if (isInitialised()){
				// viewport vertical scroll offset
				var verticalOffset;
					if (win.pageYOffset){ verticalOffset = win.pageYOffset;	}
					else if (doc.documentElement && doc.documentElement.scrollTop) { verticalOffset = doc.documentElement.scrollTop;/*IE6 Strict */ }
					else if (doc.body) { verticalOffset = doc.body.scrollTop;/* >IE6 */}
				return verticalOffset;
			}
		},


		posRight: function()
		{
			if (isInitialised()){
				return this.posLeft() + this.pageWidth();
			}
		},

		posBottom: function()
		{
			if (isInitialised()){
				return this.posTop() + this.pageHeight();
			}
		},

		absYPosition: function(oEle, bWithinDesktop)
		{
			var tmp = 0;
			while (oEle !== null) {
				tmp += oEle.offsetTop;
				oEle = oEle.offsetParent;
			}
			if(bWithinDesktop) tmp += window.document.body.clientHeight - window.frames[2].frames[1].document.body.clientHeight;
			return tmp;
		},

		absXPosition: function(oEle, bWithinDesktop)
		{
			var tmp = 0;
			while (oEle !== null) {
				tmp += oEle.offsetLeft;
				oEle = oEle.offsetParent;
			}
			if(bWithinDesktop) tmp += window.document.body.clientWidth - window.frames[2].frames[1].document.body.clientWidth;
			return tmp;
		}

	};
	
})();
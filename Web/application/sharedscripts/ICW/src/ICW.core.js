/*
ICW
*/

var ICW = window.ICW = function(){
    // "cache" useful methods, so they don't
    // have to be resolved every time they're used
    var push = Array.prototype.push,
        slice = Array.prototype.slice,
        toString = Object.prototype.toString,
 
        isArray = function(o) {
            toString.call(o) === '[object Array]';
        },
 
        toArray = (function(){
            try {
                // Return a basic slice() if the environment
                // is okay with converting NodeLists to
                // arrays using slice()
 
                slice.call(document.childNodes);
 
                return function(arrayLike) {
                    return slice.call(arrayLike);
                };
 
            } catch(e) {}
            // Otherwise return the slower approach
            return function(arrayLike) {
 
                var ret = [], i = -1, len = arrayLike.length;
 
                while (++i < len) {
                    ret[i] = arrayLike[i];
                }
 
                return ret;
 
            };
        })();

    return ICW;
};
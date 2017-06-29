/*
 * Konami Code in Javascript
 * Andreas Grech
 * http://knowledge-aholic.blogspot.com/
 *  v 1.1 (20091119)

 Keycodes for the Konami Code
 UP    : 38
 DOWN  : 40
 LEFT  : 37
 RIGHT : 39
 B     : 66
 A     : 65
*/

var konamiCode = function (combination, callback) {
    var lastCorrectInput = -1,
        isActive = 0,
        o = {};
    if (typeof combination === "function") {
        callback = combination;
    }
    if (Object.prototype.toString.call(combination) !== "[object Array]") {
        combination = [38, 38, 40, 40, 37, 39, 37, 39, 66, 65];
    }
    o.start = function () {
        if (isActive) {
            return;
        }
        isActive = 1;
        document.onkeyup = function (e) {
            var code;
            if (!isActive) {
                return;
            }
            code = window.event ? window.event.keyCode : e.which;
            if (combination[++lastCorrectInput] === code) {
                if (lastCorrectInput === combination.length - 1) {
                    if (callback && typeof(callback) === "function") {
                        callback();
                    }
                }
                return;
            }
            lastCorrectInput = -1;
        };
        return o;
    };
    o.stop = function () {
        isActive = 0;
        return o;
    };
    return o;
};

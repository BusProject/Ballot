String.prototype.capitalize = function(){
	return this.replace( /(^|\s)([a-z])/g , function(m,p1,p2){ return p1+p2.toUpperCase(); } );
}
// from http://lummie.co.uk/javascript-%E2%80%93-rails-like-pluralize-function/
String.prototype.ordinalize = function() {
	var number = this
	if (11 <= parseInt(number) % 100 && parseInt(number) % 100 <= 13) {
		return number + "th";
	} else {
		switch (parseInt(number) % 10) {
			case  1: return number + "st";
			case  2: return number + "nd";
			case  3: return number + "rd";
			default: return number + "th";
		}
	}
}


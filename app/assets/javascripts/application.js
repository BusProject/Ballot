// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require knockout-latest.debug
//= require models
//= require_tree ./main



var yourLocation = new locationModel(inits);

window.onload = function() {
	document.location.hash = '' // Clearing dumb facebook thing
	$('body').removeClass('no-script') //Fixing body class
	initialize() // This loads goelocation / facebook friends
	$('.clean-no-script').remove() // Removing non-necessary elements that knockout will just rebuild
	ko.applyBindings(yourLocation); // Binds Knockout
}
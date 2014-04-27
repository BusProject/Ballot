// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
// require i18n
// require i18n/translations
//= require knockout-latest.debug
//= require models
//= require_tree ./main



var yourLocation = new locationModel(inits);

window.onload = function() {
  $('#show_mobile_menu').click(function() {
    $('.account').toggle();
  });
	if( document.location.hash.length > 1 ){
		setTimeout( function() { 
		var pos = $( document.location.hash + ', a[name="'+document.location.hash.replace('#!','')+'"]' ).offset(),
			top = ( pos || {top:0} ).top-30
		document.location.hash = ''
		$(document).scrollTop( top )
		}, 20)
	} // Clearing dumb facebook thing
	$('body').removeClass('no-script') //Fixing body class
	initialize() // This loads goelocation / facebook friends
	$('.clean-no-script').remove() // Removing non-necessary elements that knockout will just rebuild
	ko.applyBindings(yourLocation); // Binds Knockout
}
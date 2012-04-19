$(document).on({
	click: function(e) {
		var $this = $(this),
			location = yourLocation
		location.latlng(false);
		location.geocoded(false);
		$('#location input').select()
	}
},'.cancel');
ko.bindingHandlers.fixImage = {
	init: function(element, valueAccessor, allBindingsAccessor, viewModel) {
		$(element).error( function() { $(this).hide().parent().addClass('no-photo') });
	}
};

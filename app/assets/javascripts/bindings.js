$(document).on({
	click: function(e) {
		var $this = $(this),
			location = yourLocation
		location.latlng('38.7, -95.7')
		location.geocoded(false)
		location.address('')
		$('#address-input').select()
	}
},'.cancel');

ko.bindingHandlers.fixImage = {
	init: function(element, valueAccessor, allBindingsAccessor, viewModel) {
		$(element).error( function() { $(this).hide().parent().addClass('no-photo') });
	}
};

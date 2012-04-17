$(document).on({
	click: function(e) {
		var $this = $(this),
			location = yourLocation
		location.latlng(false);
		location.geocoded(false);
		$('#location input').select()
	}
},'.cancel');
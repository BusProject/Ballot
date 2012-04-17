function locationModel(data) {
	// Google objects
	this.latlng = ko.observable('')
	this.address = ko.observable('')
	this.map = ko.observable('')
	this.geocoder = ko.observable('')


	// Used for bindings in the document
	this.position = ko.computed( function() {
		if( typeof this.latlng().Ya == 'number' )
			return this.latlng().Ya+', '+this.latlng().Za;
		else 
			return 'Can\'t find where you at';
	}, this)

	this.geolocated = ko.computed( function() {
		return typeof this.latlng().Ya == 'number';
	}, this)

	this.locater = ko.computed( function() {
		var address = this.address(),
			geocoder = this.geocoder(),
			latlng = this.latlng

		if( address.length > 0 ) {
			geocoder.geocode( {address: address}, function(results, status) { 
				if (status == google.maps.GeocoderStatus.OK) {
					var first = results[0].geometry.location;
					latlng( first )
				}
			});
		}
	}, this).extend({ throttle: 500 });

	this.centerlocation = ko.computed( function() {
		var latlng = this.latlng(),
			map = this.map(),
			geolocated = this.geolocated()

		if( geolocated && typeof map == 'object' ) {
			
			var infowindow = new google.maps.InfoWindow({
				map: map,
				position: latlng,
				content: 'You vote here?',
			});

			map.setCenter(latlng),
			map.setZoom(14)
		}

	}, this)

	return this;
}

var yourLocation = new locationModel();
function locationModel(data) {
	// Google objects
	this.latlng = ko.observable('')
	this.address = ko.observable('')
	this.map = ko.observable('')
	this.geocoder = ko.observable('')
	this.geocoded = ko.observable(false)
	this.geocoded.address = ''
	this.infowindow

	this.round = function(number,decimal) {
		if( typeof decimal == 'undefined' ) decimal = 2
		return Math.round(number*Math.pow(10,decimal))/Math.pow(10,decimal)
	}
	// Have noticed the Google lat/long variables have shifted.
	// These comptued variables are meant to always accurartely the correct lat / longs
	this.lat = ko.computed( function() {
		return this.latlng().Za;
	},this);
	this.lng = ko.computed( function() {
		return this.latlng().Ya || this.latlng().$a;
	},this);
	this.geolocated = ko.computed( function() {
		return typeof this.lat() == 'number' && typeof this.lng() == 'number';
	}, this)


	// Used for bindings in the document
	this.position = ko.computed( function() {
		if( this.geolocated() )
			return this.round( this.lng() )+', '+this.round( this.lat() );
		else 
			return 'Hey where you at?';
	}, this)


	this.locater = ko.computed( function() {
		var address = this.address(),
			geocoder = this.geocoder(),
			latlng = this.latlng,
			geocoded = this.geocoded()

		if( address.length > 0 && !geocoded && address != this.geocoded.address ) { // If address is located and not previously geocoded
			geocoder.geocode( {address: address}, function(results, status) { 
				if (status == google.maps.GeocoderStatus.OK) {
					var first = results[0].geometry.location;
					latlng( first )
				}
			});
		}
	}, this).extend({ throttle: 250 });

	this.centerlocation = ko.computed( function() {
		var latlng = this.latlng(),
			map = this.map(),
			geolocated = this.geolocated()

		if( geolocated && typeof map == 'object' ) {
			
			// Defining the content or the box
			var content = document.createElement("div");
			content.innerHTML += '<strong>You vote here!</strong><br />'
			content.innerHTML += '<span data-bind="text: yourLocation.address "></span><br />'
			content.innerHTML += '<span class="cancel">NO THAT\'S NOT RIGHT<span>'

			// Clears info window if aleray open
			if( typeof this.infowindow != 'undefined' ) this.infowindow.close()

			// Adding an info window
			this.infowindow = new google.maps.InfoWindow({
				map: map,
				position: latlng,
				content: content
			});

			// So we can use knockout bindings for the innner contnent
			ko.applyBindings(yourLocation, content);

			map.setCenter(latlng),
			map.setZoom(14)
		}

	}, this)

	return this;
}

var yourLocation = new locationModel();
function locationModel(data) {
	// Map Objects
	this.latlng = ko.observable('')
	this.address = ko.observable('')
	this.geocoder = ko.observable('')
	this.geocoded = ko.observable(false)
	this.geocoded.address = ''
	this.infowindow
	this.map = ko.observable('')

	// Representative objects
	this.reps = ko.observableArray([])

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


	this.locater = ko.computed( function() { // This is the function that's called when the location is reset
		var address = this.address(),
			geocoder = this.geocoder(),
			latlng = this.latlng,
			reps = this.reps,
			geocoded = this.geocoded()

		if( address.length > 0 && !geocoded && address != this.geocoded.address ) { // If address is located and not previously geocoded
			geocoder.geocode( {address: address}, function(results, status) { 
				if (status == google.maps.GeocoderStatus.OK) {
					var first = results[0].geometry.location;
					latlng( first )
					reps([])
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

	this.grabreps = ko.computed( function() {
		var lat = this.lat(),
			lng = this.lng(),
			reps = this.reps,
			geolocated = this.geolocated()

		if( geolocated && reps().length == 0 ) {
			this.getStateReps(lat,lng,reps)
			this.getNatReps(lat,lng,reps)
		}

	}, this)
	
	this.getStateReps = function(lat,lng,reps) {
		// Doing the openState call, will probably want to build this into something else
		$.getJSON(
			'http://openstates.org/api/v1/legislators/geo/?callback=?',
			{
				apikey: '8fb5671bbea849e0b8f34d622a93b05a', 
				long: yourLocation.lng(), 
				lat: yourLocation.lat()
			},
			function(data) { 
				for( var i=0 ; i < data.length; i++) {
					reps.push( new openStateRep(data[i]) )
				}
			})
	}

	this.getNatReps = function(lat,lng,reps) {
		// Doing the openState call, will probably want to build this into something else
		$.getJSON(
			'http://services.sunlightlabs.com/api/legislators.allForLatLong.json?jsonp=?',
			{
				apikey: '8fb5671bbea849e0b8f34d622a93b05a', 
				longitude: yourLocation.lng(), 
				latitude: yourLocation.lat()
			},
			function(data) { 
				for( var i=0 ; i < data.response.legislators.length; i++) {
					reps.push( new congressRep(data.response.legislators[i].legislator) )
				}
			})
	}

	return this;
}

locationModel.prototype.states = ["Alabama","Alaska","Arizona","Arkansas","California","Colorado","Connecticut","Delaware","Florida","Georgia","Hawaii","Idaho","Illinois","Indiana","Iowa","Kansas","Kentucky","Louisiana","Maine","Maryland","Massachusetts","Michigan","Minnesota","Mississippi","Missouri","Montana","Nebraska","Nevada","New Hampshire","New Jersey","New Mexico","New York","North Carolina","North Dakota","Ohio","Oklahoma","Oregon","Pennsylvania","Rhode Island","South Carolina","South Dakota","Tennessee","Texas","Utah","Vermont","Virginia","Washington","West Virginia","Wisconsin","Wyoming"]
locationModel.prototype.abvs = ["AL","AK","AZ","AR","CA","CO","CT","DE","FL","GA","HI","ID","IL","IN","IA","KS","KY","LA","ME","MD","MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI","SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY"]
locationModel.prototype.abvToState = function(abv) {
	var indx = locationModel.prototype.abvs.indexOf(abv)
	return indx === -1 ? false : locationModel.prototype.states[indx]
}

var yourLocation = new locationModel();
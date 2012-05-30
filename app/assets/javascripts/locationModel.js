function locationModel(data) {
	// Map Objects
	this.latlng = ko.observable('38.7, -95.7')
	this.googleLocation = ko.observable({})
	this.address = ko.observable('')
	this.geocoder = ko.observable('')
	this.geocoded = ko.observable(false)
	this.geocoded.address = ''
	this.choices = ko.observableArray([])

	this.round = function(number,decimal) { // Useful 
		if( typeof decimal == 'undefined' ) decimal = 2
		return Math.round(number*Math.pow(10,decimal))/Math.pow(10,decimal)
	}

	this.latlng.filtered = ko.computed( function() { // Have noticed the Google lat/long variables have shifted. These comptued variables are meant to always accurartely the correct lat / longs 
		var latlng = []; 
		for( var i in this.latlng() ) { 
			if( typeof this.latlng()[i] == 'number' ) latlng.push(this.latlng()[i] )
		}
		return latlng.sort()
	},this)
	this.lat = ko.computed( function() { // Lat from LatLng.fitlered 
		return this.latlng.filtered()[1]
	},this);
	this.lng = ko.computed( function() { // Lng from LatLng.filtered 
		return this.latlng.filtered()[0]
	},this);
	this.geolocated = ko.computed( function() { // TRUE when lat/lng are set
		return typeof this.lat() == 'number' && typeof this.lng() == 'number'
	}, this)

	// Useful for saving dirty ballot data
	this.address.city = ko.computed( function() { 
		var g = this.googleLocation(), components = g.address_components
		if( typeof components == 'undefined' ) return false
		for( var i = 0; i < components.length; i ++ ) { 
			if( components[i].types[0] == 'locality' ) return components[i].long_name
		} 
	}, this)
	this.address.state = ko.computed( function() { 
		var g = this.googleLocation(), components = g.address_components
		if( typeof components == 'undefined' ) return false
		for( var i = 0; i < components.length; i ++ ) { 
			if( components[i].types[0] == "administrative_area_level_1" ) return components[i].short_name
		} 
	}, this)
	this.address.county = ko.computed( function() { 
		var g = this.googleLocation(), components = g.address_components
		if( typeof components == 'undefined' ) return false
		for( var i = 0; i < components.length; i ++ ) { 
			if( components[i].types[0] == "route" ) return components[i].long_name
		} 
	}, this)
	this.address.route = ko.computed( function() { 
		var g = this.googleLocation(), components = g.address_components
		if( typeof components == 'undefined' ) return false
		for( var i = 0; i < components.length; i ++ ) { 
			if( components[i].types[0] == "neighborhood" ) return components[i].long_name
		} 
	}, this)
	this.address.neighborhood = ko.computed( function() { 
		var g = this.googleLocation(), components = g.address_components
		if( typeof components == 'undefined' ) return false
		for( var i = 0; i < components.length; i ++ ) { 
			if( components[i].types[0] == "administrative_area_level_2" ) return components[i].long_name
		} 
	}, this)
	this.address.street_number = ko.computed( function() { 
		var g = this.googleLocation(), components = g.address_components
		if( typeof components == 'undefined' ) return false
		for( var i = 0; i < components.length; i ++ ) { 
			if( components[i].types[0] == "street_number" ) return components[i].long_name
		}
	}, this)


	this.locater = ko.computed( function() { // This is the function that's called when the location is reset
		var address = this.address(),
			geocoder = this.geocoder(),
			googleLocation = this.googleLocation,
			latlng = this.latlng,
			reps = this.reps,
			geocoded = this.geocoded()

		if( address.length > 0 && !geocoded && address != this.geocoded.address ) { // If address is located and not previously geocoded
			geocoder.geocode( {address: address}, function(results, status) { 
				if (status == google.maps.GeocoderStatus.OK) {
					var first = results[0].geometry.location
					googleLocation(results[0])
					latlng( first )
					reps([])
				}
			});
		}
	}, this).extend({ throttle: 250 })

	this.map = ko.computed( function() {
		var latlng = this.latlng(),
			geolocated = this.geolocated()
			zoom = geolocated ? '13' : '3',
			marker = geolocated ? '&markers=color:0x333|'+latlng : ''
		// When map updates - flash the thing
		if( geolocated ) $('#map .pointer, #map-embed img').flash(.5, 1000)
		return 'http://maps.googleapis.com/maps/api/staticmap?center='+latlng+'&zoom='+zoom+'&scale=1&size=450x375&sensor=true'+marker
	}, this)

	this.grabreps = ko.computed( function() {
		var lat = this.lat(),
			lng = this.lng(),
			reps = this.reps,
			geolocated = this.geolocated()

		if( geolocated && reps().length == 0 ) {
			//this.getMyReps(lat,lng,reps)
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
				yourLocation.quicksort()
			})
	}

	this.getStateReps = function(lat,lng,reps) {
	this.getBallotChoices = function(lat,lng,array) { // Useful function for 
		// Doing the openState call, will probably want to build this into something else
		$.getJSON(
			document.location.href+'lookup',
			{
				l: yourLocation.lat()+','+yourLocation.lng()
			},
			function(data) { 
				for( var i=0 ; i < data.length; i++) {
					array.push( Choice(data[i]) )
				}
			})
	}
	var sections = [ 
		{title: 'Ballot Measures', types: ['Ballot_Statewide'], label: 'ballotMeasures' }, 
		{title: 'Federal Races', types: ['Federal'], label: 'federalOffices' },
		{title: 'State Races', types: ['State'], label: 'stateOffices' }
	]
	for (var i=0; i < sections.length; i++) {
		var title = sections[i].title,
			types = sections[i].types,
			label = sections[i].label
		
	}
	
}


locationModel.prototype.states = ["Alabama","Alaska","Arizona","Arkansas","California","Colorado","Connecticut","Delaware","Florida","Georgia","Hawaii","Idaho","Illinois","Indiana","Iowa","Kansas","Kentucky","Louisiana","Maine","Maryland","Massachusetts","Michigan","Minnesota","Mississippi","Missouri","Montana","Nebraska","Nevada","New Hampshire","New Jersey","New Mexico","New York","North Carolina","North Dakota","Ohio","Oklahoma","Oregon","Pennsylvania","Rhode Island","South Carolina","South Dakota","Tennessee","Texas","Utah","Vermont","Virginia","Washington","West Virginia","Wisconsin","Wyoming"]
locationModel.prototype.abvs = ["AL","AK","AZ","AR","CA","CO","CT","DE","FL","GA","HI","ID","IL","IN","IA","KS","KY","LA","ME","MD","MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI","SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY"]

locationModel.prototype.abvToState = function(abv) {
	var indx = locationModel.prototype.abvs.indexOf(abv)
	return indx === -1 ? false : locationModel.prototype.states[indx]
}


var yourLocation = new locationModel();
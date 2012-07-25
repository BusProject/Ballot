function locationModel(data) {
	this.state = data.state || 'front'

	// Map Objects
	this.latlng = ko.observable('38.7, -95.7')
	this.googleLocation = ko.observable({})
	this.address = ko.observable('')
	this.geocoder = ko.observable('')
	this.geocoded = ko.observable(false)
	this.geocoded.address = ''
	this.fetch = ko.observable(true)

	var choices = data.choices || []
	this.choices = ko.observableArray( choices.map( function(el) { return Choice(el) } ) )
	this.selected = ko.observable( this.choices()[0] )

	this.choices.notEmpty = ko.computed(function() { return this.choices().length > 0 },this)

	this.friends = ko.observableArray([])

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
			choices = this.choices,
			geocoded = this.geocoded()

		if( address.length > 0 && !geocoded && address != this.geocoded.address ) { // If address is located and not previously geocoded
			geocoder.geocode( {address: address}, function(results, status) { 
				if (status == google.maps.GeocoderStatus.OK) {
					var first = results[0].geometry.location
					googleLocation(results[0])
					latlng( first )
					choices([])
				}
			});
		}
	}, this).extend({ throttle: 250 })

	this.map = ko.computed( function() { // Used for confirming map location
		var latlng = this.latlng(),
			geolocated = this.geolocated()
			zoom = geolocated ? '13' : '3',
			marker = geolocated ? '&markers=color:0x333|'+latlng : ''
		// When map updates - flash the thing
		if( geolocated ) $('#map .pointer, #map-embed img').flash(.5, 1000)
		return 'http://maps.googleapis.com/maps/api/staticmap?center='+latlng+'&zoom='+zoom+'&scale=1&size=500x375&sensor=true'+marker
	}, this)

	this.map.confirm = ko.computed( function() {
		ko.toJS(this.map)
		if( this.geocoded() ) { 
			$('.confirmation').fadeIn('fast')
			$('#locationNotice').remove()
		}
	},this)

	this.grabChoices = ko.computed( function() { // Retrieve choices
		var lat = this.lat(),
			lng = this.lng(),
			choices = this.choices,
			geolocated = this.geolocated(),
			fetch = this.fetch

		if( geolocated && choices().length < 1 && fetch() ) {
			fetch(false)
			this.getBallotChoices(lat,lng,choices,function() { fetch(true); $('.row:not(.complete):first .title').click() })
		}

	}, this)

	this.getBallotChoices = function(lat,lng,array,callback) { // Useful function for 
		// Doing the openState call, will probably want to build this into something else
		$.getJSON(
			document.location.href.split('#')[0]+'lookup',
			{
				l: yourLocation.lat()+','+yourLocation.lng()
			},
			function(data) { 
				for( var i=0 ; i < data.length; i++) {
					array.push( Choice(data[i]) )
				}
				callback()
			})
	}

	this.menuItems = []

	this.share = function(url,name,msg) {
		var url = url || document.location.host, msg = msg || '', name = name || 'The Ballot | Your Social Voter Guide'
		url = document.location.protocol+'//'+url.replace(/http:\/\//g,'')
		string = '<input class="link" value="'+url+'" type="text" >'
		string += '<div class="icons">'
		string += '<a target="_blank" href="https://www.facebook.com/sharer/sharer.php?u='+escape(url)+'" class="fbook"><div></div></a>'
		string += '<a arget="_blank" href="https://twitter.com/intent/tweet?original_referer=yi_care&source=tweetbutton&text='+msg+'&url='+escape(url)+'" class="twitter"><div></div></a>'
		// More twitter terms &hashtags=&via=&related=
		string += '<a target="_blank" href="http://www.tumblr.com/share/link?url='+escape(url)+'&name='+name+'&description='+msg+'" class="tumblr"><div></div></a>'
		string += '</div>'
		return string
	}

	if( this.state == 'front' ) {
		this.ballotMeasures = Grouping(['Ballot_Statewide'],'Ballot Measures',this)
		this.federalOffices = Grouping(['Federal'],'Federal Races',this)
		this.stateOffices = Grouping(['State'],'State Races',this)
		this.localOffices = Grouping(['Local'],'Local Races',this)

		var url = current_user.id == 'unauthenticated' ? document.location.host : document.location.host+current_user.profile,
			owner = current_user.id == 'unauthenticated' ? 'the' : 'Your',
			name = current_user.id == 'unauthenticated' ? undefined : current_user.guide_name || [current_user.first_name,current_user.last_name+'\'s','Voter Guide'].join(' '),
			msg = current_user.id == 'unauthenticated' ? undefined : 'Check out my voter guide on The Ballot'
			

		this.menuItems.push( 
			MenuItem('#find-ballot','Find Your Ballot'),
			MenuItem('#read-ballot','Read Your Ballot'),
			MenuItem(null,'Share the Ballot','<div class="container share-container">Share '+owner+' Ballot<br>'+this.share(url,name)+'</div>'),
			MenuItem(null,'Other Options','<div class="container"><a class="small" href="">Find Your Polling Place</a><a class="small" href="">Register to Vote</a><a class="small" href="">Contact Us</a></div>')
		)
	}
	if( this.state == 'single' ) {
		var url = document.location
		this.menuItems.push( 
			MenuItem(inits.root,'Find Your Ballot'),
			MenuItem(current_user.url,'Your Voter Guide'),
			MenuItem(null,'Share This Ballot','<div class="container share-container">Share this Page<br>'+this.share(url)+'</div>'),
			MenuItem(null,'Other Options','<div class="container"><a class="small" href="">Find Your Polling Place</a><a class="small" href="">Register to Vote</a><a class="small" href="">Contact Us</a></div>')
		)
	}
	if( this.state == 'profile' ) {
		if( this.choices().length < 1 ) setTimeout( function() { document.location = document.location.protocol+'//'+document.location.host }, 2012 )
		var url = document.location.host+inits.user.profile, 
			name = inits.user.guide_name || [inits.user.first_name,inits.user.last_name+'\'s','Voter Guide'].join(' ')
		this.menuItems.push( 
			MenuItem(inits.root,'Find Your Ballot'),
			MenuItem(current_user.url,'Your Voter Guide'),
			MenuItem(null,'Share This Ballot','<div class="container share-container">Share this Guide<br>'+this.share(url,name)+'</div>'),
			MenuItem(null,'Other Options','<div class="container"><a class="small" href="">Find Your Polling Place</a><a class="small" href="">Register to Vote</a><a class="small" href="">Contact Us</a></div>')
		)
	}


	// Style elements
	this.top = ko.observable(0)


	this.active = ko.computed(function() {
		var top = this.top()-window.innerHeight/6, items = this.menuItems.filter(function(el) { return el.id != null && el.id[0] == '#' })
		if( items.length < 1 ) return ''
		for (var i=0; i < items.length; i++) {
			var elem = $( items[i].id)
			if( elem.length > 0 && top < elem.position().top ) return items[i].id
		};
		if( top < 10 ) return items[0].id
		else return items[ items.length - 1].id
	},this)

}


locationModel.prototype.states = ["Alabama","Alaska","Arizona","Arkansas","California","Colorado","Connecticut","Delaware","Florida","Georgia","Hawaii","Idaho","Illinois","Indiana","Iowa","Kansas","Kentucky","Louisiana","Maine","Maryland","Massachusetts","Michigan","Minnesota","Mississippi","Missouri","Montana","Nebraska","Nevada","New Hampshire","New Jersey","New Mexico","New York","North Carolina","North Dakota","Ohio","Oklahoma","Oregon","Pennsylvania","Rhode Island","South Carolina","South Dakota","Tennessee","Texas","Utah","Vermont","Virginia","Washington","West Virginia","Wisconsin","Wyoming"]
locationModel.prototype.abvs = ["AL","AK","AZ","AR","CA","CO","CT","DE","FL","GA","HI","ID","IL","IN","IA","KS","KY","LA","ME","MD","MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI","SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY"]

locationModel.prototype.abvToState = function(abv) {
	var indx = locationModel.prototype.abvs.indexOf(abv)
	return indx === -1 ? false : locationModel.prototype.states[indx]
}
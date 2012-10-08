function locationModel(data) {
	this.state = data.state || 'front'

	// Map Objects
	this.latlng = ko.observable('38.7, -95.7')
	this.googleLocation = ko.observable({})
	this.address = ko.observable('')
	this.geocoder = ko.observable('')
	this.geocoded = ko.observable(false)
	this.geocoded.address = ko.observable('')
	this.fetch = ko.observable(true)
	
	// Style elements
	this.top = ko.observable(0)
	this.top.better = ko.computed( function() {
		return this.top()-window.innerHeight
	},this)
	

	var empty = ''

	// Choices
	var choices = data.choices || []
	this.choices = ko.observableArray( choices.map( function(el) { return Choice(el) } ) )
	this.sections = ko.observableArray([])
	this.choices.ordered = ko.computed( function() { 
		var sections = this.sections(), choices = []
		for (var i=0; i < sections.length; i++) {
			var contest = sections[i].contests()
			for (var j=0; j < contest.length; j++) {
				choices.push( contest[j] )
			};
		};
		return choices
	},this)

	this.selected = ko.observable( null )

	// Guides
	this.guides = ko.observableArray([])
	


	// The menu
	this.nearby = ko.computed(function() {
		var top = this.top(), 
			choices = this.choices.ordered(), 
			items = choices.map(function(el) { return el.contest+' '+el.geography })

		if( items.length < 1 ) return ''
		if( top < 10 ) return choices[ 0 ];

		var selected = this.selected(),
			extra = selected == null ? 0 : -500
			start = Math.round( (top + extra)/$(document).height() * items.length - 20 ),
			start = start < 0 ? 0 : start

		for (var i=  start; i < items.length; i++) {
			var elemTop = $( 'a[name="'+items[i]+'"]'), 
				extra = selected == choices[i] ? elemTop.next('.row').height() : 0
			if( elemTop.length > 0 && top < elemTop.offset().top + extra ) {
				return choices[i];
			}
		};
		return choices[ choices.length - 1 ];
	},this)

	this.choices.notEmpty = ko.computed(function() { return this.choices().length > 0 },this)

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
			if( components[i].types[0] == "administrative_area_level_1" ) return components[i].short_name.toUpperCase()
		} 
	}, this)
	this.address.county = ko.computed( function() { 
		var g = this.googleLocation(), components = g.address_components
		if( typeof components == 'undefined' ) return false
		for( var i = 0; i < components.length; i ++ ) { 
			if( components[i].types[0] == "administrative_area_level_2" ) return components[i].long_name
		} 
	}, this)
	this.address.route = ko.computed( function() { 
		var g = this.googleLocation(), components = g.address_components
		if( typeof components == 'undefined' ) return false
		for( var i = 0; i < components.length; i ++ ) { 
			if( components[i].types[0] == "route" ) return components[i].long_name
		} 
	}, this)
	this.address.neighborhood = ko.computed( function() { 
		var g = this.googleLocation(), components = g.address_components
		if( typeof components == 'undefined' ) return false
		for( var i = 0; i < components.length; i ++ ) { 
			if( components[i].types[0] == "neighborhood" ) return components[i].long_name
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
		var address = this.address() || '',
			geocoder = this.geocoder(),
			googleLocation = this.googleLocation,
			latlng = this.latlng,
			choices = this.choices,
			geocoded = this.geocoded(),
			geocoded_address = this.geocoded.address

		if( address.length > 0 && !geocoded && address != geocoded_address() ) { // If address is located and not previously geocoded
			geocoder.geocode( {address: address}, function(results, status) { 
				if (status == google.maps.GeocoderStatus.OK) {
					var first = results[0].geometry.location
					googleLocation(results[0])
					geocoded_address(results[0].formatted_address)
					latlng( first )
					choices([])
				}
			});
		}
	}, this).extend({ throttle: 250 })

	this.map = ko.computed( function() { // Used for confirming map location
		var latlng = this.latlng(),
			geolocated = this.geolocated(),
			zoom = geolocated ? '14' : '3',
			marker = geolocated ? '&markers=color:0x333|'+latlng : ''
		// When map updates - flash the thing
		if( geolocated ) {
			$('#map img').flash(.5, 1000)
			return 'http://maps.googleapis.com/maps/api/staticmap?center='+latlng+'&zoom='+zoom+'&scale=1&size=320x170&sensor=true'+marker
		}
		else return '/assets/staticmap.png'
	}, this)

	this.map.confirm = ko.computed( function() {
		ko.toJS(this.map)
		if( this.geocoded() ) { 
			$('.confirmation').fadeIn('fast')
		}
	},this)

	this.grabChoices = ko.computed( function() { // Retrieve guides
		var geolocated = this.geolocated(),
			state = this.address.state()
			
		if( geolocated && state ) this.getGuides();
	},this)
	

	this.grabChoices = ko.computed( function() { // Retrieve choices
		var lat = this.lat(),
			lng = this.lng(),
			choices = this.choices,
			geolocated = this.geolocated(),
			state = this.address.state(),
			fetch = this.fetch

		if( geolocated && state && choices().length < 1 && fetch() && empty != lat+','+lng ) {
			fetch(false)
			this.getBallotChoices(lat,lng,choices,function() {   setTimeout( function() { fetch(true); $('.candidate.row:last .next').text('Next Measure').bind('click touchend',function() { $('.ballot-measures button.open:first').click() });  },100) })
		}
	}, this)


	this.getBallotChoices = function(lat,lng,array,callback) { // Useful function for 
		var state = yourLocation.address.state(), 
			address = state ? ['Prez',(state+yourLocation.address.city()), state, (state+yourLocation.address.county()) ] : []

		// Doing the openState call, will probably want to build this into something else
		$.getJSON(
			inits.root+'lookup',
			{
				l: yourLocation.lat()+','+yourLocation.lng(),
				address: address
			},
			function(data) { 
				if( data != null && data.constructor == Array ) {
					for( var i=0 ; i < data.length; i++) {
						array.push( Choice(data[i]) )
					}
				}
				empty = yourLocation.lat()+','+yourLocation.lng();
				callback()
			})
	}
	this.getGuides = function() { // Useful function for 
		var state = yourLocation.address.state(), 
			guides = yourLocation.guides

		$.getJSON(
			inits.root+'guides/'+state+'.json?limit=5',
			function(data) { 
				if( data != null && data.constructor == Array ) {
					guides(data)
				}
			})
	}


	
	
	// More menu shite
	this.menuItems = []

	if( this.state == 'front' ) {
		var ballotMeasures = Grouping(['Ballot_Statewide'],'Ballot Measures','measure',this,'Learn about initiatives, referenda, and other ballot measures appearing on your ballot, see what other people are saying about them, and share your own opinion.'),
			federalCandidates = Grouping(['Federal'],'Federal','candidate',this,'Take a peek at the candidates that you’ll have the chance to vote on. These candidates will represent you the Federal Government.'),
			stateCandidates = Grouping(['State'],'State','candidate',this,'These candidates will represent you in your State\'s government.'),
			countyCandidates = Grouping(['County'],'County','candidate',this,'These candidates will represent you in your county, municipal, or judicial government.')
			otherCandidates = Grouping(['Other'],'Other','candidate',this,'These candidates will represent you in your county, municipal, or judicial government.')
		
		this.sections.push( federalCandidates)
		this.sections.push( stateCandidates)
		this.sections.push( otherCandidates)
		this.sections.push( ballotMeasures)
		layout = '<ul><!-- ko foreach: yourLocation.sections --><li><a class="fix-link" data-bind="text: $data.title, attr: {href: \'#\'+$data.title }, visible: $data.contests().length > 0"></a></li><li ><ul style="display: none" data-bind="visible: $data.active, foreach: $data.contests"><li>'
		layout += '<a class="fixed-link" data-bind="css:{active: yourLocation.nearby() == $data, done: $data.you() != null },attr: { href: \'#!\'+$data.contest+\' \'+$data.geography},text: $data.contest"></a>'
		layout += '</li></ul></li><!-- /ko --></ul>'
		
		var url = current_user.id == 'unauthenticated' ? document.location.host : document.location.host+current_user.url,
			owner = current_user.id == 'unauthenticated' ? 'the' : 'Your',
			name = current_user.id == 'unauthenticated' ? undefined : current_user.guide_name || [current_user.first_name,current_user.last_name+'\'s','Voter Guide'].join(' '),
			msg = current_user.id == 'unauthenticated' ? undefined : 'Check out my voter guide on The Ballot',
			extra = current_user.id == 'unauthenticated' ? '' : '<a style="text-align: center" href="http://'+url+'" class="small">Your Voter Guide</a>'
			
		this.menuItems.push( 
			MenuItem('#find-ballot','Find Your Ballot','<p>Enter your voting address to look up what will appear on your on your ballot.</p>'),
			MenuItem('#read-ballot','Read Your Ballot',"<p>Get the lowdown on everything on your ballot for the November 6th Election.</p><p>Read what others have to say about the important races in your state and share your own views.</p>"+layout,null, this),
			MenuItem(null,'Share Your Guide',null,'<div class="container share-container">Share '+owner+' Ballot<br>'+makeShare(url,name)+extra)
		)
	}
	if( this.state == 'state' ) {
		var ballotMeasures = Grouping(['Ballot_Statewide'],'Ballot Measures','measure',this,'Learn about initiatives, referenda, and other ballot measures appearing on your ballot, see what other people are saying about them, and share your own opinion.'),
			federalCandidates = Grouping(['Federal'],'Federal','candidate',this,'Take a peek at the candidates that you’ll have the chance to vote on. These candidates will represent you the Federal Government.'),
			stateCandidates = Grouping(['State'],'State','candidate',this,'These candidates will represent you in your State\'s government.'),
			countyCandidates = Grouping(['County'],'County','candidate',this,'These candidates will represent you in your county, municipal, or judicial government.')
			otherCandidates = Grouping(['Other'],'Other','candidate',this,'These candidates will represent you in your county, municipal, or judicial government.')
			userCandidate = Grouping(['User_Candidate'],'User Created Candidates','candidate',this,'These are candidates that were created by another user on The Ballot. We cannot verify their accuracy.')
			userBallotMeasures = Grouping(['User_Measure'],'User Created Measures','candidate',this,'These are ballot measures that were created by another user on The Ballot. We cannot verify their accuracy.')
		
		this.sections.push( federalCandidates)
		this.sections.push( stateCandidates)
		this.sections.push( countyCandidates )
		this.sections.push( otherCandidates)
		this.sections.push( ballotMeasures)
		this.sections.push( userCandidate )
		this.sections.push( userBallotMeasures )
		layout = '<ul><!-- ko foreach: yourLocation.sections --><li><a class="fix-link" data-bind="text: $data.title, attr: {href: \'#\'+$data.title }, visible: $data.contests().length > 0"></a></li><li ><ul style="display: none" data-bind="visible: $data.active, foreach: $data.contests"><li>'
		layout += '<a class="fixed-link" data-bind="css:{active: yourLocation.nearby() == $data, done: $data.you() != null },attr: { href: \'#!\'+$data.contest+\' \'+$data.geography},text: $data.contest"></a>'
		layout += '</li></ul></li><!-- /ko --><li style="font-weight: normal; margin: 10px; font-size: 10px;" data-bind="visible: !yourLocation.fetch() "><em>Still loading...</em></li></ul>'
		
		var url = document.location.toString(), name = inits.title
		this.menuItems.push( 
			MenuItem(inits.root,'Find Your Ballot',null),
			MenuItem('#read-ballot','Read Your Ballot', layout ,null, this),
			MenuItem(null,'Share Your Guide',null,'<div class="container share-container">Share '+inits.title+'<br>'+makeShare(url,name, inits.message )+extra)
		)
	}
	if( this.state == 'single' ) {
		var url = document.location.toString()
		this.menuItems.push( 
			MenuItem(inits.root,'Find Your Ballot'),
			MenuItem(current_user.url,'Your Voter Guide'),
			MenuItem(null,'Share This Ballot',null,'<div class="container share-container">Share this Page<br>'+makeShare(url)+'</div>')
		)
	}
	if( this.state == 'guides' ) {
		var url = document.location.toString()
		
		
		this.menuItems.push( 
			MenuItem(inits.root,'Find Your Ballot'),
			MenuItem('#read-ballot','Guides By States','<ul style="margin: 20px 0; max-height: 300px; overflow-y: scroll;">'+inits.states.map( function(el) { return '<li><a href="#'+el.replace(/ /g,'_')+'">'+el+'</a></li>' }).join("\n")+'</ul>',null),
			MenuItem(null,'Share This Ballot',null,'<div class="container share-container">Share this Page<br>'+makeShare(url)+'</div>')
		)
	}
	if( this.state == 'profile' ) {
		var ballotMeasures = Grouping(['Ballot_Statewide'],'Ballot Measures','measure',this,'Learn about initiatives, referenda, and other ballot measures appearing on your ballot, see what other people are saying about them, and share your own opinion.'),
			federalCandidates = Grouping(['Federal'],'Federal','candidate',this,'Take a peek at the candidates that you’ll have the chance to vote on. These candidates will represent you the Federal Government.'),
			stateCandidates = Grouping(['State'],'State','candidate',this,'These candidates will represent you in your State\'s government.'),
			countyCandidates = Grouping(['County'],'County','candidate',this,'These candidates will represent you in your State\'s government.'),
			otherCandidates = Grouping(['Other'],'Other','candidate',this,'These candidates will represent you in your county, municipal, or judicial government.')
			userCandidate = Grouping(['User_Candidate'],'User Created Candidates','candidate',this,'These are candidates that were created by another user on The Ballot. We cannot verify their accuracy.')
			userBallotMeasures = Grouping(['User_Measure'],'User Created Measures','candidate',this,'These are ballot measures that were created by another user on The Ballot. We cannot verify their accuracy.')
		
		this.sections.push( federalCandidates)
		this.sections.push( stateCandidates)
		this.sections.push( countyCandidates)
		this.sections.push( otherCandidates)
		this.sections.push( ballotMeasures)
		this.sections.push( userCandidate )
		this.sections.push( userBallotMeasures )

		layout = '<ul><!-- ko foreach: yourLocation.sections --><li><a class="fix-link" data-bind="text: $data.title, attr: {href: \'#\'+$data.title }, visible: $data.contests().length > 0"></a></li><li ><ul style="display: none" data-bind="visible: $data.active, foreach: $data.contests"><li>'
		layout += '<a class="fixed-link" data-bind="css:{active: yourLocation.nearby() == $data, done: $data.you() != null },attr: { href: \'#!\'+$data.contest+\' \'+$data.geography},text: $data.contest"></a>'
		layout += '</li></ul></li><!-- /ko --></ul>'
		
		var url = current_user.id == 'unauthenticated' ? document.location.host : document.location.host+current_user.url,
			owner = current_user.id == 'unauthenticated' ? 'the' : 'Your',
			name = current_user.id == 'unauthenticated' ? undefined : current_user.guide_name || [current_user.first_name,current_user.last_name+'\'s','Voter Guide'].join(' '),
			msg = current_user.id == 'unauthenticated' ? undefined : 'Check out my voter guide on The Ballot',
			extra = current_user.id == 'unauthenticated' ? '' : '<a style="text-align: center" href="http://'+url+'" class="small">Your Voter Guide</a>'
			
		
		
		var url = document.location.host+inits.user.profile, 
			name = inits.user.guide_name || [inits.user.first_name,inits.user.last_name+'\'s','Voter Guide'].join(' '),
			pronoun = inits.user.id == current_user.id ? 'Your' : inits.user.first_name != '' ? inits.user.first_name+'\'s' : inits.user.last_name+'\'s'

		this.menuItems.push( 
			MenuItem(inits.root,'Find Your Ballot'),
			MenuItem('#',pronoun+' Voter Guide',layout),
			MenuItem(null,'Share This Ballot',null,'<div class="container share-container">Share this Guide<br>'+makeShare(url,name)+'</div>')
		)
	}

	this.active = ko.computed(function() {
		var top = this.top()-$(window).innerHeight() /6, items = this.menuItems.filter(function(el) { return el.id != null && el.id[0] == '#' })
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
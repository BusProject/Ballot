function locationModel(data) {
	this.state = data.state || 'front'

	// Map Objects
	this.latlng = ko.observable( data.latlng == null ? '38.7, -95.7' : { boom: parseFloat(data.latlng.split(',')[0]), bewm: parseFloat(data.latlng.split(',')[1]) } )
	this.googleLocation = ko.observable( data.google || {} )
	this.address = ko.observable('')
	this.geocoder = ko.observable('')
	this.geocoded = ko.observable( data.latlng != null )
	this.geocoded.address = ko.observable('')
	this.fetch = ko.observable(true)
	this.remember = ko.observable( inits.remember )
	this.pollingLocation = ko.observable('')


	// Style elements
	this.top = ko.observable(0)
	this.top.better = ko.computed( function() {
		return this.top()-window.innerHeight
	},this)
	

	var empty = '', __state = ''

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
					//choices([])
				}
			});
		}
	}, this).extend({ throttle: 250 })

	this.map = ko.computed( function() { // Used for confirming map location
		var latlng = [this.lat(),this.lng()].join(','),
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

	function pollingPlace(address, callback) {
		var key = 'AIzaSyAnFJvCCJnJtv86xVD-NXoneJ5OhYWGAjQ'
		$.ajax({ 
			url: 'https://www.googleapis.com/civicinfo/us_v1/voterinfo/4000/lookup?key='+key+'&officialOnly=false',
			type: 'POST',
			contentType: 'application/json',
			data: '{ "address": "'+address+'" }',
			success: function(response) { callback(response) }
		})
	}

	function processLocations(locations ) {
		// This processes election locations into something more manageable
		var locales = []
		if( typeof locations == 'undefined' ) return locales;
		for( var i = 0; i < locations.length; i++ ) {
			var locale = locations[i],
				address = [
					locale.address.line1,
					locale.address.line2,
					locale.address.line3,
					locale.address.city,
					locale.address.state,
					locale.address.zip
				].join(' '),
				directions = 'https://maps.google.com/maps?q=from:'+yourLocation.address()+' to:'+address,
				hours = [
					locale.pollingHours ? 'From: '+locale.pollingHours : '',
					locale.startDate ? 'on '+locale.startDate : '' ,
					locale.endDate ? 'till '+locale.endDate : ''
					].join(' ').trim()
			locales.push( { 
				name: locale.address.locationName, 
				address: address,
				hours: hours, 
				directions: directions });
			}
	    return locales;
	}

	this.grabChoices = ko.computed( function() { // Retrieve choices
		var lat = this.lat(),
			lng = this.lng(),
			choices = this.choices,
			geolocated = this.geolocated(),
			state = this.address.state(),
			fetch = this.fetch,
			pollingLocation = this.pollingLocation,
			noGoogle = { 
				OR:  'Oregon votes by mail - <a href="http://ballotdrop.org/#'+this.address()+'" target="_blank">find Ballot Drop sites here</a>.<br /><br />If you haven\'t received your ballot yet - and are registered - <a href="http://oregonvotes.org/" target="_blank">contact the Secretary of State for a new ballot<a/>.'
				}

		if( geolocated && state && fetch() && empty != lat+','+lng && this.address() != '' ) {
			fetch(false)

			if( choices().length < 1 ) this.getBallotChoices(lat,lng,choices,function() {   setTimeout( function() { fetch(true); $('.candidate.row:last .next').text( I18n.t('measures.next') ).bind('click touchend',function() { $('.ballot-measures button.open:first').click() });  },100) })
			else fetch(true) // Not needed - used with the Lookup callback

			if( typeof noGoogle[ state ] == 'undefined' ) pollingPlace(
				this.address(),
				function(response) {
					var early = processLocations( response.earlyVoteSites ), earlyHTML = ''
					if( early.length > 0 ) {
						earlyHTML = '<a onclick="$(this).hide().next(\'ul\').show().nextAll(\'a.link:first\').show(); return false" href="#" class="link">Click to see Early Vote Locations</a><ul style="display:none;">'
						earlyHTML += early.map( function(location) { 
							return [ '<li><strong>'+location.name,
								'</strong> at <a href="',
								location.directions,'" target="_blank">',
								location.address,
								'</a>',
								location.hours,
								'</li>'
								].join(' ')
							}).join('')
						earlyHTML += '</ul>'
					}
					pollingLocation( 
						processLocations( response.pollingLocations ).map( function(location) { 
							return [ '<strong>Your Polling Place:</strong>',
								location.name,
								'at <a href="',
								location.directions,'" target="_blank">',
								location.address,
								'</a> ',
								location.hours,
								'<br /><br />'
								].join(' ')
						}).join(' ') + earlyHTML+'<a style="display:none;" class="link" onclick="$(this).hide().prev(\'ul\').hide().prevAll(\'a.link:first\').show(); return false" href="#" class="click">Hide All</a>'
					)
				}
			);
			else {
				pollingLocation( '<strong>How To Vote:</strong> '+noGoogle[ state ] )
			}
		}
	}, this)


	this.getBallotChoices = function(lat,lng,array,callback) { // Useful function for 
		var state = yourLocation.address.state(), 
			address = state ? ['Prez',(state+yourLocation.address.city()), state, (state+yourLocation.address.county()+' County') ] : []

		// Doing the openState call, will probably want to build this into something else
		$.getJSON(
			inits.root+'lookup',
			{
				l: yourLocation.lat()+','+yourLocation.lng(),
				address: address,
				address_text: yourLocation.remember() ? yourLocation.address() : ''
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
	this.getGuides = function(state,guides ) { // Useful function for 
		$.getJSON(
			inits.root+'guides/'+state+'.json?limit=5',
			function(data) { 
				if( data != null && data.constructor == Array ) {
					if( data.length > 0 ) guides(data) 
				} 
			})
	}


	this.grabChoices = ko.computed( function() { // Retrieve guides
		var geolocated = this.geolocated(),
			state = this.address.state(),
			guides = this.guides
			
		if( geolocated && state != __state ) {
			this.getGuides(state,guides,__state);
			__state = state
		} 
	},this)
	
	
	// More menu shite
	this.menuItems = []
	
	var ballotMeasures = Grouping(['Ballot_Statewide'],I18n.t('types.ballot_measures.title'),'Ballot Measures','measure',this, I18n.t('types.ballot_measures.text')  ),
		federalCandidates = Grouping(['Federal'],I18n.t('types.federal.title'),'Federal','candidate',this, I18n.t('types.federal.text') ),
		stateCandidates = Grouping(['State'],I18n.t('types.state.title'),'State','candidate',this,I18n.t('types.state.text')),
		countyCandidates = Grouping(['County'],I18n.t('types.county.title'),'County','candidate',this,I18n.t('types.county.text') ),
		otherCandidates = Grouping(['Other'],I18n.t('types.other.title'),'Other','candidate',this,I18n.t('types.other.text') )
		userCandidate = Grouping(['User_Candidate'],I18n.t('types.user_candidates.title'),'User Created Candidates','candidate',this,I18n.t('types.user_candidates.text'))
		userBallotMeasures = Grouping(['User_Ballot'],I18n.t('types.user_measures.title'),'User Created Ballots','measure',this,I18n.t('types.user_measures.text'))
	

	if( this.state == 'front' ) {

		this.sections.push( federalCandidates)
		this.sections.push( stateCandidates)
		this.sections.push( countyCandidates)
		this.sections.push( otherCandidates)
		this.sections.push( ballotMeasures)
		layout = '<ul><!-- ko foreach: yourLocation.sections --><li><a class="fix-link" data-bind="text: $data.title, attr: {href: \'#\'+$data.url }, visible: $data.contests().length > 0"></a></li><li ><ul style="display: none" data-bind="visible: $data.active, foreach: $data.contests"><li>'
		layout += '<a class="fixed-link" data-bind="css:{active: yourLocation.nearby() == $data, done: $data.you().length > 0 },attr: { href: \'#!\'+$data.contest+\' \'+$data.geography},text: $data.contest"></a>'
		layout += '</li></ul></li><!-- /ko --></ul>'
		
		var url = current_user.id == 'unauthenticated' ? document.location.host : document.location.host+current_user.url,
			owner = current_user.id == 'unauthenticated' ? I18n.t('menu.share') : I18n.t('menu.the_ballot'),
			name = current_user.id == 'unauthenticated' ? undefined : current_user.guide_name || I18n.t('i18n_toolbox.possessive',{owner: current_user.name, thing: I18n.t("site.voter_guide") } ),
			msg = current_user.id == 'unauthenticated' ? undefined : I18n.t('menu.share_message'),
			extra = current_user.id == 'unauthenticated' ? '' : '<a style="text-align: center" href="http://'+url+'" class="small">'+I18n.t('i18n_toolbox.possessive_you',{thing: 'Voter Guide'})+'</a>'
			
		this.menuItems.push( 
			MenuItem('#find-ballot',I18n.t('menu.find'),'<p>'+I18n.t('menu.find_text')+'</p>'),
			MenuItem('#read-ballot',I18n.t('menu.read'),"<p>"+I18n.t('menu.read_text')+'</p><p>'+I18n.t('menu.read_text_2')+"</p>"+layout,null, this),
			MenuItem(null,'Share Your Guide',null,'<div class="container share-container">'+owner+'<br>'+makeShare(url,name)+extra)
		)
	}
	if( this.state == 'state' ) {

		this.sections.push( federalCandidates)
		this.sections.push( stateCandidates)
		this.sections.push( countyCandidates )
		this.sections.push( otherCandidates)
		this.sections.push( ballotMeasures)
		this.sections.push( userCandidate )
		this.sections.push( userBallotMeasures )


		layout = '<ul><!-- ko foreach: yourLocation.sections --><li><a class="fix-link" data-bind="text: $data.title, attr: {href: \'#\'+$data.title }, visible: $data.contests().length > 0"></a></li><li ><ul style="display: none" data-bind="visible: $data.active, foreach: $data.contests"><li>'
		layout += '<a class="fixed-link" data-bind="css:{active: yourLocation.nearby() == $data, done: $data.you().length > 0 },attr: { href: \'#!\'+$data.contest+\' \'+$data.geography},text: $data.contest"></a>'
		layout += '</li></ul></li><!-- /ko --><li style="font-weight: normal; margin: 10px; font-size: 10px;" data-bind="visible: !yourLocation.fetch() "><em>'+I18n.t('site.loading')+'</em></li></ul>'
		
		var url = document.location.toString().split('?')[0], name = inits.title
		this.menuItems.push( 
			MenuItem(inits.root,I18n.t('menu.find'),null),
			MenuItem('#read-ballot',I18n.t('menu.read'), layout ,null, this),
			MenuItem(null,I18n.t('menu.this_page'),null,'<div class="container share-container">'+I18n.t('menu.this_page')+'<br>'+makeShare(url,name)+'</div>')
		)
	}
	if( this.state == 'single' ) {
		var url = document.location.toString().split('?')[0]
		this.selected( this.choices()[0] )
		this.menuItems.push( 
			MenuItem(inits.root,I18n.t('menu.find')),
			MenuItem(current_user.url, I18n.t('i18n_toolbox.possessive_you',{thing: 'Voter Guide'})),
			MenuItem(null,I18n.t('menu.this_page'),null,'<div class="container share-container">'+I18n.t('menu.this_page')+'<br>'+makeShare(url,name)+'</div>')
		)
	}
	if( this.state == 'guides' ) {
		var url = document.location.toString().split('?')[0]
		
		this.menuItems.push( 
			MenuItem(inits.root, I18n.t('menu.find')),
			MenuItem('#read-ballot', inits.stateName ?  I18n.t('menu.guides_in', {state: inits.stateName}) : I18n.t('menu.state_guides') ,'<ul style="margin: 20px 0; max-height: 300px; overflow-y: scroll;">'+inits.states.map( function(el) { return '<li><a href="#'+el.replace(/ /g,'_')+'">'+el+'</a></li>' }).join("\n")+'</ul>',null),
			MenuItem(null,I18n.t('menu.this_page'),null,'<div class="container share-container">'+I18n.t('menu.this_page')+'<br>'+makeShare(url,name)+'</div>')
		)
	}
	if( this.state == 'profile' ) {

		this.sections.push( federalCandidates)
		this.sections.push( stateCandidates)
		this.sections.push( countyCandidates )
		this.sections.push( otherCandidates)
		this.sections.push( ballotMeasures)
		this.sections.push( userCandidate )
		this.sections.push( userBallotMeasures )

		layout = '<ul><!-- ko foreach: yourLocation.sections --><li><a class="fix-link" data-bind="text: $data.title, attr: {href: \'#\'+$data.url }, visible: $data.contests().length > 0"></a></li><li ><ul style="display: none" data-bind="visible: $data.active, foreach: $data.contests"><li>'
		layout += '<a class="fixed-link" data-bind="css:{active: yourLocation.nearby() == $data, done: $data.you().length > 0 },attr: { href: \'#!\'+$data.contest+\' \'+$data.geography},text: $data.contest"></a>'
		layout += '</li></ul></li><!-- /ko --></ul>'

		
		var url = document.location.host+inits.user.profile, 
			name = inits.user.guide_name || I18n.t('i18n_toolbox.possessive',{owner: inits.user.name, thing: I18n.t("site.voter_guide") } ), 
			pronoun = inits.user.id == current_user.id ? I18n.t('i18n_toolbox.possessive_you',{thing: 'Voter Guide'}) : inits.user.first_name != '' ? I18n.t('i18n_toolbox.possessive',{owner: inits.user.first_name,thing: 'Voter Guide' } ) : I18n.t('i18n_toolbox.possessive',{owner: inits.user.last_name,thing: 'Voter Guide' } )

		this.menuItems.push( 
			MenuItem(inits.root, I18n.t('menu.find')),
			MenuItem('#',pronoun,layout),
			MenuItem(null,I18n.t('menu.this_guide'),null,'<div class="container share-container">'+I18n.t('menu.this_guide')+'<br>'+makeShare(url,name)+'</div>')
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
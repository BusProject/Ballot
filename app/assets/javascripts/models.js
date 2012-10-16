function Choice(data,args) {
	var args = data || {}
	if( typeof data == 'undefined' ) throw "No Data for the Choice - can't do it"

	switch(args.type) {
		default:
			return new ballotChoice(data)
			break;
	}
	
	function ballotChoice(data) {
		this.options = ko.observableArray([])
		this.id = data.id
		this.contest = data.contest,
		this.type = data.contest_type
		this.description = data.description
		this.geography = data.geography
		this.nice_geography = data.nice_geography
		this.commentable = true
		this.comments = 0;
		this.commentsPure = ko.observable(0);
		this.sortOptions = [
			{value: 'normal', label: 'Sort by...' },
			{value: 'best', label: 'Most Helpful' },
			{value: 'friends', label: 'Your Friends' }
		]
		this.mode = ko.observable('normal')
		this.all = ko.observable( inits.state == 'single' )


		if( typeof data.options != 'undefined' ) {
			var tmp = []
			for (var i=0; i < data.options.length; i++) {
				tmp.push( Option(data.options[i],this) )
				this.comments += data.options[i].comments
				this.commentsPure( this.commentsPure() + data.options[i].comments )
				this.sortOptions.push( {value: data.options[i].name, label: 'Supporting '+data.options[i].name } )
			};
			this.options(tmp)
		}


		this.yes = ko.computed( function() { 
			return this.options().filter( function(el) { return el.type == 'yes' })[0] || null  
		},this)
		this.no = ko.computed( function() { 
			return this.options().filter( function(el) { return el.type == 'no' })[0] || null  
		},this)


		this.feedback = ko.computed( function() { 
			var feedback = [], mode = this.mode(), options = this.options()

			for (var i=0; i < options.length; i++) {
				feedback = feedback.concat( options[i].feedback() )
			};

			feedback.sort( function(a,b) {
				if( mode != 'best' ) {
					var af = a.friend(), 
						bf = b.friend()
					if( af && !bf ) return -1; 
					if ( !bf && af ) return 1;
				}
				return a.usefulness() > b.usefulness() ? -1 : 1 
			})
			return feedback
		},this)

		this.votes = 1;
		this.chosen = ko.observable()
		this.you = ko.computed(function() { 
			var ft = null
			ft = this.feedback().filter( function(el) { return  el.ftFeedback })
			var ids = ft.map( function(el) { return el.option_id })
			if( ft != null && this.type == 'Ballot_Statewide' ) {
				ft.sort( function(a,b) { return a.id > b.id ?  1 : -1  } )
				this.options( this.options().sort(function(a,b) {  return ids.indexOf(a.id) !== -1 ? -1 : 1 }) )
			}
			return ft
		},this)
		this.featured = this.you
		this.available = ko.computed( function() {
			var featured = this.featured()
			return this.options().filter( function(option) { return ! featured.filter( function(featured) { return featured.option_id == option.id } ).length > 0 })
		},this)
		this.selected = ko.computed( function() {
			var featured = this.featured()
			return this.options().filter( function(option) { return featured.filter( function(featured) { return featured.option_id == option.id } ).length  > 0 })
		},this)

		this.feedback.realLength = ko.computed(function() {
			return this.feedback().length - ( this.you() == null ? 0 : 1) - ( this.featured() == null || this.featured() ==  this.you() ? 0 : 1)
		},this)
		this.feedback.everyone = ko.computed(function() {
			var mode = this.mode()
			var feedback = this.feedback().filter( function(el) { 
				var condition = !el.ftFeedback && !el.yourFeedback && el.comment != null && el.comment.length > 0
				if( mode == 'yes' || mode == 'no' ) condition = condition && el.type == mode
				else if( mode == 'friends' ) condition = condition && el.friend()
				else if( mode != '' && mode != 'best' && mode != 'normal' ) condition = el.option_name == mode && condition
				
				return condition
			}) || [] 
			return this.all() ? feedback : feedback.slice(0,3)
		},this)

		this.feedback.page= ko.observable( 0);
		this.feedback.more = ko.computed( function() {
			var comments = this.comments - this.feedback().length
			return comments > 0 ? 3+this.feedback.page()*10 : false
		},this)

		this.__voted = data.voted
		this.voted = ko.computed(function() {
			return this.__voted + this.you().length > 0 ? 1 : 0
		},this)

		this.__commented = data.commented
		this.commented = ko.computed(function() {
			return this.__commented + this.you().length > 0 ? 1 : 0
		},this)
		

		return this;
	}
}

function Option(data,choice) {
	var args = data || {}
	if( typeof data == 'undefined' ) throw "No Data for the Option - can't do it"

	return new ballotOption(data,choice)

	function ballotOption(data,choice) {
		this.name = data.name
		this.blurb = data.blurb
		this.blurb
		this.id = data.id
		this.support = ko.observable(data.support)
		this.comments = data.comments
		this.choice_id = data.choice_id
		this.photo = data.photo
		this.party = data.party
		var party = this.party
		this.partySmall = function() {
			if( party == null ) return '';
			if( party.search('Democrat') !== -1 ) return '(D)';
			if( party.search('Republican') !== -1 ) return '(R)';
			if( party.search('Green') !== -1 ) return '(G)';
			if( party.search('Libertarian') !== -1 ) return '(L)';
			if( party.search('Constitution') !== -1 ) return '(C)';
			if( party.search('Independent') !== -1 ) return '(I)';
			return ''
		}
		
		
		this.incumbant = data.incumbant
		this.twitter = data.twitter
		this.facebook = data.facebook
		this.website = data.website
		this.blurb_source = data.blurb_source
		
		this.feedback = ko.observableArray([])
		
		this.type = data.option_type
		data.feedback = data.feedbacks
		if( typeof data.feedback != 'undefined' ) {
			for (var i=0; i < data.feedback.length; i++) {
				data.feedback[i].option_name = this.name
				data.feedback[i].type = this.type
				this.feedback.push( Feedback( data.feedback[i] ) )
			};
		}

		this.faces = data.faces
		this.faces.show = ko.computed( function() { 
			var you = this.feedback().filter( function(el) { return el.yourFeedback })[0]
			if( typeof you == 'undefined' ) return this.faces
			else {
				var faces = this.faces.slice(0,3)
				faces.unshift( { image: current_user.image, url: current_user.profile, name: 'You' })
				return faces
			}
		},this) 

		return this;
	}
}

function Feedback(data) {
	if( typeof data == 'undefined' ) throw "No Data for the Option - can't do it"

	return new ballotFeedback(data) 
	function ballotFeedback(data) {
		this.option_id = data.option_id
		this.option_name = data.option_name
		this.user_id = data.user_id
		this.id = data.id
		this.support = data.support
		this.comment = data.comment
		var user = typeof inits.user != 'undefined' ? inits.user.id : current_user.id
		this.yourFeedback = data.user_id == current_user.id
		this.ftFeedback = data.user_id == user
		if( typeof data.user == 'undefined' ) {
			this.image = data.user_image || 'http://localhost:3000/assets/alincoln.gif'
			this.url = data.user_profile || ''
			this.fb = data.user_fb || ''
			this.name =  data.user_name || '[deleted]'
		} else {
			this.image = data.user.image || 'http://localhost:3000/assets/alincoln.gif'
			this.url = data.user.profile || ''
			this.fb = data.user.fb || ''
			this.name =  data.user.name || '[deleted]'
			
		}

		this.type = data.type
		this.updated = data.updated_at != data.created_at
		var useless = data.cached_votes_down || 0, useful = data.cached_votes_up || 0,
			wilson = useless + useful == 0 ? 0 : ((useful + 1.9208) / (useful + useless) - 1.96 * Math.sqrt((useful * useless) / (useful + useless) + 0.9604) / (useful + useless)) / (1 + 3.8416 / (useful + useless))
			// Adopted from http://evanmiller.org/how-not-to-sort-by-average-rating.html
		this.usefulness = ko.observable( wilson )
		this.useless = useless
		this.useful = useful

		var date = new Date(data.updated_at),
			time = date.toLocaleTimeString().slice(0,5)+'am',
			day = date.toLocaleDateString().split(', ')
			day.shift()
			day = day.join(', ')

		if( date.getHours() > 12 ) {
			time = (date.getHours()-12) +time.slice(2,5)+'pm'
		} else if ( date.getHours() == 12 ) time = time.slice(0,5)+'pm'

		this.time =  day+' '+time

		this.friend = ko.computed( function() { 
			var friends = typeof current_user != 'undefined' && current_user.fb_friends != null ?  current_user.fb_friends.split(',') : []
			return friends.indexOf( this.fb ) !== -1
		},this)
		return this
	}
}

function Grouping(keys,title,url,template,locationModel,description) {
	var grouping = {}

	grouping.contests = ko.computed( function() {
		return ko.utils.arrayFilter(this.choices(), function(choice){
			return keys.indexOf(choice.type) !== -1
		})
	}, locationModel)

	grouping.contests.cutoff = ko.utils.arrayFilter(locationModel.choices(), function(choice){ return keys.indexOf(choice.type) !== -1}).length

	grouping.contests.fresh = ko.computed( function() {
		var contests = this.contests()
		return contests.slice( this.contests.cutoff, contests.length )
	}, grouping)

	grouping.visible = ko.computed( function() {
		return this.contests().length > 0
	},grouping)


	grouping.title = title
	grouping.url = url
	grouping.template = template
	grouping.description = description
	grouping.className = title != 'Ballot Measures' ? 'candidates' : 'ballot-measures'
	grouping.className += ' ballot-category clearfix'
	grouping.active = ko.computed(function() {
		return this.contests().indexOf( locationModel.nearby() ) !== -1
	},grouping)

	return grouping
}

function MenuItem(id,name,description,html,model) {
	var menuItem = { id: id, name: name, html: html, description: description, model: model }

	return menuItem
}
function Choice(data,args) {
	var args = data || {}
	if( typeof data == 'undefined' ) throw "No Data for the Choice - can't do it"

	switch(args.type) {
		default:
			return new ballotChoice(data)
			break;
	}
	
	function ballotChoice(data) {
		this.options = []
		this.contest = data.contest,
		this.type = data.contest_type
		this.description = data.description
		this.geography = data.geography
		this.commentable = data.commentable
		this.mode = ko.observable('normal')
		this.all = ko.observable( inits.state == 'single' )

		if( typeof data.options != 'undefined' ) {
			for (var i=0; i < data.options.length; i++) {
				this.options.push( Option(data.options[i]) )
			};
		}

		this.yes = ko.computed( function() { 
			return this.options.filter( function(el) { return el.type == 'yes' })[0] || null  
		},this)
		this.no = ko.computed( function() { 
			return this.options.filter( function(el) { return el.type == 'no' })[0] || null  
		},this)


		this.feedback = ko.computed( function() { 
			var feedback = [], mode = this.mode(), options = this.options

			for (var i=0; i < options.length; i++) {
				feedback = feedback.concat( this.options[i].feedback() )
			};

			feedback.sort( function(a,b) {
				if( mode != 'best' ) {
					var af = a.friend(), 
						bf = b.friend()
					if( af && !bf ) return 1; 
					if ( !bf && af ) return -1;
				}
				return a.usefulness() > b.usefulness() ? -1 : 1 
			})

			return feedback
		},this)

		this.you = ko.computed(function() { return this.feedback().filter( function(el) { return el.yourFeedback })[0] || null  },this)

		this.feedback.realLength = ko.computed(function() {
			return this.feedback().length - ( this.you() == null ? 0 : 1)
		},this)
		this.feedback.everyone = ko.computed(function() {
			var mode = this.mode()
			var feedback = this.feedback().filter( function(el) { 
				var condition = !el.yourFeedback && el.comment.length > 0
				if( mode == 'yes' || mode == 'no' ) condition = condition && el.type == mode
				if( mode == 'friends' ) condition = condition && el.friend()

				return condition
			}) || [] 
			return this.all() ? feedback : feedback.slice(0,5)
		},this)

		return this;
	}
}

function Option(data,args) {
	var args = data || {}
	if( typeof data == 'undefined' ) throw "No Data for the Option - can't do it"

	return new ballotOption(data)

	function ballotOption(data) {
		this.name = data.name
		this.blurb = data.blurb
		this.blurb
		this.id = data.id
		this.choice_id = data.choice_id
		this.photo = data.photo
		this.feedback = ko.observableArray([])
		var type = ''

		if( ['support','yes','for'].indexOf(this.name.toLowerCase()) !== -1 )  type = 'yes'
		if( ['oppose','no','against'].indexOf(this.name.toLowerCase()) !== -1 ) type = 'no'
		this.type = type

		if( typeof data.feedback != 'undefined' ) {
			for (var i=0; i < data.feedback.length; i++) {
				data.feedback[i].type = type
				this.feedback.push( Feedback( data.feedback[i] ) )
			};
		}

		this.feedback.five = ko.computed(function() {
			var feedback = this.feedback(),
				friends = typeof yourLocation != 'undefined' ? yourLocation.friends() : [],
				find_friends = feedback.filter( function(el) { return friends.indexOf(el.fb) !== -1; } )

				if( find_friends.length < 5 ) find_friends = find_friends.concat( feedback.filter( function(el) { return friends.indexOf(el.fb) === -1; } ).sort(function() {return 0.5 - Math.random()}).slice(0, 5 - find_friends.length  ) )

				return find_friends
			
		},this)

		return this;
	}
}

function Feedback(data) {
	if( typeof data == 'undefined' ) throw "No Data for the Option - can't do it"

	return new ballotFeedback(data) 
	function ballotFeedback(data) {
		this.option_id = data.option_id
		this.user_id = data.user_id
		this.id = data.id
		this.support = data.support
		this.comment = data.comment
		var user = typeof inits.user != 'undefined' ? inits.user.id : current_user.id
		this.yourFeedback = data.user_id == user
		this.image = data.user.image
		this.url = data.user.profile
		this.fb = data.user.fb
		this.name =  data.user.first_name+' '+data.user.last_name
		this.type = data.type
		this.updated = data.updated_at != data.created_at
		var useless = data.useless || '', useful = data.useful || ''
		useless = useless.split(',').length + ( useless.length > 0 ? 1 : 0 )
		useful = useful.split(',').length +  ( useful.length > 0 ? 1 : 0 )
		this.usefulness = ko.observable( useful - useless )

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
			var friends = typeof yourLocation != 'undefined' ? yourLocation.friends() : []
			return friends.indexOf( this.user.fb ) !== -1
		},data)
		return this
	}
}

function Grouping(keys,title,locationModel) {
	var grouping = {}

	grouping.contests = ko.computed( function() {
		return ko.utils.arrayFilter(this.choices(), function(choice){
			return keys.indexOf(choice.type) !== -1
		})
	}, locationModel)
	grouping.visible = ko.computed( function() {
		return this.contests().length > 0
	},grouping)


	grouping.title = title
	grouping.class = title != 'Ballot Measures' ? 'candidates' : 'ballot-measures'
	grouping.class += ' ballot-category clearfix'

	return grouping
}

function MenuItem(id,name,html) {
	var menuItem = { id: id, name: name, html: html }

	return menuItem
}
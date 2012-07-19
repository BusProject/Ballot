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
		this.commentable = data.commentable
		this.mode = ko.observable('normal')
		this.all = ko.observable(false)

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
		this.yourFeedback = data.user_id == current_user.id
		this.image = data.user.image
		this.url = data.user.url
		this.name = this.yourFeedback ? 'You' : data.user.first_name

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

	grouping.current = ko.observable(null)
	grouping.selected = ko.computed( function() {
		if( this.current() != null ) return this.current()
		else return this.contests()[0]
	},grouping)

	grouping.title = title
	grouping.class = title != 'Ballot Measures' ? 'candidates' : 'ballot-measures'
	grouping.class += ' ballot-category clearfix'

	return grouping
}

function MenuItem(id,name,disabled,locationModel) {
	var menuItem = { id: id, name: name }

	return menuItem
}
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

		if( typeof data.options != 'undefined' ) {
			for (var i=0; i < data.options.length; i++) {
				this.options.push( Option(data.options[i]) )
			};
		}
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
		this.readmore = ko.observable(true)
		this.id = data.id
		this.photo = data.photo
		this.feedback = ko.observableArray([])

		if( typeof data.feedback != 'undefined' ) {
			for (var i=0; i < data.feedback.length; i++) {
				this.feedback.push( Feedback(data.feedback[i]) )
			};
		}

		this.yourComment = ko.computed( function() {
			var yourFeedback = this.feedback().filter( function(feedback) { 
				return feedback.yourFeedback
			})
			if( yourFeedback.length == 0 ) {
				this.feedback.push( Feedback({option_id: this.id, user_id: current_user.id }) )
			}
			yourFeedback = this.feedback().filter( function(feedback) { 
				return feedback.yourFeedback
			})
			return yourFeedback[0] 
		}, this)

		return this;
	}
}

function Feedback(data) {
	if( typeof data == 'undefined' ) throw "No Data for the Option - can't do it"

	return new ballotFeedback(data) 
	function ballotFeedback(data) {
		this.option_id = data.option_id
		this.user_id = data.user_id
		this.support = ko.observable(data.support)
		this.actionButton = 'Share'
		this.comment = ko.observable(data.comment)
		this.yourFeedback = data.user_id == current_user.id
		

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
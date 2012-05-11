function repModel(args) {
	if( typeof args == 'undefined' ) return false;

	this.firstName = args.firstName
	this.lastName = args.lastName
	this.fullName = args.fullName || this.firstName+' '+this.lastName
	this.photo = args.photo
	this.website = args.website
	this.office = args.office
	this.title = args.title
	this.rank = locationModel.prototype.order.indexOf(this.title) === -1 ? 999 : locationModel.prototype.order.indexOf(this.title)
	this.choice_key = [this.fullName,this.office].join(' ')
	this.district = args.district

	return this
}


function openStateRep(args) {
	if( typeof args == 'undefined' ) return false;
	var newRep = {}

	newRep.firstName = args.first_name
	newRep.lastName = args.last_name
	newRep.fullName = args.full_name
	newRep.photo = args.photo_url
	newRep.website = args.website

	var level = args.roles[0].level.capitalize(),
		title = args.roles[0].chamber == 'lower' ? 'Representative' : 'Senator'
		dist = args.roles[0].chamber == 'lower' ? 'HD' : 'SD'

	newRep.title = 'State '+title
	newRep.office = [level,title,'for',args.state.toUpperCase(),dist,args.roles[0].district].join(' ')
	newRep.district = args.state.toUpperCase()+dist+args.roles[0].district

	
	return new repModel(newRep)
}

function congressRep(args) {
	if( typeof args == 'undefined' ) return false;
	var newRep = {}
	
	newRep.firstName = args.firstname
	newRep.lastName = args.lastname
	newRep.website = args.website
	
	var title = args.chamber != 'senate' ? 'Representative' : 'Senator',
		dist = args.chamber != 'senate' ? yourLocation.abvToState(args.state)+'\'s '+args.district.ordinalize()+' District': yourLocation.abvToState(args.state)
		rank = args.chamber != 'senate' ? '' : args.district.split(' ')[0].capitalize()+' '
 		district_label = args.chamber != 'senate' ? 'CD'+args.district : rank.trim()+'S'
	
	newRep.title = rank+title
	newRep.office = [title,'from',dist].join(' ')
	newRep.district = args.state+district_label
	
	return new repModel(newRep)
}
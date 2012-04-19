function repModel(args) {
	if( typeof args == 'undefined' ) return false;

	this.firstName = args.firstName
	this.lastName = args.lastName
	this.fullName = args.fullName || this.firstName+' '+this.lastName
	this.photo = args.photo
	this.website = args.website
	this.office = args.office

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

	newRep.office = [level,title,'for',dist,args.roles[0].district].join(' ')

	
	return new repModel(newRep)
}
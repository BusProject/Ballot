function locationModel(data) {
	// Google objects
	this.latlng = ko.observable('');
	this.map = ko.observable('');

	// Used for bindings in the document
	this.position = ko.computed( function() {
		if( typeof this.latlng().Ya == 'number' )
			return this.latlng().Ya+', '+this.latlng().Za;
		else 
			return 'Can\'t find where you at';
	}, this)

	return this;
}

var yourLocation = new locationModel();
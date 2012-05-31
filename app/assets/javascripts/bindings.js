$(document).on({
$(document).on({ // binding clearing a location
	click: function(e) {
		var $this = $(this),
			location = yourLocation
		location.latlng('38.7, -95.7')
		location.geocoded(false)
		location.address('')
		$('#address-input').select()
	}
},'.cancel')
.on({ // Binding the click-to-change issue
	click: function(e) {
		var ctx = ko.contextFor(this),
			$parent = ctx.$parent,
			$data = ctx.$data
	}
},'.race-menu ul li')
.on('click','#instructions ul li a',function(e){
	e.preventDefault()
	$this = $(this)
	$(document).scrollTop( $($this.attr('href')).position().top )
})

ko.bindingHandlers.src = {
	init: function(element, valueAccessor, allBindingsAccessor, viewModel) {
		var all = allBindingsAccessor(),
			src = all.src
		if( src == null ) $(element).remove()
		$(element).attr('src',src).error( function() { $(this).remove().parent().addClass('no-photo') });
	}
};

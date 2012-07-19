$(document).on({ // binding clearing a location
	click: function(e) {
		e.preventDefault();
		var $this = $(this),
			location = yourLocation
		location.latlng('38.7, -95.7')
		location.geocoded(false)
		location.choices([])
	}
},'.cancel')
.on('click','.clear',function(e) {
	yourLocation.address('')
	$('input.find-ballot').select()
})
.on({ // Binding the click-to-change issue
	click: function(e) {
		var ctx = ko.contextFor(this),
			$root = ctx.$root,
			$data = ctx.$data,
			selected = $root.selected()

		if( selected == $data ) return false
		$('.selected .body').find('.overlayText, .overlayBg').hide()
		$('.selected .body').slideUp()

		
		$root.selected($data)
		$(this).next('.body').slideDown('fast',function() { 
			var $this = $(this).parent()
			$('.overlayText, .overlayBg',$this).hide().fadeIn()
			// For scrolling to the top after it's done
			// setTimeout( function() { $(document).scrollTop( $this.position().top ) }, 500)
		}).parents(document) 
	}
},'h1.title')
	e.preventDefault()
	$this = $(this)
	$(document).scrollTop( $($this.attr('href')).position().top )
})
.on('click','.more',function(e){
	e.preventDefault()
	ctx = ko.contextFor(this)
	ctx.$parent.readmore(true)
	$(this).hide()
})
.on('click','.submitFeedback',function(e){
	if( current_user.id == 'unauthenticated' ) {
		document.location = $('.account a').attr('href')
	} else {
		var $ctx = ko.contextFor(this),
			$comment = $(this).prev('textarea')
			option = $ctx.$data,
			id = option.id,
			comment = $comment.val()
		
		if( comment.length > 1 ) $.ajax({
			url: document.location.href.split('#')[0]+'feedback/save',
			data: { feedback: [ 
					{
						option_id: parseInt(id),
						comment: comment,
					}
				]
			},
			success: function(response) {
				if( response.success ) {
					option.feedback.push( Feedback( { comment: comment, user: current_user, user_id: current_user.id, id: response.successes[0].obj } ) )
					$comment.val('')
				}
			}
		})
	}
})
.on('click','.feedback .remove',function(e) {
	var $ctx = ko.contextFor(this),
		$data = $ctx.$data
	$.post(
		'http://localhost:3000/feedback/'+$data.id,
		function(response){
			$ctx.$parent.feedback.remove( $data)
		}
	)
})
.scroll(function(e){ // Binding the scroll
		$this = $(this)
		yourLocation.top( $this.scrollTop() )
})

ko.bindingHandlers.src = {
	init: function(element, valueAccessor, allBindingsAccessor, viewModel) {
		var all = allBindingsAccessor(),
			src = all.src
		if( src == null ) $(element).remove()
		$(element).attr('src',src).error( function() { $(this).remove().parent().addClass('no-photo') });
	}
}

ko.bindingHandlers.elastic = {
	init: function(element, valueAccessor, allBindingsAccessor, viewModel) {
		$(element).elastic()
	}
}

ko.bindingHandlers.readmore = {
	init: function(element, valueAccessor, allBindingsAccessor, viewModel) {
		var all = allBindingsAccessor(),
			ctx = ko.contextFor(element),
			$parent = ctx.$parent
		
		if( all.text == null ) return false
		if( all.text.length > 300 ) {
			all.html = all.text.slice(0, all.text.slice(290).search(' ')+290 )+' ... <span class="more link">Read More</span>'
			if( typeof $parent.readmore == 'undefined' ) $parent.readmore = ko.observable(false)
		}
		if( typeof $parent.readmore != 'undefined' ) $(element).addClass('readMored')
	},
	update: function(element, valueAccessor, allBindingsAccessor, viewModel) { 
		var all = allBindingsAccessor(),
			ctx = ko.contextFor(element)
			$parent = ctx.$parent

		if( typeof $parent.readmore != 'undefined'  && $parent.readmore() ) {
			all.text = all.text
			var height = $(element).height()
			if( height > $parent.readmore() ) {
				$parent.readmore(height)
			}
			$(element).height($parent.readmore() )
		}
	}
};

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
	$('#enter-address input').select()
})
.on('keypress','#enter-address input',function(e) {
	if( e.keyCode == 13 ) $(this).next('a').click()
})
.on({ // Binding the click-to-change issue
	click: function(e) {
		if( inits.state == 'profile' || inits.state == 'single' ) return false

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
.on('click','#instructions ul li a, .fixed-link',function(e){
	$this = $(this)
	var href = $this.attr('href')
	if( href[0] == '#' ) {
		e.preventDefault()
		$(document).scrollTop( $(href).position().top )
	}
})
.on('click','.more',function(e){
	e.preventDefault()
	ctx = ko.contextFor(this)
	ctx.$parent.readmore(true)
	$(this).hide()
})
.on('click','.pick',function(e) {
	e.preventDefault()
	$('.picked').removeClass('picked')
	$(this).addClass('picked')
})
.on('click','.submitFeedback',function(e){
	e.preventDefault()
	var $this = $(this), $parent = $this.parents('.yourFeedback') 
	if( current_user.id == 'unauthenticated' ) {
		document.location = $('.account a').attr('href')
	} else {
		var $picked = $('.picked', $parent )

		if( $picked.length == 0 ) {
			$('.buttons p',$parent).css({'text-decoration':'underline','font-weight':'bold','color':'red'})
			setTimeout( function() { $('.buttons p',$parent).css({'text-decoration':'none', 'font-weight':'normal','color':'#D37A3C'}) },800)
			return false;
		}


		var $ctx = ko.contextFor( $picked[0] ),
			$comment = $('.comment', $parent),
			option = $ctx.$data,
			option_id = option.id,
			choice_id = option.choice_id,
			comment = $comment.val()

		// if( comment.length < 1 ) {
		// 	$('.comment',$parent).css({'border-color':'red','border-width':'3px'})
		// 	setTimeout( function() { $('.comment',$parent).css({'border-color':'rgb(215, 122, 60)','border-width':'1px'}) },800)
		// 	return false;
		// }

		$.ajax({
			url: inits.root+'feedback/save',
			data: { feedback: [ 
					{
						option_id: parseInt(option_id),
						choice_id: parseInt(choice_id),
						comment: comment,
						
					}
				]
			},
			success: function(response) {
				if( response.success ) {
					option.feedback.push( Feedback( { comment: comment, user: current_user, user_id: current_user.id, id: response.successes[0].obj, type: option.type } ) )
					$comment.val('')
					$('.yourFeedback img').load( function() { $('.selected .overlayText, .selected .overlayBg').hide().fadeIn() })
				}
			}
		})
	}
})
.on('click','body.not_logged_in .yourFeedback',function(e) {
	
	window.location = $('.account a').attr('href')
})
.on('click','.yourFeedback .remove',function(e) {
	var $data = ko.dataFor(this),
		option = $data.options.filter( function(el) { return el.feedback().indexOf( $data.you() ) !== -1 } )[0],
		$this = $(this)

	if( $this.hasClass('edit') ) {
		$this.parents('.row').find('.pick.'+$data.you().type).addClass('picked')
		$this.parents('.row').find('textarea.comment').val( $data.you().comment )
	}

	if( $data.you().id != 'undefined' ) $.post(
		inits.root+'feedback/'+$data.you().id,
		function(response){
			
			option.feedback.remove( $data.you() )
		}
	)
})
.on('click','.feedback .link',function(e) {

	e.preventDefault()

	var $ctx = ko.contextFor(this),
		$data = $ctx.$data,
		$this = $(this),
		action = 'useless'

	if( $this.hasClass('helpful') ) {
		action = 'useful'
		$data.usefulness( $data.usefulness() + 1 )
	} else {
		$data.usefulness( $data.usefulness() - 1 )
	}

	if( $this.hasClass('flag') ) action = 'flag'

	$.post(
		inits.root+'feedback/'+$data.id+'/'+action,
		function(response){
			$this.parents('.ask').html( response.message )
			if( $this.hasClass('flag') ) setTimeout( function() { $this.parent('.feedback').remove() }, 300 )
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
ko.bindingHandlers.slide = {
	update: function(element, valueAccessor, allBindingsAccessor, viewModel) { 
		if( valueAccessor() ) $(element).slideDown()
		else $(element).slideUp()
	}
};
ko.bindingHandlers.overwrite = {
	init: function(element, valueAccessor, allBindingsAccessor, viewModel) { 
		var val = valueAccessor()
		if( val ) {
			element.innerHTML = val
		}
	}
};
ko.bindingHandlers.addClass = {
	update: function(element, valueAccessor, allBindingsAccessor, viewModel) { 
		element.className += ' '+valueAccessor()
	}
};

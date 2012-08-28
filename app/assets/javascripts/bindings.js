$(document).on('click touchend','#find-ballot .cancel',function(e) { // binding clearing a location
		e.preventDefault();
		var $this = $(this),
			location = yourLocation
		location.latlng('38.7, -95.7')
		location.geocoded(false)
		location.choices([])
})
.on('click touchend','.clear',function(e) {
	yourLocation.address('')
	$('#enter-address input').select()
})
.on('keypress','#enter-address input',function(e) {
	if( e.keyCode == 13 ) $(this).next('a').click()
})
.on('click touchend', '.row button.open', function(e) {
		if( inits.state == 'profile' || inits.state == 'single' ) return false

		var ctx = ko.contextFor(this),
			$root = ctx.$root,
			$data = ctx.$data,
			selected = $root.selected()

		$('.selected .body').slideUp( function() { $('button.open', this.parentElement).text("Learn More and Comment") })

		if( selected == $data ) {
			$root.selected(null);
			return false
		}
		
		$(this).text('Close').nextAll('.body').slideDown('fast',function() { 
			$root.selected($data)
			var $this = $(this).parent()
			$('.overlayText, .overlayBg',$this).hide().fadeIn()
			// For scrolling to the top after it's done
			setTimeout( function() { $(document).scrollTop( $this.position().top ) }, 1)
		})
		
})
.on('click touchend','#instructions ul li a, .fixed-link',function(e){
	$this = $(this)
	var href = $this.attr('href')
	if( href[0] == '#' ) {
		var top = $(href).position().top
		e.preventDefault()

		$(document).scrollTop( top ).trigger('scroll')
	}
})
.on('click touchend','.more',function(e){
	e.preventDefault()
	ctx = ko.contextFor(this)
	ctx.$parent.readmore(true)
	$(this).hide()
})
.on('click touchend','.toggle',function(e) {
	e.preventDefault()
	$this = $(this);
	if( $this.attr('disabled') ) return false
	$this.attr('disabled',true)
	var animate = $this.hasClass('right') ? { left: '+=135' } : { right: '+=135' }
	$('.cover',$this).animate(animate, 200, function() {
		$this.toggleClass('right').attr('disabled',false).find('.cover').css({left: '', right: ''})
	});
})
.on('click touchend','.next',function(e) {
	$(this).parents('.row').next('.row').find('button.open').click()
})
.on('click ','button.submit',function(e){
	e.preventDefault()
	var $this = $(this), $parent = $this.parents('.yourFeedback') 
	if( current_user.id == 'unauthenticated' ) {
		document.location = $('.account a').attr('href')
	} else {
		var $toggle = $('.toggle', $parent )


		var $ctx = ko.contextFor( $toggle[0] ),
			$comment = $('.comment', $parent),
			//choice_id = $ctx.$data.id,
			option = $toggle.hasClass('right') ? $ctx.$data.no() : $ctx.$data.yes(),
			option_id = option.id,
			comment = $comment.val()

		$.post(
			inits.root+'feedback/save',
			{ feedback: [ 
					{
						option_id: parseInt(option_id),
						//choice_id: parseInt(choice_id),
						comment: comment,
						
					}
				]
			},
			function(response) {
				if( response.success ) {
					option.feedback.push( Feedback( { comment: comment, user: current_user, user_id: current_user.id, id: response.successes[0].obj, type: option.type, updated_at:  response.successes[0].updated_at } ) )
					$comment.val('')
					$('.yourFeedback img').load( function() { $('.selected .overlayText, .selected .overlayBg').hide().fadeIn() })
				}
			}
		)
	}
})
.on('click ','body.not_logged_in .yourFeedback',function(e) {
	window.location = $('.account a').attr('href')
})
.on('click touchend','.yourFeedback .meme',function(e) {
	var $data = ko.dataFor(this), memetainer = $('#meme-tainer')
	$('iframe',memetainer.show() ).attr('src',inits.root+'m/'+$data.you().id+'/new?frame=true' ).parent().prev('#meme-cova').show() 
	$(document.body).bind('click.meme touchstart.meme',function(e) {
		if( $(e.target).parents( memetainer ).length > 0  ) {
			$('iframe',memetainer.hide() ).attr('src','').parent().prev('#meme-cova').hide()
			$(this).unbind('click.meme touchstart.meme')
		}
		
	})
})
.on('click touchend','.yourFeedback .remove',function(e) {
	var $data = ko.dataFor(this),
		option = $data.options.filter( function(el) { return el.feedback().indexOf( $data.you() ) !== -1 } )[0],
		$this = $(this)

	if( $this.hasClass('edit') ) {
		$this.parents('.row').find('.pick.'+$data.you().type).addClass('picked')
		$this.parents('.row').find('textarea.comment').val( $data.you().comment )
	}

	if( $data.you().id != 'undefined' ) $.post(
		inits.root+'feedback/'+$data.you().id+'/remove',
		function(response){
			option.feedback.remove( $data.you() )
		}
	)
})
.on('click touchend','.feedback .link',function(e) {

	e.preventDefault()

	var $ctx = ko.contextFor(this),
		$data = $ctx.$data,
		$this = $(this),
		action = 'useless'

	if( $this.hasClass('helpful') ) {
		action = 'useful'
		var change = 1;
	} else {
		var change = -1;
	}

	if( $this.hasClass('flag') ) {
		$this.parent().html('Are you sure you want to flag? <span class="confirm-flag link">Yes</span> / <span class="stop-flag link">No</span>');
		return false;
	}
	if( $this.hasClass('confirm-flag') ) {
		var option = $ctx.$parent.options.filter( function(el) { return el.id == $data.option_id  })[0]
		option.feedback.remove( $data )
		$ctx.$parent.feedback()
		action = 'flag'
	}
	if( $this.hasClass('stop-flag') ) {
		$this.parent().html('Was this helpful?<span class="helpful link">Yes</span>&nbsp;|&nbsp;<span class="not link">No</span>&nbsp;|&nbsp;<span class="flag link">Flag</span></div>')
		return false;
	}

	$.post(
		inits.root+'feedback/'+$data.id+'/'+action,
		function(response){
			$this.parents('.ask').html( response.message )
			if( $this.hasClass('flag') ) setTimeout( function() { $this.parent('.feedback').remove() }, 300 )
			if( response.success ) $data.usefulness( $data.usefulness() + change )
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
		value = valueAccessor()
		element.className = element.className.replace(valueAccessor(),'').trim()+' '+value
	}
};

ko.bindingHandlers.stopBinding = {
    init: function() {
        return { controlsDescendantBindings: true };
    }
};

ko.virtualElements.allowedBindings.stopBinding = true;
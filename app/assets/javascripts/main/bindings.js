$(document).on('click touchend','#find-ballot .cancel',function(e) { // binding clearing a location
		e.preventDefault();
		var $this = $(this),
			location = yourLocation
		if( $this.hasClass('find-ballot-submit') ) location.geocoded.address('')
		location.latlng('38.7, -95.7')
		location.geocoded(false)
		location.choices([])
})
.on('click touchend','.clear',function(e) {
	yourLocation.address('')
	$('#enter-address input').select()
})
.on('keydown','#enter-address input',function(e) {
	if( e.keyCode == 13 ) { $(this).blur().nextAll('a.find-ballot-submit').click(); }
})
.on('click touchend', 'body.front .row button.open', function(e) {
		if( inits.state == 'profile' || inits.state == 'single' ) return false

		var ctx = ko.contextFor(this),
			$root = ctx.$root,
			$data = ctx.$data,
			selected = $root.selected()

		$('.selected .body').slideUp(400, function() { $('button.open', this.parentElement).text("Learn More and Comment"); })

		if( selected == $data ) {
			$root.selected(null);
			return false
		}
		var $this = $(this).parent()
		scrollUp = setInterval( function() { 
			var top = $this.position().top - 80
			if( top < $(document).scrollTop()  ) $(document).scrollTop( top  );
		}, 10)
		
		setTimeout(function() { clearInterval(scrollUp); },1000)
		
		$(this).text('Close').nextAll('.body').slideDown(400,function() { 
			$root.selected($data)
			clearInterval(scrollUp);
		})
		
})
.on('click touchend','#instructions ul li a:not(".small"), .fixed-link',function(e){
	$this = $(this)
	var href = $this.attr('href')
	if( href[0] == '#' && href[1] == '!' ) {
		var $href = $('a[name="'+href.split('!')[1]+'"]'),
			$button = $href.next('.row').find('button.open')
		if( !$button.parent().is('a') ) $button.click()
		setTimeout( function() { $(document).scrollTop( $href.offset().top - 80 ) },200)
		e.preventDefault()
	} else if( href[0] == '#' ) {
		var top = $(href).position().top-80
		e.preventDefault()
		$(document).scrollTop( top ).trigger('scroll')
		e.preventDefault()
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
.on('click touchend','.chooseable .option',function(e) {
	if( ['A','SPAN'].indexOf(e.target.tagName) === -1 ) {
		e.preventDefault();
		var $ctx = ko.contextFor(this),
			$parent = $ctx.$parent,
			$data = $ctx.$data
			$parent.chosen( $data )
	}
})
.on('click touchend','.next',function(e) {
	$(this).parents('.row').nextAll('.row:first').find('button.open').click()
})
.on('click ','button.submit',function(e){
	e.preventDefault()
	var $this = $(this), $parent = $this.parents('.yourFeedback') 
	if( current_user.id == 'unauthenticated' ) {
		document.location = $('.account a').attr('href')
	} else {
		
		if( $parent.hasClass('candidate') ) {
			var $ctx = ko.contextFor( $parent[0] ),
				$comment = $('.comment', $parent),
				choice_id = $ctx.$data.id,
				option = $ctx.$data.chosen(),
				option_id = option.id,
				comment = $comment.val()

		} else {
			var $toggle = $('.toggle', $parent ),
				$ctx = ko.contextFor( $toggle[0] ),
				$comment = $('.comment', $parent),
				choice_id = $ctx.$data.id,
				option = $toggle.hasClass('right') ? $ctx.$data.no() : $ctx.$data.yes(),
				option_id = option.id,
				comment = $comment.val()
		}

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
					option.support( option.support() +1 )
					option.feedback.push( Feedback( { option_id: option.id, option_name: option.name, comment: comment, user: current_user, user_id: current_user.id, id: response.successes[0].obj, type: option.type, updated_at:  response.successes[0].updated_at } ) )
					$comment.val('')
					$('.yourFeedback img').load( function() { $('.selected .overlayText, .selected .overlayBg').hide().fadeIn() })
				}
			}
		)
	}
})
.on('click touchend','.controls .meme',function(e) {
	var $data = ko.dataFor(this), memetainer = $('#meme-tainer')
	if( window.innerHeight < 750 ) memetainer.css('top', ((window.innerHeight < 642 ? 642 : window.innerHeight)-632)+'px')
	if( window.innerWidth < 1100 ) memetainer.css('marginLeft', (( window.innerWidth < 890 ? 780 : window.innerWidth ) -766-162 ) / 2+'px')
	$('iframe',memetainer.show() ).attr('src',inits.root+'m/'+$data.you().id+'/new?frame=true' ).parent().prev('#meme-cova').show() 
	$(document.body).bind('click.meme touchstart.meme',function(e) {
		if( $(e.target).parents( memetainer ).length > 0  ) {
			$('iframe',memetainer.hide() ).attr('src','').parent().prev('#meme-cova').hide()
			$(this).unbind('click.meme touchstart.meme')
		}
		
	})
})
.on('click touchend','.controls .remove',function(e) {
	var $ctx = ko.contextFor(this),
		$data = $ctx.$data,
		option = $data.options().filter( function(el) { return el.feedback().indexOf( $data.you() ) !== -1 } )[0],
		$this = $(this)

	option.support( option.support() -1 )
	if( $this.hasClass('edit') ) {
		var $row = $this.parents('.row')
		if( $row.hasClass('candidate') ) {
			//$data.chosen( $data.options().filter( function(el) { return el.id == $data.you().option_id })[0] )
		} else {
			$row.find('.pick.'+$data.you().type).addClass('picked')
		}
		$this.parents('.row').find('textarea.comment').val( $data.you().comment )
	}

	if( $data.you().id != 'undefined' ) $.post(
		inits.root+'feedback/'+$data.you().id+'/remove',
		function(response){
			if( $('body').hasClass('profile') ) yourLocation.choices.remove( $data )
			else option.feedback.remove( $data.you() );
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
		var option = $ctx.$parent.options().filter( function(el) { return el.id == $data.option_id  })[0]
		option.feedback.remove( $data )
		$ctx.parent.comments -= 1;
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
			if( $this.hasClass('conf-flag') ) setTimeout( function() { $this.parent('.feedback').remove() }, 300 )
			if( response.success ) $data.usefulness( $data.usefulness() + change )
		}
	)

})
.on('click touchend','.body a.get-more',function(e) {
	e.preventDefault();
	var $data = ko.dataFor(this), options = $data.options()
	$.get( 
		inits.root+'lookup/'+$data.id+'/more', {page: $data.feedback.more() },
		function(response) {
			var feedback = response
			for (var i=0; i < options.length; i++) {
				var option_id = options[i].id,
					matches = feedback.filter( function(el) { return el.option_id == option_id })
				for (var ii=0; ii < matches.length; ii++) {
					matches[ii].type = options[i].type
					matches[ii].option_name = options[i].name
					options[i].feedback.push( Feedback( matches[ii] ) )
				};
			};
			$data.feedback.page( $data.feedback.page() +1 )
	})
})
.on({
	mouseover: function(e) {
		var $doc = $(document), $this = $(this), alt = $this.attr('alt'), top = e.pageY-$doc.scrollTop()-26, left = e.pageX-$doc.scrollLeft()-alt.length*10/3.2
		$this.before('<div class="nametip" style=" top:'+top+'px; left: '+left+'px;" >'+alt+'</div>')
	},
	mousemove: function(e) {
		var $doc = $(document), $this = $(this), alt = $this.attr('alt'), top = e.pageY-$doc.scrollTop()-26, left = e.pageX-$doc.scrollLeft()-alt.length*10/3.2
		$(this).prev('.nametip').css({left: left, top: top})
	},
	mouseout: function(e) {
		$(this).prev('.nametip').remove()
	}
},'.face')
.scroll(function(e){ // Binding the scroll
		$this = $(this)
		if( window.innerWidth < 1029 ) {
			var left = $this.scrollLeft()
			if( left < 120 ) $('#instructions-box').css({'marginLeft':(-54-left)+'px','left':'auto'})
			else $('#instructions-box').css('left','-180px')
		}
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
ko.bindingHandlers.href = {
	init: function(element, valueAccessor, allBindingsAccessor, viewModel) {
		var all = allBindingsAccessor(),
			href = all.href
		if( href == null || href == '' ) $(element).remove()
		$(element).attr('href',href)
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
ko.bindingHandlers.stripClass = {
	update: function(element, valueAccessor, allBindingsAccessor, viewModel) { 
		element.className =''+valueAccessor()
	}
}
ko.bindingHandlers.addClass = {
	update: function(element, valueAccessor, allBindingsAccessor, viewModel) { 
		value = valueAccessor()
		element.className = element.className.replace(valueAccessor(),'').trim()+' '+value;
	}
};



ko.bindingHandlers.stopBinding = {
    init: function() {
        return { controlsDescendantBindings: true };
    }
};
ko.bindingHandlers.bindDescendents = {
    update: function(element, valueAccessor, allBindingsAccessor, viewModel) {
		var bindings =  allBindingsAccessor(),
			bind = bindings['model']
			ko.applyBindingsToDescendants(bind, element);
    }
};



ko.virtualElements.allowedBindings.stopBinding = true;
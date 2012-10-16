function makeMeme(memeRaw,path,flavor) {

	function memeModel(data) {

		this.quote = ko.observable( data.feedback.comment )
		this.choices = ko.observableArray([])
		this.limit = 140
		var memes = 6
		this.loading = ko.observable(false)
		this.unsaved = true
		this.title = 'Powered by theballot.org See all my recommendations at '+document.location.host+current_user.profile
		this.id = ko.observable(null)

		for (var i=1; i < memes+1; i++) {
			this.choices.push( 'new/'+i+'.jpg' )
		};

		this.theme = ko.observable( this.choices()[ Math.floor(Math.random()*(memes-1)) ] )

		this.quote.fixed = ko.computed( function() { 
			var limit = this.limit, 
				copy = this.quote().trim(), 
				length = copy.length
			if( length > limit ) {
				var space = copy.slice(limit-5,length).search(' ')
				return copy.slice(0,limit+space-1)
			} else return copy;
		}, this)
		
		this.special = ko.computed( function() {
			var quote = this.quote.fixed().trim().toLowerCase(), choices = this.choices()
			if( quote.search('hey girl') === 0 ) {
				if( choices.length == memes ) {
					this.choices.push(path+'special/gosling.jpg')
					this.theme( path+'special/gosling.jpg' )
				}
				return true
			} else if( quote.search('listen up') === 0 ) {
				if( choices.length == memes ) {
					this.choices.push(path+'special/coach-taylor.jpg')
					this.theme( path+'special/coach-taylor.jpg' )
				}
				return true
			} else if( quote.search('what if i told you') === 0 ) {
				if( choices.length == memes ) {
					this.choices.push(path+'special/morpheus.jpg')
					this.theme( path+'special/morpheus.jpg' )
				}
				return true
			} else if( quote.search('am i the only one around here') === 0 ) {
				if( choices.length == memes ) {
					this.choices.push(path+'special/walter.jpg')
					this.theme( path+'special/walter.jpg' )
				}
				return true
			} else if( quote.search('one does not simply') === 0 ) {
				if( choices.length == memes ) {
					this.choices.push(path+'special/boromir.jpg')
					this.theme( path+'special/boromir.jpg' )
				}
				return true
			} else if( quote.search('is too damn high') === quote.length - 'is too damn high'.length ) {
							if( quote.search('is too damn high') !== -1 && choices.length == memes && quote.length != 0  ) {
								this.choices.push(path+'special/high.jpg')
								this.theme( path+'special/high.jpg' )
							}
							return true
			} else if( quote.replace("'",'').search('i dont always') === 0 && quote.search('but when i do') !== -1 ) {
				if( choices.length == memes && quote.length != 0  ) {
					this.choices.push(path+'special/interesting.jpg')
					this.theme( path+'special/interesting.jpg' )
				}
				return true
			}
			if( choices[memes] ) {
				this.choices.remove( choices[memes] )
				this.theme( this.choices()[ Math.floor( Math.random() * (memes-1) ) ] )
			}

		},this)

		this.previewChange = ko.computed(function() {
			var p = this.quote.fixed(), t = this.theme()
			this.loading(true)
		},this)

		this.preview = ko.computed( function() {
			var loading = this.loading, id = this.id(), url = this.url
			$.post( 
				document.location.toString().replace('new','preview')+'.png',
				{ quote: this.quote.fixed(), theme: this.theme(), meme: this.id() }, 
				function(response) { 
					var url = typeof id == 'undefined' || id == null ? 'data:image/png;base64,' + response : document.location.protocol+'//'+document.location.host+'/m/'+id+'.png';
					$('.preview',document.body).html('<a href="'+url+'" target="_blank"><img src="data:image/png;base64,' + response + '" /></a>')
					loading(false)
				}
			)
		},this).extend({throttle: 500})

		return this;
	}

	window.onload = function() { 

		if( typeof current_user == 'undefined' ) window.current_user = window.parent.current_user

		if( typeof jQuery == 'undefined' && window.parent.jQuery ) { // Loads jQuery if necessary and jQuery UJS
			window.jQuery = window.parent.jQuery;
			window.$ = window.parent.jQuery;
			applyBindings()
		} else if( !jQuery ) {
			var add_jQ = document.createElement('script')
			add_jQ.onload = function() {
				var add_jQujs = document.createElement('script')
				add_jQujs.src = '<%= asset_path "jquery_ujs.js" %>'
				add_jQujs.onload = function() { applyBindings() }
				document.body.appendChild(add_jQujs)
			}
			add_jQ.src = '<%= asset_path "jquery.js" %>'
			document.body.appendChild(add_jQ)
		} else {
			applyBindings()
		}

		function applyBindings() {
			$(document.body)
				.on('click touchend','.pick div',function() { 
					var ctx = ko.contextFor(this); ctx.$parent.theme( ctx.$data ) 
				})
				.on('click touchend','button.share',function() {
					var data = ko.dataFor(this)
					if( data.unsaved ) {
						$('.share #share-box input').val('http://saving-one-sec').select()
						$.post(
							document.location.toString().split('?')[0],
							{ quote: data.quote.fixed(), theme: data.theme(), meme: data.id() }, 
							function(response) {
								if( response.success ) {

									var guide_name = ko.toJS(current_user.guide_name) == '' ? current_user.name+"'s Voter Guide" : ko.toJS(current_user.guide_name)
										img = document.location.protocol+'//'+document.location.host+response.url, // Le image you're linking to 
										link = document.location.protocol+'//'+document.location.host+current_user.profile, // Le page you're linkg to
										message = 'Check out '+guide_name

									$('a.facebook',document.body).attr('href',img.replace('.png','')+'/fb');
									$('a.googleplus',document.body).attr('href','https://plus.google.com/share?url='+img.slice(0,-4) );
									$('a.pinterest',document.body).attr('href','http://pinterest.com/pin/create/button/?url='+escape(link)+'&media='+escape(img)+'&description='+escape(message));

									var referr = 'theleague99', via = '', hashtags = 'TheBallot'
									var twitter = 'https://twitter.com/intent/tweet?original_referer='+referr+
										'&source=tweetbutton&hashtags='+hashtags+
										//'&via='+via+
										'&text='+message+
										'&url='+img.replace(/ /g,'-').replace(/\&/g,'%26').slice(0,-4);
									$('a.twitter',document.body).attr('href',twitter);

									var tumblr = 'http://www.tumblr.com/share/photo?source='+escape(img)+
										'&caption='+escape( message )+
										'&click_thru='+escape(link);
									$('a.tumblr',document.body).attr('href',tumblr);

									data.id( response.id )
									data.unsaved = false
								}
							}
						)
					}
				} )
				.on('click touchend','.icons a',function(e) {
					var data = ko.dataFor(this)
					if( data.unsaved ) { 
						data.calls = '.icons'
						$('.share').click()
						return false
					}
				})
				.on('click touchend','.kill',function(e) {
					var data = ko.dataFor(this)
					$.post( 
						'http://'+document.location.host+'/m/'+data.id(),
						function(response) {
							if( window.parent != window ) $(window.parent.document.body).trigger('click')
							else {
								data.id( null );
								data.unsaved = true;
							}
						})
				}).on('keydown','textarea',function(e){
					if( e.keyCode === 13 ) return false;
				})


			if( typeof ko == 'undefined' && window.parent.ko ) {  // Function loads KO if it's standalone HTML, grabs parent KO if in frame
				window.ko = window.parent.ko;
				ko.applyBindings( new memeModel(memeRaw), document.body )
			} else if ( !ko ) {
				var add_ko = document.createElement('script')
				add_ko.src = '<%= asset_path "knockout-latest.debug.js" %>'
				add_ko.onload = function() { ko.applyBindings( new memeModel(memeRaw), document.body ) }
				document.body.appendChild(add_ko)
			} else {
				ko.applyBindings( new memeModel(memeRaw), document.body )
			}

			$('.share-inner',document.body).html(  )
		}


	}
}
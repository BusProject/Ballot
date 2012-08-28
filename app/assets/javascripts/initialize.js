function initialize() {

	var geocoder = new google.maps.Geocoder()

	// var position = 'left: 40%; top: 200px;', verb = 'Allow', fired = false, display = "display: none;",timeout = 5000
	// function show() {
	// 	if( !yourLocation.geocoded() && navigator.geolocation && yourLocation.state == 'front' ) {
	// 
	// 		$('body').append('<div id="locationNotice" style="opacity: .9; font-size: 50px;'+display+position+'z-index: 1; position: fixed; background: #333;  color: white; border: 4px solid black; padding: 10px;"><a onclick="$(this).parent().slideUp(\'slow\',function(){ $(this).remove() } ); return false;" style="cursor: pointer; float: right; margin: -10px; font-size: 12px; font-family: sans-serif;">close</a>Click '+verb+'<p style="font-size: 14px; color: #fff;">Your location will not be stored - we\'re<br />just going to use it to build your ballot</p></div>').find('#locationNotice').slideDown('slow')
	// 		fired = true
	// 
	// 		$('body').bind('click.location-notice touchstart.location-notice', function() { 
	// 			$('#locationNotice').slideUp('slow',function(){$(this).remove()})
	// 			$(this).unbind('click.location-notice touchstart.location-notice')
	// 		})
	// 
	// 		setTimeout(function(){ $('#locationNotice').slideUp('slow',function(){$(this).remove()}) },timeout)
	// 	}
	// 	
	// }
	// 
	// if( navigator.userAgent.toLowerCase().search('chrome') !== -1  ) position = 'right: 20px;top: 20px;'
	// if( $.browser.mozilla  ) position = 'left: 500px;top: 20px;', verb = 'Share Location'
	// if( navigator.userAgent.search(/iPad/i) !== -1 ) {
	// 	position = 'left: 39%; top: 60%; ', verb = 'Ok', display = "display: block;", timeout = 10000
	// 	show()
	// }
	// if(  navigator.userAgent.search(/iPhone/i) !== -1 || navigator.userAgent.search(/iPod/i) !== -1 ) {
	// 	position = 'left: 20%; top: 70%; font-size: 150px;', verb = 'Ok', display = "display: block;", timeout = 10000
	// 	show()
	// }
	// 
	// if( navigator.platform.search("android") !== -1 ) {
	// 	position = 'left: 20px; bottom: 350px; font-size: 150px;', verb = 'Share location', display = "display: block;", timeout = 10000
	// 	show()
	// }
	

	// Adding the prompt for Geolocation - sometimes there's a bit of a lag for the browsers API to fire up
	// if( ! fired ) setTimeout( function() { show() }, 750)

  // Try HTML5 geolocation
  if(navigator.geolocation && yourLocation.state == 'front' ) {

    navigator.geolocation.getCurrentPosition(
		function(position) {
			var pos = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
			yourLocation.latlng(pos);
			geocoder.geocode({'latLng': pos}, function(results, status) {
				if (status == google.maps.GeocoderStatus.OK) {
					yourLocation.geocoded( true )
					yourLocation.googleLocation(results[0])
					yourLocation.geocoded.address = results[0].formatted_address
					yourLocation.address( results[0].formatted_address )
				}
			});
			$('#locationNotice').remove()
		}, 
		function(error) {
			console.log(error)
			$('#locationNotice').remove()
		},
		{maximumAge: 0, enableHighAccuracy: true }
		);
	} else {

	}



	if( FB ) {
		FB.getLoginStatus(function(response) {
			if( response.status == 'connected' ) {
				FB.api(
					{
						method: 'fql.query',
						query: 'SELECT uid FROM user WHERE is_app_user = '+FB.__appid+' AND uid IN (SELECT uid2 FROM friend WHERE uid1 =me() );'
					},
				  	function(response) { 
						var friends = response.map( function(el) { return el.uid } )
						if( yourLocation.friends().join('') != friends.join('') ) {
							yourLocation.friends( friends )
							$.post( inits.root+'users/update', { fb_friends:  friends.join(',') } )
						}
					}
				)
			} else if (response.status === 'not_authorized')  {
			} else {
			}
			current_user.auth_token = FB.getAccessToken();
		})
		
	}



	yourLocation.geocoder( geocoder );

}

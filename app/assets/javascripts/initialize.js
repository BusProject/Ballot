function initialize() {

	var geocoder = new google.maps.Geocoder()

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
			$('#locationNotice').slideUp('slow',function(){$(this).remove()})
		}, 
		function(error) {
			console.log(error)
			$('#locationNotice').slideUp('slow',function(){$(this).remove()})
		},
		{maximumAge: 0, enableHighAccuracy: true }
		);
	} else {
		
	}

	// Adding the prompt for Geolocation - sometimes there's a bit of a lag for the browsers API to fire up
	setTimeout( function() { 
		if( !yourLocation.geocoded() && navigator.geolocation && yourLocation.state == 'front' ) {
			var position = 'left: 40%; top: 200px;', verb = 'Allow'
			if( navigator.userAgent.toLowerCase().search('chrome') !== -1  ) position = 'right: 20px;top: 20px;'
			if( $.browser.mozilla  ) position = 'left: 500px;top: 20px;', verb = 'Share Location'

			$('body').append('<div id="locationNotice" style="opacity: .9; display: none; '+position+'z-index: 1; position: fixed; background: #333; font-size: 50px; color: white; border: 4px solid black; padding: 10px;"><a onclick="$(this).parent().slideUp(\'slow\',function(){ $(this).remove() } ); return false;" style="cursor: pointer; float: right; margin: -10px; font-size: 12px; font-family: sans-serif;">close</a>Click '+verb+'<p style="font-size: 14px; color: #fff;">Your location will not be stored - we\'re<br />just going to use it to build your ballot</p></div>').find('#locationNotice').slideDown('slow')

			$('body').bind('click.location-notice', function() { 
				$('#locationNotice').slideUp('slow',function(){$(this).remove()})
				$(this).unbind('click.location-notice')
			})

			setTimeout(function(){ $('#locationNotice').slideUp('slow',function(){$(this).remove()}) },5000)
		}
	}, 750)

	if( FB ) {
		FB.getLoginStatus(function(response) {
			if( response.status == 'connected' ) {
				FB.api(
					{
						method: 'fql.query',
						query: 'SELECT uid FROM user WHERE is_app_user = '+FB.__appid+' AND uid IN (SELECT uid2 FROM friend WHERE uid1 =me() );'
					},
				  	function(response) { yourLocation.friends( response.map( function(el) { return el.uid } ) ) }
				)
			} else if (response.status === 'not_authorized')  {
			} else {
			}
		})
	}



	yourLocation.geocoder( geocoder );

}

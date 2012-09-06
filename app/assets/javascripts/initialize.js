function initialize() {

	var geocoder = new google.maps.Geocoder()

  // Try HTML5 geolocation
  if(navigator.geolocation && yourLocation.state == 'front' && inits.address.length < 1 ) {

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
		}, 
		function(error) {
			console.log(error)
		},
		{maximumAge: 0, enableHighAccuracy: true }
		);
	} else {
		yourLocation.address( inits.address )
	}



	if( typeof FB != 'undefined' ) {
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

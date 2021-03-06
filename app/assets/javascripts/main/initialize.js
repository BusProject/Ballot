function initialize() {

	if( typeof google != 'undefined') {
		if( typeof google.maps != 'undefined' ) var geocoder = new google.maps.Geocoder()

	  // Try HTML5 geolocation
	  if(navigator.geolocation && yourLocation.state == 'front' && inits.address == '' ) {

	    navigator.geolocation.getCurrentPosition(
			function(position) {
				var pos = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
				yourLocation.latlng(pos);
				geocoder.geocode({'latLng': pos}, function(results, status) {
					if (status == google.maps.GeocoderStatus.OK) {
						yourLocation.geocoded( true )
						yourLocation.googleLocation(results[0])
						yourLocation.geocoded.address(results[0].formatted_address)
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
						if( current_user.fb_friends != friends.join(',') ) {
							$.post( inits.root+'users/update', { fb_friends:  friends.join(',') } )
							current_user.fb_friends = friends.join(',')
						}
					}
				)
			} else if (response.status === 'not_authorized')  {
				$('a[href="/users/auth/facebook"]').attr('href','https://m.facebook.com/dialog/permissions.request?app_id='+FB.__appid+'&next='+escape( document.location.protocol + '//'+document.location.host )+'%2Fusers%2Fauth%2Ffacebook%2Fcallback&response_type=code&perms=email%2Coffline_access%2Cfriends_activities%2Cuser_location%2Cfriends_location%2Cuser_activities%2Cuser_status%2Cuser_photos%2Cpublish_stream&fbconnect=1')
			} else {
			}
			current_user.auth_token = FB.getAccessToken();
		})

	}

	$('.search').betterAutocomplete( '/search', function( event, ui ) { document.location = ui.item.url }, 2,  'top-search')
	$('.search').bind('focus.down',function(e) { $(document).scrollTop( $(this).unbind('focus.down').position().top ) })


	yourLocation.geocoder( geocoder );

}

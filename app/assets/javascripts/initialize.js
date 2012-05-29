function initialize() {

	var geocoder = new google.maps.Geocoder()

  // Try HTML5 geolocation
  if(navigator.geolocation) {
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
		
	}
	yourLocation.geocoder( geocoder );
}


google.maps.event.addDomListener(window, 'load', initialize);
function initialize() {
  var myOptions = {
    zoom: 2,
    mapTypeId: google.maps.MapTypeId.ROADMAP,
	disableDefaultUI: true
  };
  var map = new google.maps.Map(document.getElementById('map_canvas'),myOptions),
	geocoder = new google.maps.Geocoder()

	setMap(map);

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
		function() {
		});
	} 
	yourLocation.map(map);
	yourLocation.geocoder( geocoder );
}


google.maps.event.addDomListener(window, 'load', initialize);
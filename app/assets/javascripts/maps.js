var map;

function initialize() {
  var myOptions = {
    zoom: 2,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  };
  var map = new google.maps.Map(document.getElementById('map_canvas'),myOptions),
	geocoder = new google.maps.Geocoder()

	handleNoGeolocation(map);

  // Try HTML5 geolocation
  if(navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(
		function(position) {
			var pos = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
			yourLocation.latlng(pos);
			geocoder.geocode({'latLng': pos}, function(results, status) {
				if (status == google.maps.GeocoderStatus.OK) {
					yourLocation.geocoded( true )
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

function handleNoGeolocation(map) {

  var options = {
    map: map,
    position: new google.maps.LatLng(38.7, -95.7),
    content: content
  };

  //var infowindow = new google.maps.InfoWindow(options);
  map.setCenter(options.position);
}

google.maps.event.addDomListener(window, 'load', initialize);
function setMap(map) {
  var options = {
    map: map,
    position: new google.maps.LatLng(38.7, -95.7),
  };
  //var infowindow = new google.maps.InfoWindow(options);
  map.setCenter(options.position);
}

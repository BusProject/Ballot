var geocoder = new google.maps.Geocoder();

function ward(lat, lng) {
    var point = {
        "type": "Feature",
            "geometry": {
            "type": "Point",
                "coordinates": [lng, lat]
        }
    };
    for (var i in NEW_WARDS) {
        var the_ward = {
            "type": "Feature",
                "geometry": {
                "type": "Polygon",
                    "coordinates": NEW_WARDS[i].simple_shape[0]
            }
        };
        if (turf.inside(point, the_ward)) {
            map_label.innerText = "Ward #" + i;
            mapIt(the_ward, NEW_WARDS[i].centroid, [lng, lat]);
            return NEW_WARDS[i];
        }
    }
    new_map([lng, lat]);
    map_label.innerText = "Not in Chicago :|";
}

function new_map(center) {
    var map = new google.maps.Map(map_canvas, {
        zoom: 13,
        center: new google.maps.LatLng(center[1], center[0]),
        mapTypeId: google.maps.MapTypeId.ROADMAP
    });
    return map;
}

function mapIt(ward, center, home) {
    var map = new_map(center);
    map.data.addGeoJson(ward);
    map.data.setStyle({
        "strokeWeight": 1,
            "color": "red",
            "fillColor": "red",
            "fillOpacity": 0.1,
            "strokeColor": "red"
    });
    new google.maps.Marker({
        position: new google.maps.LatLng(home[1], home[0]),
        map: map,
        title: 'Hello World!'
    });
    return map;
}


function searchSubmit(form) {
    map_label.innerText = "";
    map_canvas.innerHTML = "";

    var address = form.address.value;
    geocoder.geocode({
        address: address
    }, function (results, status) {
        if (status == google.maps.GeocoderStatus.OK) {
            var parse = results[0].geometry.location.toString().replace(/\(|\)/g, '')
            lat = parse.split(',')[0],
                lng = parse.split(',')[1];
            ward(lat, lng);
        }
    });
    return false;
}

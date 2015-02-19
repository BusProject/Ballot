(function() {
    var geocoder = new google.maps.Geocoder(),
        wards = false,
        alderpeople = false,
        callback = false

    function findWard(lat, lng) {
        var point = {
            "type": "Feature",
                "geometry": {
                "type": "Point",
                    "coordinates": [lng, lat]
            }
        };
        for (var i in wards) {
            var the_ward = {
                "type": "Feature",
                    "geometry": {
                    "type": "Polygon",
                        "coordinates": wards[i].simple_shape[0]
                }
            };
            if (turf.inside(point, the_ward)) {
                mapIt(the_ward, wards[i].centroid, [lng, lat]);
                renderAlerpeople(i);
                return wards[i];
            }
        }
        new_map([lng, lat]);
    }
    function new_map(center) {
        map_canvas.style.display = 'block';
        var map = new google.maps.Map(map_canvas, {
            zoom: 12,
            center: new google.maps.LatLng(center[1], center[0]),
            mapTypeId: google.maps.MapTypeId.ROADMAP,
            scrollwheel: false,
            overviewMapControl: false,
            streetViewControl: false,
            zoomControl: false,
            panControl: false,
            mapTypeControl: false,
            scaleControl: false,
            draggable: true
        });
        return map;
    }
    function mapIt(ward, center, home) {
        var map = new_map(center);

        new google.maps.Marker({
            position: new google.maps.LatLng(home[1], home[0]),
            map: map})

        map.data.addGeoJson(ward);
        map.data.setStyle({
            "strokeWeight": 1,
            "color": "red",
            "fillColor": "red",
            "fillOpacity": 0.1,
            "strokeColor": "red"
        });
        return map;
    }
    function searchSubmit() {
        map_canvas.innerHTML = "";

        var address = this.address.value;

        geocoder.geocode({
            address: address
        }, function (results, status) {
            if (status == google.maps.GeocoderStatus.OK) {
                var parse = results[0].geometry.location.toString().replace(/\(|\)/g, '')
                    lat = parse.split(',')[0],
                    lng = parse.split(',')[1]
                setUp(lat, lng)
                for( var i = 0; i < results[0].address_components.length; i++) {
                    if( results[0].address_components[i].types[0] == 'postal_code' ) {
                        log_zip(results[0].address_components[i].long_name);
                        break;
                    }
                }
            }
        });
        return false;
    }
    function log_zip(zip) {
        try { ga('send', 'event', 'zip', 'lookup'); } catch(e) { }
    }
    function renderAlerpeople(ward) {
        alderperson_list.innerHTML = '<h3>Candidates for Ward '+ward+'</h3>';

        for (var i = alderpeople.length - 1; i >= 0; i--) {
            if( alderpeople[i].ward == ward ) {
                alderperson_list.appendChild(renderAlderPerson(alderpeople[i]))
            }
        };
    }
    function renderAlderPerson(alderperson) {
        var container = document.createElement('div'),
            img = document.createElement('div'),
            title = document.createElement('h2'),
            generic_link = document.createElement('a')


        container.className = 'alderperson'
        title.innerText = [alderperson.first, alderperson.last].join(' ')
        container.appendChild(title)


        img.className = 'img'
        img.style.backgroundImage = 'url(/'+alderperson.photo+')'
        container.appendChild(img)


        generic_link.setAttribute('_target','blank')

        var twitter = generic_link.cloneNode(),
            website = generic_link.cloneNode()

        website.className = "fa fa-link"
        twitter.className = "fa fa-twitter-square"

        website.innerText = "Webpage"
        twitter.innerText = "Twitter"

        if( (alderperson.website || '').length > 0 ) {
            website.setAttribute('href', alderperson.website)
            container.appendChild(website)
        }
        if( (alderperson.twitter || '').length > 0 ) {
            twitter.setAttribute('href',alderperson.twitter)
            container.appendChild(twitter)
        }
        return container
    }

    function setUp(lat, lng) {
        if( wards && alderpeople ) {
            if( callback ) return callback()
            if(lat && lng) {
                return findWard(lat, lng)
            }
        }
        if(lat && lng) {
            callback = function() { return findWard(lat, lng); }
        }
    }

    document.body.onload = function() {
        search_form.onsubmit = searchSubmit;

        tinyGET('/data/wards.json',{},
            function(data) { wards = data; setUp(); });
        tinyGET('/data/alderpeople.json',{},
            function(data) { alderpeople = data; setUp(); });

        if( document.location.hash.length > 0 ) {
            search_form.address.value = document.location.hash.replace('#','').replace(/\+/g,' ')
            searchSubmit.apply(search_form)
        }
    }

})()

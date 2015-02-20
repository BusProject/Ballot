(function() {
    var geocoder = new google.maps.Geocoder(),
        wards = false,
        alderpeople = false,
        callback = false

    /** Mapping **/
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
    function specifyWard(ward) {
        var the_ward = {
                "type": "Feature",
                    "geometry": {
                    "type": "Polygon",
                        "coordinates": wards[ward].simple_shape[0]
                }
            };
        mapIt(the_ward, wards[ward].centroid, wards[ward].centroid);
        renderAlerpeople(ward);
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

    /** Templates **/
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
            endorsement_button = document.createElement('a'),
            title = document.createElement('h2'),
            incumbent = document.createElement('h4'),
            generic_link = document.createElement('a'),
            name = [alderperson.first, alderperson.last].join(' '),
            ordinal = getOrdinal(parseInt(alderperson.ward))


        container.className = 'alderperson'
        title.innerText = name
        container.appendChild(title)

        if( (alderperson.photo || '').length > 0 ) {
            img.className = 'img'
            img.style.backgroundImage = 'url(/'+alderperson.photo+')'
            container.appendChild(img)
        }
        if( alderperson.incumbent ) {
            incumbent.innerText = 'Incumbent'
            container.appendChild(incumbent)
        }

        generic_link.setAttribute('target','blank')

        // TODO: Abtract into templating function
        var twitter = generic_link.cloneNode(),
            facebook = generic_link.cloneNode(),
            website = generic_link.cloneNode()

        website.className = "fa fa-link"
        twitter.className = "fa fa-twitter-square"
        facebook.className = "fa fa-facebook-square"

        website.innerText = "Webpage"
        twitter.innerText = "Twitter"
        facebook.innerText = "Facebook"

        if( (alderperson.website || '').length > 0 ) {
            website.setAttribute('href', alderperson.website)
            container.appendChild(website)
        }
        if( (alderperson.facebook || '').length > 0 ) {
            facebook.setAttribute('href',alderperson.facebook)
            container.appendChild(facebook)
        }
        if( (alderperson.twitter || '').length > 0 ) {
            twitter.setAttribute('href',alderperson.twitter)
            container.appendChild(twitter)
        }

        // TODO: Abtract into templating function
        endorsement_button.innerText = 'endorse'
        endorsement_button.className = 'vote_for'
        endorsement_button.setAttribute('data-name', name)
        endorsement_button.setAttribute('data-link',
            ('/sharing/alderman/'+alderperson.ward+'-'+(name
            .replace(' ','-').toLowerCase().replace(/[^a-zA-Z0-9\-]/g,''))))
        endorsement_button.setAttribute('data-office',
                                        ordinal+' Ward Alderman')
        endorsement_button.onclick = function() { endorsementWidget(this) }
        container.appendChild(endorsement_button)

        return container
    }
    function endorsementWidget(button) {
        var button = button,
            name = button.getAttribute('data-name'),
            link = button.getAttribute('data-link'),
            office = button.getAttribute('data-office'),
            generic_link = document.createElement('a'),
            cover = document.createElement('div'),
            outers = document.createElement('div'),
            inners = document.createElement('div'),
            socials = document.createElement('div'),
            messages = document.createElement('strong'),
            parent = button.parentElement

        parent.className += ' now_voting_for'

        button.onclick = endorsementWidgetclose
        button.innerText = 'close'

        cover.setAttribute('id','the_cover')
        cover.onclick = endorsementWidgetclose

        generic_link.setAttribute('target','_blank')

        var facebook = generic_link.cloneNode(),
            twitter = generic_link.cloneNode(),
            tumblr = generic_link.cloneNode()

        facebook.className = "fa fa-facebook"
        twitter.className = "fa fa-twitter"
        tumblr.className = "fa fa-tumblr"

        facebook.onclick = function() {
            log_share('facebook', office, name)
            this.className += ' clicked'}
        twitter.onclick = function() {
            log_share('twitter', office, name)
            this.className += ' clicked'
        }
        tumblr.onclick = function() {
            log_share('tumblr', office, name)
            this.className += ' clicked'
        }

        message = ["Vote",name,"for",office].join(' ')
        link = "http://www.chicagovoterguide.org"+link

        facebook.setAttribute('href',
            "https://www.facebook.com/sharer/sharer.php?u="+link)
        tweet_params = ["text="+message,
                        "url="+link,
                        "hashtags=#chivote2015",
                        "related=chicagovotes"].join('&')
        twitter.setAttribute('href',
            "https://twitter.com/intent/tweet?"+tweet_params)

        tumblr_params = ["v=3",
                        "u="+link,
                        "t="+message,
                        "s="].join('&')
        tumblr.setAttribute('href',
            "https://www.tumblr.com/share?"+tumblr_params);

        socials.appendChild(twitter)
        socials.appendChild(facebook)
        socials.appendChild(tumblr)

        messages.innerText = 'Spread the word:'
        socials.className = 'socials'
        inners.className = 'inners'
        outers.className = 'outers'

        inners.appendChild(messages)
        inners.appendChild(socials)
        outers.appendChild(inners)

        if( button.nextSibling && button.nextSibling.nodeType != 4 ) {
            parent.appendChild(outers)
        } else {
            parent.insertBefore(outers, button.nextSibling)
        }

        document.body.appendChild(cover)

        log_endorse(office, name)

        function endorsementWidgetclose() {
            parent.style.position = null
            parent.style.zIndex = null
            parent.style.backgound = null
            parent.style.borderRadius = null
            parent.className = parent.className.replace(' now_voting_for','')
            button.className += ' fa checked fa-check-circle-o'
            button.innerText = 'endorsed'
            button.onclick = function() { endorsementWidget(this) }

            parent.removeChild(outers)

            document.body.removeChild(cover)
        }
    }
    window.endorsementWidget = endorsementWidget

    /** Bindings **/
    function searchSubmit() {
        map_canvas.innerHTML = "";

        var address = this.address.value;
        if( address.toLowerCase().search('chicago') === -1 ) {
            address += ' Chicago IL'
        }
        if( address.toLowerCase().search('il') === -1 ||
                address.toLowerCase().search('illinois') === -1 ) {
            address += ' IL'
        }

        geocoder.geocode({
            address: address
        }, function (results, status) {
            if (status == google.maps.GeocoderStatus.OK) {
                var parse = results[0].geometry.location.toString().replace(/\(|\)/g, '')
                    lat = parse.split(',')[0],
                    lng = parse.split(',')[1]
                when_ready(function() { findWard(lat, lng) })
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
        try { ga('send', 'event', 'lookup', zip); } catch(e) { }
    }
    function log_endorse(type, thing) {
        try { ga('send', 'event', 'endorse', type, thing); } catch(e) { }
    }
    function log_share(method, type, thing) {
        try { ga('send', 'event', "share_"+method, type, thing); } catch(e) { }
    }
    function when_ready(runn_func) {
        if( wards && alderpeople ) {
            if( callback ) {
                return callback()
            } else if( typeof runn_func != 'undefined' ) {
                return runn_func()
            }
        } else if( typeof runn_func != 'undefined' ) {
            callback = runn_func
        }
    }
    function getOrdinal(n) {
       var s=["th","st","nd","rd"],
           v=n%100;
       return n+(s[(v-20)%10]||s[v]||s[0]);
    }

    document.body.onload = function() {
        search_form.onsubmit = searchSubmit;

        tinyGET('/data/wards.json',{},
            function(data) { wards = data; when_ready(); });
        tinyGET('/data/alderpeople.json',{},
            function(data) { alderpeople = data; when_ready(); });

        if( document.location.hash.length > 0 ) {
            if( document.location.hash[1] != '!' ) {
                search_form.address.value = document.location.hash.replace('#','').replace(/\+/g,' ')
                searchSubmit.apply(search_form)
            } else {
                if( document.location.hash[2] == '@') {
                    when_ready( function() {
                        specifyWard(document.location.hash.replace(/[^0-9]/g,''))
                        document.location.hash = 'alderperson_list'
                    });
                }
            }
        }
    }

})()

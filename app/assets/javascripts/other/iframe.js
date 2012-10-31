$(document).on('click touchend','a[href="/users/auth/facebook"]', function() {
	FB.login(function(response) {
		if (response.authResponse) {
			document.location = '/users/auth/facebook'+document.location.search
		} else {
			console.log('User cancelled login or did not fully authorize.');
		}
	},{scope: 'email, offline_access, friends_activities, user_location, friends_location, user_activities, user_status, user_photos, publish_stream'})
	return false;
});

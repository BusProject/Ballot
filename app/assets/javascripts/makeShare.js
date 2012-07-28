function makeShare(url,name,msg) {
	var url = url || document.location.host, msg = msg || '', name = name || 'The Ballot | Your Social Voter Guide'
	url = document.location.protocol+'//'+url.replace(/http:\/\//g,'')
	string = '<div id="share-box" class="'+(navigator.appVersion.indexOf("Mac")!==-1 ? 'osx' : '')+'"><input onblur="$(this).parent().removeClass(\'on\')" onclick="$(this).select().parent().addClass(\'on\')" onkeypress="return false" class="link" value="'+url+'" type="text" >'
	string += '<div class="icons">'
	string += '<a target="_blank" href="https://www.facebook.com/sharer/sharer.php?u='+escape(url)+'" class="fbook"><div></div></a>'
	string += '<a arget="_blank" href="https://twitter.com/intent/tweet?original_referer=yi_care&source=tweetbutton&text='+msg+'&url='+escape(url)+'" class="twitter"><div></div></a>'
	// More twitter terms &hashtags=&via=&related=
	string += '<a target="_blank" href="http://www.tumblr.com/share/link?url='+escape(url)+'&name='+name+'&description='+msg+'" class="tumblr"><div></div></a>'
	string += '</div></div>'
	return string
}

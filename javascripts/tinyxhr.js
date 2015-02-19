/* based off of tinyxhr by Shimon Doodkin - license: public doamin - https://gist.github.com/4706967

 Added ontop of Simon's code:
  - Serialization of the object
  - Moved some arguments to line up with jQuery( url, data, callback )
  - Will attempt to parse JSON from the response if it's valid JSON
  - Added a tinyPost and tinyGet method

 Some other things that'd be good:
  - Seprate error callback for failed responses
  - Automatically process and post data as JSON if content type is set and data is not a string
  - Serialize method probably doesn't work for complex forms, womp womp

*/

function tinyPOST(url,data,callback) {
 tinyxhr(url,data,callback,'POST');
}

function tinyGET(url,data,callback) {
 tinyxhr(url,data,callback);
}

function tinyxhr(url,data,callback,method,contenttype,timeout) {

	var requestTimeout,xhr;

	try{ xhr = new XMLHttpRequest();
	} catch(e){
		try{ xhr = new ActiveXObject("Msxml2.XMLHTTP");}
		catch (e){ return null; }
	}

	requestTimeout = setTimeout( function() {
		xhr.abort(); callback(new Error("tinyxhr: aborted by a timeout"), "",xhr);
	}, timeout || 5000);

	xhr.onreadystatechange = function() {
		if (xhr.readyState != 4) return;
		clearTimeout(requestTimeout);
		var response = xhr.responseText
		try { response = JSON.parse( response ); } catch( e ) {}
		callback( response, (xhr.status != 200 ? new Error("tinyxhr: server respnse status is "+xhr.status) : false), xhr );
	}
	xhr.open( method ? method.toUpperCase() : "GET", url, true);

	function serialize(obj) {
		var str = [];
		for(var p in obj)
		 str.push(encodeURIComponent(p) + "=" + encodeURIComponent(obj[p]));
		return str.join("&");
	}

 	if(! data ) { xhr.send();
	} else {
		if( typeof data == 'object' ) data = serialize(data);
		xhr.setRequestHeader('Content-type', contenttype ? contenttype : 'application/x-www-form-urlencoded');
  		xhr.send(data)
	}

}

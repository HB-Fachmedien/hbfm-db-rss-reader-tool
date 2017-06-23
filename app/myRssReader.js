var fs = require('fs');
var http = require('https');
var request = require('request');
var replace = require('stream-replace');

const log = require('electron-log'); 

var myRssReader = function(){

	var stream;

	this.leseFeed = function(uri, proxy){
		let urlTest = 'https://www.der-betrieb.de/feed/?cat=27';
		// https://www.der-betrieb.de/category/interview/feed/atom/
		// gesamter Feed: https://www.der-betrieb.de/feed/?cat=11
		// Interviews: cat=28
		
	    console.log("Feed wird gelesen... Proxy lautet: " + proxy);
	    log.warn("Feed wird gelesen... Proxy lautet: " + proxy);

	    return new Promise(function (fulfill, reject){

		    // Der VHB Proxy lautet proxy.vhb.de:80, benötigt aber für den Dateidownload den Protokoll Prefix
		    let proxystring = proxy.includes("http") ? proxy : "http://"+proxy;

		    console.log("Proxy Vergleich:");
		    console.log("NPM Proxy: " + process.env.npm_config_proxy);
		    console.log("Request Proxy: " + proxy);

		    log.warn("Proxy Vergleich:");
		    log.warn("NPM Proxy: " + process.env.npm_config_proxy);
		    log.warn("Request Proxy: " + proxy);

		    var writable = fs.createWriteStream("./output/rss.xml");
		    let req_options = {
		        uri: uri,
		        encoding: null,
		        //proxy: "http://proxy.vhb.de"
		        //proxy: process.env.npm_config_proxy
		        //proxy : proxystring
		    };

		    // bei der Mainpost wird 'DIRECT' als Rückgabewert nach dem Proxy geschrieben, das wird hier abgefangen
		    if (proxystring.indexOf('DIRECT') == -1) {		    	
		    	req_options.proxy = proxystring;
		    }
		    else{
		    	log.warn("proxystring enthält DIRECT. Es ist also kein Proxy vorhanden.");
		    }
		    log.warn("Request Options Objekt:");
		    log.warn(req_options);

		    stream = request.get(req_options).on('response', function(response) {
		        console.log("code:", response.statusCode);
		        log.warn("code:", response.statusCode);
		        if (response.statusCode >= 500) {
		            console.err(response.statusCode, " Servererror");
		            log.warn(response.statusCode, " Servererror");
		            reject(response.statusCode);
		        }
		    }).pipe(replace(/\<!\[CDATA\[/g, '')).pipe(replace(/\]\]\>/g, '')).pipe(replace(/\&nbsp;/g, ''))
		    .pipe(replace(/content:encoded/g, 'content')).pipe(writable);
		    stream.on('finish', function () {
		    	fulfill(true);
				console.log("Datei erstellt!");
				log.warn("Datei erstellt!");
			});

		  });
	    
	    
		
	};


};

module.exports = myRssReader;
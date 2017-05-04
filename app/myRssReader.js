var fs = require('fs');
var http = require('https');
var request = require('request');
var replace = require('stream-replace');

var myRssReader = function(){

	this.test = function(){
		console.log(" klappt klappt");
	};

	var stream;

	this.leseFeed = function(uri){
		let urlTest = 'https://www.der-betrieb.de/feed/?cat=27';
		// https://www.der-betrieb.de/category/interview/feed/atom/
		// gesamter Feed: https://www.der-betrieb.de/feed/?cat=11
		// Interviews: cat=28
		
	    console.log("Feed wird gelesen...");

	    return new Promise(function (fulfill, reject){
		    // fs.readFile(filename, enc, function (err, res){
		    //   if (err) reject(err);
		    //   else fulfill(res);
		    // });
		    var writable = fs.createWriteStream("./output/rss.xml");
		    stream = request.get({
		        uri: uri,
		        encoding: null,
		        //proxy: "http://proxy.vhb.de"
		        proxy: process.env.npm_config_proxy
		    }).on('response', function(response) {
		        console.log("code:", response.statusCode);
		        if (response.statusCode >= 500) {
		            console.err(response.statusCode, " Servererror");
		            reject(response.statusCode);
		        }
		    }).pipe(replace(/\<!\[CDATA\[/g, '')).pipe(replace(/\]\]\>/g, '')).pipe(replace(/\&nbsp;/g, ''))
		    .pipe(replace(/content:encoded/g, 'content')).pipe(writable);
		    stream.on('finish', function () {
		    	fulfill(true);
				console.log("Datei erstellt!");
			});

		  });
	    
	    
		
	};


};

module.exports = myRssReader;
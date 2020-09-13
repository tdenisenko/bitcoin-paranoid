using Toybox.Communications as Comm;
using Toybox.System as Sys;
using Toybox.Timer;
using Toybox.WatchUi as Ui;
using Toybox.Application.Storage;

(:glance)
class CryptoPrice {	//Data of top 10 market cap coins
	var curSymbol = ["BTC", "ETH"];
	var curPrice = new [2]; //Current $USD price of top 10
	var curTime = new [2];
}

(:glance)
class PriceModel {
	var cp = null;
	var myTimer;
	var intervals;
	var idx;
	hidden var curUrls = [
		"https://www.bitmex.com/api/v1/trade?symbol=XBTUSD&columns=timestamp%2Cprice&count=1&reverse=true",
		"https://www.bitmex.com/api/v1/trade?symbol=ETHUSD&columns=timestamp%2Cprice&count=1&reverse=true"
	];
	hidden var notify;

  	function initialize(handlers) {
  		intervals = [1000, 5000, 10000, 30000, 60000, 300000, 600000, 900000, 1800000, 3600000];
  		var interval = Storage.getValue("interval");
  		if (interval == null) {
	  		idx = 1;
	  		interval = intervals[idx];
  			Storage.setValue("interval", intervals[idx]);
  		} else {
  			idx = intervals.indexOf(interval);
  		}
  	   	notify = handlers;
  	   	myTimer = new Timer.Timer();
    	myTimer.start(method(:makePriceRequests), interval, true);
        makePriceRequests();
    }
    
    function resetTimer() {
    	idx++;
    	idx %= intervals.size();
    	myTimer.stop();
    	myTimer.start(method(:makePriceRequests), intervals[idx], true);
    	Storage.setValue("interval", intervals[idx]);
    }
    
    function makePriceRequests() {
		//Check if Communications is allowed for Widget usage
		if (Toybox has :Communications) {
			//Ui.requestUpdate();
			cp = null;
			// Get current price and coin symbol from API
			for( var i = 0; i < 2; i++ ) {
				Comm.makeWebRequest(curUrls[i],
			         				 {}, 
			         				 {}, 
			         				 method(:onReceiveData));
			}
		}else { //If communication fails
      		Sys.println("Communication\nnot\npossible");
      	} 
    }

	function onReceiveData(responseCode, data) {
        if(responseCode == 200) {
        		if(cp == null) {
            		cp = new CryptoPrice();
			}
			//Load data from JSON into arrays of USD prices, EUR prices and coin symbols.
			var isFull = true;
         	for( var i = 0; i < 2; i++ ) {
         		if ((cp.curSymbol[i].equals("BTC") && data[0]["symbol"].equals("XBTUSD")) ||
         			(cp.curSymbol[i].equals("ETH") && data[0]["symbol"].equals("ETHUSD"))) {
					cp.curPrice[i] = data[0]["price"].toFloat();
					cp.curTime[i] = data[0]["timestamp"];
				}
				if (cp.curPrice[i] == null) {
					isFull = false;
				}
			}
			if (isFull) {
				for ( var i = 0; i < notify.size(); i++) {
           			notify[i].invoke(cp);
       			}
       			//Ui.requestUpdate();
           	}
        }else { //If error in getting data from JSON API
        		Sys.println("Data request failed\nWith response: ");
        		Sys.println(responseCode);
        }
    }
}
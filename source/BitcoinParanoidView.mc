using Toybox.WatchUi as Ui;
using Toybox.System;
using Toybox.Time;
using Toybox.System as Sys;
using Toybox.Application.Storage;
using Toybox.Timer;

(:glance)
class BitcoinParanoidView extends Ui.View {
	//Fields:
	
	//Time Zone
	hidden var clockTime = System.getClockTime();
	hidden var zone = clockTime.timeZoneOffset / 3600f;
	
	//Communication
	hidden var commConf = false; // Confirm communication
		
	//Data storage
	hidden var mCurrency = ["BTC", "ETH"]; //Initializing array for top 5 currencies
	hidden var mCurPrice = new [2]; //Initializing array for current price of top 5 currencies (USD $)
	hidden var mCurTime = new [2];
	hidden var curCurrencyPrice = new [2];
	//hidden var curCurrencyTime = new [2];
	hidden var oldCurrencyPrice = new [2];
	//hidden var oldCurrencyTime = new [2];
	hidden var myText;
	var bmapDict = {}; //Hash table for storing Bitmaps/drawables
	hidden var options;
	hidden var moment;
	hidden var curUpdate;
	hidden var lastUpdate;
	hidden var diff;
	hidden var ago = "-";
	
	//Graphics parameters
	var dcHeight, dcWidth, dcWidthBM, dcWidthRefresh, dcHeightRefresh; //Device screen dimensions
	hidden var heightSplitter = [8.72, 3.633, 2.29473, 1.67692, 1.32121, 8.72, 3.633, 2.29473, 1.67692, 1.32121, 1.12953, 1.12953]; //For splitting screen height into 5
	hidden var heightSplitter2 = [2.6, 1.8];
	hidden var textFont = Graphics.FONT_TINY; //Font size
	var idx, dh, l; //For draw height function
	
	//For page mode (Changing between page 1 and 2)
	var today, dateString; //, titleStr; //Timestamp variables
	//var pg = 1, k = 0; //Page 0: Top 5, Page 1: Top 5-10. Initially 0.
	var currSymbol; //$/€ Currency iterator and Symbol
	
	//Timer
	var myTimer;
	
	function initialize() {
    	Ui.View.initialize();
    	myTimer = new Timer.Timer();
    	var myMethod = new Lang.Method(Ui, :requestUpdate);
    	myTimer.start(myMethod, 1000, true);
    }

    // Load resources here
    function onLayout(dc) {        
        //Get device screen width and height to avoid too many function calls
		dcHeight = dc.getHeight();
		dcWidth = dc.getWidth()/3; //Divide by tree to right align text
		dcWidthBM = dc.getWidth()/8; //Left align bitmap icons
		dcWidthRefresh = dc.getWidth() - dc.getWidth()/5.5f;
		dcHeightRefresh = dcHeight/5f; 
        
        //Loading coin icons as Bitmaps into hash table
        bmapDict = {
			"BTC" => Ui.loadResource( Rez.Drawables.BTC ),
			"ETH" => Ui.loadResource( Rez.Drawables.ETH ),
		};
    }
		
    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK); //Keep Bg color
        dc.clear();//Clear screen
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK); //Set text color
        drawLastPrice(dc, commConf); //Draw prices and logos on screen
		commConf = false;
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }
    
    // Find height to draw coin icon at
    function drawHeight(dcHeight,i) {
		dh = (dcHeight*(30+i*15)/100)-4; //Base = 23 pixels. Pixel height of logo
		return dh; //Return height to draw logo at
	}
	
	function optionGenerator(string) {
		return {
			:year => string.substring(0, 4).toNumber(),
			:month => string.substring(5, 7).toNumber(),
			:day => string.substring(8, 10).toNumber(),
			:hour => string.substring(11, 13).toNumber(),
			:minute => string.substring(14, 16).toNumber(),
			:second => string.substring(17, 19).toNumber()
		};
	}
	
	function formatDate(time) {
		return Lang.format("$1$:$2$:$3$", [time.hour.format("%02d"), time.min.format("%02d"), time.sec.format("%02d")]); //Create timestamp string
	}
	
	function formatDuration(duration) {
		var hours = (duration / (1000 * 60 * 60));
		var mins = (duration / (1000 * 60)) % 60;
		var seconds = (duration / 1000) % 60;
		
		var durationStr;
		if (hours > 0) {
			durationStr = hours + "h";
		} else if (mins > 0) {
			durationStr = mins + "m";
		} else {
			durationStr = seconds + "s";
		}
		
		return durationStr;
	}
        
    //Draw current prices and logos for top 5 cryptocurrencies
    function drawLastPrice(dc, loaded) {
		//Timestamp of data collection
		var now = Time.now();
		today = Time.Gregorian.info(now, Time.FORMAT_MEDIUM); //Get time
		dateString = formatDate(today);
		
		currSymbol = "$ ";
		
		if (loaded) {
			if (curCurrencyPrice != null) {
				for (var i = 0; i < 2; i++) {
					oldCurrencyPrice[i] = curCurrencyPrice[i];
				}
			}
			if (mCurPrice != null) {
				for (var i = 0; i < 2; i++) {
					curCurrencyPrice[i] = mCurPrice[i];
				}
			}
			/*
			if (curCurrencyTime != null) {
				for (var i = 0; i < 2; i++) {
					oldCurrencyTime[i] = curCurrencyTime[i];
				}
			}
			if (mCurTime != null) {
				for (var i = 0; i < 2; i++) {
					options = optionGenerator(mCurTime[i]);
					curCurrencyTime[i] = Time.Gregorian.moment(options);
				}
			}
			*/
			if (curUpdate != null) {
				lastUpdate = curUpdate;
			}
			curUpdate = Time.now();
		}
		
		if (curUpdate != null) {
			diff = Time.now().subtract(curUpdate).value();
			ago = formatDuration(diff * 1000) + " ago";
		}
		
		//2020-09-13T20:21:49.832Z
		
		/*
		if (curCurrencyTime[0] != null) {
			lastUpdate = curCurrencyTime[0];
			if (curCurrencyTime[1] != null && lastUpdate.lessThan(curCurrencyTime[1])) {
				lastUpdate = curCurrencyTime[1];
			}
			diff = Time.now().subtract(lastUpdate).value();
			ago = formatDuration(diff * 1000) + " ago";
		}
		*/
		
		
		//Draw title (Top)
		dc.drawText(
			dc.getWidth()/2, 
			5, 
			Graphics.FONT_XTINY, 
			dateString, 
			Graphics.TEXT_JUSTIFY_CENTER
		);
		
		//Draw refresh icon
		dc.drawBitmap(
			dcWidthRefresh,
			dcHeightRefresh,
			Ui.loadResource( Rez.Drawables.RefreshIcon )
		);
		
		var interval = Storage.getValue("interval");
		var intervalStr = "Update interval: " + formatDuration(interval);
		
		//Draw update interval
		dc.drawText(
			dc.getWidth()/2, 
			dc.getHeight()*70/100, 
			Graphics.FONT_XTINY, 
			intervalStr,
			Graphics.TEXT_JUSTIFY_CENTER
		);
		
		dc.drawText(
			dc.getWidth()/2, 
			dc.getHeight()*80/100, 
			Graphics.FONT_XTINY, 
			"Last Update:",
			Graphics.TEXT_JUSTIFY_CENTER
		);
		
		//Draw timestamp (Bottom)
		dc.drawText(
			dc.getWidth()/2, 
			dc.getHeight()*90/100, 
			Graphics.FONT_XTINY, 
			ago, 
			Graphics.TEXT_JUSTIFY_CENTER
		);
		
		for( var i = 0; i < 2; i++ ) {
			//Draw symbol and price for each coin
			var price = "Updating...";
			if (curCurrencyPrice[i] != null) {
				price = currSymbol + curCurrencyPrice[i];
				if (oldCurrencyPrice[i] != null) {
					if (oldCurrencyPrice[i].toDouble() < curCurrencyPrice[i].toDouble()) {
						dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_BLACK);
					} else if (oldCurrencyPrice[i].toDouble() > curCurrencyPrice[i].toDouble()) {
						dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_BLACK);
					}
				}
			}
			dc.drawText(
    			dcWidth, 
    			dcHeight*(30+i*15)/100, 
    			textFont,
    			price,
    			Graphics.TEXT_JUSTIFY_LEFT
    		);
    		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
   			//Draw icons for each coin	
			drawIcon(dc, mCurrency[i]); //Call draw icon function
		}
    		
    }
    
    //Draw icon using hashtable of bitmaps.
    //Find the index/position of coin, then draw bitmap to the left of the coin symbol + price.
    function drawIcon(dc, str) {
		if (mCurrency.indexOf(str) != -1) { //Make sure currency exists
			idx = mCurrency.indexOf(str); //Find index of currency
			if (bmapDict.hasKey(str) != false) { //Make sure currency icon exists
				dc.drawBitmap( dcWidthBM, drawHeight(dcHeight, idx), bmapDict.get(str) ); //Draw bitmap
			}
		}
    }
    
    //Get prices and save symbol and price array
    function onPrice(cp) {
        if (cp instanceof CryptoPrice) {        	
			
			//Get prices and coins, and save in array
			for( var i = 0; i < 2; i++ ) {
				mCurPrice[i] = cp.curPrice[i].format("%.2f");
				mCurTime[i] = cp.curTime[i];
				//mCurrency[i] = cp.curSymbol[i];
			}
    		//If current prices are fetched, communication is confirmed. By default, false.
    		if (mCurPrice[0] != null) {
    			commConf = true;
    		}
        	//If data is not fetched yet, throw waiting for data msg.
        }else if (cp instanceof Lang.String) {
        		commConf = false;
       	}
        //Ui.requestUpdate(); //Request an update
    }

}


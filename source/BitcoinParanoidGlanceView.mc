using Toybox.WatchUi as Ui;
using Toybox.System;
using Toybox.Time.Gregorian;
using Toybox.System as Sys;

(:glance)
class BitcoinParanoidGlanceView extends Ui.GlanceView {
	
	hidden var bmapArr;
	
    function initialize(bmap) {
		Ui.GlanceView.initialize();
		bmapArr = bmap;
    }
    
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
	hidden var curCurrencyTime = new [2];
	hidden var oldCurrencyPrice = new [2];
	
	//Graphics parameters
	var dcHeight, dcWidth, dcWidthBM, dcWidthRefresh, dcHeightRefresh; //Device screen dimensions
	hidden var textFont = Graphics.FONT_GLANCE; //Font size
	var idx, dh, l; //For draw height function
	
	//For page mode (Changing between page 1 and 2)
	var today, dateString; //, titleStr; //Timestamp variables
	var currSymbol; //$/€ Currency iterator and Symbol
	
    // Load resources here
    function onLayout(dc) {        
        //Get device screen width and height to avoid too many function calls
		dcHeight = dc.getHeight();
		dcWidth = dc.getWidth()/4; //Divide by tree to right align text
		dcWidthBM = 0; //Left align bitmap icons
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
        //dc.drawRectangle(0, 0, dc.getWidth(), dc.getHeight());
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
		dh = ((dcHeight / 2) * i) + 2; //Base = 23 pixels. Pixel height of logo
		return dh; //Return height to draw logo at
	}    
        
    //Draw current prices and logos for top 5 cryptocurrencies
    function drawLastPrice(dc, loaded) {
		//Timestamp of data collection
		dateString = "-";
		if (curCurrencyTime[0] != null) {
			today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM); //Get time
			dateString = Lang.format("$1$:$2$:$3$", [today.hour.format("%02d"), today.min.format("%02d"), today.sec.format("%02d")]); //Create timestamp string
		}
		
		currSymbol = "$ ";
		
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
		curCurrencyTime = mCurTime;
		
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
    			((dcHeight/2) * i) + 6, 
    			textFont,
    			price,
    			Graphics.TEXT_JUSTIFY_LEFT
    		);
    		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
   			//Draw icons for each coin	
			drawIcon(dc, i); //Call draw icon function
		}
    		
    }
    
    //Draw icon using hashtable of bitmaps.
    //Find the index/position of coin, then draw bitmap to the left of the coin symbol + price.
    function drawIcon(dc, idx) {
    	dc.drawBitmap( dcWidthBM, drawHeight(dcHeight, idx), Ui.loadResource(bmapArr[idx])); //Draw bitmap
    }
    
    //Get prices and save symbol and price array
    function onPrice(cp) {
        if (cp instanceof CryptoPrice) {        	
			
			//cp.makePriceRequests();
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


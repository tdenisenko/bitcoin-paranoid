using Toybox.Application as App;

class BitcoinParanoidApp extends App.AppBase {

    hidden var View;
	hidden var Model;
    hidden var Delegate;
    hidden var GlanceView;
    hidden var GlanceModel;
    hidden var GlanceDelegate;
    hidden var bmapArr = new [2];
    
    function initialize() {
    	App.AppBase.initialize();
    	bmapArr[0] = 70; //Rez.Drawables.BTC;
    	bmapArr[1] = 1116; //Rez.Drawables.ETH;
    }
    
    //Called on application start up
    function onStart(state) {
    		GlanceView = new BitcoinParanoidGlanceView(bmapArr);
    		//GlanceModel = new PriceModel(GlanceView.method(:onPrice));
    		View = new BitcoinParanoidView();
			//Model = new PriceModel(View.method(:onPrice));
			Model = new PriceModel([GlanceView.method(:onPrice), View.method(:onPrice)]); 
			GlanceDelegate = new CryptoPricesDelegate(Model);
			Delegate = new CryptoPricesDelegate(Model);
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    	Model.myTimer.stop();
    }

    // Return the initial view of your application here
    
    (:glance)
    function getInitialView() {
        return [ View, Delegate ];
    }
    
    // Return glance view
    (:glance)
    function getGlanceView() {
        return [ GlanceView ];
    }

}
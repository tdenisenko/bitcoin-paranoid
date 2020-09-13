using Toybox.WatchUi as Ui;

(:glance)
class CryptoPricesDelegate extends Ui.BehaviorDelegate {

	hidden var Model;
	
    function initialize(priceModel) {
    	Ui.BehaviorDelegate.initialize();
		Model = priceModel;
    }

    function onSelect() { //When Select is pressed, update and change page view.
        Model.resetTimer();
        Ui.requestUpdate();
    	//Model.makePriceRequests();
    }
}
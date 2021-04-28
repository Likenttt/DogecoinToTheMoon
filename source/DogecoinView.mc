using Toybox.WatchUi;
using Toybox.Communications;
using Toybox.Graphics;

class DogecoinView extends WatchUi.View {

    hidden var priceLabel;
    hidden var currencyType = "cny";
    hidden var priceDict;
    hidden var util;
    hidden var result;
    hidden var fetchResult = false;
    hidden var networkReachable = false;
    hidden var urlTemplate = "https://api.coingecko.com/api/v3/simple/price?ids=dogecoin&vs_currencies=$1$&include_24hr_change=true";
    hidden var marketDataDict;
    hidden var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
            :headers => {
                "accept" => "application/json"
            }
        };


    function initialize() {
        View.initialize();
        fetchPrice();

    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
        
    }

    // Update the view
    function onUpdate(dc) {
        // dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        View.onUpdate(dc);
        if(fetchResult){
            dc.drawText(dc.getWidth()/2,dc.getHeight()/2,
                        Graphics.FONT_NUMBER_THAI_HOT,
                        (marketDataDict[currencyType]).format("%0.2f"),
                        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            fetchResult = false;

        }else{
            dc.drawText(dc.getWidth()/2,dc.getHeight()/2,
                        Graphics.FONT_NUMBER_THAI_HOT,
                        "...",
                        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            fetchResult = false;

        }
        // Call the parent onUpdate function to redraw the layout
    }

    

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    function fetchPrice(){

        Communications.makeWebRequest(
            "https://api.coingecko.com/api/v3/ping",
            {},
            options,
            method(:onPingReceive)
        );
    }

    function onPingReceive(responseCode, data){
        System.print("-------onPingReceive------");

        System.print("responseCode:"+responseCode);
        System.print("data:"+data);


        if (responseCode == 200) {
            networkReachable = true;
            System.print("networkReachable:"+networkReachable);
            Communications.makeWebRequest(
                Lang.format(urlTemplate, [currencyType]),
                {},
                options,
                method(:onReceive)
            );
        }else{
            networkReachable = false;
            System.print("The network is not reachable!");
        }
    }

    

    function onReceive(responseCode, data) {
        System.print("-------onReceive------");
        System.print(responseCode);
        System.print(data);
        if (responseCode == 200) {
            fetchResult = true;
            System.print(data);
            marketDataDict = data["dogecoin"];
            WatchUi.requestUpdate();
        } else {
            fetchResult = false;
        }
    }



}

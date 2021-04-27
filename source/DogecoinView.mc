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
    hidden var marketDataDict = {
      "aed"=>-1,
      "ars"=>-1,
      "aud"=>-1,
      "bch"=>-1,
      "bdt"=>-1,
      "bhd"=>-1,
      "bmd"=>-1,
      "bnb"=>-1,
      "brl"=>-1,
      "btc"=>-1,
      "cad"=>-1,
      "chf"=>-1,
      "clp"=>-1,
      "cny"=>-1,
      "czk"=>-1,
      "dkk"=>-1,
      "dot"=>-1,
      "eos"=>-1,
      "eth"=>-1,
      "eur"=>-1,
      "gbp"=>-1,
      "hkd"=>-1,
      "huf"=>-1,
      "idr"=>-1,
      "ils"=>-1,
      "inr"=>-1,
      "jpy"=>-1,
      "krw"=>-1,
      "kwd"=>-1,
      "lkr"=>-1,
      "ltc"=>-1,
      "mmk"=>-1,
      "mxn"=>-1,
      "myr"=>-1,
      "ngn"=>-1,
      "nok"=>-1,
      "nzd"=>-1,
      "php"=>-1,
      "pkr"=>-1,
      "pln"=>-1,
      "rub"=>-1,
      "sar"=>-1,
      "sek"=>-1,
      "sgd"=>-1,
      "thb"=>-1,
      "try"=>-1,
      "twd"=>-1,
      "uah"=>-1,
      "usd"=>-1,
      "vef"=>-1,
      "vnd"=>-1,
      "xag"=>-1,
      "xau"=>-1,
      "xdr"=>-1,
      "xlm"=>-1,
      "xrp"=>-1,
      "yfi"=>-1,
      "zar"=>-1,
      "bits"=>-1,
      "link"=>-1,
      "sats"=>-1
    };


    function initialize() {
        View.initialize();
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
        dc.drawText(dc.getWidth()/2,dc.getHeight()/2,
        	 			Graphics.FONT_NUMBER_THAI_HOT,
                        "-",
                        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        if(networkReachable){
            fetchPrice();
            if(fetchResult){
                dc.clear();
                System.print(marketDataDict);
                dc.drawText(dc.getWidth()/2,dc.getHeight()/2,
                            Graphics.FONT_NUMBER_THAI_HOT,
                            (marketDataDict[currencyType]).toString(),
                            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            }
        }

        View.onUpdate(dc);
        // Call the parent onUpdate function to redraw the layout
    }

    

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    function fetchPrice(){
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
            :headers => {
                "accept" => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
            }
        };

        Communications.makeWebRequest(
            "https://api.coingecko.com/api/v3/ping",
            {},
            options,
            method(:onPingReceive)
        );
        if(!networkReachable){
            return;
        }
        Communications.makeWebRequest(
            "https://api.coingecko.com/api/v3/coins/dogecoin?tickers=false&market_data=true&community_data=false&developer_data=false&sparkline=false",
            {},
            options,
            method(:onReceive)
        );
    }

    function onPingReceive(responseCode, data){
        if (responseCode == 200) {
            networkReachable = true;
        }else{
            networkReachable = false;
        }
    }

    

    function onReceive(responseCode, data) {
        System.print(responseCode);
        System.print(data);
        if (responseCode == 200) {
            fetchResult = true;
            System.print(data);
            marketDataDict = data["market_data"]["current_price"];
        } else {
            fetchResult = false;
        }
    }



}

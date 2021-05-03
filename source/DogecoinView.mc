using Toybox.WatchUi;
using Toybox.Communications;
using Toybox.Graphics;
using Toybox.Time;
using Toybox.Time.Gregorian;

class DogecoinView extends WatchUi.View {

    hidden var priceLabel;
    hidden var currencyType = "cny";
    hidden var priceDict;
    hidden var util;
    hidden var result;
    hidden var fetchResult = false;
    hidden var networkReachable = false;
    hidden var urlTemplate = "https://api.coingecko.com/api/v3/simple/price?ids=dogecoin&vs_currencies=$1$&include_24hr_change=true";
    hidden var priceApi = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=$1$&ids=dogecoin&order=market_cap_desc&per_page=100&page=1&sparkline=false&price_change_percentage=1h%2C24h";
    hidden var marketDataDict;
    hidden var priceChangePercentage1hKey = "price_change_percentage_1h_in_currency";
    hidden var priceChangePercentage24hKey = "price_change_percentage_24h_in_currency";
    hidden var lastUpdatedTimeKey = "last_updated";
    hidden var currentPriceKey = "current_price";
    hidden var priceHigh24hKey= "high_24h";
    hidden var priceLow24hKey = "low_24h";
    const ChineseUpColorDict = {true => Graphics.COLOR_RED,false => Graphics.COLOR_GREEN}; 
    //In Chinese mainland, red indicates up.
    hidden var redUpGreenDown = true;
    hidden var highest24hString;
    hidden var lowest24hString;
    hidden var updatedString;
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
        highest24hString = WatchUi.loadResource(Rez.Strings.highest24Label);
        lowest24hString = WatchUi.loadResource(Rez.Strings.lowest24Label);
        updatedString = WatchUi.loadResource(Rez.Strings.updatedLabel);
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


    //{
    //     "id": "dogecoin",
    //     "symbol": "doge",
    //     "name": "Dogecoin",
    //     "image": "https://assets.coingecko.com/coins/images/5/large/dogecoin.png?1547792256",
    //     "current_price": 2.51,
    //     "market_cap": 325499286424,
    //     "market_cap_rank": 6,
    //     "fully_diluted_valuation": null,
    //     "total_volume": 42183254513,
    //     "high_24h": 2.54,
    //     "low_24h": 2.39,
    //     "price_change_24h": 0.109548,
    //     "price_change_percentage_24h": 4.56384,
    //     "market_cap_change_24h": 13888575328,
    //     "market_cap_change_percentage_24h": 4.45703,
    //     "circulating_supply": 129433561915.491,
    //     "total_supply": null,
    //     "max_supply": null,
    //     "ath": 2.73,
    //     "ath_change_percentage": -7.7161,
    //     "ath_date": "2021-04-19T11:04:20.126Z",
    //     "atl": 0.00053661,
    //     "atl_change_percentage": 468545.1273,
    //     "atl_date": "2015-05-06T00:00:00.000Z",
    //     "roi": null,
    //     "last_updated": "2021-05-03T08:27:20.641Z",
    //     "price_change_percentage_1h_in_currency": 0.6878196956697009,
    //     "price_change_percentage_24h_in_currency": 4.563837247877844
    //   }

    // Update the view
    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        View.onUpdate(dc);
        if(fetchResult){
            //current price
            dc.drawText(dc.getWidth()/2,dc.getHeight()/2,
                        Graphics.FONT_NUMBER_THAI_HOT,
                        (marketDataDict[currentPriceKey]).format("%0.2f"),
                        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            
            dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_TRANSPARENT);
            dc.drawText(dc.getWidth()/2 + 85,dc.getHeight()/2-25,
                    Graphics.FONT_SYSTEM_XTINY,
                    "1H",
                    Graphics.TEXT_JUSTIFY_CENTER); 
            dc.drawText(dc.getWidth()/2 + 85,dc.getHeight()/2+3,
                    Graphics.FONT_SYSTEM_XTINY,
                    "24H",
                    Graphics.TEXT_JUSTIFY_CENTER);
            var changeRate1h = (marketDataDict[priceChangePercentage1hKey]).toFloat();
            var changeRate24h = (marketDataDict[priceChangePercentage24hKey]).toFloat();
            System.print("changeRate1h is:"+changeRate1h);
            System.print("changeRate24h is:"+changeRate24h);

            var color;
            if(redUpGreenDown){
                color = ChineseUpColorDict[changeRate1h >= 0];
                dc.setColor(color,Graphics.COLOR_TRANSPARENT);
                dc.drawText(dc.getWidth()/2 + 70,dc.getHeight()/2-12,
                        Graphics.FONT_SYSTEM_XTINY,
                        (changeRate1h>=0?"+":"")+changeRate1h.format("%0.2f")+"%",
                        Graphics.TEXT_JUSTIFY_LEFT );
                color = ChineseUpColorDict[changeRate24h >= 0];
                dc.setColor(color,Graphics.COLOR_TRANSPARENT);
                dc.drawText(dc.getWidth()/2 + 70,dc.getHeight()/2+15,
                        Graphics.FONT_SYSTEM_XTINY,
                        (changeRate24h >= 0?"+":"")+changeRate24h.format("%0.2f")+"%",
                        Graphics.TEXT_JUSTIFY_LEFT);
            }else{ 
                color = ChineseUpColorDict[changeRate1h <= 0];
                dc.setColor(color,Graphics.COLOR_TRANSPARENT);
                dc.drawText(dc.getWidth()/2 + 70,dc.getHeight()/2-10,
                        Graphics.FONT_SYSTEM_XTINY,
                        (changeRate1h>=0?"+":"")+changeRate1h+"%",
                        Graphics.TEXT_JUSTIFY_LEFT);
                color = ChineseUpColorDict[changeRate24h<=0];
                dc.setColor(color,Graphics.COLOR_TRANSPARENT);
                dc.drawText(dc.getWidth()/2 + 70,dc.getHeight()/2+15,
                        Graphics.FONT_SYSTEM_XTINY,
                        (changeRate24h>=0?"+":"")+changeRate24h+"%",
                        Graphics.TEXT_JUSTIFY_LEFT);                
            }
            //currency type
            dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_TRANSPARENT);
            dc.drawText(dc.getWidth()/2 - 80,
                        dc.getHeight()/2 + 20,
                        Graphics.FONT_SYSTEM_XTINY,
                        currencyType.toUpper(),
                        Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
            
            //24 high 
            dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_TRANSPARENT);
            dc.drawText(dc.getWidth()/2,dc.getHeight()/2 - 35,
                        Graphics.FONT_SYSTEM_XTINY,
                        highest24hString+ (marketDataDict[priceHigh24hKey]).format("%0.2f"),
                        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            
            //24 low
            dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_TRANSPARENT);
            dc.drawText(dc.getWidth()/2,dc.getHeight()/2 + 40,
                        Graphics.FONT_SYSTEM_XTINY,
                        lowest24hString+ (marketDataDict[priceLow24hKey]).format("%0.2f"),
                        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            
            //update time
            dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_TRANSPARENT);
            // var lastUpdateTime = marketDataDict[lastUpdatedTimeKey];
            // //2021-05-03T08:27:20.641Z
            // var options = {
            //     :year   => lastUpdateTime.substring(0, 4).toNumber(),
            //     :month  => lastUpdateTime.substring(5, 7).toNumber(),
            //     :day    => lastUpdateTime.substring(8, 10).toNumber(),
            //     :hour   => lastUpdateTime.substring(12, 14).toNumber(),
            //     :minute => lastUpdateTime.substring(15, 17).toNumber(),
            //     :second => lastUpdateTime.substring(18, 20).toNumber()
            // };
            // var now = Gregorian.moment(options);
            // var info = Gregorian.utcInfo(now, Time.FORMAT_SHORT);
            var myTime = System.getClockTime(); // ClockTime object
            dc.drawText(dc.getWidth()/2,dc.getHeight()/2 + 55,
                        Graphics.FONT_SYSTEM_XTINY,
                        updatedString+ myTime.hour.format("%02d") + ":" +myTime.min.format("%02d") + ":" + myTime.sec.format("%02d"),
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
                Lang.format(priceApi, [currencyType]),
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
            marketDataDict = data[0];
            WatchUi.requestUpdate();
        } else {
            fetchResult = false;
        }
    }



}

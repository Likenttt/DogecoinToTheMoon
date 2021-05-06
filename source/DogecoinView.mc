using Toybox.WatchUi;
using Toybox.Communications;
using Toybox.Graphics;
using Toybox.Time;
using Toybox.Time.Gregorian;

class DogecoinView extends WatchUi.View {

    hidden var priceLabel;
    hidden var currencyType = "usd";
    hidden var priceDict;
    hidden var util;
    hidden var result;
    hidden var fetchResult = false;
    hidden var networkReachable = false;
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
    hidden var currencyTypeDict = {0 => "cny",1 => "usd",2 => "jpy", 3 => "eur"};


    function initialize() {
        View.initialize();
        var currencyTypeNumber = Application.getApp().getProperty("currencyType");
        System.print("currency Type is: " + currencyType);
        if(null != currencyTypeNumber){
            currencyType = currencyTypeDict[currencyTypeNumber];
        }
        System.print("currency Type is: " + currencyType);
        var upDownColor = Application.getApp().getProperty("redUpGreenDown");
        if(null != upDownColor && upDownColor == 1){
            redUpGreenDown = false;
        }
        // redUpGreenDown = true;
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
            var priceStr = (marketDataDict[currentPriceKey]).format("%0.2f");
            dc.drawText(dc.getWidth()/2,dc.getHeight()/2,
                        Graphics.FONT_NUMBER_THAI_HOT,
                        priceStr,
                        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            var priceStrWidth = dc.getTextWidthInPixels(priceStr,Graphics.FONT_NUMBER_THAI_HOT);
            var priceFontHeight = Graphics.getFontHeight(Graphics.FONT_NUMBER_THAI_HOT);
            var xtinyFontHeight = Graphics.getFontHeight(Graphics.FONT_SYSTEM_XTINY);
            var xtinyFontDescent = Graphics.getFontDescent(Graphics.FONT_SYSTEM_XTINY);
            var priceStrDescent = Graphics.getFontDescent(Graphics.FONT_NUMBER_THAI_HOT);
            System.print("priceStrDescent is:"+priceStrDescent);


            var changeRate1h = (marketDataDict[priceChangePercentage1hKey]).toFloat();
            var changeRate24h = (marketDataDict[priceChangePercentage24hKey]).toFloat();
            System.print("changeRate1h is:"+changeRate1h);
            System.print("changeRate24h is:"+changeRate24h);

            var oneHStrWidth = dc.getTextWidthInPixels("1H(%)",Graphics.FONT_SYSTEM_XTINY);

            dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_TRANSPARENT);
            dc.drawText(dc.getWidth()/2 - priceStrWidth/2 - oneHStrWidth/2,
                    dc.getHeight()/2 - xtinyFontHeight + xtinyFontDescent,
                    Graphics.FONT_SYSTEM_XTINY,
                    "1H(%)",
                    Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);

            var twenty4HStrWidth = dc.getTextWidthInPixels("24H(%)",Graphics.FONT_SYSTEM_XTINY);

            dc.drawText(dc.getWidth()/2 + priceStrWidth/2 + twenty4HStrWidth/2,
                    dc.getHeight()/2 - xtinyFontHeight + xtinyFontDescent,
                    Graphics.FONT_SYSTEM_XTINY,
                    "24H(%)",
                    Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
            var changeRate1hColor;
            var changeRate24hColor;
            if(redUpGreenDown){
                changeRate1hColor = ChineseUpColorDict[changeRate1h >= 0];
                changeRate24hColor = ChineseUpColorDict[changeRate24h >= 0];
            }else{ 
                changeRate1hColor = ChineseUpColorDict[changeRate1h <= 0];
                changeRate24hColor = ChineseUpColorDict[changeRate24h<=0];
            }

            var changeRate1hStr = (changeRate1h>=0?"+":"")+changeRate1h.format("%0.2f");
            var changeRate1hStrFontWidth = dc.getTextWidthInPixels(changeRate1hStr,Graphics.FONT_SYSTEM_XTINY);
 
            dc.setColor(changeRate1hColor,Graphics.COLOR_TRANSPARENT);
            dc.drawText(dc.getWidth()/2 - priceStrWidth/2 - oneHStrWidth/2 - 5,
                        dc.getHeight()/2 ,
                        Graphics.FONT_SYSTEM_XTINY,
                        changeRate1hStr,
                        Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);

            var changeRate24hStr = (changeRate24h>=0?"+":"")+changeRate24h.format("%0.2f");
            var changeRate24hStrFontWidth = dc.getTextWidthInPixels(changeRate24hStr,Graphics.FONT_SYSTEM_XTINY);
            dc.setColor(changeRate24hColor,Graphics.COLOR_TRANSPARENT);
            dc.drawText(dc.getWidth()/2 + priceStrWidth/2 + changeRate24hStrFontWidth/2,
                        dc.getHeight()/2,
                        Graphics.FONT_SYSTEM_XTINY,
                        changeRate24hStr,
                        Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);                
            
            //currency type
            var currencyTypeStr = currencyType.toUpper();
            var currencyTypeStrWidth = dc.getTextWidthInPixels(currencyTypeStr,Graphics.FONT_SYSTEM_XTINY);
            dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_TRANSPARENT);
            dc.drawText(dc.getWidth()/2 - priceStrWidth/2 - currencyTypeStrWidth/2 - 5,
                        dc.getHeight()/2 + priceFontHeight/2 - priceStrDescent - xtinyFontHeight/2 + 5,
                        Graphics.FONT_SYSTEM_XTINY,
                        currencyTypeStr,
                        Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
            
            //24 high 
            dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_TRANSPARENT);
            dc.drawText(dc.getWidth()/2,
                        dc.getHeight()/2 - priceFontHeight/2 + priceStrDescent - xtinyFontHeight/2,
                        Graphics.FONT_SYSTEM_XTINY,
                        highest24hString+ (marketDataDict[priceHigh24hKey]).format("%0.2f"),
                        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            
            //24 low
            dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_TRANSPARENT);
            dc.drawText(dc.getWidth()/2,
                        dc.getHeight()/2 + priceFontHeight/2 - priceStrDescent + xtinyFontHeight/2,
                        Graphics.FONT_SYSTEM_XTINY,
                        lowest24hString+ (marketDataDict[priceLow24hKey]).format("%0.2f"),
                        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            
            //update time
            dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_TRANSPARENT);
            var myTime = System.getClockTime(); // ClockTime object
            dc.drawText(dc.getWidth()/2,
                        dc.getHeight()/2 + priceFontHeight/2 - priceStrDescent + 10 + xtinyFontHeight,
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
                Lang.format(priceApi, [currencyType]),
                {},
                options,
                method(:onReceive)
        );
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

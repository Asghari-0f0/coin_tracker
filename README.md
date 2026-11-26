
# Coin Tracker Challenge
You may follow the TODOs created in the code to complete the challenge.

### CoinAPI setup
The app loads BTC, ETH, and LTC exchange rates from CoinAPI. Create an API key
and run the app with:

```shell
flutter run --dart-define=COIN_API_KEY=your_api_key
```

The key is passed to the app at build time, so it can still be extracted from
a distributed client app. For production, proxy CoinAPI requests through a
backend instead of embedding a private key in the mobile app.

### End Result Screenshots
#### iOS
<img src="https://github.com/Aalem/coin-tracker-starting-project/blob/master/screenshot_ios.png" width="400"/>

#### Android
<img src="https://github.com/Aalem/coin-tracker-starting-project/blob/master/screenshot_android.png" width="400"/>

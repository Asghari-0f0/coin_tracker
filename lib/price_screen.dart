import 'package:coin_tracker/models/coin_model.dart';
import 'package:coin_tracker/utilities/coin_data.dart';
import 'package:coin_tracker/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PriceScreen extends StatefulWidget {
  @override
  _PriceScreenState createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  String selectedCurrency = 'USD';
  final CoinData _coinData = CoinData();
  List<CoinModel> coinsList = [];
  bool isLoading = false;
  String? errorMessage;
  int _requestId = 0;
  late final FixedExtentScrollController _currencyPickerController;

  @override
  void initState() {
    super.initState();
    _currencyPickerController = FixedExtentScrollController(
      initialItem: currenciesList.indexOf(selectedCurrency),
    );
    getCoinsValue();
  }

  @override
  void dispose() {
    _currencyPickerController.dispose();
    super.dispose();
  }

  Future<void> getCoinsValue() async {
    final requestId = ++_requestId;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await _coinData.getCoinData(selectedCurrency);
      if (!mounted || requestId != _requestId) return;
      setState(() {
        coinsList = data;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        errorMessage = 'Could not load prices: $error';
        isLoading = false;
      });
    }
  }

  CupertinoPicker getCupertinoPicker() {
    List<Text> pickerItems = [];
    for (String currency in currenciesList) {
      pickerItems.add(Text(currency));
    }
    return CupertinoPicker(
      itemExtent: 32,
      onSelectedItemChanged: (selectedIndex) {
        final currency = currenciesList[selectedIndex];
        if (currency == selectedCurrency) return;
        setState(() {
          selectedCurrency = currency;
        });
        getCoinsValue();
      },
      scrollController: _currencyPickerController,
      children: pickerItems,
    );
  }

  InputDecorator getDropdownButton() {
    List<DropdownMenuItem<String>> dropdownItems = [];
    for (String currency in currenciesList) {
      var newItem = DropdownMenuItem(
        child: Text(currency),
        value: currency,
      );
      dropdownItems.add(newItem);
    }

    return InputDecorator(
      decoration: const InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          isExpanded: true,
          value: selectedCurrency,
          items: dropdownItems,
          onChanged: (value) {
            if (value == null || value == selectedCurrency) return;
            setState(() {
              selectedCurrency = value;
            });
            getCoinsValue();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
                flex: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('images/coin.png', width: 100),
                    const SizedBox(height: 16),
                    const Text(
                      'Coin Tracker',
                      style: TextStyle(fontSize: 28),
                    ),
                  ],
                )),
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  if (errorMessage != null && coinsList.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  if (isLoading && coinsList.isNotEmpty)
                    const LinearProgressIndicator(),
                  Expanded(
                    child: coinsList.isEmpty
                        ? Center(
                            child: isLoading
                                ? const CircularProgressIndicator()
                                : Column(
                                    mainAxisSize: MainAxisSize.min,
                                   children: [
                                      Text(
                                        errorMessage ??
                                             'No prices are available.',
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      TextButton(
                                        onPressed: getCoinsValue,
                                        child: const Text('Try again'),
                                      ),
                                    ],
                                  ),
                          )
                        : ListView.separated(
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                leading: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      'images/${coinsList[index].icon}.png',
                                      width: 60,
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      children: [
                                        const Text('1',
                                            style: TextStyle(fontSize: 18)),
                                        Text(
                                          coinsList[index].name,
                                          style: const TextStyle(
                                              color: Colors.white24),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      NumberFormat("#,###.0")
                                          .format(coinsList[index].price),
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    Text(
                                      selectedCurrency,
                                      style: const TextStyle(
                                          color: Colors.white24),
                                    ),
                                  ],
                                ),
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const Divider(),
                            itemCount: coinsList.length,
                          ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: isIOS ? 0 : 8),
              height: isIOS ? 150 : 60,
              child: isIOS ? getCupertinoPicker() : getDropdownButton(),
            ),
          ],
        ),
      ),
    );
  }
}

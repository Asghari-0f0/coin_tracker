import 'dart:convert';
import 'package:coin_tracker/utilities/coin_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() { 
  test('fetches and parses a price for each coin', () async {
    final client = _CoinApiClient();
    final prices =
        await CoinData(client: client, apiKey: 'test-key').getCoinData('ILS');

    expect(
      client.requests.map((request) => request.url.path).toList(),
      [
        '/v1/exchangerate/BTC/ILS',
        '/v1/exchangerate/ETH/ILS',
        '/v1/exchangerate/LTC/ILS',
      ],
    );
    expect(
      client.requests.every(
        (request) => request.headers['X-CoinAPI-Key'] == 'test-key',
      ),
      isTrue,
    );
    expect(prices.map((coin) => coin.icon).toList(), ['btc', 'eth', 'ltc']);
    expect(prices.map((coin) => coin.name).toList(), [
      'Bitcoin',
      'Ethereum',
      'Litecoin',
    ]);
    expect(prices.map((coin) => coin.price).toList(), [100.0, 20.0, 5.0]);
  });

  test('requires an API key', () async {
    final client = _CoinApiClient();

    await expectLater(
      CoinData(client: client, apiKey: '').getCoinData('ILS'),
      throwsStateError,
    );
    expect(client.requests, isEmpty);
  });

  test('reports invalid CoinAPI authentication clearly', () async {
    final client = _CoinApiClient(statusCode: 401);

    await expectLater(
      CoinData(client: client, apiKey: 'invalid-key').getCoinData('USD'),
      throwsA(
        isA<StateError>().having(
          (error) => error.toString(),
          'message',
          contains('HTTP 401'),
        ),
      ),
    );
  });
}

class _CoinApiClient extends http.BaseClient {
  final List<http.BaseRequest> requests = [];
  final int statusCode;
  final Map<String, double> _prices = {
    'BTC': 100,
    'ETH': 20,
    'LTC': 5,
  };

  _CoinApiClient({this.statusCode = 200});

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requests.add(request);
    final symbol = request.url.pathSegments[2];
    return http.StreamedResponse(
      Stream.value(utf8.encode(jsonEncode({'rate': _prices[symbol]}))),
      statusCode,
      request: request,
    );
  }
}

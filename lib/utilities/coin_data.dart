import 'dart:convert';
import 'package:coin_tracker/constants.dart';
import 'package:coin_tracker/models/coin_model.dart';
import 'package:http/http.dart' as http;

class CoinData {
  final http.Client? _client;
  final String _apiKey;

  CoinData({http.Client? client, String apiKey = kAPIKey})
      : _client = client,
        _apiKey = apiKey.trim();

  Future<List<CoinModel>> getCoinData(String currency) async {
    if (_apiKey.isEmpty) {
      throw StateError(
        'CoinGecko API key is missing.',
      );
    }

    final List<CoinModel> cryptoPrices = [];
    final client = _client ?? http.Client();
    
    final fiat = currency.toLowerCase();
    
    final uri = Uri.parse(
      '$kBaseURL/simple/price?ids=bitcoin,ethereum,litecoin&vs_currencies=$fiat&x_cg_demo_api_key=$_apiKey'
    );

    try {
      final response = await client.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        if (response.statusCode == 401) {
          throw StateError('CoinGecko authentication failed (HTTP 401). Your API key is invalid.');
        }
        if (response.statusCode == 429) {
          throw StateError('CoinGecko rate limit reached (HTTP 429). Try again later.');
        }
        throw Exception('CoinGecko returned HTTP ${response.statusCode}.');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid response format received from server.');
      }

      if (decoded['bitcoin'] != null && decoded['bitcoin'][fiat] != null) {
        cryptoPrices.add(CoinModel(
          icon: 'btc',
          name: 'Bitcoin',
          price: (decoded['bitcoin'][fiat] as num).toDouble(),
        ));
      }

      if (decoded['ethereum'] != null && decoded['ethereum'][fiat] != null) {
        cryptoPrices.add(CoinModel(
          icon: 'eth',
          name: 'Ethereum',
          price: (decoded['ethereum'][fiat] as num).toDouble(),
        ));
      }

      if (decoded['litecoin'] != null && decoded['litecoin'][fiat] != null) {
        cryptoPrices.add(CoinModel(
          icon: 'ltc',
          name: 'Litecoin',
          price: (decoded['litecoin'][fiat] as num).toDouble(),
        ));
      }

    } finally {
      if (_client == null) {
        client.close();
      }
    }

    return cryptoPrices;
  }
}

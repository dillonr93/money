/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import '../money.dart';
import 'exchange_rate.dart';

typedef _CodePair = String;

/// The [ExchangePlatform] allows you to register a set of [ExchangeRate]
/// which you can then use to do currency conversions.
///
/// We allow multiple [ExchangePlatform]s to exist to reflect
/// the fact that there multiple exchanges around the world.
///
/// To use an [ExchangePlatform] call register for each exchange rate.
/// If you only provide an exchange rate in one direction (AUD -> USD)
/// then it will calculate the inverse exchange rate if required.
/// In the real world you will probably need to provide exchange rates
/// in both directions as they are rarely the recipricol of each other.
class ExchangePlatform {
  final exchangeMap = <_CodePair, ExchangeRate>{};

  /// Register an exchange rate with this platform.
  void register(ExchangeRate exchangeRate) {
    exchangeMap[_generate(exchangeRate.fromCurrency.isoCode,
        exchangeRate.toCurrency.isoCode)] = exchangeRate;
  }

  /// Converts [from] to the [to] currency using
  /// a regisetered exhange rate.
  ///
  /// If no exchange exists but an inverted rate exists
  /// then the inverted rate will be used unless [useInversion] is false.
  ///
  /// If no exchange can be calculated an [UnknownExchangeRateException]
  /// will be thrown.
  Money exchangeTo(Money from, CurrencyIsoCode to, {bool useInversion = true}) {
    var exchangeRate = exchangeMap[_generate(from.currency.isoCode, to)];

    if (exchangeRate != null) {
      return exchangeRate.applyRate(from);
    }

    /// try the inverse isoCode pair
    exchangeRate = exchangeMap[_generate(
      to,
      from.currency.isoCode,
    )];

    if (exchangeRate != null && useInversion) {
      return exchangeRate.applyInverseRate(from);
    }
    throw UnknownExchangeRateException(from.currency.isoCode, to);
  }

  _CodePair _generate(CurrencyIsoCode from, CurrencyIsoCode to) => '$from:$to';
}

/// Thrown if an attempt is made to calcuate the value of a [Money] amount
/// in another currency for which there isn't a registered exchange rate.
class UnknownExchangeRateException implements MoneyException {
  /// Thrown if no exchange rate exists between [from] and [to]
  UnknownExchangeRateException(this.from, this.to);

  /// The from currency isoCode in the unknown exchange
  CurrencyIsoCode from;

  /// The to  currency isoCode in the unknown exchange
  CurrencyIsoCode to;

  @override
  String toString() =>
      "An unknown currency exchange was attempted from: '$from' to: '$to'. "
      'Register the ExchangeRate'
      ' via [ExchangePlatform.register()] and try again.';
}

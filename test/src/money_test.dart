/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:money2/money2.dart';
import 'package:test/test.dart';

void main() {
  group('Money', () {
    group('instantiation', () {
      test('fromInt', () {
        Money.fromInt(0, isoCode: 'USD');
        Money.fromInt(1, isoCode: 'USD');
        Money.fromInt(-1, isoCode: 'USD');
      });

      test('from', () {
        expect(Money.fromNum(0, isoCode: 'USD'),
            equals(Money.fromInt(0, isoCode: 'USD')));
        expect(Money.fromNum(1, isoCode: 'USD'),
            equals(Money.fromInt(100, isoCode: 'USD')));
        expect(Money.fromNum(-1, isoCode: 'USD'),
            equals(Money.fromInt(-100, isoCode: 'USD')));
        expect(Money.fromNum(1.99, isoCode: 'USD'),
            equals(Money.fromInt(199, isoCode: 'USD')));
        expect(Money.fromNum(-1.99, isoCode: 'USD'),
            equals(Money.fromInt(-199, isoCode: 'USD')));
      });

      test('high precision', () {
        final currency = Currency.create('BIG', 63);
        Currencies().register(currency);
        expect(
            Money.parse(r'$10.0', isoCode: 'BIG').minorUnits /
                currency.scaleFactor,
            equals(10.0));

        expect(
            () =>
                Money.fromNum(10.0, isoCode: 'BIG').minorUnits /
                currency.scaleFactor,
            throwsA(isA<AmountTooLargeException>()));
        expect(
            Money.parse(r'$-10.0', isoCode: 'BIG').minorUnits /
                currency.scaleFactor,
            equals(-10.0));
      });
    });

    test('bigint hash value', () {
      final fiveDollars = Money.fromInt(500, isoCode: 'USD');

      expect(fiveDollars.hashCode,
          equals(Money.fromInt(500, isoCode: 'USD').hashCode));
    });

    test('int hash value', () {
      final fiveDollars = Money.fromInt(500, isoCode: 'USD');

      expect(fiveDollars.hashCode,
          equals(Money.fromInt(500, isoCode: 'USD').hashCode));
    });

    test('predicate of currency', () {
      final oneDollars = Money.fromInt(100, isoCode: 'USD');

      expect(oneDollars.isInCurrency('USD'), isTrue);
      expect(oneDollars.isInCurrency('EUR'), isFalse);
    });

    test('predicate of currency match', () {
      final oneDollar = Money.fromInt(100, isoCode: 'USD');
      final twoDollars = Money.fromInt(200, isoCode: 'USD');
      final oneEuro = Money.fromInt(100, isoCode: 'EUR');

      expect(oneDollar.isInSameCurrencyAs(twoDollars), isTrue);
      expect(oneDollar.isInSameCurrencyAs(oneEuro), isFalse);
    });

    group('big int amount predicates:', () {
      final zeroCents = Money.fromInt(0, isoCode: 'USD');
      final oneCent = Money.fromInt(1, isoCode: 'USD');
      final minusOneCent = Money.fromInt(-1, isoCode: 'USD');

      moneyAmountPredicates(zeroCents, oneCent, minusOneCent);
    }); // big int amount predicates

    group('int amount predicates:', () {
      final zeroCents = Money.fromInt(0, isoCode: 'USD');
      final oneCent = Money.fromInt(1, isoCode: 'USD');
      final minusOneCent = Money.fromInt(-1, isoCode: 'USD');

      moneyAmountPredicates(zeroCents, oneCent, minusOneCent);
    }); //

    group('copyWith', () {
      final usd = Money.fromInt(101, isoCode: 'USD', decimalDigits: 2);

      test('currency', () {
        final one = usd.copyWith(isoCode: 'EUR');
        expect(one.integerPart, equals(BigInt.one));
        expect(one.decimalPart, equals(BigInt.one));
        expect(one.currency.isoCode, equals('EUR'));
        expect(one.minorUnits, equals(BigInt.from(101)));
        expect(one.decimalDigits, equals(2));
      });

      test('amount', () {
        final one = usd.copyWith(amount: Fixed.ten);
        expect(one.integerPart, equals(BigInt.from(10)));
        expect(one.currency.isoCode, equals('USD'));
        expect(one.minorUnits, equals(BigInt.from(1000)));
        expect(one.decimalDigits, equals(2));
      });

      test('decimalDigits', () {
        final one = usd.copyWith(decimalDigits: 4);
        expect(one.integerPart, equals(BigInt.from(1)));
        expect(one.currency.isoCode, equals('USD'));
        expect(one.minorUnits, equals(BigInt.from(10100)));
        expect(one.decimalDigits, equals(4));
      });
    });
    group('comparison', () {
      final fourDollars = Money.fromInt(400, isoCode: 'USD');
      final fiveDollars = Money.fromInt(500, isoCode: 'USD');
      final sixDollars = Money.fromInt(600, isoCode: 'USD');

      final fiveEuros = Money.fromInt(500, isoCode: 'EUR');

      test('==()', () {
        expect(fiveDollars, equals(Money.fromInt(500, isoCode: 'USD')));
        expect(fiveDollars, isNot(equals(fourDollars)));
        expect(fiveDollars, isNot(equals(sixDollars)));
        expect(fiveDollars, isNot(equals(fiveEuros)));
        // ignore: unrelated_type_equality_checks
        expect(fiveDollars == 'Not money', equals(false));
      });

      test('<()', () {
        expect(fiveDollars < sixDollars, isTrue);
        expect(fiveDollars < fiveDollars, isFalse);
        expect(fiveDollars < fourDollars, isFalse);

        // Cannot compare money in different currencies:
        expect(() => fiveDollars < fiveEuros, throwsArgumentError);
      });

      test('<=()', () {
        expect(fiveDollars <= sixDollars, isTrue);
        expect(fiveDollars <= fiveDollars, isTrue);
        expect(fiveDollars <= fourDollars, isFalse);

        // Cannot compare money in different currencies:
        expect(() => fiveDollars <= fiveEuros, throwsArgumentError);
      });

      test('>()', () {
        expect(fiveDollars > fourDollars, isTrue);
        expect(fiveDollars > fiveDollars, isFalse);
        expect(fiveDollars > sixDollars, isFalse);

        // Cannot compare money in different currencies:
        expect(() => fiveDollars > fiveEuros, throwsArgumentError);
      });

      test('>=()', () {
        expect(fiveDollars >= fourDollars, isTrue);
        expect(fiveDollars >= fiveDollars, isTrue);
        expect(fiveDollars >= sixDollars, isFalse);

        // Cannot compare money in different currencies:
        expect(() => fiveDollars >= fiveEuros, throwsArgumentError);
      });

      test('conformance to Comparable', () {
        expect(fiveDollars, isA<Comparable<Money>>());

        expect(fiveDollars.compareTo(fiveDollars), isZero);
        expect(fiveDollars.compareTo(fourDollars), isPositive);
        expect(fiveDollars.compareTo(sixDollars), isNegative);
        expect(() => fiveDollars.compareTo(fiveEuros), throwsArgumentError);
      });
    }); // comparison

    group('arithmetic:', () {
      test('addition', () {
        final oneDollar = Money.fromInt(100, isoCode: 'USD');
        final twoDollars = Money.fromInt(200, isoCode: 'USD');
        final threeDollars = Money.fromInt(300, isoCode: 'USD');

        expect(oneDollar + twoDollars, equals(threeDollars));
      });

      test('addition error for summands in different currencies', () {
        final oneDollar = Money.fromInt(100, isoCode: 'USD');
        final oneEuro = Money.fromInt(100, isoCode: 'EUR');

        expect(() => oneDollar + oneEuro, throwsArgumentError);
      });

      test('unary minus', () {
        final oneDollar = Money.fromInt(100, isoCode: 'USD');
        final minusOneDollar = Money.fromInt(-100, isoCode: 'USD');

        expect(-oneDollar, equals(minusOneDollar));
        expect(-minusOneDollar, equals(oneDollar));
      });

      test('subtraction', () {
        final oneDollar = Money.fromInt(100, isoCode: 'USD');
        final twoDollars = Money.fromInt(200, isoCode: 'USD');
        final threeDollars = Money.fromInt(300, isoCode: 'USD');

        expect(threeDollars - oneDollar, equals(twoDollars));
      });

      test('subtraction error for operands in different currencies', () {
        final oneDollar = Money.fromInt(100, isoCode: 'USD');
        final oneEuro = Money.fromInt(100, isoCode: 'EUR');

        expect(() => oneDollar - oneEuro, throwsArgumentError);
      });

      test('multiplication', () {
        final zeroDollars = Money.fromInt(0, isoCode: 'USD');
        final oneDollar = Money.fromInt(100, isoCode: 'USD');
        final twoDollars = Money.fromInt(200, isoCode: 'USD');

        // Test integral multiplication:
        expect(oneDollar * 0, equals(zeroDollars));
        expect(oneDollar * 2, equals(twoDollars));
        expect(oneDollar * -2, equals(-twoDollars));

        // Test floating-point multiplication:
        expect(oneDollar * 0.0, equals(zeroDollars));
        expect(oneDollar * -0.0, equals(zeroDollars));
        expect(oneDollar * 1.0, equals(oneDollar));
        expect(oneDollar * -1.0, equals(-oneDollar));

        expect(oneDollar * 0.5, equals(Money.fromInt(50, isoCode: 'USD')));
        expect(oneDollar * 2.01, equals(Money.fromInt(201, isoCode: 'USD')));
        expect(oneDollar * 0.99, equals(Money.fromInt(99, isoCode: 'USD')));

        // Test schoolbook rounding:
        expect(oneDollar * 0.094, equals(Money.fromInt(9, isoCode: 'USD')));
        expect(oneDollar * -0.094, equals(Money.fromInt(-9, isoCode: 'USD')));

        expect(oneDollar * 0.095, equals(Money.fromInt(10, isoCode: 'USD')));
        expect(oneDollar * -0.095, equals(Money.fromInt(-10, isoCode: 'USD')));
      });

      test('division', () {
        final zeroDollars = Money.fromInt(0, isoCode: 'USD');
        final fiftyCents = Money.fromInt(50, isoCode: 'USD');
        final oneDollar = Money.fromInt(100, isoCode: 'USD');
        final twoDollars = Money.fromInt(200, isoCode: 'USD');

        final t1 = twoDollars / 2;
        expect(t1.integerPart, equals(BigInt.one));
        expect(t1.decimalPart, equals(BigInt.zero));
        expect(t1.decimalDigits, 2);

        final t2 = -oneDollar;
        expect(t2.integerPart, equals(BigInt.from(-1)));
        expect(t2.decimalPart, equals(BigInt.zero));
        expect(t2.decimalDigits, equals(2));

        // Test with integral divisor:
        expect(zeroDollars / 2, equals(zeroDollars));
        expect(twoDollars / 1, equals(twoDollars));

        expect(twoDollars / 2, equals(oneDollar));
        expect(twoDollars / -2, equals(-oneDollar));

        expect(oneDollar / 2, equals(fiftyCents));
        expect(oneDollar / 3, equals(Money.fromInt(33, isoCode: 'USD')));

        // Test with floating-point divisor:
        expect(oneDollar / 0.5, equals(twoDollars));
        expect(oneDollar / 0.5, equals(twoDollars));

        expect(oneDollar / 1.094, equals(Money.fromInt(91, isoCode: 'USD')));
        expect(oneDollar / -1.094, equals(Money.fromInt(-91, isoCode: 'USD')));

        expect(oneDollar / 1.092, equals(Money.fromInt(92, isoCode: 'USD')));
        expect(oneDollar / -1.092, equals(Money.fromInt(-92, isoCode: 'USD')));
      });
    }); // arithmetic

    group('allocation according to ratios', () {
      test('throws an error when list of ratios is empty', () {
        final money = Money.fromInt(1, isoCode: 'USD');

        expect(() => money.allocationAccordingTo([]), throwsArgumentError);
      });

      test('throws an error if any of ratios is negative', () {
        final money = Money.fromInt(1, isoCode: 'USD');

        expect(() => money.allocationAccordingTo([-1]), throwsArgumentError);
        expect(() => money.allocationAccordingTo([4, -1]), throwsArgumentError);
      });

      test('throws an error if sum of ratios euals zero', () {
        final money = Money.fromInt(1, isoCode: 'USD');

        expect(() => money.allocationAccordingTo([0]), throwsArgumentError);
        expect(() => money.allocationAccordingTo([0, 0]), throwsArgumentError);
      });

      test('provides list with allocated money values', () {
        void testAllocation(
            int minorUnits, List<int> ratios, List<int> result) {
          final money = Money.fromInt(minorUnits, isoCode: 'USD');

          expect(
              money.allocationAccordingTo(ratios),
              equals(result.map(
                  (minorUnits) => Money.fromInt(minorUnits, isoCode: 'USD'))));
        }

        // Allocation of zero amount:
        testAllocation(0, [1], [0]);
        testAllocation(0, [1, 1], [0, 0]);
        testAllocation(0, [1, 0], [0, 0]);

        // Allocation of positive amount:
        testAllocation(100, [50], [100]);
        testAllocation(100, [1, 1], [50, 50]);
        testAllocation(100, [1, 1, 1], [34, 33, 33]);
        testAllocation(101, [1, 1, 1], [34, 34, 33]);
        testAllocation(2, [1, 1, 1], [1, 1, 0]);
        testAllocation(5, [3, 7], [2, 3]);
        testAllocation(5, [7, 3], [4, 1]);
        testAllocation(5, [0, 7, 3], [0, 4, 1]);
        testAllocation(5, [7, 0, 3], [4, 0, 1]);
        testAllocation(5, [7, 3, 0], [4, 1, 0]);
        testAllocation(5, [0, 0, 1], [0, 0, 5]);

        // Allocation of negative amount:
        testAllocation(-100, [50], [-100]);
        testAllocation(-100, [1, 1], [-50, -50]);
        testAllocation(-100, [1, 1, 1], [-34, -33, -33]);
        testAllocation(-101, [1, 1, 1], [-34, -34, -33]);
        testAllocation(-2, [1, 1, 1], [-1, -1, 0]);
        testAllocation(-5, [3, 7], [-2, -3]);
        testAllocation(-5, [7, 3], [-4, -1]);
        testAllocation(-5, [0, 7, 3], [0, -4, -1]);
        testAllocation(-5, [7, 0, 3], [-4, 0, -1]);
        testAllocation(-5, [7, 3, 0], [-4, -1, 0]);
        testAllocation(-5, [0, 0, 1], [0, 0, -5]);
      });
    });

    group('allocation to targets', () {
      test('throws an error if number of targets less than one', () {
        final money = Money.fromInt(100, isoCode: 'USD');

        expect(() => money.allocationTo(0), throwsArgumentError);
        expect(() => money.allocationTo(-1), throwsArgumentError);
      });

      test('returns a list with values allocated among N targets', () {
        void testAllocation(int minorUnits, int targets, List<int> result) {
          final money = Money.fromInt(minorUnits, isoCode: 'USD');

          expect(
              money.allocationTo(targets),
              equals(result
                  .map(
                      (minorUnits) => Money.fromInt(minorUnits, isoCode: 'USD'))
                  .toList()));
        }

        // Allocation of zero amount:
        testAllocation(0, 1, [0]);
        testAllocation(0, 2, [0, 0]);

        // Allocation of positive amount:
        testAllocation(100, 1, [100]);
        testAllocation(100, 2, [50, 50]);
        testAllocation(101, 2, [51, 50]);

        // Allocation of negative amount:
        testAllocation(-100, 1, [-100]);
        testAllocation(-100, 2, [-50, -50]);
        testAllocation(-101, 2, [-51, -50]);
      });
    });

    test('currency property', () {
      expect(Currencies().find('USD'),
          Money.fromInt(1000, isoCode: 'USD').currency);
      expect(Currencies().find('EUR'),
          Money.fromInt(1000, isoCode: 'EUR').currency);
    });

    test('minorUnits property', () {
      expect(Money.fromInt(2000, isoCode: 'USD').minorUnits, BigInt.from(2000));
      expect(Money.fromInt(1001, isoCode: 'EUR').minorUnits, BigInt.from(1001));
    });
  });
}

void moneyAmountPredicates(Money zeroCents, Money oneCent, Money minusOneCent) {
  test('isZero', () {
    expect(zeroCents.isZero, isTrue);
    expect(oneCent.isZero, isFalse);
    expect(minusOneCent.isZero, isFalse);
  });

  test('isPositive', () {
    expect(oneCent.isPositive, isTrue);
    expect(zeroCents.isPositive, isFalse);
    expect(minusOneCent.isPositive, isFalse);
  });

  test('isNegative', () {
    expect(minusOneCent.isNegative, isTrue);
    expect(zeroCents.isNegative, isFalse);
    expect(oneCent.isNegative, isFalse);
  });
}

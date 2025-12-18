import 'package:flutter_test/flutter_test.dart';
import 'package:frame/utils/validators.dart';

// **Feature: flutter-enterprise-framework, Property 4: Validator Correctness**
// **Validates: Requirements 9.2**
void main() {
  group('Validators Tests', () {
    test('Valid emails pass validation', () {
      final validEmails = [
        'test@example.com',
        'user.name@domain.org',
        'user+tag@example.co.uk',
        'a@b.cc',
      ];
      for (final email in validEmails) {
        expect(Validators.isEmail(email), isTrue, reason: '$email should be valid');
      }
    });

    test('Invalid emails fail validation', () {
      final invalidEmails = [
        'invalid',
        '@example.com',
        'test@',
        'test@.com',
        '',
        null,
      ];
      for (final email in invalidEmails) {
        expect(Validators.isEmail(email), isFalse, reason: '$email should be invalid');
      }
    });

    test('Valid phone numbers pass validation', () {
      final validPhones = [
        '13800138000',
        '15912345678',
        '18888888888',
        '19999999999',
      ];
      for (final phone in validPhones) {
        expect(Validators.isPhone(phone), isTrue, reason: '$phone should be valid');
      }
    });

    test('Invalid phone numbers fail validation', () {
      final invalidPhones = [
        '12345678901',
        '1380013800',
        '23800138000',
        'abcdefghijk',
        '',
        null,
      ];
      for (final phone in invalidPhones) {
        expect(Validators.isPhone(phone), isFalse, reason: '$phone should be invalid');
      }
    });

    test('Strong passwords pass validation', () {
      final validPasswords = [
        'Password1',
        'Test1234',
        'Abc12345',
        'MyP@ssw0rd',
      ];
      for (final password in validPasswords) {
        expect(Validators.isStrongPassword(password), isTrue, 
            reason: '$password should be valid');
      }
    });

    test('Weak passwords fail validation', () {
      final invalidPasswords = [
        'password',
        '12345678',
        'Pass1',
        '',
        null,
      ];
      for (final password in invalidPasswords) {
        expect(Validators.isStrongPassword(password), isFalse,
            reason: '$password should be invalid');
      }
    });

    test('isNotEmpty correctly identifies empty strings', () {
      expect(Validators.isNotEmpty('hello'), isTrue);
      expect(Validators.isNotEmpty('  hello  '), isTrue);
      expect(Validators.isNotEmpty(''), isFalse);
      expect(Validators.isNotEmpty('   '), isFalse);
      expect(Validators.isNotEmpty(null), isFalse);
    });

    test('isNumeric correctly identifies numbers', () {
      expect(Validators.isNumeric('123'), isTrue);
      expect(Validators.isNumeric('12.34'), isTrue);
      expect(Validators.isNumeric('-123'), isTrue);
      expect(Validators.isNumeric('abc'), isFalse);
      expect(Validators.isNumeric(''), isFalse);
      expect(Validators.isNumeric(null), isFalse);
    });

    test('isLengthBetween correctly validates string length', () {
      expect(Validators.isLengthBetween('hello', 1, 10), isTrue);
      expect(Validators.isLengthBetween('hello', 5, 5), isTrue);
      expect(Validators.isLengthBetween('hello', 6, 10), isFalse);
      expect(Validators.isLengthBetween('', 0, 0), isTrue);
      expect(Validators.isLengthBetween(null, 0, 10), isFalse);
    });
  });
}

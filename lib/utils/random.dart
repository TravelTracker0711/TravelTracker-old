import 'dart:math';

class RandomType {
  final int value;
  const RandomType._(this.value);
  static const RandomType upperCaseAlphabet = RandomType._(1);
  static const RandomType lowerCaseAlphabet = RandomType._(2);
  static const RandomType number = RandomType._(4);
  static const RandomType specialCharacter = RandomType._(8);
  static const RandomType all = RandomType._(15);
}

class RandomUtils {
  static final Random _rnd = Random();

  static const _upperCaseAlphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const _lowerCaseAlphabet = 'abcdefghijklmnopqrstuvwxyz';
  static const _number = '1234567890';
  static const _specialCharacter = '!@#\$%^&*()_+-=[]{}|;:,./<>?';

  static String getRandomString({
    required int length,
    int? type,
  }) {
    type ??= RandomType.all.value;
    String chars = _getChars(type);
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(
          _rnd.nextInt(chars.length),
        ),
      ),
    );
  }

  static String _getChars(int type) {
    String chars = '';
    if (_checkRandomType(type, RandomType.upperCaseAlphabet.value)) {
      chars += _upperCaseAlphabet;
    }
    if (_checkRandomType(type, RandomType.lowerCaseAlphabet.value)) {
      chars += _lowerCaseAlphabet;
    }
    if (_checkRandomType(type, RandomType.number.value)) {
      chars += _number;
    }
    if (_checkRandomType(type, RandomType.specialCharacter.value)) {
      chars += _specialCharacter;
    }
    return chars;
  }

  static bool _checkRandomType(int type, int randomType) {
    return type & randomType == randomType;
  }
}

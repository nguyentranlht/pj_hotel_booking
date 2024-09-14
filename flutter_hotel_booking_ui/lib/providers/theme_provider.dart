import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ui/utils/shared_preferences_keys.dart';
import 'package:flutter_hotel_booking_ui/utils/themes.dart';
import 'package:flutter_hotel_booking_ui/utils/enum.dart';
import 'package:flutter_hotel_booking_ui/motel_app.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider({required ThemeData state}) : super();

  bool _isLightMode = true;
  ThemeData _themeData = AppTheme.getThemeData;
  ThemeModeType _themeModeType = ThemeModeType.system;
  ThemeData get themeData => _themeData;
  bool get isLightMode => _isLightMode;
  ThemeModeType get themeModeType => _themeModeType;
  FontFamilyType get fontType => _fontType;
  FontFamilyType _fontType = FontFamilyType.WorkSans;
  ColorType get colorType => _colorType;
  ColorType _colorType = ColorType.Verdigris;
  LanguageType get languageType => _languageType;
  LanguageType _languageType = LanguageType.en;

  updateThemeMode(ThemeModeType themeModeType) async {
    await SharedPreferencesKeys().setThemeMode(themeModeType);
    final systembrightness =
        MediaQuery.of(applicationcontext!).platformBrightness;
    checkAndSetThemeMode(themeModeType == ThemeModeType.light
        ? Brightness.light
        : themeModeType == ThemeModeType.dark
            ? Brightness.dark
            : systembrightness);
  }

// this func is auto check theme and update them
  void checkAndSetThemeMode(Brightness systemBrightness) async {
    bool theLightTheme = _isLightMode;

    // mode is selected by user
    _themeModeType = await SharedPreferencesKeys().getThemeMode();
    if (_themeModeType == ThemeModeType.system) {
      // if mode is system then we add as system birtness
      theLightTheme = systemBrightness == Brightness.light;
    } else if (_themeModeType == ThemeModeType.dark) {
      theLightTheme = false;
    } else {
      //light theme selected by user
      theLightTheme = true;
    }

    if (_isLightMode != theLightTheme) {
      _isLightMode = theLightTheme;
      _themeData = AppTheme.getThemeData;
      notifyListeners();
    }
  }

  void checkAndSetFonType() async {
    final FontFamilyType fontType = await SharedPreferencesKeys().getFontType();
    if (fontType != _fontType) {
      _fontType = fontType;
      _themeData = AppTheme.getThemeData;
      notifyListeners();
    }
  }

  void updateFontType(FontFamilyType fontType) async {
    await SharedPreferencesKeys().setFontType(fontType);
    fontType = fontType;
    _themeData = AppTheme.getThemeData;
    notifyListeners();
  }

  void updateColorType(ColorType color) async {
    await SharedPreferencesKeys().setColorType(color);
    _colorType = color;
    _themeData = AppTheme.getThemeData;
    notifyListeners();
  }

  void checkAndSetColorType() async {
    final ColorType colorTypeData =
        await SharedPreferencesKeys().getColorType();
    if (colorTypeData != colorType) {
      _colorType = colorTypeData;
      _themeData = AppTheme.getThemeData;
      notifyListeners();
    }
  }

  void updateLanguage(LanguageType language) async {
    await SharedPreferencesKeys().setLanguageType(language);
    _languageType = language;
    _themeData = AppTheme.getThemeData;
    notifyListeners();
  }

  void checkAndSetLanguage() async {
    final LanguageType languageTypeData =
        await SharedPreferencesKeys().getLanguageType();
    if (languageTypeData != languageType) {
      _languageType = languageTypeData;
      _themeData = AppTheme.getThemeData;
      notifyListeners();
    }
  }
}

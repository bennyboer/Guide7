import 'dart:core';
import 'dart:ui';

import 'package:flutter/widgets.dart';

/// Class containing localizations for the app (translations).
class AppLocalizations {
  /// Version of the application.
  static const String _appVersion = "0.1.0";

  /// Create app localizations.
  AppLocalizations(this.locale);

  /// Current locale.
  final Locale locale;

  /// Convenience method to easily get the localizations.
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// Map containing all localizations (translations).
  static const Map<String, Map<String, String>> _localizations = {
    "de": _deLocalizations,
    "en": _enLocalizations,
  };

  /// German localized values.
  static const Map<String, String> _deLocalizations = {
    "title": "Guide7",
    "splash_subtitle": "Eine App der Fachschaft 07",
    "login": "Anmeldung",
    "login_info": "Gib deine ZPA Anmeldedaten an um dich anzumelden.",
    "username": "Benutzername",
    "username_error": "Bitte geben Sie einen Benutzernamen an",
    "password": "Passwort",
    "password_error": "Bitte geben Sie ein Password an",
    "do_login": "Anmelden",
    "check_login": "Überprüfe Anmeldedaten...",
    "login_failed": "Anmeldung fehlgeschlagen",
    "notice_board": "Schwarzes Brett",
    "weekplan": "Wochenplan",
    "appointments": "Termine",
    "logout": "Abmelden",
    "search": "Suche",
    "end_search": "Suche beenden",
    "do_search": "Suchen...",
    "notice_board_entry_load_error": "Beim Laden der Einträge ist ein Fehler aufgetreten.",
    "navigation_view_item_title": "Mehr...",
    "navigation_view_title": "Navigation",
    "settings": "Einstellungen",
    "privacy_policy_statement": "Datenschutzerklärung",
    "or": "Oder",
    "skip_login": "Anmeldung überspringen",
    "room_search": "Raumsuche",
    "day": "Tag",
    "from": "Von",
    "to": "Bis",
    "room_search_error": "Freie Räume konnten nicht geladen werden.",
    "seat_count": "Sitzanzahl",
    "appointment_load_error": "Die Termine konnten nicht geladen werden.",
    "weekplan_load_error": "Die Wochenplan Einträge konnten nicht geladen werden.",
    "refresh": "Aktualisieren",
    "version": "Version",
  };

  /// English localized values.
  static const Map<String, String> _enLocalizations = {
    "title": "Guide7",
    "splash_subtitle": "App of the students council of department 07",
    "login": "Login",
    "login_info": "Enter your ZPA credentials to login.",
    "username": "Username",
    "username_error": "Please enter a username",
    "password": "Password",
    "password_error": "Please enter a password",
    "do_login": "Login",
    "check_login": "Checking credentials...",
    "login_failed": "Login failed",
    "notice_board": "Notice board",
    "weekplan": "Week plan",
    "appointments": "Appointments",
    "logout": "Log out",
    "search": "Search",
    "end_search": "Exit search",
    "do_search": "Search...",
    "notice_board_entry_load_error": "An error occurred when trying to load notice board entries.",
    "navigation_view_item_title": "More...",
    "navigation_view_title": "Navigation",
    "settings": "Settings",
    "privacy_policy_statement": "Privacy policy statement",
    "or": "Or",
    "skip_login": "Skip the login",
    "room_search": "Room search",
    "day": "Day",
    "from": "From",
    "to": "To",
    "room_search_error": "Free rooms could not be fetched.",
    "seat_count": "Seat count",
    "appointment_load_error": "Appointments could not be loaded.",
    "weekplan_load_error": "Week plan entries could not be loaded.",
    "refresh": "Refresh",
    "version": "Version",
  };

  /// Get localized value by [key].
  String _get(String key) => _localizations[locale.languageCode][key];

  String get appVersion => _appVersion;

  String get title => _get("title");

  String get splashSubtitle => _get("splash_subtitle");

  String get login => _get("login");

  String get loginInfo => _get("login_info");

  String get username => _get("username");

  String get usernameError => _get("username_error");

  String get password => _get("password");

  String get passwordError => _get("password_error");

  String get doLogin => _get("do_login");

  String get checkLogin => _get("check_login");

  String get loginFailed => _get("login_failed");

  String get noticeBoard => _get("notice_board");

  String get weekPlan => _get("weekplan");

  String get appointments => _get("appointments");

  String get logOut => _get("logout");

  String get search => _get("search");

  String get endSearch => _get("end_search");

  String get doSearch => _get("do_search");

  String get noticeBoardEntryLoadError => _get("notice_board_entry_load_error");

  String get navigationViewItemTitle => _get("navigation_view_item_title");

  String get navigationViewTitle => _get("navigation_view_title");

  String get settings => _get("settings");

  String get privacyPolicyStatement => _get("privacy_policy_statement");

  String get or => _get("or");

  String get skipLogin => _get("skip_login");

  String get roomSearch => _get("room_search");

  String get day => _get("day");

  String get from => _get("from");

  String get to => _get("to");

  String get roomSearchError => _get("room_search_error");

  String get seatCount => _get("seat_count");

  String get appointmentLoadError => _get("appointment_load_error");

  String get weekPlanLoadError => _get("weekplan_load_error");

  String get refresh => _get("refresh");

  String get version => _get("version");
}

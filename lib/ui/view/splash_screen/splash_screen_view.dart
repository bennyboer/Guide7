import 'dart:async';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/app-routes.dart';
import 'package:guide7/app.dart';
import 'package:guide7/connect/login/zpa/response/zpa_login_response.dart';
import 'package:guide7/connect/repository.dart';
import 'package:guide7/localization/app_localizations.dart';
import 'package:guide7/model/credentials/username_password_credentials.dart';
import 'package:guide7/model/login_info/login_info.dart';
import 'package:guide7/storage/login_info/login_info_storage.dart';
import 'package:guide7/ui/common/headline.dart';

/// Splash screen of the application.
/// It redirects to the correct starting view (Login if user already logged in).
class SplashScreenView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SplashScreenState();
}

/// State of the splash screen redirecting to the correct starting view.
class _SplashScreenState extends State<SplashScreenView> {
  /// Duration the splash screen is shown.
  static const Duration _minDuration = Duration(milliseconds: 600);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    double imageWidth;
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      imageWidth = size.width / 2;
    } else {
      imageWidth = size.width / 4;
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "res/images/guide7_logo.png",
              width: imageWidth,
            ),
            Container(
              child: Headline(AppLocalizations.of(context).title),
              padding: EdgeInsets.only(top: 20.0),
            ),
            Text(
              AppLocalizations.of(context).splashSubtitle,
              style: TextStyle(fontFamily: "NotoSerifTC"),
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _startTimer();
  }

  /// Start the splash screen timer.
  Future<void> _startTimer() async {
    Future<void> minDurationFuture = Future.delayed(_SplashScreenState._minDuration);
    Future<Function> nextViewAction = _fetchNextView();

    /// Wait for both actions, then navigate to start view.
    Future.wait([
      minDurationFuture,
      nextViewAction,
    ]).then((values) {
      Function navigateToStartView = values[1] as Function;

      navigateToStartView();
    });
  }

  /// Fetch next view to navigate after the splash screen.
  Future<Function> _fetchNextView() async {
    LoginInfo loginInfo = await _getLoginInfo();
    bool skippedLogin = false;

    if (loginInfo != null) {
      skippedLogin = loginInfo.skippedLogin;
    }

    if (skippedLogin || await isLoggedIn()) {
      return _gotoNoticeBoard;
    } else {
      return _gotoLoginView;
    }
  }

  /// Get login info from the last login.
  Future<LoginInfo> _getLoginInfo() async {
    LoginInfoStorage storage = LoginInfoStorage();

    if (await storage.isEmpty()) {
      return null;
    } else {
      return await storage.read();
    }
  }

  /// Check if a user is currently logged in.
  Future<bool> isLoggedIn() async {
    Repository repo = Repository();

    UsernamePasswordCredentials credentials = await repo.getLocalCredentialsRepository().loadLocalCredentials();
    ZPALoginResponse response = await repo.getZPALoginRepository().tryLogin(credentials);

    return response != null;
  }

  /// Navigate to login view.
  void _gotoLoginView() {
    App.router.navigateTo(context, AppRoutes.login, transition: TransitionType.native, replace: true);
  }

  /// Navigate to notice board.
  void _gotoNoticeBoard() {
    App.router.navigateTo(context, AppRoutes.main, transition: TransitionType.native, replace: true);
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend/bloc/calculator/calculatorBloc.dart';
import 'package:frontend/bloc/form/logIn/logInFormBloc.dart';
import 'package:frontend/bloc/form/signUp/signUpFormBloc.dart';
import 'package:frontend/bloc/user/userBloc.dart';
import 'package:frontend/bloc/user/userBlocEvent.dart';
import 'package:frontend/bloc/user/userBlocState.dart';
import 'package:frontend/service/ioc/blocContainerService.dart';
import 'package:frontend/view/screens/calculator/calculatorView.dart';
import 'package:frontend/view/screens/login/loginView.dart';
import 'package:frontend/view/screens/splash/splashAnimationView.dart';
import 'package:get_it/get_it.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class SplashView extends StatelessWidget {
  UserBloc userBloc;

  SplashView() {
    _setupBlocs();

    userBloc = BlocContainerService.instance.getAndInit(UserBloc.BLOC_NAME);

    userBloc.events.add(RestoreSession());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      navigatorObservers: [routeObserver],
      home: StreamBuilder<UserBlocState>(
        stream: userBloc.states,
        builder: (context, snapshot) {
          UserBlocState state = snapshot.data;

          print("Splash state: ${state.runtimeType}");

          if (state is UserLoggedIn) {
            //_followRoute(CalculatorViewRoute(), context);
            return Text("Authorized!");
          } else if (state is UserUnauthorized) {
            print("Unauth reason: ${state.errorContainer.toString()}");
            _followRoute(LoginRoute(), context);
          }

          return SplashAnimationView();
        },
      ),
      theme: ThemeData(
        primaryColor: Colors.purple,
        accentColor: Colors.grey,
        fontFamily: 'Pacifico',
      ),
    );
  }

  void _setupBlocs() {
    var IoC = GetIt.instance;
    IoC.reset();

    GetIt.instance.registerSingleton<RouteObserver>(routeObserver, signalsReady: true);

    BlocContainerService.instance.addIfAbcent(UserBloc(), blocName: UserBloc.BLOC_NAME);
    BlocContainerService.instance.addIfAbcent(CalculatorBloc(), blocName: CalculatorBloc.BLOC_NAME);
    BlocContainerService.instance.addIfAbcent(LogInFormBloc(), blocName: LogInFormBloc.BLOC_NAME);
    BlocContainerService.instance.addIfAbcent(SignUpFormBloc(), blocName: SignUpFormBloc.BLOC_NAME);
  }

  void _followRoute(PageRoute pageRoute, BuildContext context) {
    _whenWidgetBuilt(() =>
        Navigator
            .of(context)
            .pushAndRemoveUntil(pageRoute, (cond) => false));
  }

  void _whenWidgetBuilt(Function fun) {
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      fun.call();
    });
  }
}

class SplashViewRoute extends CupertinoPageRoute {
  SplashViewRoute() : super(builder: (BuildContext context) => SplashView());
}
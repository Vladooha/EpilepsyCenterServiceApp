import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend/bloc/calculator/calculatorBloc.dart';
import 'package:frontend/bloc/chat/chatBloc.dart';
import 'package:frontend/bloc/user/userBloc.dart';
import 'package:frontend/bloc/user/userBlocEvent.dart';
import 'package:frontend/bloc/user/userBlocState.dart';
import 'package:frontend/service/database/remoteStorageServiceImpl.dart';
import 'package:frontend/service/ioc/blocContainerService.dart';
import 'package:frontend/service/storage/storageServiceImpl.dart';
import 'package:frontend/view/screens/calculator/calculatorView.dart';
import 'package:frontend/view/screens/chat/chatListView.dart';
import 'package:frontend/view/screens/login/loginFormView.dart';
import 'package:frontend/view/screens/splash/splashAnimationView.dart';
import 'package:get_it/get_it.dart';
//import 'package:firebase/firebase.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class SplashView extends StatelessWidget {
  UserBloc userBloc;

  SplashView() {
    _setupIoC();

    userBloc = BlocContainerService.instance.getAndInit(UserBloc.BLOC_NAME);
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
      home: StreamBuilder<UserData>(
        initialData: null,
        stream: userBloc.userData,
        builder: (context, snapshot) {
          print('Splash: ${snapshot.data}');

          if (snapshot.hasData) {
            UserData userData = snapshot.data;
            if (userData.user != null) {
              _whenWidgetBuilt(() =>
                  Navigator
                      .of(context)
                      .pushAndRemoveUntil(CalculatorViewRoute(), (cond) => false));
            } else {
              _whenWidgetBuilt(() =>
                  Navigator
                      .of(context)
                      .pushAndRemoveUntil(LoginFormRoute(), (cond) => false));
            }
          }

          // TODO: Implement splash screen
          return SplashAnimationView();
        },
      ),
      theme: ThemeData(
        primaryColor: Colors.red[500],
        accentColor: Colors.grey[600],
        fontFamily: 'Pacifico',
      ),
    );
  }

  void _setupIoC() {
    // TODO: Automate dependency order
    // TODO: Fix beans' self-wiring to IoC container

    print("Setup IoC!");

    var IoC = GetIt.instance;
    IoC.reset();

    GetIt.instance.registerSingleton<RouteObserver>(routeObserver, signalsReady: true);

    // Core services
    StorageServiceImpl();
    //WebServiceImpl();

    //ChatServiceImpl();


    BlocContainerService.instance.addIfAbcent(UserBloc(), blocName: UserBloc.BLOC_NAME);
    BlocContainerService.instance.addIfAbcent(ChatBloc(), blocName: ChatBloc.BLOC_NAME);
    BlocContainerService.instance.addIfAbcent(CalculatorBloc(), blocName: CalculatorBloc.BLOC_NAME);

    RemoteStorageServiceImpl();
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
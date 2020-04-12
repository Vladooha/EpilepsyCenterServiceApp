import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/bloc/user/userBloc.dart';
import 'package:frontend/bloc/user/userBlocEvent.dart';
import 'package:frontend/bloc/user/userBlocState.dart';
import 'package:frontend/model/user/user.dart';
import 'package:frontend/service/ioc/blocContainerService.dart';
import 'package:frontend/view/screens/calculator/calculatorProductListView.dart';
import 'package:frontend/view/screens/calculator/calculatorView.dart';
import 'package:frontend/view/screens/chat/chatListView.dart';
import 'package:frontend/view/screens/login/loginView.dart';

class DrawerMenuPart {
  UserBloc userBloc = BlocContainerService.instance.getAndInit(UserBloc.BLOC_NAME);

  Widget createDrawerMenuPart(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
//          StreamBuilder<UserData>(
//            initialData: userBloc.lastCurrentUserData,
//            stream: userBloc.currentUserData,
//            builder: (context, snapshot) {
//              Widget avatar = Icon(Icons.broken_image);
//              Widget fullName = Text("Загрузка...");
//
//              if (snapshot.hasData && snapshot.data.user != null) {
//                User user = snapshot.data.user;
//
//                avatar = _createAvatar(user);
//                fullName = Text("${user.name} ${user.surname}");
//              }
//
//              return UserAccountsDrawerHeader(
//                 currentAccountPicture: avatar,
//                 accountName: fullName
//              );
//            }
//          ),
//          //_createListTile("Чаты", context, ChatListViewRoute(), iconData: Icons.chat_bubble),
//          _createListTile("Диета", context, CalculatorViewRoute(), iconData: Icons.table_chart),
//          _createListTile("Продукты", context, CalculatorProductListViewRoute(), iconData: Icons.restaurant),
//          _createListTile(
//            "Выход",
//            context,
//            LoginFormRoute(),
//            iconData: Icons.exit_to_app,
//            onTap: () {
//              userBloc.eventListener.add(UserAction(UserActionsType.logOut));
//            },
//            clearNavigation: true,
//          ),
        ],
      ),
    );
  }

  ListTile _createListTile(
      String name,
      BuildContext context,
      PageRoute route,
      {
        IconData iconData,
        Function() onTap,
        bool clearNavigation = false
      }) {
    Widget title = iconData == null
      ? Text(name)
      : Row(
          children: [
            Padding(
              padding: EdgeInsets.only(right: 32.0),
              child: Icon(
                iconData,
                color: Color.fromRGBO(0, 0, 0, 0.3),
              ),
            ),
            Text(name)
          ]
        );

    return ListTile(
        title: title,
        onTap: () async {
          onTap?.call();

          var navigator = Navigator.of(context);
          if (clearNavigation) {
            navigator.pushAndRemoveUntil(route, (route) => false);
          } else {
            navigator.pop();
            navigator.push(route);
          }
        });
  }

  Widget _createAvatar(User user) {
    return Container(
      width: 50.0,
      height: 50.0,
//      decoration: BoxDecoration(
//          shape: BoxShape.circle,
//          image: DecorationImage(
//              fit: BoxFit.fill,
//              image: user.avatar
//          )
//      ),
      child: Icon(Icons.person),
    );
  }
}
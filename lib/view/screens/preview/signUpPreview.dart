import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/view/uiparts/drawerMenuPart.dart';
import 'package:frontend/view/uiparts/inputFieldPart.dart';

class SignUpPreview extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SignUpPreviewState();
}

class SignUpPreviewState extends State<SignUpPreview> with DrawerMenuPart, InputFieldPart {
  bool isPatient;


  SignUpPreviewState({this.isPatient = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.purple,
        accentColor: Colors.grey[600],
        fontFamily: 'Pacifico',
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Регистрация"),
        ),
        //drawer: createDrawerMenuPart(context),
        body: SingleChildScrollView(
          child: Column(
            children: List.from(() sync* {
                yield Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Checkbox(
                          value: isPatient,
                          onChanged: (bool value) => setState(() => isPatient = value),
                        ),
                      ),
                      Text(
                          "Я пациент Keto-Clinic"
                      ),
                    ],
                  ),
                );
                yield* _getUserFields();
                yield RawMaterialButton(
                  child: Text("Зарегистрироваться"),
                  padding: EdgeInsets.all(5.0),
                  fillColor: Colors.purple,
                  textStyle: TextStyle(color: Colors.white),
                  onPressed: () {},
                );
            } ())
          ),
        ),
      ),
    );
  }

  List<Widget> _getUserFields() {
    if (isPatient) {
      return [
        //createInputTextField("ID пациента клиники", TextEditingController(), (textValue) => [], padding: 5),
        SizedBox(height: 480.0)
      ];
    } else {
      return [
        //createInputTextField("Фамилия", TextEditingController(), (textValue) => [], padding: 5),
        //createInputTextField("Имя", TextEditingController(), (textValue) => [], padding: 5),
        //createInputTextField("Отчество", TextEditingController(), (textValue) => [], padding: 5),
        SizedBox(height: 300.0)
      ];
    }
  }
}
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/view/uiparts/cardPart.dart';
import 'package:frontend/view/uiparts/tablePart.dart';

enum Role {
  patient,
  client,
  admin
}

class ReportPreview extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ReportPreviewState();
}

class ReportPreviewState extends State<ReportPreview> with TablePart, CardPart {
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
          title: Text("Ежедневный отчёт"),
        ),  
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              createCard(
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text("Дата"),
                            Spacer(),
                            _createTimePickerCalendar()
                          ],
                        ),
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5.0),
                            child: _createTimePickerRow()
                        ),
                      ]
                  )
              ),
              createCard(
                createTable([
                  createTableRow("Соотношение Б/ЖУ", value: "1/2"),
                  createTableRow("Калории", value: "1200"),
                  createTableRow("Белки (г)", value: "30"),
//                  createTableRowDivider(),
//                  createEditableTableRow("Кетоны", () => 5.0, (e) { }, context, (e) { }),
//                  createEditableTableRow("Глюкоза", () => 5.0, (e) { }, context, (e) { }),
                ]),
              ),
              Padding(
                padding: EdgeInsets.all(5.0),
                child: RawMaterialButton(
                  child: SizedBox(
                    width: 100.0,
                    child: Row(
                        children: [
                          _createIcon(Icons.restaurant),
                          Text("Готовить")
                        ]
                    ),
                  ),
                  padding: EdgeInsets.all(5.0),
                  fillColor: Colors.purple,
                  textStyle: TextStyle(color: Colors.white),
                  onPressed: () {},
                ),
              ),
//              Padding(
//                padding: EdgeInsets.symmetric(horizontal: 20.0),
//                child: Row(
//                  children: [
//                    RawMaterialButton(
//                      child: SizedBox(
//                        width: 100.0,
//                        child: Row(
//                            children: [
//                              _createIcon(Icons.restaurant),
//                              Text("Готовить")
//                            ]
//                        ),
//                      ),
//                      padding: EdgeInsets.all(5.0),
//                      fillColor: Colors.purple,
//                      textStyle: TextStyle(color: Colors.white),
//                      onPressed: () {},
//                    ),
//                    Spacer(),
//                    RawMaterialButton(
//                      child: SizedBox(
//                        width: 180.0,
//                        child: Row(
//                            children: [
//                              _createIcon(Icons.chat_bubble),
//                              Text("Сообщения от врача")
//                            ]
//                        ),
//                      ),
//                      padding: EdgeInsets.all(5.0),
//                      fillColor: Colors.purple,
//                      textStyle: TextStyle(color: Colors.white),
//                      onPressed: () {},
//                    ),
//                  ],
//                ),
//              ),
//              createCard(
//                Padding(
//                  padding: EdgeInsets.all(10.0),
//                  child: TextField(
//                    maxLines: 4,
//                    minLines: 4,
//                    controller: TextEditingController(),
//                    decoration: InputDecoration.collapsed(
//                        hintText: "Информация для врача"
//                    ),
//                  ),
//                ),
//              ),
//              RawMaterialButton(
//                child: Text("Отправить"),
//                padding: EdgeInsets.all(5.0),
//                fillColor: Colors.purple,
//                textStyle: TextStyle(color: Colors.white),
//                onPressed: () {},
//              ),
            ],
          ),
        ),
      )
    );
  }

  Widget _createTimePickerRow() {
    int datepickerLength = 10;

    var datepicker = DatePickerTimeline(
      DateTime.now(),
      onDateChange: (dateTime) {},
      locale: "ru",
      daysCount: datepickerLength,
      beginDate: DateTime.now().subtract(Duration(days: datepickerLength)),
    );

    return Row(
        children: [
          _createIcon(Icons.arrow_back_ios),
          Expanded(child: datepicker),
          _createIcon(Icons.arrow_forward_ios),
        ]);
  }

  Widget _createTimePickerCalendar() {
    return FlatButton(
      onPressed: () {},
      textColor: Colors.grey[110],
      child: Row(
        children: [
          Text("Указать на календаре"),
          _createIcon(Icons.date_range),
        ],
      ),
    );
  }

  Widget _createIcon(IconData iconData, {width = 30.0, height = 30.0, iconSize = 15.0}) {
    return IconButton(
      constraints: BoxConstraints.loose(Size(width, height)),
      iconSize: iconSize,
      icon: Icon(iconData),
      color: Colors.grey[150],
    );
  }
}
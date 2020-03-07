import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:frontend/bloc/calculator/calculatorBloc.dart';
import 'package:frontend/bloc/calculator/calculatorBlocEvent.dart';
import 'package:frontend/bloc/calculator/calculatorBlocState.dart';
import 'package:frontend/model/calculator/dailyEating.dart';
import 'package:frontend/model/calculator/eatingType.dart';
import 'package:frontend/model/calculator/product.dart';
import 'package:frontend/model/calculator/singleEating.dart';
import 'package:frontend/model/calculator/dish.dart';
import 'package:frontend/service/date/dateService.dart';
import 'package:frontend/service/ioc/blocContainerService.dart';
import 'package:frontend/view/screens/calculator/calculatorProductListView.dart';
import 'package:frontend/view/screens/calculator/calculatorSingleEatingView.dart';
import 'package:frontend/view/uiparts/cardPart.dart';
import 'package:frontend/view/uiparts/customTextPart.dart';
import 'package:frontend/view/uiparts/drawerMenuPart.dart';
import 'package:frontend/view/uiparts/popupPart.dart';
import 'package:get_it/get_it.dart';

class MealTimeView {
  static const MealTimeView BREAKFAST = MealTimeView._("Завтрак", EatingType.breakfast, Colors.red);
  static const MealTimeView DINNER = MealTimeView._("Обед", EatingType.dinner, Colors.orange);
  static const MealTimeView LAUNCH = MealTimeView._("Полдник", EatingType.launch, Colors.yellow);
  static const MealTimeView EVENING_MEAL = MealTimeView._("Ужин", EatingType.evening_meal, Colors.green);
  static const MealTimeView SNACK = MealTimeView._("Перекус", EatingType.snack, Colors.blue);
  static const MealTimeView NIGHT_MEAL = MealTimeView._("Ночь", EatingType.night_meal, Colors.indigo);

  static List<MealTimeView> get values => [
    BREAKFAST, DINNER, LAUNCH, EVENING_MEAL, SNACK, NIGHT_MEAL
  ];

  static MealTimeView getByMealTime(EatingType mealTime) =>
      values.firstWhere((element) =>
          element.mealTime == mealTime);

  final String name;
  final EatingType mealTime;
  final Color color;

  const MealTimeView._(this.name, this.mealTime, this.color);
}

class CalculatorView extends StatefulWidget {
  final RouteObserver routeObserver = GetIt.instance.get<RouteObserver>();

  final CalculatorBloc calculatorBloc = BlocContainerService.instance
      .getAndInit(CalculatorBloc.BLOC_NAME);

  final DateService dateService = DateService();

  @override
  State<StatefulWidget> createState() => CalculatorViewState();
}

class CalculatorViewState extends State<CalculatorView>
    with RouteAware, DrawerMenuPart, CustomTextPart, PopupPart, CardPart {
  EatingType chosenMealTime = EatingType.breakfast;
  DateTime chosenDateTime;
  DateTime beginDateTime;

  DailyEating dailyMealTime;

  BuildContext _context;

  /// State lifecycle ///

  @override
  void initState() {
    super.initState();

    chosenDateTime = widget.dateService.toDayBeggining(DateTime.now());
    beginDateTime = chosenDateTime.subtract(Duration(days: 15));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void didPop() {
    _saveDailyMealTime();
  }

  @override
  void didPushNext() {
    _saveDailyMealTime();
  }

  @override
  Widget build(BuildContext context) {
    widget.calculatorBloc.eventListener.add(GetDailyEating(chosenDateTime));

    _context = context;

    return Scaffold(
      appBar: AppBar(
        title: Text("Калькулятор диеты"),
      ),
      drawer: createDrawerMenuPart(context),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          createCard(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    createHeader("Дата"),
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
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                createHeader("Приём пищи"),
                _createMealTimeRow(),
              ],
            ),
          ),
          Expanded(
            child: createCard(
              StreamBuilder<DailyEatingState>(
                initialData: GettingDailyEating(),
                stream: widget.calculatorBloc.dailyEatings,
                builder: _createProductBlockBySnapshot
              )
            )
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget.routeObserver.unsubscribe(this);
    super.dispose();
  }

  /// Complex UI parts ///



  Widget _createTimePickerCalendar() {
    return FlatButton(
      onPressed: _pickTimeByCalendar,
      textColor: Colors.grey[110],
      child: Row(
        children: [
          Text("Указать на календаре"),
          _createIcon(Icons.date_range),
        ],
      ),
    );
  }

  Widget _createTimePickerRow() {
    int datepickerLength = DateTime.now().difference(beginDateTime).inDays + 1;

    var datepicker = DatePickerTimeline(
      chosenDateTime,
      onDateChange: _pickTime,
      locale: "ru",
      daysCount: datepickerLength,
      beginDate: beginDateTime,
    );

    return Row(
        children: [
          _createIcon(Icons.arrow_back_ios),
          Expanded(child: datepicker),
          _createIcon(Icons.arrow_forward_ios),
    ]);
  }

  Widget _createMealTimeRow() {
    return Row(
        children: [
          _createIcon(Icons.arrow_back_ios),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                  children:
                  MealTimeView.values.map(_createMealTimeButton).toList()
              ),
            ),
          ),
          _createIcon(Icons.arrow_forward_ios),
        ]
    );
  }

  Widget _createProductBlockBySnapshot(
      BuildContext context,
      AsyncSnapshot<CalculatorBlocState> snapshot) {
    if (!snapshot.hasError && snapshot.hasData && snapshot.data is GotDailyEating) {
      GotDailyEating state = snapshot.data;
      dailyMealTime = state.dailyEating;
      SingleEating singleEating = dailyMealTime.singleEatings[chosenMealTime];

      return Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
              children: [
                createHeader("Блюда"),
                Spacer(),
                _createAddProductButton(singleEating)
              ]
          ),
          _createProductList(singleEating)
        ],
      );
    } else {
      // TODO: Custom load
      return createHeader("Загрузка...");
    }
  }

  Widget _createProductList(SingleEating singleEating) {
    if (singleEating != null) {
      return Expanded(
        child: Container(
          foregroundDecoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment(0.0, -1.0),
                  end: Alignment(0.0, -0.9),
                  colors: [Colors.white, Color.fromRGBO(255, 255, 255, 0.0)]
              )
          ),
          child: ListView.builder(
              itemCount: singleEating.dishes.length,
              itemBuilder: (context, index) {
                Dish dish = singleEating.dishes[index];

                return CalculatorSingleEatingView(
                    dish,
                    _createOnDishDelete(singleEating, dish)
                );
              }
          ),
        ),
      );
    } else {
      return Text("MENU IS NULL");
    }
  }

  /// Simple UI widgets ///

  Widget _createMealTimeButton(MealTimeView mealTimeView) {
    bool isChosen = chosenMealTime == mealTimeView.mealTime;

    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.0),
        child: FlatButton(
          onPressed: () => _pickMealType(mealTimeView),
          color: isChosen
              ? Colors.redAccent
              : Colors.grey[200],
          child: Text(mealTimeView.name),
        )
    );
  }

  Widget _createAddProductButton(SingleEating singleEating) {
    return FlatButton(
      onPressed: () => _addDish(singleEating),
      textColor: Colors.grey[110],
      child: Row(
        children: [
          Text("Добавить"),
          _createIcon(Icons.add),
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

  /// Logic functionality ///

  _pickTimeByCalendar() async {
    DateTime pickedDateTime = await showDatePicker(
      context: _context,
      initialDate: chosenDateTime,
      firstDate: beginDateTime,
      lastDate: DateTime.now(),
      locale: Locale("ru")
    );

    _pickTime(pickedDateTime);
  }

  _pickTime(DateTime pickedDateTime) async {
    if (pickedDateTime != null) {
      _saveDailyMealTime();
      
      setState(() {
        chosenDateTime = pickedDateTime;
      });
    }
  }

  _pickMealType(MealTimeView mealTimeView) {
    if (mealTimeView != null) {
      _saveDailyMealTime();

      setState(() {
        chosenMealTime = mealTimeView.mealTime;
      });
    }
  }

  _addDish(SingleEating singleEating) {
    Navigator
        .of(context)
        .push(CalculatorProductListViewRoute(
            onChoose: _createOnProductChoose(singleEating)
        ));
  }
  
  _saveDailyMealTime() {
    print('CalculatorView: Saved!');
    widget.calculatorBloc.eventListener.add(SaveDailyEating(dailyMealTime));
  }

  // TODO: Create id generator
  Future<bool> Function(Product) _createOnProductChoose(SingleEating singleEating) {
    return (product) async {
      TextEditingController weightController = TextEditingController();

      await createInputPopup(context, "Введите массу в граммах", weightController, true);

      try {
        double weight = double.parse(weightController.text);

        setState(() {
          singleEating.dishes.add(Dish(null, product, weight: weight));
        });

        return true;
      } catch (exception) {
        createWarningPopup(context, "Введено неверное значение!");

        return false;
      }
    };
  }
  
  bool Function() _createOnDishDelete(SingleEating singleEating, Dish dish) {
    return () {
      setState(() {
        singleEating.dishes.remove(dish);
      });
      
      return true;
    };
  }

  Widget _createSmoothBorder({bool leftSide = true, double width = 20.0}) {
    Color white = Colors.white;
    Color fullOpacity = Color.fromRGBO(255, 255, 255, 0.0);
    
    Alignment gradientAlignBegin = leftSide
        ? Alignment.centerLeft 
        : Alignment.centerRight;
    Alignment gradientAlignEnd = leftSide
        ? Alignment.centerRight
        : Alignment.centerLeft;

    TextDirection gradientDirection = leftSide
        ? TextDirection.ltr
        : TextDirection.rtl;

    return Positioned.directional(
      textDirection: gradientDirection,
      top: 0.0,
      bottom: 0.0,
      start: 0.0,
      width: width,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: gradientAlignBegin,
            end: gradientAlignEnd,
            colors: [white, fullOpacity],
            tileMode: TileMode.clamp,
          ),
        ),
      )
    );
  }
}

class CalculatorViewRoute extends CupertinoPageRoute {
  CalculatorViewRoute()
      : super(builder: (BuildContext context) => CalculatorView());
}
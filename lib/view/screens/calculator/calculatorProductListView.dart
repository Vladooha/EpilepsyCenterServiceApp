import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/bloc/calculator/calculatorBloc.dart';
import 'package:frontend/bloc/calculator/calculatorBlocEvent.dart';
import 'package:frontend/bloc/calculator/calculatorBlocState.dart';
import 'package:frontend/model/calculator/product.dart';
import 'package:frontend/service/ioc/blocContainerService.dart';
import 'package:frontend/view/screens/calculator/calculatorProductListPosition.dart';
import 'package:frontend/view/screens/calculator/calculatorProductView.dart';
import 'package:frontend/view/uiparts/cardPart.dart';
import 'package:frontend/view/uiparts/drawerMenuPart.dart';

class CalculatorProductListView extends StatefulWidget {
  final CalculatorBloc calculatorBloc = BlocContainerService.instance.getAndInit(CalculatorBloc.BLOC_NAME);

  final Future<bool> Function(Product) onChoose;

  final TextEditingController searchController = TextEditingController();

  CalculatorProductListView({this.onChoose}) {
    calculatorBloc.eventListener.add(GetProducts());
  }

  @override
  State<StatefulWidget> createState() => CalculatorProductListViewState();
}

class CalculatorProductListViewState extends State<CalculatorProductListView>
    with DrawerMenuPart, CardPart {
  String query = null;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProductState>(
      initialData: widget.calculatorBloc.lastProducts,
      stream: widget.calculatorBloc.products,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Список продуктов"),
          ),
          drawer: createDrawerMenuPart(context),
          body: _createBody(context, snapshot)
        );
      }
    );
  }

  _createBody(BuildContext context, AsyncSnapshot<ProductState> snapshot) {
    if (snapshot.hasData && snapshot.data is GotProducts) {
      GotProducts productsState = snapshot.data as GotProducts;
      List<Product> filteredProducts = query != null
        ? productsState.products.where(_isMatchingQuery)
                .toList()
        : productsState.products;

      return createCard(
          Column(
            children: [
              Padding(
                  padding: EdgeInsets.all(10.0),
                  child: _createSearchRow()
              ),
              Expanded(
                child: Container(
                  foregroundDecoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment(0.0, -1.0),
                          end: Alignment(0.0, -0.9),
                          colors: [Colors.white, Color.fromRGBO(255, 255, 255, 0.0)]
                      )
                  ),
                  child: ListView.builder(
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        return CalculatorProductListPosition(
                            filteredProducts[index],
                            onChoose: widget.onChoose
                        );
                      }
                  ),
                ),
              )
            ]
          )
      );
    } else {
      return createCard(Text("Загрузка..."));
    }
  }

  _createSearchRow() {
    // TODO: Stream search
    List<Widget> children = [];
    children.add(
        Flexible(
          child: TextField(
            onChanged: (value) {
              setState(() {
                query = widget.searchController.text;
              });
            },
            controller: widget.searchController,
            decoration: InputDecoration(
                labelText: "Поиск",
                hintText: "Поиск",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)
                    )
                )
            ),
          ),
        )
    );

    if (widget.onChoose == null) {
      children.add(
        GestureDetector(
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Icon(
              Icons.add,
              size: 32.0,
              color: Colors.red,
            ),
          ),
          onTap: _openProductCreation,
        )
      );
    }

    return Row(
        mainAxisSize: MainAxisSize.min,
        children: children
      );
  }

  bool _isMatchingQuery(Product product) {
    String queryPayload = query.trim().toLowerCase();
    String namePayload = product.name.trim().toLowerCase();

    return namePayload.contains(queryPayload);
  }

  _openProductCreation() {
    Product newProduct = Product(null);

    Navigator
        .of(context)
        .push(CalculatorProductViewRoute(newProduct, isNewProduct: true));
  }
}

class CalculatorProductListViewRoute extends CupertinoPageRoute {
  CalculatorProductListViewRoute({Future<bool> Function(Product) onChoose})
      : super(builder: (BuildContext context) => CalculatorProductListView(onChoose: onChoose));
}
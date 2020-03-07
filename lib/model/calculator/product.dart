class Product {
  static const double NORMALIZED_WEIGHT_GRAMM = 100.0;
  static const int PRECISION = 3;
  
  final String id;
  String name;

  double _proteins;
  double _fats;
  double _carbohydrates;

  double _cholesterol;
  double _sodium;
  double _ballast;

  Product(
      this.id, {
        this.name,

        num proteins = 0.0,
        num fats = 0.0,
        num carbohydrates = 0.0,

        num cholesterol = 0.0,
        num sodium = 0.0,
        num ballast = 0.0
      }) {
    setProteins(proteins.toDouble());
    setFats(fats.toDouble());
    setCarbohydrates(carbohydrates.toDouble());

    setCholesterol(cholesterol.toDouble());
    setSodium(sodium.toDouble());
    setBallast(ballast.toDouble());
  }

  double getProteins({double weight = NORMALIZED_WEIGHT_GRAMM}) => _summarize(_proteins, weight: weight);
  double getFats({double weight = NORMALIZED_WEIGHT_GRAMM}) => _summarize(_fats, weight: weight);
  double getCarbohydrates({double weight = NORMALIZED_WEIGHT_GRAMM}) => _summarize(_carbohydrates, weight: weight);

  void setProteins(double value, {double weight = NORMALIZED_WEIGHT_GRAMM}) => _proteins = _normalize(value, weight: weight);
  void setFats(double value, {double weight = NORMALIZED_WEIGHT_GRAMM}) => _fats = _normalize(value, weight: weight);
  void setCarbohydrates(double value, {double weight = NORMALIZED_WEIGHT_GRAMM}) => _carbohydrates = _normalize(value, weight: weight);



  double getCholesterol({double weight = NORMALIZED_WEIGHT_GRAMM}) => _summarize(_cholesterol, weight: weight);
  double getSodium({double weight = NORMALIZED_WEIGHT_GRAMM}) => _summarize(_sodium, weight: weight);
  double getBallast({double weight = NORMALIZED_WEIGHT_GRAMM}) => _summarize(_ballast, weight: weight);
  
  void setCholesterol(double value, {double weight = NORMALIZED_WEIGHT_GRAMM}) => _cholesterol =  _normalize(value, weight: weight);
  void setSodium(double value, {double weight = NORMALIZED_WEIGHT_GRAMM}) => _sodium =  _normalize(value, weight: weight);
  void setBallast(double value, {double weight = NORMALIZED_WEIGHT_GRAMM}) => _ballast =  _normalize(value, weight: weight);


  double _summarize(double value, {double weight = NORMALIZED_WEIGHT_GRAMM})
    => _round(value / NORMALIZED_WEIGHT_GRAMM * weight);
  double _normalize(double value, {double weight = NORMALIZED_WEIGHT_GRAMM})
    => _round(value / weight * NORMALIZED_WEIGHT_GRAMM);

  double _round(double value, {int precision = PRECISION})
    => double.parse(value.toStringAsFixed(precision));
}
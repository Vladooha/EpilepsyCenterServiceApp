import 'package:frontend/service/ioc/abstractBloc.dart';

/// IoC realisation for BLoCs
///
/// Contains map of BLoC classes and their dependencies on each other
/// for safe injecting, initialization and disposing
class BlocContainerService {
  static final BlocContainerService instance = BlocContainerService._internal();

  /// BLoC name -> BLoC
  Map<String, AbstractBloc> _blocMap = {};
  /// BLoC-dependency name -> BLoC-child names
  Map<String, List<String>> _dependencyMap = {};

  BlocContainerService._internal();

  /// Adding [bloc] to container
  /// if container doesn't have another with [blocName]
  ///
  /// [bloc] cannot be added if it has dependencies
  /// that wasn't added to container yet
  ///
  /// If [blocName] isn't passed, uses [bloc.name] instead
  bool addIfAbcent(AbstractBloc bloc, {String blocName}) {
    blocName = blocName ?? bloc.name;

    if (!_blocMap.containsKey(blocName)) {
      return addOrReplace(bloc, blocName: blocName);
    }
    
    return false;
  }

  /// Adding or replacing BLoC in container with [blocName] by [bloc]
  /// BLoC with [blocName] cannot be replaced if any other BLoC
  /// has dependency on [bloc]
  ///
  /// [bloc] cannot be added or replaced if it has dependencies
  /// that wasn't added to container yet
  ///
  /// If [blocName] isn't passed, uses [bloc.name] instead
  bool addOrReplace(AbstractBloc bloc, {String blocName}) {
    blocName = blocName ?? bloc.name;

    var childBlocs = _dependencyMap[blocName];
    if (childBlocs == null || childBlocs.isEmpty) {
      _blocMap[blocName] = bloc;
      _dependencyMap[blocName] = [];

      return true;
    }

    return false;
  }

  /// Each BLoC with name contained in [dependencyNames] become
  /// a dependency for BLoC with [blocName]
  /// 
  /// If [dependencyNames] contains BLoC's name which wasn't added yet, all 
  /// dependency list would be rejected and nothing would be changed
  ///
  /// IMPORTANT: This method cannot resolve cyclic dependencies, be careful
  bool addDependency(String blocName, List<String> dependencyNames) {
    bool noUnknownDependences = (dependencyNames ?? []).any(
            (dependency) => _dependencyMap.containsKey(dependency));

    if (noUnknownDependences) {
      dependencyNames.forEach((dependency) {
        _dependencyMap[dependency].add(blocName);
      });

      return true;
    }

    return false;
  }

  /// Returns BLoC with [blocName] if it was added before and null instead
  AbstractBloc get(String blocName) {
    return _blocMap[blocName];
  }

  /// Returns BLoC with [blocName] if it was added before and null instead
  ///
  /// If BLoC was found and had been disposed before,
  /// it would be re-initialised
  AbstractBloc getAndInit(String blocName) {
    AbstractBloc bloc = get(blocName);

    if (bloc != null && bloc.isDisposed) {
      bloc.init();
    }

    return bloc;
  }

  /// Disposing all BLoCs in container
  void disposeAll() {
    _blocMap.values.forEach((bloc) => dispose(bloc.name, false));
  }

  /// Disposing BLoC with [blocName]
  ///
  /// [safe] mode - disposing all BLoC-child of BLoC-dependency
  /// with [blocName] (true by default)
  ///
  /// IMPORTANT: In case of cyclic dependency and [safe] mode enabled
  /// would never be executed. Use unsafe mode to break cyclic dependencies
  void dispose(String blocName, [bool safe = true]) {
    print('$blocName disposing...');

    if (safe && _dependencyMap.containsKey(blocName)) {
      _dependencyMap[blocName].forEach(
              (dependency) => _blocMap[dependency].dispose());
    }

    AbstractBloc bloc = get(blocName);
    if (bloc != null) {
      bloc.dispose();
    }
  }
}
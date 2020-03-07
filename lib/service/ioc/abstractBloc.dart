import 'package:flutter/cupertino.dart';

/// Provides basic BLoC functionality - initialisation and disposing for
/// tracking lifecycle status
abstract class AbstractBloc {
  bool _isDisposed = true;

  bool get isDisposed => _isDisposed;
  String get name;

  /// Contains [name]'s of all other BLoCs-dependencies
  /// Used by BlocContainerServices for dependency management
  List<String> get dependencyNames => [];


  /// This method should be overriden by child
  /// Returns `true` if stream wasn't initialized or was disposed,
  /// based on [_isDisposed] status
  ///
  /// Stream init must be called only if this super method returns `true`
  @mustCallSuper
  bool init() {
    if (isDisposed) {
      _isDisposed = false;

      return true;
    }

    return false;
  }

  /// This method should be overriden in child.
  /// Returns `true` if stream was initialized, based on [_isDisposed] status
  ///
  /// Stream closing must be called only if this super method returns `true`
  @mustCallSuper
  bool dispose() {
    if (!_isDisposed) {
      _isDisposed = true;

      return true;
    }

    return false;
  }
}
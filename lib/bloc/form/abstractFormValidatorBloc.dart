import 'dart:async';

import 'package:frontend/model/common/errorContainer.dart';
import 'package:frontend/service/ioc/abstractBloc.dart';
import 'package:rxdart/rxdart.dart';

abstract class AbstractFormValidatorBloc extends AbstractBloc {
  List<Stream> get formFieldStreamList;

  Stream<bool> get formValidity => Rx.combineLatest(
      formFieldStreamList,
      (valueList) => true);

  createTransformer(List<String> Function(String) validator) {
    return StreamTransformer<String, String>.fromHandlers(
      handleData: (value, sink) {
        List<String> errors = validator(value);

        if (errors == null || errors.isEmpty) {
          sink.add(value);
        } else {
          sink.addError(ErrorContainer(errorList: errors));
        }
      }
    );
  }
}
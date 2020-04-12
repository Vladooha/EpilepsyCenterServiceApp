import 'package:frontend/service/api/apiService.dart';

class ErrorContainer {
  final List<String> errorList;

  ErrorContainer({this.errorList = const []});

  factory ErrorContainer.fromJson(Map<String, dynamic> jsonMap) {
    List<String> jsonErrorList = jsonMap != null ? jsonMap["errorList"] ?? [] : [];

    return ErrorContainer(errorList: jsonErrorList);
  }

  bool get hasErrors => errorList.isNotEmpty;

  concat(ErrorContainer errorContainer) {
    errorList.addAll(errorContainer.errorList);
  }

  @override
  String toString() => errorList.join("\n");
}

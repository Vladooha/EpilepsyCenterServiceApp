class DateService {
  DateTime toDayBeggining(DateTime dateTime)
      => DateTime(dateTime.year, dateTime.month, dateTime.day);
}
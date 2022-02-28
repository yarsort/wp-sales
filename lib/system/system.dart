import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

doubleToString(double sum) {
  var f = NumberFormat("##0.00", "en_US");
  return (f.format(sum).toString());
}

doubleThreeToString(double sum) {
  var f = NumberFormat("##0.000", "en_US");
  return (f.format(sum).toString());
}

shortDateToString(DateTime date) {
  var f = DateFormat('dd.MM.yyyy');
  return (f.format(date).toString());
}

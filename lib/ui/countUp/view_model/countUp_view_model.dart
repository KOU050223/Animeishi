import 'package:flutter/material.dart';
import '../../../model/counter_model.dart';

class CountUpViewModel extends ChangeNotifier {
  final CounterModel _counterModel = CounterModel();

  int get counter => _counterModel.counter;

  void incrementCounter() {
    _counterModel.incrementCounter();
    notifyListeners();
  }
}

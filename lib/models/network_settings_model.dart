import 'package:blowjobboard/data/error_simulation.dart';
import 'package:flutter/foundation.dart';

class NetworkSettingsModel extends ChangeNotifier {
  NetworkSettingsModel(this._errorSimulation);

  final ErrorSimulation _errorSimulation;

  bool get simulateError => _errorSimulation.simulateError;

  void setSimulateError(bool value) {
    if (simulateError == value) return;

    _errorSimulation.simulateError = value;
    notifyListeners();
  }
}

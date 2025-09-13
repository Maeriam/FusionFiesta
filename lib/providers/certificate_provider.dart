import 'package:flutter/material.dart';
import '../models/certificate_model.dart';
import '../services/certificate_service.dart';

class CertificateProvider with ChangeNotifier {
  List<Certificate> _certificates = [];

  List<Certificate> get certificates => _certificates;

  Future<void> fetchCertificates(String token) async {
    _certificates = await CertificateService.getCertificates(token);
    notifyListeners();
  }
}

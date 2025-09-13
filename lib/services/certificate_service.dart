import '../models/certificate_model.dart';
import 'api_service.dart';

class CertificateService {
  static Future<List<Certificate>> getCertificates(String token) async {
    final data = await ApiService.get("certificates", token: token);
    return (data as List).map((c) => Certificate.fromJson(c)).toList();
  }
}

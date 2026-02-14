import 'api_service.dart';

class PaymentService {
  final ApiService _api;

  PaymentService(this._api);

  Future<Map<String, dynamic>> createPaymentOrder(int applicationId, int adminId) async {
    // Returns PaymentDto
    return await _api.post(
      '/admin/payments/create',
      queryParams: {
        'applicationId': applicationId.toString(),
        'adminId': adminId.toString(),
      },
    );
  }

  Future<Map<String, dynamic>> confirmPayment(String reference, String channel, String externalId) async {
    return await _api.post(
      '/admin/payments/confirm',
      body: {
        'paymentReference': reference,
        'channel': channel,
        'externalTransactionId': externalId,
      },
    );
  }

  Future<List<dynamic>> getPaymentsByApplication(int applicationId) async {
    return await _api.getList('/admin/payments/by-application/$applicationId');
  }
}

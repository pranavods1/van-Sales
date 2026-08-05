class InvoiceModel {
  final int id;
  final String invoiceNo;
  final String inDate;
  final double grandTotal;
  final String customerName;
  final int status;

  InvoiceModel({
    required this.id,
    required this.invoiceNo,
    required this.inDate,
    required this.grandTotal,
    required this.customerName,
    required this.status,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    String customerName = 'Unknown Customer';
    if (json['customer'] != null && json['customer'] is List && (json['customer'] as List).isNotEmpty) {
      customerName = json['customer'][0]['name'] ?? 'Unknown Customer';
    }

    return InvoiceModel(
      id: json['id'] ?? 0,
      invoiceNo: json['invoice_no'] ?? '',
      inDate: json['in_date'] ?? '',
      grandTotal: double.tryParse(json['grand_total'].toString()) ?? 0.0,
      customerName: customerName,
      status: json['status'] ?? 0,
    );
  }
}

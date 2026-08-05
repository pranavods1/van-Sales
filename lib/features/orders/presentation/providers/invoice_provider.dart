import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/order_repository.dart';
import '../providers/order_provider.dart';
import '../../data/models/invoice_model.dart';

final invoiceListProvider = FutureProvider<List<InvoiceModel>>((ref) async {
  final repository = ref.watch(orderRepositoryProvider);
  return await repository.getInvoices();
});

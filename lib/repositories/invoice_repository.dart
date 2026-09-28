import '../models/invoice.dart';

class InvoiceRepository {
  final List<Invoice> _invoices = [];

  void addInvoice(Invoice invoice) {
    _invoices.add(invoice);
  }

  void updateInvoice(Invoice invoice) {
    final index = _invoices.indexWhere((item) => item.id == invoice.id);

    if (index != -1) {
      _invoices[index] = invoice;
    }
  }

  List<Invoice> getAllInvoices() {
    return List.unmodifiable(_invoices);
  }

  Invoice? getInvoiceById(String id) {
    for (final invoice in _invoices) {
      if (invoice.id == id) {
        return invoice;
      }
    }

    return null;
  }

  int get invoiceCount => _invoices.length;
}

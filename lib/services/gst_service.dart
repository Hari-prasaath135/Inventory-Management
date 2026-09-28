class GstResult {
  final double cgst;
  final double sgst;
  final double igst;
  final double totalGst;
  final double grandTotal;

  GstResult({
    required this.cgst,
    required this.sgst,
    required this.igst,
    required this.totalGst,
    required this.grandTotal,
  });
}

class GstService {
  static GstResult calculate({
    required double subtotal,
    required double gstRate,
    required bool isInterstate,
  }) {
    double cgst = 0;
    double sgst = 0;
    double igst = 0;

    if (isInterstate) {
      igst = subtotal * gstRate / 100;
    } else {
      cgst = subtotal * (gstRate / 2) / 100;
      sgst = subtotal * (gstRate / 2) / 100;
    }

    final totalGst = cgst + sgst + igst;
    final grandTotal = subtotal + totalGst;

    return GstResult(
      cgst: cgst,
      sgst: sgst,
      igst: igst,
      totalGst: totalGst,
      grandTotal: grandTotal,
    );
  }
}

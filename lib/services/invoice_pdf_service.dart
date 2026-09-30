import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/invoice.dart';
import '../models/bill_item.dart';

class InvoicePdfService {
  // ============================================================
  // SHOP DETAILS
  // ============================================================

  static const String shopName = 'Sree Lakshmi Cards';

  static const String shopTagline =
      'WHOLESALE & RETAIL DEALER IN';

  static const String shopDescription =
      'ALL KINDS OF GREETING CARDS, INVITATION CARDS & RELATED ITEMS';

  static const String address =
      'Near KBS Coffe Shop, Chetty Street,\n'
      ' Pondicherry - 605001';

  static const String email =
      'sreelakshmicards@gmail.com';
  static const String mobile =
    'Mobile: +91 90423 80305';
  static const String gstin =
      '34BPPPA3805N2ZQ';

  static const String placeOfSupply =
      'Puducherry (34)';

  // ============================================================
  // MAIN PDF FUNCTION
  // ============================================================

  static Future<void> generateInvoicePdf(
    Invoice invoice,
  ) async {
    final pdf = pw.Document();

    // ------------------------------------------------------------
    // Load Sri Lakshmi PNG
    // ------------------------------------------------------------

    final lakshmiImage = pw.MemoryImage(
      (await rootBundle.load(
        'assets/images/sri_lakshmi.png',
      ))
          .buffer
          .asUint8List(),
    );

    // ------------------------------------------------------------
    // Load Unicode fonts
    // Required for ₹ symbol
    // ------------------------------------------------------------

    final regularFont = pw.Font.ttf(
      await rootBundle.load(
        'assets/fonts/NotoSans-Regular.ttf',
      ),
    );

    final boldFont = pw.Font.ttf(
      await rootBundle.load(
        'assets/fonts/NotoSans-Bold.ttf',
      ),
    );

    final pdfTheme = pw.ThemeData.withFont(
      base: regularFont,
      bold: boldFont,
    );

    // ------------------------------------------------------------
    // Create A4 page
    // ------------------------------------------------------------

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        theme: pdfTheme,
        build: (context) {
          return _buildInvoicePage(
            invoice,
            lakshmiImage,
          );
        },
      ),
    );

    // ------------------------------------------------------------
    // Open print / save PDF preview
    // ------------------------------------------------------------

    await Printing.layoutPdf(
      onLayout: (format) async {
        return pdf.save();
      },
    );
  }

  // ============================================================
  // COMPLETE INVOICE
  // ============================================================

  static pw.Widget _buildInvoicePage(
    Invoice invoice,
    pw.ImageProvider lakshmiImage,
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: PdfColors.grey600,
          width: 0.7,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment:
            pw.CrossAxisAlignment.stretch,
        children: [
          // ------------------------------------------------------
          // HEADER
          // ------------------------------------------------------

          _buildHeader(lakshmiImage),

          pw.SizedBox(height: 10),

          // ------------------------------------------------------
          // TAX INVOICE
          // ------------------------------------------------------

          _buildTaxInvoiceHeader(),

          pw.SizedBox(height: 12),

          // ------------------------------------------------------
          // BILL TO + INVOICE DETAILS
          // ------------------------------------------------------

          _buildCustomerAndInvoiceDetails(invoice),

          pw.SizedBox(height: 12),

          // ------------------------------------------------------
          // PRODUCTS
          // ------------------------------------------------------

          _buildProductTable(invoice.items),

          pw.SizedBox(height: 12),

          // ------------------------------------------------------
          // TOTALS
          // ------------------------------------------------------

          _buildTotalsSection(invoice),

          pw.SizedBox(height: 12),

          // ------------------------------------------------------
          // NOTES
          // ------------------------------------------------------

          _buildNotes(),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  static pw.Widget _buildHeader(
    pw.ImageProvider lakshmiImage,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(10),
      child: pw.Column(
        children: [
          // Sri Lakshmi image
          pw.Container(
            height: 75,
            alignment: pw.Alignment.center,
            child: pw.Image(
              lakshmiImage,
              height: 72,
              fit: pw.BoxFit.contain,
            ),
          ),

          pw.SizedBox(height: 5),

          // Shop name
          pw.Text(
            shopName.toUpperCase(),
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              fontSize: 17,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 3),

          // Tagline
          pw.Text(
            shopTagline,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              fontSize: 7.5,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 2),

          // Description
          pw.Text(
            shopDescription,
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(
              fontSize: 7,
            ),
          ),

          pw.SizedBox(height: 5),

          // Address
          pw.Text(
            address,
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(
              fontSize: 7.5,
            ),
          ),

          pw.SizedBox(height: 2),

          // Email
          pw.Text(
            email,
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(
              fontSize: 7.5,
            ),
          ),

          pw.SizedBox(height: 2),
          // Mobile
            pw.Text(
              mobile,
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(
                fontSize: 7.5,
              ),
            ),

            pw.SizedBox(height: 2),
                      // GSTIN
          pw.Text(
            'GSTIN: $gstin',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TAX INVOICE HEADER
  // ============================================================

  static pw.Widget _buildTaxInvoiceHeader() {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: PdfColors.grey600,
          width: 0.7,
        ),
      ),
      child: pw.Center(
        child: pw.Text(
          'TAX INVOICE',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BILL TO + INVOICE DETAILS
  // ============================================================

  static pw.Widget _buildCustomerAndInvoiceDetails(
    Invoice invoice,
  ) {
    final date = _formatDate(invoice.createdAt);
    final time = _formatTime(invoice.createdAt);

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 10,
      ),
      child: pw.Row(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,
        children: [
          // ------------------------------------------------------
          // BILL TO
          // ------------------------------------------------------

          pw.Expanded(
            flex: 1,
            child: pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                  color: PdfColors.grey500,
                  width: 0.6,
                ),
              ),
              child: pw.Column(
                crossAxisAlignment:
                    pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Bill To:',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),

                  pw.SizedBox(height: 8),

                  _customerLine(),

                  _customerLine(),

                  _customerLine(),
                ],
              ),
            ),
          ),

          pw.SizedBox(width: 10),

          // ------------------------------------------------------
          // INVOICE DETAILS
          // ------------------------------------------------------

          pw.Expanded(
            flex: 1,
            child: pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                  color: PdfColors.grey500,
                  width: 0.6,
                ),
              ),
              child: pw.Column(
                children: [
                  _detailRow(
                    'Invoice No.',
                    invoice.invoiceNumber,
                  ),

                  _detailRow(
                    'Date',
                    date,
                  ),

                  _detailRow(
                    'Time',
                    time,
                  ),

                  _detailRow(
                    'Place of Supply',
                    placeOfSupply,
                    last: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CUSTOMER LINE
  // ============================================================

  static pw.Widget _customerLine() {
    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(
        bottom: 9,
      ),
      child: pw.Divider(
        color: PdfColors.grey500,
        thickness: 0.5,
      ),
    );
  }

  // ============================================================
  // INVOICE DETAIL ROW
  // ============================================================

  static pw.Widget _detailRow(
    String label,
    String value, {
    bool last = false,
  }) {
    return pw.Container(
      decoration: last
          ? null
          : pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(
                  color: PdfColors.grey400,
                  width: 0.5,
                ),
              ),
            ),
      child: pw.Row(
        children: [
          pw.Container(
            width: 80,
            padding: const pw.EdgeInsets.all(7),
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),

          pw.Container(
            width: 0.5,
            height: 28,
            color: PdfColors.grey400,
          ),

          pw.Expanded(
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(7),
              child: pw.Text(
                value,
                style: const pw.TextStyle(
                  fontSize: 8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PRODUCT TABLE
  // ============================================================

  static pw.Widget _buildProductTable(
    List<BillItem> items,
  ) {
    final rows = <List<String>>[];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];

      rows.add([
        '${i + 1}',
        item.product.name,
        item.quantity.toString(),
        '₹ ${_money(item.product.price)}',
        '₹ ${_money(item.subtotal)}',
      ]);
    }

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 10,
      ),
      child: pw.Table.fromTextArray(
        headers: [
          'S.No',
          'Description of Goods',
          'Quantity',
          'Unit Price (₹)',
          'Amount (₹)',
        ],
        data: rows,

        // Simple black/grey table
        border: pw.TableBorder.all(
          color: PdfColors.grey600,
          width: 0.5,
        ),

        headerDecoration:
            const pw.BoxDecoration(
          color: PdfColors.grey300,
        ),

        headerStyle: pw.TextStyle(
          fontSize: 8,
          fontWeight: pw.FontWeight.bold,
        ),

        cellStyle: const pw.TextStyle(
          fontSize: 8,
        ),

        cellPadding:
            const pw.EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 6,
        ),

        columnWidths: {
          0: const pw.FixedColumnWidth(35),
          1: const pw.FlexColumnWidth(4.5),
          2: const pw.FixedColumnWidth(55),
          3: const pw.FixedColumnWidth(75),
          4: const pw.FixedColumnWidth(80),
        },

        cellAlignments: {
          0: pw.Alignment.center,
          1: pw.Alignment.centerLeft,
          2: pw.Alignment.center,
          3: pw.Alignment.centerRight,
          4: pw.Alignment.centerRight,
        },
      ),
    );
  }

  // ============================================================
  // TOTALS
  // ============================================================

  static pw.Widget _buildTotalsSection(
    Invoice invoice,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 10,
      ),
      child: pw.Row(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,
        children: [
          // ------------------------------------------------------
          // AMOUNT IN WORDS
          // ------------------------------------------------------

          pw.Expanded(
            flex: 6,
            child: pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                  color: PdfColors.grey500,
                  width: 0.5,
                ),
              ),
              child: pw.Column(
                crossAxisAlignment:
                    pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Invoice Amount In Words:',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),

                  pw.SizedBox(height: 8),

                  pw.Text(
                    '${numberToWords(invoice.grandTotal)} Rupees Only',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          pw.SizedBox(width: 10),

          // ------------------------------------------------------
          // TOTALS
          // ------------------------------------------------------

          pw.Expanded(
            flex: 5,
            child: pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                  color: PdfColors.grey500,
                  width: 0.5,
                ),
              ),
              child: pw.Column(
                children: [
                  _totalRow(
                    'Sub Total',
                    invoice.subtotal,
                  ),

                  if (invoice.cgst > 0)
                    _totalRow(
                      'CGST',
                      invoice.cgst,
                    ),

                  if (invoice.sgst > 0)
                    _totalRow(
                      'SGST',
                      invoice.sgst,
                    ),

                  if (invoice.igst > 0)
                    _totalRow(
                      'IGST',
                      invoice.igst,
                    ),

                  pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    decoration:
                        const pw.BoxDecoration(
                      border: pw.Border(
                        top: pw.BorderSide(
                          color: PdfColors.grey600,
                          width: 0.7,
                        ),
                      ),
                    ),
                    child: pw.Row(
                      mainAxisAlignment:
                          pw.MainAxisAlignment
                              .spaceBetween,
                      children: [
                        pw.Text(
                          'TOTAL',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight:
                                pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          '₹ ${_money(invoice.grandTotal)}',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight:
                                pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SINGLE TOTAL ROW
  // ============================================================

  static pw.Widget _totalRow(
    String label,
    double value,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfColors.grey400,
            width: 0.5,
          ),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment:
            pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(
              fontSize: 8,
            ),
          ),
          pw.Text(
            '₹ ${_money(value)}',
            style: const pw.TextStyle(
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NOTES
  // ============================================================

  static pw.Widget _buildNotes() {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      child: pw.Container(
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(
            color: PdfColors.grey500,
            width: 0.5,
          ),
        ),
        child: pw.Column(
          crossAxisAlignment:
              pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Notes:',
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 4),

            pw.Text(
              'Goods once sold will not be taken back or exchanged.',
              style: const pw.TextStyle(
                fontSize: 7.5,
              ),
            ),

            pw.SizedBox(height: 2),

            pw.Text(
              'Please make the payment by cheque/cash/UPI.',
              style: const pw.TextStyle(
                fontSize: 7.5,
              ),
            ),

            pw.SizedBox(height: 2),

            pw.Text(
              'GST is payable on Reverse Charge: No',
              style: const pw.TextStyle(
                fontSize: 7.5,
              ),
            ),

            pw.SizedBox(height: 6),

            pw.Center(
              child: pw.Text(
                'Thank you for your business!',
                style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight:
                      pw.FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  static String _formatDate(
    DateTime date,
  ) {
    final day =
        date.day.toString().padLeft(2, '0');

    final month =
        date.month.toString().padLeft(2, '0');

    return '$day-$month-${date.year}';
  }

  // ============================================================
  // TIME FORMAT
  // ============================================================

  static String _formatTime(
    DateTime date,
  ) {
    int hour = date.hour;

    final minute =
        date.minute.toString().padLeft(2, '0');

    final period =
        hour >= 12 ? 'PM' : 'AM';

    hour = hour % 12;

    if (hour == 0) {
      hour = 12;
    }

    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  // ============================================================
  // MONEY FORMAT
  // ============================================================

  static String _money(
    double value,
  ) {
    return value.toStringAsFixed(2);
  }

  // ============================================================
  // NUMBER TO WORDS
  // ============================================================

  static String numberToWords(
    double amount,
  ) {
    final rupees = amount.floor();

    final paise =
        ((amount - rupees) * 100).round();

    String result =
        _convertNumber(rupees);

    if (paise > 0) {
      result +=
          ' and ${_convertNumber(paise)} Paise';
    }

    return _capitalize(result);
  }

  // ============================================================
  // CONVERT NUMBER
  // ============================================================

  static String _convertNumber(
    int number,
  ) {
    if (number == 0) {
      return 'Zero';
    }

    if (number < 1000) {
      return _convertBelowThousand(number);
    }

    if (number < 100000) {
      final thousands =
          number ~/ 1000;

      final remainder =
          number % 1000;

      String result =
          '${_convertNumber(thousands)} Thousand';

      if (remainder > 0) {
        result +=
            ' ${_convertNumber(remainder)}';
      }

      return result;
    }

    if (number < 10000000) {
      final lakhs =
          number ~/ 100000;

      final remainder =
          number % 100000;

      String result =
          '${_convertNumber(lakhs)} Lakh';

      if (remainder > 0) {
        result +=
            ' ${_convertNumber(remainder)}';
      }

      return result;
    }

    final crores =
        number ~/ 10000000;

    final remainder =
        number % 10000000;

    String result =
        '${_convertNumber(crores)} Crore';

    if (remainder > 0) {
      result +=
          ' ${_convertNumber(remainder)}';
    }

    return result;
  }

  // ============================================================
  // BELOW THOUSAND
  // ============================================================

  static String _convertBelowThousand(
    int number,
  ) {
    const ones = [
      '',
      'One',
      'Two',
      'Three',
      'Four',
      'Five',
      'Six',
      'Seven',
      'Eight',
      'Nine',
      'Ten',
      'Eleven',
      'Twelve',
      'Thirteen',
      'Fourteen',
      'Fifteen',
      'Sixteen',
      'Seventeen',
      'Eighteen',
      'Nineteen',
    ];

    const tens = [
      '',
      '',
      'Twenty',
      'Thirty',
      'Forty',
      'Fifty',
      'Sixty',
      'Seventy',
      'Eighty',
      'Ninety',
    ];

    if (number < 20) {
      return ones[number];
    }

    if (number < 100) {
      final ten = number ~/ 10;
      final remainder = number % 10;

      if (remainder == 0) {
        return tens[ten];
      }

      return '${tens[ten]} ${ones[remainder]}';
    }

    final hundred = number ~/ 100;
    final remainder = number % 100;

    if (remainder == 0) {
      return '${ones[hundred]} Hundred';
    }

    return '${ones[hundred]} Hundred '
        '${_convertBelowThousand(remainder)}';
  }

  // ============================================================
  // CAPITALIZE
  // ============================================================

  static String _capitalize(
    String value,
  ) {
    if (value.isEmpty) {
      return value;
    }

    return value[0].toUpperCase() +
        value.substring(1);
  }
}
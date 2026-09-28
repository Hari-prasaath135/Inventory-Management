import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/invoice.dart';
import '../models/bill_item.dart';
import 'package:flutter/services.dart' show rootBundle;

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
      'Sri Vija Lakshmi, Pondicherry - 605001';

  static const String email =
      'sreelakshmicards@gmail.com';

  static const String gstin =
      '34BPPPA3805N2ZQ';

  static const String placeOfSupply =
      'Puducherry (34)';

  // ============================================================
  // COLORS
  // ============================================================

  static final PdfColor burgundy =
      PdfColor.fromHex('#8D1725');

  static final PdfColor darkBurgundy =
      PdfColor.fromHex('#650C18');

  static final PdfColor lightPink =
      PdfColor.fromHex('#F9EDEE');

  static final PdfColor gold =
      PdfColor.fromHex('#C99A3D');

  static final PdfColor darkText =
      PdfColor.fromHex('#101936');

  static final PdfColor lightBorder =
      PdfColor.fromHex('#D9C7C9');

  // ============================================================
  // MAIN FUNCTION
  // ============================================================

static Future<void> generateInvoicePdf(
  Invoice invoice,
) async {
  final pdf = pw.Document();

  final lakshmiImage = pw.MemoryImage(
    (await rootBundle.load(
      'assets/images/sri_lakshmi.png',
    ))
        .buffer
        .asUint8List(),
  );

  pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
       build: (context) {
  return _buildInvoicePage(
    invoice,
    lakshmiImage,
  );
},
      ),
    );

    // Opens the system print/PDF preview.
    await Printing.layoutPdf(
      onLayout: (format) async {
        return pdf.save();
      },
    );
  }

  // ============================================================
  // COMPLETE INVOICE PAGE
  // ============================================================

static pw.Widget _buildInvoicePage(
  Invoice invoice,
  pw.ImageProvider lakshmiImage,
) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: lightBorder,
          width: 0.7,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [

          // ----------------------------------------------------
          // HEADER
          // ----------------------------------------------------

         _buildHeader(lakshmiImage),

          pw.SizedBox(height: 8),

          // ----------------------------------------------------
          // TAX INVOICE BAR
          // ----------------------------------------------------

          _buildTaxInvoiceHeader(invoice),

          pw.SizedBox(height: 12),

          // ----------------------------------------------------
          // BILL TO + INVOICE DETAILS
          // ----------------------------------------------------

          _buildCustomerAndInvoiceDetails(invoice),

          pw.SizedBox(height: 12),

          // ----------------------------------------------------
          // PRODUCT TABLE
          // ----------------------------------------------------

          _buildProductTable(invoice.items),

          pw.SizedBox(height: 12),

          // ----------------------------------------------------
          // AMOUNT IN WORDS + TOTALS
          // ----------------------------------------------------

          _buildTotalsSection(invoice),

          pw.SizedBox(height: 12),

          // ----------------------------------------------------
          // NOTES + THANK YOU
          // ----------------------------------------------------

          _buildNotesAndFooter(),

          pw.SizedBox(height: 8),

          // ----------------------------------------------------
          // BOTTOM DECORATIVE FOOTER
          // ----------------------------------------------------

          _buildBottomFooter(),
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
  return pw.Container(
    padding: const pw.EdgeInsets.fromLTRB(
      18,
      8,
      18,
      8,
    ),
    child: pw.Column(
      children: [
        // Sri Lakshmi logo
        pw.Container(
          height: 90,
          alignment: pw.Alignment.center,
          child: pw.Image(
            lakshmiImage,
            height: 88,
            fit: pw.BoxFit.contain,
          ),
        ),

        pw.SizedBox(height: 4),

        pw.Divider(
          color: gold,
          thickness: 1,
        ),

        pw.SizedBox(height: 5),

        // Address
        pw.Text(
          address,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            color: darkText,
            fontSize: 8,
          ),
        ),

        pw.SizedBox(height: 4),

        // Email
        pw.Text(
          email,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            color: darkText,
            fontSize: 8,
          ),
        ),
      ],
    ),
  );
}

  // ============================================================
  // TAX INVOICE HEADER
  // ============================================================

  static pw.Widget _buildTaxInvoiceHeader(
    Invoice invoice,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(
        horizontal: 12,
      ),
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 9,
      ),
      decoration: pw.BoxDecoration(
        color: lightPink,
        borderRadius:
            pw.BorderRadius.circular(7),
        border: pw.Border.all(
          color: burgundy,
          width: 0.6,
        ),
      ),
      child: pw.Row(
        mainAxisAlignment:
            pw.MainAxisAlignment.spaceBetween,
        children: [

          pw.Column(
            crossAxisAlignment:
                pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'TAX INVOICE',
                style: pw.TextStyle(
                  color: burgundy,
                  fontSize: 19,
                  fontWeight:
                      pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'ORIGINAL FOR RECIPIENT',
                style: pw.TextStyle(
                  color: burgundy,
                  fontSize: 7,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),

          pw.Text(
            'GSTIN : $gstin',
            style: pw.TextStyle(
              color: darkText,
              fontSize: 11,
              fontWeight:
                  pw.FontWeight.bold,
            ),
          ),
        ],
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
        horizontal: 14,
      ),
      child: pw.Row(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,
        children: [

          // -------------------------------
          // BILL TO
          // -------------------------------

          pw.Expanded(
            flex: 5,
            child: pw.Column(
              crossAxisAlignment:
                  pw.CrossAxisAlignment.start,
              children: [

                pw.Text(
                  'Bill To :',
                  style: pw.TextStyle(
                    color: burgundy,
                    fontSize: 15,
                    fontWeight:
                        pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 10),

                _blankLine(),
                _blankLine(),
                _blankLine(),
                _blankLine(),
              ],
            ),
          ),

          pw.SizedBox(width: 15),

          // -------------------------------
          // INVOICE DETAILS
          // -------------------------------

          pw.Expanded(
            flex: 5,
            child: pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                  color: lightBorder,
                ),
                borderRadius:
                    pw.BorderRadius.circular(7),
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

  static pw.Widget _blankLine() {
    return pw.Container(
      margin:
          const pw.EdgeInsets.only(bottom: 10),
      width: double.infinity,
      child: pw.Divider(
        color: darkText,
        thickness: 0.4,
      ),
    );
  }

  static pw.Widget _detailRow(
    String label,
    String value, {
    bool last = false,
  }) {
    return pw.Container(
      decoration:pw.BoxDecoration(
        border: last
            ? null
            : pw.Border(
                bottom: pw.BorderSide(
                  color: lightBorder,
                  width: 0.6,
                ),
              ),
      ),
      child: pw.Row(
        children: [

          pw.Container(
            width: 82,
            padding:
                const pw.EdgeInsets.all(7),
            child: pw.Text(
              label,
              style: pw.TextStyle(
                color: darkText,
                fontSize: 8.5,
                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),
          ),

          pw.Container(
            width: 0.6,
            height: 30,
            color: lightBorder,
          ),

          pw.Expanded(
            child: pw.Padding(
              padding:
                  const pw.EdgeInsets.all(7),
              child: pw.Text(
                value,
                style: pw.TextStyle(
                  color: darkText,
                  fontSize: 8.5,
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
        _money(item.product.price),
        _money(item.subtotal),
      ]);
    }

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 12,
      ),
      child: pw.Table.fromTextArray(
        headers: [
          'S.No',
          'Description of Goods',
          'Quantity',
          'Unit Price\n(₹)',
          'Amount\n(₹)',
        ],
        data: rows,
        border: pw.TableBorder.all(
          color: lightBorder,
          width: 0.5,
        ),
        headerDecoration:
            pw.BoxDecoration(
          color: burgundy,
        ),
        headerStyle: pw.TextStyle(
          color: PdfColors.white,
          fontSize: 8,
          fontWeight:
              pw.FontWeight.bold,
        ),
        cellStyle: pw.TextStyle(
          color: darkText,
          fontSize: 8,
        ),
        cellPadding:
            const pw.EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 7,
        ),
        columnWidths: {
          0: const pw.FixedColumnWidth(35),
          1: const pw.FlexColumnWidth(4.8),
          2: const pw.FixedColumnWidth(55),
          3: const pw.FixedColumnWidth(70),
          4: const pw.FixedColumnWidth(75),
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
        horizontal: 14,
      ),
      child: pw.Row(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,
        children: [

          // -------------------------------
          // AMOUNT IN WORDS
          // -------------------------------

          pw.Expanded(
            flex: 6,
            child: pw.Container(
              padding:
                  const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                color: lightPink,
                borderRadius:
                    pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment:
                    pw.CrossAxisAlignment.start,
                children: [

                  pw.Text(
                    'Amount in Words :',
                    style: pw.TextStyle(
                      color: burgundy,
                      fontSize: 14,
                      fontWeight:
                          pw.FontWeight.bold,
                    ),
                  ),

                  pw.SizedBox(height: 10),

                  pw.Text(
                    '${numberToWords(invoice.grandTotal)} Rupees Only',
                    style: pw.TextStyle(
                      color: darkText,
                      fontSize: 10,
                      fontWeight:
                          pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          pw.SizedBox(width: 14),

          // -------------------------------
          // TOTALS TABLE
          // -------------------------------

          pw.Expanded(
            flex: 5,
            child: pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                  color: lightBorder,
                ),
                borderRadius:
                    pw.BorderRadius.circular(7),
              ),
              child: pw.Column(
                children: [

                  _totalRow(
                    'Sub Total',
                    _money(invoice.subtotal),
                  ),

                  if (invoice.sgst > 0)
                    _totalRow(
                      'SGST',
                      _money(invoice.sgst),
                    ),

                  if (invoice.cgst > 0)
                    _totalRow(
                      'CGST',
                      _money(invoice.cgst),
                    ),

                  if (invoice.igst > 0)
                    _totalRow(
                      'IGST',
                      _money(invoice.igst),
                    ),

                  pw.Container(
                    color: lightPink,
                    padding:
                        const pw.EdgeInsets.all(9),
                    child: pw.Row(
                      mainAxisAlignment:
                          pw.MainAxisAlignment
                              .spaceBetween,
                      children: [

                        pw.Text(
                          'TOTAL AMOUNT',
                          style: pw.TextStyle(
                            color: burgundy,
                            fontSize: 11,
                            fontWeight:
                                pw.FontWeight.bold,
                          ),
                        ),

                        pw.Text(
                          '₹ ${_money(invoice.grandTotal)}',
                          style: pw.TextStyle(
                            color: burgundy,
                            fontSize: 13,
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

  static pw.Widget _totalRow(
    String label,
    String value,
  ) {
    return pw.Container(
      padding:
          const pw.EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 7,
      ),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: lightBorder,
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
            style: pw.TextStyle(
              color: darkText,
              fontSize: 9,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              color: darkText,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NOTES
  // ============================================================

  static pw.Widget _buildNotesAndFooter() {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 14,
      ),
      child: pw.Row(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,
        children: [

          // -------------------------------
          // NOTES
          // -------------------------------

          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment:
                  pw.CrossAxisAlignment.start,
              children: [

                pw.Text(
                  'Notes :',
                  style: pw.TextStyle(
                    color: burgundy,
                    fontSize: 11,
                    fontWeight:
                        pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 5),

                _note(
                  'Goods once sold will not be taken back or exchanged.',
                ),

                _note(
                  'Please make the payment by cheque/cash/UPI.',
                ),

                _note(
                  'GST is payable on Reverse Charge : No',
                ),

                _note(
                  'Thank you for your business!',
                ),
              ],
            ),
          ),

          pw.SizedBox(width: 20),

          // -------------------------------
          // THANK YOU
          // -------------------------------

          pw.Expanded(
            child: pw.Column(
              children: [

                pw.Divider(
                  color: burgundy,
                  thickness: 0.8,
                ),

                pw.SizedBox(height: 8),

                pw.Text(
                  'Thank You!',
                  style: pw.TextStyle(
                    color: burgundy,
                    fontSize: 25,
                    fontStyle:
                        pw.FontStyle.italic,
                  ),
                ),

                pw.SizedBox(height: 8),

                pw.Text(
                  '—  VISIT AGAIN  —',
                  style: pw.TextStyle(
                    color: burgundy,
                    fontSize: 8,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _note(String text) {
    return pw.Padding(
      padding:
          const pw.EdgeInsets.only(bottom: 4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          color: darkText,
          fontSize: 7.5,
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM FOOTER
  // ============================================================

  static pw.Widget _buildBottomFooter() {
    return pw.Container(
      padding:
          const pw.EdgeInsets.symmetric(
        vertical: 11,
      ),
      decoration: pw.BoxDecoration(
        color: darkBurgundy,
        borderRadius:
            const pw.BorderRadius.only(
          bottomLeft: pw.Radius.circular(7),
          bottomRight: pw.Radius.circular(7),
        ),
      ),
      child: pw.Center(
        child: pw.Text(
          '✦   SPREAD HAPPINESS, ONE CARD AT A TIME   ✦',
          style: pw.TextStyle(
            color: PdfColors.white,
            fontSize: 7.5,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DATE
  // ============================================================

  static String _formatDate(DateTime date) {
    final day =
        date.day.toString().padLeft(2, '0');

    final month =
        date.month.toString().padLeft(2, '0');

    return '$day-$month-${date.year}';
  }

  // ============================================================
  // TIME
  // ============================================================

  static String _formatTime(DateTime date) {
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

  static String _money(double value) {
    return value.toStringAsFixed(2);
  }

  // ============================================================
  // NUMBER TO WORDS
  // ============================================================

  static String numberToWords(double amount) {
    final rupees = amount.floor();

    final paise =
        ((amount - rupees) * 100).round();

    String result = _convertNumber(rupees);

    if (paise > 0) {
      result +=
          ' and ${_convertNumber(paise)} Paise';
    }

    return _capitalize(result);
  }

  static String _convertNumber(int number) {
    if (number == 0) {
      return 'Zero';
    }

    if (number < 1000) {
      return _convertBelowThousand(number);
    }

    if (number < 100000) {
      final thousands = number ~/ 1000;
      final remainder = number % 1000;

      String result =
          '${_convertNumber(thousands)} Thousand';

      if (remainder > 0) {
        result +=
            ' ${_convertNumber(remainder)}';
      }

      return result;
    }

    if (number < 10000000) {
      final lakhs = number ~/ 100000;
      final remainder = number % 100000;

      String result =
          '${_convertNumber(lakhs)} Lakh';

      if (remainder > 0) {
        result +=
            ' ${_convertNumber(remainder)}';
      }

      return result;
    }

    final crores = number ~/ 10000000;
    final remainder = number % 10000000;

    String result =
        '${_convertNumber(crores)} Crore';

    if (remainder > 0) {
      result +=
          ' ${_convertNumber(remainder)}';
    }

    return result;
  }

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

  static String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }

    return value[0].toUpperCase() +
        value.substring(1);
  }
}
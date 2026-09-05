import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A mini popup dialog that mimics a real card-payment sheet: a card preview
/// plus card-number / name / expiry / CVV fields, used to "pay" \$0.99 and
/// unlock the response.
///
/// Nothing is charged and no network call is made — this is UI only. When the
/// user taps "Pay", a short fake round-trip runs and the dialog closes
/// returning `true` so the caller can reveal the response.
class PaymentDialog extends StatefulWidget {
  const PaymentDialog({
    super.key,
    this.textColor = Colors.orangeAccent,
    this.backgroundColor = Colors.black,
  });

  final Color textColor;
  final Color backgroundColor;

  /// Shows the dialog and resolves to `true` only when the (simulated) payment
  /// succeeds, and `false` when the user cancels or dismisses it.
  static Future<bool> show(
    BuildContext context, {
    Color textColor = Colors.orangeAccent,
    Color backgroundColor = Colors.black,
  }) async {
    final bool? paid = await showDialog<bool>(
      context: context,
      builder: (_) => PaymentDialog(
        textColor: textColor,
        backgroundColor: backgroundColor,
      ),
    );
    return paid ?? false;
  }

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  final TextEditingController _cardController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  /// Which payment method is mid-flight: `'apple'`, `'card'`, or `null` when
  /// idle. Used to show the spinner on the button that was actually tapped.
  String? _payingVia;
  bool get _isProcessing => _payingVia != null;

  String get _digits => _cardController.text.replaceAll(RegExp(r'\D'), '');

  bool get _canPay =>
      !_isProcessing &&
      _digits.length >= 15 &&
      _nameController.text.trim().isNotEmpty &&
      _expiryController.text.length == 5 &&
      _cvvController.text.length >= 3;

  String get _brand {
    final d = _digits;
    if (d.startsWith('4')) return 'VISA';
    if (d.startsWith('34') || d.startsWith('37')) return 'AMEX';
    if (d.startsWith('5') || d.startsWith('2')) return 'MASTERCARD';
    return 'CARD';
  }

  @override
  void dispose() {
    _cardController.dispose();
    _nameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _pay(String via) async {
    setState(() => _payingVia = via);
    // Simulate a payment round-trip. Nothing is actually charged.
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor = widget.textColor;
    final Color backgroundColor = widget.backgroundColor;

    InputDecoration decoration(String label, String hint, {Widget? suffix}) {
      OutlineInputBorder border(double opacity, double width) =>
          OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: textColor.withValues(alpha: opacity),
              width: width,
            ),
          );
      return InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textColor),
        floatingLabelStyle: TextStyle(color: textColor),
        hintText: hint,
        hintStyle: TextStyle(color: textColor.withValues(alpha: 0.4)),
        suffixIcon: suffix,
        counterText: '',
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        enabledBorder: border(0.5, 1),
        focusedBorder: border(1, 1.6),
      );
    }

    return AlertDialog(
      backgroundColor: backgroundColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: textColor.withValues(alpha: 0.6)),
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Payment',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
          Text(
            '\$0.99',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 340,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Express checkout: one tap simulates a full payment.
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : () => _pay('apple'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.white.withValues(alpha: 0.5),
                    disabledForegroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _payingVia == 'apple'
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.apple, size: 24),
                            SizedBox(width: 2),
                            Text(
                              'Pay',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Divider(color: textColor.withValues(alpha: 0.3)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'or pay with card',
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: textColor.withValues(alpha: 0.3)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _cardPreview(textColor),
              const SizedBox(height: 20),
              TextField(
                controller: _cardController,
                enabled: !_isProcessing,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.creditCardNumber],
                style: TextStyle(color: textColor, letterSpacing: 1.2),
                onChanged: (_) => setState(() {}),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _CardNumberFormatter(),
                ],
                decoration: decoration(
                  'Card number',
                  '4242 4242 4242 4242',
                  suffix: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Text(
                      _brand,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _nameController,
                enabled: !_isProcessing,
                textCapitalization: TextCapitalization.characters,
                autofillHints: const [AutofillHints.creditCardName],
                style: TextStyle(color: textColor),
                onChanged: (_) => setState(() {}),
                decoration: decoration('Cardholder name', 'JOHN DOE'),
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _expiryController,
                      enabled: !_isProcessing,
                      keyboardType: TextInputType.number,
                      autofillHints: const [
                        AutofillHints.creditCardExpirationDate,
                      ],
                      style: TextStyle(color: textColor),
                      onChanged: (_) => setState(() {}),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _ExpiryFormatter(),
                      ],
                      decoration: decoration('Expiry', 'MM/YY'),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextField(
                      controller: _cvvController,
                      enabled: !_isProcessing,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 4,
                      autofillHints: const [
                        AutofillHints.creditCardSecurityCode,
                      ],
                      style: TextStyle(color: textColor),
                      onChanged: (_) => setState(() {}),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: decoration('CVV', '•••'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
      actions: <Widget>[
        TextButton(
          onPressed:
              _isProcessing ? null : () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(foregroundColor: textColor),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _canPay ? () => _pay('card') : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: textColor,
            foregroundColor: backgroundColor,
            disabledBackgroundColor: textColor.withValues(alpha: 0.4),
            disabledForegroundColor: backgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: _payingVia == 'card'
              ? SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: backgroundColor,
                  ),
                )
              : const Text('Pay \$0.99'),
        ),
      ],
    );
  }

  /// A live credit-card preview that mirrors what the user types.
  Widget _cardPreview(Color textColor) {
    final digits = _digits.padRight(16, '•');
    final groups = <String>[
      for (int i = 0; i < 16; i += 4) digits.substring(i, i + 4),
    ];
    final number = groups.join('  ');
    final name = _nameController.text.trim().isEmpty
        ? 'CARDHOLDER NAME'
        : _nameController.text.toUpperCase();
    final expiry =
        _expiryController.text.isEmpty ? 'MM/YY' : _expiryController.text;

    return Container(
      height: 180,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withValues(alpha: 0.7)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C1C1C), Color(0xFF3A1E00)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Card "chip".
              Container(
                width: 42,
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: LinearGradient(
                    colors: [
                      textColor,
                      textColor.withValues(alpha: 0.6),
                    ],
                  ),
                ),
              ),
              Text(
                _brand,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            number,
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              letterSpacing: 2,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CARD HOLDER',
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.6),
                        fontSize: 9,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: textColor, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VALID THRU',
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.6),
                      fontSize: 9,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    expiry,
                    style: TextStyle(color: textColor, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Groups card-number digits into blocks of four ("4242 4242 …") as the user
/// types, capping the input at 16 digits.
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 16) digits = digits.substring(0, 16);
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Formats an expiry date as "MM/YY" while typing.
class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 4) digits = digits.substring(0, 4);
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

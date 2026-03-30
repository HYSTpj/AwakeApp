import 'package:flutter/material.dart';
import 'common_layout.dart';

class PasscodeEntryPage extends StatefulWidget {
  const PasscodeEntryPage({super.key});

  @override
  State<PasscodeEntryPage> createState() => _PasscodeEntryPageState();
}

class _PasscodeEntryPageState extends State<PasscodeEntryPage> {
  final TextEditingController _passcodeController = TextEditingController();

  @override
  void dispose() {
    _passcodeController.dispose();
    super.dispose();
  }

  void _onConfirmCheckIn() {
    final passcode = _passcodeController.text.trim();
    if (passcode.isNotEmpty) {
      // Return a map indicating this is a passcode result
      Navigator.pop(context, {'type': 'passcode', 'value': passcode});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('IDを入力してください', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFF1A1C1C);
    const orangeColor = Color(0xFFFF5C00);

    return CommonLayout(
      body: Container(
        color: const Color(0xFFF9FAFA), // slightly off-white background
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Back Button
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: borderColor, width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: borderColor,
                        offset: Offset(4, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: borderColor),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(height: 64),
              
              // Lock Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: orangeColor,
                  border: Border.all(color: borderColor, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: borderColor,
                      offset: Offset(4, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lock_outline,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 40),
              
              // Titles
              const Text(
                'SECURE ENTRY',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: borderColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Enter your check-in passcode',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280), // Gray color for secondary text
                ),
              ),
              const SizedBox(height: 48),
              
              // Input Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: borderColor, width: 4),
                ),
                child: TextField(
                  controller: _passcodeController,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    color: borderColor,
                  ),
                  keyboardType: TextInputType.visiblePassword, // Alphanumeric keyboard
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _onConfirmCheckIn(),
                  decoration: const InputDecoration(
                    hintText: 'ENTER THE ID',
                    hintStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: Color(0xFFA1A1AA),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 20),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              
              // Confirm Button
              Container(
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: borderColor,
                      offset: Offset(6, 6),
                      blurRadius: 0,
                    ),
                  ],
                ),
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orangeColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                      side: const BorderSide(color: borderColor, width: 3),
                    ),
                  ),
                  onPressed: _onConfirmCheckIn,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'CONFIRM CHECK-IN',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class QuickAddSheet extends ConsumerStatefulWidget {
  const QuickAddSheet({super.key});

  @override
  ConsumerState<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<QuickAddSheet> {
  String _amount = '0';
  bool _isExpense = true;
  final FocusNode _keyboardFocusNode = FocusNode();

  void _handleKeyPress(String value) {
    setState(() {
      if (value == '.') {
        if (!_amount.contains('.')) {
          _amount += '.';
        }
      } else if (value == 'backspace') {
        if (_amount.length > 1) {
          _amount = _amount.substring(0, _amount.length - 1);
          if (_amount.endsWith('.')) {
            _amount = _amount.substring(0, _amount.length - 1);
          }
        } else {
          _amount = '0';
        }
      } else {
        if (_amount == '0') {
          _amount = value;
        } else {
          _amount += value;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          final logicalKey = event.logicalKey;
          if (logicalKey == LogicalKeyboardKey.backspace) {
            _handleKeyPress('backspace');
          } else if (logicalKey == LogicalKeyboardKey.period || logicalKey == LogicalKeyboardKey.comma) {
            _handleKeyPress('.');
          } else if (logicalKey == LogicalKeyboardKey.enter) {
            // TODO: Validate
          } else {
            final label = logicalKey.keyLabel;
            if (RegExp(r'^[0-9]$').hasMatch(label)) {
              _handleKeyPress(label);
            }
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTypeToggle('EXPENSE', true),
                const SizedBox(width: 16),
                _buildTypeToggle('INCOME', false),
              ],
            ),
            const SizedBox(height: 32),
            
            // Amount Display
            Text(
              '$_amount €',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 32),
            
            // Selectors
            Row(
              children: [
                Expanded(child: _buildSelector('Account', 'Checking')),
                const SizedBox(width: 12),
                Expanded(child: _buildSelector('Budget', 'Unplanned')),
              ],
            ),
            const SizedBox(height: 32),
            
            // Custom Keypad
            _buildKeypad(),
            
            const SizedBox(height: 24),
            
            // Validate Button
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'VALIDATE',
                style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeToggle(String label, bool isExpense) {
    final active = _isExpense == isExpense;
    return GestureDetector(
      onTap: () => setState(() => _isExpense = isExpense),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? Colors.black : Colors.grey[300]!),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSelector(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const Icon(LucideIcons.chevron_down, size: 14, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        _buildKeyRow(['1', '2', '3']),
        const SizedBox(height: 12),
        _buildKeyRow(['4', '5', '6']),
        const SizedBox(height: 12),
        _buildKeyRow(['7', '8', '9']),
        const SizedBox(height: 12),
        _buildKeyRow(['.', '0', 'backspace']),
      ],
    );
  }

  Widget _buildKeyRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: InkWell(
              onTap: () => _handleKeyPress(key),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: key == 'backspace'
                    ? const Icon(LucideIcons.delete, size: 20)
                    : Text(
                        key,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

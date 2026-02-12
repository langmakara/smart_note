import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../services/security_service.dart';

enum SecurityPageMode { setup, change, verify }

class SecurityPage extends StatefulWidget {
  final SecurityPageMode mode;
  final VoidCallback? onVerifySuccess;

  const SecurityPage({super.key, required this.mode, this.onVerifySuccess});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final SecurityService _securityService = SecurityService.instance;
  final List<String> _pins = [];
  String _confirmPin = '';
  String _newPin = '';
  String _errorMessage = '';
  bool _isLoading = false;
  int _step = 0;

  static const List<String> _numpadKeys = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '',
    '0',
    '⌫',
  ];

  @override
  void initState() {
    super.initState();
    _step = 0;
    if (widget.mode == SecurityPageMode.verify) {
      _securityService.init();
    }
  }

  void _onKeyPressed(String key) {
    if (_isLoading) return;

    setState(() {
      _errorMessage = '';
    });

    if (key == '⌫') {
      if (_pins.isNotEmpty) {
        setState(() {
          _pins.removeLast();
        });
      }
      return;
    }

    if (key.isEmpty) return;

    if (_pins.length < 6) {
      setState(() {
        _pins.add(key);
      });

      if (_pins.length == 6) {
        _handlePinComplete();
      }
    }
  }

  Future<void> _handlePinComplete() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    final enteredPin = _pins.join();

    switch (widget.mode) {
      case SecurityPageMode.setup:
        if (_confirmPin.isEmpty) {
          setState(() {
            _confirmPin = enteredPin;
            _pins.clear();
            _isLoading = false;
          });
        } else {
          if (enteredPin == _confirmPin) {
            await _securityService.setPassword(enteredPin);
            if (mounted) {
              Navigator.pop(context, true);
            }
          } else {
            setState(() {
              _errorMessage = 'PINs do not match. Try again.';
              _confirmPin = '';
              _pins.clear();
              _isLoading = false;
            });
          }
        }
        break;

      case SecurityPageMode.change:
        if (_step == 0) {
          if (_securityService.verifyPassword(enteredPin)) {
            setState(() {
              _step = 1;
              _confirmPin = enteredPin;
              _pins.clear();
              _isLoading = false;
            });
          } else {
            setState(() {
              _errorMessage = 'Incorrect PIN. Try again.';
              _pins.clear();
              _isLoading = false;
            });
          }
        } else if (_step == 1) {
          setState(() {
            _newPin = enteredPin;
            _step = 2;
            _pins.clear();
            _isLoading = false;
          });
        } else if (_step == 2) {
          if (enteredPin == _newPin) {
            await _securityService.setPassword(enteredPin);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('PIN changed successfully'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
              Navigator.pop(context, true);
            }
          } else {
            setState(() {
              _errorMessage = 'PINs do not match. Try again.';
              _step = 1;
              _newPin = '';
              _pins.clear();
              _isLoading = false;
            });
          }
        }
        break;

      case SecurityPageMode.verify:
        if (_securityService.verifyPassword(enteredPin)) {
          if (mounted) {
            if (widget.onVerifySuccess != null) {
              widget.onVerifySuccess!();
            } else {
              Navigator.pop(context, true);
            }
          }
        } else {
          setState(() {
            _errorMessage = 'Incorrect PIN. Try again.';
            _pins.clear();
            _isLoading = false;
          });
        }
        break;
    }
  }

  String _getTitle() {
    switch (widget.mode) {
      case SecurityPageMode.setup:
        return _confirmPin.isEmpty ? 'Create PIN' : 'Confirm PIN';
      case SecurityPageMode.change:
        if (_step == 0) return 'Enter Current PIN';
        if (_step == 1) return 'Enter New PIN';
        return 'Confirm New PIN';
      case SecurityPageMode.verify:
        return 'Enter PIN';
    }
  }

  String _getSubtitle() {
    switch (widget.mode) {
      case SecurityPageMode.setup:
        return _confirmPin.isEmpty
            ? 'Enter a 6-digit PIN'
            : 'Re-enter your PIN';
      case SecurityPageMode.change:
        if (_step == 0) return 'Enter your current PIN';
        if (_step == 1) return 'Enter your new PIN';
        return 'Re-enter your new PIN';
      case SecurityPageMode.verify:
        return 'Enter your PIN to continue';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.appBarColor,
        elevation: 0,
        title: Text(
          _getTitle(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: themeProvider.accentColor,
          ),
        ),
        centerTitle: true,
        leading: widget.mode != SecurityPageMode.verify
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: themeProvider.textColor),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Icon(
                  Icons.lock_outline,
                  size: 80,
                  color: themeProvider.accentColor.withValues(alpha: 0.8),
                ),
                const SizedBox(height: 16),
                Text(
                  _getTitle(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getSubtitle(),
                  style: TextStyle(
                    fontSize: 16,
                    color: themeProvider.subtitleColor,
                  ),
                ),
                const SizedBox(height: 32),
                _buildPinDots(themeProvider),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                const SizedBox(height: 24),
                _buildNumpad(themeProvider),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinDots(ThemeProvider themeProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        6,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index < _pins.length
                ? themeProvider.accentColor
                : themeProvider.accentColor.withValues(alpha: 0.2),
            border: Border.all(color: themeProvider.accentColor, width: 1),
          ),
        ),
      ),
    );
  }

  Widget _buildNumpad(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          for (int row = 0; row < 4; row++)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int col = 0; col < 3; col++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 6,
                      ),
                      child: _buildNumpadButton(
                        _numpadKeys[row * 3 + col],
                        themeProvider,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildNumpadButton(String key, ThemeProvider themeProvider) {
    final isDelete = key == '⌫';
    final isEmpty = key == '';

    return AspectRatio(
      aspectRatio: 1,
      child: GestureDetector(
        onTap: isEmpty || _isLoading ? null : () => _onKeyPressed(key),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isEmpty
                ? Colors.transparent
                : isDelete
                ? Colors.red.withValues(alpha: 0.1)
                : themeProvider.accentColor.withValues(alpha: 0.1),
            border: Border.all(
              color: isEmpty
                  ? Colors.transparent
                  : isDelete
                  ? Colors.red.withValues(alpha: 0.3)
                  : themeProvider.accentColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Center(
            child: isEmpty
                ? const SizedBox.shrink()
                : Text(
                    key,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: isDelete ? Colors.red : themeProvider.accentColor,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

enum ButtonType {
  primary,
  secondary,
  danger,
  outline,
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final bool isDisabled;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    Color borderColor = Colors.transparent;

    switch (type) {
      case ButtonType.primary:
        backgroundColor = Theme.of(context).primaryColor;
        textColor = Colors.white;
        break;
      case ButtonType.secondary:
        backgroundColor = Colors.grey.shade200;
        textColor = Theme.of(context).primaryColor;
        break;
      case ButtonType.danger:
        backgroundColor = Colors.red;
        textColor = Colors.white;
        break;
      case ButtonType.outline:
        backgroundColor = Colors.transparent;
        textColor = Theme.of(context).primaryColor;
        borderColor = Theme.of(context).primaryColor;
        break;
    }

    if (isDisabled) {
      backgroundColor = Colors.grey.shade300;
      textColor = Colors.grey.shade600;
    }

    final button = ElevatedButton(
      onPressed: (isDisabled || isLoading) ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        minimumSize: isFullWidth ? const Size(double.infinity, 48) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Row(
              mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(text),
              ],
            ),
    );

    return button;
  }
}

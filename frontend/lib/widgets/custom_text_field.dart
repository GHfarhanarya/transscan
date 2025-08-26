import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? errorText;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final TextInputType keyboardType;
  final bool enabled;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.errorText,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: enabled ? Colors.white : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null ? Colors.red : Colors.grey.shade300,
              width: errorText != null ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: errorText != null
                    ? Colors.red.withOpacity(0.1)
                    : Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            enabled: enabled,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 16,
              color: enabled ? Colors.black87 : Colors.grey[600],
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: errorText != null
                    ? Colors.red.shade400
                    : Colors.grey.shade500,
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              prefixIcon: prefixIcon != null
                  ? Icon(
                      prefixIcon,
                      color:
                          errorText != null ? Colors.red : Colors.grey.shade600,
                      size: 20,
                    )
                  : null,
              suffixIcon: suffixIcon,
            ),
            onChanged: onChanged,
            onSubmitted: onSubmitted,
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 6),
            child: Text(
              errorText!,
              style: TextStyle(
                color: Colors.red.shade600,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

// Widget khusus untuk dialog form
class DialogTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final Function(String)? onChanged;

  const DialogTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: prefixIcon != null
              ? Icon(
                  prefixIcon,
                  color: Color(0xFFE31837),
                  size: 20,
                )
              : null,
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

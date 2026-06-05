import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:physical_activity_log_app/theme/app_colors.dart';

class AuthInputComponent extends StatefulWidget {
  final IconData icon;
  final String hintText;
  final bool isPassword;
  final TextEditingController? controller;
  final int? maxLength;
  final TextInputType? keyboardType;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const AuthInputComponent({
    super.key,
    required this.icon,
    required this.hintText,
    this.isPassword = false,
    this.controller,
    this.maxLength,
    this.keyboardType,
    this.errorText,
    this.onChanged,
  });

  @override
  State<AuthInputComponent> createState() => _AuthInputComponentState();
}

class _AuthInputComponentState extends State<AuthInputComponent> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final borderColor = hasError ? const Color(0xFFD32F2F) : AppColors.inputBorder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: borderColor),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 18),
              Icon(widget.icon, color: AppColors.placeholderGrey, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  obscureText: widget.isPassword && _obscureText,
                  keyboardType: widget.keyboardType,
                  maxLength: widget.maxLength,
                  onChanged: widget.onChanged,
                  inputFormatters: widget.maxLength != null
                      ? [LengthLimitingTextInputFormatter(widget.maxLength)]
                      : null,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: const TextStyle(
                      color: AppColors.placeholderGrey,
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    counterText: '',
                  ),
                ),
              ),
              if (widget.isPassword)
                IconButton(
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                  icon: Icon(
                    _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppColors.placeholderGrey,
                    size: 20,
                  ),
                  padding: const EdgeInsets.only(right: 8),
                  constraints: const BoxConstraints(),
                )
              else
                const SizedBox(width: 18),
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 18),
            child: Text(
              widget.errorText!,
              style: const TextStyle(
                color: Color(0xFFD32F2F),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

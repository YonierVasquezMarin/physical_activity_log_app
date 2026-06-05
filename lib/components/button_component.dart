import 'package:flutter/material.dart';

/// Tamaños predefinidos para [ButtonComponent].
enum ButtonComponentSize {
  /// Altura 40.
  small,
  /// Altura 48 (comportamiento histórico por defecto).
  medium,
  /// Altura 56.
  large,
}

extension ButtonComponentSizeDimensions on ButtonComponentSize {
  double get height {
    switch (this) {
      case ButtonComponentSize.small:
        return 40;
      case ButtonComponentSize.medium:
        return 48;
      case ButtonComponentSize.large:
        return 56;
    }
  }

  double get iconSize {
    switch (this) {
      case ButtonComponentSize.small:
        return 20;
      case ButtonComponentSize.medium:
        return 24;
      case ButtonComponentSize.large:
        return 28;
    }
  }

  /// Texto en botón transparente.
  double get labelFontSizeTransparent {
    switch (this) {
      case ButtonComponentSize.small:
        return 14;
      case ButtonComponentSize.medium:
        return 16;
      case ButtonComponentSize.large:
        return 18;
    }
  }

  /// Texto en botón relleno.
  double get labelFontSizeElevated {
    switch (this) {
      case ButtonComponentSize.small:
        return 16;
      case ButtonComponentSize.medium:
        return 18;
      case ButtonComponentSize.large:
        return 20;
    }
  }

  double get iconLabelSpacing {
    switch (this) {
      case ButtonComponentSize.small:
        return 8;
      case ButtonComponentSize.medium:
        return 12;
      case ButtonComponentSize.large:
        return 14;
    }
  }

  /// Padding que encaja con [height]; si es demasiado alto, el texto se recorta dentro del [SizedBox].
  EdgeInsetsGeometry get buttonPadding {
    switch (this) {
      case ButtonComponentSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case ButtonComponentSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
      case ButtonComponentSize.large:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
    }
  }
}

class ButtonComponent extends StatefulWidget {
  final String label;
  final IconData? iconData;
  final VoidCallback onPressed;
  final bool fullWidth;
  final Color? color;
  final bool isTransparent;
  final bool fullyRoundedSides;
  /// Tamaño predefinido. Si es null, equivale a [ButtonComponentSize.medium].
  final ButtonComponentSize? size;
  /// Elevación del botón relleno. Si es null, usa el valor por defecto del tema.
  final double? elevation;

  const ButtonComponent({
    super.key,
    required this.label,
    this.iconData,
    required this.onPressed,
    this.color,
    this.fullWidth = false,
    this.isTransparent = false,
    this.fullyRoundedSides = false,
    this.size,
    this.elevation,
  });

  @override
  State<ButtonComponent> createState() => _ButtonComponentState();
}

class _ButtonComponentState extends State<ButtonComponent> {
  late ColorScheme _colorScheme;

  @override
  Widget build(BuildContext context) {
    _colorScheme = Theme.of(context).colorScheme;
    return _buildContent();
  }

  Widget _buildContent() {
    if (widget.fullWidth) {
      return _buildFullWidthButton();
    } else {
      return _buildNormalButton();
    }
  }

  ButtonComponentSize get _effectiveSize => widget.size ?? ButtonComponentSize.medium;

  double get _effectiveHeight => _effectiveSize.height;

  Widget _buildFullWidthButton() {
    return SizedBox(
      width: double.infinity,
      height: _effectiveHeight,
      child: _buildButton()
    );
  }

  Widget _buildNormalButton() {
    return SizedBox(
      height: _effectiveHeight,
      child: _buildButton()
    );
  }

  Widget _buildButton() {
    if (widget.isTransparent) {
      return _buildTextButton();
    } else {
      return _buildElevatedButton();
    }
  }

  Widget _buildTextButton() {
    return TextButton(
      style: _getTransparentButtonStyle(),
      onPressed: widget.onPressed,
      child: _buildButtonContent(),
    );
  }

  Widget _buildElevatedButton() {
    return ElevatedButton(
      style: _getButtonStyle(),
      onPressed: widget.onPressed,
      child: _buildButtonContent(),
    );
  }

  OutlinedBorder _buttonShape() {
    if (widget.fullyRoundedSides) {
      return const StadiumBorder();
    }
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    );
  }

  ButtonStyle _getButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: _getColorForButton(),
      foregroundColor: Colors.white,
      elevation: widget.elevation,
      shadowColor: widget.elevation == 0 ? Colors.transparent : null,
      shape: _buttonShape(),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: _effectiveSize.buttonPadding,
      minimumSize: Size.zero,
      alignment: Alignment.center,
    );
  }

  ButtonStyle _getTransparentButtonStyle() {
    return TextButton.styleFrom(
      backgroundColor: Colors.transparent,
      foregroundColor: _getTextColorForTransparent(),
      shape: _buttonShape(),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: _effectiveSize.buttonPadding,
      minimumSize: Size.zero,
      alignment: Alignment.center,
    );
  }

  Color _getColorForButton() {
    return widget.color ?? _colorScheme.primary;
  }

  Color _getTextColorForTransparent() {
    return _colorScheme.primary;
  }

  Widget _buildButtonContent() {
    // Si no hay ícono, mostrar solo el texto para evitar espacios innecesarios
    if (widget.iconData == null) {
      return _buildLabel();
    }
    
    return _buildPaddingWithRowForButtonContent();
  }

  Widget _buildPaddingWithRowForButtonContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: _buildRowForButtonContent(),
    );
  }

  Widget _buildRowForButtonContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      spacing: _effectiveSize.iconLabelSpacing,
      children: [
        _buildIcon(),
        _buildLabel(),
      ],
    );
  }

  Widget _buildIcon() {
    if (widget.iconData != null) {
      return _buildIconForButton();
    } else {
      return SizedBox.shrink();
    }
  }

  Widget _buildIconForButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Icon(
        widget.iconData,
        size: _effectiveSize.iconSize,
        color: widget.isTransparent ? _getTextColorForTransparent() : Colors.white,
      ),
    );
  }

  Text _buildLabel() {
    return Text(
      widget.label,
      style: _buildTextStyleForLabel(),
      textHeightBehavior: const TextHeightBehavior(
        applyHeightToFirstAscent: false,
        applyHeightToLastDescent: false,
      ),
    );
  }

  TextStyle _buildTextStyleForLabel() {
    final fontSize = widget.isTransparent
        ? _effectiveSize.labelFontSizeTransparent
        : _effectiveSize.labelFontSizeElevated;
    return TextStyle(
      color: widget.isTransparent ? _getTextColorForTransparent() : Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: fontSize,
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/neu_theme.dart';

// ── NeuCard — the primary surface widget ──────────────────────
//  Every card/panel in the app should use this instead of Card/Container.
class NeuCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final bool pressed;         // true = inset (selected, input, active)
  final Color? color;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const NeuCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.radius = 18,
    this.pressed = false,
    this.color,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final neu = context.neu;
    final bg = color ?? neu.surface;
    final r = BorderRadius.circular(radius);

    Widget card = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: r,
        boxShadow: pressed ? neu.inset : neu.raisedSoft,
      ),
      child: child,
    );

    if (margin != null) card = Padding(padding: margin!, child: card);

    if (onTap != null) {
      card = GestureDetector(
        onTap: onTap,
        child: card,
      );
    }
    return card;
  }
}

// ── NeuButton — animated press-in on tap ──────────────────────
class NeuButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double radius;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;

  const NeuButton({
    super.key,
    required this.child,
    this.onPressed,
    this.radius = 14,
    this.color,
    this.padding,
    this.isLoading = false,
  });

  @override
  State<NeuButton> createState() => _NeuButtonState();
}

class _NeuButtonState extends State<NeuButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    if (widget.onPressed == null) return;
    HapticFeedback.lightImpact();
    setState(() => _pressed = true);
    _ctrl.forward();
  }

  void _onTapUp(_) {
    setState(() => _pressed = false);
    _ctrl.reverse();
    widget.onPressed?.call();
  }

  void _onTapCancel() {
    setState(() => _pressed = false);
    _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final neu = context.neu;
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: widget.padding ??
            const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: widget.color ?? neu.surface,
          borderRadius: BorderRadius.circular(widget.radius),
          boxShadow: _pressed
              ? neu.inset
              : neu.raisedSoft,
        ),
        child: widget.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primary,
                ),
              )
            : widget.child,
      ),
    );
  }
}

// ── NeuPrimaryButton — gradient + raised + press-in ──────────
class NeuPrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final Gradient gradient;

  const NeuPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.gradient = AppColors.primaryGradient,
  });

  @override
  State<NeuPrimaryButton> createState() => _NeuPrimaryButtonState();
}

class _NeuPrimaryButtonState extends State<NeuPrimaryButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.onPressed == null) return;
        HapticFeedback.lightImpact();
        setState(() => _pressed = true);
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: widget.width,
        height: 52,
        decoration: BoxDecoration(
          gradient: widget.onPressed != null ? widget.gradient : null,
          color: widget.onPressed == null ? AppColors.textHint : null,
          borderRadius: BorderRadius.circular(14),
          boxShadow: _pressed
              ? []
              : [
                  BoxShadow(
                    color: (widget.gradient.colors.first).withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
          border: _pressed
              ? Border.all(
                  color: Colors.white.withOpacity(0.15), width: 1)
              : null,
        ),
        child: widget.isLoading
            ? const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── NeuIconButton — circular neumorphic icon button ───────────
class NeuIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? iconColor;
  final Color? bgColor;
  final String? tooltip;
  final bool active;

  const NeuIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 44,
    this.iconColor,
    this.bgColor,
    this.tooltip,
    this.active = false,
  });

  @override
  State<NeuIconButton> createState() => _NeuIconButtonState();
}

class _NeuIconButtonState extends State<NeuIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final neu = context.neu;
    final color = widget.active ? AppColors.primary : (widget.iconColor ?? neu.textSecondary);
    final bg = widget.active ? AppColors.primarySurface : (widget.bgColor ?? neu.surface);

    Widget btn = GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onPressed?.call(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          boxShadow: _pressed ? neu.inset : neu.raisedSoft,
        ),
        child: Icon(widget.icon, color: color, size: widget.size * 0.44),
      ),
    );
    if (widget.tooltip != null) btn = Tooltip(message: widget.tooltip!, child: btn);
    return btn;
  }
}

// ── NeuTextField — inset input field ─────────────────────────
class NeuTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final bool obscureText;
  final VoidCallback? onToggleObscure;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final int? maxLines;
  final Widget? suffix;

  const NeuTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.obscureText = false,
    this.onToggleObscure,
    this.textInputAction,
    this.onSubmitted,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.suffix,
  });

  @override
  State<NeuTextField> createState() => _NeuTextFieldState();
}

class _NeuTextFieldState extends State<NeuTextField> {
  bool _focused = false;
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() { _focus.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final neu = context.neu;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: neu.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: _focused ? neu.inset : neu.raisedSoft,
        border: _focused
            ? Border.all(color: AppColors.primary.withOpacity(0.4), width: 1.5)
            : Border.all(color: Colors.transparent),
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focus,
        obscureText: widget.obscureText,
        textInputAction: widget.textInputAction,
        onFieldSubmitted: widget.onSubmitted,
        validator: widget.validator,
        keyboardType: widget.keyboardType,
        maxLines: widget.maxLines,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: neu.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          contentPadding: EdgeInsets.only(
            left: widget.prefixIcon != null ? 0 : 16,
            right: 16,
            top: 14,
            bottom: 14,
          ),
          prefixIcon: widget.prefixIcon != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(widget.prefixIcon,
                      color: _focused
                          ? AppColors.primary
                          : neu.textSecondary,
                      size: 18),
                )
              : null,
          suffixIcon: widget.onToggleObscure != null
              ? IconButton(
                  icon: Icon(
                    widget.obscureText
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: neu.textHint,
                    size: 18,
                  ),
                  onPressed: widget.onToggleObscure,
                )
              : widget.suffix,
        ),
      ),
    );
  }
}

// ── NeuChip — selectable chip ─────────────────────────────────
class NeuChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? selectedColor;
  final IconData? icon;

  const NeuChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.selectedColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final neu = context.neu;
    final color = selectedColor ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : neu.surface,
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected ? neu.inset : neu.raisedSoft,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13,
                  color: selected ? Colors.white : neu.textSecondary),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : neu.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── NeuDivider ────────────────────────────────────────────────
class NeuDivider extends StatelessWidget {
  final double indent;
  const NeuDivider({super.key, this.indent = 0});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: indent),
      child: Container(
        height: 1.5,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              AppColors.border,
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

// ── NeuBadge — stat count badge ───────────────────────────────
class NeuBadge extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  const NeuBadge({
    super.key,
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return NeuCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── SolidCard alias — kept for backwards compat ───────────────
// Now wraps NeuCard so all existing usages get neumorphism.
class SolidCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? color;
  final Color? borderColor;   // kept for API compat; ignored in neu style
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final List<BoxShadow>? shadows;  // ignored; neu style uses its own shadows
  final bool hoverable;

  const SolidCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
    this.borderColor,
    this.width,
    this.height,
    this.onTap,
    this.gradient,
    this.shadows,
    this.hoverable = true,
  });

  @override
  Widget build(BuildContext context) {
    // If a gradient is provided, render a plain gradient container
    if (gradient != null) {
      Widget card = Container(
        width: width,
        height: height,
        margin: margin,
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: borderRadius ?? BorderRadius.circular(18),
          boxShadow: AppColors.glow(gradient!.colors.first),
        ),
        child: child,
      );
      if (onTap != null) {
        card = GestureDetector(onTap: onTap, child: card);
      }
      return card;
    }

    return NeuCard(
      padding: padding,
      margin: margin,
      radius: borderRadius?.topLeft.x ?? 18,
      color: color,
      width: width,
      height: height,
      onTap: onTap,
      child: child,
    );
  }
}

// ── GlassCard alias — also uses neu in light mode ─────────────
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double blur;
  final Color? fillColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final List<BoxShadow>? shadows;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blur = 16,
    this.fillColor,
    this.borderColor,
    this.width,
    this.height,
    this.onTap,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) => SolidCard(
        child: child,
        padding: padding,
        margin: margin,
        borderRadius: borderRadius,
        color: fillColor,
        width: width,
        height: height,
        onTap: onTap,
      );
}

// ── GradientCard ──────────────────────────────────────────────
class GradientCard extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const GradientCard({
    super.key,
    required this.child,
    this.gradient = AppColors.primaryGradient,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = borderRadius ?? BorderRadius.circular(20);
    Widget card = Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: r,
        boxShadow: AppColors.glow(gradient.colors.first),
      ),
      child: child,
    );
    if (onTap != null) {
      card = GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}

// ── InfoChip ──────────────────────────────────────────────────
class InfoChip extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  final double fontSize;

  const InfoChip(this.text, this.color,
      {super.key, this.icon, this.fontSize = 10});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: fontSize + 1, color: color),
              const SizedBox(width: 3),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      );
}

// ── TiltCard (kept for compatibility) ─────────────────────────
class TiltCard extends StatelessWidget {
  final Widget child;
  final double maxTilt;
  final BorderRadius? borderRadius;
  final Color? color;
  final Gradient? gradient;
  final List<BoxShadow>? shadows;

  const TiltCard({
    super.key,
    required this.child,
    this.maxTilt = 0.06,
    this.borderRadius,
    this.color,
    this.gradient,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) => SolidCard(
        child: child,
        color: color,
        gradient: gradient,
        borderRadius: borderRadius,
      );
}

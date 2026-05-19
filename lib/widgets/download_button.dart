import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import '../core/theme/app_colors.dart';
import '../services/download_helper.dart';

/// A beautiful gradient download button.
/// Shows a bottom sheet asking PDF or CSV (if both builders are provided).
/// If only CSV is provided, downloads immediately without asking.
class DownloadButton extends StatefulWidget {
  /// Label shown on the button
  final String label;

  /// Base filename without extension
  final String filename;

  /// Returns CSV bytes — required
  final Future<Uint8List> Function() csvBuilder;

  /// Returns PDF bytes — optional. If null, only CSV is offered.
  final Future<Uint8List> Function()? pdfBuilder;

  /// Icon override (default: download)
  final IconData icon;

  /// Compact icon-only button (for toolbars)
  final bool compact;

  const DownloadButton({
    super.key,
    required this.label,
    required this.filename,
    required this.csvBuilder,
    this.pdfBuilder,
    this.icon = Icons.download_rounded,
    this.compact = false,
  });

  @override
  State<DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Future<void> _download(bool pdf) async {
    setState(() => _loading = true);
    try {
      if (pdf && widget.pdfBuilder != null) {
        final bytes = await widget.pdfBuilder!();
        await Printing.sharePdf(bytes: bytes, filename: '${widget.filename}.pdf');
      } else {
        final bytes = await widget.csvBuilder();
        await _saveCsv(bytes, '${widget.filename}.csv');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e'),
              backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveCsv(Uint8List bytes, String filename) async {
    if (kIsWeb) {
      downloadFile(bytes, filename);
      _snack('Downloading $filename…');
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(bytes);
      _snack('Saved: ${dir.path}/$filename');
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 3)),
    );
  }

  Future<void> _onTap() async {
    // If only CSV, download directly
    if (widget.pdfBuilder == null) {
      await _download(false);
      return;
    }
    // Otherwise show the choice sheet
    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (_) => _DownloadSheet(
        filename: widget.filename,
        onCsv: () { Navigator.pop(context); _download(false); },
        onPdf: () { Navigator.pop(context); _download(true); },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) return _compactBtn();
    return _fullBtn();
  }

  Widget _fullBtn() => GestureDetector(
        onTapDown: (_) => _anim.forward(),
        onTapUp: (_) { _anim.reverse(); _onTap(); },
        onTapCancel: () => _anim.reverse(),
        child: AnimatedBuilder(
          animation: _anim,
          builder: (_, __) => Transform.scale(
            scale: 1.0 - _anim.value * 0.03,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF8B83FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _loading
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.download_rounded,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 7),
                        Text(widget.label,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ],
                    ),
            ),
          ),
        ),
      );

  Widget _compactBtn() => Tooltip(
        message: widget.label,
        child: GestureDetector(
          onTap: _loading ? null : _onTap,
          child: Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF8B83FF)],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _loading
                ? const Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : Icon(widget.icon, color: Colors.white, size: 17),
          ),
        ),
      );
}

// ── Choice bottom sheet ──────────────────────────────────────
class _DownloadSheet extends StatelessWidget {
  final String filename;
  final VoidCallback onCsv;
  final VoidCallback onPdf;

  const _DownloadSheet({
    required this.filename,
    required this.onCsv,
    required this.onPdf,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.neuBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.12),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Download as',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(filename,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Expanded(child: _FormatBtn(
                label: 'PDF',
                subtitle: 'Beautiful report\nwith charts & graphics',
                icon: Icons.picture_as_pdf_rounded,
                color: const Color(0xFFE53935),
                onTap: onPdf,
              )),
              const SizedBox(width: 12),
              Expanded(child: _FormatBtn(
                label: 'CSV',
                subtitle: 'Spreadsheet\nfor Excel / Sheets',
                icon: Icons.table_chart_rounded,
                color: const Color(0xFF43A047),
                onTap: onCsv,
              )),
            ]),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _FormatBtn extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FormatBtn({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 10),
              Text(label,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: color)),
              const SizedBox(height: 4),
              Text(subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textSecondary,
                      height: 1.4)),
            ],
          ),
        ),
      );
}

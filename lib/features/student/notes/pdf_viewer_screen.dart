import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/iframe_viewer_stub.dart'
    if (dart.library.html) '../../../widgets/iframe_viewer_web.dart';

class PdfViewerScreen extends StatefulWidget {
  final String title;
  final String url;

  const PdfViewerScreen({super.key, required this.title, required this.url});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

const _kSignInRequired = '__sign_in_required__';

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  // Mobile only
  WebViewController? _controller;
  bool _loading = true;
  int _loadingProgress = 0;
  String? _errorMessage;

  String get _embedUrl => _toEmbedUrl(widget.url);

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(NavigationDelegate(
          onPageStarted: (url) {
            setState(() { _loading = true; _errorMessage = null; });
            // Detect Google sign-in redirect — happens when PDF is not public
            if (url.contains('accounts.google.com') ||
                url.contains('signin') ||
                url.contains('ServiceLogin')) {
              setState(() {
                _loading = false;
                _errorMessage = _kSignInRequired;
              });
            }
          },
          onPageFinished: (_) => setState(() => _loading = false),
          onProgress: (p) => setState(() => _loadingProgress = p),
          onWebResourceError: (err) => setState(() {
            _loading = false;
            _errorMessage = 'Could not load the document.\n(${err.description})';
          }),
        ))
        ..loadRequest(Uri.parse(_embedUrl));
    }
  }

  static String _toEmbedUrl(String raw) {
    final url = raw.trim();
    final driveMatch =
        RegExp(r'drive\.google\.com/file/d/([^/]+)').firstMatch(url);
    if (driveMatch != null) {
      return 'https://drive.google.com/file/d/${driveMatch.group(1)!}/preview';
    }
    final openMatch =
        RegExp(r'drive\.google\.com/open\?id=([^&]+)').firstMatch(url);
    if (openMatch != null) {
      return 'https://drive.google.com/file/d/${openMatch.group(1)!}/preview';
    }
    if (url.contains('docs.google.com')) return url;
    return 'https://docs.google.com/viewer?url=${Uri.encodeComponent(url)}&embedded=true';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neuBackground,
      appBar: AppBar(
        title: Text(widget.title,
            style: const TextStyle(fontSize: 15),
            overflow: TextOverflow.ellipsis),
        actions: [
          if (!kIsWeb)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => _controller?.reload(),
              tooltip: 'Reload',
            ),
          if (kIsWeb)
            IconButton(
              icon: const Icon(Icons.open_in_new_rounded),
              onPressed: () => launchUrl(Uri.parse(_embedUrl),
                  mode: LaunchMode.externalApplication),
              tooltip: 'Open in new tab',
            ),
        ],
        bottom: (!kIsWeb && _loading)
            ? PreferredSize(
                preferredSize: const Size.fromHeight(3),
                child: LinearProgressIndicator(
                  value: _loadingProgress < 100 ? _loadingProgress / 100 : null,
                  backgroundColor: AppColors.border,
                  valueColor:
                      const AlwaysStoppedAnimation(AppColors.primary),
                  minHeight: 3,
                ),
              )
            : null,
      ),
      body: kIsWeb
          ? buildIframeViewer(_embedUrl)
          : _errorMessage == _kSignInRequired
              // Google sign-in detected — show helpful open-in-browser card
              ? _SignInRequiredView(url: widget.url, title: widget.title)
              : _errorMessage != null
                  ? _ErrorView(
                      message: _errorMessage!,
                      onRetry: () {
                        setState(() => _errorMessage = null);
                        _controller?.reload();
                      },
                    )
                  : WebViewWidget(controller: _controller!),
    );
  }
}

// On Flutter web, Google Drive blocks iframes via CSP (frame-ancestors policy).
// We show a clean placeholder with an "Open" button instead.
class _WebPdfPlaceholder extends StatelessWidget {
  final String url;
  final String title;
  const _WebPdfPlaceholder({required this.url, required this.title});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: AppColors.errorSurface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.picture_as_pdf_rounded,
                    color: AppColors.error, size: 40),
              ),
              const SizedBox(height: 20),
              Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              const Text(
                'Google Drive PDFs cannot be embedded directly in the browser\ndue to Google\'s security policy.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Open in Google Drive'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () =>
                    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
              ),
            ],
          ),
        ),
      );
}

// ── Shown when Google Drive requires sign-in ──────────────────
class _SignInRequiredView extends StatelessWidget {
  final String url;
  final String title;
  const _SignInRequiredView({required this.url, required this.title});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppColors.warningSurface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.lock_outline_rounded,
                  color: AppColors.warning, size: 40),
            ),
            const SizedBox(height: 20),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            const Text(
              'This file requires Google sign-in to view.\n\n'
              'Ask your admin to set the file sharing to\n"Anyone with the link can view".',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.6),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              icon: const Icon(Icons.open_in_browser_rounded),
              label: const Text('Open in Browser'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () =>
                  launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
            ),
          ]),
        ),
      );
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.broken_image_outlined,
                  size: 56, color: AppColors.textHint),
              const SizedBox(height: 16),
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppColors.textSecondary, height: 1.6)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                onPressed: onRetry,
              ),
            ],
          ),
        ),
      );
}

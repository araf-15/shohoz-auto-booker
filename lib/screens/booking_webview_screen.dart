import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/profile.dart';
import '../services/booking_script.dart';

class BookingWebViewScreen extends StatefulWidget {
  final BookingProfile profile;
  final DateTime travelDate;

  const BookingWebViewScreen({
    super.key,
    required this.profile,
    required this.travelDate,
  });

  @override
  State<BookingWebViewScreen> createState() => _BookingWebViewScreenState();
}

class _BookingWebViewScreenState extends State<BookingWebViewScreen> {
  late final WebViewController _controller;
  String _statusMsg = '⏳ লোড হচ্ছে...';
  String _statusType = 'info';
  bool _isLoading = true;
  bool _isComplete = false;
  int _busCount = 0;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    final url = BookingScript.buildSearchUrl(
      widget.profile.from,
      widget.profile.to,
      widget.travelDate,
    );

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
      )
      ..addJavaScriptChannel(
        'ShohozbridgeChannel',
        onMessageReceived: (msg) => _handleMessage(msg.message),
      )
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) async {
          setState(() => _isLoading = false);
          await Future.delayed(const Duration(milliseconds: 1500));
          _injectScript();
        },
        onPageStarted: (_) => setState(() => _isLoading = true),
        onNavigationRequest: (req) {
          // Allow all Shohoz pages
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(url));
  }

  void _handleMessage(String raw) {
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final type = data['type'] as String;

      setState(() {
        switch (type) {
          case 'status':
            _statusMsg = data['message'] ?? '';
            _statusType = data['statusType'] ?? 'info';
            break;
          case 'busCount':
            _busCount = data['count'] ?? 0;
            break;
          case 'complete':
            _isComplete = true;
            _statusMsg = '🎉 শেষ! PROCEED TO PAYMENT চাপুন।';
            _statusType = 'success';
            break;
          case 'error':
            _statusMsg = '❌ ${data['message']}';
            _statusType = 'error';
            break;
        }
      });
    } catch (_) {}
  }

  Future<void> _injectScript() async {
    final script = BookingScript.generate(widget.profile.toJson());
    try {
      await _controller.runJavaScript(script);
    } catch (e) {
      debugPrint('Script injection error: $e');
    }
  }

  Color get _statusColor {
    switch (_statusType) {
      case 'success': return const Color(0xFF4ADE80);
      case 'error': return const Color(0xFFF87171);
      default: return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.profile.name,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            Text(
              '${widget.profile.from} → ${widget.profile.to}',
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: _injectScript,
            tooltip: 'Retry',
          ),
        ],
      ),

      // Status bar at top
      body: Column(
        children: [
          // Status card
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            color: const Color(0xFF1A1A2E),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                if (_isLoading)
                  const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF4ADE80),
                    ),
                  )
                else
                  Icon(
                    _isComplete ? Icons.check_circle : Icons.auto_fix_high,
                    color: _statusColor, size: 16,
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _statusMsg,
                    style: TextStyle(color: _statusColor, fontSize: 13),
                  ),
                ),
                if (_busCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE94560).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('$_busCount bus',
                        style: const TextStyle(color: Color(0xFFE94560), fontSize: 11)),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white12),

          // WebView
          Expanded(
            child: WebViewWidget(controller: _controller),
          ),

          // Payment button (shows when complete)
          if (_isComplete)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF1A1A2E),
              child: ElevatedButton(
                onPressed: () async {
                  await _controller.runJavaScript('''
                    const btn = [...document.querySelectorAll('button')]
                      .find(b => b.textContent.trim().toUpperCase().includes('PROCEED'));
                    if (btn) btn.click();
                  ''');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A859),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  '💳 PROCEED TO PAYMENT',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

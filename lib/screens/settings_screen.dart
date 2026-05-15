import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isActive = provider.isGlobalActive;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('⚙️ Settings', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Power button card
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isActive ? const Color(0xFF4ADE80) : Colors.white12,
                width: isActive ? 2 : 1,
              ),
              boxShadow: isActive ? [
                BoxShadow(color: const Color(0xFF4ADE80).withOpacity(0.15), blurRadius: 20, spreadRadius: 2),
              ] : null,
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(isActive ? '🚀' : '😴', style: const TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                Text(
                  isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: isActive ? const Color(0xFF4ADE80) : Colors.white54,
                    fontSize: 20, fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isActive
                      ? 'App চালু আছে — Search করলে কাজ করবে'
                      : 'App ঘুমাচ্ছে — Shohoz-এ গেলে কিছু হবে না',
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: provider.toggleGlobalActive,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? const Color(0xFF4ADE80).withOpacity(0.15)
                          : const Color(0xFF16213E),
                      border: Border.all(
                        color: isActive ? const Color(0xFF4ADE80) : Colors.white24,
                        width: 3,
                      ),
                      boxShadow: isActive ? [
                        BoxShadow(color: const Color(0xFF4ADE80).withOpacity(0.4), blurRadius: 20),
                      ] : null,
                    ),
                    child: Icon(
                      Icons.power_settings_new,
                      color: isActive ? const Color(0xFF4ADE80) : Colors.white38,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isActive ? 'Tap to deactivate' : 'Tap to activate',
                  style: TextStyle(
                    color: isActive ? const Color(0xFF4ADE80) : Colors.white38,
                    fontSize: 11, letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('📌 কীভাবে কাজ করে:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                SizedBox(height: 10),
                _InfoRow('১', 'App Active করুন'),
                _InfoRow('২', 'Profile তৈরি করুন (route, seat, passenger info)'),
                _InfoRow('৩', 'Search tab থেকে তারিখ দিয়ে খুঁজুন চাপুন'),
                _InfoRow('৪', 'App নিজেই bus খুঁজবে → seat নেবে → passenger fill করবে'),
                _InfoRow('৫', 'আপনি শুধু PROCEED TO PAYMENT চাপুন'),
                SizedBox(height: 10),
                Text('⚠️ Inactive থাকলে কোনো কাজ হবে না।',
                    style: TextStyle(color: Color(0xFFFBBF24), fontSize: 11)),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // App version
          Center(
            child: Text('Shohoz Auto-Booker v1.0.0',
                style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String number;
  final String text;
  const _InfoRow(this.number, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20, height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFFE94560).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(number,
                style: const TextStyle(color: Color(0xFFE94560), fontSize: 10, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white54, fontSize: 12))),
        ],
      ),
    );
  }
}

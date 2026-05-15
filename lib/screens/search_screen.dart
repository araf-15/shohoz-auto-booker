import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/profile.dart';
import 'booking_webview_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final Map<String, DateTime> _selectedDates = {};

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final profiles = provider.profiles;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Row(
          children: [
            Text('🚌', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Shohoz Auto-Booker',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('স্বয়ংক্রিয় টিকেট বুকিং',
                    style: TextStyle(fontSize: 10, color: Colors.white38)),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 10, height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: provider.isGlobalActive ? const Color(0xFF4ADE80) : Colors.grey,
              boxShadow: provider.isGlobalActive
                  ? [BoxShadow(color: const Color(0xFF4ADE80).withOpacity(0.6), blurRadius: 8)]
                  : null,
            ),
          ),
        ],
      ),
      body: profiles.isEmpty
          ? _buildEmpty()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: profiles.length,
              itemBuilder: (context, i) => _buildProfileCard(context, profiles[i], provider),
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🚌', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const Text('কোনো profile নেই', style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('"Profiles" tab থেকে তৈরি করুন',
              style: TextStyle(color: Colors.white38, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext ctx, BookingProfile profile, AppProvider provider) {
    final selectedDate = _selectedDates[profile.id] ??
        DateTime.now().add(Duration(days: profile.daysInAdvance));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile name & tags
          Row(
            children: [
              Expanded(
                child: Text(profile.name,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              ),
              if (profile.busType != 'any')
                _tag(profile.busType == 'ac' ? '❄️ AC' : '🌀 Non AC', Colors.blue),
            ],
          ),
          const SizedBox(height: 8),

          // Route
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFF4ADE80), size: 14),
              const SizedBox(width: 4),
              Text(profile.from, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.arrow_forward, color: Color(0xFFE94560), size: 14),
              ),
              Text(profile.to, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              if (profile.preferredOperator.isNotEmpty) ...[
                const Spacer(),
                Text(profile.preferredOperator,
                    style: const TextStyle(color: Color(0xFFE94560), fontSize: 11)),
              ],
            ],
          ),
          const SizedBox(height: 6),

          // Seat prefs
          Wrap(
            spacing: 4,
            children: [
              if (profile.seatPreferences.contains('window')) _tag('🪟 Window', Colors.purple),
              if (profile.seatPreferences.contains('front')) _tag('⬆️ সামনে', Colors.orange),
              if (profile.seatPreferences.contains('aisle')) _tag('🚶 Aisle', Colors.teal),
              if (profile.avoidBackSeats) _tag('🚫 পেছন নেই', Colors.red),
              _tag('🎟️ ${profile.ticketCount}টি', Colors.indigo),
            ],
          ),
          const SizedBox(height: 12),

          // Date picker + Search button
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (picked != null) setState(() => _selectedDates[profile.id] = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16213E),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.white38, size: 14),
                        const SizedBox(width: 8),
                        Text(
                          '${selectedDate.day} ${_monthName(selectedDate.month)} ${selectedDate.year}',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => _startSearch(ctx, profile, selectedDate, provider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE94560),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('🔍 খুঁজুন', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _startSearch(BuildContext ctx, BookingProfile profile, DateTime date, AppProvider provider) {
    if (!provider.isGlobalActive) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Extension Inactive! Settings থেকে Active করুন।'),
          backgroundColor: Color(0xFFE94560),
        ),
      );
      return;
    }

    Navigator.push(ctx, MaterialPageRoute(
      builder: (_) => BookingWebViewScreen(profile: profile, travelDate: date),
    ));
  }

  Widget _tag(String text, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(text, style: TextStyle(color: color.shade200, fontSize: 10)),
    );
  }

  String _monthName(int m) =>
      ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m-1];
}

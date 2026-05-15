import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/app_provider.dart';
import '../models/profile.dart';
import 'profile_form_screen.dart';

class ProfilesScreen extends StatelessWidget {
  const ProfilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final profiles = provider.profiles;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('📋 আমার Profiles', style: TextStyle(color: Colors.white, fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFFE94560)),
            onPressed: () => _openForm(context, null),
          ),
        ],
      ),
      body: profiles.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📭', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  const Text('কোনো profile নেই', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _openForm(context, null),
                    icon: const Icon(Icons.add),
                    label: const Text('নতুন Profile'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE94560)),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: profiles.length,
              itemBuilder: (ctx, i) => _buildCard(ctx, profiles[i], provider),
            ),
      floatingActionButton: profiles.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => _openForm(context, null),
              backgroundColor: const Color(0xFFE94560),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildCard(BuildContext ctx, BookingProfile p, AppProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(p.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 12, color: Color(0xFF4ADE80)),
                const SizedBox(width: 4),
                Text('${p.from} → ${p.to}',
                    style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 4,
              children: [
                _chip('🎟️ ${p.ticketCount}টি'),
                if (p.busType != 'any') _chip(p.busType == 'ac' ? '❄️ AC' : '🌀 Non AC'),
                if (p.avoidBackSeats) _chip('🚫 পেছন নেই'),
                if (p.preferredOperator.isNotEmpty) _chip('🚌 ${p.preferredOperator}'),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white38, size: 20),
              onPressed: () => _openForm(ctx, p),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Color(0xFFF87171), size: 20),
              onPressed: () => _confirmDelete(ctx, p, provider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white54, fontSize: 10)),
    );
  }

  void _openForm(BuildContext ctx, BookingProfile? existing) {
    Navigator.push(ctx, MaterialPageRoute(
      builder: (_) => ProfileFormScreen(existing: existing),
    ));
  }

  void _confirmDelete(BuildContext ctx, BookingProfile p, AppProvider provider) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Delete করবেন?', style: TextStyle(color: Colors.white)),
        content: Text('"${p.name}" মুছে ফেলবেন?',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
          TextButton(
            onPressed: () { provider.deleteProfile(p.id); Navigator.pop(ctx); },
            child: const Text('Delete', style: TextStyle(color: Color(0xFFF87171))),
          ),
        ],
      ),
    );
  }
}

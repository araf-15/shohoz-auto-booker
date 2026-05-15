import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/app_provider.dart';
import '../models/profile.dart';

class ProfileFormScreen extends StatefulWidget {
  final BookingProfile? existing;
  const ProfileFormScreen({super.key, this.existing});

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name, _from, _to, _operator;

  String _busType = 'any';
  int _ticketCount = 1;
  List<String> _seatPrefs = ['window', 'front'];
  bool _avoidBack = true;
  List<String> _departureTimes = [];
  List<Map<String, String>> _passengers = [
    {'firstName': '', 'lastName': '', 'gender': 'male'}
  ];
  bool _autoCheck = false;
  int _daysInAdvance = 1;

  final _timeOptions = ['06:00','07:00','08:00','09:00','10:00','21:00','22:00','23:00','00:00'];

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _name = TextEditingController(text: p?.name ?? '');
    _from = TextEditingController(text: p?.from ?? '');
    _to = TextEditingController(text: p?.to ?? '');
    _operator = TextEditingController(text: p?.preferredOperator ?? '');
    if (p != null) {
      _busType = p.busType;
      _ticketCount = p.ticketCount;
      _seatPrefs = List.from(p.seatPreferences);
      _avoidBack = p.avoidBackSeats;
      _departureTimes = List.from(p.preferredDepartureTimes);
      _autoCheck = p.autoCheckEnabled;
      _daysInAdvance = p.daysInAdvance;
      _passengers = p.passengers.map((px) => {
        'firstName': px.firstName,
        'lastName': px.lastName,
        'gender': px.gender,
      }).toList();
      _ensurePassengerCount();
    }
  }

  void _ensurePassengerCount() {
    while (_passengers.length < _ticketCount) {
      _passengers.add({'firstName': '', 'lastName': '', 'gender': 'male'});
    }
    while (_passengers.length > _ticketCount) {
      _passengers.removeLast();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(widget.existing == null ? '✨ নতুন Profile' : '✏️ Edit Profile',
            style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('💾 Save', style: TextStyle(color: Color(0xFF4ADE80), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _section('📋 Basic Info'),
            _field(_name, 'Profile নাম', 'যেমন: ঢাকা → চট্টগ্রাম'),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _field(_from, 'From', 'Dhaka')),
              const SizedBox(width: 10),
              Expanded(child: _field(_to, 'To', 'Chittagong')),
            ]),
            const SizedBox(height: 10),
            _field(_operator, 'Bus Operator (optional)', 'Hanif, SR Travels...', required: false),

            _section('🚌 Bus Type'),
            _busTypeSelector(),

            _section('🎟️ কতটি Ticket?'),
            _ticketCountSelector(),

            _section('💺 Seat Preference'),
            _seatPrefSelector(),
            const SizedBox(height: 8),
            _toggleRow('🚫 পিছনের seat এড়িয়ে চলবে', _avoidBack,
                (v) => setState(() => _avoidBack = v)),

            _section('⏰ পছন্দের Departure Time'),
            _timeSelector(),

            _section('👤 Passenger তথ্য'),
            ..._buildPassengerForms(),

            _section('⚙️ Auto-Check Settings'),
            _toggleRow('স্বয়ংক্রিয় Check সক্রিয়', _autoCheck,
                (v) => setState(() => _autoCheck = v)),
            if (_autoCheck) ...[
              const SizedBox(height: 8),
              _numberField('কতদিন আগে বুক করবে?', _daysInAdvance,
                  (v) => setState(() => _daysInAdvance = v)),
            ],

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE94560),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('💾 Profile Save করুন',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 10),
    child: Text(title, style: const TextStyle(
        color: Color(0xFFE94560), fontWeight: FontWeight.bold, fontSize: 13,
        letterSpacing: 0.5)),
  );

  Widget _field(TextEditingController ctrl, String label, String hint, {bool required = true}) {
    return TextFormField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
        filled: true,
        fillColor: const Color(0xFF16213E),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white12)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE94560))),
      ),
      validator: required ? (v) => v!.isEmpty ? '$label দিন' : null : null,
    );
  }

  Widget _busTypeSelector() {
    final opts = [('any', '🚌 যেকোনো'), ('ac', '❄️ AC'), ('nonac', '🌀 Non AC')];
    return Row(
      children: opts.map((o) => Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _busType = o.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: _busType == o.$1 ? const Color(0xFFE94560).withOpacity(0.15) : const Color(0xFF16213E),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _busType == o.$1 ? const Color(0xFFE94560) : Colors.white12),
            ),
            child: Text(o.$2, textAlign: TextAlign.center,
                style: TextStyle(color: _busType == o.$1 ? const Color(0xFFE94560) : Colors.white54, fontSize: 12)),
          ),
        ),
      )).toList(),
    );
  }

  Widget _ticketCountSelector() {
    return Row(
      children: [1, 2, 3, 4].map((n) => Expanded(
        child: GestureDetector(
          onTap: () => setState(() { _ticketCount = n; _ensurePassengerCount(); }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: _ticketCount == n ? const Color(0xFFE94560).withOpacity(0.15) : const Color(0xFF16213E),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _ticketCount == n ? const Color(0xFFE94560) : Colors.white12),
            ),
            child: Text('$n টি', textAlign: TextAlign.center,
                style: TextStyle(color: _ticketCount == n ? const Color(0xFFE94560) : Colors.white54)),
          ),
        ),
      )).toList(),
    );
  }

  Widget _seatPrefSelector() {
    final opts = [('window', '🪟 Window'), ('front', '⬆️ সামনে'), ('aisle', '🚶 Aisle'), ('any', '🎲 যেকোনো')];
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: opts.map((o) {
        final sel = _seatPrefs.contains(o.$1);
        return GestureDetector(
          onTap: () => setState(() {
            if (o.$1 == 'any') { _seatPrefs = ['any']; return; }
            _seatPrefs.remove('any');
            sel ? _seatPrefs.remove(o.$1) : _seatPrefs.add(o.$1);
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: sel ? const Color(0xFFE94560).withOpacity(0.15) : const Color(0xFF16213E),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: sel ? const Color(0xFFE94560) : Colors.white12),
            ),
            child: Text(o.$2, style: TextStyle(color: sel ? const Color(0xFFE94560) : Colors.white54, fontSize: 13)),
          ),
        );
      }).toList(),
    );
  }

  Widget _timeSelector() {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: _timeOptions.map((t) {
        final sel = _departureTimes.contains(t);
        return GestureDetector(
          onTap: () => setState(() => sel ? _departureTimes.remove(t) : _departureTimes.add(t)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: sel ? const Color(0xFFE94560).withOpacity(0.15) : const Color(0xFF16213E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: sel ? const Color(0xFFE94560) : Colors.white12),
            ),
            child: Text(t, style: TextStyle(color: sel ? const Color(0xFFE94560) : Colors.white54, fontSize: 12)),
          ),
        );
      }).toList(),
    );
  }

  List<Widget> _buildPassengerForms() {
    return List.generate(_ticketCount, (i) {
      final pax = _passengers[i];
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Passenger ${i + 1}',
                style: const TextStyle(color: Color(0xFFE94560), fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _inlineField('First Name', pax['firstName']!,
                  (v) => setState(() => _passengers[i]['firstName'] = v))),
              const SizedBox(width: 8),
              Expanded(child: _inlineField('Last Name', pax['lastName']!,
                  (v) => setState(() => _passengers[i]['lastName'] = v))),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              const Text('Gender:', style: TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(width: 12),
              _genderBtn('Male', pax['gender'] == 'male', () => setState(() => _passengers[i]['gender'] = 'male')),
              const SizedBox(width: 8),
              _genderBtn('Female', pax['gender'] == 'female', () => setState(() => _passengers[i]['gender'] = 'female')),
            ]),
          ],
        ),
      );
    });
  }

  Widget _inlineField(String label, String value, Function(String) onChanged) {
    return TextFormField(
      initialValue: value,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38, fontSize: 11),
        filled: true,
        fillColor: const Color(0xFF0F0F1A),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.white12)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.white12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE94560))),
      ),
    );
  }

  Widget _genderBtn(String label, bool sel, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: sel ? const Color(0xFF00A859) : const Color(0xFF0F0F1A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: sel ? const Color(0xFF00A859) : Colors.white12),
        ),
        child: Text(label, style: TextStyle(color: sel ? Colors.white : Colors.white38, fontSize: 12)),
      ),
    );
  }

  Widget _toggleRow(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13))),
          Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFFE94560)),
        ],
      ),
    );
  }

  Widget _numberField(String label, int value, Function(int) onChanged) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13))),
        const SizedBox(width: 12),
        Row(children: [
          IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.white38),
              onPressed: () { if (value > 1) onChanged(value - 1); }),
          Text('$value', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          IconButton(icon: const Icon(Icons.add_circle_outline, color: Color(0xFF4ADE80)),
              onPressed: () => onChanged(value + 1)),
        ]),
      ],
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final profile = BookingProfile(
      id: widget.existing?.id ?? const Uuid().v4(),
      name: _name.text.trim(),
      from: _from.text.trim(),
      to: _to.text.trim(),
      busType: _busType,
      preferredOperator: _operator.text.trim(),
      ticketCount: _ticketCount,
      seatPreferences: _seatPrefs,
      avoidBackSeats: _avoidBack,
      preferredDepartureTimes: _departureTimes,
      passengers: _passengers.map((p) => PassengerInfo(
        firstName: p['firstName'] ?? '',
        lastName: p['lastName'] ?? '',
        gender: p['gender'] ?? 'male',
      )).toList(),
      autoCheckEnabled: _autoCheck,
      daysInAdvance: _daysInAdvance,
    );

    context.read<AppProvider>().saveProfile(profile);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Profile save হয়েছে!'), backgroundColor: Color(0xFF00A859)),
    );
  }
}

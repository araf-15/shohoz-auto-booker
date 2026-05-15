// lib/services/booking_script.dart
// This is the core automation JavaScript that gets injected into Shohoz WebView

class BookingScript {
  /// Generate the full automation script for a given profile
  static String generate(Map<String, dynamic> profile) {
    final profileJson = _escapeJson(profile);
    return '''
(async function() {
  const sleep = ms => new Promise(r => setTimeout(r, ms));
  const log = (...a) => console.log('[SAB]', ...a);

  // Send message to Flutter
  function flutterMsg(type, data) {
    try {
      ShohozbridgeChannel.postMessage(JSON.stringify({ type, ...data }));
    } catch(e) {}
  }

  function showOverlay(msg, type) {
    let el = document.getElementById('sab-overlay');
    if (!el) {
      el = document.createElement('div');
      el.id = 'sab-overlay';
      el.style.cssText = [
        'position:fixed','top:12px','right:12px','z-index:2147483647',
        'background:#0f172a','color:#e2e8f0',
        'padding:12px 16px','border-radius:12px',
        'font-family:sans-serif','font-size:13px',
        'box-shadow:0 4px 24px rgba(0,0,0,.7)',
        'border:1px solid rgba(255,255,255,.1)',
        'max-width:260px','min-width:180px'
      ].join(';');
      document.body.appendChild(el);
    }
    const color = type === 'error' ? '#f87171' : type === 'success' ? '#4ade80' : '#e2e8f0';
    el.innerHTML = '<div style="font-size:10px;color:#4ade80;font-weight:700;margin-bottom:4px;">🚌 SHOHOZ AUTO-BOOKER</div>'
      + '<div style="color:' + color + '">' + msg + '</div>';
    flutterMsg('status', { message: msg, statusType: type || 'info' });
  }

  const profile = $profileJson;

  try {
    const url = window.location.href;

    if (url.includes('/trip-info') || url.includes('/passenger')) {
      await handlePassengerPage();
    } else if (url.includes('/search') || url.includes('fromcity')) {
      await handleSearchResults();
    }
  } catch(err) {
    log('Error:', err.message);
    showOverlay('❌ ' + err.message, 'error');
    flutterMsg('error', { message: err.message });
  }

  // ── Search Results: try each bus ─────────────────────────────
  async function handleSearchResults() {
    showOverlay('⏳ Bus list লোড হচ্ছে...');

    let bookBtns = [];
    for (let i = 0; i < 20; i++) {
      await sleep(800);
      bookBtns = [...document.querySelectorAll('button.btn-book-ticket')];
      if (bookBtns.length > 0) break;
    }
    if (bookBtns.length === 0) throw new Error('কোনো bus পাওয়া যায়নি');

    // AC/Non-AC filter
    const busType = profile.busType || 'any';
    if (busType !== 'any') {
      const cbId = busType === 'ac' ? 'bus-type-1' : 'bus-type-2';
      const cb = document.getElementById(cbId);
      if (cb && !cb.checked) { cb.click(); await sleep(1200); }
      bookBtns = [...document.querySelectorAll('button.btn-book-ticket')];
      if (bookBtns.length === 0) throw new Error(busType.toUpperCase() + ' bus পাওয়া যায়নি');
    }

    // Score and sort buses
    const scored = bookBtns.map(btn => {
      let el = btn;
      for (let i = 0; i < 7; i++) {
        if (!el.parentElement) break;
        el = el.parentElement;
        const r = el.getBoundingClientRect();
        if (r.width > 400 && r.height > 80 && r.height < 400) break;
      }
      const text = (el.innerText||'').toLowerCase();
      const op = (profile.preferredOperator||'').toLowerCase();
      let sc = 0;
      if (op && text.includes(op)) sc += 20;
      (profile.preferredDepartureTimes||[]).forEach(t => { if (text.includes(t)) sc += 10; });
      if (!text.includes('sold out')) sc += 5;
      return { btn, score: sc };
    }).sort((a,b) => b.score - a.score);

    flutterMsg('busCount', { count: scored.length });
    showOverlay('✅ ' + scored.length + 'টি bus। Seat খুঁজছি...');

    for (let i = 0; i < scored.length; i++) {
      showOverlay('🚌 Bus ' + (i+1) + '/' + scored.length + ' check করছি...');
      scored[i].btn.click();
      await sleep(2000);

      // Ensure Seats tab
      const seatsTab = [...document.querySelectorAll('li')].find(li => li.querySelector('img[src*="seat.svg"]'));
      if (seatsTab && !seatsTab.classList.contains('active-trip-tab')) {
        seatsTab.click(); await sleep(600);
      }

      const available = [...document.querySelectorAll('button.btn-seat.seat-available')]
        .filter(btn => { const r = btn.getBoundingClientRect(); return r.width > 0 && r.top > 0; });

      const count = profile.ticketCount || 1;

      if (available.length < count) {
        showOverlay('⚠️ Bus ' + (i+1) + ': ' + available.length + 'টি seat — পরের bus...');
        await closeDrawer(); await sleep(400); continue;
      }

      try {
        const group = findAdjacentGroup(available, count);
        showOverlay('💺 ' + group.map(s => s.label).join('+') + ' select করছি...');

        for (const seat of group) { seat.btn.click(); await sleep(350); }
        await sleep(400);

        const cont = document.querySelector('button.stepper-continue-btn');
        if (!cont || cont.disabled) throw new Error('Continue disabled');

        showOverlay('✅ Seat নেওয়া হয়েছে! Boarding point...');
        cont.click(); await sleep(800);
        await handleBoardingPoint();
        return;

      } catch(e) {
        showOverlay('⚠️ Bus ' + (i+1) + ': ' + e.message);
        await closeDrawer(); await sleep(400);
      }
    }
    throw new Error('সব bus-এ try হয়েছে — ' + (profile.ticketCount||1) + 'টি পাশাপাশি seat নেই');
  }

  // ── Adjacent Seat Finder ──────────────────────────────────────
  function findAdjacentGroup(available, count) {
    const prefs = profile.seatPreferences || [];
    const avoidBack = profile.avoidBackSeats !== false;

    const posData = available.map(btn => {
      const r = btn.getBoundingClientRect();
      return { label: btn.textContent.trim(), x: Math.round(r.left), y: Math.round(r.top), btn };
    }).filter(s => s.x > 0 && s.y > 0);

    const byY = {};
    posData.forEach(s => {
      const yKey = Math.round(s.y / 8) * 8;
      if (!byY[yKey]) byY[yKey] = [];
      byY[yKey].push(s);
    });

    const sortedYs = Object.keys(byY).map(Number).sort((a,b) => a-b);
    const totalRows = sortedYs.length;
    const candidates = [];

    sortedYs.forEach((yKey, rowIdx) => {
      const isBack = rowIdx >= totalRows - 1;
      if (avoidBack && isBack) return;
      const frontScore = (totalRows - 1 - rowIdx) * 5;
      const row = byY[yKey].sort((a,b) => a.x - b.x);

      if (count === 1) {
        row.forEach(s => {
          let sc = 0;
          if (prefs.includes('front')) sc += frontScore;
          const isWindow = row.indexOf(s) === 0 || row.indexOf(s) === row.length - 1;
          if (prefs.includes('window') && isWindow) sc += 10;
          candidates.push({ seats: [s], score: sc });
        });
      } else {
        for (let i = 0; i <= row.length - count; i++) {
          const group = row.slice(i, i + count);
          let maxGap = 0;
          for (let j = 1; j < group.length; j++) maxGap = Math.max(maxGap, group[j].x - group[j-1].x);
          if (maxGap > 90) continue;
          let sc = frontScore + 5;
          const isWindow = group[0] === row[0] || group[group.length-1] === row[row.length-1];
          if (prefs.includes('window') && isWindow) sc += 8;
          if (prefs.includes('front')) sc += frontScore;
          candidates.push({ seats: group, score: sc });
        }
      }
    });

    if (candidates.length === 0) {
      if (count > 1) throw new Error(count + 'টি পাশাপাশি seat নেই');
      throw new Error('কোনো seat নেই');
    }

    candidates.sort((a,b) => b.score - a.score);
    return candidates[0].seats;
  }

  // ── Boarding Point ────────────────────────────────────────────
  async function handleBoardingPoint() {
    for (let i = 0; i < 15; i++) {
      await sleep(400);
      if (document.querySelector('.boarding-point-item')) break;
    }
    const firstItem = document.querySelector('.boarding-point-item');
    const bpRadio = firstItem?.querySelector('.bp-radio');
    if (!bpRadio) throw new Error('Boarding point radio নেই');
    bpRadio.click(); await sleep(400);
    const cont = document.querySelector('button.stepper-continue-btn');
    if (!cont || cont.disabled) throw new Error('Boarding continue disabled');
    showOverlay('✅ Boarding select! Passenger page...');
    cont.click();
  }

  // ── Close Drawer ──────────────────────────────────────────────
  async function closeDrawer() {
    const closeBtn = [...document.querySelectorAll('button')]
      .find(b => (b.className||'').includes('w-14') && (b.className||'').includes('h-10'));
    if (closeBtn) closeBtn.click();
    else document.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape', bubbles: true }));
    for (let i = 0; i < 15; i++) {
      await sleep(300);
      if (!document.querySelectorAll('button.btn-seat').length) break;
    }
  }

  // ── Passenger Page ────────────────────────────────────────────
  async function handlePassengerPage() {
    showOverlay('👤 Passenger তথ্য fill করছি...');
    await sleep(2000);

    const passengers = profile.passengers || [];
    const count = profile.ticketCount || 1;

    const allGenderBtns = [...document.querySelectorAll('button')]
      .filter(b => ['male','female'].includes(b.textContent.trim().toLowerCase()));

    for (let i = 0; i < count; i++) {
      const pax = passengers[i] || passengers[0] || { firstName: '', lastName: '', gender: 'male' };
      const fnInput = document.getElementById('first_name-' + i);
      const lnInput = document.getElementById('last_name-' + i);
      const setter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
      if (fnInput && pax.firstName) {
        fnInput.focus();
        setter.call(fnInput, pax.firstName);
        fnInput.dispatchEvent(new Event('input', { bubbles: true }));
        fnInput.dispatchEvent(new Event('change', { bubbles: true }));
        fnInput.blur();
        await sleep(400);
      }
      if (lnInput && pax.lastName) {
        lnInput.focus();
        setter.call(lnInput, pax.lastName);
        lnInput.dispatchEvent(new Event('input', { bubbles: true }));
        lnInput.dispatchEvent(new Event('change', { bubbles: true }));
        lnInput.blur();
        await sleep(400);
      }
      const gender = (pax.gender || 'male').toLowerCase();
      const gBtn = gender === 'female' ? allGenderBtns[i*2+1] : allGenderBtns[i*2];
      if (gBtn) { gBtn.click(); await sleep(200); }
    }

    showOverlay('🎉 শেষ! PROCEED TO PAYMENT চাপুন।', 'success');
    flutterMsg('complete', { success: true });

    const proceedBtn = [...document.querySelectorAll('button')]
      .find(b => b.textContent.trim().toUpperCase().includes('PROCEED'));
    if (proceedBtn) {
      proceedBtn.style.boxShadow = '0 0 20px #00a859, 0 0 40px #00a859';
    }
  }

})();
''';
  }

  static String _escapeJson(Map<String, dynamic> data) {
    import 'dart:convert';
    return jsonEncode(data)
        .replaceAll(r'\', r'\\')
        .replaceAll("'", r"\'");
  }

  /// Build Shohoz search URL
  static String buildSearchUrl(String from, String to, DateTime date) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final d = '${date.day.toString().padLeft(2,'0')}-${months[date.month-1]}-${date.year}';
    return 'https://www.shohoz.com/bus-tickets/booking/bus/search'
        '?fromcity=${Uri.encodeComponent(from)}'
        '&tocity=${Uri.encodeComponent(to)}'
        '&doj=$d&dor=';
  }
}

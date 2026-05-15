# 🚌 Shohoz Auto-Booker — Flutter App

Shohoz.com থেকে স্বয়ংক্রিয়ভাবে বাস টিকেট বুক করার Android app।

## APK Download করতে (GitHub Actions):

### ধাপ ১ — Repository তৈরি করো
1. GitHub-এ login করো
2. **New Repository** → নাম দাও: `shohoz-auto-booker`
3. **Public** রাখো → **Create repository**

### ধাপ ২ — Code upload করো
```bash
cd shohoz_app
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/shohoz-auto-booker.git
git push -u origin main
```

### ধাপ ৩ — APK নামাও
1. GitHub-এ তোমার repository খোলো
2. **Actions** tab-এ click করো
3. Build শেষ হলে **Releases** থেকে APK download করো
4. অথবা Actions → Latest run → **Artifacts** থেকে download করো

---

## Features:
- ✅ Multiple Profile (route, seat preference, passenger info)
- ✅ AC/Non-AC filter
- ✅ পাশাপাশি seat auto-selection (2, 3, 4 tickets)
- ✅ Multiple passenger form fill
- ✅ Bus-by-bus try (একটায় না পেলে পরেরটা)
- ✅ Active/Inactive global toggle
- ✅ সামনের seat preference

## Phone-এ Install:
1. Settings → Security → **Unknown sources** allow করো
2. APK file tap করো → Install

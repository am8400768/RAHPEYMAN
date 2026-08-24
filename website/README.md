# سایت مستقل رهپیمان

این پوشه frontend وب مستقل از Flutter موبایل است و با JavaScript خام نوشته شده
است؛ بنابراین به `lib` یا `mobile/lib` وابستگی ندارد.

## اجرا در حالت توسعه

ابتدا در `config.js` آدرس backend را تنظیم کنید:

```js
window.RAHPYMAN_CONFIG = {
  apiBaseUrl: 'http://localhost:8000',
};
```

سپس پوشه‌ی `website` را با یک static server اجرا کنید. برای نمونه:

```powershell
python -m http.server 5500
```

و آدرس زیر را باز کنید:

```text
http://localhost:5500
```

بازکردن مستقیم `index.html` با `file://` به‌دلیل محدودیت‌های مرورگر برای
درخواست‌های API توصیه نمی‌شود.

## احراز هویت

- ورود و ثبت‌نام با OTP شماره موبایل انجام می‌شود.
- JWT فقط در `sessionStorage` نگهداری می‌شود و با بستن تب حذف می‌شود.
- شناسه‌ی نصب مرورگر در `localStorage` قرار می‌گیرد تا ثبت‌نام دوم با همان
  browser profile توسط backend شناسایی شود.
- backend همچنان شماره موبایل و IP/User-Agent را کنترل و ثبت می‌کند.

شناسه‌ی مرورگر جایگزین attestation موبایل نیست؛ پاک‌کردن localStorage یا تغییر
مرورگر می‌تواند آن را تغییر دهد. امنیت اصلی وب بر پایه‌ی OTP، JWT، HTTPS و
کنترل سمت backend است.
